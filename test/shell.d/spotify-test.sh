#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

spotify_rules="$ROOT/default/hypr/apps/spotify.lua"

[[ -f $spotify_rules ]] ||
  fail "Spotify ships Hyprland window rules"

# Spotify runs under XWayland, so it cannot bind zwp_idle_inhibit_manager_v1 and
# never inhibits idle on its own. Without a compositor-side rule the screensaver
# covers fullscreen video podcasts mid-playback.
rg -q 'idle_inhibit = "fullscreen"' "$spotify_rules" ||
  fail "Spotify inhibits idle while fullscreen"
pass "Spotify inhibits idle while fullscreen"

# Match both the XWayland class (Spotify) and the app id Spotify uses when run
# with the Wayland ozone backend (spotify).
rg -q '\^\[sS\]potify\$' "$spotify_rules" ||
  fail "Spotify rule matches both its XWayland class and its Wayland app id"
pass "Spotify rule matches both its XWayland class and its Wayland app id"

# "always" would hold the machine awake for paused music; idle must still run
# when Spotify is merely open.
if rg -q 'idle_inhibit = "always"' "$spotify_rules"; then
  fail "Spotify does not inhibit idle outside fullscreen"
fi
pass "Spotify does not inhibit idle outside fullscreen"
