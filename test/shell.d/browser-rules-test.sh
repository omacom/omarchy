#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

browser_rules="$ROOT/default/hypr/apps/browser.lua"

rg -q 'tile = true' "$browser_rules" || fail "chromium browsers stay tiled by default"
rg -qU '^o\.window\(\{ tag = "chromium-based-browser", title = "\(Live Caption\|Live Translate\|实时字幕\)" \}, \{\n(?:[^}\n]*\n)* *float = true' "$browser_rules" ||
  fail "Live Caption rule floats the bubble by title"
pass "Chrome Live Caption bubble floats instead of tiling"
