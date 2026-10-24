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
pass "system lock waits for ttfx before closing its terminal"

# A refused lock must not be polled for a session lock that will never land.
mapfile -t unaccepted_polls < <(rg '^omarchy-shell lock status' "$call_log")
[[ ${#unaccepted_polls[@]} == 0 ]] ||
  fail "system lock skips the secure wait when the shell did not accept the lock" "${unaccepted_polls[*]}"

# An accepted lock must be secure before the screensaver dies: the session
# lock lands half a second after the request, and killing the screensaver
# first flashes the desktop in the gap.
secure_log="$tmpdir/calls-secure"
poll_file="$tmpdir/polls"

cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s %s\n' "$(basename "$0")" "$*" >>"$CALL_LOG"
if [[ $* == "lock lock" ]]; then
  echo ok
elif [[ $* == "lock status" ]]; then
  polls=$(cat "$POLL_FILE" 2>/dev/null || echo 0)
  echo $((polls + 1)) >"$POLL_FILE"
  (( polls > 1 )) && echo '{"secure":true}' || echo '{"secure":false}'
fi
SH
chmod +x "$mock_bin/omarchy-shell"

PATH="$mock_bin:$PATH" CALL_LOG="$secure_log" POLL_FILE="$poll_file" "$ROOT/bin/omarchy-system-lock"

mapfile -t secure_polls < <(rg '^omarchy-shell lock status$' "$secure_log")
first_pkill_line=$(rg -n '^pkill' "$secure_log" | head -1 | cut -d: -f1)
last_poll_line=$(rg -n '^omarchy-shell lock status$' "$secure_log" | tail -1 | cut -d: -f1)

[[ ${#secure_polls[@]} == 3 ]] ||
  fail "system lock polls status until the lock is secure" "polls: ${#secure_polls[@]}"
(( last_poll_line < first_pkill_line )) ||
  fail "system lock tears the screensaver down only after the lock is secure" "last poll: $last_poll_line, first pkill: $first_pkill_line"
pass "system lock waits for a secure lock before tearing the screensaver down"

# A shell that accepts the lock and then stalls must not stretch the wait to
# ten status timeouts: the lid-close caller runs this script synchronously,
# so the deadline, not a poll count, bounds it.
slow_log="$tmpdir/calls-slow"
slow_start_ms=$((10#${EPOCHREALTIME//[!0-9]/} / 1000))

cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s %s\n' "$(basename "$0")" "$*" >>"$CALL_LOG"
if [[ $* == "lock lock" ]]; then
  echo ok
elif [[ $* == "lock status" ]]; then
  sleep "$OMARCHY_SHELL_IPC_TIMEOUT"
  echo '{"secure":false}'
fi
SH
chmod +x "$mock_bin/omarchy-shell"

PATH="$mock_bin:$PATH" CALL_LOG="$slow_log" "$ROOT/bin/omarchy-system-lock"
slow_elapsed_ms=$((10#${EPOCHREALTIME//[!0-9]/} / 1000 - slow_start_ms))
mapfile -t slow_polls < <(rg '^omarchy-shell lock status$' "$slow_log")
mapfile -t slow_shutdown < <(rg '^(pkill|timeout) ' "$slow_log")

[[ ${#slow_polls[@]} -le 2 ]] ||
  fail "system lock stops polling a stalled shell" "polls: ${#slow_polls[@]}"
[[ ${#slow_shutdown[@]} == 3 ]] ||
  fail "system lock still tears the screensaver down after a stalled shell" "calls: ${slow_shutdown[*]}"
(( slow_elapsed_ms < 3000 )) ||
  fail "system lock bounds a stalled shell" "elapsed: ${slow_elapsed_ms}ms"
pass "system lock bounds a stalled shell by the deadline"
