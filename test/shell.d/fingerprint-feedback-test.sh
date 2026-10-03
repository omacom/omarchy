#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const readerQml = fs.readFileSync(path.join(root, 'shell/Ui/FingerprintReader.qml'), 'utf8')
const lockQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')
const polkitQml = fs.readFileSync(path.join(root, 'shell/plugins/polkit/PolkitAgent.qml'), 'utf8')

// Pull a top-level QML function out of the reader so it can run against a
// stand-in for the reader's properties.
function extractFunction(name) {
  const start = readerQml.indexOf(`  function ${name}(`)
  if (start < 0) fail(`FingerprintReader.qml defines ${name}`)
  const end = readerQml.indexOf('\n  }\n', start)
  const source = readerQml.slice(start, end + 4)
  const params = source.slice(source.indexOf('(') + 1, source.indexOf(')'))
  const body = source.slice(source.indexOf('{') + 1, source.lastIndexOf('}'))
  return { params, body }
}

const handler = extractFunction('handleLine')

function makeReader() {
  const reader = {
    active: true,
    needed: false,
    present: false,
    touched: false,
    result: '',
    resultTimer: { stop() {} },
    results: [],
    landings: 0,
    showResult(value) { reader.present = false; reader.result = value; reader.results.push(value) },
    fingerLanded() { reader.landings += 1 }
  }
  // Sloppy-mode `with` resolves the QML function's bare property names.
  reader.handle = new Function('reader', handler.params, `with (reader) {${handler.body}}`).bind(null, reader)
  return reader
}

// Lines as `gdbus monitor --system --dest net.reactivated.Fprint` prints them,
// captured from an Apple Silicon Touch ID sensor through fprintd 1.94.
const needed = "/net/reactivated/Fprint/Device/0: org.freedesktop.DBus.Properties.PropertiesChanged ('net.reactivated.Fprint.Device', {'finger-needed': <true>}, @as [])"
const present = "/net/reactivated/Fprint/Device/0: org.freedesktop.DBus.Properties.PropertiesChanged ('net.reactivated.Fprint.Device', {'finger-needed': <false>, 'finger-present': <true>}, @as [])"
const lifted = "/net/reactivated/Fprint/Device/0: org.freedesktop.DBus.Properties.PropertiesChanged ('net.reactivated.Fprint.Device', {'finger-present': <false>}, @as [])"
const noMatch = "/net/reactivated/Fprint/Device/0: net.reactivated.Fprint.Device.VerifyStatus ('verify-no-match', true)"
const match = "/net/reactivated/Fprint/Device/0: net.reactivated.Fprint.Device.VerifyStatus ('verify-match', true)"
const retry = "/net/reactivated/Fprint/Device/0: net.reactivated.Fprint.Device.VerifyStatus ('verify-retry-scan', false)"

const r = makeReader()
r.handle(needed)
assert(r.needed && !r.present, 'finger-needed marks the reader as waiting')

r.handle(present)
assert(!r.needed && r.present, 'finger-present marks the scan in progress')
assertEqual(r.landings, 1, 'a finger landing on the sensor is reported')

r.handle(present)
assertEqual(r.landings, 1, 'a repeated finger-present is not a new landing')

r.handle(noMatch)
assertEqual(r.results.join(','), 'no-match', 'verify-no-match reports a rejected read')

r.handle(present)
assertEqual(r.result, '', 'a new finger on the sensor clears the last verdict')
assertEqual(r.landings, 2, 'each new finger on the sensor is reported')

r.handle(retry)
assertEqual(r.results.join(','), 'no-match,retry', 'retry statuses report a read to repeat')

r.handle(match)
assertEqual(r.results.join(','), 'no-match,retry,match', 'verify-match reports a match')

r.handle(lifted)
assert(!r.present, 'finger-present false ends the scan')

r.handle("/net/reactivated/Fprint/Device/0: net.reactivated.Fprint.Device.VerifyFingerSelected ('right-index-finger',)")
assertEqual(r.results.length, 3, 'unrelated fprintd signals are ignored')

// pam_fprintd cancels the verify at its 30 s timeout, and the Apple SEP driver
// answers the cancel with verify-no-match. No finger came near the sensor, so
// no rejection is shown.
const cancelled = makeReader()
cancelled.handle(needed)
cancelled.handle(noMatch)
cancelled.handle(retry)
assertEqual(cancelled.results.length, 0, 'a verdict with no finger on the sensor is ignored')
cancelled.handle(present)
cancelled.handle(noMatch)
assertEqual(cancelled.results.join(','), 'no-match', 'a rejection after a touch is still shown')
cancelled.handle(noMatch)
assertEqual(cancelled.results.join(','), 'no-match', 'one touch yields one verdict')
cancelled.handle(match)
assertEqual(cancelled.results.join(','), 'no-match,match', 'a match is always shown')

const inactive = makeReader()
inactive.active = false
inactive.handle(present)
assert(!inactive.present && inactive.landings === 0, 'signals are ignored while the reader is inactive')

// The monitor is display-only: it must never be what authenticates.
assert(
  /command: \["gdbus", "monitor", "--system", "--dest", "net\.reactivated\.Fprint"\]/.test(readerQml),
  'the reader watches fprintd on the system bus'
)
assert(/running: root\.active/.test(readerQml), 'the fprintd monitor only runs while active')
assert(!/Pam|finishUnlock|submit/.test(readerQml), 'the reader never authenticates by itself')

// Lock screen wiring.
assert(
  /FingerprintReader \{[^}]*active: root\.lockRequested && root\.fingerprintConfigured/.test(lockQml),
  'the lock watches the reader only while locked with an enrolled finger'
)
assert(/onFingerLanded: root\.runWake\(\)/.test(lockQml), 'a finger on the sensor wakes a blanked lock screen')
assert(
  /readonly property string fingerprintState: fingerprintConfigured \? fingerprintReader\.readerState : "idle"/.test(lockQml),
  'the lock shows reader state only with an enrolled finger'
)

// Polkit dialog wiring.
assert(
  /readonly property bool holdsReader: fingerprintMode && !closing/.test(polkitQml) &&
    /FingerprintReader \{[^}]*active: root\.holdsReader \|\| root\.awaitingVerdict/.test(polkitQml),
  'polkit watches the reader only while this request holds it'
)
assert(
  /onFingerLanded: if \(root\.holdsReader\) root\.awaitingVerdict = true/.test(polkitQml) &&
    /if \(!holdsReader && awaitingVerdict\) verdictGraceTimer\.restart\(\)/.test(polkitQml) &&
    /id: verdictGraceTimer\s+interval: 500/.test(polkitQml),
  'polkit keeps listening briefly for the verdict of a read under way when it lets the reader go'
)
assert(/onVerdict: function\(result\) \{\s+root\.awaitingVerdict = false/.test(polkitQml), 'the verdict ends the grace window')
assert(/function beginFlow\(\) \{[^}]*awaitingVerdict = false/.test(polkitQml), 'a new polkit request drops any pending grace window')
assert(/function beginFlow\(\) \{[^}]*fingerprintReader\.clear\(\)/.test(polkitQml), 'each polkit request starts without a stale verdict')
assert(/function resetSnapshot\(\) \{[^}]*fingerprintReader\.clear\(\)/.test(polkitQml), 'a closed polkit dialog drops its reader state')
assert(
  /onVerdict: function\(result\) \{[^}]*if \(result !== "match"\) shakeAnimation\.restart\(\)/.test(polkitQml),
  'a rejected read shakes the polkit card'
)
JS
