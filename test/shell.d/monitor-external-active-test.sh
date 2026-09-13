#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

helper="$ROOT/bin/omarchy-hyprland-monitor-external-active"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
drm_path="$tmpdir/drm"
monitors="$tmpdir/monitors.json"
mkdir -p "$mock_bin" "$drm_path"

cat >"$mock_bin/hyprctl" <<SH
#!/bin/bash
cat "$monitors"
SH
chmod +x "$mock_bin/hyprctl"

run_helper() {
  OMARCHY_DRM_PATH="$drm_path" PATH="$mock_bin:$PATH" "$helper"
}

set_connector() {
  local name="$1" state="$2"
  mkdir -p "$drm_path/card1-$name"
  printf '%s\n' "$state" >"$drm_path/card1-$name/status"
}

printf '[{"name":"DP-5","disabled":false}]\n' >"$monitors"
set_connector DP-5 connected
run_helper || fail "connected active external monitor is detected"
pass "connected active external monitor is detected"

printf '[{"name":"FALLBACK","disabled":false}]\n' >"$monitors"
if run_helper; then
  fail "Hyprland fallback is not treated as an external monitor"
fi
pass "Hyprland fallback is not treated as an external monitor"

printf '[{"name":"DP-5","disabled":false}]\n' >"$monitors"
set_connector DP-5 disconnected
if run_helper; then
  fail "stale Hyprland output is not treated as physically connected"
fi
pass "stale Hyprland output is not treated as physically connected"

printf '[{"name":"DP-5","disabled":true}]\n' >"$monitors"
set_connector DP-5 connected
if run_helper; then
  fail "disabled external monitor is not treated as active"
fi
pass "disabled external monitor is not treated as active"

printf '[{"name":"eDP-1","disabled":false}]\n' >"$monitors"
set_connector eDP-1 connected
if run_helper; then
  fail "internal panel is not treated as an external monitor"
fi
pass "internal panel is not treated as an external monitor"

printf '[{"name":"DP-5","disabled":false}]\n' >"$monitors"
set_connector DP-5 connected
run_helper || fail "mirrored external output is read from the all-monitor query"
pass "mirrored external output is read from the all-monitor query"
