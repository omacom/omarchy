#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
if [[ $1 == "activewindow" ]]; then
  printf '{"address":"0xTEST"}\n'
  exit 0
fi
printf 'hyprctl:%s\n' "$*" >>"$OMARCHY_TEST_HYPR_LOG"
SH
chmod +x "$mock_bin/hyprctl"

export PATH="$mock_bin:$PATH"
export OMARCHY_TEST_HYPR_LOG="$test_tmp/hypr-log"
move="$ROOT/bin/omarchy-hyprland-window-workspace"

: >"$OMARCHY_TEST_HYPR_LOG"
"$move" 3
grep -Fq 'hl.dsp.window.move({ workspace = "3" })' "$OMARCHY_TEST_HYPR_LOG" ||
  fail "workspace move follows by default" "$(cat "$OMARCHY_TEST_HYPR_LOG")"
pass "workspace move follows by default"

: >"$OMARCHY_TEST_HYPR_LOG"
"$move" 5 --silent
grep -Fq 'hl.dsp.window.move({ workspace = "5", follow = false })' "$OMARCHY_TEST_HYPR_LOG" ||
  fail "workspace move honors --silent"
pass "workspace move honors --silent"

"$move" 11 >/dev/null 2>&1 &&
  fail "workspace move rejects out-of-range workspaces"
pass "workspace move rejects out-of-range workspaces"

"$move" --help >/dev/null 2>&1 || fail "workspace move --help succeeds"
pass "workspace move --help succeeds"
