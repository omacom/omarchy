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
  skip "qt6 qmltestrunner not found; skipping menu scroll tests"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# Splice revealCursor() out of Menu.qml itself, so the test cannot drift from the menu.
awk '/^  function revealCursor\(\) \{/,/^  \}$/' "$ROOT/shell/plugins/menu/Menu.qml" >"$test_tmp/reveal-cursor.qml"
[[ -s $test_tmp/reveal-cursor.qml ]] || fail "Menu.qml defines revealCursor()"

awk -v function_file="$test_tmp/reveal-cursor.qml" '
  /@REVEAL_CURSOR@/ { while ((getline line < function_file) > 0) print line; next }
  { print }
' "$SHELL_TEST_DIR/menu-scroll/ScrollHarness.qml.in" >"$test_tmp/ScrollHarness.qml"
cp "$SHELL_TEST_DIR/menu-scroll/tst_menu_scroll.qml" "$test_tmp/"

output=$(QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software "$qml_test_runner" -input "$test_tmp" -o -,txt 2>&1) ||
  fail "menu keeps the cursor row whole and the first row at the top" "$output"
pass "menu keeps the cursor row whole and the first row at the top"
