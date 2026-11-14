#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Match the theme's Qt 6 runtime; Qt 5 can report success without running it.
qml_test_runner=""
for candidate in /usr/lib/qt6/bin/qmltestrunner /usr/lib/qt6/qmltestrunner; do
  if [[ -x $candidate ]]; then
    qml_test_runner=$candidate
    break
  fi
done

if [[ -z $qml_test_runner ]]; then
  skip "qt6 qmltestrunner not found; skipping SDDM theme tests"
  exit 0
fi

output=$(QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= QT_QUICK_BACKEND=software \
  "$qml_test_runner" -input "$SHELL_TEST_DIR/sddm-theme/qml" -o -,txt 2>&1) ||
  fail "SDDM theme keeps optional fingerprint and password paths independent" "$output"
[[ $output == *"SddmTheme::test_starts_fingerprint_without_password_submission"* ]] ||
  fail "the QML runner actually executes the greeter cases" "$output"
printf '%s\n' "$output"
pass "SDDM theme keeps optional fingerprint and password paths independent"
