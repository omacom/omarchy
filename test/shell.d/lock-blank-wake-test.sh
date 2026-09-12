#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')
const lockViewQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/LockView.qml'), 'utf8')

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

const wake = bodyOf(serviceQml, 'runWake', 'display wake')
assert(wake.includes('displayBlanked = false'), 'a wake clears the blanked state')
assert(wake.includes('focusRequestVersion += 1'), 'a wake re-arms password focus')
assert(
  wake.includes('wakePending = true') && wake.includes('drainDisplayRequest()'),
  'a wake is latched behind any in-flight display operation'
)

const blank = bodyOf(serviceQml, 'runBlank', 'display blank')
assert(blank.includes('displayBlanked = true') && blank.includes('blankPending = true'), 'blanked state and its pending operation are published together')
const drain = bodyOf(serviceQml, 'drainDisplayRequest', 'display request drain')
assert(
  drain.includes('if (blankProcess.running || wakeProcess.running) return') &&
    drain.includes('if (wakePending)') && drain.includes('else if (blankPending)'),
  'blank and wake are serialized with the latest wake taking priority'
)
assert(
  /id: wakeProcess[\s\S]*command: \["timeout", "--kill-after=0\.2s", "2s"[\s\S]*onExited: function\(exitCode\) \{ root\.handleWakeExit\(exitCode\) \}/.test(serviceQml) &&
    /id: blankProcess[\s\S]*command: \["timeout", "--kill-after=0\.2s", "2s"[\s\S]*onExited: function\(exitCode\) \{ root\.handleBlankExit\(exitCode\) \}/.test(serviceQml),
  'both bounded child exits drain a request that arrived during a wedge'
)

const wakeExit = bodyOf(serviceQml, 'handleWakeExit', 'failed wake recovery')
assert(
  wakeExit.includes('!displayBlanked && wakeRetryAttempt < wakeRetryBudget') &&
    wakeExit.includes('wakePending = true') &&
    wakeExit.includes('wakeRetryTimer.restart()'),
  'a failed latest wake is retained and retried after unlock'
)
assert(
  /readonly property int wakeRetryBudget: 3/.test(serviceQml) &&
    /wakeRetryTimer\.interval = 250 \* Math\.pow\(2, wakeRetryAttempt - 1\)/.test(serviceQml),
  'wake recovery has a finite exponential-backoff budget'
)
assert(
  /id: wakeRetryTimer[\s\S]*if \(!root\.displayBlanked && root\.wakePending\) root\.drainDisplayRequest\(\)/.test(serviceQml),
  'wake retry remains active independently of the destroyed lock surface'
)

// A timed-out wake after finishUnlock has no lock surface or IdleMonitor to
// generate another request. Model the exit/retry budget directly.
let displayBlanked = false
let wakePending = false
let wakeAttempts = 0
const wakeBudget = 3
function failedWake() {
  if (!displayBlanked && wakeAttempts < wakeBudget) {
    wakeAttempts += 1
    wakePending = true
  }
}
failedWake()
assert(wakePending && wakeAttempts === 1, 'the first timed-out unlock wake is retried')
while (wakeAttempts < wakeBudget) {
  wakePending = false
  failedWake()
}
assertEqual(wakeAttempts, wakeBudget, 'wake retries stop at their fixed budget')

const blankExit = bodyOf(serviceQml, 'handleBlankExit', 'failed blank recovery')
assert(
  blankExit.includes('lockRequested && displayBlanked && blankRetryAttempt < blankRetryBudget') &&
    blankExit.includes('blankPending = true') &&
    blankExit.includes('blankRetryTimer.restart()'),
  'a failed blank is retained and retried without later input'
)
assert(
  /readonly property int blankRetryBudget: 3/.test(serviceQml) &&
    /blankRetryTimer\.interval = 250 \* Math\.pow\(2, blankRetryAttempt - 1\)/.test(serviceQml),
  'blank recovery has a finite exponential-backoff budget'
)
assert(
  /function runWake\(\)[\s\S]*blankRetryTimer\.stop\(\)[\s\S]*blankRetryAttempt = 0/.test(serviceQml),
  'a later wake cancels pending blank retries'
)

let lockRequested = true
displayBlanked = true
let blankPending = false
let blankAttempts = 0
const blankBudget = 3
function failedBlank() {
  if (lockRequested && displayBlanked && blankAttempts < blankBudget) {
    blankAttempts += 1
    blankPending = true
  }
}
failedBlank()
assert(blankPending && blankAttempts === 1, 'the first timed-out blank retries without input')
while (blankAttempts < blankBudget) {
  blankPending = false
  failedBlank()
}
assertEqual(blankAttempts, blankBudget, 'blank retries stop at their fixed budget')
displayBlanked = false
blankPending = false
failedBlank()
assert(!blankPending, 'a later wake supersedes failed blank recovery')

assert(
  /IdleMonitor \{[\s\S]*enabled: root\.lockRequested[\s\S]*respectInhibitors: false/.test(serviceQml),
  'compositor input monitoring is armed for the whole lock'
)
assert(
  /onIsIdleChanged: \{[\s\S]*root\.focusRequestVersion \+= 1[\s\S]*if \(root\.displayBlanked\) root\.runWake\(\)/.test(serviceQml),
  'keyboard activity wakes a blank display without depending on field focus'
)

assert(
  /displayBlanked: root\.displayBlanked[\s\S]*focusRequestVersion: root\.focusRequestVersion/.test(serviceQml),
  'each lock view receives display and compositor-focus state'
)

const armFocus = bodyOf(lockViewQml, 'armPasswordFocusRetry', 'password focus retry')
assert(
  armFocus.includes('!inputEnabled || authenticatingPassword || displayBlanked'),
  'focus retry idles when input cannot be accepted'
)
assert(
  armFocus.includes('focusRetry.remaining = focusRetry.budget') && armFocus.includes('focusRetry.restart()'),
  'every focus-loss event receives a fresh bounded retry budget'
)

for (const handler of [
  'onInputEnabledChanged: armPasswordFocusRetry()',
  'onAuthenticatingPasswordChanged: armPasswordFocusRetry()',
  'onDisplayBlankedChanged: armPasswordFocusRetry()',
  'onFocusRequestVersionChanged: armPasswordFocusRetry()',
]) {
  assert(lockViewQml.includes(handler), `${handler.split(':')[0]} re-arms password focus`)
}

const timer = lockViewQml.match(/id: focusRetry[\s\S]*?readonly property int budget: (\d+)[\s\S]*?property int remaining: 0[\s\S]*?onTriggered: \{([\s\S]*?)\n    \}/)
assert(timer, 'the password focus retry has a fixed budget and trigger')
assert(Number(timer[1]) > 0 && Number(timer[1]) <= 100, 'the retry budget is finite and practical')
assert(timer[2].includes('passwordInput.activeFocus'), 'the retry stops as soon as focus is acquired')
assert(timer[2].includes('if (remaining <= 0) stop()'), 'an unfocusable hotplugged surface cannot retry forever')

assert(
  /onActiveFocusChanged: \{[\s\S]*if \(activeFocus\) focusRetry\.stop\(\)[\s\S]*else root\.armPasswordFocusRetry\(\)/.test(lockViewQml),
  'later focus loss re-arms the bounded retry'
)
JS
