#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
call_log="$tmpdir/calls"
mkdir -p "$mock_bin"

for command in omarchy-shell hyprctl pkill timeout; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash
printf '%s %s\n' "$(basename "$0")" "$*" >>"$CALL_LOG"
SH
done

cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$mock_bin"/*

PATH="$mock_bin:$PATH" CALL_LOG="$call_log" "$ROOT/bin/omarchy-system-lock"
mapfile -t shutdown < <(rg '^(pkill|timeout) ' "$call_log")

[[ ${shutdown[0]} == "pkill -x ttfx" ]] ||
  fail "system lock stops ttfx before closing its terminal" "calls: ${shutdown[*]}"
[[ ${shutdown[1]} == "timeout 1s pidwait -x ttfx" ]] ||
  fail "system lock waits for ttfx to exit" "calls: ${shutdown[*]}"
[[ ${shutdown[2]} == "pkill -f [o]rg.omarchy.screensaver" ]] ||
  fail "system lock closes the screensaver terminal after ttfx exits" "calls: ${shutdown[*]}"

# #15371: a third-party screensaver is matched only by its window class, so it
# never gets to run its own cursor restore. The lock has to do it, afterwards.
restore_line=$(rg -Fn 'cursor = { invisible = false }' "$call_log" | cut -d: -f1 | tail -1 || true)
kill_line=$(rg -Fn 'pkill -f [o]rg.omarchy.screensaver' "$call_log" | cut -d: -f1 | head -1 || true)
[[ -n $restore_line ]] ||
  fail "system lock restores the pointer a screensaver may have left hidden" "$(cat "$call_log")"
[[ -n $kill_line && $restore_line -gt $kill_line ]] ||
  fail "system lock restores the pointer after closing the screensaver terminal" "$(cat "$call_log")"
pass "system lock waits for ttfx before closing its terminal"
pass "system lock restores the pointer a third-party screensaver left hidden"
