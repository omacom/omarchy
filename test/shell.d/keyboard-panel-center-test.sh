#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_compositor "keyboard panel centering test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping keyboard panel centering test"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

ln -s "$ROOT/shell/Ui" "$test_tmp/Ui"
ln -s "$ROOT/shell/Commons" "$test_tmp/Commons"

cat >"$test_tmp/shell.qml" <<'QML'
import QtQuick
import Quickshell
import qs.Ui

ShellRoot {
  id: root

  function fail(message) {
    console.log("RESULT fail " + message)
    Qt.quit()
  }

  // Wait for the bar window to map, so the anchors have real positions on it.
  Timer {
    property int waited: 0
    running: true
    repeat: true
    interval: 100
    onTriggered: {
      if (barWindow.width <= 0) {
        if (++waited > 100) { stop(); root.fail("fixture bar window did not map") }
        return
      }
      stop()
      Qt.callLater(root.check)
    }
  }

  function check() {
    var centeredX = inCenter.cardOrigin.x
    if (onRight.cardOrigin.x <= centeredX) return fail("a widget moved to the right section still opens its panel centered")
    if (onLeft.cardOrigin.x >= centeredX) return fail("a widget moved to the left section still opens its panel centered")
    if (unlisted.cardOrigin.x !== centeredX) return fail("a widget missing from the layout stopped centering its panel")
    testBar.layoutConfig = { left: ["test.left"], center: [{ id: "test.center" }, { id: "test.right" }], right: [] }
    if (onRight.cardOrigin.x !== centeredX) return fail("a widget moved back to the center section does not center its panel again")
    console.log("RESULT pass")
    Qt.quit()
  }

  QtObject {
    id: testBar
    property string position: "top"
    property var layoutConfig: ({
      left: ["test.left"],
      center: [{ id: "test.center" }],
      right: [{ id: "test.right" }]
    })
  }

  PanelWindow {
    id: barWindow
    anchors { top: true; left: true; right: true }
    implicitHeight: 30
    color: "transparent"

    Item { id: leftAnchor; x: 40; width: 20; height: 20 }
    Item { id: rightAnchor; x: barWindow.width - 60; width: 20; height: 20 }
  }

  QtObject { id: centerOwner; property string moduleName: "test.center" }
  QtObject { id: rightOwner; property string moduleName: "test.right" }
  QtObject { id: leftOwner; property string moduleName: "test.left" }
  QtObject { id: unlistedOwner; property string moduleName: "test.unlisted" }

  KeyboardPanel { id: inCenter; anchorItem: rightAnchor; bar: testBar; owner: centerOwner; centerOnBar: true; contentWidth: 40 }
  KeyboardPanel { id: onRight; anchorItem: rightAnchor; bar: testBar; owner: rightOwner; centerOnBar: true; contentWidth: 40 }
  KeyboardPanel { id: onLeft; anchorItem: leftAnchor; bar: testBar; owner: leftOwner; centerOnBar: true; contentWidth: 40 }
  KeyboardPanel { id: unlisted; anchorItem: rightAnchor; bar: testBar; owner: unlistedOwner; centerOnBar: true; contentWidth: 40 }
}
QML

output=$(timeout 15 env \
  QML2_IMPORT_PATH="$ROOT/shell${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
  QML_IMPORT_PATH="$ROOT/shell${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
  quickshell -p "$test_tmp" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "keyboard panel centering fixture exits cleanly"
}

if ! grep -q 'RESULT pass' <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "a centered panel follows its widget out of the bar's center section"
fi

pass "a centered panel follows its widget out of the bar's center section"
