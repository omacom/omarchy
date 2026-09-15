#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const retry = requireFromRoot('shell/plugins/lock/FingerprintRetry.js')

assertEqual(retry.INITIAL_MS, 250, 'fingerprint retry starts at 250ms')
assertEqual(retry.CAP_MS, 30000, 'fingerprint retry delay caps at 30s')
assertEqual(retry.MAX_ATTEMPTS, 8, 'fingerprint retries stop after 8 attempts')

assertEqual(retry.delayForAttempt(0), 250, 'first failure retries in 250ms')
assertEqual(retry.delayForAttempt(1), 500, 'second failure doubles')
assertEqual(retry.delayForAttempt(2), 1000, 'third failure doubles')
assertEqual(retry.delayForAttempt(7), 30000, 'the last allowed delay hits the 30s cap')
assertEqual(retry.delayForAttempt(-1), 250, 'a negative attempt restarts at 250ms')
assertEqual(retry.delayForAttempt('nope'), 250, 'a non-numeric attempt restarts at 250ms')

assert(retry.shouldRetry(0), 'the first failure still retries')
assert(retry.shouldRetry(7), 'the eighth failure still retries')
assert(!retry.shouldRetry(8), 'the ninth failure is exhausted')
assert(!retry.shouldRetry(99), 'attempts past the cap stay exhausted')
assert(retry.shouldRetry(-1), 'a negative attempt count still retries')
assert(retry.shouldRetry('nope'), 'a non-numeric attempt count still retries')

assertEqual(retry.lidClosedPolicy('skip'), 'skip', 'skip is an explicit lid-closed policy')
assertEqual(retry.lidClosedPolicy('try'), 'try', 'try is an explicit lid-closed policy')
assertEqual(retry.lidClosedPolicy(undefined), 'try', 'a missing lid policy keeps current quattro behavior')
assertEqual(retry.lidClosedPolicy('nope'), 'try', 'an unknown lid policy keeps current quattro behavior')

const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

assert(
  /import "FingerprintRetry\.js" as FingerprintRetry/.test(serviceQml),
  'the lock service uses FingerprintRetry.js for the delay'
)
assert(
  /fingerprintRetryAttempt = FingerprintRetry/.test(serviceQml) === false,
  'attempt tracking stays in the service, not the delay helper'
)
assert(
  /fingerprintRetryAttempt \+= 1/.test(serviceQml) &&
    /FingerprintRetry\.delayForAttempt\(fingerprintRetryAttempt\)/.test(serviceQml),
  'each fingerprint failure consumes one attempt and uses that attempt for the delay'
)
assert(
  /FingerprintRetry\.shouldRetry\(fingerprintRetryAttempt\)/.test(serviceQml),
  'fingerprint retries stop when the attempt budget is exhausted'
)
assert(
  /fingerprint-retry-exhausted/.test(serviceQml),
  'exhausting fingerprint retries is logged'
)
assert(
  /function scheduleFingerprintRetry\(\)/.test(serviceQml) &&
    /scheduleFingerprintRetry\(\)/.test(serviceQml.replace(/function scheduleFingerprintRetry\(\)[\s\S]*?\n  \}/, '')),
  'fingerprint PAM failure and error both schedule the backoff timer'
)
assert(
  /fingerprintRetryAttempt = 0/.test(serviceQml),
  'a new lock session resets the fingerprint retry budget'
)
assert(
  /onSecureStateChanged:[\s\S]*fingerprintRetryAttempt = 0/.test(serviceQml),
  'a newly secured lock resets the fingerprint retry budget'
)
assert(
  /if \(!fingerprintPam\.start\(\)\) \{[\s\S]*scheduleFingerprintRetry\(\)/.test(serviceQml),
  'a failed fingerprintPam.start still consumes the backoff budget'
)
JS
