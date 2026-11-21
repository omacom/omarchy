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
  skip "Qt6 qmltestrunner not found; skipping indicator null-owner test"
  exit 0
fi

imports=$(mktemp -d)
trap 'rm -rf "$imports"' EXIT
mkdir -p "$imports/qs" "$imports/home"
ln -s "$ROOT/shell/Commons" "$imports/qs/Commons"
ln -s "$ROOT/shell/Ui" "$imports/qs/Ui"

runner_status=0
output=$(HOME="$imports/home" XDG_CONFIG_HOME="$imports/home/.config" XDG_STATE_HOME="$imports/home/.state" \
  QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= QT_QUICK_BACKEND=software \
  "$qml_test_runner" -import "$imports" -input "$SHELL_TEST_DIR/fixtures/indicator-null-owner" -o -,txt 2>&1) || runner_status=$?

if printf '%s\n' "$output" | rg -q 'module "Quickshell(\.Io)?" (is not installed|plugin "[^"]+" not found)'; then
  skip "Quickshell Qt plugin unavailable to qmltestrunner; skipping indicator null-owner test"
  exit 0
fi

if (( runner_status != 0 )); then
  fail "indicator test runner exits successfully, including cleanup" "$output"
fi

if printf '%s\n' "$output" | rg -q "Cannot read property 'bar' of null"; then
  fail "tearing down the indicator host does not read bar from a null owner" "$output"
fi

if ! printf '%s\n' "$output" | rg -q '^Totals: [1-9][0-9]* passed, 0 failed'; then
  fail "tearing down the indicator host does not read bar from a null owner" "$output"
fi

printf '%s\n' "$output" | sed -n '/^Totals:/p'
pass "tearing down the indicator host does not read bar from a null owner"
