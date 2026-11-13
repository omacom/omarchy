#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const service = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

function bodyOf(name) {
  const start = service.indexOf(`function ${name}(`)
  if (start < 0) fail(`lock service defines ${name}`)
  const next = service.indexOf('\n  function ', start + 1)
  return service.slice(start, next < 0 ? service.length : next)
}

const start = bodyOf('startFingerprint')
assert(
  start.includes('if (!laptopClosedKnown)') && start.includes('if (laptopClosed) return'),
  'fingerprint does not start until the lid probe says the reader is reachable'
)

assert(
  /onSecureStateChanged:[\s\S]*if \(secure\)[\s\S]*laptopClosedKnown = false[\s\S]*refreshLaptopClosed\(\)[\s\S]*startFingerprint\(\)/.test(service),
  'a later lock drops the previous lid result before starting fingerprint'
)

const apply = bodyOf('applyLaptopClosed')
assert(
  apply.includes('fingerprintRetryTimer.stop()') &&
    apply.includes('fingerprintPam.abort()') &&
    apply.includes('settleFingerprintAttempt()'),
  'a closed lid aborts an in-flight verify and does not leave a retry armed'
)

const settle = bodyOf('settleFingerprintAttempt')
assert(
  settle.includes('laptopClosed') && settle.includes('fingerprintRetryTimer.stop()'),
  'settling a clamshell attempt does not re-arm pam_fprintd'
)

assert(
  service.includes('omarchy-hw-laptop-closed && echo closed || echo open') &&
    service.includes('id: laptopClosedTimer') &&
    /id: laptopClosedTimer[\s\S]*running: root\.lockRequested && root\.fingerprintConfigured/.test(service),
  'the lock rechecks the lid while locked, using the same probe as polkit'
)

assert(
  service.includes('running: root.lockRequested && root.fingerprintConfigured && !root.laptopClosed'),
  'the resume watcher does not restart fingerprint while the lid is closed'
)

assert(
  !/auth\s+\[success=1 default=ignore\]\s+pam_exec\.so quiet \/usr\/bin\/omarchy-hw-laptop-closed/.test(
    fs.readFileSync(path.join(root, 'bin/omarchy-apply-lock'), 'utf8')
  ),
  'the lock PAM stack does not reuse the sudo skip gate, which would unlock with no auth'
)
JS
