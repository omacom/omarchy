#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const retry = requireFromRoot('shell/plugins/lock/FingerprintRetry.js')
const fs = require('fs')

assertEqual(retry.lidClosedPolicy('skip'), 'skip', 'skip is an explicit lid-closed policy')
assertEqual(retry.lidClosedPolicy(undefined), 'try', 'a missing lid policy keeps current quattro behavior')

const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')
const shellJson = JSON.parse(fs.readFileSync(path.join(root, 'config/omarchy/shell.json'), 'utf8'))

assertEqual(
  shellJson.lock && shellJson.lock.fingerprintLidClosed,
  'skip',
  'packaged shell.json defaults lock fingerprint to skip when the lid is closed'
)

assert(
  /shellConfig\.lock/.test(serviceQml) &&
    /FingerprintRetry\.lidClosedPolicy\(/.test(serviceQml),
  'the lock service reads lock.fingerprintLidClosed from shell.json'
)
assert(
  /omarchy-hw-laptop-closed && echo closed/.test(serviceQml),
  'the lock service refreshes lid state through omarchy-hw-laptop-closed'
)
assert(
  /fingerprintLidClosed === "skip" && laptopClosed/.test(serviceQml),
  'skip mode blocks fingerprint PAM while the lid is closed'
)
assert(
  /function startFingerprint\(\)[\s\S]*fingerprintBlockedByLid\(\)/.test(serviceQml),
  'startFingerprint does not arm PAM when skip mode sees a closed lid'
)
assert(
  /function scheduleFingerprintRetry\([\s\S]*fingerprintBlockedByLid\(\)/.test(serviceQml),
  'lid-closed skip does not consume the fingerprint retry budget'
)
assert(
  /fingerprintPam\.abort\(\)/.test(serviceQml.replace(/function resetAuthenticationState\(\)[\s\S]*?\n  \}/, '')) &&
    /laptopClosed/.test(serviceQml),
  'skip mode aborts an in-flight fingerprint PAM session when the lid shuts'
)
assert(
  /function applyLidClosed[\s\S]*wasClosed && !closed/.test(serviceQml),
  'the lid poll starts fingerprint only on a closed-to-open transition'
)
JS
