pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Grant status belongs to the session, not to each monitor or active/inactive
// indicator view. This exposes only the noninteractive policy probe; enabling
// and revoking grants still go through the existing command's authorization.
Singleton {
  id: root

  readonly property bool granted: statusProc.granted
  property bool refreshPending: false

  function refresh() {
    // Every indicator hears a tray refresh. Fold that burst into one probe.
    refreshDebounce.start()
  }

  function runRefresh() {
    if (statusProc.running) {
      root.refreshPending = true
      return
    }
    root.refreshPending = false
    statusProc.running = true
  }

  Timer {
    id: refreshDebounce
    interval: 0
    onTriggered: root.runRefresh()
  }

  Timer {
    interval: 5000
    repeat: true
    running: true
    onTriggered: root.refresh()
  }

  Process {
    id: statusProc
    property bool granted: false
    command: ["omarchy-sudo-passwordless", "--active"]
    onExited: function(exitCode, exitStatus) {
      statusProc.granted = exitCode === 0 && exitStatus === 0
      // A revoke can finish while a previous probe is in flight. Its result
      // must be followed by a fresh reading rather than swallowing the nudge.
      if (root.refreshPending) root.refresh()
    }
  }

  Component.onCompleted: refresh()
}
