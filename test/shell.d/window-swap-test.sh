#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
printf 'hyprctl:%s\n' "$*" >>"$OMARCHY_TEST_HYPR_LOG"
SH
chmod +x "$mock_bin/hyprctl"

export PATH="$mock_bin:$PATH"
export OMARCHY_TEST_HYPR_LOG="$test_tmp/hypr-log"
swap="$ROOT/bin/omarchy-hyprland-window-swap"

: >"$OMARCHY_TEST_HYPR_LOG"
"$swap" left
grep -Fq 'hl.dsp.window.swap({ direction = "l" })' "$OMARCHY_TEST_HYPR_LOG" ||
  fail "window swap left dispatches lua" "$(cat "$OMARCHY_TEST_HYPR_LOG")"
pass "window swap left dispatches lua"

: >"$OMARCHY_TEST_HYPR_LOG"
"$swap" down
grep -Fq 'hl.dsp.window.swap({ direction = "d" })' "$OMARCHY_TEST_HYPR_LOG" ||
  fail "window swap down dispatches lua"
pass "window swap down dispatches lua"

"$swap" sideways >/dev/null 2>&1 &&
  fail "window swap exits non-zero on unknown direction"
pass "window swap exits non-zero on unknown direction"

"$swap" --help >/dev/null 2>&1 || fail "window swap --help succeeds"
pass "window swap --help succeeds"
