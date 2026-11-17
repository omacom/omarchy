pragma Singleton
import QtQuick
import Quickshell
import "NetworkVpnModel.js" as Model
import "VpnNetworkManagerModel.js" as NetworkManagerModel
import "VpnTailscaleModel.js" as TailscaleModel

// Every VPN configured on this machine, kept once for the whole shell rather
// than per bar widget. Each source of VPNs is a provider:
//
//   VpnNetworkManager  NetworkManager's VPN and WireGuard profiles
//   VpnTailscale       Tailscale, driven by its own bar widget
//
// A provider has `provider` (its name), `connections` (its VPNs, shaped as
// NetworkVpnModel.js describes) and `toggle(id)`. Another source of VPNs is
// another provider added to `providers`.
Singleton {
  id: root

  VpnNetworkManager {
    id: networkManager
    onRead: function(raw) { tailscale.deviceSeen(NetworkManagerModel.hasDevice(raw, TailscaleModel.device, "tun")) }
  }

  VpnTailscale {
    id: tailscale
  }

  readonly property var providers: [networkManager, tailscale]

  // Every provider's VPNs, including any a panel doesn't list.
  readonly property var all: Model.mergeConnections(providers.map(function(provider) { return provider.connections }))
  // The VPNs the network panel lists. Republished only when they really
  // change, since a new list rebuilds the panel's rows, and with them a
  // prompt being typed into.
  property var connections: []
  property string connectionsSignature: "[]"
  function publish() {
    var next = all.filter(function(connection) { return connection.listed !== false })
    var signature = JSON.stringify(next)
    if (signature === connectionsSignature) return
    connectionsSignature = signature
    connections = next
  }
  onAllChanged: publish()
  Component.onCompleted: publish()
  readonly property var activeNames: Model.activeVpnNames(all)
  readonly property bool active: activeNames.length > 0

  // Progress of a connect or disconnect started from the shell.
  readonly property string pendingId: networkManager.pendingId
  readonly property string pendingAction: networkManager.pendingAction
  readonly property string failedId: networkManager.failedId
  readonly property bool busy: networkManager.busy

  // The VPN the panel is asking a user name and password for.
  readonly property string credentialsId: networkManager.credentialsId
  readonly property string credentialsUser: networkManager.credentialsUser
  readonly property bool credentialsNeedUser: networkManager.credentialsNeedUser

  // A connect moved to a terminal; whatever holds keyboard focus over it (the
  // network panel) should let go.
  signal handedToTerminal(string id)

  Connections {
    target: networkManager
    function onHandedToTerminal(id) { root.handedToTerminal(id) }
  }

  function providerFor(connection) {
    for (var i = 0; i < providers.length; i++) {
      if (connection && providers[i].provider === connection.provider) return providers[i]
    }
    return null
  }

  // Connects or disconnects a VPN. One that `opens` a bar widget is handled
  // there instead; the caller opens it.
  function toggle(connection) {
    var provider = providerFor(connection)
    if (provider) provider.toggle(connection.id)
  }

  function submitCredentials(username, password) { networkManager.submitCredentials(username, password) }
  function cancelCredentials() { networkManager.cancelCredentials() }

  // Nothing here is needed while the shell draws its first frames, and every
  // process started then competes with the bar and the lock being built, so
  // listening starts a moment later.
  Timer {
    interval: 1000
    running: true
    onTriggered: networkManager.start()
  }
}
