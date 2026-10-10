import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  required property bool secure
  property bool ready: false

  function publishLockState() {
    if (ready && bridgeProcess.running) {
      bridgeProcess.write((secure ? "true" : "false") + "\n")
    }
  }

  onSecureChanged: publishLockState()

  Process {
    id: bridgeProcess
    command: ["python3", Quickshell.env("OMARCHY_PATH") + "/shell/plugins/lock/session-lock-bridge.py"]
    stdinEnabled: true
    running: true
    stdout: SplitParser {
      onRead: function(line) {
        if (line === "ready") {
          root.ready = true
          root.publishLockState()
        }
      }
    }
    onExited: function(exitCode) {
      root.ready = false
      if (exitCode !== 0) retryTimer.restart()
    }
  }

  Timer {
    id: retryTimer
    interval: 1000
    onTriggered: bridgeProcess.running = true
  }
}
