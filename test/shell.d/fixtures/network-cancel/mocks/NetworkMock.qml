pragma Singleton
import QtQuick
import Quickshell.Networking

// Stands in for the Quickshell.Networking NetworkManager backend, and mirrors
// the frontend guards that backend puts in front of its methods. Those guards
// are the whole point of this fixture: a panel change that reaches for an API
// the real shell would refuse has to fail here too, or the fix is only
// cosmetic.
QtObject {
  property int backend: NetworkBackendType.NetworkManager
  property bool wifiEnabled: true
  property bool canCheckConnectivity: true
  property bool connectivityCheckEnabled: true
  property int connectivity: NetworkConnectivity.Full
  property int checks: 0
  function checkConnectivity() { checks++ }

  property var devices: ({ values: [device] })

  property QtObject device: QtObject {
    property int type: DeviceType.Wifi
    property string name: "test-wifi"
    property bool connected: false
    property bool scannerEnabled: false
    // Quickshell maps NetworkManager's device states 40-90 onto Connecting.
    property int state: ConnectionState.Disconnected
    // Counts the calls that actually reached NetworkManager, and the ones its
    // own guard turned away.
    property int disconnects: 0
    property int refusedDisconnects: 0
    property var networks: ({ values: [cafe, home] })

    // Quickshell's NetworkDevice::disconnect() refuses only while the device
    // is Disconnected or Disconnecting; anything else becomes NM's
    // Device.Disconnect.
    function disconnect() {
      if (state === ConnectionState.Disconnected || state === ConnectionState.Disconnecting) {
        refusedDisconnects++
        return
      }
      disconnects++
      state = ConnectionState.Disconnected
      cafe.connected = false
      cafe.stateChanging = false
    }
  }

  // Passwordless known network: Forget is available on it directly.
  property QtObject cafe: QtObject {
    property string name: "Cafe WiFi"
    property bool connected: false
    property bool known: true
    property bool stateChanging: false
    property real signalStrength: 0.8
    property int security: WifiSecurityType.Open
    property int disconnects: 0
    property int refusedDisconnects: 0
    property int forgets: 0
    property int refusedForgets: 0
    signal connectionFailed(int reason)
    property var device: NetworkMock.device

    function connect() {
      // NetworkManager accepts the request and starts activating, so the
      // device is no longer Disconnected. `connected` stays false, which is
      // exactly the state the panel has to be able to cancel from.
      device.state = ConnectionState.Connecting
    }

    function connectWithPsk(psk) { connect() }

    // Quickshell's Network::disconnect() returns early unless `connected`,
    // and `connected` is bound to NetworkManager's Activated state -- so this
    // is a no-op while a connect is still in flight.
    function disconnect() {
      if (!connected) {
        refusedDisconnects++
        return
      }
      disconnects++
      device.state = ConnectionState.Disconnected
      connected = false
    }

    function forget() {
      if (!known || connected) {
        refusedForgets++
        return
      }
      forgets++
    }
  }

  // Saved, credentialed, not known to NetworkManager: a second Forget target
  // and a second row for the connect lane.
  property QtObject home: QtObject {
    property string name: "HomeNet"
    property bool connected: false
    property bool known: true
    property bool stateChanging: false
    property real signalStrength: 0.6
    property int security: WifiSecurityType.Wpa2Psk
    property int disconnects: 0
    property int refusedDisconnects: 0
    property int forgets: 0
    property int refusedForgets: 0
    signal connectionFailed(int reason)
    property var device: NetworkMock.device

    function connect() { device.state = ConnectionState.Connecting }
    function connectWithPsk(psk) { connect() }
    function disconnect() {
      if (!connected) { refusedDisconnects++; return }
      disconnects++
      device.state = ConnectionState.Disconnected
      connected = false
    }
    function forget() {
      if (!known || connected) { refusedForgets++; return }
      forgets++
    }
  }
}
