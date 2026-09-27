import QtQuick
import Quickshell
import Quickshell.Networking
import qs.Commons
import "mocks"
import "network" as Network

// Behavioural coverage for the network panel's cancel and forget lanes. The
// mocked backend mirrors the frontend guards of the real one, so a cancel that
// relies on an API Quickshell would refuse fails here.
// NETWORK_CANCEL_OUT receives a line per assertion; the runner requires every
// one of them and no "FAIL" lines.
ShellRoot {
  id: test
  property int failures: 0

  function check(ok, message) {
    if (!ok) failures++
    console.log((ok ? "PASS " : "FAIL ") + message)
  }

  Item {
    Network.Panel {
      id: panel
      bar: QtObject {
        property color foreground: Color.foreground
        property color barForeground: Color.foreground
        property color urgent: Color.urgent
        property string fontFamily: Style.font.family
        property string position: "top"
        property int barSize: 24
        property bool vertical: false
        property bool foregroundAnimationEnabled: false
        property var activePopout: null
        function requestPopout(owner) { activePopout = owner }
        function releasePopout(owner) { activePopout = null }
        function registerClickTarget(target) {}
        function unregisterClickTarget(target) {}
        function hideTooltip(target) {}
        function showTooltip(target, text) {}
      }
    }
  }

  function arm() {
    NetworkMock.cafe.connected = false
    NetworkMock.cafe.known = true
    NetworkMock.cafe.stateChanging = false
    NetworkMock.home.connected = false
    NetworkMock.home.known = true
    NetworkMock.home.stateChanging = false
    NetworkMock.device.connected = false
    NetworkMock.device.state = ConnectionState.Disconnected
    NetworkMock.device.disconnects = 0
    NetworkMock.device.refusedDisconnects = 0
    NetworkMock.cafe.disconnects = 0
    NetworkMock.cafe.refusedDisconnects = 0
    NetworkMock.cafe.forgets = 0
    NetworkMock.cafe.refusedForgets = 0
    NetworkMock.home.forgets = 0
    NetworkMock.home.refusedForgets = 0
    panel.actionSsid = ""
    panel.actionKind = ""
    panel.forgetActive = false
    panel.forgetSsid = ""
    panel.failureSsid = ""
    panel.failureReason = ""
    panel.passwordSsid = ""
    panel.cursorActive = true
    panel.focusSection = "wifi"
  }

  // Row order is by connection, then known, then signal, so index by SSID
  // rather than hardcoding one.
  function indexOf(ssid) {
    for (var i = 0; i < panel.wifiNetworks.length; i++)
      if (panel.wifiNetworks[i].ssid === ssid) return i
    return -1
  }

  function focusRow(ssid) {
    panel.cursorActive = true
    panel.focusSection = "wifi"
    panel.selectedIndex = indexOf(ssid)
    panel.wifiActionFocused = false
  }

  Timer {
    interval: 700
    running: true
    onTriggered: {
      check(panel.wifiNetworks.length === 2, "two rows are listed")
      arm()
      cancelReachesNetworkManager()
    }
  }

  // The core of the fix: with the profile still Activating, the profile-level
  // disconnect is refused by Quickshell, so the abort has to go through the
  // device.
  function cancelReachesNetworkManager() {
    arm()
    panel.connectDirectly("Cafe WiFi")
    check(panel.actionKind === "connect" && panel.isConnectTarget("Cafe WiFi"),
      "a direct connect arms the connect lane")
    check(NetworkMock.device.state === ConnectionState.Connecting,
      "the connect put the device into the activating state")
    check(NetworkMock.cafe.connected === false,
      "the profile is not connected yet, so its own disconnect is a no-op")

    panel.cancelNetworkAction()

    check(NetworkMock.device.disconnects === 1,
      "cancel reached NetworkManager through the device (the profile-level call is a no-op)")
    check(NetworkMock.cafe.refusedDisconnects === 0,
      "cancel does not rely on the profile-level disconnect at all")
    check(panel.actionKind === "" && panel.actionSsid === "" && panel.busy === false,
      "cancel clears the connect lane")
    check(panel.failureSsid === "" && panel.failureReason === "",
      "cancel records no failure")
    check(panel.wifiActionFocused === false,
      "cancel disarms the slot so a second click cannot land on Forget")
    noWait()
  }

  // A late outcome of the aborted attempt must not reopen the passphrase
  // prompt: nothing is tracking the action any more.
  function noWait() {
    arm()
    panel.connectDirectly("Cafe WiFi")
    panel.cancelNetworkAction()
    NetworkMock.cafe.connected = true
    panel.checkActionCompletion(NetworkMock.cafe)
    check(panel.failureSsid === "" && panel.failureReason === "",
      "a late success for an aborted connect stays silent")
    arm()
    panel.connectDirectly("Cafe WiFi")
    panel.cancelNetworkAction()
    panel.failNetworkAction(NetworkMock.cafe, 4)
    check(panel.failureSsid === "" && panel.failureReason === "",
      "a late failure for an aborted connect is not turned into a failure")
    keyboardCancel()
  }

  // The same abort has to be reachable from the keyboard.
  function keyboardCancel() {
    arm()
    panel.connectDirectly("Cafe WiFi")
    focusRow("Cafe WiFi")
    NetworkMock.device.disconnects = 0
    panel.activateSelected()
    check(panel.actionKind === "" && NetworkMock.device.disconnects === 1,
      "Enter on the connecting row cancels and reaches NetworkManager")
    keyboardAbortPath()
  }

  function keyboardAbortPath() {
    arm()
    panel.connectWithPassphrase("HomeNet", "hunter2")
    check(panel.isConnectTarget("HomeNet"), "a passphrase connect arms the lane")
    focusRow("HomeNet")
    NetworkMock.device.disconnects = 0
    panel.activateSelected()
    check(NetworkMock.device.disconnects === 1,
      "Enter on a passphrase connect aborts the activation too")
    cancelOnlyWhenActivating()
  }

  // Before NetworkManager has picked the request up there is nothing to abort,
  // and the device disconnect would hit whatever the user is connected to.
  function cancelOnlyWhenActivating() {
    arm()
    panel.actionSsid = "Cafe WiFi"
    panel.actionKind = "connect"
    NetworkMock.device.state = ConnectionState.Connected
    NetworkMock.device.disconnects = 0
    panel.cancelNetworkAction()
    check(NetworkMock.device.disconnects === 0,
      "cancel leaves the device alone unless it is actually activating")
    check(panel.actionKind === "", "cancel still stops tracking the action")
    forgetLaneDuringConnect()
  }

  // Forget moved to its own lane so a saved row stays forgettable while another
  // SSID connects.
  function forgetLaneDuringConnect() {
    arm()
    panel.connectDirectly("Cafe WiFi")
    check(panel.isConnectTarget("Cafe WiFi"), "the connect lane is live")
    panel.forget({ ssid: "HomeNet" })
    check(NetworkMock.home.forgets === 1,
      "another saved row can be forgotten while one SSID connects")
    check(panel.actionKind === "connect" && panel.actionSsid === "Cafe WiFi",
      "forgetting does not disturb the connect lane")
    check(panel.forgetActive === true && panel.forgetSsid === "HomeNet",
      "the forget tracks its own row")
    // The panel refuses this before it ever reaches the backend, so the
    // backend's own counters must not move.
    panel.forget({ ssid: "Cafe WiFi" })
    check(panel.forgetActive === true && panel.forgetSsid === "HomeNet" && NetworkMock.cafe.forgets === 0,
      "forget stays off the row the connect lane is driving")
    pendingForgetBlocksKeyboardConnect()
  }

  // Enter must not start a connect on a profile that is still being deleted.
  function pendingForgetBlocksKeyboardConnect() {
    arm()
    panel.forget({ ssid: "HomeNet" })
    check(panel.forgetActive === true, "forget is pending on HomeNet")
    focusRow("HomeNet")
    NetworkMock.device.state = ConnectionState.Disconnected
    panel.activateSelected()
    check(panel.actionKind === "",
      "Enter does not start a connect on a row whose forget is still pending")
    check(NetworkMock.device.state === ConnectionState.Disconnected,
      "the refused keyboard connect did not disturb the device")
    done()
  }

  function done() {
    if (failures > 0) {
      console.log("RESULT fail " + failures + " assertion(s)")
      Qt.quit()
      return
    }
    console.log("RESULT pass cancel-and-forget-lanes")
    Qt.quit()
  }

  Timer { interval: 25000; running: true; onTriggered: { console.log("RESULT fail timeout"); Qt.quit() } }
}
