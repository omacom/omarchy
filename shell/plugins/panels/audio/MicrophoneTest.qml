import QtQuick
import Quickshell.Io

Item {
  id: root

  property string target: ""
  property bool available: false
  readonly property bool running: capture.running
  property string error: ""
  property bool expectedStop: false
  property string captureTarget: ""

  function start() {
    if (!available || !target || running) return
    error = ""
    expectedStop = false
    captureTarget = target
    // A peak monitor alone cannot activate a Bluetooth microphone. Open a
    // real capture stream, discard its samples, and let WirePlumber select
    // and restore the headset profile. Never fall back to another device.
    capture.command = [
      "pw-record", "--target", target, "--media-role", "Communication",
      "--properties", "node.dont-fallback=true node.dont-reconnect=true",
      "--raw", "/dev/null"
    ]
    capture.running = true
  }

  function stop() {
    expectedStop = true
    deadline.stop()
    sourceLost.stop()
    capture.running = false
  }

  function toggle() {
    if (running) stop()
    else start()
  }

  onTargetChanged: {
    error = ""
    if (!running) return
    // The default-source binding can briefly disappear while Bluetooth
    // switches profiles. Keep the original target through that transition;
    // a different selected source still stops the test immediately.
    if (!target) sourceLost.restart()
    else if (target !== captureTarget) stop()
    else sourceLost.stop()
  }
  onAvailableChanged: if (!available) stop()
  Component.onDestruction: stop()

  Process {
    id: capture
    onStarted: {
      // Closing the panel can race process startup.
      if (!root.available || root.expectedStop) root.stop()
      else deadline.restart()
    }
    onExited: {
      deadline.stop()
      sourceLost.stop()
      if (!root.expectedStop) root.error = "Could not test microphone. Try again."
    }
  }

  Timer {
    id: deadline
    interval: 30000
    onTriggered: root.stop()
  }

  Timer {
    id: sourceLost
    interval: 1000
    onTriggered: root.stop()
  }
}
