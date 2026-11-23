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

mirror_home="$external_tmp/home"
mirror_runtime="$external_tmp/runtime"
mirror_flag="$mirror_home/.local/state/omarchy/toggles/hypr/internal-monitor-mirror.lua"
recovery_state="$mirror_runtime/omarchy-monitor-mirror-disconnected"
mkdir -p "$(dirname "$mirror_flag")" "$mirror_runtime"
printf '#!/bin/bash\nexit 0\n' >"$external_tmp/omarchy-restart-hyprctl"
chmod +x "$external_tmp/omarchy-restart-hyprctl"

recover_mirror() {
  HOME="$mirror_home" XDG_RUNTIME_DIR="$mirror_runtime" OMARCHY_PATH="$ROOT" \
    PATH="$external_tmp:$ROOT/bin:$PATH" OMARCHY_TEST_MONITORS="$1" \
    "$ROOT/bin/omarchy-hyprland-monitor-internal-mirror" recover
}

no_external='[{"name":"eDP-1","disabled":false},{"name":"FALLBACK","disabled":false}]'
connected='[{"name":"eDP-1","disabled":false},{"name":"HDMI-A-1","disabled":false}]'
printf 'hl.monitor({ output = "HDMI-A-1", mirror = "eDP-1" })\n' >"$mirror_flag"
recover_mirror "$no_external"
[[ -f $mirror_flag && -s $recovery_state ]] || fail "a brief disconnect preserves mirroring"
pass "a brief disconnect preserves mirroring"

# Reconnecting cancels the pending recovery even if its grace period elapsed.
printf '%s\n' "$(( EPOCHSECONDS - 4 ))" >"$recovery_state"
recover_mirror "$connected"
[[ -f $mirror_flag && ! -f $recovery_state ]] || fail "reconnecting cancels mirror recovery"
recover_mirror "$no_external"
[[ -f $mirror_flag ]] || fail "a later disconnect gets its own grace period"
pass "reconnecting cancels mirror recovery and resets the grace period"

printf '%s\n' "$(( EPOCHSECONDS - 4 ))" >"$recovery_state"
recover_mirror "$no_external"
[[ ! -f $mirror_flag && ! -f $recovery_state ]] || fail "a lasting disconnect still clears mirroring"
pass "a lasting disconnect still clears mirroring"
