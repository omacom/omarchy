#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# /usr/bin/qmltestrunner is the Qt 5 binary, which exits 0 having run nothing.
qml_test_runner=""
for candidate in /usr/lib/qt6/bin/qmltestrunner /usr/lib/qt6/qmltestrunner; do
  if [[ -x $candidate ]]; then
    qml_test_runner=$candidate
    break
  fi
done

if [[ -z $qml_test_runner ]]; then
  skip "qt6 qmltestrunner not found; skipping dock app grid wheel tests"
  exit 0
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Lift the app grid's own WheelHandler out of AppGrid.qml, so the test drives
# the shipped handler rather than a copy of it.
handler=$(awk '
  !found && /^ *WheelHandler \{$/ { found = 1; indent = index($0, "W") }
  found { print }
  found && index($0, "}") == indent && /^ *\}$/ { exit }
' "$ROOT/shell/plugins/dock/AppGrid.qml")
[[ -n $handler ]] || fail "the dock's app grid has a WheelHandler"

cat >"$TMPDIR/tst_dock_wheel.qml" <<QML
import QtQuick
import QtTest

Item {
  id: root
  width: 700
  height: 440

  readonly property int cellHeight: 110

  GridView {
    id: grid
    anchors.fill: parent
    model: 70
    cellWidth: 100
    cellHeight: root.cellHeight
    boundsBehavior: Flickable.StopAtBounds
    delegate: Item { width: 100; height: root.cellHeight }

$handler
  }

  TestCase {
    name: "DockAppGridWheel"
    when: windowShown

    function init() {
      grid.cancelFlick()
      grid.contentY = 0
    }

    function test_a_notch_moves_one_row_at_once() {
      mouseWheel(grid, 350, 220, 0, -120)
      compare(grid.contentY, root.cellHeight, "one notch down moves one row straight away")
      wait(400)
      compare(grid.contentY, root.cellHeight, "and the grid does not glide on afterwards")
      verify(!grid.moving, "no flick is left running")
      mouseWheel(grid, 350, 220, 0, 120)
      compare(grid.contentY, 0, "one notch up moves the row back")
    }

    function test_the_grid_stops_at_both_ends() {
      mouseWheel(grid, 350, 220, 0, 120)
      compare(grid.contentY, 0, "the top is the limit going up")
      for (var i = 0; i < 20; i++) mouseWheel(grid, 350, 220, 0, -120)
      compare(grid.contentY, grid.contentHeight - grid.height, "the last row is the limit going down")
    }

  }
}
QML

output=$(QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software "$qml_test_runner" -input "$TMPDIR/tst_dock_wheel.qml" -o -,txt 2>&1) ||
  fail "the dock's app grid scrolls a row per wheel notch" "$output"
pass "the dock's app grid scrolls a row per wheel notch"
