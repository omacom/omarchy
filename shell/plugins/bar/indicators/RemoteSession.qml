import QtQuick
import qs.Commons as Commons
import qs.Ui

BarIndicator {
  id: root

  readonly property var remoteSessionService: bar?.shell?.firstPartyServiceFor("omarchy.remote-session")
  readonly property var peers: remoteSessionService && Array.isArray(remoteSessionService.peers) ? remoteSessionService.peers : []

  active: remoteSessionService ? remoteSessionService.active : false
  activeText: "󰢹"
  inactiveText: "󰢹"
  activeTooltipText: peers.length > 0 ? "Remote session from " + peers.join(", ") : "Remote session"
  inactiveTooltipText: "Remote Session"
  useActiveColor: true
  activeColor: Commons.Color.urgent

  Connections {
    target: root.indicatorHost
    ignoreUnknownSignals: true
    function onRefreshRequested() {
      if (root.remoteSessionService) root.remoteSessionService.refresh()
    }
  }
}
