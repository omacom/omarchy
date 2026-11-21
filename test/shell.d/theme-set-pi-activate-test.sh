#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home"
mkdir -p "$test_home/.pi/agent" "$test_home/.local/state/omarchy/current/theme"
printf '{"background": "#1a1b26"}\n' >"$test_home/.local/state/omarchy/current/theme/pi.json"

run_pi() {
  HOME="$test_home" bash "$ROOT/bin/omarchy-theme-set-pi" --activate
}

# A theme the user chose themselves survives --activate (re-provisioning).
printf '{"theme": "custom:user-choice"}\n' >"$test_home/.pi/agent/settings.json"
run_pi
[[ $(jq -r '.theme' "$test_home/.pi/agent/settings.json") == "custom:user-choice" ]] \
  || fail "--activate leaves a user-chosen Pi theme alone"
pass "--activate leaves a user-chosen Pi theme alone"

# The Omarchy theme selection still syncs through.
printf '{"theme": "omarchy-system"}\n' >"$test_home/.pi/agent/settings.json"
run_pi
[[ $(jq -r '.theme' "$test_home/.pi/agent/settings.json") == "omarchy-system" ]] \
  || fail "--activate keeps the Omarchy theme selected"
pass "--activate keeps the Omarchy theme selected"

# Fresh install still seeds the Omarchy theme.
rm -f "$test_home/.pi/agent/settings.json"
run_pi
[[ $(jq -r '.theme' "$test_home/.pi/agent/settings.json") == "omarchy-system" ]] \
  || fail "--activate seeds the Omarchy theme on first install"
pass "--activate seeds the Omarchy theme on first install"

# The generated theme file is synced in all cases.
cmp -s "$test_home/.local/state/omarchy/current/theme/pi.json" \
  "$test_home/.pi/agent/themes/omarchy-system.json" \
  || fail "--activate syncs the generated theme file"
pass "--activate syncs the generated theme file"
