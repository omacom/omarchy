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
