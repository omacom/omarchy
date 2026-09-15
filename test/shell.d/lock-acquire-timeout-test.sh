#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

assert(
  /function clearStalledLockRequest\(reason\)/.test(serviceQml),
  'stalled lock requests can be cleared without reporting a successful lock'
)

assert(
  /id: lockAcquireTimeoutTimer[\s\S]*lock-failed: acquire-timeout/.test(serviceQml),
  'a pending lock that never reaches the compositor times out'
)

assert(
  /function lock\(\): string \{[\s\S]*if \(sessionLock\.locked \|\| sessionLock\.secure\) return "ok"/.test(serviceQml),
  'lock IPC success requires a real compositor lock, not bare lockRequested'
)

assert(
  /if \(root\.lockRequested\) \{[\s\S]*root\.queueSessionLock\(\)/.test(serviceQml),
  'a stalled lockRequested re-queues session lock acquisition instead of no-op success'
)

assert(
  /function beginLock\(\) \{[\s\S]*lockAcquireTimeoutTimer\.restart\(\)/.test(serviceQml),
  'beginLock arms the acquire timeout'
)

assert(
  /if \(locked\) \{[\s\S]*lockAcquireTimeoutTimer\.stop\(\)/.test(serviceQml) &&
    /if \(secure\) \{[\s\S]*lockAcquireTimeoutTimer\.stop\(\)/.test(serviceQml),
  'a successful compositor lock cancels the acquire timeout'
)
JS
