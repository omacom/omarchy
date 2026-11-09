import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import qs.Commons
import qs.Commons as Commons
import "mocks"
import "network" as Network

// Drives the real network panel's Modify Network editor end to end through the
// paths the task binds on:
//   1. prefill a connected profile, change one field, Save runs exactly one
//      `nmcli connection modify` naming only that key for the resolved UUID;
//   2. an untouched Save sends nothing and does not reconnect;
//   3. a typed passphrase goes over `nmcli connection edit` stdin and never argv,
//      and the active profile is cycled with `connection up` so it takes effect;
//   4. an ipv4 change queues the modify and the same `connection up`;
//   5. a duplicate SSID with no active profile shows the picker, and choosing a
//      UUID opens the editor for that UUID.
//   6. a WPA2-Enterprise profile shows an editable password field that writes
//      802-1x.password over stdin (never argv), alongside its 802-1x.identity.
//
// The nmcli stub logs every invocation and, for `connection edit`, the stdin it
// read, to separate files; the fixture reads them back so the assertions are on
// the real argv/stdin the panel produced and that no secret reaches argv.
ShellRoot {
  id: test
  property bool failed: false
  readonly property string nmcliLog: Quickshell.env("NETWORK_TEST_NMCLI_LOG")
  readonly property string nmcliStdinLog: Quickshell.env("NETWORK_TEST_NMCLI_STDIN_LOG")
  readonly property string uuid: "11111111-1111-1111-1111-111111111111"
  readonly property string ambigUuid: "44444444-4444-4444-4444-444444444444"
  readonly property string eapUuid: "55555555-5555-5555-5555-555555555555"
  readonly property string secret: "s3cr3t pass"
  readonly property string eapIdentity: "alice@corp.example"
  readonly property string eapSecret: "eap s3cr3t"
  property string lastLog: ""
  property string stage: ""

  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  function linesOf(raw) {
    return String(raw || "").split("\n")
  }

  function countPrefix(lines, prefix) {
    var n = 0
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].indexOf(prefix) === 0) n++
    }
    return n
  }

  function hasLine(lines, exact) {
    for (var i = 0; i < lines.length; i++) {
      if (lines[i] === exact) return true
    }
    return false
  }

  // The row Model.wifiRow() would build for the connected KEMENKEU profile.
  property QtObject kemenkeu: QtObject {
    property string name: "KEMENKEU"
    property bool connected: true
    property bool known: true
    property bool stateChanging: false
    property real signalStrength: 0.9
    property int security: WifiSecurityType.Wpa2Psk
    signal connectionFailed(int reason)
    function forget() {}
  }

  // A known profile with two saved entries and neither active, so the resolver
  // reports it ambiguous and the editor must ask which one to edit.
  property QtObject ambig: QtObject {
    property string name: "AMBIG"
    property bool connected: false
    property bool known: true
    property bool stateChanging: false
    property real signalStrength: 0.5
    property int security: WifiSecurityType.Wpa2Psk
    signal connectionFailed(int reason)
    function forget() {}
  }

  // A WPA2-Enterprise row whose saved profile carries an 802.1X identity and
  // password the editor must let the user re-enter.
  property QtObject corp: QtObject {
    property string name: "CORP"
    property bool connected: false
    property bool known: true
    property bool stateChanging: false
    property real signalStrength: 0.7
    property int security: WifiSecurityType.Wpa2Eap
    signal connectionFailed(int reason)
    function forget() {}
  }

  Item {
    Network.Panel {
      id: panel
      bar: QtObject {
        property color foreground: Commons.Color.foreground
        property color barForeground: Commons.Color.foreground
        property color urgent: Commons.Color.urgent
        property string fontFamily: Style.font.family
        property string position: "top"
        property int barSize: 24
        property bool vertical: false
        property bool foregroundAnimationEnabled: false
        property var activePopout: null
        function requestPopout(owner) { activePopout = owner }
        function releasePopout(owner) { activePopout = null }
        function registerClickTarget(target) {}
        function unregisterClickTarget(target) {}
        function hideTooltip(target) {}
        function showTooltip(target, text) {}
      }
    }
  }

  Timer {
    interval: 250
    running: true
    onTriggered: {
      NetworkMock.wifi.networks = ({ values: [test.kemenkeu, test.ambig, test.corp] })
      panel.testEnsureContent()
      panel.open()
      Qt.callLater(test.start)
    }
  }

  // A stalled editor must fail loudly instead of hanging to the harness timeout.
  Timer {
    id: watchdog
    interval: 12000
    running: true
    onTriggered: {
      check(false, "timed out waiting for the editor to open, save, or pick")
      finish()
    }
  }

  function start() {
    check(panel.testContent !== null, "panel content builds")
    check(!!panel.testEditor, "editor builds with the content")
    if (failed) { finish(); return }
    openEditor("KEMENKEU", waitPrefill)
  }

  // Opens the editor and waits for the resolved profile read to land.
  function openEditor(ssid, onReady) {
    panel.openEditor(ssid)
    openWait.next = onReady
    openWait.restart()
  }

  Timer {
    id: openWait
    interval: 120
    repeat: true
    property var next: null
    onTriggered: {
      if (panel.editingUuid === "" && !panel.editorPicking) return
      stop()
      var fn = next
      next = null
      Qt.callLater(fn)
    }
  }

  // Waits for a Save to walk its process queue and close the editor.
  function afterSave(onDone) {
    saveWait.next = onDone
    saveWait.restart()
  }

  Timer {
    id: saveWait
    interval: 120
    repeat: true
    property var next: null
    onTriggered: {
      if (panel.editorOpen) return
      stop()
      var fn = next
      next = null
      Qt.callLater(fn)
    }
  }

  // ---------- Phase 0: change auto-connect, Save ----------

  function waitPrefill() {
    check(panel.editingUuid === test.uuid, "resolves the connected profile to its active uuid")
    check(panel.editorOpen === true, "the editor view is open")
    check(panel.editingSsid === "KEMENKEU", "the editor remembers the ssid it edits")
    var editor = panel.testEditor
    check(!!editor.fields, "the editor has prefilled fields")
    check(editor.fields && editor.fields.autoConnect === true, "prefills auto-connect yes")
    check(editor.fields && editor.fields.ipv4Method === "auto", "prefills ipv4.method auto")
    check(editor.form && editor.form.autoConnect === true, "the form starts from the prefill")
    if (failed) { finish(); return }
    editor.update("autoConnect", false)
    check(editor.form.autoConnect === false, "the toggle flips the form value")
    editor.submit()
    afterSave(readChangedLog)
  }

  function readChangedLog() {
    stage = "changed"
    logProc.running = true
  }

  // ---------- Phase 1: untouched form, Save sends nothing ----------

  function checkChanged(lines) {
    check(countPrefix(lines, "connection modify") === 1, "exactly one nmcli connection modify runs")
    check(hasLine(lines, "connection modify uuid " + test.uuid + " connection.autoconnect no"),
      "the modify argv carries only the changed key for the resolved uuid")
    check(countPrefix(lines, "connection up") === 0, "an auto-connect change alone does not reconnect")
    if (failed) { finish(); return }
    openEditor("KEMENKEU", noopSave)
  }

  function noopSave() {
    var editor = panel.testEditor
    check(editor.form.autoConnect === true, "the reopened form prefills the saved value")
    if (failed) { finish(); return }
    editor.submit()
    afterSave(readNoopLog)
  }

  function readNoopLog() {
    stage = "noop"
    logProc.running = true
  }

  // ---------- Phase 2: passphrase over stdin, active profile cycles ----------

  function checkNoop(lines) {
    check(countPrefix(lines, "connection modify") === 1, "an untouched Save runs no additional modify")
    check(countPrefix(lines, "connection up") === 0, "an untouched Save does not reconnect")
    if (failed) { finish(); return }
    openEditor("KEMENKEU", passphraseSave)
  }

  function passphraseSave() {
    var editor = panel.testEditor
    editor.update("password", test.secret)
    editor.submit()
    afterSave(readPassphraseLog)
  }

  function readPassphraseLog() {
    stage = "passphrase"
    logProc.running = true
  }

  function checkPassphrase(lines) {
    lastLog = lines.join("\n")
    stdinProc.running = true
  }

  function checkPassphraseStdin(text) {
    var lines = linesOf(lastLog)
    var stdinLines = linesOf(text)
    check(hasLine(stdinLines, "set 802-11-wireless-security.psk"),
      "the passphrase is set through nmcli's interactive value prompt")
    check(hasLine(stdinLines, test.secret),
      "the passphrase value, spaces and all, is written verbatim on its own stdin line")
    check(String(lastLog).indexOf(test.secret) === -1, "the passphrase never appears in nmcli argv")
    // A passphrase write edits the profile without activating it, so the live
    // link keeps running on the old key unless the active profile is cycled.
    check(countPrefix(lines, "connection up") === 1, "a passphrase change on the active profile reconnects")
    check(hasLine(lines, "connection up uuid " + test.uuid), "the reconnect targets the edited uuid")
    if (failed) { finish(); return }
    openEditor("KEMENKEU", ipv4Save)
  }

  // ---------- Phase 3: ipv4 change queues modify + reconnect ----------

  function ipv4Save() {
    var editor = panel.testEditor
    editor.update("ipv4Method", "manual")
    editor.update("address", "10.0.0.5/24")
    check(editor.validation.ok === true, "a manual CIDR is valid")
    if (failed) { finish(); return }
    editor.submit()
    afterSave(readIpv4Log)
  }

  function readIpv4Log() {
    stage = "ipv4"
    logProc.running = true
  }

  function checkIpv4(lines) {
    check(countPrefix(lines, "connection modify") === 2, "the ipv4 change queues another modify")
    check(hasLine(lines, "connection modify uuid " + test.uuid + " ipv4.method manual ipv4.addresses 10.0.0.5/24"),
      "the ipv4 modify carries only the changed keys")
    check(countPrefix(lines, "connection up") === 2, "an ipv4 change on the active profile reconnects")
    if (failed) { finish(); return }
    openEditor("AMBIG", checkPicker)
  }

  // ---------- Phase 4: duplicate SSID → picker → chosen UUID ----------

  function checkPicker() {
    var editor = panel.testEditor
    check(panel.editorPicking === true, "a duplicate SSID with no active profile shows the picker")
    check(editor.picking === true, "the editor switches to the picker view")
    check((editor.choices || []).length === 2, "the picker lists both saved profiles")
    check(panel.editingUuid === "", "the editor does not resolve a uuid until one is chosen")
    if (failed) { finish(); return }
    editor.choose(test.ambigUuid)
    openWait.next = checkChosen
    openWait.restart()
  }

  function checkChosen() {
    check(panel.editorPicking === false, "choosing a profile leaves the picker")
    check(panel.editingUuid === test.ambigUuid, "the editor reads the chosen profile's uuid")
    check(!!panel.testEditor.fields, "the chosen profile's settings prefill the form")
    if (failed) { finish(); return }
    openEditor("KEMENKEU", typePassphrase)
  }

  // ---------- Phase 5: a typed passphrase does not survive into the next edit ----------

  function typePassphrase() {
    var field = test.passwordField()
    check(!!field, "the passphrase field is reachable")
    if (field) field.text = test.secret
    check(!!field && field.text === test.secret, "the passphrase field shows the typed value")
    if (failed) { finish(); return }
    openEditor("KEMENKEU", checkFieldCleared)
  }

  function checkFieldCleared() {
    var field = test.passwordField()
    check(!!field && field.text === "", "reopening the editor clears the stale passphrase from the field")
    if (failed) { finish(); return }
    openEditor("CORP", eapOpened)
  }

  // ---------- Phase 6: an EAP profile offers an editable password ----------

  function eapOpened() {
    var editor = panel.testEditor
    check(panel.editingUuid === test.eapUuid, "resolves the EAP profile to its uuid")
    check(editor.enterprise === true, "a WPA2-Enterprise profile opens as enterprise")
    var field = test.passwordField()
    check(!!field && !!field.parent && field.parent.visible === true,
      "the password field is visible for an enterprise profile")
    check(editor.form && editor.form.identity === "", "the EAP identity starts blank")
    if (failed) { finish(); return }
    field.text = test.eapSecret
    check(editor.form.password === test.eapSecret, "typing in the EAP password field reaches the form")
    editor.update("identity", test.eapIdentity)
    editor.submit()
    afterSave(readEapArgv)
  }

  function readEapArgv() {
    stage = "eap"
    logProc.running = true
  }

  function checkEapArgv(lines) {
    lastLog = lines.join("\n")
    check(String(lastLog).indexOf(test.eapSecret) === -1, "the EAP password never appears in nmcli argv")
    check(String(lastLog).indexOf(test.eapIdentity) === -1, "the EAP identity never appears in nmcli argv")
    stdinEapProc.running = true
  }

  function checkEapStdin(text) {
    var stdinLines = linesOf(text)
    check(countPrefix(stdinLines, "set 802-1x.password") === 1,
      "the EAP password is set through nmcli's interactive value prompt")
    check(hasLine(stdinLines, test.eapSecret),
      "the EAP password is written verbatim on its own stdin line")
    check(countPrefix(stdinLines, "set 802-1x.identity") === 1,
      "the EAP identity change uses the same interactive prompt")
    check(hasLine(stdinLines, test.eapIdentity),
      "the EAP identity is written verbatim on its own stdin line")
    finish()
  }

  // Locates the passphrase TextField by the objectName the staging adds, so the
  // fixture can prove the visible field is emptied between edit sessions.
  function passwordField() {
    return test.findObject(panel.testEditor, "pskField")
  }

  function findObject(obj, name) {
    if (!obj) return null
    if (obj.objectName === name) return obj
    var kids = obj.children || []
    for (var i = 0; i < kids.length; i++) {
      var found = test.findObject(kids[i], name)
      if (found) return found
    }
    return null
  }

  // ---------- Log readers ----------

  Process {
    id: logProc
    command: ["cat", test.nmcliLog]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var lines = test.linesOf(text)
        if (test.stage === "changed") test.checkChanged(lines)
        else if (test.stage === "noop") test.checkNoop(lines)
        else if (test.stage === "passphrase") test.checkPassphrase(lines)
        else if (test.stage === "ipv4") test.checkIpv4(lines)
        else if (test.stage === "eap") test.checkEapArgv(lines)
      }
    }
  }

  Process {
    id: stdinProc
    command: ["cat", test.nmcliStdinLog]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: test.checkPassphraseStdin(text)
    }
  }

  Process {
    id: stdinEapProc
    command: ["cat", test.nmcliStdinLog]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: test.checkEapStdin(text)
    }
  }

  function finish() {
    watchdog.stop()
    console.log(failed ? "RESULT fail" : "RESULT pass")
    Qt.quit()
  }
}
