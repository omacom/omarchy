#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

qmltestrunner=""
for candidate in /usr/lib/qt6/bin/qmltestrunner /usr/lib/qt6/qmltestrunner; do
  if [[ -x $candidate ]]; then
    qmltestrunner=$candidate
    break
  fi
done

if [[ -z $qmltestrunner ]]; then
  skip "qmltestrunner not installed; skipping bar widget tooltip test"
  exit 0
fi

test_imports=$(mktemp -d)
trap 'rm -rf "$test_imports"' EXIT
mkdir -p "$test_imports/qs"
ln -s "$ROOT/shell/Ui" "$test_imports/qs/Ui"
ln -s "$SHELL_TEST_DIR/fixtures/bar-widget-tooltip/qs/Commons" "$test_imports/qs/Commons"

output=$(QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software \
  QML2_IMPORT_PATH="$test_imports${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
  QML_IMPORT_PATH="$test_imports${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
  "$qmltestrunner" -import "$test_imports" -input "$SHELL_TEST_DIR/fixtures/bar-widget-tooltip/qml" -o -,txt 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "bar widget tooltip QML test passes"
}

printf '%s\n' "$output"
pass "bar widget tooltip QML test passes"
