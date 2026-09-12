#!/bin/bash

source "$(dirname "$0")/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')

const lockView = fs.readFileSync(path.join(root, 'shell/plugins/lock/LockView.qml'), 'utf8')

assert(
  /function\s+passwordFocusAllowed\(\)\s*{[\s\S]*?return\s+inputEnabled\s+&&\s+!authenticatingPassword[\s\S]*?}/.test(lockView),
  'lock password focus is allowed only while the field can accept input'
)

assert(
  /onInputEnabledChanged:\s*schedulePasswordFocus\(\)/.test(lockView) &&
    /onAuthenticatingPasswordChanged:\s*schedulePasswordFocus\(\)/.test(lockView),
  'lock password focus is rescheduled when input becomes available'
)

assert(
  /focus:\s*root\.passwordFocusAllowed\(\)/.test(lockView) &&
    /onActiveFocusChanged:\s*{[\s\S]*?if\s*\(!activeFocus\)\s*root\.schedulePasswordFocus\(\)[\s\S]*?}/.test(lockView),
  'lock password input reclaims focus if it is lost while locked'
)
JS
