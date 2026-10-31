#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

lock="$ROOT/shell/plugins/lock"
service="$lock/Service.qml"
view="$lock/LockView.qml"

run_node_test <<'JS'
const fs = require('fs')
const model = requireFromRoot('shell/plugins/lock/FaceModel.js')
assert(model.ATTEMPT_TIMEOUT_MS > 4000 * 2, "the abort bound leaves Howdy's own 4-second timeout room to report")
assert(model.REARM_DELAY_MS >= 1000, 'a failed scan stays readable before the next check waits for the key')

// The lock follows the scan by the lines the helper and the key service print.
const helper = fs.readFileSync(path.join(root, 'bin/omarchy-face-match'), 'utf8')
const key = fs.readFileSync(path.join(root, 'bin/omarchy-face-key'), 'utf8')
assert(helper.includes(`echo "${model.SCAN_MESSAGE}"`), 'the helper announces a scan with the line the lock waits for')
assert(key.includes(`REFUSED_MESSAGE = "${model.REFUSED_MESSAGE}"`), 'the key service refuses with the line the lock recognises')
assert(key.includes(`ARMED_MESSAGE = "${model.ARMED_MESSAGE}"`), "the key service says the lock's check waits with the line the lock offers the face on")
// Howdy tells a face it does not know only by running out of time, and
// pam_exec turns that, like any refusal, into a system error.
assert(/\n  11\)\n    echo "([^"]*)"\n/.exec(helper)[1] === model.NO_MATCH_MESSAGE, "the helper reports Howdy's timeout with the line the lock takes for a stranger")
assertEqual(model.NO_MATCH_HOLD_MS, 10000, '"Who are you?" stands for ten seconds')

const hour = 60 * 60 * 1000
assertDeepEqual(model.parsePolicy(''), { attempts: 1, windowMs: hour }, 'without a policy file a lock allows one scan within an hour of locking')
assertDeepEqual(model.parsePolicy('# Face scans\nLOCK_ATTEMPTS=3\n  LOCK_WINDOW_MINUTES="15"  \nOTHER=9\n'), { attempts: 3, windowMs: 15 * 60 * 1000 },
  'the policy file sets both limits, quoted or not, and other keys are ignored')
for (const bad of ['0', '-1', '1.5', 'many', '', '01', '1 # one', '1234567']) {
  assertDeepEqual(model.parsePolicy(`LOCK_ATTEMPTS=${bad}\nLOCK_WINDOW_MINUTES=${bad}\n`), { attempts: 1, windowMs: hour },
    `a malformed value (${JSON.stringify(bad)}) falls back to the strict default`)
}

const policy = model.parsePolicy('LOCK_ATTEMPTS=2\nLOCK_WINDOW_MINUTES=60\n')
const lockedAt = 1700000000000
assert(!model.windowExpired(lockedAt, lockedAt + hour - 1, policy), 'the face stays on offer within the window after locking')
assert(model.windowExpired(lockedAt, lockedAt + hour, policy), 'the window closes once its minutes since locking have passed')
assert(model.windowExpired(0, lockedAt, policy), 'a lock of unknown age offers no face')
assert(model.windowExpired(lockedAt, lockedAt - 1, policy), 'a clock that went backwards offers no face')

assertEqual(model.faceState(false, 0, false, policy), '', 'nothing is offered without an enrolled face')
assertEqual(model.faceState(true, 0, false, policy), 'offered', 'a fresh lock offers the face')
assertEqual(model.faceState(true, 1, false, policy), 'offered', 'a scan left keeps the offer')
assertEqual(model.faceState(true, 2, false, policy), 'exhausted', 'the spent scans end the offer')
assertEqual(model.faceState(true, 2, true, policy), 'exhausted', 'spent scans are what the lock reports when both apply')
assertEqual(model.faceState(true, 0, true, policy), 'expired', 'the closed window ends the offer')

// The field offers the face only while root holds a check for the key, so a
// check that ended, however it ended, never leaves an offer with nothing behind it.
assertEqual(model.viewState('offered', false, false), '', 'an offer without a registered check shows the plain password field')
assertEqual(model.viewState('offered', true, false), 'offered', 'a registered check shows the offer')
assertEqual(model.viewState('offered', false, true), 'offered', 'a running scan keeps the offer shown')
for (const state of ['exhausted', 'expired', '']) {
  assertEqual(model.viewState(state, false, false), state, `"${state || 'unconfigured'}" shows as it is, check or not`)
}

// The model names catalog keys; English comes from the catalog, and a key
// the face did not add, like upstream's own lock.enterPassword, stays upstream's.
const catalog = JSON.parse(require('fs').readFileSync(path.join(root, 'default/i18n/en/shell.json'), 'utf8'))
const t = (key) => catalog[key] || key
const placeholders = {
  offered: 'Face or Password',
  exhausted: 'Password (face failed)',
  expired: 'Password (face expired)'
}
for (const [state, text] of Object.entries(placeholders)) {
  assertEqual(model.placeholderText(state, t), text, `the empty field reads "${text}" when the face state is "${state}"`)
  assert(text.length <= 23, `"${text}" fits the field beside the fingerprint hint`)
}
assertEqual(model.placeholderText('', (key) => key), 'lock.enterPassword', 'without a face the field keeps upstream\'s own prompt')
assertEqual(catalog['lock.faceNoMatch'], 'Who are you?', 'a face the lock does not know is asked who it is')
assertEqual(model.noMatchFollowUp('offered', t), '', 'with a scan left the field falls back to "Face or Password"')
assertEqual(model.noMatchFollowUp('exhausted', (key) => key), 'lock.enterPassword', 'with the scans spent the field asks for the password in upstream\'s words')
assertEqual(model.noMatchFollowUp('expired', (key) => key), 'lock.enterPassword', 'with the window closed the field asks for the password in upstream\'s words')
JS

# function_has <name> <literal>: the QML function's body contains the literal.
function_has() {
  awk -v name="function $1(" -v literal="$2" '
    index($0, name) { inside = 1 }
    inside && index($0, literal) { found = 1 }
    inside && /^  \}/ { exit }
    END { exit !found }' "$service"
}

# The face context mirrors the fingerprint one structurally: it waits while the
# lock offers the face, and root scans once the Copilot key is pressed. The
# lock itself never starts a scan, and the password field has nothing to do
# with the face any more.
grep -q 'id: facePam' "$service" || fail "the service has a face PAM context"
grep -q 'config: "omarchy-lock-face"' "$service" || fail "the face context uses the omarchy-lock-face service"
grep -q 'path: "/etc/pam.d/omarchy-lock-face"' "$service" || fail "enrollment is read from the lock PAM file the setup writes"
{ (( $(grep -c 'facePam.start()' "$service") == 1 )) && function_has armFace 'facePam.start()'; } || fail "only armFace starts the face check"
{ (( $(grep -c 'armFace()' "$service") == 2 )) && function_has syncFace 'armFace()'; } || fail "only syncFace arms it, and only while the lock offers the face"
function_has syncFace 'if (currentFaceState() === "offered") armFace()' || fail "the check is armed only while the face is offered"
function_has syncFace 'else if (facePam.active) settleFaceAttempt(' || fail "the check is withdrawn once the face is no longer offered"
! grep -q 'startFace\|faceScanRequested' "$service" "$view" || fail "nothing in the lock or its field starts a scan"
{ grep -Fq "          if (submitted.length > 0) root.submitPassword(submitted)" "$view" &&
  ! grep -A1 -F "root.submitPassword(submitted)" "$view" | grep -q 'else'; } || fail "Enter submits a typed password and nothing else"
grep -Pzo 'root\.startFingerprint\(\)\n\s*root\.syncFace\(\)' "$service" >/dev/null || fail "the check is armed once the lock is secure, beside the fingerprint"
function_has runWake 'syncFace()' || fail "waking the display re-checks the offer"
grep -q 'onFaceConfiguredChanged: syncFace()' "$service" || fail "enrolling or removing the face re-checks the offer"
grep -q 'onPamMessage: root.noteFaceMessage(message)' "$service" || fail "the lock follows the helper's lines"
function_has noteFaceMessage 'if (message === FaceModel.SCAN_MESSAGE) {' || fail "the helper's scan line marks the scan's start"
function_has noteFaceMessage 'failureMessage = I18n.t("lock.faceRefused")' || fail "a refused key is reported in the field"
awk '/function runBlank\(\) \{/{f=1} f && /if \(faceAuthenticating\) \{/{found=1} f && /^  \}/{exit} END{exit !found}' "$service" ||
  fail "blanking the display stops a running scan, not the waiting check"
{ grep -q 'interval: FaceModel.ATTEMPT_TIMEOUT_MS' "$service" && function_has noteFaceMessage 'faceAbortTimer.restart()'; } ||
  fail "a scan is bounded by the model's timeout from its start"
function_has handleFaceFinished 'if (!scanned) {' || fail "a check that ends without a scan is no attempt"
{ function_has handleFaceFinished 'rejectFace()' && function_has handleFaceFinished 'faceRearmTimer.restart()'; } ||
  fail "a miss is reported in the field and the check waits again after a pause"
grep -q '  property bool faceArmed: false' "$service" || fail "the lock tracks whether root holds its check"
function_has noteFaceMessage '} else if (message === FaceModel.ARMED_MESSAGE) {' || fail "the key service's line marks the check as registered"
{ function_has noteFaceMessage 'faceArmed = true' && function_has noteFaceMessage 'logEvent("face-armed")'; } ||
  fail "the registered check is noted and logged"
! function_has armFace 'logEvent("face-armed")' || fail "starting the conversation is not yet a registered check"
{ function_has settleFaceAttempt 'faceArmed = false' && function_has handleFaceFinished 'faceArmed = false'; } ||
  fail "a check that ends or is withdrawn is no longer registered"
awk '/function handleFaceFinished\(result\) \{/{f=1} f && /if \(!scanned\) \{/{s=1} s && /if \(armed\) faceRearmTimer\.restart\(\)/{found=1} f && /^  \}/{exit} END{exit !found}' "$service" ||
  fail "a registered check that ends without a scan waits again after a pause"
function_has handleFaceError 'if (armed && lockRequested) faceRearmTimer.restart()' ||
  fail "a registered check that fails without a scan waits again after a pause"
grep -q 'readonly property string faceViewState: FaceModel.viewState(faceState, faceArmed, faceAuthenticating)' "$service" ||
  fail "the field's offer follows the registered check"
grep -q 'interval: FaceModel.REARM_DELAY_MS' "$service" || fail "the pause comes from the model"
grep -Pzo 'interval: 30000\s*repeat: true\s*running: root\.lockRequested && root\.faceConfigured\s*onTriggered: root\.syncFace\(\)' "$service" >/dev/null ||
  fail "the offer is re-checked while the display stays on"
{ grep -q 'face: root.faceConfigured' "$service" && grep -q 'faceArmed: root.faceArmed' "$service"; } || fail "the lock status reports enrollment and the registered check"
grep -qF 'Commons.I18n.t("lock.scanningFace")' "$view" || fail "a running scan is shown in the field"
{ grep -q 'id: faceIcon' "$view" && grep -q 'Math.max(root.fingerprintReserve, root.faceReserve)' "$view"; } || fail "the view shows a face hint and keeps the dots clear of it"
pass "the lock keeps a face check waiting for the Copilot key while it offers the face and never scans on its own"

# A stranger's face reaches the lock as pam_exec's system error after the
# helper's timeout line; the lock asks who it is, holds that, then says what
# is left. Typing, a new scan or a new lock replaces the question first.
function_has noteFaceMessage '} else if (message === FaceModel.NO_MATCH_MESSAGE) {' || fail "the lock follows the helper's timeout line"
function_has noteFaceMessage 'if (faceAuthenticating) faceNoMatch = true' || fail "only a running scan's timeout line marks a stranger"
function_has noteFaceMessage 'faceNoMatch = false' || fail "every scan starts without a verdict"
grep -q 'onError: function(error) { root.handleFaceError() }' "$service" || fail "the face context's error goes through the stranger check"
function_has handleFaceError 'if (!scanning || !faceNoMatch) {' || fail "an error without the timeout line stays an error"
function_has handleFaceError 'settleFaceAttempt("face-error", I18n.t("lock.faceUnavailable"))' || fail "a real error still says the face is unavailable"
{ function_has handleFaceError 'settleFaceAttempt("face-no-match")' && function_has handleFaceError 'rejectFace()' &&
  function_has handleFaceError 'faceRearmTimer.restart()'; } || fail "a stranger is asked who they are, and the check waits again after a pause"
{ function_has rejectFace 'failureMessage = I18n.t("lock.faceNoMatch")' && function_has rejectFace 'faceNoMatchTimer.restart()'; } ||
  fail "the question starts the hold"
grep -Pzo 'id: faceNoMatchTimer\s*interval: FaceModel\.NO_MATCH_HOLD_MS\s*repeat: false\s*onTriggered: root\.followUpNoMatch\(\)' "$service" >/dev/null ||
  fail "the hold comes from the model and ends in the follow-up"
{ function_has followUpNoMatch 'if (failureMessage !== I18n.t("lock.faceNoMatch")) return' &&
  function_has followUpNoMatch 'failureMessage = FaceModel.noMatchFollowUp(currentFaceState(), I18n.t)'; } ||
  fail "the follow-up replaces only the question still standing, by what the lock still offers"
function_has resetAuthenticationState 'faceNoMatchTimer.stop()' || fail "a new lock or an unlock ends the hold"
function_has noteFaceMessage 'faceNoMatchTimer.stop()' || fail "a new scan ends the hold"
pass "a face the lock does not know is asked \"Who are you?\" for ten seconds, then told to enter the password"

# Each lock bounds the offer: so many scans, so long after locking. The policy
# is root's file, the count and the clock belong to the lock, and the decision
# to scan reads them afresh instead of trusting a binding.
grep -q 'path: "/etc/omarchy/face.conf"' "$service" || fail "the policy comes from the file the setup writes"
grep -q 'onLoadFailed: root.applyFacePolicy("")' "$service" || fail "a missing policy file means the strict defaults"
function_has noteFaceMessage 'refreshFaceWindow()' || fail "a scan's start re-reads the clock, which a dark display or sleep may have left stale"
function_has noteFaceMessage 'if (currentFaceState() !== "offered") {' || fail "a scan past the lock's offer is stopped at once"
function_has noteFaceMessage 'faceAttempts += 1' || fail "every scan counts against the lock's allowance"
function_has resetAuthenticationState 'faceAttempts = 0' || fail "a new lock or an unlock restores the allowance"
function_has beginLock 'faceLockedAtMs = Date.now()' || fail "the window starts when the screen locks"
function_has recoverStrandedLock 'faceLockedAtMs = 0' || fail "a lock recovered after a shell restart offers no face: its age and spent scans are unknown"
function_has syncFace 'refreshFaceWindow()' || fail "every re-check of the offer reads the window afresh"
# A scan holds the display up the way a password check does, by stopping the
# idle blank, which would otherwise cut it short and spend the allowance.
# Upstream's own gate on the timer stays as it is.
grep -Pzo 'onFaceAuthenticatingChanged: \{\s*if \(!lockRequested\) return\s*if \(faceAuthenticating\) idleBlankTimer\.stop\(\)\s*else armBlankTimer\(\)' "$service" >/dev/null ||
  fail "a starting scan stops the idle blank and its end re-arms it"
function_has armBlankTimer 'if (faceAuthenticating) return' || fail "activity during a scan does not re-arm the idle blank under it"
grep -q 'if (root.lockRequested && !root.authenticatingPassword) root.runBlank()' "$service" || fail "upstream's gate on the idle blank stays as it is"
grep -q 'faceState: root.faceState,' "$service" || fail "the lock status reports what it offers"
grep -q 'faceState: root.faceViewState$' "$service" || fail "the locked view follows the lock's offer and its registered check"
pass "each lock offers the face for a bounded number of scans within a bounded time"

grep -q 'import "FaceModel.js" as FaceModel' "$view" || fail "the view reads its texts from the model"
grep -qF 'placeholderText: FaceModel.placeholderText(faceState, Commons.I18n.t)' "$view" ||
  fail "the empty field names what unlocks the screen in each face state"
grep -q 'readonly property bool faceIconShown: faceState === "offered" || faceAuthenticating' "$view" ||
  fail "the camera hint shows only while the face is offered or scanning"
grep -q 'visible: root.faceIconShown' "$view" || fail "the camera hint follows the offer"
grep -q 'faceReserve: faceIconShown ?' "$view" || fail "the dots reclaim the hint's space once it goes"
pass "the field and the camera hint say whether the face can still unlock"

qmllint=/usr/lib/qt6/bin/qmllint
if [[ -x $qmllint ]]; then
  for file in "$service" "$view"; do
    out=$("$qmllint" --bare "$file" 2>&1 || true)
    ! grep -q -i -E 'syntax error|unexpected token|expected token' <<<"$out" || fail "${file##*/} parses" "$out"
  done
  pass "the patched QML parses"
else
  skip "qmllint is not installed; QML syntax not checked"
fi
