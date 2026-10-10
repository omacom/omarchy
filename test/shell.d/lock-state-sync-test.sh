#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

// Quickshell can release the session lock without emitting lockStateChanged, so
// a binding over sessionLock.locked stays true and every later lock is refused.
assert(
  !/readonly property bool locked:/.test(serviceQml),
  'locked is not a binding that a missed change signal can leave stale'
)

assert(
  /function syncLocked\(\) \{\s*locked = lockRequested \|\| sessionLock\.locked \|\| sessionLock\.secure\s*\}/.test(serviceQml),
  'locked is recomputed from the live lock state'
)

assert(
  /onLockRequestedChanged: syncLocked\(\)/.test(serviceQml),
  'a lock request or its end updates locked'
)

assert(
  /sessionLock\.locked = true\s*\n\s*syncLocked\(\)/.test(serviceQml) &&
    /sessionLock\.locked = false\s*\n\s*syncLocked\(\)/.test(serviceQml),
  'locked follows the session lock the shell sets, signal or not'
)

assert(
  /onSecureStateChanged: \{\s*root\.syncLocked\(\)/.test(serviceQml) &&
    /onLockStateChanged: \{\s*root\.syncLocked\(\)/.test(serviceQml),
  'locked follows the compositor when it does signal'
)

// The sleep lock asks over IPC; a stale answer there sends suspend out unlocked.
for (const method of ['lock', 'isLocked', 'status']) {
  assert(
    new RegExp(`function ${method}\\(\\): string \\{\\s*root\\.syncLocked\\(\\)`).test(serviceQml),
    `the ${method} IPC call answers from the live lock state`
  )
}
JS
