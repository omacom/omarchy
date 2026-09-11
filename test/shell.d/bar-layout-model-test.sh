#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
if ! command -v quickshell >/dev/null 2>&1; then
  pass "quickshell not installed; skipping layout model runtime test"
  exit 0
fi
fixture=$(mktemp -d)
trap 'rm -rf -- "$fixture"' EXIT
cp -- "$SHELL_TEST_DIR/fixtures/bar-layout-model/shell.qml" "$fixture/shell.qml"
ln -s -- "$ROOT/shell/plugins/bar/BarModel.js" "$fixture/BarModel.js"
QT_QPA_PLATFORM=offscreen timeout 10 quickshell -p "$fixture" --no-color >"$fixture/log" 2>&1 || true
if ! rg -q BAR_LAYOUT_MODEL_OK "$fixture/log" || rg -q 'BAR_LAYOUT_MODEL_FAIL|TypeError|ReferenceError' "$fixture/log"; then
  cat "$fixture/log" >&2
  fail "layout changes preserve QML delegates and nested settings"
fi
pass "layout changes preserve QML delegates and nested settings"
