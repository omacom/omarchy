#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

const finishUnlock = serviceQml.match(/function finishUnlock\(\) \{[\s\S]*?\n  \}/)
assert(finishUnlock, 'finishUnlock is defined')

// WlSessionLock does not always notify when it releases. Clearing
// lockRequested first re-evaluated `locked` while the session lock still read
// as held, and nothing re-evaluated it afterwards: `locked` stayed true and
// every later lock request was ignored until the shell restarted.
const release = finishUnlock[0].indexOf('sessionLock.locked = false')
const clear = finishUnlock[0].indexOf('lockRequested = false')
assert(release >= 0 && clear >= 0, 'finishUnlock releases the session lock and clears the request')
assert(release < clear, 'finishUnlock releases the session lock before clearing lockRequested')

const ipcLock = serviceQml.match(/function lock\(\): string \{[\s\S]*?\n    \}/)
assert(ipcLock, 'the lock IPC method is defined')
assert(
  !/!root\.locked\b/.test(ipcLock[0]),
  'the lock IPC method does not trust the derived locked binding'
)
assert(
  /root\.lockRequested \|\| sessionLock\.locked \|\| sessionLock\.secure/.test(ipcLock[0]),
  'the lock IPC method checks the live lock state'
)
JS
