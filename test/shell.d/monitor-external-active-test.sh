#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-hyprland-monitor-external-active must ignore Hyprland's synthetic
# FALLBACK head. Otherwise internal-panel recover() never runs after unplug
# (issue #10584).

helper="$ROOT/bin/omarchy-hyprland-monitor-external-active"
[[ -f $helper ]] || fail "external-active helper exists"

grep -F 'select(.name != "FALLBACK")' "$helper" >/dev/null ||
  fail "external-active helper excludes the synthetic FALLBACK monitor"
pass "external-active helper excludes the synthetic FALLBACK monitor"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash
[[ $1 == "monitors" && $2 == "all" && $3 == "-j" ]] || exit 1
printf '%s\n' "${OMARCHY_TEST_MONITORS_JSON:?}"
SH
chmod +x "$stub_bin/hyprctl"

run_helper() {
  OMARCHY_TEST_MONITORS_JSON="${1:?}" PATH="$stub_bin:/usr/bin:/bin" bash "$helper"
  return $?
}

# Real external HDMI still active with internal disabled → true.
hdmi='[
  {"name":"eDP-1","disabled":true,"width":1920,"height":1200},
  {"name":"HDMI-A-1","disabled":false,"width":3840,"height":2160}
]'
if ! run_helper "$hdmi"; then
  fail "external-active is true with a live HDMI output"
fi
pass "external-active is true with a live HDMI output"

# Unplug case: only disabled internal + FALLBACK → must be false.
fallback_only='[
  {"name":"eDP-1","disabled":true,"width":1920,"height":1200},
  {"name":"FALLBACK","disabled":false,"width":0,"height":0}
]'
if run_helper "$fallback_only"; then
  fail "external-active is false when only FALLBACK remains after unplug"
fi
pass "external-active is false when only FALLBACK remains after unplug"

# FALLBACK alone (no internal listed) → false.
fallback_solo='[{"name":"FALLBACK","disabled":false,"width":0,"height":0}]'
if run_helper "$fallback_solo"; then
  fail "external-active is false for FALLBACK alone"
fi
pass "external-active is false for FALLBACK alone"

# Internal only, enabled → false (no external).
internal_only='[{"name":"eDP-1","disabled":false,"width":1920,"height":1200}]'
if run_helper "$internal_only"; then
  fail "external-active is false for internal-only"
fi
pass "external-active is false for internal-only"

# Mirrored/disabled external must not count (existing contract).
disabled_hdmi='[
  {"name":"eDP-1","disabled":false,"width":1920,"height":1200},
  {"name":"HDMI-A-1","disabled":true,"width":3840,"height":2160}
]'
if run_helper "$disabled_hdmi"; then
  fail "external-active ignores disabled external outputs"
fi
pass "external-active ignores disabled external outputs"
