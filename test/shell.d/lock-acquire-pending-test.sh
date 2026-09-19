#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

assert(
  /property bool sessionLockAcquirePending: false/.test(serviceQml),
  'session lock acquire carries an in-flight pending flag'
)

assert(
  /function requestSessionLock\(\) \{[\s\S]*if \(sessionLockAcquirePending\) return/.test(serviceQml),
  'requestSessionLock refuses overlapping acquires'
)

assert(
  /sessionLockAcquirePending = true\s*\n\s*sessionLockAcquireWatchdog\.restart\(\)\s*\n\s*sessionLock\.locked = true/.test(serviceQml),
  'requestSessionLock marks acquire pending before writing sessionLock.locked'
)

assert(
  /id: sessionLockAcquireWatchdog[\s\S]*lock-acquire: watchdog-reset/.test(serviceQml),
  'a stalled acquire clears the pending flag so a later lock can retry'
)

assert(
  /if \(locked\) \{[\s\S]*sessionLockAcquirePending = false[\s\S]*sessionLockAcquireWatchdog\.stop\(\)/.test(serviceQml),
  'a successful lock clears the acquire pending flag'
)
JS
