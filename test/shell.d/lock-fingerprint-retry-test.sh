#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const retry = requireFromRoot('shell/plugins/lock/FingerprintRetry.js')

assertEqual(retry.INITIAL_MS, 250, 'fingerprint retry starts at 250ms')
assertEqual(retry.CAP_MS, 30000, 'fingerprint retry delay caps at 30s')

assertEqual(retry.delayForAttempt(0), 250, 'first failure retries in 250ms')
assertEqual(retry.delayForAttempt(1), 500, 'second failure doubles')
assertEqual(retry.delayForAttempt(2), 1000, 'third failure doubles')
assertEqual(retry.delayForAttempt(7), 30000, 'later failures stay at the 30s cap')
assertEqual(retry.delayForAttempt(99), 30000, 'the delay never grows past 30s')
assertEqual(retry.delayForAttempt(-1), 250, 'a negative attempt restarts at 250ms')
assertEqual(retry.delayForAttempt('nope'), 250, 'a non-numeric attempt restarts at 250ms')

assert(retry.isIdleTimeout('Verification timed out'), 'pam_fprintd timeout is an idle timeout')
assert(retry.isIdleTimeout('verification timed out.'), 'idle timeout match is case-insensitive')
assert(!retry.isIdleTimeout('Failed to match fingerprint'), 'a rejected print is not an idle timeout')
assert(!retry.isIdleTimeout(''), 'an empty PAM message is not an idle timeout')

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
  /fingerprintRetryAttempt \+= 1/.test(serviceQml) &&
    /FingerprintRetry\.delayForAttempt\(fingerprintRetryAttempt\)/.test(serviceQml),
  'each consumed fingerprint failure advances the backoff'
)
assert(
  !/FingerprintRetry\.shouldRetry/.test(serviceQml) &&
    !/fingerprint-retry-exhausted/.test(serviceQml),
  'fingerprint retries keep a capped delay instead of stopping'
)
assert(
  /onError:[\s\S]*fingerprintAuthenticating = false/.test(serviceQml) &&
    !/onError:[\s\S]*scheduleFingerprintRetry/.test(serviceQml),
  'onError does not schedule a retry; Quickshell always follows it with completed(Error)'
)
assert(
  /PamResult\.Failed && FingerprintRetry\.isIdleTimeout/.test(serviceQml),
  'a timed-out verify does not consume a backoff slot'
)
assert(
  /function scheduleFingerprintRetry\(/.test(serviceQml) &&
    /handleFingerprintFinished/.test(serviceQml),
  'fingerprint PAM completion schedules the backoff timer'
)
assert(
  /fingerprintRetryAttempt = 0/.test(serviceQml),
  'a new lock session resets the fingerprint backoff'
)
assert(
  /onSecureStateChanged:[\s\S]*fingerprintRetryAttempt = 0/.test(serviceQml),
  'a newly secured lock resets the fingerprint backoff'
)
assert(
  /if \(!fingerprintPam\.start\(\)\) \{[\s\S]*scheduleFingerprintRetry\(/.test(serviceQml),
  'a failed fingerprintPam.start still consumes the backoff'
)
assert(
  /onPamMessage:[\s\S]*fingerprintRetryAttempt = 0/.test(serviceQml),
  'a live fingerprint prompt resets the backoff so a recovered reader is not stuck at 30s'
)
JS
