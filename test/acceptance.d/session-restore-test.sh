#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# This suite belongs in the disposable acceptance VM. Its fixture state is
# isolated from both the user's saved session and ordinary desktop entries.
fixture=$(mktemp -d)
cleanup() {
  omarchy-menu close >/dev/null 2>&1 || true
  hyprctl -j clients | jq -r '.[] | select(.class == "omarchy-session-fixture") | .address' |
    while IFS= read -r address; do
      hyprctl dispatch "hl.dsp.window.close({ window = \"address:$address\" })" >/dev/null || true
    done
  rm -rf "$fixture"
}
trap cleanup EXIT
mkdir -p "$fixture/data/applications" "$fixture/state" "$fixture/runtime"
cat > "$fixture/data/applications/omarchy-session-fixture.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Session restore fixture
StartupWMClass=omarchy-session-fixture
Exec=foot --app-id=omarchy-session-fixture sh -c "printf 'Session restore verification\n'; sleep 600"
DESKTOP
session() {
  XDG_DATA_HOME="$fixture/data" XDG_STATE_HOME="$fixture/state" omarchy-session "$@"
}

omarchy-menu summon system.session
wait_until 'session menu shows its restore action' 15 screen_contains 'Reopen Apps'
screenshot success-session-menu
omarchy-menu close
XDG_DATA_HOME="$fixture/data" uwsm-app -- gtk-launch omarchy-session-fixture.desktop
wait_until 'session fixture opens' 20 window_present '^omarchy-session-fixture$'
address=$(hyprctl -j clients | jq -r '.[] | select(.class == "omarchy-session-fixture") | .address' | head -1)
hyprctl dispatch "hl.dsp.window.move({ window = \"address:$address\", workspace = \"3\", follow = false })"
session save
hyprctl dispatch "hl.dsp.window.close({ window = \"address:$address\" })"
wait_until 'session fixture closes' 15 window_absent '^omarchy-session-fixture$'
session restore
wait_until 'saved application reopens' 20 window_present '^omarchy-session-fixture$'
[[ $(hyprctl -j clients | jq '[.[] | select(.class == "omarchy-session-fixture" and .workspace.id == 3)] | length') == 1 ]] || fail 'restored application returns to its workspace'
session restore
[[ $(hyprctl -j clients | jq '[.[] | select(.class == "omarchy-session-fixture")] | length') == 1 ]] || fail 'a second restore must not duplicate an application'
hyprctl dispatch 'hl.dsp.focus({ workspace = "3" })'
screenshot success-session-restored
pass 'saved desktop identity reopens once on its workspace'
