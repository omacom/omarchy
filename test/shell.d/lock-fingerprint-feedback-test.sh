#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

// The lock view cannot see a rejected scan on its own: PAM re-arms faster than
// any state transition, so the service has to hand the view a discrete signal.
assert(
  /property int fingerprintFailureNonce: 0/.test(serviceQml),
  'the lock service tracks fingerprint failures'
)

assert(
  /fingerprintAuthenticating: root\.fingerprintAuthenticating/.test(serviceQml),
  'the lock view receives the live fingerprint state'
)

assert(
  /fingerprintFailureNonce: root\.fingerprintFailureNonce/.test(serviceQml),
  'the lock view receives the failure signal'
)

assert(
  /onPamMessage: root\.fingerprintAttemptEngaged = true/.test(serviceQml),
  'the service records whether the reader ever asked for a finger'
)

assert(
  /function scheduleFingerprintRetry\(\)/.test(serviceQml),
  'the lock service centralises the fingerprint retry'
)

assert(
  (serviceQml.match(/scheduleFingerprintRetry\(\)/g) || []).length >= 3,
  'both fingerprint failure paths retry through the shared helper'
)

assert(
  /interval: root\.fingerprintRetryDelay/.test(serviceQml),
  'the retry interval follows the backoff delay'
)

assert(
  /fingerprintRetryDelay = Math\.min\(/.test(serviceQml),
  'a reader that never engaged backs the retry off instead of flashing'
)
JS
