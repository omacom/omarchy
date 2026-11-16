#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Screensaver mode keeps the displays on behind the session lock. The session
# lock and PAM only run under a compositor, so this runs the mode's own
# functions from Service.qml against a stand-in for the rest of the service.
run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

// The text between the braces that open at `from`.
function block(from) {
  const brace = source.indexOf('{', from)
  let depth = 1, end = brace + 1
  while (depth && end < source.length) {
    if (source[end] === '{') depth++
    if (source[end] === '}') depth--
    end++
  }
  return source.slice(brace + 1, end - 1)
}

function compile(name, ctx) {
  const match = new RegExp('function ' + name + '\\(([^)]*)\\)').exec(source)
  if (!match) throw Error('Missing ' + name)
  return vm.runInContext('(function (' + match[1].replace(/:\s*\w+/g, '') + ') {' + block(match.index) + '})', ctx)
}

function session() {
  const state = {
    lockRequested: false, sessionLocked: false, screensaverMode: false,
    showingScreensaver: false, enteredPassword: '', failureMessage: '',
    authenticatingPassword: false, passwordPamConfigured: true, fingerprintStarts: 0,
    idleBlankTimer: {
      running: false, idleMs: 5000, resumeMs: 15000, interval: 5000, armedAt: 0,
      stop() { this.running = false }, restart() { this.running = true },
    },
    noteSleepRequested() {},
    logEvent() {},
  }
  // The service calls these bare, so they name the state rather than `this`.
  state.currentlyLocked = () => state.lockRequested || state.sessionLocked
  state.beginLock = () => {
    state.screensaverMode = false
    state.showingScreensaver = false
    state.lockRequested = true
    return true
  }
  state.startFingerprint = () => { state.fingerprintStarts++ }
  const ctx = vm.createContext(state)
  state.root = state
  for (const name of ['requestScreensaver', 'revealPassword', 'leaveScreensaver', 'screensaverFailed', 'armBlankTimer']) {
    state[name] = compile(name, ctx)
  }
  state.runWake = () => { if (state.lockRequested) state.armBlankTimer() }
  state.lockIpc = compile('lock', ctx)
  return state
}

// Runs the blank timer's onTriggered handler as written.
const timerStart = source.indexOf('id: idleBlankTimer')
const timeoutBody = block(source.indexOf('onTriggered: {', timerStart))
function timeout(state, elapsed = 5000) {
  let blanked = false
  state.runBlank = () => { blanked = true }
  const armedAt = Date.now() - elapsed
  vm.runInNewContext('(function () {' + timeoutBody + '})()', {
    root: state, Date, armedAt, interval: 5000, resumeMs: 15000,
  })
  return blanked
}

let s = session()
assertEqual(s.requestScreensaver(), 'ok', 'the screensaver takes the session lock')
assert(s.lockRequested && s.showingScreensaver, 'the artwork shows with the session locked')
assert(!s.idleBlankTimer.running, 'the artwork does not arm display blanking')
assertEqual(s.fingerprintStarts, 0, 'screensaver mode leaves the fingerprint reader alone')

s.revealPassword()
assert(s.lockRequested && !s.showingScreensaver, 'dismissing the artwork keeps the session locked')
assert(s.idleBlankTimer.running, 'the password prompt has an inactivity deadline')

s.enteredPassword = 'partial'
assert(!timeout(s) && s.showingScreensaver && s.lockRequested, 'an idle prompt returns to the artwork without blanking')
assertEqual(s.enteredPassword, '', 'returning to the artwork clears unfinished password input')

s.revealPassword()
s.authenticatingPassword = true
s.armBlankTimer()
assert(!s.idleBlankTimer.running, 'a password check holds the prompt open')

s = session()
s.requestScreensaver()
assertEqual(s.lockIpc(), 'ok', 'a normal lock request succeeds during the screensaver')
assert(s.lockRequested && !s.screensaverMode && !s.showingScreensaver, 'a normal lock request switches to the normal lock')
assert(s.idleBlankTimer.running && timeout(s), 'the normal lock then blanks the displays')
assertEqual(s.fingerprintStarts, 1, 'the normal lock starts the fingerprint reader')

s = session()
s.requestScreensaver()
s.screensaverFailed()
assert(s.lockRequested && !s.screensaverMode && s.idleBlankTimer.running, 'artwork that fails to load falls back to the normal lock')

s = session()
s.sessionLocked = true
assertEqual(s.requestScreensaver(), 'already-locked', 'a screensaver request leaves a normal lock as it is')
assert(!s.showingScreensaver, 'a normal lock never shows the artwork')

s = session()
s.beginLock = () => false
assertEqual(s.requestScreensaver(), 'failed', 'a lock that cannot start reports failure')
assert(!s.showingScreensaver, 'the artwork never shows without the session lock')

s = session()
s.lockRequested = true
assert(timeout(s), 'the normal lock still blanks after its deadline')
s.authenticatingPassword = true
assert(!timeout(s), 'a password check in flight still holds the displays on')
JS
