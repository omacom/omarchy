#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=""
MOCK_PID=""

cleanup() {
  if [[ -n $MOCK_PID ]] && kill -0 "$MOCK_PID" 2>/dev/null; then
    kill "$MOCK_PID" 2>/dev/null || true
    wait "$MOCK_PID" 2>/dev/null || true
  fi
  [[ -n $TMPDIR && -d $TMPDIR ]] && rm -rf "$TMPDIR"
  return 0
}
trap cleanup EXIT

require_compositor "tray symbolic icon test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping tray symbolic icon test"
  exit 0
fi

require_command magick
require_command python

python - <<'PY' || {
import dbus
import gi
PY
  skip "python DBus bindings unavailable; skipping tray symbolic icon test"
  exit 0
}

TMPDIR=$(mktemp -d)
config_dir="$TMPDIR/config"
icons_dir="$TMPDIR/icons"
grab="$TMPDIR/tray.png"
qs_log="$TMPDIR/quickshell.log"
mock_log="$TMPDIR/mock-sni.log"
mkdir -p "$config_dir" "$icons_dir" "$TMPDIR/home"

for dir in Ui Commons plugins services; do
  ln -s "$ROOT/shell/$dir" "$config_dir/$dir"
done

# Adwaita and many app icons fill symbolic icons dark, which colorization
# could not lift to a light bar foreground.
cat >"$icons_dir/omarchy-test-tray-symbolic.svg" <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"><circle cx="8" cy="8" r="6.5" fill="#222222"/></svg>
SVG

cat >"$config_dir/shell.qml" <<QML
import QtQuick
import Quickshell
import qs.plugins.bar.widgets

ShellRoot {
  FloatingWindow {
    id: window
    implicitWidth: 120
    implicitHeight: 60

    Tray {
      id: tray
      settings: ({ pinned: ["omarchy-test-tray"] })
    }

    // TrayIcon is inline in Tray.qml, so find it by its shape and the mock's
    // icon name: other apps' tray icons may be in the same tray.
    function findIcon(item) {
      if (item.symbolic !== undefined && String(item.icon).indexOf("/omarchy-test-tray-symbolic?") !== -1) return item
      for (var i = 0; i < item.children.length; i++) {
        var found = findIcon(item.children[i])
        if (found) return found
      }
      return null
    }

    Timer {
      property int attempts: 0
      interval: 100
      running: true
      repeat: true
      onTriggered: {
        var icon = window.findIcon(tray)
        var ready = icon && icon.children[0].status === Image.Ready
        if (!ready && ++attempts < 100) return
        stop()
        if (!ready) {
          console.log("RESULT noicon")
          Qt.quit()
          return
        }
        noFrame.start()
        icon.grabToImage(function(result) {
          result.saveToFile("$grab")
          console.log("RESULT symbolic=" + icon.symbolic + " foreground=" + tray.foreground)
          Qt.quit()
        })
      }
    }

    // A grab waits for a frame, and an output that is asleep never draws one.
    Timer {
      id: noFrame
      interval: 5000
      onTriggered: {
        console.log("RESULT noframe")
        Qt.quit()
      }
    }
  }
}
QML

OMARCHY_TRAY_ICON_NAME="omarchy-test-tray-symbolic" \
OMARCHY_TRAY_ICON_THEME_PATH="$icons_dir" \
OMARCHY_TRAY_MENU_EVENT_RESULT="$TMPDIR/event" \
OMARCHY_TRAY_MENU_READY="$TMPDIR/ready" \
  python "$SHELL_TEST_DIR/fixtures/tray-menu-activation/mock-sni.py" >"$mock_log" 2>&1 &
MOCK_PID=$!

output=$(OMARCHY_PATH="$ROOT" \
  HOME="$TMPDIR/home" \
  XDG_CONFIG_HOME="$TMPDIR/home/.config" \
  XDG_CACHE_HOME="$TMPDIR/home/.cache" \
  XDG_STATE_HOME="$TMPDIR/home/.local/state" \
  timeout 20 quickshell -p "$config_dir" --no-color 2>&1) || true
printf '%s\n' "$output" >"$qs_log"

result=$(grep -o 'RESULT .*' "$qs_log" | tail -1 || true)
if [[ $result == "RESULT noframe" ]]; then
  skip "compositor drew no frame (output asleep?); skipping tray symbolic icon test"
  exit 0
fi
if [[ $result != "RESULT symbolic=true foreground=#"* || ! -s $grab ]]; then
  sed -n '1,160p' "$qs_log" >&2
  sed -n '1,160p' "$mock_log" >&2
  fail "tray shows the mock symbolic icon"
fi

foreground=${result##*foreground=}
foreground=${foreground^^}
[[ $foreground != "#222222" ]] || fail "tray symbolic icon test needs a foreground unlike the icon fill"

pixels=$(magick "$grab" txt:-)
opaque=$(awk 'NR > 1 && $3 ~ /FF$/ { print substr($3, 1, 7) }' <<<"$pixels" | sort | uniq -c | sort -rn)
corner=$(awk '$1 == "0,0:" { print substr($3, 8, 2) }' <<<"$pixels")

[[ $(wc -l <<<"$opaque") == 1 && $opaque == *" $foreground" ]] ||
  fail "tray paints a dark symbolic icon in the bar foreground" "expected every opaque pixel $foreground, got: ${opaque:-none}"
pass "tray paints a dark symbolic icon in the bar foreground"

[[ $corner == "00" ]] || fail "tray keeps a symbolic icon's shape" "expected a transparent corner, got alpha ${corner:-none}"
pass "tray keeps a symbolic icon's shape"
