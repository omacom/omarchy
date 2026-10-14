pragma Singleton
import QtQuick
import Quickshell.Networking

// Wi-Fi is present but not connected, so the modem is the only way out and
// the bar falls back to it.
QtObject {
  property int backend: NetworkBackendType.NetworkManager
  property bool wifiEnabled: true
  property bool canCheckConnectivity: true
  property bool connectivityCheckEnabled: true
  property int connectivity: NetworkConnectivity.Full
  function checkConnectivity() {}

  property var devices: ({ values: [wifi] })
  property QtObject wifi: QtObject {
    property int type: DeviceType.Wifi
    property string name: "test-wifi"
    property bool connected: false
    property bool scannerEnabled: false
    property var networks: ({ values: [network] })
  }
  property QtObject network: QtObject {
    property string name: "Cafe Wi-Fi"
    property bool connected: false
    property bool known: false
    property bool stateChanging: false
    property real signalStrength: 0.6
    property int security: WifiSecurityType.Open
    signal connectionFailed(int reason)
  }
}
