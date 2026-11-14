#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"
require_compositor "the Bluetooth pairable gate"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
# The directory import scans Panel.qml too, whose own imports resolve here.
for component in Commons Ui; do
  ln -s "$ROOT/shell/$component" "$stage/$component"
done
ln -s "$ROOT/shell/plugins/panels/bluetooth" "$stage/bluetooth"
cp "$SHELL_TEST_DIR/fixtures/bluetooth-pairable-gate/shell.qml" "$stage/shell.qml"

output=$(timeout 25 quickshell -p "$stage" --no-color 2>&1) || fail "the pairable gate fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "the adapter is pairable only while a Bluetooth panel is open" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Unable to assign|Binding loop' <<<"$output"; then
  fail "the pairable gate has no QML errors" "$output"
fi
pass "the adapter is pairable only while a Bluetooth panel is open"
