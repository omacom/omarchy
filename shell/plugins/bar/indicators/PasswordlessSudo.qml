import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui

BarIndicator {
  id: root

  property bool granted: false
  property bool refreshPending: false

  active: granted
  activeText: "󰟵"
  inactiveText: "󰟵"
  activeTooltipText: "Disable Passwordless Sudo"
  inactiveTooltipText: "Passwordless Sudo"
  useActiveColor: true
  activeColor: Commons.Color.urgent

  function refresh() {
    if (!root.bar) return
    if (statusProc.running) {
      root.refreshPending = true
      return
    }
    root.refreshPending = false
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
      if (root.refreshPending) Qt.callLater(root.refresh)
    }
  }

  Process {
    id: disableProc
    command: ["omarchy-sudo-passwordless", "--disable"]
    onExited: function(exitCode, exitStatus) {
      if ((exitCode !== 0 || exitStatus !== 0) && root.bar)
        root.bar.run('omarchy-notification-send "Could not disable passwordless sudo" "Check the sudo configuration and try again."')
      if (root.indicatorHost) root.indicatorHost.refresh()
      else root.refresh()
    }
  }

  onPressed: function() {
    if (!root.bar || disableProc.running) return
    if (root.granted) disableProc.running = true
    else root.bar.run("omarchy-launch-floating-terminal-with-presentation omarchy-sudo-passwordless")
  }
}
