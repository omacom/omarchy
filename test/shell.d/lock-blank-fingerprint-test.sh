#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

// Exercise the QML conversion itself: malformed settings must not produce an
// immediate blank or overflow Timer's signed 32-bit interval.
const blankTimeoutBody = serviceQml.match(/function blankTimeoutMs\(value\) \{([\s\S]*?)\n  \}/)
assert(blankTimeoutBody, 'lock exposes its blank timeout conversion')
const blankTimeoutMs = new Function('value', blankTimeoutBody[1])
assertEqual(blankTimeoutMs(15), 15000, 'lock converts configured seconds to milliseconds')
assertEqual(blankTimeoutMs(1.5), 1500, 'lock accepts fractional seconds')
assertEqual(blankTimeoutMs('15'), 15000, 'lock accepts numeric strings')
for (const value of [undefined, null, '', 'invalid', 0, -1, Infinity, true, false, [], [2], ['2'], {}]) {
  assertEqual(blankTimeoutMs(value), 5000, 'lock falls back for invalid timeout ' + String(value))
}
assertEqual(blankTimeoutMs(1e10), 2147483647, 'lock caps the interval before integer overflow')
assertEqual(blankTimeoutMs(0.0001), 1, 'lock keeps a positive sub-millisecond timeout positive')

// The fingerprint PAM stays armed while the lock is lit, waiting for a finger,
// so gating the blank on `authenticating` would leave the panel lit all night.
assert(
  /if \(root\.lockRequested && !root\.authenticatingPassword\) root\.runBlank\(\)/.test(serviceQml),
  'only a password check in flight stops the blank timer from blanking'
)

assert(
  !/idleBlankTimer[\s\S]*?!root\.authenticating\)/.test(serviceQml),
  'the blank timer never gates on the combined authenticating state'
)

assert(
  /onAuthenticatingPasswordChanged: \{\s*if \(!lockRequested\) return\s*if \(authenticatingPassword\) idleBlankTimer\.stop\(\)\s*else armBlankTimer\(\)/.test(serviceQml),
  'the blank timer is held off by password entry and re-armed when it finishes'
)

assert(
  !/onAuthenticatingChanged:/.test(serviceQml),
  'the combined authenticating state no longer drives the blank timer'
)

assert(
  /function runBlank\(\) \{[^}]*pauseFingerprint\(\)/.test(serviceQml) &&
    /function runWake\(\) \{[^}]*resumeFingerprint\(\)/.test(serviceQml),
  'blanking the displays leaves the reader alone and waking them arms it again'
)

assert(
  /function lock\(\): string \{[^}]*if \(root\.currentlyLocked\(\)\) root\.noteSleepRequested\(\)/.test(serviceQml),
  'the lock request made before every suspend marks a sleep while the reader is paused'
)

assert(
  /function onScreensChanged\(\) \{[\s\S]*?if \(screens > root\.knownScreenCount\) \{\s*root\.resumeFingerprint\(\)\s*if \(root\.lockRequested\) root\.armBlankTimer\(\)/.test(serviceQml),
  'only a display arriving wakes the reader, and the blank countdown starts over'
)
JS
