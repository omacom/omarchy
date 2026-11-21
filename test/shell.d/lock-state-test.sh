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

// Screensaver mode: run its functions and the blank timer's handler from the
// source against a stand-in for the rest of the service.
const vm = require('vm')

function block(from) {
  const brace = serviceQml.indexOf('{', from)
  let depth = 1, end = brace + 1
  while (depth) {
    if (serviceQml[end] === '{') depth++
    if (serviceQml[end] === '}') depth--
    end++
  }
  return serviceQml.slice(brace + 1, end - 1)
}

function session() {
  const state = {
    lockRequested: false, screensaverMode: false, showingScreensaver: false,
    enteredPassword: '', failureMessage: '', authenticatingPassword: false,
    passwordPamConfigured: true, blanked: false,
    idleBlankTimer: { running: false, idleMs: 5000, stop() { this.running = false }, restart() { this.running = true } },
    logEvent() {}, startFingerprint() {}, noteSleepRequested() {},
  }
  // The service calls these bare, so they name the state rather than `this`.
  state.root = state
  state.currentlyLocked = () => state.lockRequested
  state.beginLock = () => { state.screensaverMode = false; state.showingScreensaver = false; state.lockRequested = true; return true }
  state.runWake = () => { if (state.lockRequested) state.armBlankTimer() }
  state.runBlank = () => { state.blanked = true }
  const ctx = vm.createContext(state)
  for (const [name, args] of [['requestScreensaver', ''], ['revealPassword', ''], ['leaveScreensaver', ''], ['armBlankTimer', 'delayMs'], ['lock', '']]) {
    const at = serviceQml.search(new RegExp('function ' + name + '\\('))
    state[name] = vm.runInContext('(function (' + args + ') {' + block(at) + '})', ctx)
  }
  const timeout = block(serviceQml.indexOf('onTriggered: {', serviceQml.indexOf('id: idleBlankTimer')))
  state.blankTimeout = () => vm.runInContext('(function (armedAt, interval, resumeMs) {' + timeout + '})', ctx)(Date.now() - 5000, 5000, 15000)
  return state
}

let s = session()
assertEqual(s.requestScreensaver(), 'ok', 'the screensaver takes the session lock')
assert(s.showingScreensaver && !s.idleBlankTimer.running, 'the screensaver shows behind the lock and never arms blanking')
s.revealPassword()
assert(s.lockRequested && s.idleBlankTimer.running, 'dismissing the screensaver keeps the lock and gives the prompt a deadline')
s.enteredPassword = 'partial'
s.blankTimeout()
assert(!s.blanked && s.showingScreensaver && s.enteredPassword === '', 'an idle prompt returns to the screensaver, clearing the field, without blanking')
assertEqual(s.lock(), 'ok', 'a lock request succeeds during the screensaver')
assert(!s.screensaverMode && s.idleBlankTimer.running, 'a lock request switches to the normal lock')
s.blankTimeout()
assert(s.blanked, 'the normal lock then blanks the displays')

s = session()
s.lockRequested = true
assertEqual(s.requestScreensaver(), 'already-locked', 'a screensaver request leaves an existing normal lock alone')
s = session()
s.beginLock = () => false
assert(s.requestScreensaver() === 'failed' && !s.showingScreensaver, 'the screensaver never shows without the session lock')
JS
