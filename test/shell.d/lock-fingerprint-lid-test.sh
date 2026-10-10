#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')

const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')
const shellJson = JSON.parse(fs.readFileSync(path.join(root, 'config/omarchy/shell.json'), 'utf8'))

function body(name) {
  const marker = 'function ' + name + '('
  const start = serviceQml.indexOf(marker)
  assert(start !== -1, name + ' is defined')
  const open = serviceQml.indexOf('{', start)
  let depth = 0
  for (let i = open; i < serviceQml.length; i++) {
    const ch = serviceQml[i]
    if (ch === '{') depth += 1
    else if (ch === '}') {
      depth -= 1
      if (depth === 0) return serviceQml.slice(start, i + 1)
    }
  }
  assert(false, name + ' has a closing brace')
}

assertEqual(
  shellJson.lock && shellJson.lock.fingerprintLidClosed,
  'skip',
  'packaged shell.json defaults lock fingerprint to skip when the lid is closed'
)

assert(
  /shellConfig\.lock/.test(serviceQml) &&
    /fingerprintLidClosed === "skip" \? "skip" : "try"/.test(serviceQml),
  'a missing lock.fingerprintLidClosed stays try, and skip is the only skip value'
)
assert(
  /omarchy-hw-laptop-closed && echo closed/.test(serviceQml),
  'the lock service refreshes lid state through omarchy-hw-laptop-closed'
)
assert(
  /fingerprintLidClosed === "skip" && laptopClosed/.test(serviceQml),
  'skip mode blocks fingerprint PAM while the lid is closed'
)

const start = body('startFingerprint')
assert(
  /fingerprintBlockedByLid\(\)/.test(start),
  'startFingerprint does not arm PAM when skip mode sees a closed lid'
)
assert(
  /fingerprintLidClosed === "skip" && !laptopClosedKnown[\s\S]*refreshLidState\(\)/.test(start),
  'skip mode waits for the first lid reading before starting fingerprint PAM'
)

const apply = body('applyLidClosed')
const applyBlocked = apply.slice(apply.indexOf('if (fingerprintBlockedByLid())'), apply.indexOf('The first reading'))
assert(
  /stopFingerprintForLid\(\)/.test(applyBlocked) &&
    !/settleFingerprintAttempt\(/.test(applyBlocked),
  'a lid that shuts aborts fingerprint PAM without counting a failed attempt'
)
assert(
  /function stopFingerprintForLid\(\) \{[\s\S]*fingerprintPam\.abort\(\)/.test(serviceQml),
  'stopping for a closed lid aborts the fingerprint PAM session'
)
assert(
  /wasClosed && !closed/.test(apply),
  'the lid poll starts fingerprint on a closed-to-open transition'
)
assert(
  /!lidWasKnown[\s\S]*startFingerprint\(\)/.test(apply),
  'the first open-lid reading starts fingerprint after the check returns'
)

const restart = body('restartFingerprintAfterSleep')
const restartBlocked = restart.slice(restart.indexOf('fingerprintBlockedByLid'), restart.indexOf('noteFingerprintResumed'))
assert(
  /stopFingerprintForLid\(\)/.test(restartBlocked) &&
    !/settleFingerprintAttempt\(/.test(restartBlocked),
  'resume recovery does not settle a fingerprint attempt while the lid is closed'
)
assert(
  /id: fingerprintRetryTimer[\s\S]*onTriggered: root\.startFingerprint\(\)/.test(serviceQml),
  'the landed retry timer starts fingerprint through the lid guard'
)
assert(
  /id: lidRefreshTimer[\s\S]*root\.lockRequested && root\.fingerprintLidClosed === "skip"/.test(serviceQml),
  'the lid poll runs only while the screen is locked and the policy is skip'
)
JS
