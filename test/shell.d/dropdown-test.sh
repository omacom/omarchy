#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

qml_test_runner=""
for candidate in /usr/lib/qt6/bin/qmltestrunner /usr/lib/qt6/qmltestrunner; do
  if [[ -x $candidate ]]; then
    qml_test_runner=$candidate
    break
  fi
done

if [[ -z $qml_test_runner ]]; then
  skip "Qt6 qmltestrunner not found; skipping dropdown popup geometry tests"
  exit 0
fi

fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/qs/Commons" "$fixture/qs/Ui" "$fixture/home"
cp "$SHELL_TEST_DIR/dropdown/Commons/"* "$fixture/qs/Commons/"
cp "$ROOT/shell/Commons/Border.qml" "$ROOT/shell/Commons/BorderGeometry.js" "$fixture/qs/Commons/"
cp "$ROOT/shell/Ui/Dropdown.qml" "$ROOT/shell/Ui/BorderSurface.qml" "$ROOT/shell/Ui/BorderOverlay.qml" "$fixture/qs/Ui/"
cp "$SHELL_TEST_DIR/dropdown/qml/"* "$fixture/"

output=$(HOME="$fixture/home" XDG_CONFIG_HOME="$fixture/home/.config" XDG_STATE_HOME="$fixture/home/.state" \
  QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software QT_QUICK_CONTROLS_STYLE=Basic \
  "$qml_test_runner" -import "$fixture" -input "$fixture" -o -,txt 2>&1) ||
  fail "dropdown popup fits short lists and preserves capped scrolling" "$output"
printf '%s\n' "$output" | sed -n '/^Totals:/p'
pass "dropdown popup fits short lists and preserves capped scrolling"
