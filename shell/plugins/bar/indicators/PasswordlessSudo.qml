import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui

BarIndicator {
  id: root

  readonly property bool granted: PasswordlessSudoStatus.granted

  active: granted
  activeText: "󰟵"
  inactiveText: "󰟵"
  activeTooltipText: "Disable Passwordless Sudo"
  inactiveTooltipText: "Passwordless Sudo"
  useActiveColor: true
  activeColor: Commons.Color.urgent

  function refresh() {
    PasswordlessSudoStatus.refresh()
  }

  Connections {
    target: root.indicatorHost
    ignoreUnknownSignals: true
    function onRefreshRequested() { root.refresh() }
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
