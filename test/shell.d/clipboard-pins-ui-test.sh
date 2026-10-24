#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

preview_display=${WAYLAND_DISPLAY:-}
if [[ -n $preview_display && $preview_display != /* ]]; then
  preview_display="${XDG_RUNTIME_DIR:-/run/user/$UID}/$preview_display"
fi

work=$(mktemp -d)
shell_base="${CLIPBOARD_PIN_SHELL_BASE:-$ROOT/shell}"
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/config/Ui" "$work/bin" "$work/home" "$work/state" "$work/runtime"
chmod 700 "$work/runtime"
cp "$SHELL_TEST_DIR/fixtures/clipboard-pins/shell.qml" "$work/config/shell.qml"
cp "$ROOT/shell/plugins/clipboard/ClipboardHistory.js" "$work/config/"
# Disable capture startup in the fixture only. Never reap or start real
# clipboard watchers, and render the otherwise unchanged UI in a test window.
sed -e 's/Component.onCompleted: initProc.running = true/Component.onCompleted: {}/' \
  -e '/WlrLayershell.namespace: "omarchy-clipboard"/d' \
  "$ROOT/shell/plugins/clipboard/Clipboard.qml" >"$work/config/Clipboard.qml"
ln -s "$shell_base/Commons" "$work/config/Commons"
for file in "$shell_base/Ui/"*; do
  [[ ${file##*/} == "OverlayWindow.qml" ]] || ln -s "$file" "$work/config/Ui/"
done
cat >"$work/config/Ui/OverlayWindow.qml" <<'QML'
import QtQuick
import Quickshell
FloatingWindow {
  property bool shown: false
  visible: shown
  implicitWidth: 1100
  implicitHeight: 800
  title: "Omarchy clipboard pin preview (isolated)"
  onShownChanged: if (!shown) Qt.quit()
}
QML
cp "$work/config/Ui/OverlayWindow.qml" "$work/config/OverlayWindow.qml"
# Even keyboard actions in preview mode cannot copy into the real clipboard,
# launch real apps, or query the active compositor.
for command in wl-copy wl-paste wtype hyprctl omasnap omarchy-launch-browser omarchy-launch-editor; do
  printf '#!/bin/bash\nexit 0\n' >"$work/bin/$command"
  chmod +x "$work/bin/$command"
done
printf '%s\n' '{"type":"text","text":"Pinned from a private request"}' >"$work/request.json"
printf '%s\n' 'A file prevents creation of a history directory here.' >"$work/blocked-state"

# Interactive previews copy only appearance settings into the scratch home.
# The panel then uses the same theme/font bindings as the installed clipboard.
if [[ ${1:-} == "--preview" || ${CLIPBOARD_PIN_DESKTOP_STYLE:-0} == "1" ]]; then
  mkdir -p "$work/home/.config/omarchy" "$work/home/.local/state/omarchy/current/theme" "$work/home/.local/share"
  if [[ -d $HOME/.config/fontconfig ]]; then
    cp -aL "$HOME/.config/fontconfig" "$work/home/.config/"
  fi
  if [[ -d $HOME/.local/share/fonts ]]; then
    ln -s "$HOME/.local/share/fonts" "$work/home/.local/share/fonts"
  fi
  if [[ -f $HOME/.config/omarchy/shell.toml ]]; then
    cp "$HOME/.config/omarchy/shell.toml" "$work/home/.config/omarchy/shell.toml"
  fi
  for appearance_file in colors.toml shell.toml; do
    if [[ -f $HOME/.local/state/omarchy/current/theme/$appearance_file ]]; then
      cp "$HOME/.local/state/omarchy/current/theme/$appearance_file" "$work/home/.local/state/omarchy/current/theme/"
    fi
  done
  export OMARCHY_MENU_FONT="${OMARCHY_MENU_FONT:-$(fc-match -f '%{family[0]}' monospace)}"
fi

export HOME="$work/home" XDG_STATE_HOME="$work/state" XDG_CONFIG_HOME="$work/home/.config"
export XDG_CACHE_HOME="$work/home/.cache" XDG_RUNTIME_DIR="$work/runtime"
export OMARCHY_PATH="$ROOT" PATH="$work/bin:$PATH"
export QT_QPA_PLATFORMTHEME= QT_STYLE_OVERRIDE= QT_QUICK_BACKEND=software
export CLIPBOARD_PIN_REQUEST="$work/request.json"
export CLIPBOARD_PIN_BLOCKED_HISTORY="$work/blocked-state/clipboard-history.json"
export CLIPBOARD_PIN_RETRY_HISTORY="$work/state/retry/clipboard-history.json"
export CLIPBOARD_PIN_SCREENSHOT="${CLIPBOARD_PIN_SCREENSHOT:-$work/preview.png}"
export CLIPBOARD_PIN_CONFIRM_SCREENSHOT="${CLIPBOARD_PIN_CONFIRM_SCREENSHOT:-$work/confirm.png}"
ulimit -c 0

if [[ ${1:-} == "--preview" ]]; then
  # An ordinary window on the current display; no shell restart or dev link.
  export CLIPBOARD_PIN_PREVIEW=1
  export WAYLAND_DISPLAY="$preview_display"
  quickshell -p "$work/config" --no-color
else
  unset WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE
  export QT_QPA_PLATFORM=offscreen CLIPBOARD_PIN_PREVIEW=0
  if ! timeout 20 quickshell -p "$work/config" --no-color >"$work/log" 2>&1; then
    cat "$work/log" >&2
    fail "isolated clipboard QML lifecycle runs"
  fi
  if ! rg -q 'CLIPBOARD_PINS_QML_PASS' "$work/log" || rg -q 'CLIPBOARD_PINS_QML_FAIL|TypeError|ReferenceError|Unable to assign' "$work/log"; then
    cat "$work/log" >&2
    fail "isolated clipboard QML pin lifecycle and persistence"
  fi
  [[ -s $CLIPBOARD_PIN_SCREENSHOT ]] || fail "isolated UI preview was rendered"
  [[ -s $CLIPBOARD_PIN_CONFIRM_SCREENSHOT ]] || fail "clear-history confirmation was rendered"
  pass "isolated clipboard controls, save failures, retries, deletion, restart persistence, limits and UI rendering"
fi
