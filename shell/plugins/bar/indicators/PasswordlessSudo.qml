import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

BarIndicator {
  id: root

  property bool granted: false

  visible: effectiveActive || inactiveRevealed
  active: granted
  activeText: "󰀦"
  inactiveText: "󰟵"
  activeTooltipText: "Danger: Passwordless sudo is enabled. Click to disable."
  inactiveTooltipText: "Passwordless Sudo"
  useActiveColor: true
  activeColor: Color.urgent

  function refresh() {
    if (!root.bar || statusProc.running) return
    statusProc.running = true
  }

  onBarChanged: refresh()
  Component.onCompleted: refresh()

  Connections {
    target: root.indicatorHost
    ignoreUnknownSignals: true
    function onRefreshRequested() { root.refresh() }
  }

  Timer {
    interval: 5000
    repeat: true
    running: !!root.bar
    onTriggered: root.refresh()
  }

  Process {
    id: statusProc
    command: ["omarchy-sudo-passwordless", "--active"]
    onExited: function(exitCode, exitStatus) {
      root.granted = exitCode === 0 && exitStatus === 0
    }
  }

  onPressed: function() {
    if (root.bar) root.bar.run("omarchy-launch-floating-terminal-with-presentation omarchy-sudo-passwordless" + (root.granted ? " --disable" : ""))
  }
}
