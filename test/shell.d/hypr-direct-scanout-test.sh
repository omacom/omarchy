#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

looknfeel="$ROOT/default/hypr/looknfeel.lua"

grep -Eq 'direct_scanout[[:space:]]*=[[:space:]]*2' "$looknfeel" || fail "direct_scanout = 2 is not configured"
pass "direct scanout is automatic for fullscreen game content"

grep -Eq 'allow_tearing[[:space:]]*=[[:space:]]*false' "$looknfeel" || fail "async tearing was enabled with direct scanout"
pass "direct scanout does not enable experimental tearing"
