#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell unavailable; skipping tray direction runtime checks"
  exit 0
fi

fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
cp "$SHELL_TEST_DIR/fixtures/tray-direction/shell.qml" "$fixture/shell.qml"
ln -s "$ROOT/shell/Commons" "$fixture/Commons"
ln -s "$ROOT/shell/Ui" "$fixture/Ui"
ln -s "$ROOT/shell/plugins/bar/widgets" "$fixture/widgets"

# Render the real Tray and its controls without touching the desktop shell.
QT_QPA_PLATFORM=offscreen timeout 50 quickshell -p "$fixture" --no-color >"$fixture/log" 2>&1 || {
  cat "$fixture/log" >&2
  fail "tray direction runtime"
}
if ! rg -q 'PASS: tray direction' "$fixture/log" || rg -q 'FAIL:|Error:' "$fixture/log"; then
  cat "$fixture/log" >&2
  fail "tray direction runtime"
fi
pass "tray direction, stationary pins, clipping, hit masks, and settings persistence"
