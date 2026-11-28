#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# A locked binding that missed a change once read locked after an unlock, and
# the lock before suspend took that for done, so the machine resumed unlocked.
# The session lock only changes state under a compositor, so nothing offscreen
# can make it disagree with a binding; this reads the source instead, as the
# one guard on a lock that must hold.
run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

assert(
  /function currentlyLocked\(\) \{\s*return lockRequested \|\| sessionLock\.locked \|\| sessionLock\.secure\s*\}/.test(serviceQml),
  'the lock state is read from the session lock itself, not a cached binding'
)
assert(
  /function lock\(\): string \{[\s\S]*?if \(!root\.currentlyLocked\(\) && !root\.beginLock\(\)\) return "failed"/.test(serviceQml)
    && /function isLocked\(\): string \{\s*return root\.currentlyLocked\(\)/.test(serviceQml)
    && /locked: root\.currentlyLocked\(\),/.test(serviceQml),
  'lock, isLocked and status decide from the current lock state'
)

// Exercise the real password failure settlement handlers: PAM can emit both
// onError and onCompleted for a single attempt, which must count once and
// always scrub pendingPassword.
const handleFailureFn = serviceQml.match(/function handlePasswordFailure\(\) \{[\s\S]*?\n  \}/)[0]
const passwordPamBlock = serviceQml.match(/PamContext \{\s*id: passwordPam[\s\S]*?\n  \}/)[0]
const onCompletedBody = passwordPamBlock.match(/onCompleted: function\(result\) \{([\s\S]*?)\n    \}/)[1]
const onErrorBody = passwordPamBlock.match(/onError: function\(error\) \{([\s\S]*?)\n    \}/)[1]

function runPasswordPam(events, lockRequested = true) {
  const ctx = {
    lockRequested,
    authenticatingPassword: true,
    enteredPassword: 'secret',
    pendingPassword: 'secret',
    failedAttempts: 0,
    failureMessage: '',
    unlocked: false,
    woke: 0,
    PamResult: { Success: 0, Failed: 1 },
    I18n: { t: () => ({ arg: v => `Failed (${v})` }), formatNumber: n => String(n) },
    runWake() { this.woke += 1 },
    finishUnlock() { this.unlocked = true }
  }
  ctx.root = ctx
  require('vm').runInNewContext(
    `${handleFailureFn}\nfunction fireCompleted(result) {${onCompletedBody}}\nfunction fireError(error) {${onErrorBody}}`,
    ctx
  )
  for (const [kind, arg] of events) {
    if (kind === 'error') ctx.fireError(arg)
    else ctx.fireCompleted(arg)
  }
  return ctx
}

let attempt = runPasswordPam([['error', 1], ['completed', 1]])
assertEqual(attempt.failedAttempts, 1, 'password onError followed by onCompleted counts a single failure')
assertEqual(attempt.pendingPassword, '', 'password failure scrubs pendingPassword')

attempt = runPasswordPam([['completed', 1], ['error', 1]])
assertEqual(attempt.failedAttempts, 1, 'password onCompleted followed by onError counts a single failure')

attempt = runPasswordPam([['error', 1]], false)
assertEqual(attempt.failedAttempts, 0, 'password error after unlock does not increment failedAttempts')
assertEqual(attempt.pendingPassword, '', 'password error after unlock still scrubs pendingPassword')
assertEqual(attempt.authenticatingPassword, false, 'password error after unlock clears authenticatingPassword')
JS
