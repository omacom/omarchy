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
  skip "qt6 qmltestrunner not found; skipping plugin bar api tests"
  exit 0
fi

output=$(QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software "$qml_test_runner" -input "$SHELL_TEST_DIR/plugin-bar-api/qml" -o -,txt 2>&1) ||
  fail "plugin bar api passes centerHoverRevealSuppressed writes to the bar" "$output"
pass "plugin bar api passes centerHoverRevealSuppressed writes to the bar"
