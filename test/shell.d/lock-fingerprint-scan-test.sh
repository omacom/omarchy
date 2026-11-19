#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const model = requireFromRoot('shell/plugins/lock/FingerprintModel.js')

// The lines gdbus monitor prints for fprintd's device, as the lock reads them.
const present = "/net/reactivated/Fprint/Device/0: org.freedesktop.DBus.Properties.PropertiesChanged ('net.reactivated.Fprint.Device', {'finger-present': <true>}, @as [])"
// fprintd bundles both properties in one change when the finger it asked for
// lands: this is the line a Mac's Touch ID produced.
const landed = "/net/reactivated/Fprint/Device/0: org.freedesktop.DBus.Properties.PropertiesChanged ('net.reactivated.Fprint.Device', {'finger-needed': <false>, 'finger-present': <true>}, @as [])"
const absent = "/net/reactivated/Fprint/Device/0: org.freedesktop.DBus.Properties.PropertiesChanged ('net.reactivated.Fprint.Device', {'finger-present': <false>}, @as [])"
const needed = "/net/reactivated/Fprint/Device/0: org.freedesktop.DBus.Properties.PropertiesChanged ('net.reactivated.Fprint.Device', {'finger-needed': <true>}, @as [])"
const verdict = "/net/reactivated/Fprint/Device/0: net.reactivated.Fprint.Device.VerifyStatus ('verify-match', true)"
const header = 'Monitoring signals from all objects owned by net.reactivated.Fprint'
const owner = 'The name net.reactivated.Fprint is owned by :1.42'

assertEqual(model.parseFingerPresent(present), true, 'a finger landing on the reader reads as present')
assertEqual(model.parseFingerPresent(landed), true, 'a finger landing bundled with the reader no longer asking reads as present')
assertEqual(model.parseFingerPresent(absent), false, 'a finger leaving the reader reads as absent')
assertEqual(model.parseFingerPresent(needed), null, "the reader asking for a finger is not a finger")
assertEqual(model.parseFingerPresent(verdict), null, 'the verdict signal carries no finger status')
assertEqual(model.parseFingerPresent(header), null, "the monitor's own header is not a finger")
assertEqual(model.parseFingerPresent(owner), null, 'a name owner change is not a finger')
assertEqual(model.parseFingerPresent(''), null, 'an empty line is not a finger')
assertEqual(model.parseFingerPresent(undefined), null, 'no line is not a finger')

// A scan the daemon never ends is bounded, and the bound leaves a slow reader
// time to return its verdict first.
assert(model.SCAN_TIMEOUT_MS >= 2000, 'the scan bound leaves a slow reader time to match')
JS

require_quickshell "lock fingerprint scan test"

# A new lock service asks fprintd-list about enrolment, and the fixture's
# wiring check waits for that answer before it sends its stand-in line. Where
# this machine's lock has fingerprint PAM, the real fprintd-list can take
# longer than that wait to start the daemon, and an answer of no enrolment
# landing late would settle the attempt under the check. A stub answers at
# once, with an enrolment.
qml_fixture_scratch
printf '#!/bin/bash\nprintf "Fingerprints for user %%s on Stub:\\n - #0: right-index-finger\\n" "$1"\n' >"$QML_FIXTURE_TMP/bin/fprintd-list"
chmod +x "$QML_FIXTURE_TMP/bin/fprintd-list"

run_qml_fixture lock-fingerprint-scan "the lock shows the reader matching a finger" Ui Commons
