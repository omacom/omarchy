#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')
const handler = source.match(/id: fingerprintPam\s+onPamMessage: \{([\s\S]*?)\n    \}\n    config:/)
assert(handler, 'fingerprint PAM exposes a message handler')
let wakes = 0
const state = { lockRequested: true, fingerprintWakeUsed: false, fingerprintMessage: '', runWake() { wakes++ } }
function message(text, error = false, response = false) {
  vm.runInNewContext(handler[1], { root: state, message: text, messageIsError: error, responseRequired: response })
}
message('')
message('Reader unavailable', true)
message('Password:', false, true)
assertEqual(wakes, 0, 'empty, error, and response prompts do not wake the screen')
message('Place your finger')
assertEqual(state.fingerprintMessage, 'Place your finger', 'PAM placement message reaches the lock view state')
assertEqual(wakes, 1, 'first informational prompt wakes the screen')
message('Try again', true)
message('Place your finger')
assertEqual(wakes, 1, 'retry prompts do not repeatedly wake an unattended screen')
state.lockRequested = false
state.fingerprintWakeUsed = false
message('Reader ready')
assertEqual(wakes, 1, 'late prompts after unlock do not wake the screen')
const reset = source.match(/function resetAuthenticationState\(\) \{([\s\S]*?)\n  \}/)
const context = { fingerprintMessage: 'Previous attempt', fingerprintRetryTimer: { stop() {} }, passwordPam: { active: false }, fingerprintPam: { active: false } }
vm.runInNewContext(reset[1], context)
assertEqual(context.fingerprintMessage, '', 'authentication reset clears the previous reader message')
JS
