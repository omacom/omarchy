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

assert(
  retry.isRecoveryPrompt('Place your finger on the fingerprint reader', false),
  'a place-your-finger info message can show that a down reader recovered'
)
assert(!retry.isRecoveryPrompt('Place your finger on the fingerprint reader', true), 'an error-styled prompt is not recovery')
assert(!retry.isRecoveryPrompt('Verification timed out', false), 'an idle timeout is not a recovery prompt')
assert(!retry.isRecoveryPrompt('Failed to match fingerprint', true), 'a rejected print is not a recovery prompt')
assert(!retry.isRecoveryPrompt('', false), 'an empty PAM message is not a recovery prompt')

let scan = retry.applyPamMessage(4, false, false, 'Place your finger on the fingerprint reader', false)
assertEqual(scan.retryAttempt, 4, 'an ordinary prompt leaves the backoff where it is')
assertEqual(scan.promptSeen, true, 'an ordinary prompt records that this conversation offered a scan')
assertEqual(scan.readerDown, false, 'an ordinary prompt does not mark the reader down')
scan = retry.applyConversationEnd(scan.retryAttempt + 1, true, scan.promptSeen, false)
assertEqual(scan.retryAttempt, 5, 'a rejected scan after a prompt keeps the advanced backoff')
assertEqual(scan.readerDown, false, 'a scan offer clears a stale down latch when the conversation ends')
scan = retry.applyPamMessage(scan.retryAttempt, scan.readerDown, scan.promptSeen, 'Place your finger on the fingerprint reader', false)
assertEqual(scan.retryAttempt, 5, 'the next ordinary prompt still does not erase the backoff')

let down = retry.applyConversationEnd(2, false, false, false)
assertEqual(down.readerDown, true, 'a conversation with no scan prompt marks the reader down')
assertEqual(down.retryAttempt, 2, 'marking the reader down does not itself change the backoff')
down = retry.applyPamMessage(down.retryAttempt, down.readerDown, down.promptSeen, 'No devices available', true)
assertEqual(down.retryAttempt, 2, 'an error message does not reset a down reader')
assertEqual(down.readerDown, true, 'an error message leaves a down reader down')
down = retry.applyPamMessage(down.retryAttempt, down.readerDown, down.promptSeen, 'Verification timed out', false)
assertEqual(down.retryAttempt, 2, 'an idle timeout does not reset a down reader')
assertEqual(down.promptSeen, false, 'an idle timeout is not a scan prompt')
const idleEnd = retry.applyConversationEnd(down.retryAttempt, down.readerDown, down.promptSeen, true)
assertEqual(idleEnd.readerDown, true, 'an idle timeout does not clear a down reader')
assertEqual(idleEnd.retryAttempt, 2, 'an idle timeout does not change the backoff count')
down = retry.applyPamMessage(idleEnd.retryAttempt, idleEnd.readerDown, idleEnd.promptSeen, 'Place your finger on the fingerprint reader', false)
assertEqual(down.retryAttempt, 0, 'the first scan prompt after a down reader resets the backoff')
assertEqual(down.readerDown, false, 'that scan prompt clears the down-reader latch')
assertEqual(down.promptSeen, true, 'that scan prompt counts as a scan offer')

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
const fingerprintPam = serviceQml.slice(
  serviceQml.indexOf('id: fingerprintPam'),
  serviceQml.indexOf('readonly property string lockWallpaperPath')
)
assert(
  /onPamMessage:[\s\S]*FingerprintRetry\.applyPamMessage\(/.test(fingerprintPam) &&
    !/fingerprintRetryAttempt = 0/.test(fingerprintPam) &&
    !/if\s*\(\s*!fingerprintPam\.messageIsError && fingerprintPam\.message\s*\)/.test(serviceQml),
  'a PAM message does not zero the backoff; only applyPamMessage can, and only for recovery'
)
const startFingerprint = serviceQml.match(/function startFingerprint\(\) \{[\s\S]*?\n  \}/)
const finishedFingerprint = serviceQml.match(/function handleFingerprintFinished\(result\) \{[\s\S]*?\n  \}/)
assert(
  startFingerprint &&
    /FingerprintRetry\.applyConversationEnd\(/.test(startFingerprint[0]) &&
    finishedFingerprint &&
    /FingerprintRetry\.applyConversationEnd\(/.test(finishedFingerprint[0]) &&
    /scheduleFingerprintRetry\(idle\)/.test(finishedFingerprint[0]),
  'a conversation that never offered a scan, including a failed start, latches the reader down before retrying'
)
JS
