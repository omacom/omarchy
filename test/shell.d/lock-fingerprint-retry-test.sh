#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const retry = requireFromRoot('shell/plugins/lock/FingerprintRetry.js')

assertEqual(retry.INITIAL_MS, 250, 'fingerprint retry starts at 250ms')
assertEqual(retry.MAX_MS, 8000, 'fingerprint retry caps at 8s')

assertEqual(retry.nextInterval(0), 250, 'first failure retries in 250ms')
assertEqual(retry.nextInterval(250), 500, 'second failure doubles')
assertEqual(retry.nextInterval(500), 1000, 'third failure doubles')
assertEqual(retry.nextInterval(4000), 8000, 'doubling stops at the cap')
assertEqual(retry.nextInterval(8000), 8000, 'a capped delay stays capped')
assertEqual(retry.nextInterval(-1), 250, 'a negative delay restarts at 250ms')
assertEqual(retry.nextInterval('nope'), 250, 'a non-numeric delay restarts at 250ms')

const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

assert(
  /import "FingerprintRetry\.js" as FingerprintRetry/.test(serviceQml),
  'the lock service uses FingerprintRetry.js for the delay'
)
assert(
  /fingerprintRetryMs = FingerprintRetry\.nextInterval\(fingerprintRetryMs\)/.test(serviceQml),
  'each fingerprint failure advances the backoff'
)
assert(
  /function scheduleFingerprintRetry\(\)/.test(serviceQml) &&
    /scheduleFingerprintRetry\(\)/.test(serviceQml.replace(/function scheduleFingerprintRetry\(\)[\s\S]*?\n  \}/, '')),
  'fingerprint PAM failure and error both schedule the backoff timer'
)
assert(
  /fingerprintRetryMs = 0/.test(serviceQml),
  'a new lock session resets the fingerprint backoff'
)
JS
