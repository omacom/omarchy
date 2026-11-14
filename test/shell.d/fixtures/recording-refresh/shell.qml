import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
  id: root
  property var indicator: null
  property bool observedActive: false
  readonly property string stateDir: Quickshell.env("TEST_RECORDING_STATE")

  QtObject {
    id: host
    signal refreshRequested()
  }

  function finish(ok) {
    var result = Quickshell.env("OMARCHY_QML_TEST_RESULT")
    Quickshell.execDetached(["bash", "-c", "printf '%s' \"$1\" > \"$2\"", "result", JSON.stringify({ok: ok}), result])
  }

  Component.onCompleted: {
    var component = Qt.createComponent("file://" + Quickshell.env("OMARCHY_PATH") + "/shell/plugins/bar/indicators/ScreenRecording.qml")
    indicator = component.createObject(root, {indicatorHost: host})
    indicator.recordingChanged.connect(function() {
      if (indicator.recording) root.observedActive = true
      else if (root.observedActive) root.finish(true)
    })
    indicator.bar = ({})
    endRecorder.running = true
  }

  Process {
    id: endRecorder
    command: ["bash", "-c", "while [[ ! -e $1/observed ]]; do sleep 0.01; done; rm \"$1/active\"", "recorder", root.stateDir]
    onExited: {
      // The active result is still blocked when this exit refresh arrives.
      host.refreshRequested()
      releaseResult.running = true
    }
  }

  Process {
    id: releaseResult
    command: ["bash", "-c", "echo release > \"$1/release\"", "release", root.stateDir]
  }

  Timer {
    interval: 5000
    running: true
    onTriggered: root.finish(false)
  }
}
