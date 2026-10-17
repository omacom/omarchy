#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

pip="$ROOT/default/hypr/apps/pip.lua"

if grep -E 'move = .*window_[wh]' "$pip" >/dev/null; then
  fail "pip.lua move does not use window_w or window_h" "$(grep -n -E 'move = .*window_[wh]' "$pip")"
fi

grep -F '(monitor_w-600-40)' "$pip" >/dev/null || fail "pip.lua inlines 600 in the move x expression"
grep -F '(monitor_h-338-40)' "$pip" >/dev/null || fail "Meet PiP inlines 338 in the move y expression"

pass "pip.lua inlines size in move expressions like webcam-overlay.lua"
