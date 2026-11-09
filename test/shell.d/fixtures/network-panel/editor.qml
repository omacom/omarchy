import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import qs.Commons
import qs.Commons as Commons
import "mocks"
import "network" as Network

// Drives the real network panel's Modify Network editor end to end: the menu's
// Modify action is reached through openEditor(), the profile is read back with
// nmcli against a stub, the form prefills from it, a Save of one changed field
// runs exactly one `nmcli connection modify` with only that key, and a second,
// untouched Save sends nothing.
//
// The nmcli stub logs every invocation to NETWORK_TEST_NMCLI_LOG; the fixture
// reads it back so the assertions are on the real argv the panel ran, and checks
// that no argument carries a secret.
ShellRoot {
  id: test
  property bool failed: false
  readonly property string nmcliLog: Quickshell.env("NETWORK_TEST_NMCLI_LOG")
  readonly property string uuid: "11111111-1111-1111-1111-111111111111"

  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
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
      NetworkMock.wifi.networks = ({ values: [test.kemenkeu] })
      panel.testEnsureContent()
      panel.open()
      Qt.callLater(test.start)
    }
  }

  // A stalled editor must fail loudly instead of hanging to the harness timeout.
  Timer {
    id: watchdog
    interval: 8000
    running: true
    onTriggered: {
      check(false, "timed out waiting for the editor to open and save")
      finish()
    }
  }

  function start() {
    check(panel.testContent !== null, "panel content builds")
    check(!!panel.testEditor, "editor builds with the content")
    if (failed) { finish(); return }
    panel.openEditor("KEMENKEU")
    waitTimer.start()
  }

  // ---------- Phase 1: change auto-connect, Save ----------

  Timer {
    id: waitTimer
    interval: 120
    repeat: true
    onTriggered: {
      if (panel.editingUuid === "") return
      waitTimer.stop()
      Qt.callLater(test.checkPrefill)
    }
  }

  function checkPrefill() {
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
    saveTimer.start()
  }

  Timer {
    id: saveTimer
    interval: 120
    repeat: true
    onTriggered: {
      if (panel.editorOpen) return
      saveTimer.stop()
      readLog.running = true
    }
  }

  Process {
    id: readLog
    command: ["cat", test.nmcliLog]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: test.checkChangedSave(text)
    }
  }

  function checkChangedSave(raw) {
    var lines = String(raw || "").split("\n")
    var modify = []
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].indexOf("connection modify") === 0) modify.push(lines[i])
    }
    check(modify.length === 1, "exactly one nmcli connection modify runs")
    check(modify[0] === "connection modify uuid " + test.uuid + " connection.autoconnect no",
      "the modify argv carries only the changed key for the resolved uuid, got: " + modify[0])
    if (failed) { finish(); return }
    panel.openEditor("KEMENKEU")
    waitTimer2.start()
  }

  // ---------- Phase 2: untouched form, Save sends nothing ----------

  Timer {
    id: waitTimer2
    interval: 120
    repeat: true
    onTriggered: {
      if (panel.editingUuid === "") return
      waitTimer2.stop()
      Qt.callLater(test.noopSave)
    }
  }

  function noopSave() {
    var editor = panel.testEditor
    check(editor.form.autoConnect === true, "the reopened form prefills the saved value")
    if (failed) { finish(); return }
    editor.submit()
    saveTimer2.start()
  }

  Timer {
    id: saveTimer2
    interval: 120
    repeat: true
    onTriggered: {
      if (panel.editorOpen) return
      saveTimer2.stop()
      readLog2.running = true
    }
  }

  Process {
    id: readLog2
    command: ["cat", test.nmcliLog]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: test.checkNoopSave(text)
    }
  }

  function checkNoopSave(raw) {
    var lines = String(raw || "").split("\n")
    var modify = 0
    var up = 0
    var secret = false
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].indexOf("connection modify") === 0) modify++
      if (lines[i].indexOf("connection up") === 0) up++
      if (/psk|password/i.test(lines[i])) secret = true
    }
    check(modify === 1, "an untouched Save runs no additional modify")
    check(up === 0, "an untouched Save does not reconnect")
    check(secret === false, "no nmcli argument carries a secret")
    finish()
  }

  function finish() {
    watchdog.stop()
    console.log(failed ? "RESULT fail" : "RESULT pass")
    Qt.quit()
  }
}
