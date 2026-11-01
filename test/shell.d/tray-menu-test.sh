#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=""
QS_PID=""
MOCK_PID=""
NO_MENU_PID=""
TWIN_PID=""
TRAY_PID=""

cleanup() {
  local pid
  for pid in "$TRAY_PID" "$MOCK_PID" "$NO_MENU_PID" "$TWIN_PID"; do
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

tray_dir="$TMPDIR/tray"
tray_log="$TMPDIR/tray.log"
mkdir -p "$tray_dir"
for dir in Ui Commons plugins services; do
  ln -s "$ROOT/shell/$dir" "$tray_dir/$dir"
done

cat >"$tray_dir/shell.qml" <<'QML'
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.plugins.bar.widgets

ShellRoot {
  FloatingWindow {
    implicitWidth: 120
    implicitHeight: 60

    Tray {
      id: tray
      settings: ({ pinned: ["omarchy-test-tray-no-menu"] })
    }

    Timer {
      property int attempts: 0
      interval: 100
      running: true
      repeat: true
      onTriggered: {
        var values = SystemTray.items.values
        for (var i = 0; i < values.length; i++) {
          if (String(values[i].id) === "omarchy-test-tray-no-menu") {
            stop()
            tray.openTrayMenu(values[i], tray)
            return
          }
        }
        if (++attempts >= 50) stop()
      }
    }
  }
}
QML

PATH="$ROOT/bin:$PATH" \
OMARCHY_PATH="$ROOT" \
HOME="$TMPDIR/home" \
XDG_CONFIG_HOME="$TMPDIR/home/.config" \
XDG_CACHE_HOME="$TMPDIR/home/.cache" \
XDG_STATE_HOME="$TMPDIR/home/.local/state" \
  quickshell -p "$tray_dir" --no-color >"$tray_log" 2>&1 &
TRAY_PID=$!

for _ in {1..80}; do
  [[ -s $context_menu_result ]] && break
  sleep 0.1
done

if [[ ! -s $context_menu_result ]]; then
  sed -n '1,160p' "$tray_log" >&2
  sed -n '1,160p' "$no_menu_log" >&2
  fail "tray right-click on an item without a D-Bus menu calls its ContextMenu"
fi

pass "tray right-click on an item without a D-Bus menu calls its ContextMenu"

rm -f "$context_menu_result"
twin_ready="$TMPDIR/twin-ready"
twin_result="$TMPDIR/twin-context-menu"

OMARCHY_TRAY_MENU_READY="$twin_ready" \
OMARCHY_TRAY_CONTEXT_MENU_RESULT="$twin_result" \
  python "$SHELL_TEST_DIR/fixtures/tray-menu-activation/mock-sni.py" >"$TMPDIR/mock-sni-twin.log" 2>&1 &
TWIN_PID=$!

for _ in {1..50}; do
  [[ -s $twin_ready ]] && break
  sleep 0.1
done
[[ -s $twin_ready ]] || fail "second tray item with the same id registers with the watcher"

if "$ROOT/bin/omarchy-tray-context-menu" omarchy-test-tray-no-menu omarchy-test-tray-no-menu 2>/dev/null; then
  fail "tray context menu helper refuses to pick between items with the same id"
fi
[[ ! -e $context_menu_result && ! -e $twin_result ]] ||
  fail "tray context menu helper opens no menu when items share an id"

pass "tray context menu helper opens no menu when items share an id"
