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
  skip "qt6 qmltestrunner not found; skipping SDDM login user tests"
  exit 0
fi

output=$(QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software "$qml_test_runner" \
  -import "$SHELL_TEST_DIR/sddm-login-user/imports" \
  -input "$SHELL_TEST_DIR/sddm-login-user/qml" -o -,txt 2>&1) ||
  fail "the SDDM theme logs in as the remembered user, or the first account without one" "$output"
pass "the SDDM theme logs in as the remembered user, or the first account without one"
