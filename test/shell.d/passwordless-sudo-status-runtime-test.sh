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
  skip "qt6 qmltestrunner not found; skipping shared sudo status runtime tests"
  exit 0
fi

fixture="$SHELL_TEST_DIR/fixtures/passwordless-sudo-status"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/qs/Commons"
cp "$ROOT/shell/Commons/PasswordlessSudoStatus.qml" "$scratch/qs/Commons/"
printf '%s\n' 'module qs.Commons' 'singleton PasswordlessSudoStatus 1.0 PasswordlessSudoStatus.qml' >"$scratch/qs/Commons/qmldir"
output=$(QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software "$qml_test_runner" \
  -import "$scratch" -import "$fixture/mocks" -input "$fixture" -o -,txt 2>&1) ||
  fail "shared sudo status coalesces real QML timers and bindings" "$output"
pass "shared sudo status coalesces real QML timers and bindings"
