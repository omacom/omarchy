#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Isolated config/palette and owned player; only run through disposable VM acceptance.
python3 "$ROOT/test/acceptance.d/fixtures/mpv_controls.py" > "$ARTIFACTS/mpv.log" 2>&1 || fail "mpv controls acceptance" "See $ARTIFACTS/mpv.log"
pass "mpv controller renders, retints and handles playback, menus and sliders"
