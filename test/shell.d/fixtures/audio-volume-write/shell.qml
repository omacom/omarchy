import QtQuick
import Quickshell
import qs.Commons

// Drives the audio panel's serialized pactl fallback: a slider value queued
// while a write is still running must be written once that write exits. The
// test's pactl stub logs each set-sink-volume and takes a while to finish.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  property var failures: []
  property var panel: null
  property int phase: 0
  property real deadline: 0

  function fail(message) {
    failures.push(String(message))
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function writeResult() {
    var payload = JSON.stringify({ ok: failures.length === 0, failures: failures })
    if (resultPath) Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
  }

  function finish() {
    poll.stop()
    writeResult()
  }

  function load() {
    var component = Qt.createComponent(rootPath + "/shell/plugins/panels/audio/Panel.qml", Component.PreferSynchronous)
    if (component.status !== Component.Ready) {
      fail("audio panel failed to load: " + component.errorString())
      return false
    }
    panel = component.createObject(host, {})
    if (!panel) {
      fail("audio panel failed to instantiate: " + component.errorString())
      return false
    }
    return true
  }

  Item { id: host }

  // Queue a first value; once its write is running, queue two more; then wait
  // for the queue to drain. Each phase waits on the panel's own state, so a
  // slow machine changes how long this takes, not what it checks.
  Timer {
    id: poll
    interval: 25
    running: true
    repeat: true
    onTriggered: {
      if (root.phase === 0) {
        if (!root.load()) return root.finish()
        root.deadline = Date.now() + 5000
        root.panel.queueOutputVolumeWrite("bluez_output.test", [20])
        root.phase = 1
        return
      }

      var state = root.panel.outputVolumeWriteState
      if (Date.now() > root.deadline) {
        root.fail("volume writes did not drain (phase " + root.phase + "): " + JSON.stringify(state))
        return root.finish()
      }

      if (root.phase === 1 && state.running) {
        root.panel.queueOutputVolumeWrite("bluez_output.test", [45])
        root.panel.queueOutputVolumeWrite("bluez_output.test", [80, 60])
        root.phase = 2
      } else if (root.phase === 2 && !state.running && state.pendingSink === "") {
        root.finish()
      }
    }
  }
}
