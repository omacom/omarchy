import QtQuick
import Quickshell
import Quickshell.Networking
import qs.Commons
import qs.Commons as Commons
import "mocks"
import "network" as Network

// Exercises credential entry against the live held-order model. New networks
// remain visible, while a disappeared network or Wi-Fi device must release the
// prompt and keyboard catcher instead of leaving an invisible modal state.
ShellRoot {
  id: test
  property bool failed: false
  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  component Ap: QtObject {
    property string name: ""
    property bool connected: false
    property bool known: false
    property bool stateChanging: false
    property real signalStrength: 0
    property int security: WifiSecurityType.Wpa2Psk
    signal connectionFailed(int reason)
    function connectWithPsk(passphrase) {}
  }

  Ap { id: alpha; name: "Alpha"; signalStrength: 0.7 }
  Ap { id: cafe; name: "Cafe"; signalStrength: 0.5 }
  Ap { id: delta; name: "Delta"; signalStrength: 0.9 }
  Ap { id: echo; name: "Echo"; signalStrength: 0.8 }

  Item {
    Network.Panel {
      id: panel
      bar: QtObject {
        property color foreground: Commons.Color.foreground
        property color barForeground: Commons.Color.foreground
        property color urgent: Commons.Color.urgent
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

  function ssids() { return panel.wifiNetworks.map(function(n) { return n.ssid }).join(",") }
  function scan(list) { NetworkMock.wifi.networks = { values: list } }

  Component.onCompleted: {
    NetworkMock.wifi.connected = false
    NetworkMock.devices = { values: [NetworkMock.wifi] }
    scan([alpha, cafe])
    panel.open()
  }

  Timer {
    interval: 300
    running: true
    onTriggered: {
      check(ssids() === "Alpha,Cafe", "first scan lists by signal (got " + ssids() + ")")
      check(panel.testContent !== null && panel.testNetworkList !== null, "the panel builds its network list")
      panel.selectedIndex = 1
      panel.openPasswordPrompt("Cafe")
      scan([alpha, cafe, delta, echo])
      Qt.callLater(test.added)
    }
  }

  function added() {
    check(ssids() === "Alpha,Cafe,Delta,Echo", "held rows keep their order while new networks remain visible (got " + ssids() + ")")
    check(panel.selectedIndex === 1 && panel.passwordSsid === "Cafe", "the prompt keeps its row")
    closePrompt.start()
  }

  Timer {
    id: closePrompt
    interval: 100
    onTriggered: {
      panel.cancelPasswordPrompt()
      Qt.callLater(test.cancelled)
    }
  }

  function cancelled() {
    check(ssids() === "Delta,Echo,Alpha,Cafe", "cancelling a prompt restores signal order without another scan (got " + ssids() + ")")
    panel.selectedIndex = panel.wifiIndexForSsid("Cafe")
    panel.openPasswordPrompt("Cafe")
    scan([alpha, delta, echo])
    Qt.callLater(dropped)
  }

  function dropped() {
    check(ssids() === "Delta,Echo,Alpha", "a dropped prompt leaves the remaining networks visible (got " + ssids() + ")")
    check(panel.passwordSsid === "", "a dropped prompt network closes credential entry")
    check(!panel.testContent.blocked, "a dropped prompt network releases panel keyboard input")
    scan([alpha, cafe])
    Qt.callLater(startInRangeTimeout)
  }

  function startInRangeTimeout() {
    panel.selectedIndex = 1
    panel.openPasswordPrompt("Cafe")
    panel.connectWithPassphrase(cafe, "hunter")
    check(panel.actionKind === "connect", "submitting to a live network starts a connection")
    panel.testActionTimeout.triggered()
    check(panel.passwordSsid === "Cafe", "an in-range timeout keeps credential entry open for retry")
    panel.cancelPasswordPrompt()
    Qt.callLater(startDeviceLoss)
  }

  function startDeviceLoss() {
    panel.selectedIndex = 1
    panel.openPasswordPrompt("Cafe")
    check(panel.passwordSsid === "Cafe" && panel.testContent.blocked,
      "credential entry owns keyboard input before device loss")
    NetworkMock.devices = { values: [] }
    Qt.callLater(deviceLost)
  }

  function deviceLost() {
    check(panel.passwordSsid === "", "losing the Wi-Fi device closes credential entry")
    check(!panel.wifiStationAvailable, "losing the Wi-Fi device clears station availability")
    check(!panel.testContent.blocked, "losing the Wi-Fi device releases panel keyboard input")
    if (!failed) console.log("RESULT pass")
    done.start()
  }

  Timer { id: done; interval: 200; onTriggered: Qt.quit() }
}
