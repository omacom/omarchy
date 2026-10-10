#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq
real_timeout=$(command -v timeout)

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const receipts = requireFromRoot('shell/plugins/lock/LockRequestModel.js')
const source = fs.readFileSync(root + '/shell/plugins/lock/Service.qml', 'utf8')
const ledger = receipts.create('instance-a')
const first = receipts.request(ledger, 0)
assertEqual(first.state, 'pending', 'a tracked request starts pending')
assertEqual(receipts.request(ledger, 1).requestId, first.requestId, 'concurrent callers share the active lock request')
receipts.secured(ledger, 2)
receipts.released(ledger, 3)
assertEqual(receipts.result(ledger, first.requestId, 3).state, 'secured', 'a secure receipt survives authenticated unlock')
const second = receipts.request(ledger, 4)
assert(second.requestId !== first.requestId, 'a later lock gets a distinct request token')
assertEqual(receipts.result(ledger, second.requestId, 4).state, 'pending', 'an earlier secure receipt cannot satisfy a later request')
assertEqual(receipts.result(receipts.create('instance-b'), first.requestId).state, 'unknown', 'a shell restart rejects receipts from the old instance')
receipts.released(ledger, 5)
assertEqual(receipts.result(ledger, second.requestId, 5).state, 'failed', 'a request dropped before security records failure')
receipts.secured(ledger, 6)
assertEqual(receipts.result(ledger, second.requestId, 6).state, 'failed', 'a terminal failed receipt never becomes a successful other request')

const saturated = receipts.create('saturation')
const ids = []
for (let i = 0; i < 64; i++) {
  const request = receipts.request(saturated, 0)
  ids.push(request.requestId)
  receipts.secured(saturated, 0)
  receipts.released(saturated, 0)
}
assertEqual(receipts.request(saturated, 29999), null, 'receipt saturation refuses a new tracked request instead of evicting an in-budget receipt')
assertEqual(receipts.result(saturated, ids[0], 29999).state, 'secured', 'bounded retention preserves receipts beyond the command deadline')
assert(receipts.request(saturated, 30000), 'expired receipts free capacity without reusing their identifiers')
assertEqual(receipts.result(saturated, ids[0]).state, 'unknown', 'an expired receipt cannot prove a new lock')

const readExpiry = receipts.create('read-expiry')
const archived = receipts.request(readExpiry, 0)
receipts.secured(readExpiry, 1)
receipts.released(readExpiry, 2)
assertEqual(receipts.result(readExpiry, archived.requestId, 30001).state, 'secured', 'an archived secure receipt remains valid until its retention boundary')
assertEqual(receipts.result(readExpiry, archived.requestId, 30002).state, 'unknown', 'an archived secure receipt expires on read without another request')
assertEqual(readExpiry.order.length, 0, 'read expiry also releases the archived receipt capacity')
const failed = receipts.request(readExpiry, 30002)
receipts.released(readExpiry, 30003)
assertEqual(receipts.result(readExpiry, failed.requestId, 60003).state, 'unknown', 'an archived failed receipt expires on read')
const held = receipts.request(readExpiry, 60004)
assertEqual(receipts.result(readExpiry, held.requestId, 100000).state, 'pending', 'retention does not discard a currently pending request')
receipts.secured(readExpiry, 100001)
assertEqual(receipts.request(readExpiry, 200000).requestId, held.requestId, 'an already-locked caller keeps the current active token after thirty seconds')
assertEqual(receipts.result(readExpiry, held.requestId, 200000).state, 'secured', 'the current held lock still has a successful receipt after thirty seconds')
receipts.released(readExpiry, 200001)
assertEqual(receipts.result(readExpiry, held.requestId, 201001).state, 'secured', 'a fresh already-locked caller can read its old active receipt after a fast unlock')
assertEqual(receipts.result(readExpiry, held.requestId, 230000).state, 'secured', 'a released long-held lock gets the complete archived retention window')
assertEqual(receipts.result(readExpiry, held.requestId, 230001).state, 'unknown', 'a released long-held lock expires thirty seconds after release')
assertEqual(receipts.request(readExpiry, 230002).state, 'pending', 'read expiry permits a new request without an old secure outcome')

const context = {
  LockRequests: receipts,
  requestLedger: receipts.create('qml-instance'),
  lockRequested: true,
  locked: true,
  secure: true,
  pendingSessionLock: true,
  logEvent() {},
  resetAuthenticationState() {},
  runWake() {},
  sessionLock: { locked: true, secure: true },
  sessionLockStabilizeTimer: { stop() {} },
  pendingSessionLockTimer: { stop() {} },
  idleBlankTimer: { stop() {} }
}
context.root = context
const qmlRequest = receipts.request(context.requestLedger, 0)
context.startFingerprint = function() {
  assertEqual(receipts.result(context.requestLedger, qmlRequest.requestId).state, 'secured', 'the QML secure handler records the outcome before fingerprint authentication starts')
}
const secureHandler = source.match(/onSecureStateChanged: \{([\s\S]*?)\n    \}/)
assert(secureHandler, 'the lock service exposes its secure-state handler')
vm.runInNewContext(secureHandler[1], context)
const finishUnlock = source.match(/function finishUnlock\(\) \{([\s\S]*?)\n  \}/)
assert(finishUnlock, 'the lock service exposes authenticated unlock cleanup')
vm.runInNewContext('(function() {' + finishUnlock[1] + '})()', context)
assertEqual(receipts.result(context.requestLedger, qmlRequest.requestId).state, 'secured', 'the shipped finishUnlock implementation preserves the request receipt')

const trackedRequest = source.match(/function request\(\): string \{([\s\S]*?)\n    \}/)
const lockHandler = source.match(/onLockStateChanged: \{([\s\S]*?)\n    \}/)
assert(trackedRequest && lockHandler, 'the service exposes tracked requests and lock-release lifecycle')
for (const lastFlag of ['secure', 'locked']) {
  const duringUnlock = {
    LockRequests: receipts,
    requestLedger: receipts.create('unlock-' + lastFlag),
    passwordPamConfigured: true,
    lockRequested: false,
    pendingSessionLock: false,
    sessionLock: { locked: lastFlag === 'locked', secure: lastFlag === 'secure' },
    secure: lastFlag === 'secure',
    logEvent() {},
    resetAuthenticationState() {},
    runWake() {},
    sessionLockStabilizeTimer: { stop() {} },
    pendingSessionLockTimer: { stop() {} },
    beginLock() { this.lockRequested = true; return true }
  }
  duringUnlock.root = duringUnlock
  Object.defineProperty(duringUnlock, 'locked', {
    get() { return this.lockRequested || this.sessionLock.locked || this.sessionLock.secure }
  })
  const inFlight = JSON.parse(vm.runInNewContext('(function() {' + trackedRequest[1] + '})()', duringUnlock))
  if (lastFlag === 'secure') {
    duringUnlock.sessionLock.secure = false
    duringUnlock.secure = false
    vm.runInNewContext(secureHandler[1], duringUnlock)
  } else {
    duringUnlock.sessionLock.locked = false
    // This handler's "locked" refers to the WlSessionLock, not root.locked.
    const withLockSignal = Object.create(duringUnlock)
    withLockSignal.root = duringUnlock
    Object.defineProperty(withLockSignal, 'locked', { value: false })
    vm.runInNewContext(lockHandler[1], withLockSignal)
  }
  const afterUnlock = JSON.parse(vm.runInNewContext('(function() {' + trackedRequest[1] + '})()', duringUnlock))
  assert(afterUnlock.requestId !== inFlight.requestId, 'a tracked call during ' + lastFlag + ' release is not reused after unlock')
  assertEqual(afterUnlock.state, 'pending', 'a new call after ' + lastFlag + ' release cannot inherit an old secure outcome')
}

const jumped = receipts.create('clock-jump')
const beforeJump = receipts.request(jumped, 0)
receipts.secured(jumped, 1)
receipts.released(jumped, 2)
const afterJump = receipts.request(jumped, 100000)
assertEqual(receipts.result(jumped, beforeJump.requestId).state, 'unknown', 'forward wall-clock jumps expire a receipt conservatively')
assertEqual(afterJump.state, 'pending', 'a clock jump never turns an old success into a new request success')

const legacy = source.match(/function lock\(\): string \{([\s\S]*?)\n    \}/)
assert(legacy, 'legacy lock IPC remains available')
const legacyRoot = { passwordPamConfigured: true, locked: false, beginLock() { this.locked = true; return true } }
assertEqual(vm.runInNewContext('(function() {' + legacy[1] + '})()', { root: legacyRoot }), 'ok', 'legacy lock IPC retains its ok reply')
legacyRoot.passwordPamConfigured = false
assertEqual(vm.runInNewContext('(function() {' + legacy[1] + '})()', { root: legacyRoot }), 'missing-pam', 'legacy lock IPC retains its refusal reply')
JS

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mock_bin="$tmpdir/bin"
call_log="$tmpdir/calls"
mkdir -p "$mock_bin"

for command in hyprctl pkill timeout omarchy-notification-send; do
  cat >"$mock_bin/$command" <<'MOCK'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >>"$CALL_LOG"
MOCK
done

cat >"$mock_bin/omarchy-shell" <<'MOCK'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >>"$CALL_LOG"
case "${2:-}" in
request)
  case "${LOCK_REPLY:-}" in
  missing-pam) printf '{"reason":"missing-pam"}\n' ;;
  unavailable) exit 1 ;;
  malformed) printf 'not json\n' ;;
  *) printf '{"requestId":"current-instance:1","state":"pending"}\n' ;;
  esac
  ;;
result)
  polls=$(( $(cat "$POLL_COUNT" 2>/dev/null || echo 0) + 1 ))
  printf '%s' "$polls" >"$POLL_COUNT"
  id=current-instance:1
  state=pending
  if [[ ${RESULT_ID:-} != "" ]]; then id=$RESULT_ID; fi
  if [[ ${SECURE_AFTER:-1} != "never" ]] && (( polls >= ${SECURE_AFTER:-1} )); then state=secured; fi
  if [[ ${LOCK_REPLY:-} == "dropped" ]]; then state=failed; fi
  if [[ ${LOCK_REPLY:-} == "restart" ]]; then state=unknown; fi
  printf '{"requestId":"%s","state":"%s","requested":%s,"secure":%s}\n' \
    "$id" "$state" "${REQUESTED:-true}" "${CURRENT_SECURE:-true}"
  ;;
*) exit 1 ;;
esac
MOCK
cat >"$mock_bin/pgrep" <<'MOCK'
#!/bin/bash
exit 1
MOCK
chmod +x "$mock_bin"/*

run_lock() {
  local rc=0
  : >"$call_log"
  : >"$tmpdir/polls"
  PATH="$mock_bin:$PATH" CALL_LOG="$call_log" POLL_COUNT="$tmpdir/polls" \
    SECURE_AFTER="${SECURE_AFTER:-1}" LOCK_REPLY="${LOCK_REPLY:-}" RESULT_ID="${RESULT_ID:-}" \
    REQUESTED="${REQUESTED:-true}" CURRENT_SECURE="${CURRENT_SECURE:-true}" \
    "$real_timeout" -k 5s 40s "$ROOT/bin/omarchy-system-lock" 2>"$tmpdir/stderr" || rc=$?
  return "$rc"
}

assert_one_request() {
  [[ $(grep -c '^omarchy-shell lock request$' "$call_log") == 1 ]] || fail "one invocation submits exactly one tracked request"
  if grep -q '^omarchy-shell lock lock$' "$call_log"; then fail "system lock never re-locks after a status snapshot"; fi
}
assert_failure() {
  local rc=$1
  ((rc == 1)) || fail "unconfirmed lock exits nonzero" "exit $rc, $(<"$tmpdir/stderr")"
  grep -q '^omarchy-notification-send .*Screen did not lock' "$call_log" || fail "failure requests a critical notification"
  if grep -q '^pkill ' "$call_log"; then fail "failed lock leaves the screensaver running"; fi
  grep -q '^hyprctl switchxkblayout all 0$' "$call_log" || fail "failed lock still resets the keyboard layout"
  assert_one_request
}

rc=0
run_lock || rc=$?
((rc == 0)) || fail "system lock succeeds once its request becomes secure" "exit $rc"
assert_one_request
pass "system lock succeeds with its matching secure receipt"

mapfile -t shutdown < <(rg '^(pkill|timeout) ' "$call_log")
[[ ${shutdown[0]} == "pkill -x ttfx" ]] || fail "system lock stops ttfx before closing its terminal"
[[ ${shutdown[1]} == "timeout 1s pidwait -x ttfx" ]] || fail "system lock waits for ttfx"
[[ ${shutdown[2]} == "pkill -f [o]rg.omarchy.screensaver" ]] || fail "system lock closes the terminal after ttfx"
secure_line=$(grep -n '^omarchy-shell lock result ' "$call_log" | head -1 | cut -d: -f1)
cleanup_line=$(grep -n '^pkill -x ttfx$' "$call_log" | cut -d: -f1)
((secure_line < cleanup_line)) || fail "screensaver cleanup follows the secure receipt"
pass "successful lock preserves screensaver shutdown ordering after security"

rc=0
SECURE_AFTER=3 run_lock || rc=$?
((rc == 0)) || fail "system lock waits for a request still arming"
assert_one_request
pass "a delayed secure request needs no second lock"

# The receipt remains secured even when authentication already cleared flags.
rc=0
REQUESTED=false CURRENT_SECURE=false run_lock || rc=$?
((rc == 0)) || fail "an immediate authenticated unlock remains a successful lock"
assert_one_request
pass "fast authenticated unlock does not re-lock or require a second authentication"

for reason in missing-pam unavailable malformed dropped restart; do
  rc=0
  LOCK_REPLY="$reason" run_lock || rc=$?
  assert_failure "$rc"
  pass "$reason cannot report lock success or close the screensaver"
done

rc=0
RESULT_ID=old-instance:1 run_lock || rc=$?
assert_failure "$rc"
pass "a stale or different request receipt cannot satisfy this invocation"

started=$SECONDS
rc=0
SECURE_AFTER=never REQUESTED=true CURRENT_SECURE=false run_lock || rc=$?
elapsed=$((SECONDS - started))
assert_failure "$rc"
((elapsed >= 8 && elapsed <= 13)) || fail "an accepted never-secure request ends within the command's deadline" "$elapsed seconds"
grep -q 'did not secure the session' "$tmpdir/stderr" || fail "never-secure failure reports its deadline"
pass "an accepted requested:true lock that never secures fails and notifies within ten seconds"
