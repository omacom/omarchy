pragma Singleton
import QtQuick

// Stands in for Commons.NetworkVpn so the staged panel never reads the host's
// VPNs, listens on its system bus or watches tailscaled.
QtObject {
  property var connections: []
  property var activeNames: []
  property bool active: false
  property string pendingId: ""
  property string pendingAction: ""
  property string failedId: ""
  property bool busy: false
  property string credentialsId: ""
  property string credentialsUser: ""
  property bool credentialsNeedUser: false
  signal handedToTerminal(string id)
  function toggle(connection) {}
  function submitCredentials(username, password) {}
  function cancelCredentials() { credentialsId = "" }
}
