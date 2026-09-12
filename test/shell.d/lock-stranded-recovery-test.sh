#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

function bodyOf(src, name, label) {
  const start = src.indexOf(`function ${name}(`)
  assert(start !== -1, `${label}: source defines ${name}()`)
  const open = src.indexOf('{', start)
  let depth = 0
  for (let i = open; i < src.length; i++) {
    if (src[i] === '{') depth += 1
    else if (src[i] === '}') {
      depth -= 1
      if (depth === 0) return src.slice(open + 1, i)
    }
  }
  fail(`${label}: ${name}() has balanced braces`)
}

assert(
  /Component\.onCompleted:[\s\S]*checkStrandedLock\(\)/.test(serviceQml),
  'the lock service asks the compositor whether the session is locked at startup'
)

assert(
  /id: strandedLockCheckProc[\s\S]*omarchy-hyprland-session-locked/.test(serviceQml),
  'the startup check goes through the shared compositor lock helper'
)

assert(
  /onExited: function\(exitCode\) \{[\s\S]*if \(exitCode === 2\) return/.test(serviceQml),
  'an undetermined compositor answer never resolves the check'
)

const ownership = serviceQml.match(/readonly property bool sessionLockOwned:([^\n]*)/)
assert(ownership, 'the lock service exposes deterministic ownership to the shell')
assertEqual(
  ownership[1].trim(),
  'lockRequested || sessionLock.locked',
  'ownership is requested or instance-owned, without the stale secure flag'
)

const check = bodyOf(serviceQml, 'checkStrandedLock', 'stranded check')
assert(
  check.includes('if (sessionLockOwned)'),
  'a lock this service owns ends the stranded-lock search'
)
assert(
  !/\blocked\b/.test(check),
  'the stranded check does not consult the wider locked state containing secure'
)

assert(
  /root\.strandedLock = exitCode === 0 && !root\.sessionLockOwned/.test(serviceQml),
  'a compositor lock without an instance-owned surface is classified as stranded'
)

const recover = bodyOf(serviceQml, 'recoverStrandedLock', 'stranded recovery')
assert(
  recover.includes('!lockOwnerReady'),
  'recovery waits until the persisted lock owner is known'
)
assert(
  recover.includes('lockOwnerInstance === String(Quickshell.instanceId)'),
  'recovery distinguishes a poisoned in-process remount from a fresh shell'
)
assert(
  recover.indexOf('restartForStrandedLock()') < recover.indexOf('beginLock()'),
  'an in-process orphan restarts before the fresh-shell takeover path'
)

const restart = bodyOf(serviceQml, 'restartForStrandedLock', 'poisoned-shell restart')
assert(
  restart.includes('Quickshell.execDetached(["omarchy-restart-shell"])'),
  'the recovery command is detached from the shell it terminates'
)
assert(
  restart.includes('strandedRestartAttempted = true'),
  'a poisoned service serializes each restart attempt'
)
assert(
  /id: strandedRestartRetryTimer[\s\S]*strandedRestartAttempted = false[\s\S]*restartForStrandedLock\(\)/.test(serviceQml),
  'a transiently refused detached restart is retried while poison remains'
)
assert(
  /readonly property bool lockStatePoisoned: sessionLock\.secure && !sessionLock\.locked && !cleanUnlockInProgress/.test(serviceQml) &&
    /onLockStatePoisonedChanged: if \(lockStatePoisoned\) recoverPoisonedLockState\(\)/.test(serviceQml),
  'the real stale-secure tuple triggers recovery without trusting the wider locked state'
)
assert(
  /function finishUnlock\(\)[\s\S]*cleanUnlockInProgress = true[\s\S]*sessionLock\.locked = false/.test(serviceQml) &&
    /onSecureStateChanged:[\s\S]*if \(!secure\) \{[\s\S]*root\.cleanUnlockInProgress = false/.test(serviceQml),
  'the expected secure-to-unlocked transition cannot be mistaken for poison'
)
const begin = bodyOf(serviceQml, 'beginLock', 'lock request')
assert(
  !begin.includes('cleanUnlockInProgress = false'),
  'an immediate relock keeps the clean-unlock suppressor until secure actually falls'
)
assert(
  /if \(!secure\) \{[\s\S]*cleanUnlockInProgress = false[\s\S]*if \(root\.lockRequested\) root\.queueSessionLock\(\)/.test(serviceQml),
  'the secure-false transition resumes an immediate relock without poison recovery'
)
assert(
  /function lock\(\): string \{[\s\S]*lockStatePoisoned[\s\S]*recoverPoisonedLockState\(\)[\s\S]*return "recovering"/.test(serviceQml),
  'manual lock cannot report success from a poisoned secure flag'
)

// Model the exact unlock -> immediate lock -> delayed secure=false ordering.
// Clearing suppression in beginLock would synchronously increment restarts.
const transition = { secure: true, sessionLocked: false, clean: true, requested: false, restarts: 0, queued: 0 }
function observePoison() {
  if (transition.secure && !transition.sessionLocked && !transition.clean) transition.restarts += 1
}
transition.requested = true
observePoison()
assertEqual(transition.restarts, 0, 'immediate relock does not dispatch poisoned-shell recovery')
transition.secure = false
transition.clean = false
if (transition.requested) transition.queued += 1
observePoison()
assertEqual(transition.restarts, 0, 'secure falling cannot poison the latched relock')
assertEqual(transition.queued, 1, 'secure falling resumes the latched relock')

const mark = bodyOf(serviceQml, 'markSessionLockOwner', 'owner marker')
assert(
  mark.includes('Quickshell.instanceId') && mark.includes('lockOwnerFile.setText'),
  'a service records the Quickshell instance that acquired the lock'
)

assert(
  /lockOwnerPath:[^\n]*HYPRLAND_INSTANCE_SIGNATURE/.test(serviceQml),
  'the owner marker is isolated to one Hyprland session'
)
assert(
  /id: lockOwnerFile[\s\S]*blockWrites: true/.test(serviceQml),
  'the owner marker reaches tmpfs before the lock service can be destroyed'
)

const clear = bodyOf(serviceQml, 'clearSessionLockOwner', 'owner marker cleanup')
assert(
  clear.includes('lockOwnerFile.setText("")'),
  'a clean unlock clears the persisted lock owner'
)

assert(
  /if \(locked\) \{\s*root\.markSessionLockOwner\(\)/.test(serviceQml),
  'a lock-state notification records this service as the owner'
)

const request = bodyOf(serviceQml, 'requestSessionLock', 'session-lock acquisition')
assert(
  request.indexOf('sessionLock.locked = true') < request.indexOf('if (sessionLock.locked) markSessionLockOwner()'),
  'successful lock acquisition records the owner even when no state notification fires'
)

assert(
  /id: strandedLockRetryTimer[\s\S]*running: !root\.strandedLockResolved && remaining > 0/.test(serviceQml),
  'the compositor check retries while its answer is unavailable'
)

assert(
  /function onScreensChanged\(\) \{[\s\S]*strandedLockRetryTimer\.rearm\(\)[\s\S]*root\.checkStrandedLock\(\)/.test(serviceQml),
  'a screen coming back gives the compositor check another settling budget'
)
JS
