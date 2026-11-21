#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Exercise the real service handlers without PAM or a compositor. In particular,
# the wake must not depend on a LockView key or pointer handler being invoked.
run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const qml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')
function bodyAfter(source, marker) {
  const start = source.indexOf(marker)
  if (start < 0) throw new Error('Missing ' + marker)
  const open = source.indexOf('{', start)
  let depth = 1, end = open + 1
  for (; depth && end < source.length; end++) {
    if (source[end] === '{') depth++
    if (source[end] === '}') depth--
  }
  return source.slice(open + 1, end - 1)
}
function timer() {
  return { running: false, interval: 0, restarts: 0,
    restart() { this.running = true; this.restarts++ },
    stop() { this.running = false } }
}
const monitor = bodyAfter(qml, 'IdleMonitor {')
const activity = bodyAfter(monitor, 'onIsIdleChanged:')
const blank = bodyAfter(qml.slice(qml.indexOf('id: idleBlankTimer')), 'onTriggered:')
const state = {
  Date, Math, FingerprintModel: requireFromRoot('shell/plugins/lock/FingerprintModel.js'),
  lockRequested: true, fingerprintConfigured: true, fingerprintAuthenticating: false,
  fingerprintPaused: false, fingerprintSleptWhilePaused: false,
  fingerprintRetryDueMs: Date.now() - 1000, fingerprintRetryBackoffMs: 250,
  fingerprintLastNudgeMs: 0, fingerprintLastSettleMs: 0,
  fingerprintRetryTimer: timer(), idleBlankTimer: timer(), wakeProcess: { running: false },
  blankProcess: { running: false }, fingerprintPam: { active: false }, isIdle: true
}
state.root = state
state.lockActivity = {
  get enabled() { return vm.runInContext(monitor.match(/enabled: ([^\n]+)/)[1], context) },
  get isIdle() { return state.isIdle }
}
const context = vm.createContext(state)
for (const name of ['armBlankTimer', 'armFingerprintRetry', 'pauseFingerprint', 'resumeFingerprint', 'nudgeFingerprint', 'runWake', 'runBlank']) {
  const marker = 'function ' + name + '('
  const start = qml.indexOf(marker)
  const signature = qml.slice(start, qml.indexOf('{', start))
  vm.runInContext(signature + '{' + bodyAfter(qml, marker) + '}', context)
}
state.idleBlankTimer.idleMs = 5000
state.idleBlankTimer.resumeMs = 15000
state.resumeMs = state.idleBlankTimer.resumeMs
state.armBlankTimer()
state.armedAt = state.idleBlankTimer.armedAt
state.interval = state.idleBlankTimer.interval
vm.runInContext('(function() {' + blank + '})()', context)
assert(state.fingerprintPaused && !state.fingerprintRetryTimer.running, 'blanking pauses retries with no input')
vm.runInContext(activity, context)
assert(state.fingerprintPaused && !state.wakeProcess.running, 'becoming idle cannot wake the reader')
state.isIdle = false
vm.runInContext(activity, context)
assert(!state.fingerprintPaused && state.wakeProcess.running, 'compositor-only input wakes the paused reader')
assert(state.fingerprintRetryTimer.running && state.fingerprintRetryTimer.interval === 250, 'compositor-only wake schedules the existing 250 ms retry')
assert(state.idleBlankTimer.running, 'compositor-only wake rearms blanking')
const retries = state.fingerprintRetryTimer.restarts
state.wakeProcess.running = false
vm.runInContext(activity, context)
assertEqual(state.fingerprintRetryTimer.restarts, retries, 'activity while unblanked adds no fingerprint attempts')
assert(!state.wakeProcess.running, 'activity while unblanked issues no redundant wake command')
state.armBlankTimer(state.resumeMs)
vm.runInContext(activity, context)
assertEqual(state.idleBlankTimer.interval, state.resumeMs, 'compositor-only activity preserves the post-suspend blank delay')
state.blankProcess.running = false
state.armedAt = state.idleBlankTimer.armedAt
state.interval = state.idleBlankTimer.interval
vm.runInContext('(function() {' + blank + '})()', context)
assert(!state.fingerprintPaused && !state.blankProcess.running, 'recent compositor input defers blanking until the monitor can detect the next wake')
assertEqual(state.idleBlankTimer.interval, state.resumeMs, 'deferring blanking preserves the post-suspend delay')
state.lockRequested = false
state.pauseFingerprint()
vm.runInContext(activity, context)
assert(state.fingerprintPaused && !state.wakeProcess.running, 'activity after unlocking cannot resume fingerprint')
assert(!state.lockActivity.enabled, 'the input monitor is disabled outside the lock')
JS

require_quickshell "lock fingerprint service test"

# The fixture exercises runWake; keep its display command inside the scratch HOME.
qml_fixture_scratch
printf '#!/bin/bash\nexit 0\n' >"$QML_FIXTURE_TMP/bin/omarchy-system-wake"
chmod +x "$QML_FIXTURE_TMP/bin/omarchy-system-wake"

run_qml_fixture lock-fingerprint-service "fingerprint service handles enrollment, failures and recovery" Ui Commons
