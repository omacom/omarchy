#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
call_log="$tmpdir/calls"
mkdir -p "$mock_bin"

cat >"$mock_bin/busctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$CALL_LOG"
SH
chmod +x "$mock_bin/busctl"

helper="$ROOT/shell/plugins/lock/login-session.sh"
session="--allow-interactive-authorization=no org.freedesktop.login1 /org/freedesktop/login1/session/auto org.freedesktop.login1.Session"

run_helper() {
  : >"$call_log"
  PATH="$mock_bin:$PATH" CALL_LOG="$call_log" "$helper" "$@"
}

run_helper lock
[[ $(<"$call_log") == "call $session Lock" ]] ||
  fail "lock asks logind to send the Lock signal" "calls: $(<"$call_log")"
pass "lock asks logind to send the Lock signal"

run_helper locked
[[ $(<"$call_log") == "call $session SetLockedHint b true" ]] ||
  fail "locked sets logind's locked hint" "calls: $(<"$call_log")"
pass "locked sets logind's locked hint"

run_helper unlocked
[[ $(<"$call_log") == "call $session SetLockedHint b false" ]] ||
  fail "unlocked clears logind's locked hint" "calls: $(<"$call_log")"
pass "unlocked clears logind's locked hint"

if run_helper bogus 2>/dev/null; then
  fail "an unknown action is refused"
fi
[[ ! -s $call_log ]] || fail "an unknown action calls nothing" "calls: $(<"$call_log")"
pass "an unknown action is refused and calls nothing"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

assert(
  /onLockedChanged: \{\s*if \(locked\) loginLockProc\.running = true/.test(serviceQml),
  'a lock request sends logind the Lock signal'
)

assert(
  /id: loginLockProc\s*command: \["bash", Quickshell\.env\("OMARCHY_PATH"\) \+ "\/shell\/plugins\/lock\/login-session\.sh", "lock"\]/.test(serviceQml),
  'the Lock signal goes through the login session helper'
)

assert(
  /function syncLoginHint\(\) \{\s*loginHintProc\.command = \[[^\]]*login-session\.sh", sessionLock\.secure \? "locked" : "unlocked"\]\s*loginHintProc\.running = true/.test(serviceQml),
  'the locked hint reports whether the session lock is secure'
)

// A bound command made the hint lag one change behind.
assert(
  /id: loginHintProc\s*\}/.test(serviceQml),
  'the locked hint command is set when the hint is synced, not bound'
)

assert(
  /onSecureStateChanged: \{[\s\S]*?root\.syncLoginHint\(\)/.test(serviceQml),
  'the locked hint is updated whenever the session lock is taken or released'
)

assert(
  /root\.strandedLockResolved = true[\s\S]*?if \(exitCode !== 0\) root\.syncLoginHint\(\)/.test(serviceQml),
  'startup clears a hint left by a dead shell once the compositor reports no lock'
)
JS
