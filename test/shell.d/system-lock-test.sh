#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
call_log="$tmpdir/calls"
mkdir -p "$mock_bin"

for command in omarchy-shell hyprctl pkill timeout omarchy-hyprland-fullscreen-snapshot; do
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
mapfile -t shutdown < <(rg '^(pkill|timeout|omarchy-hyprland-fullscreen-snapshot) ' "$call_log")

[[ ${shutdown[0]} == "pkill -x ttfx" ]] ||
  fail "system lock stops ttfx before closing its terminal" "calls: ${shutdown[*]}"
[[ ${shutdown[1]} == "timeout 1s pidwait -x ttfx" ]] ||
  fail "system lock waits for ttfx to exit" "calls: ${shutdown[*]}"
[[ ${shutdown[2]} == "pkill -f [o]rg.omarchy.screensaver" ]] ||
  fail "system lock closes the screensaver terminal after ttfx exits" "calls: ${shutdown[*]}"
[[ ${shutdown[3]} == "omarchy-hyprland-fullscreen-snapshot restore" ]] ||
  fail "system lock restores fullscreen state after closing the screensaver" "calls: ${shutdown[*]}"
pass "system lock waits for ttfx before closing its terminal"
