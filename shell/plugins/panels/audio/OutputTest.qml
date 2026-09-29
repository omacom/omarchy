import QtQuick
import Quickshell.Io

Item {
  id: root

  property string target: ""
  property bool available: false
  readonly property bool running: playback.running
  property string error: ""
  property bool expectedStop: false

  function start() {
    if (!available || !target || running) return
    error = ""
    expectedStop = false
    // Use the selected sink, including any speaker tuning or effects, and
    // never fall back to another output if it disappears. alsa-utils ships
    // this short spoken sample as part of Omarchy's base package set.
    playback.command = [
      "pw-play", "--target", target, "--volume", "0.5",
      "--properties", "application.name=\"Output test\" media.name=\"Output test\" node.dont-fallback=true node.dont-reconnect=true",
      "/usr/share/sounds/alsa/Front_Center.wav"
    ]
    playback.running = true
  }

  function stop() {
    expectedStop = true
    deadline.stop()
    playback.running = false
  }

  function toggle() {
    if (running) stop()
    else start()
  }

  onTargetChanged: {
    stop()
    error = ""
  }
  onAvailableChanged: if (!available) stop()
  Component.onDestruction: stop()

  Process {
    id: playback
    onStarted: {
      if (!root.available || root.expectedStop) root.stop()
      else deadline.restart()
    }
    onExited: function(exitCode, exitStatus) {
      deadline.stop()
      if (!root.expectedStop && (exitCode !== 0 || exitStatus !== 0))
        root.error = "Could not test output. Try again."
    }
  }

  // Bound a test whose output never becomes ready as well as normal playback.
  Timer {
    id: deadline
    interval: 10000
    onTriggered: root.stop()
  }
}
