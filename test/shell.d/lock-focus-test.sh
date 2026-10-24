#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

const secureHandlerStart = serviceQml.indexOf('onSecureStateChanged:')
const lockHandlerStart = serviceQml.indexOf('onLockStateChanged:', secureHandlerStart)
const secureHandler = serviceQml.slice(secureHandlerStart, lockHandlerStart)

// lockView is declared inside the per-screen WlSessionLockSurface delegate, so
// naming it here is a ReferenceError that also skips startFingerprint().
assert(
  !secureHandler.includes('lockView'),
  'the session lock handler does not reach into the per-screen lock view'
)

const surfaceStart = serviceQml.indexOf('WlSessionLockSurface {')
let surfaceEnd = serviceQml.indexOf('{', surfaceStart)
for (let depth = 0; surfaceEnd < serviceQml.length; surfaceEnd++) {
  if (serviceQml[surfaceEnd] === '{') depth++
  if (serviceQml[surfaceEnd] === '}' && --depth === 0) break
}
const surface = serviceQml.slice(surfaceStart, surfaceEnd + 1)

assert(
  /Connections \{\s*target: sessionLock\s*function onSecureStateChanged\(\) \{\s*if \(sessionLock\.secure\) lockView\.forcePasswordFocus\(\)/.test(surface),
  'each lock surface refocuses its password field when the compositor secures the lock'
)
JS
