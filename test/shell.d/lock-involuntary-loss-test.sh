#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

// Authenticated unlock must clear lockRequested before sessionLock.locked =
// false, or onLockStateChanged would treat the drop as involuntary.
assert(
  /function finishUnlock\(\) \{[\s\S]*lockRequested = false[\s\S]*sessionLock\.locked = false/.test(serviceQml),
  'finishUnlock clears lockRequested before dropping the compositor lock'
)

assert(
  /function handleInvoluntaryLockLoss\(\)/.test(serviceQml),
  'involuntary lock loss has a dedicated handler'
)

// The fail-open path that woke the desktop on any locked→false is gone.
assert(
  !/if \(!locked && root\.lockRequested\) \{[\s\S]*root\.lockRequested = false[\s\S]*root\.runWake\(\)/.test(serviceQml),
  'onLockStateChanged must not clear lockRequested and wake on unauthenticated loss'
)

assert(
  /if \(!locked && root\.lockRequested\) \{[\s\S]*root\.handleInvoluntaryLockLoss\(\)/.test(serviceQml),
  'onLockStateChanged routes unauthenticated loss to the fail-closed handler'
)

assert(
  /id: lockLossProbeProc[\s\S]*omarchy-hyprland-session-locked/.test(serviceQml),
  'lock-loss recovery probes the compositor through the shared helper'
)

assert(
  /if \(exitCode === 0\) \{[\s\S]*lock-lost: compositor still locked/.test(serviceQml),
  'when the compositor still holds the lock, the shell does not re-request in-process'
)

assert(
  /lock-lost: session is open, relocking[\s\S]*queueSessionLock\(\)/.test(serviceQml),
  'when the session is open after lock loss, the shell queues a new session lock'
)

assert(
  /lockLossRelocks <= 3/.test(serviceQml),
  'relock attempts are rate-limited'
)
JS
