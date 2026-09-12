#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

looknfeel="$ROOT/default/hypr/looknfeel.lua"
steam="$ROOT/default/hypr/apps/steam.lua"
retroarch="$ROOT/default/hypr/apps/retroarch.lua"

grep -Eq 'allow_tearing[[:space:]]*=[[:space:]]*true' "$looknfeel" || fail "allow_tearing is enabled in looknfeel.lua"
pass "allow_tearing is enabled in looknfeel.lua"

grep -Eq 'direct_scanout[[:space:]]*=[[:space:]]*2' "$looknfeel" || fail "direct_scanout = 2 is configured in looknfeel.lua"
pass "direct_scanout = 2 is configured in looknfeel.lua"

grep -Eq 'steam_app_\.\*' "$steam" && grep -Eq 'immediate[[:space:]]*=[[:space:]]*true' "$steam" || fail "immediate rule configured for steam apps"
pass "immediate presentation rule is configured for Steam games"

grep -Eq 'immediate[[:space:]]*=[[:space:]]*true' "$retroarch" || fail "immediate rule configured for retroarch"
pass "immediate presentation rule is configured for RetroArch"
