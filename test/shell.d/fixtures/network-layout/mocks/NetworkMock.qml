pragma Singleton
import QtQuick
import Quickshell.Networking

QtObject {
  property int backend: NetworkBackendType.NetworkManager
  property bool wifiEnabled: true
  property bool canCheckConnectivity: true
  property bool connectivityCheckEnabled: true
  property int connectivity: NetworkConnectivity.Full
  property int checks: 0
  function checkConnectivity() { checks++ }

  property QtObject guest: QtObject {
    property string name: "Guest Wi-Fi"
    property bool connected: true
    property bool known: true
    property bool stateChanging: false
    property real signalStrength: 0.8
    property int security: WifiSecurityType.Wpa2Psk
    property int connectCalls: 0
    function connect() { connectCalls++ }
    function connectWithPsk(passphrase) { connectCalls++ }
    function disconnect() {}
    function forget() {}
    signal connectionFailed(int reason)
  }

  property QtObject cafe: QtObject {
    property string name: "Cafe"
    property bool connected: false
    property bool known: true
    property bool stateChanging: false
    property real signalStrength: 0.5
    property int security: WifiSecurityType.Wpa2Psk
    property int connectCalls: 0
    function connect() { connectCalls++ }
    function connectWithPsk(passphrase) { connectCalls++ }
    function disconnect() {}
    function forget() {}
    signal connectionFailed(int reason)
  }

  property QtObject openNet: QtObject {
    property string name: "TownHall"
    property bool connected: false
    property bool known: false
    property bool stateChanging: false
    property real signalStrength: 0.3
    property int security: WifiSecurityType.Open
    property int connectCalls: 0
    function connect() { connectCalls++ }
    function connectWithPsk(passphrase) { connectCalls++ }
    function disconnect() {}
    function forget() {}
    signal connectionFailed(int reason)
  }

  property var devices: ({ values: [wifi] })
  property QtObject wifi: QtObject {
    property int type: DeviceType.Wifi
    property string name: "test-wifi"
    property bool connected: true
    property bool scannerEnabled: false
    property var networks: ({ values: [guest, cafe, openNet] })
  }
}
