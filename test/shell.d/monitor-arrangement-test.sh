#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command quickshell
require_command python3
require_command lua5.1
require_command jq

scratch=$(mktemp -d)
qs_pid=""
cleanup() {
  if [[ -n $qs_pid ]] && kill -0 "$qs_pid" 2>/dev/null; then
    kill "$qs_pid"
    wait "$qs_pid" 2>/dev/null || true
  fi
  rm -rf "$scratch"
}
trap cleanup EXIT
mkdir -p "$scratch/config" "$scratch/bin" "$scratch/home"
cp "$SHELL_TEST_DIR/monitor-arrangement/shell.qml" "$scratch/config/shell.qml"
ln -s "$ROOT/shell/Ui" "$scratch/config/Ui"
ln -s "$ROOT/shell/Commons" "$scratch/config/Commons"
cat >"$scratch/bin/hyprctl" <<'SH'
#!/bin/bash
exec python3 "$ARRANGEMENT_TEST_DIR/fake-hyprctl.py" "$@"
SH
chmod +x "$scratch/bin/hyprctl"

# Isolated Qt window and compositor stub; no live display or user config access.
env QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= QT_QUICK_BACKEND=software \
  WAYLAND_DISPLAY= HYPRLAND_INSTANCE_SIGNATURE= \
  HOME="$scratch/home" XDG_CONFIG_HOME="$scratch/home/.config" \
  XDG_CACHE_HOME="$scratch/home/.cache" XDG_STATE_HOME="$scratch/home/.local/state" \
  OMARCHY_PATH="$ROOT" ARRANGEMENT_TEST_DIR="$SHELL_TEST_DIR/monitor-arrangement" \
  ARRANGEMENT_TEST_STATE="$scratch/state.json" ARRANGEMENT_TEST_RESULT="$scratch/result.json" \
  PATH="$scratch/bin:$PATH" \
  quickshell -p "$scratch/config" --no-color >"$scratch/log" 2>&1 &
qs_pid=$!

for (( attempt = 0; attempt < 650; attempt++ )); do
  [[ -s $scratch/result.json ]] && break
  if ! kill -0 "$qs_pid" 2>/dev/null; then
    cat "$scratch/log" >&2
    fail "Display arrangement fixture exited without a result"
  fi
  sleep 0.1
done
if [[ ! -s $scratch/result.json ]] || ! jq -e '.ok and (.checks | length == 22)' "$scratch/result.json" >/dev/null; then
  cat "$scratch/log" >&2
  [[ ! -f $scratch/result.json ]] || cat "$scratch/result.json" >&2
  fail "Display arrangement controls pass with the real backend"
fi
jq -r '.checks[]' "$scratch/result.json" | while IFS= read -r check; do pass "$check"; done
