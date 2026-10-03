#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
call_log="$tmpdir/calls"
mkdir -p "$mock_bin"

for command in hyprctl pkill; do
  cat >"$mock_bin/$command" <<'MOCK'
#!/bin/bash
printf '%s %s\n' "$(basename "$0")" "$*" >>"$CALL_LOG"
MOCK
done

cat >"$mock_bin/omarchy-shell" <<'MOCK'
#!/bin/bash
printf '%s %s\n' "$(basename "$0")" "$*" >>"$CALL_LOG"
printf '%s\n' "${LOCK_REPLY-ok}"
exit "${LOCK_STATUS:-0}"
MOCK

cat >"$mock_bin/pgrep" <<'MOCK'
#!/bin/bash
[[ ${PASSWORD_MANAGER_RUNNING:-0} == "1" ]]
MOCK
cat >"$mock_bin/omarchy-cmd-present" <<'MOCK'
#!/bin/bash
exit 0
MOCK
cat >"$mock_bin/flock" <<'MOCK'
#!/bin/bash
exit 0
MOCK
cat >"$mock_bin/1password" <<'MOCK'
#!/bin/bash
printf '1password %s\n' "$*" >>"$CALL_LOG"
MOCK
cat >"$mock_bin/timeout" <<'MOCK'
#!/bin/bash
printf 'timeout %s\n' "$*" >>"$CALL_LOG"
if [[ $1 == "--kill-after=1s" ]]; then
  shift 2
  "$@"
fi
MOCK
chmod +x "$mock_bin"/*

run_lock() {
  PATH="$mock_bin:$PATH" CALL_LOG="$call_log" XDG_RUNTIME_DIR="$tmpdir" "$ROOT/bin/omarchy-system-lock"
}

# New lock requests and already-locked sessions both answer "ok".
run_lock
cat >"$tmpdir/expected" <<'EXPECTED'
omarchy-shell lock lock
hyprctl switchxkblayout all 0
pkill -x ttfx
timeout 1s pidwait -x ttfx
pkill -f [o]rg.omarchy.screensaver
EXPECTED
cmp -s "$tmpdir/expected" "$call_log" ||
  fail "accepted lock waits for ttfx before closing its terminal" "$(cat "$call_log")"
pass "accepted lock waits for ttfx before closing its terminal"

for reply in missing-pam failed ""; do
  : >"$call_log"
  status=0
  LOCK_REPLY="$reply" run_lock >/dev/null 2>"$tmpdir/error" || status=$?
  (( status == 1 )) || fail "refused lock returns failure" "reply: $reply; status: $status"
  [[ $(cat "$call_log") == $'omarchy-shell lock lock\nhyprctl switchxkblayout all 0' ]] ||
    fail "refused lock preserves the screensaver" "$(cat "$call_log")"
  [[ -s $tmpdir/error ]] || fail "refused lock explains the failure"
done
pass "refused and empty lock replies preserve the screensaver and return failure"

: >"$call_log"
status=0
LOCK_STATUS=7 run_lock >/dev/null 2>&1 || status=$?
(( status == 7 )) || fail "failed IPC preserves its exit status" "status: $status"
[[ $(cat "$call_log") == $'omarchy-shell lock lock\nhyprctl switchxkblayout all 0' ]] ||
  fail "failed IPC preserves the screensaver" "$(cat "$call_log")"
pass "failed IPC preserves its exit status and the screensaver"

# Capture stdout so the subshell also waits for the finite background vault-lock
# fixture. Every invoked command is mocked; no real process or vault is touched.
: >"$call_log"
status=0
output=$(PASSWORD_MANAGER_RUNNING=1 LOCK_STATUS=7 run_lock 2>"$tmpdir/error") || status=$?
(( status == 7 )) || fail "IPC failure remains visible after password-manager protection" "status: $status"
(( $(grep -c '^1password --lock$' "$call_log") == 1 )) ||
  fail "failed screen lock still locks the password manager once" "$(cat "$call_log")"
grep -F 'timeout --kill-after=1s 3s 1password --lock' "$call_log" >/dev/null ||
  fail "password-manager locking keeps its timeout"
if grep -q '^pkill ' "$call_log"; then
  fail "password-manager protection does not tear down the screensaver after failed lock"
fi
pass "failed screen lock retains bounded password-manager protection without screensaver teardown"
