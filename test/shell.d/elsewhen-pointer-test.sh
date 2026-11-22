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
  skip "qt6 qmltestrunner not found; skipping elsewhen pointer tests"
  exit 0
fi

fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
cp "$SHELL_TEST_DIR/elsewhen/qml/"* "$fixture/"
cp "$ROOT/shell/plugins/panels/elsewhen/Model.js" "$fixture/"
printf '%s\n' 'singleton Style 1.0 Style.qml' > "$fixture/qmldir"
cat > "$fixture/Style.qml" <<'QML'
pragma Singleton
import QtQuick
QtObject { function space(value) { return value } }
QML

# Exercise the production grab without loading the row's unrelated shell UI.
cat > "$fixture/CityRowGrab.qml" <<'QML'
import QtQuick
import "."
import "Model.js" as Model
Item {
  id: row
  property var panel
  property int index: 0
  property bool dragged: false
  property alias grab: grab
  width: 300
  height: 100
  Item {
    id: strip
    y: 80
    property int shownChip: Model.NO_CHIP
    function dismissUnlessChanged(chip) { row.panel.events.push("finish") }
  }
QML
sed -n '/^  MouseArea {/,/^  }$/p' "$ROOT/shell/plugins/panels/elsewhen/CityRow.qml" >> "$fixture/CityRowGrab.qml"
printf '}\n' >> "$fixture/CityRowGrab.qml"

output=$(QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software "$qml_test_runner" -input "$fixture" -o -,txt 2>&1) ||
  fail "elsewhen pointer tests" "$output"
pass "elsewhen pointer tests"
