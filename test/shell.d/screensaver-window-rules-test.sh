#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

screensaver_rules="$ROOT/default/hypr/apps/system.lua"
screensaver_block=$(rg -n -U -o 'o\.window\("org\.omarchy\.screensaver"[^)]*\{[\s\S]*?\}\)' "$screensaver_rules" || true)

[[ -n $screensaver_block ]] || fail "screensaver window rule is defined"

# Compositor fullscreen / maximize demotes maximized or full-width windows on
# the workspace. Idle lock would then leave people tiled after unlock.
if rg -q 'fullscreen\s*=\s*true|maximize\s*=\s*true' <<<"$screensaver_block"; then
  fail "screensaver must not use compositor fullscreen or maximize"
fi
pass "screensaver avoids compositor fullscreen mode"

rg -q 'float\s*=\s*true' <<<"$screensaver_block" || fail "screensaver floats over the existing layout"
rg -q 'pin\s*=\s*true' <<<"$screensaver_block" || fail "screensaver stays pinned while covering the monitor"
rg -q 'size\s*=\s*\{\s*"monitor_w",\s*"monitor_h"\s*\}' <<<"$screensaver_block" ||
  fail "screensaver sizes to the full monitor"
rg -q 'move\s*=\s*\{\s*0,\s*0\s*\}' <<<"$screensaver_block" ||
  fail "screensaver is anchored to the monitor origin"
pass "screensaver covers the monitor as a floating overlay"
