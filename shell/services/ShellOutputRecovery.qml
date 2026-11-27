import QtQuick
import Quickshell
import Quickshell.Io
import "OutputRecovery.js" as OutputRecovery

Item {
  id: root

  required property string omarchyPath
  property bool enabled: false
  property var screenNames: Quickshell.screens.map(function(screen) { return screen.name })
  property var recoveryState: OutputRecovery.initialState()

  function observeOutputs() {
    recoveryState = OutputRecovery.update(recoveryState || OutputRecovery.initialState(), screenNames)
  }
  onScreenNamesChanged: observeOutputs()
  Component.onCompleted: observeOutputs()

  // After all outputs disappear, stale surfaces can stop mapping while IPC
  // and heartbeat timers still work. Let the returning output settle before
  // requesting recovery; the helper defers while locked or undetermined.
  Timer {
    interval: 10000
    repeat: true
    running: root.enabled && root.recoveryState.pending && root.recoveryState.connected
    onTriggered: if (!recovery.running) recovery.running = true
  }

  Process {
    id: recovery
    command: [root.omarchyPath + "/bin/omarchy-shell-recover-outputs"]
  }
}
