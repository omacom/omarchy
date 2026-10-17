#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT

cp "$SHELL_TEST_DIR/fixtures/real-screens/shell.qml" "$stage/shell.qml"
ln -s "$ROOT/shell/Commons" "$stage/Commons"

# Qt invents a nameless placeholder QScreen whenever the compositor has no
# outputs. Windows mapped on it have no wl_output behind them, and the next
# output change takes the Wayland connection, and the shell, down with it.
output=$(timeout 10 quickshell -p "$stage" --no-color 2>&1) || fail "real screens fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "only named, sized outputs count as real screens" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<<"$output"; then
  fail "real screens fixture has no QML errors" "$output"
fi
pass "the shell maps per-output windows only on real screens"
