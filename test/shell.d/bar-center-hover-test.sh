#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"
require_command quickshell
require_command python3

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
ln -s "$ROOT/shell/Commons" "$scratch/Commons"

# Exercise the production section placement and hover handlers. Only the
# module contents and host services are stubbed; pointer events come from Qt.
python3 - "$ROOT" "$scratch" <<'PY'
from pathlib import Path
import sys
root, scratch = map(Path, sys.argv[1:])
source = (root / 'shell/plugins/bar/Bar.qml').read_text()
horizontal = source[source.index('    Component {\n      id: horizontalBar'):source.index('    Component {\n      id: verticalBar')]
center = source[source.index('  component CenterModules: Item {'):source.index('  component CenterGestureArea: MouseArea {')]
(scratch / 'BarHost.qml').write_text('''import QtQuick
import qs.Commons
Item {
  id: root
  property bool moved: false
  property bool vertical: false
  property string centerAnchor: "clock"
  property bool sectionHovered: false
  property bool revealed: false
  QtObject { id: barWindow; property bool centerBesideRight: root.moved }
  function setCenterSectionHovered(value) { sectionHovered = value; if (value) revealed = true }
  function entryIndex(entries, id) { return entries.indexOf(id) }
  function findCenterAnchorEntry(entries) { return entries.indexOf(centerAnchor) < 0 ? null : centerAnchor }
  function entriesBefore(entries, id) { return entries.slice(0, entries.indexOf(id)) }
  function entriesAfter(entries, id) { return entries.slice(entries.indexOf(id) + 1) }
  function layoutEntries(region) { return region === "center" ? ["indicators", "clock"] : [region] }
  Loader { anchors.fill: parent; sourceComponent: horizontalBar }
  component CenterGestureArea: Item {}
  component ModuleSlot: Rectangle {
    property var entry
    property string region
    implicitWidth: entry ? 60 : 0
    implicitHeight: entry ? 30 : 0
    color: "steelblue"
    MouseArea { anchors.fill: parent; hoverEnabled: true }
  }
  component ModuleList: Row {
    property var entries: []
    property string region
    Repeater { model: entries; delegate: ModuleSlot { required property var modelData; entry: modelData } }
  }
  component LeftModules: ModuleList { entries: root.layoutEntries("left"); region: "left" }
  component RightModules: ModuleList { entries: root.layoutEntries("right"); region: "right" }
''' + horizontal + center + '}\n')
(scratch / 'shell.qml').write_text('''import QtQuick
import QtTest
import Quickshell
ShellRoot {
  Window {
    id: window
    visible: true
    width: 800; height: 120
    BarHost { id: bar; width: 800; height: 30; moved: true }
    Timer {
      interval: 300
      running: true
      onTriggered: {
        try { checks.test_centerHover() }
        catch (error) { console.log("RESULT fail " + error) }
        Qt.quit()
      }
    }
    TestCase {
      id: checks
      name: "CenterHover"
      when: false
      function check(value, message) { if (!value) throw new Error(message) }
      function test_centerHover() {
        wait(100)
        mouseMove(bar, 400, 15)
        wait(30)
        check(!bar.sectionHovered && !bar.revealed, "empty middle must not reveal moved indicators")
        mouseMove(bar, 650, 15)
        check(bar.sectionHovered, "center section did not receive hover")
        check(bar.revealed, "moved center widgets must reveal indicators")
        mouseMove(bar, 400, 90)
        wait(50)
        check(!bar.sectionHovered, "center section retained hover after leaving")
        bar.revealed = false
        bar.moved = false
        wait(30)
        mouseMove(bar, 650, 15)
        wait(30)
        check(!bar.sectionHovered && !bar.revealed, "empty relocated list must not retain hover")
        mouseMove(bar, 250, 15)
        check(bar.sectionHovered, "ordinary center section did not receive hover")
        check(bar.revealed, "ordinary center region still reveals indicators")
        console.log("RESULT pass center hover follows relocated widgets")
        Qt.quit()
      }
    }
  }
}
''')
PY
output=$(QT_QPA_PLATFORM=offscreen QML_IMPORT_PATH="$ROOT/shell" QML2_IMPORT_PATH="$ROOT/shell" timeout 15 quickshell -p "$scratch" --no-color 2>&1) || {
  fail 'bar center hover fixture exits cleanly' "$output"
}
rg -q 'RESULT pass' <<<"$output" || fail 'center hover follows relocated widgets' "$output"
pass 'center hover follows relocated widgets and leaves the empty middle inactive'
