pragma Singleton
import QtQuick
import Quickshell.Networking

// A saved hotspot that has just come back into range: Quickshell lists it
// before NetworkManager attaches its profile, so it starts out unknown.
QtObject {
  property int backend: NetworkBackendType.NetworkManager
  property bool wifiEnabled: true
  property bool canCheckConnectivity: false
  property bool connectivityCheckEnabled: false
  property int connectivity: NetworkConnectivity.Full
  function checkConnectivity() {}

  property var devices: ({ values: [wifi] })
  property QtObject wifi: QtObject {
    property int type: DeviceType.Wifi
    property string name: "test-wifi"
    property bool connected: true
    property bool scannerEnabled: false
    property var networks: ({ values: [cafe, neighbor, hotspot] })
  }
  property QtObject cafe: QtObject {
    property string name: "Cafe"
    property bool connected: true
    property bool known: true
    property bool stateChanging: false
    property real signalStrength: 0.8
    property int security: WifiSecurityType.Wpa2Psk
    signal connectionFailed(int reason)
  }
  property QtObject neighbor: QtObject {
    property string name: "Neighbor"
    property bool connected: false
    property bool known: false
    property bool stateChanging: false
    property real signalStrength: 0.9
    property int security: WifiSecurityType.Wpa2Psk
    signal connectionFailed(int reason)
  }
  property QtObject hotspot: QtObject {
    property string name: "Phone Hotspot"
    property bool connected: false
    property bool known: false
    property bool stateChanging: false
    property real signalStrength: 0.4
    property int security: WifiSecurityType.Wpa2Psk
    property int connects: 0
    signal connectionFailed(int reason)
    function connect() { connects++ }
  }
}
