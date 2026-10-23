#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
MPV_PARITY_REPORT="$ARTIFACTS/mpv-parity-results.json" python3 "$ROOT/test/acceptance.d/fixtures/mpv_parity.py" > "$ARTIFACTS/mpv-parity.log" 2>&1 || fail "mpv state and input parity" "See $ARTIFACTS/mpv-parity.log"
pass "mpv visibility, subtitle preferences, pointer lifecycle and live seekability"
