#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command dbus-run-session

dbus-run-session -- python3 "$ROOT/test/shell.d/fixtures/session-lock-bridge.py"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const qml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')
const publishFunction = qml.match(/function publishLockState\(\) \{([\s\S]*?)\n  \}/)
assert(publishFunction, 'lock service exposes its state publication function')
const writes = []
const service = {
  sessionLockBridgeReady: false,
  sessionLockBridgeProcess: { running: true, write: text => writes.push(text) },
  sessionLock: { secure: true }
}
vm.runInNewContext('function publishLockState() {' + publishFunction[1] + '\n}', service)
service.publishLockState()
assertDeepEqual(writes, [], 'lock state waits for the bridge readiness handshake')
service.sessionLockBridgeReady = true
service.publishLockState()
service.sessionLock.secure = false
service.publishLockState()
assertDeepEqual(writes, ['true\n', 'false\n'], 'ready bridge receives current secure state and unlock transitions')
service.sessionLockBridgeProcess.running = false
service.publishLockState()
assertEqual(writes.length, 2, 'lock state is not written to an exited bridge')
assert(
  /onSecureStateChanged:\s*\{[^}]*root\.publishLockState\(\)/.test(qml)
    && /function publishLockState\(\)[\s\S]*?sessionLock\.secure/.test(qml),
  'screensaver notifications follow compositor security, not a lock request or preview'
)
assert(
  /line === "ready"\)\s*\{\s*root\.sessionLockBridgeReady = true\s*root\.publishLockState\(\)/.test(qml)
    && /onExited: function\(exitCode\)\s*\{\s*root\.sessionLockBridgeReady = false\s*if \(exitCode !== 0\) sessionLockBridgeRetryTimer\.restart\(\)/.test(qml),
  'bridge restart republishes current security state without fighting another bus owner'
)
JS
