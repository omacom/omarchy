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
  skip "qt6 qmltestrunner not found; skipping Dropbox collection runtime tests"
  exit 0
fi

fixture="$SHELL_TEST_DIR/fixtures/dropbox-collection"
mocks="$SHELL_TEST_DIR/fixtures/passwordless-sudo-status/mocks"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/DropboxUnderTest"
cp "$ROOT/shell/plugins/panels/dropbox/Service.qml" "$ROOT/shell/plugins/panels/dropbox/Model.js" "$scratch/DropboxUnderTest/"
printf '%s\n' 'module DropboxUnderTest' 'DropboxService 1.0 Service.qml' >"$scratch/DropboxUnderTest/qmldir"
output=$(QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software "$qml_test_runner" \
  -import "$scratch" -import "$mocks" -input "$fixture" -o -,txt 2>&1) ||
  fail "Dropbox separates background status from visible inventory in QML" "$output"
pass "Dropbox separates background status from visible inventory in QML"
