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

  Item { id: host }

  // The stub's write takes 400ms: queue the first value, then two more while
  // it runs, then wait well past both writes.
  property int step: 0
  Timer {
    interval: 150
    running: true
    repeat: true
    onTriggered: {
      root.step++
      if (root.step === 1) {
        var component = Qt.createComponent(root.rootPath + "/shell/plugins/panels/audio/Panel.qml", Component.PreferSynchronous)
        if (component.status !== Component.Ready) {
          root.fail("audio panel failed to load: " + component.errorString())
          stop()
          root.writeResult()
          return
        }
        root.panel = component.createObject(host, {})
        if (!root.panel) {
          root.fail("audio panel failed to instantiate: " + component.errorString())
          stop()
          root.writeResult()
          return
        }
        root.panel.queueOutputVolumeWrite("bluez_output.test", [20])
      } else if (root.step === 2) {
        root.panel.queueOutputVolumeWrite("bluez_output.test", [45])
        root.panel.queueOutputVolumeWrite("bluez_output.test", [80, 60])
      } else if (root.step === 12) {
        var state = root.panel.outputVolumeWriteState
        if (state.running || state.pendingSink !== "") root.fail("volume writes still queued: " + JSON.stringify(state))
        stop()
        root.writeResult()
      }
    }
  }
}
