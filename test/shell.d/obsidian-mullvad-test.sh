#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

flags="$ROOT/config/obsidian/user-flags.conf"
[[ -f $flags ]] || fail "obsidian user-flags.conf is shipped"

# Single-dash -disable-gpu is not a valid Electron flag (#9781).
if rg -q '^-disable-gpu$' "$flags"; then
  fail "obsidian flags must not use a single-dash -disable-gpu"
fi
rg -q '^--disable-gpu$' "$flags" || fail "obsidian flags include --disable-gpu"
rg -q '^--ozone-platform-hint=' "$flags" || fail "obsidian flags include an ozone platform hint for Wayland"
rg -q '^--enable-wayland-ime$' "$flags" || fail "obsidian flags keep wayland IME support"
pass "obsidian user-flags.conf uses valid Electron flags"

mullvad="$ROOT/default/hypr/apps/mullvad.lua"
[[ -f $mullvad ]] || fail "mullvad app rule is shipped"
rg -q 'float = true' "$mullvad" || fail "mullvad rule floats the window"
rg -q 'center = true' "$mullvad" || fail "mullvad rule centers the window"
rg -q 'size = \{ 380, 640 \}' "$mullvad" || fail "mullvad rule keeps the companion popup size"
rg -q 'Mullvad VPN\|mullvad-vpn' "$mullvad" || fail "mullvad rule matches Mullvad VPN window class"
pass "mullvad app rule floats and centers the VPN window"

# default.hypr.apps require_all loads every .lua under default/hypr/apps.
apps_loader="$ROOT/default/hypr/apps.lua"
rg -q 'default/hypr/apps' "$apps_loader" || fail "apps.lua loads the apps directory"
pass "mullvad.lua is picked up by default.hypr.apps require_all"
