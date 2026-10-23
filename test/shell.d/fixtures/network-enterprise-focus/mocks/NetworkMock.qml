pragma Singleton
import QtQuick
import Quickshell.Networking

QtObject {
  property int backend: NetworkBackendType.NetworkManager
  property bool wifiEnabled: true
  property bool canCheckConnectivity: true
  property bool connectivityCheckEnabled: true
  property int connectivity: NetworkConnectivity.None
  function checkConnectivity() {}

  property var devices: ({ values: [wifi] })
  property QtObject wifi: QtObject {
    property int type: DeviceType.Wifi
    property string name: "test-wifi"
    property bool connected: false
    property bool scannerEnabled: false
    property var networks: ({ values: [corp, cafe] })
  }
  property QtObject corp: QtObject {
    property string name: "Corp"
    property bool connected: false
    property bool known: false
    property bool stateChanging: false
    property real signalStrength: 0.7
    property int security: WifiSecurityType.Wpa2Eap
    signal connectionFailed(int reason)
  }
  property QtObject cafe: QtObject {
    property string name: "Cafe"
    property bool connected: false
    property bool known: false
    property bool stateChanging: false
    property real signalStrength: 0.5
    property int security: WifiSecurityType.Open
    signal connectionFailed(int reason)
  }
}
