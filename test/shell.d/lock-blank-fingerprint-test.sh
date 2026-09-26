#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

// The fingerprint PAM stays armed for the whole lock waiting for a finger, so
// `authenticating` is true from lock until unlock on every machine with a
// reader enrolled. Gating the blank on it leaves the panel lit all night.
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

// Nobody can touch the sensor once the panel is dark, so the reader is not
// polled through the blank: the PAM conversation is dropped and the retry
// timer stopped until the display comes back.
assert(
  /function runBlank\(\) \{[\s\S]*?suspendFingerprint\(\)[\s\S]*?\n  \}/.test(serviceQml),
  'blanking the display suspends the fingerprint'
)

assert(
  /function suspendFingerprint\(\) \{[\s\S]*?fingerprintRetryTimer\.stop\(\)[\s\S]*?if \(fingerprintPam\.active\) fingerprintPam\.abort\(\)/.test(serviceQml),
  'suspending stops the retry timer and aborts the fingerprint PAM'
)

assert(
  /startFingerprint\(\) \{\s*if \(fingerprintSuspended \|\|/.test(serviceQml),
  'the fingerprint prompt does not start again while suspended'
)

assert(
  /function scheduleFingerprintRetry\(\) \{\s*if \([^)]*fingerprintSuspended\) return/.test(serviceQml),
  'an aborted conversation does not re-arm the retry timer while suspended'
)

// The display coming back is the only thing that brings the reader back, and
// it must survive a wake that is itself the first keystroke of a password.
assert(
  /function runWake\(\) \{[\s\S]*?resumeFingerprint\(\)[\s\S]*?\n  \}/.test(serviceQml),
  'waking the display resumes the fingerprint'
)

assert(
  /function resumeFingerprint\(\) \{[\s\S]*?if \(lockRequested && fingerprintConfigured\) startFingerprint\(\)/.test(serviceQml),
  'resuming only re-arms a lock that still wants a fingerprint'
)

const fingerprintToggles = serviceQml.match(/function (?:suspend|resume)Fingerprint\(\) \{[\s\S]*?\n  \}/g) || []

assert(
  fingerprintToggles.length === 2,
  'the display drives the fingerprint through one suspend and one resume'
)

assert(
  fingerprintToggles.every(body => !/[Pp]assword/.test(body)),
  'suspending and resuming never touch a password in flight'
)

assert(
  /resetAuthenticationState\(\) \{[\s\S]*?fingerprintSuspended = false/.test(serviceQml),
  'a fresh lock starts with the fingerprint unsuspended'
)

// A reader that errors the instant it is asked answers faster than a finger
// can arrive, so retrying it at the base interval is a hot loop for as long as
// the lock is up. Only those attempts compound, and the display waking clears
// the streak so a recovered reader is live again straight away.
assert(
  /else scheduleFingerprintRetry\(\)/.test(serviceQml) &&
    /onError: function\(error\) \{[\s\S]*?root\.scheduleFingerprintRetry\(\)/.test(serviceQml),
  'every unsuccessful fingerprint conversation reschedules through the backoff'
)

assert(
  !/fingerprintRetryTimer\.restart\(\)/.test(serviceQml.replace(/function (?:reset|schedule)Fingerprint\w+\(\) \{[\s\S]*?\n  \}/g, '')),
  'nothing re-arms the retry timer behind the backoff'
)

assert(
  /interval: root\.fingerprintRetryDelay/.test(serviceQml),
  'the retry timer takes its interval from the backoff'
)

const retryDelay = serviceQml.match(/readonly property int fingerprintRetryDelay:[\s\S]*?\n  property/)
assert(retryDelay, 'the retry delay is derived from the failure streak')
assert(
  /fingerprintFailureStreak === 0\s*\?\s*fingerprintRetryBase/.test(retryDelay[0]),
  'a fingerprint that took a real touch to fail is retried at the base interval'
)
assert(
  /Math\.min\(fingerprintRetryMax, fingerprintRetryFloor \* Math\.pow\(2, fingerprintFailureStreak - 1\)\)/.test(retryDelay[0]),
  'instant failures back off exponentially up to the cap'
)

const backoff = {}
for (const [, name, value] of serviceQml.matchAll(/readonly property int (fingerprintRetry\w+|fingerprintInstantFailure): (\d+)/g)) {
  backoff[name] = Number(value)
}

assert(backoff.fingerprintRetryBase === 250, 'the base retry interval is unchanged')
assert(backoff.fingerprintRetryFloor >= 2000, 'a failing reader is left alone for at least a couple of seconds')
assert(backoff.fingerprintRetryMax === 30000, 'the backoff is capped at 30s')
assert(
  backoff.fingerprintInstantFailure > 0 && backoff.fingerprintInstantFailure <= backoff.fingerprintRetryFloor,
  'an attempt is only instant if it ended sooner than a finger could reach the reader'
)

assert(
  /function resumeFingerprint\(\) \{\s*resetFingerprintBackoff\(\)/.test(serviceQml),
  'the display waking clears the backoff even when the fingerprint was never suspended'
)

assert(
  /resetAuthenticationState\(\) \{[\s\S]*?fingerprintFailureStreak = 0/.test(serviceQml),
  'a fresh lock starts with no backoff'
)
JS
