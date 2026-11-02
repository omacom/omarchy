#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
call_log="$tmpdir/calls"
mkdir -p "$mock_bin"

for command in hyprctl pkill; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash
printf '%s %s\n' "$(basename "$0")" "$*" >>"$CALL_LOG"
SH
done

cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s %s\n' "$(basename "$0")" "$*" >>"$CALL_LOG"
printf '%s\n' "${LOCK_REPLY-ok}"
exit "${LOCK_STATUS:-0}"
SH

# A screensaver that does not exit within its second; 1Password's bounded lock runs.
cat >"$mock_bin/timeout" <<'SH'
#!/bin/bash
printf '%s %s\n' "$(basename "$0")" "$*" >>"$CALL_LOG"
if [[ $1 == "--kill-after=1s" ]]; then
  shift 2
  "$@"
else
  exit 124
fi
SH

cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
[[ ${PASSWORD_MANAGER_RUNNING:-0} == "1" ]]
SH
cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$mock_bin/flock" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$mock_bin/1password" <<'SH'
#!/bin/bash
printf '1password %s\n' "$*" >>"$CALL_LOG"
SH
chmod +x "$mock_bin"/*

run_lock() {
  PATH="$mock_bin:$PATH" CALL_LOG="$call_log" XDG_RUNTIME_DIR="$tmpdir" "$ROOT/bin/omarchy-system-lock"
}

# New lock requests and already-locked sessions both answer "ok".
run_lock
mapfile -t shutdown < <(rg '^(pkill|timeout) ' "$call_log")

[[ ${shutdown[0]} == "pkill -f [/]usr/lib/omarchy-screensaver/omarchy-screensaver" ]] ||
  fail "system lock stops the native screensaver" "calls: ${shutdown[*]}"
[[ ${shutdown[1]} == "timeout 1s pidwait -f [/]usr/lib/omarchy-screensaver/omarchy-screensaver" ]] ||
  fail "system lock waits for the native screensaver to clean up" "calls: ${shutdown[*]}"
[[ ${shutdown[2]} == "pkill -KILL -f [/]usr/lib/omarchy-screensaver/omarchy-screensaver" ]] ||
  fail "system lock force-stops a stuck native screensaver" "calls: ${shutdown[*]}"
rg -A1 '^pkill -KILL ' "$call_log" | rg -q 'invisible = false' ||
  fail "system lock shows the cursor a killed screensaver left hidden" "$(<"$call_log")"
pass "system lock gives the screensaver a second to restore the cursor before killing it, then restores it itself"

for reply in missing-pam failed ""; do
  : >"$call_log"
  status=0
  LOCK_REPLY="$reply" run_lock >/dev/null 2>"$tmpdir/error" || status=$?
  (( status == 1 )) || fail "refused lock returns failure" "reply: $reply; status: $status"
  [[ $(<"$call_log") == $'omarchy-shell lock lock\nhyprctl switchxkblayout all 0' ]] ||
    fail "refused lock preserves the screensaver" "$(<"$call_log")"
  [[ -s $tmpdir/error ]] || fail "refused lock explains the failure"
done
pass "refused and empty lock replies preserve the screensaver and return failure"

: >"$call_log"
status=0
LOCK_STATUS=7 run_lock >/dev/null 2>&1 || status=$?
(( status == 7 )) || fail "failed IPC preserves its exit status" "status: $status"
[[ $(<"$call_log") == $'omarchy-shell lock lock\nhyprctl switchxkblayout all 0' ]] ||
  fail "failed IPC preserves the screensaver" "$(<"$call_log")"
pass "failed IPC preserves its exit status and the screensaver"

# Capture stdout so the subshell also waits for the finite background vault-lock
# fixture. Every invoked command is mocked; no real process or vault is touched.
: >"$call_log"
status=0
output=$(PASSWORD_MANAGER_RUNNING=1 LOCK_STATUS=7 run_lock 2>"$tmpdir/error") || status=$?
(( status == 7 )) || fail "IPC failure remains visible after password-manager protection" "status: $status"
(( $(grep -c '^1password --lock$' "$call_log") == 1 )) ||
  fail "failed screen lock still locks the password manager once" "$(<"$call_log")"
grep -F 'timeout --kill-after=1s 3s 1password --lock' "$call_log" >/dev/null ||
  fail "password-manager locking keeps its timeout"
if grep -q '^pkill ' "$call_log"; then
  fail "password-manager protection does not tear down the screensaver after failed lock"
fi
pass "failed screen lock retains bounded password-manager protection without screensaver teardown"
