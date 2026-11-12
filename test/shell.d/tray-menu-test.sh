#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=""
QS_PID=""
MOCK_PID=""
NO_MENU_PID=""
TWIN_PID=""

cleanup() {
  local pid
  for pid in "$MOCK_PID" "$NO_MENU_PID" "$TWIN_PID"; do
    if [[ -n $pid ]] && kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
    fi
  done
  if [[ -n $QS_PID ]] && kill -0 "$QS_PID" 2>/dev/null; then
    kill "$QS_PID" 2>/dev/null || true
    wait "$QS_PID" 2>/dev/null || true
  fi
  [[ -n $TMPDIR && -d $TMPDIR ]] && rm -rf "$TMPDIR"
  return 0
}
trap cleanup EXIT

require_compositor "tray menu activation test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping tray menu activation test"
  exit 0
fi

require_command jq
require_command python

python - <<'PY' || {
import dbus
import gi
PY
  skip "python DBus bindings unavailable; skipping tray menu activation test"
  exit 0
}

TMPDIR=$(mktemp -d)
config_dir="$TMPDIR/tray-menu-activation"
result="$TMPDIR/result.json"
event_result="$TMPDIR/event"
ready="$TMPDIR/ready"
qs_log="$TMPDIR/quickshell.log"
mock_log="$TMPDIR/mock-sni.log"
mkdir -p "$config_dir" "$TMPDIR/home"
cp "$SHELL_TEST_DIR/fixtures/tray-menu-activation/shell.qml" "$config_dir/shell.qml"

OMARCHY_PATH="$ROOT" \
OMARCHY_QML_TEST_RESULT="$result" \
HOME="$TMPDIR/home" \
XDG_CONFIG_HOME="$TMPDIR/home/.config" \
XDG_CACHE_HOME="$TMPDIR/home/.cache" \
XDG_STATE_HOME="$TMPDIR/home/.local/state" \
  quickshell -p "$config_dir" --no-color >"$qs_log" 2>&1 &
QS_PID=$!

OMARCHY_TRAY_MENU_EVENT_RESULT="$event_result" \
OMARCHY_TRAY_MENU_READY="$ready" \
  python "$SHELL_TEST_DIR/fixtures/tray-menu-activation/mock-sni.py" >"$mock_log" 2>&1 &
MOCK_PID=$!

for _ in {1..80}; do
  [[ -s $event_result ]] && break

  if ! kill -0 "$QS_PID" 2>/dev/null; then
    sed -n '1,160p' "$qs_log" >&2
    fail "tray menu activation quickshell exited before triggering menu item"
  fi

  if ! kill -0 "$MOCK_PID" 2>/dev/null; then
    sed -n '1,160p' "$mock_log" >&2
    fail "mock StatusNotifierItem exited before receiving menu event"
  fi

  sleep 0.1
done

if [[ ! -s $event_result ]]; then
  [[ -s $result ]] && jq . "$result" >&2
  printf 'Quickshell log:\n' >&2
  sed -n '1,160p' "$qs_log" >&2
  printf 'Mock SNI log:\n' >&2
  sed -n '1,160p' "$mock_log" >&2
  fail "tray menu sends DBusMenu clicked event"
fi

pass "tray menu sends DBusMenu clicked event"

# A Wine item publishes no D-Bus menu, so the bar asks it to draw its own
# through omarchy-tray-context-menu. Wine places that menu at X11 root
# coordinates, so the helper converts the pointer from Hyprland's layout.
# The pointer here is near the bottom of a portrait monitor at scale 2:
# Hyprland reports a mode's unrotated size, and Xwayland the rotated one.
no_menu_ready="$TMPDIR/no-menu-ready"
context_menu_result="$TMPDIR/context-menu"
no_menu_log="$TMPDIR/mock-sni-no-menu.log"

OMARCHY_TRAY_MENU_READY="$no_menu_ready" \
OMARCHY_TRAY_CONTEXT_MENU_RESULT="$context_menu_result" \
  python "$SHELL_TEST_DIR/fixtures/tray-menu-activation/mock-sni.py" >"$no_menu_log" 2>&1 &
NO_MENU_PID=$!

for _ in {1..50}; do
  [[ -s $no_menu_ready ]] && break
  sleep 0.1
done

if [[ ! -s $no_menu_ready ]]; then
  sed -n '1,160p' "$no_menu_log" >&2
  fail "mock StatusNotifierItem without a menu registers with the watcher"
fi

stub_bin="$TMPDIR/bin"
mkdir -p "$stub_bin"
cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash
case $1 in
  cursorpos) echo '{"x": 2600, "y": 1700}' ;;
  monitors) echo '[{"name": "DP-1", "x": 0, "y": 0, "width": 1920, "height": 1080, "scale": 1, "transform": 0},
                   {"name": "DP-2", "x": 1920, "y": 0, "width": 3840, "height": 2160, "scale": 2, "transform": 1}]' ;;
esac
SH
cat >"$stub_bin/xrandr" <<'SH'
#!/bin/bash
printf 'Monitors: 2\n 0: +DP-1 1920/530x1080/300+0+0  DP-1\n 1: +DP-2 2160/340x3840/600+1920+0  DP-2\n'
SH
chmod +x "$stub_bin/hyprctl" "$stub_bin/xrandr"

if ! PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-tray-context-menu" omarchy-test-tray-no-menu; then
  fail "tray context menu helper finds the item without a D-Bus menu"
fi

if [[ $(cat "$context_menu_result" 2>/dev/null) != "ContextMenu 3280 3400" ]]; then
  printf 'Got: %s\n' "$(cat "$context_menu_result" 2>/dev/null)" >&2
  fail "tray context menu opens at the pointer on a rotated, scaled monitor"
fi

pass "tray context menu opens at the pointer on a rotated, scaled monitor"

# A second item with the same Id (Wine apps in two prefixes) leaves the helper
# no way to tell which was clicked, so it opens neither menu.
twin_ready="$TMPDIR/twin-ready"
twin_result="$TMPDIR/context-menu-twin"
rm -f "$context_menu_result"

OMARCHY_TRAY_MENU_READY="$twin_ready" \
OMARCHY_TRAY_CONTEXT_MENU_RESULT="$twin_result" \
  python "$SHELL_TEST_DIR/fixtures/tray-menu-activation/mock-sni.py" >"$TMPDIR/mock-sni-twin.log" 2>&1 &
TWIN_PID=$!

for _ in {1..50}; do
  [[ -s $twin_ready ]] && break
  sleep 0.1
done

if PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-tray-context-menu" omarchy-test-tray-no-menu 2>/dev/null ||
  [[ -e $context_menu_result || -e $twin_result ]]; then
  fail "tray context menu helper opens no menu when two items share an Id"
fi

pass "tray context menu helper opens no menu when two items share an Id"
