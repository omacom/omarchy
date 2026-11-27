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
  activeText: ""
  inactiveText: ""
  activeTooltipText: I18n.t("bar.disablePasswordlessLogin")
  inactiveTooltipText: I18n.t("bar.passwordlessLogin")
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

  // No polling: omarchy-setup-security-passwordless-login refreshes
  // omarchy.indicators on enable and disable.
  Connections {
    target: root.indicatorHost
    ignoreUnknownSignals: true
    function onRefreshRequested() { root.refresh() }
  }

  Process {
    id: statusProc
    command: ["omarchy-setup-security-passwordless-login", "--active"]
    onExited: function(exitCode, exitStatus) {
      root.granted = exitCode === 0 && exitStatus === 0
      if (root.refreshPending) Qt.callLater(root.refresh)
    }
  }

  onPressed: function() {
    if (!root.bar) return
    if (root.granted) root.bar.run("omarchy-launch-floating-terminal-with-presentation omarchy-setup-security-passwordless-login --disable")
    else root.bar.run("omarchy-launch-floating-terminal-with-presentation omarchy-setup-security-passwordless-login")
  }
}
