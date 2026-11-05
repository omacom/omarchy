pragma Singleton
import QtQuick
import Quickshell.Networking

QtObject {
  id: mock
  property int backend: NetworkBackendType.NetworkManager
  property bool wifiEnabled: true
  property bool canCheckConnectivity: true
  property bool connectivityCheckEnabled: true
  property int connectivity: NetworkConnectivity.Full
  property int checks: 0
  function checkConnectivity() { checks++ }

  property QtObject devices: ListModel {
    property var values: [mock.wifi, mock.wired]
    Component.onCompleted: {
      append({ modelData: mock.wifi })
      append({ modelData: mock.wired })
    }
  }
  property QtObject wifi: QtObject {
    property int type: DeviceType.Wifi
    property string name: "test-wifi"
    property bool connected: true
    property bool nmManaged: true
    property int state: ConnectionState.Connected
    property bool scannerEnabled: false
    property var networks: ({ values: [network] })
  }
  property QtObject wired: QtObject {
    property int type: DeviceType.Wired
    property string name: "test-wired"
    property bool connected: false
    property bool nmManaged: true
    property int state: ConnectionState.Disconnected
    property bool hasLink: false
  }
  property QtObject network: QtObject {
    property string name: "Guest Wi-Fi"
    property bool connected: true
    property bool known: true
    property bool stateChanging: false
    property real signalStrength: 0.8
    property int security: WifiSecurityType.Open
    signal connectionFailed(int reason)
  }
}
