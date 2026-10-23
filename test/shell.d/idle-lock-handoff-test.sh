#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const idle = requireFromRoot('shell/plugins/services/idle/IdleModel.js')
const handoff = requireFromRoot('shell/plugins/lock/Handoff.js')

assertDeepEqual(
  idle.dismissStart({ lockHandoff: false, dismissInFlight: false, windowCount: 2 }),
  { start: true, stopScreensaverTimer: true, stopLockTimer: true },
  'seat dismissal stops the screensaver and lock deadlines before the windows close'
)
assertDeepEqual(
  idle.dismissStart({ lockHandoff: true, dismissInFlight: false, windowCount: 2 }),
  { start: false },
  'seat dismissal does not start during lock handoff'
)
assertDeepEqual(
  idle.dismissStart({ lockHandoff: false, dismissInFlight: true, windowCount: 2 }),
  { start: false },
  'seat dismissal does not start a second time while one is in flight'
)
assertDeepEqual(
  idle.dismissStart({ lockHandoff: false, dismissInFlight: false, windowCount: 0 }),
  { start: false },
  'seat dismissal does nothing when no screensaver is mapped'
)

assertDeepEqual(
  idle.lockHandoffStart({ dismissInFlight: true }),
  { start: false },
  'a lock deadline that fires during dismissal does not start a handoff'
)
assertDeepEqual(
  idle.lockHandoffStart({ dismissInFlight: false }),
  { start: true },
  'a lock deadline starts a handoff when dismissal is not underway'
)

assertDeepEqual(
  idle.cancelIdleCyclePlan({ lockProcessRunning: true, lockHandoff: true, windowCount: 2, launchComplete: true }),
  { lockHandoff: true, holdHandoff: true, resetWindows: false, rearmDismiss: false },
  'Stay Awake during an in-flight lock keeps the handoff guard'
)
assertDeepEqual(
  idle.cancelIdleCyclePlan({ lockProcessRunning: false, lockHandoff: false, windowCount: 2, launchComplete: true }),
  { lockHandoff: false, holdHandoff: false, resetWindows: false, rearmDismiss: true },
  'Stay Awake keeps a visible screensaver dismissable'
)
assertDeepEqual(
  idle.cancelIdleCyclePlan({ lockProcessRunning: false, lockHandoff: false, windowCount: 0, launchComplete: false }),
  { lockHandoff: false, holdHandoff: false, resetWindows: true, rearmDismiss: false },
  'cancelling idle with no screensaver clears its tracking'
)

assertDeepEqual(
  idle.lockExitPlan({ exitCode: 0, windowCount: 2 }),
  { lockHandoff: false, resetWindows: true, rearmDismiss: false },
  'a finished handoff clears screensaver tracking'
)
assertDeepEqual(
  idle.lockExitPlan({ exitCode: 1, windowCount: 2 }),
  { lockHandoff: false, resetWindows: false, rearmDismiss: true },
  'a failed handoff keeps the screensaver and restores dismissal'
)
assertDeepEqual(
  idle.lockExitPlan({ exitCode: 1, windowCount: 0 }),
  { lockHandoff: false, resetWindows: true, rearmDismiss: false },
  'a failed handoff with no screensaver clears stale tracking'
)

assertDeepEqual(
  idle.lateScreensaverWindowPlan({ alreadyLaunchComplete: true, completesNow: false }),
  { clearSettled: true, restartArmTimer: true },
  'a screensaver window that maps after launch complete restarts the arm timer'
)
assertDeepEqual(
  idle.lateScreensaverWindowPlan({ alreadyLaunchComplete: false, completesNow: false }),
  { clearSettled: true, restartArmTimer: false },
  'a screensaver window before launch complete does not arm dismissal early'
)
assertDeepEqual(
  idle.lateScreensaverWindowPlan({ alreadyLaunchComplete: true, completesNow: true }),
  { clearSettled: true, restartArmTimer: false },
  'the window that completes launch does not also take the late-window path'
)

assertEqual(handoff.ignoresPointerWake(true, false), true, 'mapping the concealed lock ignores the pointer already sitting there')
assertEqual(handoff.ignoresPointerWake(true, true), false, 'pointer movement after the concealed lock settles can reveal authentication')
assertEqual(handoff.ignoresPointerWake(false, false), false, 'pointer movement on a revealed lock is a real wake')
JS

require_command jq

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mock_bin="$tmpdir/bin"
call_log="$tmpdir/calls"
poll_count="$tmpdir/polls"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$CALL_LOG"
case "$*" in
  "lock lockFromIdle")
    exit "${LOCK_FROM_IDLE_RC:-0}"
    ;;
  "lock isLocked")
    printf '%s\n' "${LOCK_IS_LOCKED:-true}"
    ;;
  "lock status")
    count=0
    [[ -f $POLL_COUNT ]] && count=$(<"$POLL_COUNT")
    count=$((count + 1))
    printf '%s\n' "$count" >"$POLL_COUNT"
    if (( count >= ${SECURE_ON_POLL:-1} )); then
      printf '%s\n' '{"secure":true}'
    else
      printf '%s\n' '{"secure":false}'
    fi
    ;;
esac
SH

cat >"$mock_bin/omarchy-system-lock" <<'SH'
#!/bin/bash
printf 'system-lock %s\n' "$*" >>"$CALL_LOG"
exit 0
SH
chmod +x "$mock_bin"/*

handoff="$ROOT/shell/plugins/services/idle/lock-handoff.sh"

run_handoff() {
  PATH="$mock_bin:$PATH" \
    CALL_LOG="$call_log" \
    POLL_COUNT="$poll_count" \
    LOCK_FROM_IDLE_RC="${LOCK_FROM_IDLE_RC:-0}" \
    LOCK_IS_LOCKED="${LOCK_IS_LOCKED:-true}" \
    SECURE_ON_POLL="${SECURE_ON_POLL:-1}" \
    OMARCHY_IDLE_LOCK_WAIT_SECONDS="${OMARCHY_IDLE_LOCK_WAIT_SECONDS:-10}" \
    bash "$handoff"
}

: >"$call_log"
rm -f "$poll_count"
run_handoff
grep -qx 'lock lockFromIdle' "$call_log" || fail "idle handoff asks for the concealed lock"
grep -qx 'system-lock cleanup' "$call_log" || fail "a secure idle lock removes the screensaver without requesting another lock"
grep -q 'lock lock$' "$call_log" && fail "idle handoff cleanup must not request a second lock"

: >"$call_log"
rm -f "$poll_count"
SECURE_ON_POLL=99 OMARCHY_IDLE_LOCK_WAIT_SECONDS=0 run_handoff && fail "an idle lock that never becomes secure must stop waiting"
grep -q '^system-lock ' "$call_log" && fail "giving up on a secure lock must leave the screensaver mapped"

: >"$call_log"
rm -f "$poll_count"
LOCK_IS_LOCKED=false run_handoff && fail "an idle lock that disappears must not report success"
grep -q '^system-lock ' "$call_log" && fail "a disappeared idle lock must leave the screensaver mapped"

: >"$call_log"
rm -f "$poll_count"
LOCK_FROM_IDLE_RC=1 run_handoff && fail "a refused idle lock must not wait"
grep -q 'lock isLocked' "$call_log" && fail "a refused idle lock must not poll"

: >"$call_log"
rm -f "$poll_count"
SECURE_ON_POLL=2 OMARCHY_IDLE_LOCK_WAIT_SECONDS=5 run_handoff
[[ $(<"$poll_count") == 2 ]] || fail "idle handoff keeps waiting until the lock is secure" "polls: $(<"$poll_count")"
grep -qx 'system-lock cleanup' "$call_log" || fail "idle handoff cleans up once a later poll is secure"

pass "Idle lock handoff waits for a secure lock, then cleans up without locking again"
