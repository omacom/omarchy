#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

external_tmp=$(mktemp -d)
trap 'rm -rf "$external_tmp"' EXIT
cat >"$external_tmp/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' "$OMARCHY_TEST_MONITORS"
SH
chmod +x "$external_tmp/hyprctl"

external_active() {
  PATH="$external_tmp:$PATH" OMARCHY_TEST_MONITORS="$1" "$ROOT/bin/omarchy-hyprland-monitor-external-active"
}

external_active '[{"name":"eDP-1","disabled":true},{"name":"HDMI-A-1","disabled":false}]' ||
  fail "active external monitor helper sees a connected external monitor"

# Unplugging the last external monitor while the panel is off leaves Hyprland's
# FALLBACK placeholder behind, which must not keep the panel from recovering.
! external_active '[{"name":"eDP-1","disabled":true},{"name":"FALLBACK","disabled":false}]' ||
  fail "active external monitor helper ignores Hyprland's FALLBACK output"
pass "active external monitor helper ignores Hyprland's FALLBACK output"

# omarchy-hw-recover-internal-monitor clears both the manual disable toggle and
# the clamshell toggle when no external display is connected (#20169), and
# leaves both when one is. The helper under test reads the real DRM paths, so
# the recovery script exercises it against a fixture OMARCHY_DRM_PATH.
recover_tmp=$(mktemp -d)
trap 'rm -rf "$external_tmp" "$recover_tmp"' EXIT
mkdir -p "$recover_tmp/home/.local/state/omarchy/toggles/hypr" "$recover_tmp/drm/card0-eDP-1" "$recover_tmp/drm/card1-DP-1"
printf disconnected >"$recover_tmp/drm/card0-eDP-1/status"

recover() {
  PATH="$ROOT/bin:$PATH" HOME="$recover_tmp/home" OMARCHY_DRM_PATH="$recover_tmp/drm" \
    "$ROOT/bin/omarchy-hw-recover-internal-monitor"
}

toggles_home="$recover_tmp/home/.local/state/omarchy/toggles/hypr"

printf 'hl.monitor({ output = "eDP-1", disabled = true })\n' >"$toggles_home/internal-monitor-clamshell.lua"
recover
if [[ -f $toggles_home/internal-monitor-clamshell.lua ]]; then
  fail "recovery clears a clamshell toggle left by a lid-closed shutdown"
fi
pass "recovery clears a clamshell toggle left by a lid-closed shutdown"

printf x >"$toggles_home/internal-monitor-clamshell.lua"
printf x >"$toggles_home/internal-monitor-disable.lua"
recover
if [[ -f $toggles_home/internal-monitor-clamshell.lua || -f $toggles_home/internal-monitor-disable.lua ]]; then
  fail "recovery clears both toggles with no external display connected"
fi
pass "recovery clears both toggles with no external display connected"

printf x >"$toggles_home/internal-monitor-clamshell.lua"
printf x >"$toggles_home/internal-monitor-disable.lua"
printf connected >"$recover_tmp/drm/card1-DP-1/status"
recover
if [[ ! -f $toggles_home/internal-monitor-clamshell.lua || ! -f $toggles_home/internal-monitor-disable.lua ]]; then
  fail "recovery keeps both toggles while an external display is connected"
fi
pass "recovery keeps both toggles while an external display is connected"

rm -f "$toggles_home/internal-monitor-clamshell.lua" "$toggles_home/internal-monitor-disable.lua"
printf disconnected >"$recover_tmp/drm/card1-DP-1/status"
recover
pass "recovery succeeds with no toggles present"
