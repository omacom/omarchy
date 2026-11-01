import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  required property bool secure
  property bool ready: false
  readonly property int minRetryDelay: 1000
  readonly property int maxRetryDelay: 60000
  property int retryDelay: minRetryDelay

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
          root.retryDelay = root.minRetryDelay
          root.publishLockState()
        }
      }
    }
    onExited: function(exitCode) {
      root.ready = false
      // A bridge that keeps failing must not cost the shell a spawn every second.
      if (exitCode !== 0) {
        retryTimer.interval = root.retryDelay
        retryTimer.restart()
        root.retryDelay = Math.min(root.retryDelay * 2, root.maxRetryDelay)
      }
    }
  }

  Timer {
    id: retryTimer
    onTriggered: bridgeProcess.running = true
  }
}
