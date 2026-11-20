import QtQuick
import Quickshell
import Quickshell.Io
import "services"

ShellRoot {
  id: root
  property int phase: 0
  property real connectedAt: 0
  property bool finished: false

  ShellOutputRecovery {
    id: recovery
    omarchyPath: Quickshell.env("OMARCHY_PATH")
    enabled: true
    screenNames: []
  }

  FileView {
    id: queue
    path: Quickshell.env("OMARCHY_TEST_RECOVERY_QUEUE")
    watchChanges: true
    onFileChanged: reload()
    onLoaded: if (queue.text().length > 0 && !root.finished) {
      root.finished = true
      var elapsed = Date.now() - root.connectedAt
      result.setText(JSON.stringify({ok: root.phase === 2 && elapsed >= 9700, elapsed: elapsed}))
    }
  }

  FileView { id: result; path: Quickshell.env("OMARCHY_QML_TEST_RESULT") }

  Component.onCompleted: {
    recovery.screenNames = ["DP-3"]
    recovery.screenNames = [""]
  }

  Timer {
    interval: 500
    running: true
    repeat: true
    onTriggered: {
      if (root.phase === 0) {
        if (!recovery.recoveryState.pending || recovery.recoveryState.connected) {
          result.setText(JSON.stringify({ok: false, error: "output loss did not arm recovery"}))
          stop()
        } else {
          root.phase = 1
        }
      } else if (root.phase === 1) {
        root.phase = 2
        root.connectedAt = Date.now()
        recovery.screenNames = ["DP-3"]
        stop()
      }
    }
  }
}
