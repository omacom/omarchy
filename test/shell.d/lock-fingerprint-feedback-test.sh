#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')
const lockViewQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/LockView.qml'), 'utf8')

// pam_fprintd reports a rejected read as a PAM error message while the PAM
// conversation keeps running, so the lock must turn each one into a flash
// instead of leaving the user staring at a static icon.
assert(
  /onPamMessage: \{\s*if \(fingerprintPam\.messageIsError\) root\.fingerprintFailureTick \+= 1\s*\}/.test(serviceQml),
  'a rejected fingerprint read bumps the failure tick'
)

assert(
  /fingerprintFailureTick: root\.fingerprintFailureTick/.test(serviceQml),
  'the lock surface passes the failure tick to the view'
)

assert(
  /fingerprintFailureTick = 0/.test(serviceQml),
  'the failure tick resets with the rest of the authentication state'
)

assert(
  /fingerprintError = true\s*fingerprintErrorTimer\.restart\(\)/.test(lockViewQml),
  'the view flashes the hint icon when the failure tick changes'
)

assert(
  /id: fingerprintErrorTimer[\s\S]*?onTriggered: root\.fingerprintError = false/.test(lockViewQml),
  'the hint icon returns to its normal color once the flash timer elapses'
)

assert(
  /color: root\.fingerprintError \? Color\.lock\.textError : Color\.lock\.placeholder/.test(lockViewQml),
  'the hint icon uses the error color while the flash is active'
)
JS
