#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

steam_rules="$ROOT/default/hypr/apps/steam.lua"

# Steam classes the running game's own window steam_app_<appid>, separate from
# the Steam client window matched above it. Without this rule the screensaver
# and lock still engage during play, since gamepad input doesn't register as
# activity.
rg -q '^o\.window\("\^steam_app_\[0-9\]\+\$", \{ idle_inhibit = "fullscreen" \}\)$' "$steam_rules" ||
  fail "Steam game windows (steam_app_<appid>) inhibit idle while fullscreen"
pass "Steam game windows (steam_app_<appid>) inhibit idle while fullscreen"
