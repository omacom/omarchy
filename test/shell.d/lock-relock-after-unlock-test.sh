#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

const lockBody = serviceQml.match(/function lock\(\): string \{([\s\S]*?)\n    \}/)
const finishUnlockBody = serviceQml.match(/function finishUnlock\(\) \{([\s\S]*?)\n  \}/)
assert(lockBody && finishUnlockBody, 'the lock IPC method and finishUnlock are defined')

// A lock request must start a lock whenever nothing is actually locked, even
// when the derived `locked` binding is stale.
const ipcLock = new Function('root', 'sessionLock', lockBody[1])

function lockService(state) {
  const service = {
    passwordPamConfigured: true,
    lockRequested: false,
    locked: false,
    began: 0,
    beginLock() {
      this.began += 1
      return true
    },
    ...state,
  }
  return service
}

let service = lockService({ locked: true })
assertEqual(ipcLock(service, { locked: false, secure: false }), 'ok', 'a lock request with a stale locked binding answers ok')
assertEqual(service.began, 1, 'a lock request with a stale locked binding still starts the lock')

service = lockService()
ipcLock(service, { locked: false, secure: false })
assertEqual(service.began, 1, 'a lock request starts the lock when unlocked')

for (const [description, state, sessionLock] of [
  ['requested', { lockRequested: true, locked: true }, { locked: false, secure: false }],
  ['session-locked', { locked: true }, { locked: true, secure: false }],
  ['secure', { locked: true }, { locked: false, secure: true }],
]) {
  service = lockService(state)
  assertEqual(ipcLock(service, sessionLock), 'ok', `a lock request while ${description} answers ok`)
  assertEqual(service.began, 0, `a lock request while ${description} does not start a second lock`)
}

service = lockService({ passwordPamConfigured: false })
assertEqual(ipcLock(service, { locked: false, secure: false }), 'missing-pam', 'a lock request without PAM is refused')
assertEqual(service.began, 0, 'a lock request without PAM does not start the lock')

// WlSessionLock does not always notify when it releases: releasing it drops
// `secure` (which notifies) while `locked` still reads as held, then clears
// `locked` silently. `locked` only stays correct when the last notifying
// change happens after the release.
function unlockScope() {
  const timer = { stop() {} }
  const scope = {
    locked: true,
    pendingSessionLock: false,
    sessionLockStabilizeTimer: timer,
    pendingSessionLockTimer: timer,
    idleBlankTimer: timer,
    resetAuthenticationState() {},
    logEvent() {},
    runWake() {},
  }
  let lockRequested = true
  let held = true
  let secure = true
  const recompute = () => { scope.locked = lockRequested || held || secure }
  scope.sessionLock = {
    get locked() { return held },
    set locked(value) {
      if (value) return
      secure = false
      recompute()
      held = false
    },
    get secure() { return secure },
  }
  Object.defineProperty(scope, 'lockRequested', {
    get() { return lockRequested },
    set(value) {
      lockRequested = value
      recompute()
    },
  })
  scope.root = scope
  return scope
}

const finishUnlock = new Function('scope', `with (scope) {${finishUnlockBody[1]}}`)
const scope = unlockScope()
finishUnlock(scope)
assertEqual(scope.lockRequested, false, 'unlock clears the lock request')
assertEqual(scope.sessionLock.locked, false, 'unlock releases the session lock')
assertEqual(scope.locked, false, 'locked reads false after unlock even though the session lock release did not notify')
JS
