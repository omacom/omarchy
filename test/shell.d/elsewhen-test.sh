#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

checks="$SHELL_TEST_DIR/elsewhen"

require_command node
for check in "$checks"/*_check.js; do
  output=$(node "$check" --offline 2>&1) || fail "elsewhen ${check##*/}" "$output"
  pass "elsewhen ${check##*/}"
done

output=$(python3 "$checks/currency_check.py" --offline 2>&1) || fail "elsewhen currency_check.py" "$output"
pass "elsewhen currency_check.py"

# /usr/bin/qmltestrunner is the Qt 5 binary, which exits 0 having run nothing.
qml_test_runner=""
for candidate in /usr/lib/qt6/bin/qmltestrunner /usr/lib/qt6/qmltestrunner; do
  [[ -x $candidate ]] && qml_test_runner=$candidate && break
done

if [[ -n $qml_test_runner ]]; then
  output=$(QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software "$qml_test_runner" -input "$checks/qml" -o -,txt 2>&1) ||
    fail "elsewhen pointer tests" "$output"
  pass "elsewhen pointer tests"
else
  skip "qt6 qmltestrunner not found; skipping elsewhen pointer tests"
fi
