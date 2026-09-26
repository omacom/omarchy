#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const lockSource = fs.readFileSync(root + '/shell/plugins/lock/Service.qml', 'utf8')

assert(
  /} else if \(fingerprintConfigured\) \{\s*\n\s*scheduleFingerprintRetry\(\)/.test(lockSource),
  'a failed fingerprint match is rescheduled through the backoff'
)
assert(
  /root\.fingerprintConfigured\) root\.scheduleFingerprintRetry\(\)/.test(lockSource),
  'a fingerprint PAM error is rescheduled through the backoff'
)
assert(
  /fingerprintStartedAt = Date\.now\(\)/.test(lockSource),
  'the lock screen records when a fingerprint attempt started'
)

const delayFn = lockSource.match(/  function fingerprintRetryDelay\([\s\S]*?\n  \}/)
assert(delayFn, 'the lock screen exposes a fingerprint retry delay curve')

var fingerprintRetryBaseMs = 250
var fingerprintRetryMaxMs = 30000
eval(delayFn[0])

assert(fingerprintRetryDelay(0) === 250, 'the first retry stays responsive')
assert(fingerprintRetryDelay(1) === 250, 'a single immediate failure retries at the base interval')
assert(fingerprintRetryDelay(2) === 500, 'repeated immediate failures back off')
assert(fingerprintRetryDelay(3) === 1000, 'the backoff doubles')
assert(fingerprintRetryDelay(9) === 30000, 'the backoff reaches its ceiling')
assert(fingerprintRetryDelay(999) === 30000, 'the backoff never exceeds its ceiling')

const scheduleFn = lockSource.match(/  function scheduleFingerprintRetry\([\s\S]*?\n  \}/)
assert(scheduleFn, 'the lock screen schedules fingerprint retries in one place')

var fingerprintImmediateFailures = 0
var fingerprintStartedAt = 0
var fingerprintImmediateFailureMs = 1000
var fingerprintRetryTimer = { interval: 0, restart() {} }
eval(scheduleFn[0])

fingerprintStartedAt = Date.now()
scheduleFingerprintRetry()
assert(fingerprintRetryTimer.interval === 250, 'the first immediate failure retries promptly')
fingerprintStartedAt = Date.now()
scheduleFingerprintRetry()
assert(fingerprintRetryTimer.interval === 500, 'a second immediate failure waits longer')
fingerprintStartedAt = Date.now()
scheduleFingerprintRetry()
assert(fingerprintRetryTimer.interval === 1000, 'a third immediate failure waits longer still')

// An attempt the user actually took part in must not inherit the backoff.
fingerprintStartedAt = Date.now() - 5000
scheduleFingerprintRetry()
assert(fingerprintImmediateFailures === 0, 'a genuine mismatch clears the backoff')
assert(fingerprintRetryTimer.interval === 250, 'a genuine mismatch retries promptly again')
JS
