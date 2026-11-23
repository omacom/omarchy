#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

external_tmp=$(mktemp -d)
trap 'rm -rf "$external_tmp"' EXIT
cat >"$external_tmp/hyprctl" <<'SH'
#!/bin/bash
if [[ $* == "monitors -j" ]]; then
  jq '[.[] | select(.disabled != true and (.mirrorOf // "none") == "none")]' <<<"$OMARCHY_TEST_MONITORS"
else
  printf '%s\n' "$OMARCHY_TEST_MONITORS"
fi
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

run_mirror() {
  HOME="$mirror_home" XDG_RUNTIME_DIR="$mirror_runtime" OMARCHY_PATH="$ROOT" \
    PATH="$external_tmp:$ROOT/bin:$PATH" OMARCHY_TEST_MONITORS="$1" \
    "$ROOT/bin/omarchy-hyprland-monitor-internal-mirror" "${2:-recover}"
}

no_external='[{"name":"eDP-1","disabled":false},{"name":"FALLBACK","disabled":false}]'
connected='[{"name":"eDP-1","disabled":false},{"name":"HDMI-A-1","disabled":false}]'
printf 'hl.monitor({ output = "HDMI-A-1", mirror = "eDP-1" })\n' >"$mirror_flag"
run_mirror "$no_external"
[[ -f $mirror_flag && -s $recovery_state ]] || fail "a brief disconnect preserves mirroring"
pass "a brief disconnect preserves mirroring"

# Reconnecting cancels the pending recovery even if its grace period elapsed.
printf '%s\n' "$(( EPOCHSECONDS - 4 ))" >"$recovery_state"
run_mirror "$connected"
[[ -f $mirror_flag && ! -f $recovery_state ]] || fail "reconnecting cancels mirror recovery"
run_mirror "$no_external"
[[ -f $mirror_flag ]] || fail "a later disconnect gets its own grace period"
pass "reconnecting cancels mirror recovery and resets the grace period"

printf '%s\n' "$(( EPOCHSECONDS - 4 ))" >"$recovery_state"
run_mirror "$connected" on
[[ -f $mirror_flag && ! -f $recovery_state ]] || fail "explicit mirror on cancels recovery when already mirrored"
run_mirror "$no_external"
[[ -f $mirror_flag ]] || fail "explicit mirror on resets the next disconnect's grace period"
pass "explicit mirror on cancels recovery when already mirrored"

# A dock can return under a different connector while the old rule survives.
replacement='[{"name":"eDP-1","disabled":false},{"name":"DP-2","disabled":false},{"name":"HDMI-A-2","disabled":false,"mirrorOf":"eDP-1"},{"name":"DP-3","disabled":true},{"name":"FALLBACK","disabled":false}]'
run_mirror "$replacement"
run_mirror "$replacement" on
for output in DP-2 HDMI-A-2; do
  grep -F "output = \"$output\"" "$mirror_flag" >/dev/null || fail "mirror on refreshes a retained rule for $output"
done
! grep -E 'HDMI-A-1|DP-3|FALLBACK' "$mirror_flag" >/dev/null || fail "mirror on drops absent and disabled outputs"
pass "mirror on repairs a retained rule for the current active outputs"

printf '%s\n' "$(( EPOCHSECONDS - 4 ))" >"$recovery_state"
run_mirror "$no_external"
[[ ! -f $mirror_flag && ! -f $recovery_state ]] || fail "a lasting disconnect still clears mirroring"
pass "a lasting disconnect still clears mirroring"
