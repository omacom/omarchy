#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_compositor "power panel without a battery"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping power panel no-battery test"
  exit 0
fi

stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
mkdir -p "$stage/power" "$stage/home"
cp "$SHELL_TEST_DIR/fixtures/power-no-battery/shell.qml" "$stage/shell.qml"
cp "$ROOT/shell/plugins/panels/power/Panel.qml" "$ROOT/shell/plugins/panels/power/Model.js" "$stage/power/"
ln -s "$ROOT/shell/Ui" "$stage/Ui"
ln -s "$ROOT/shell/Commons" "$stage/Commons"

# A dead system bus is a machine with no UPower display device, which is
# what makes this the no-battery path on a laptop too.
output=$(DBUS_SYSTEM_BUS_ADDRESS=/dev/null \
HOME="$stage/home" \
XDG_CONFIG_HOME="$stage/home/.config" \
XDG_CACHE_HOME="$stage/home/.cache" \
XDG_STATE_HOME="$stage/home/.local/state" \
OMARCHY_PATH="$ROOT" \
QML2_IMPORT_PATH="$ROOT/shell${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
QML_IMPORT_PATH="$ROOT/shell${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
PATH="$ROOT/bin:$PATH" \
  timeout 30 quickshell -p "$stage" --no-color 2>&1) || fail "power panel without a battery fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "power panel without a battery settles closed after open" "$output"
if rg -q 'Binding loop' <<< "$output"; then
  fail "power panel without a battery has no binding loop" "$output"
fi
pass "power panel without a battery settles closed after open, with no binding loop"
