#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT
mkdir -p "$temp_dir/bin"
export MONITOR_FIXTURE="$temp_dir/monitors.json"
export MONITOR_ACTIONS="$temp_dir/actions"
export PATH="$temp_dir/bin:$ROOT/bin:$PATH"

cat >"$temp_dir/bin/hyprctl" <<'SH'
#!/bin/bash
if [[ $1 == "monitors" ]]; then
  [[ $* == "monitors all -j" ]] || exit 1
  cat "$MONITOR_FIXTURE"
else
  printf '%s\n' "$*" >>"$MONITOR_ACTIONS"
fi
SH
cat >"$temp_dir/bin/omarchy-hyprland-toggle-enabled" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$temp_dir/bin/omarchy-hyprland-toggle" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$MONITOR_ACTIONS"
SH
chmod +x "$temp_dir/bin/"*

cat >"$MONITOR_FIXTURE" <<'JSON'
[
  {"name":"eDP-2","disabled":true},
  {"name":"FALLBACK","disabled":false}
]
JSON
if omarchy-hyprland-monitor-external-active; then
  fail "FALLBACK does not count as an external monitor"
fi
omarchy-hyprland-monitor-internal recover
grep -Fx 'internal-monitor-disable off' "$MONITOR_ACTIONS" >/dev/null || fail "undocking clears the internal display disable flag"
grep -F 'dpms' "$MONITOR_ACTIONS" >/dev/null || fail "undocking wakes the recovered display"
pass "disabled laptop panel recovers when only FALLBACK remains"

for connector in eDP-1 LVDS-1 DSI-1; do
  printf '[{"name":"%s","disabled":false}]\n' "$connector" >"$MONITOR_FIXTURE"
  if omarchy-hyprland-monitor-external-active; then
    fail "internal connector $connector does not count as external"
  fi
done
pass "internal connectors do not count as external monitors"

for disabled in true false; do
  printf '[{"name":"FALLBACK","disabled":false},{"name":"DP-1","disabled":%s,"mirrorOf":"eDP-2"}]\n' "$disabled" >"$MONITOR_FIXTURE"
  if [[ $disabled == "true" ]]; then
    if omarchy-hyprland-monitor-external-active; then
      fail "disabled external output does not prevent recovery"
    fi
  else
    omarchy-hyprland-monitor-external-active || fail "active mirrored external output still counts"
    : >"$MONITOR_ACTIONS"
    omarchy-hyprland-monitor-internal recover
    [[ ! -s $MONITOR_ACTIONS ]] || fail "active external output keeps the internal panel disabled"
  fi
done
pass "external monitor detection preserves disabled and mirrored output behavior"
