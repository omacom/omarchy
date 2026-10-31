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
  skip "qt6 qmltestrunner not found; skipping panel slider tests"
  exit 0
fi

output=$(QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= QT_QUICK_BACKEND=software "$qml_test_runner" \
  -import "$SHELL_TEST_DIR/panel-slider/imports" \
  -input "$SHELL_TEST_DIR/panel-slider/qml" -o -,txt 2>&1) ||
  fail "panel slider wheel and pointer behavior" "$output"
pass "panel slider wheel and pointer behavior"
