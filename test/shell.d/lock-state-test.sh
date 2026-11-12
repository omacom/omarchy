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
JS

# With Fcitx sharing one state across windows, an active engine followed focus
# onto the lock and showed the password as preedit. Per-window state must be
# left alone, or the app behind the lock comes back in direct input.
run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')
const begin = serviceQml.match(/function beginLock\(\) \{[\s\S]*?\n  \}/)
const unlock = serviceQml.match(/function finishUnlock\(\) \{[\s\S]*?\n  \}/)

assert(begin && /inputMethodOffProcess\.running = true/.test(begin[0]), 'a lock starts in direct input')
assert(
  /grep -qx 'ShareInputState=All'.*&& \[\[ \$\(fcitx5-remote\) == 2 \]\] && fcitx5-remote -c && echo active/.test(serviceQml),
  'only a shared, active engine is switched off'
)
assert(unlock && /if \(restoreInputMethod\) \{[\s\S]*?inputMethodOnProcess\.running = true/.test(unlock[0]), 'unlock hands the engine back')
JS
