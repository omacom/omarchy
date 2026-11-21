import QtQuick
import QtTest

TestCase {
  id: test
  name: "SddmTheme"
  when: windowShown
  width: 800
  height: 600
  visible: true

  property bool optionalBackend: true
  property var sddm: optionalBackend ? modern : legacy
  property var userModel: users
  property var sessionModel: sessions
  property var greeter: null

  QtObject { id: users; property string lastUser: "fixture-user" }
  QtObject {
    id: sessions
    property int lastIndex: 0
    function rowCount() { return 2 }
    function index(row, column) { return row }
    function data(index, role) { return index === 1 ? "Hyprland (uwsm)" : "Another session" }
  }
  QtObject {
    id: modern
    property bool parallelFingerprint: true
    property bool connected: true
    property var calls: []
    property var scans: []
    signal loginFailed()
    signal loginSucceeded()
    signal fingerprintActiveChanged(bool active)
    signal socketDisconnected()
    function login(user, password, session) {
      if (!connected) return
      calls = calls.concat([{user: user, password: password, session: session}])
    }
    function startFingerprint(user, session) {
      if (!connected) return
      scans = scans.concat([{user: user, session: session}])
    }
  }
  // Deliberately omit every optional property, method and signal.
  QtObject {
    id: legacy
    property var calls: []
    signal loginFailed()
    signal loginSucceeded()
    signal socketDisconnected()
    signal hostNameChanged()
    function login(user, password, session) {
      calls = calls.concat([{user: user, password: password, session: session}])
    }
  }
  Item { id: otherFocus; focus: false }

  function input() { return findChild(greeter, "passwordInput") }
  function indicator() { return findChild(greeter, "fingerprintIndicator") }
  function createGreeter(optional) {
    optionalBackend = optional
    modern.calls = []; modern.scans = []; legacy.calls = []
    modern.parallelFingerprint = true
    modern.connected = true
    users.lastUser = "fixture-user"
    var component = Qt.createComponent("../../../../default/sddm/omarchy/Main.qml")
    compare(component.status, Component.Ready, component.errorString())
    greeter = component.createObject(test, {width: 800, height: 600})
    verify(greeter !== null)
  }
  function init() { createGreeter(true) }
  function cleanup() { greeter.destroy(); greeter = null }
  function initialScan() { tryVerify(function() { return modern.scans.length === 1 }) }

  function test_starts_fingerprint_without_password_submission() {
    initialScan()
    compare(modern.scans[0].user, "fixture-user")
    compare(modern.scans[0].session, 1)
    compare(modern.calls.length, 0)
  }

  function test_initial_scan_keeps_partly_typed_password() {
    input().text = "partial"
    initialScan()
    compare(input().text, "partial")
    compare(modern.calls.length, 0)
  }

  function test_legacy_backend_keeps_password_and_explicit_empty_submission() {
    cleanup(); createGreeter(false)
    verify(!indicator().visible)
    input().forceActiveFocus()
    keyClick(Qt.Key_Return)
    compare(legacy.calls.length, 1)
    compare(legacy.calls[0].password, "")
    legacy.loginFailed()
    input().text = "synthetic"
    keyClick(Qt.Key_Return)
    compare(legacy.calls.length, 2)
    compare(legacy.calls[1].password, "synthetic")
  }

  function test_legacy_reconnect_preserves_text_until_hostname_announcement() {
    cleanup(); createGreeter(false)
    input().text = "partial"
    legacy.socketDisconnected()
    input().forceActiveFocus(); keyClick(Qt.Key_Return)
    compare(legacy.calls.length, 0); verify(!greeter.passwordBusy)
    compare(input().text, "partial")
    legacy.hostNameChanged()
    keyClick(Qt.Key_Return)
    compare(legacy.calls.length, 1)
    compare(legacy.calls[0].password, "partial")
  }

  function test_password_submission_keeps_reader_and_newer_edits() {
    initialScan(); modern.fingerprintActiveChanged(true)
    input().text = "old-synthetic"; input().forceActiveFocus()
    keyClick(Qt.Key_Return); keyClick(Qt.Key_Return)
    compare(modern.calls.length, 1)
    verify(greeter.passwordBusy); verify(greeter.fingerprintActive)
    verify(input().enabled)
    input().text = "new-synthetic"
    modern.loginFailed()
    compare(input().text, "new-synthetic")
    verify(!greeter.loginFailed); verify(!greeter.passwordBusy)
    verify(greeter.fingerprintActive)
    compare(modern.scans.length, 1)
  }

  function test_failed_password_restores_focus_and_accessible_feedback() {
    initialScan(); input().text = "synthetic"; greeter.submitPassword()
    compare(findChild(greeter, "passwordStatus").Accessible.name, "Checking password")
    otherFocus.forceActiveFocus()
    modern.loginFailed()
    compare(input().text, ""); verify(input().activeFocus)
    verify(greeter.loginFailed)
    compare(input().Accessible.description, "Authentication failed")
    compare(findChild(greeter, "passwordStatus").Accessible.name, "Authentication failed")
    input().text = "retry"
    verify(!greeter.loginFailed)
  }

  function test_success_clears_sensitive_text_and_stops_submissions_data() {
    return [{tag: "partly typed", submit: false}, {tag: "password in flight", submit: true}]
  }
  function test_success_clears_sensitive_text_and_stops_submissions(data) {
    initialScan(); modern.fingerprintActiveChanged(true); input().text = "synthetic"
    if (data.submit) greeter.submitPassword()
    modern.loginSucceeded()
    verify(greeter.loginComplete); verify(!input().enabled)
    compare(input().text, ""); compare(greeter.submittedPassword, "")
    verify(!greeter.passwordBusy); verify(!greeter.fingerprintActive)
    modern.fingerprintActiveChanged(true); modern.loginFailed(); greeter.submitPassword()
    verify(!greeter.fingerprintActive); verify(!greeter.loginFailed)
    compare(modern.calls.length, data.submit ? 1 : 0)
  }

  function test_clear_and_invalid_selections_cancel_then_rearm() {
    initialScan(); input().text = "synthetic"; greeter.submitPassword()
    greeter.currentUser = ""
    compare(modern.scans.length, 2); compare(modern.scans[1].user, "")
    verify(!greeter.passwordBusy); compare(input().text, "")
    greeter.submitPassword(); compare(modern.calls.length, 1)
    greeter.currentUser = "another-fixture-user"
    compare(modern.scans.length, 3); compare(modern.scans[2].user, "another-fixture-user")
    input().text = "partial"
    for (var invalid of [-1, sessions.rowCount()]) {
      greeter.sessionIndex = invalid
      compare(modern.scans[modern.scans.length - 1].session, invalid)
      greeter.submitPassword(); verify(!greeter.passwordBusy)
    }
    compare(modern.calls.length, 1); compare(input().text, "partial")
    greeter.sessionIndex = 1
    compare(modern.scans[modern.scans.length - 1].session, 1)
    var scans = modern.scans.length
    greeter.armFingerprint(); compare(modern.scans.length, scans)
  }

  function test_capability_toggle_rearms_without_disturbing_password() {
    initialScan(); modern.fingerprintActiveChanged(true)
    modern.parallelFingerprint = false
    verify(!greeter.fingerprintActive); verify(!indicator().visible)
    input().text = "synthetic"; greeter.submitPassword()
    modern.parallelFingerprint = true
    compare(modern.scans.length, 2)
    verify(greeter.passwordBusy); compare(input().text, "synthetic")
    compare(modern.calls.length, 1)
    modern.parallelFingerprintChanged()
    compare(modern.scans.length, 2)
  }

  function test_disconnect_and_same_capability_signal_rearm_once() {
    initialScan(); modern.fingerprintActiveChanged(true)
    input().text = "synthetic"; greeter.submitPassword()
    modern.socketDisconnected()
    verify(!greeter.fingerprintActive); verify(!greeter.passwordBusy)
    compare(greeter.submittedPassword, ""); compare(input().text, "synthetic")
    modern.parallelFingerprintChanged()
    compare(modern.scans.length, 2); compare(modern.calls.length, 1)
    modern.parallelFingerprintChanged()
    compare(modern.scans.length, 2)
  }

  function test_selection_change_while_disconnected_rearms_latest_selection() {
    initialScan(); modern.connected = false; modern.socketDisconnected()
    greeter.currentUser = "another-fixture-user"
    greeter.sessionIndex = -1
    greeter.sessionIndex = 0
    input().text = "partial"
    input().forceActiveFocus(); keyClick(Qt.Key_Return)
    compare(modern.calls.length, 0); verify(!greeter.passwordBusy)
    verify(!greeter.fingerprintActive)
    compare(modern.scans.length, 1)
    modern.connected = true; modern.parallelFingerprintChanged()
    compare(modern.scans.length, 2)
    compare(modern.scans[1].user, "another-fixture-user")
    compare(modern.scans[1].session, 0)
    compare(input().text, "partial"); compare(modern.calls.length, 0)
    modern.parallelFingerprintChanged()
    compare(modern.scans.length, 2)
    keyClick(Qt.Key_Return)
    compare(modern.calls.length, 1)
    compare(modern.calls[0].password, "partial")
  }

  function test_reader_indicator_describes_actual_activity() {
    initialScan()
    verify(!indicator().visible)
    compare(indicator().Accessible.name, "Fingerprint reader inactive")
    input().text = "typed-before-reader-ready"
    modern.fingerprintActiveChanged(true)
    verify(indicator().visible)
    compare(input().text, "typed-before-reader-ready")
    compare(indicator().Accessible.name, "Fingerprint reader active")
    compare(indicator().opacity, 1)
    modern.fingerprintActiveChanged(false)
    verify(!indicator().visible)
    compare(indicator().Accessible.name, "Fingerprint reader inactive")
    verify(indicator().opacity < 1)
  }
}
