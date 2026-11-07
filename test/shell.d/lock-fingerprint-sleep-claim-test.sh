#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The claim policy is pure and runs with no reader, no logind, and no compositor.
# The service fixture drives the same functions against the QML timers.

run_node_test <<'JS'
const fs = require('fs')
const model = requireFromRoot('shell/plugins/lock/FingerprintModel.js')

assertEqual(model.prepareForSleepSignal('   boolean true'), true, 'the suspend value is the true edge')
assertEqual(model.prepareForSleepSignal('   boolean false'), false, 'the wake value is the false edge')
assertEqual(
  model.prepareForSleepSignal("signal time=1 sender=:1.0 path=/org/freedesktop/login1; interface=org.freedesktop.login1.Manager; member=PrepareForSleep"),
  null,
  'the signal header is not a sleep edge'
)
assertEqual(model.prepareForSleepSignal(''), null, 'an empty monitor line is ignored')
assertEqual(model.prepareForSleepSignal('boolean true extra'), true, 'a value line still matches when dbus-monitor adds a suffix')

assertEqual(model.sleepClaimTransition(true, false), 'release', 'the first suspend edge releases the claim')
assertEqual(model.sleepClaimTransition(false, true), 'restart', 'the wake edge after a release may start one verify')
assertEqual(model.sleepClaimTransition(true, true), 'none', 'a repeated suspend edge does not release twice')
assertEqual(model.sleepClaimTransition(false, false), 'none', 'a wake with no pending suspend does nothing')
assert(model.mayStartClaim(false), 'a claim may start while the machine is awake')
assert(!model.mayStartClaim(true), 'a claim may not start while suspend is pending')

// The lock can be taken inside the delay window. Nothing may claim until wake,
// and the wake arms one verify even though the retry timer was stopped.
function step(state, event) {
  if (event === 'start') {
    if (!model.mayStartClaim(state.preparing)) return 'refused'
    state.claim = true
    state.retry = false
    return 'claim'
  }
  const sleeping = event === 'sleep'
  const transition = model.sleepClaimTransition(sleeping, state.preparing)
  if (transition === 'release') {
    state.preparing = true
    state.claim = false
    state.retry = false
    return 'release'
  }
  if (transition === 'restart') {
    state.preparing = false
    state.retry = state.lockRequested && state.configured && !state.paused
    state.claim = false
    return state.retry ? 'restart' : 'restart-idle'
  }
  return 'none'
}

const held = { preparing: false, claim: false, retry: false, lockRequested: true, configured: true, paused: false }
assertEqual(step(held, 'start'), 'claim', 'an awake lock claims the reader')
assertEqual(step(held, 'sleep'), 'release', 'suspend drops that claim')
assertEqual(held.claim, false, 'the released claim is gone')
assertEqual(step(held, 'start'), 'refused', 'a lock taken while suspending does not claim')
assertEqual(step(held, 'sleep'), 'none', 'the suspend edge does not start a replacement verify')
assertEqual(step(held, 'wake'), 'restart', 'resume arms one fresh verify')
assertEqual(held.preparing, false, 'resume leaves the next claim allowed')
assertEqual(step(held, 'wake'), 'none', 'a second wake does not cancel the fresh verify')
assertEqual(step(held, 'start'), 'claim', 'the verify after resume is a new claim')

const duringSleep = { preparing: false, claim: false, retry: false, lockRequested: true, configured: true, paused: false }
assertEqual(step(duringSleep, 'sleep'), 'release', 'suspend before the lock is secure still holds claims')
assertEqual(step(duringSleep, 'start'), 'refused', 'securing the lock during that window does not claim')
assertEqual(step(duringSleep, 'wake'), 'restart', 'resume of a lock taken on the way down starts the verify')

const blanked = { preparing: false, claim: true, retry: false, lockRequested: true, configured: true, paused: true }
assertEqual(step(blanked, 'sleep'), 'release', 'a claim left running while the displays are off is still released')
assertEqual(blanked.claim, false, 'the blanked claim does not cross suspend')
assertEqual(step(blanked, 'wake'), 'restart-idle', 'a blanked resume does not arm a verify through the awake path')

const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

function sliceBetween(start, end) {
  const from = serviceQml.indexOf(start)
  const to = serviceQml.indexOf(end, from === -1 ? 0 : from + start.length)
  if (from === -1 || to === -1) fail('missing ' + start)
  return serviceQml.slice(from, to)
}

const release = sliceBetween('function releaseFingerprintClaim()', 'function prepareFingerprintForSleep(')
assert(release.includes('fingerprintPam.abort()'), 'releasing the verify aborts the fingerprint PAM claim')
assert(release.includes('fingerprintRetryTimer.stop()'), 'release stops the retry that would claim again before suspend')
assert(release.includes('fingerprintReachTimer.stop()'), 'release stops the reach bound from aborting mid-transition later')
assert(release.includes('fingerprintRecheckTimer.stop()'), 'release stops the enrollment probe from activating fprintd')
assert(release.includes('fingerprintPreparingForSleep = true'), 'release holds every new claim until wake')
assert(!/armFingerprintRetry\(/.test(release), 'release does not arm a replacement verify')

const prepare = sliceBetween('function prepareFingerprintForSleep(sleeping)', 'function clearFingerprintSleepHold()')
assert(prepare.includes('FingerprintModel.sleepClaimTransition(sleeping, fingerprintPreparingForSleep)'), 'suspend and wake share one transition')
assert(prepare.includes('releaseFingerprintClaim()'), 'the suspend edge releases the claim')
assert(prepare.includes('restartFingerprintAfterSleep()'), 'the wake edge restarts from a clean claim')
assert(prepare.includes('fingerprintSleepWatch.lastTickMs = Date.now()'), 'the wall-clock watch does not treat this wake as a second resume')

const start = sliceBetween('function startFingerprint()', 'function noteFingerprintReachedDevice()')
assert(start.indexOf('mayStartClaim(fingerprintPreparingForSleep)') !== -1, 'starting a verify checks the suspend hold')
assert(
  start.indexOf('mayStartClaim(fingerprintPreparingForSleep)') < start.indexOf('fingerprintPam.start()'),
  'the suspend hold is checked before a new PAM claim'
)

assert(
  serviceQml.includes('member=\'PrepareForSleep\''),
  'the lock follows logind PrepareForSleep for the life of the shell'
)
assert(
  serviceQml.includes('FingerprintModel.prepareForSleepSignal(line)'),
  'monitor lines go through the same parser the unit test covers'
)

const monitorExit = sliceBetween('id: fingerprintSleepMonitor', 'id: fingerprintSleepMonitorRestart')
assert(monitorExit.includes('fingerprintSleepMonitorRestart.restart()'), 'a dead sleep monitor is restarted')
assert(
  !monitorExit.includes('prepareFingerprintForSleep(false)'),
  'a monitor exiting during the suspend window does not start a new claim'
)
JS
