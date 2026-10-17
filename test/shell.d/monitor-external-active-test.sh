#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_bin=$(mktemp -d)
monitors_file=$(mktemp)

cleanup() {
  rm -rf "$test_bin"
  rm -f "$monitors_file"
}
trap cleanup EXIT

cat >"$test_bin/hyprctl" <<'EOF'
#!/bin/bash
[[ $* == "monitors all -j" ]] || exit 1
cat "$FAKE_MONITORS"
EOF

chmod +x "$test_bin/hyprctl"

external_active() {
  printf '%s\n' "$1" >"$monitors_file"
  FAKE_MONITORS="$monitors_file" PATH="$test_bin:$PATH" \
    bash "$ROOT/bin/omarchy-hyprland-monitor-external-active"
}

extended='[
  { "name": "eDP-1", "disabled": false, "focused": false },
  { "name": "DP-1", "disabled": false, "focused": true }
]'

undocked='[
  { "name": "eDP-1", "disabled": false, "focused": true }
]'

# With the panel off and nothing plugged in, Hyprland stands up its FALLBACK
# placeholder, which is enabled but is not an external monitor.
fallback='[
  { "name": "eDP-1", "disabled": true, "focused": false },
  { "name": "FALLBACK", "disabled": false, "focused": true }
]'

# Remote-desktop sessions create enabled headless outputs named HEADLESS-*;
# they display nothing either.
headless='[
  { "name": "eDP-1", "disabled": true, "focused": false },
  { "name": "HEADLESS-1", "disabled": false, "focused": true }
]'

docked_off='[
  { "name": "eDP-1", "disabled": true, "focused": false },
  { "name": "DP-1", "disabled": false, "focused": true }
]'

# An external the user disabled on purpose is not active either.
external_disabled='[
  { "name": "eDP-1", "disabled": false, "focused": true },
  { "name": "DP-1", "disabled": true, "focused": false }
]'

external_active "$extended" ||
  fail "a connected external monitor is reported active"
pass "active external monitor is detected alongside the internal panel"

if external_active "$undocked"; then
  fail "an internal panel alone is not an external monitor"
fi
pass "internal panel alone is not reported as external"

if external_active "$fallback"; then
  fail "Hyprland's FALLBACK placeholder must not read as an external monitor"
fi
pass "FALLBACK placeholder is not reported as an external monitor"

if external_active "$headless"; then
  fail "a headless output must not read as an external monitor"
fi
pass "headless output is not reported as an external monitor"

external_active "$docked_off" ||
  fail "a docked laptop with its panel off still has an active external monitor"
pass "disabled internal panel with external connected is still docked"

if external_active "$external_disabled"; then
  fail "a monitor disabled on purpose must not read as active"
fi
pass "a disabled external monitor is not reported as active"
