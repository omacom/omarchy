#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping rendered ModuleSlot coverage"
  exit 0
fi
require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
ln -s "$ROOT/shell/Ui" "$test_tmp/Ui"
ln -s "$ROOT/shell/Commons" "$test_tmp/Commons"
ln -s "$ROOT/shell/plugins/bar/BarModel.js" "$test_tmp/BarModel.js"

cat >"$test_tmp/shell.qml" <<'QML'
import QtQuick
import Quickshell
import qs.Commons
import qs.Ui
import "BarModel.js" as BarModel

ShellRoot {
  function check(host) {
    // The contract is two scaled 6px bearings, independent of the slot
    // implementation. A changed production half-gap must fail this test.
    var expectedGap = 2 * Style.space(6)
    var slots = host.layoutItem.children
    var previous = null
    var count = 0
    for (var i = 0; i < slots.length; i++) {
      var slot = slots[i]
      if (!("activeItem" in slot)) continue
      if (!slot.activeItem || !(slot.paintedExtent > 0)) throw new Error("slot did not load: " + slot.moduleName)
      count++
      var item = slot.activeItem
      var center = item.mapToItem(host, item.width / 2, item.height / 2)
      var leading = (host.vertical ? center.y : center.x) - slot.paintedExtent / 2
      var trailing = (host.vertical ? center.y : center.x) + slot.paintedExtent / 2
      // Positioners and Loader centering can round opposite edges by a
      // pixel; larger errors must fail rather than recalculate slot padding.
      if (previous !== null && Math.abs(leading - previous - expectedGap) > 1.01)
        throw new Error((host.vertical ? "vertical" : "horizontal") + " gap before " + slot.moduleName + ": " + (leading - previous))
      previous = trailing
    }
    if (count !== host.entries.length) throw new Error("missing rendered slots: " + count)
  }

  Timer {
    interval: 300
    running: true
    onTriggered: {
      try {
        check(horizontal)
        check(vertical)
        console.log("RESULT pass real ModuleSlot horizontal and vertical layout")
      } catch (error) {
        console.log("RESULT fail " + error)
      }
      Qt.quit()
    }
  }

  Window {
    visible: true
    width: 1100
    height: 700
    SlotHost { id: horizontal; width: 1000; height: 60 }
    SlotHost { id: vertical; y: 80; width: 100; height: 600; vertical: true }
  }

  component SlotHost: Item {
    id: root
    property bool vertical: false
    property int barSize: vertical ? Style.bar.sizeVertical : Style.bar.sizeHorizontal
    property string fontFamily: Style.font.family
    property color barForeground: "white"
    property color urgent: "red"
    property color background: "black"
    property bool transparent: false
    property bool foregroundAnimationEnabled: false
    property var shell: null
    property var barDragSource: null
    property var activePopout: null
    property string omarchyPath: ""
    readonly property var layoutItem: layoutLoader.item
    function entryId(entry) { return entry.id }
    function entrySettings(entry) { return entry.settings || {} }
    function customModuleType(entry) { return "" }
    function canonicalWidgetId(id) { return id }
    function registerModuleSlot(slot) {}
    function unregisterModuleSlot(slot) {}
    function registerClickTarget(target) {}
    function unregisterClickTarget(target) {}
    function showTooltip(target, text) {}
    function hideTooltip(target) {}
    function clearBarDrag() {}
    function moduleClickTargetAt(slot, x, y) { return null }
    function pressModuleClickTarget(slot, button, x, y) { return false }
    property QtObject barWidgetRegistry: QtObject {
      property var widgets: ({ glyph: { component: glyph }, pill: { component: pill }, vector: { component: vector }, wrapped: { component: wrapped }, stack: { component: stack } })
      function metadataFor(id) { return { firstParty: true } }
    }
    Component { id: glyph; BarIconButton { text: "x" } }
    Component { id: pill; WidgetButton { text: "AB" } }
    Component { id: vector; BarIconButton { iconComponent: Component { Rectangle { implicitWidth: 12; implicitHeight: 12 } } } }
    Component { id: wrapped; BarIconButton { iconComponent: Component { Item { Rectangle { anchors.centerIn: parent; implicitWidth: 11; implicitHeight: 11 } } } } }
    Component { id: stack; WidgetButton { text: "A\nB" } }
    Component { id: emptyModuleComponent; Item {} }
    component CustomCommandModule: Item { required property var entry }
    readonly property var entries: [{ id: "glyph" }, { id: "pill" }, { id: "vector" }, { id: "wrapped" }, { id: "stack" }]
    Loader {
      id: layoutLoader
      sourceComponent: root.vertical ? columnLayout : rowLayout
    }
    Component {
      id: rowLayout
      Row {
        spacing: 0
        Repeater { model: root.entries; delegate: ModuleSlot { required property var modelData; entry: modelData } }
      }
    }
    Component {
      id: columnLayout
      Column {
        spacing: 0
        Repeater { model: root.entries; delegate: ModuleSlot { required property var modelData; entry: modelData } }
      }
    }
    // MODULE_SLOT
  }
}
QML

# Compile the complete production inline component, including its Loader
# centering and implicit-size bindings. The fixture stubs only host services.
python3 - "$ROOT/shell/plugins/bar/Bar.qml" "$test_tmp/shell.qml" <<'PY'
import sys
from pathlib import Path
source = Path(sys.argv[1]).read_text()
start = source.index('  component ModuleSlot: Item {')
end = source.index('\n  component CustomCommandModule:', start)
p = Path(sys.argv[2])
fixture = p.read_text()
host_start = fixture.index('  component SlotHost: Item {')
host = fixture[host_start:].removeprefix('  component SlotHost: ').rsplit('\n}', 1)[0]
imports = fixture[:fixture.index('ShellRoot {')]
(p.parent / 'SlotHost.qml').write_text(imports + host.replace('    // MODULE_SLOT', source[start:end]))
p.write_text(fixture[:host_start] + '}\n')
PY

output=$(QT_QPA_PLATFORM=offscreen timeout 15 env \
  QML2_IMPORT_PATH="$ROOT/shell${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
  QML_IMPORT_PATH="$ROOT/shell${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
  quickshell -p "$test_tmp" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "real bar slot layout fixture exits cleanly"
}
if ! rg -q 'RESULT pass' <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "real bar slots preserve ink gaps on both axes"
fi
pass "real bar slots preserve ink gaps on both axes"
