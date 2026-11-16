pragma Singleton
import QtQuick

// Stands in for Commons.NetworkVpn so the staged panel never reads the host's
// NetworkManager profiles or listens on its system bus.
QtObject {
  property var connections: []
  property var activeNames: []
  property bool active: false
  property string pendingUuid: ""
  property string pendingAction: ""
  property string failedUuid: ""
  property bool busy: false
  signal secretsRequested(string uuid)
  function toggle(uuid) {}
}
