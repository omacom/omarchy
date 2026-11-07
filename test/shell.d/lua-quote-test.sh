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
  skip "qt6 qmltestrunner not found; skipping lua quote tests"
  exit 0
fi

if ! output=$(QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software "$qml_test_runner" \
  -input "$SHELL_TEST_DIR/lua-quote/qml" -o -,txt 2>&1); then
  # A distro package can ship the Quickshell QML module without the plugin that
  # registers its types, and then the engine rejects the import before a single
  # test runs. The shell code is not at fault, so skip only that failure and
  # keep failing for every other one.
  if [[ $output == *Quickshell* ]] &&
    [[ $output == *"not found"* || $output == *"is not installed"* || $output == *unavailable* ]]; then
    skip "the Quickshell QML module does not load; skipping lua quote tests"
    exit 0
  fi
  fail "a monitor name stays inside the Lua literal" "$output"
fi
pass "a monitor name stays inside the Lua literal"
