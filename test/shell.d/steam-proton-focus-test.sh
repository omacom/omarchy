#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

steam_rules="$ROOT/default/hypr/apps/steam.lua"

rg -q 'class = "\^steam_app_", fullscreen = true' "$steam_rules" ||
  fail "fullscreen Proton games match steam_app_* clients"
rg -q 'stay_focused = true' "$steam_rules" ||
  fail "fullscreen Proton games keep keyboard focus"
pass "fullscreen Proton games keep keyboard focus under steam_app_*"
