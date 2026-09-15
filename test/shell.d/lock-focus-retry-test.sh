#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const lockView = fs.readFileSync(path.join(root, 'shell/plugins/lock/LockView.qml'), 'utf8')

// A single forceActiveFocus() at Component.onCompleted races the compositor
// handing the lock surface keyboard focus, and nothing re-applies it when the
// surface loses focus later (suspend/resume, the idle screensaver dying, a
// failed password re-enabling the field). The field must retry until it holds
// focus, re-armed by the running binding on every focus loss, and idled while
// the display is blanked so a surface that can never take focus (a monitor
// hotplugged mid-lock) does not spin all night.
assert(
  /running:\s*root\.inputEnabled\s*&&\s*!root\.authenticatingPassword\s*&&\s*!root\.displaysBlank\s*&&\s*!passwordInput\.activeFocus/.test(lockView),
  'the password field retries focus until it holds it, and idles while blanked'
)

assert(
  /onTriggered:\s*root\.forcePasswordFocus\(\)/.test(lockView),
  'the focus retry re-asserts focus on the password field'
)

// The single-shot grab cannot cover focus lost after completion; the retry
// timer must replace it rather than sit beside it.
assert(
  !/if\s*\(inputEnabled\)\s*Qt\.callLater\(forcePasswordFocus\)/.test(lockView),
  'the one-shot focus grab no longer replaces the retry timer'
)
JS
