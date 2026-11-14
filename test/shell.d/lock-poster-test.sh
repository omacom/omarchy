#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell unavailable; skipping lock poster QML lifecycle"
  exit 0
fi
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/config" "$work/runtime" "$work/home"
chmod 700 "$work/runtime"
cp "$SHELL_TEST_DIR/fixtures/lock-poster/shell.qml" "$work/config/shell.qml"
ln -s "$ROOT/shell/Ui" "$work/config/Ui"
ln -s "$ROOT/shell/Commons" "$work/config/Commons"

# Offscreen rendering exercises the real QML bindings without taking a lock
# or connecting to the user's compositor.
HOME="$work/home" XDG_RUNTIME_DIR="$work/runtime" \
  OMARCHY_PATH="$ROOT" QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= \
  QT_STYLE_OVERRIDE= QT_QUICK_BACKEND=software \
  timeout 15 quickshell -p "$work/config" --no-color >"$work/log" 2>&1 || {
    cat "$work/log" >&2
    fail "lock poster QML lifecycle runs"
  }
if ! grep -q 'LOCK_POSTER_TEST_PASS' "$work/log" || grep -q 'LOCK_POSTER_TEST_FAIL' "$work/log"; then
  cat "$work/log" >&2
  fail "the lock shows a video wallpaper's poster and releases it on unlock"
fi
pass "the lock shows a video wallpaper's poster and releases it on unlock"
