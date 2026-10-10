import QtQuick
import Quickshell
import Quickshell.Networking
import qs.Commons
import qs.Commons as Commons
import "mocks"
import "network" as Network

// Opens the passphrase prompt on one network, then publishes scans that
// reorder the list and drop that network, as NetworkManager does while
// someone is typing. The prompt's row must hold its place and its delegate
// until the prompt closes, and the latest scan must show once it does.
ShellRoot {
  id: test
  property bool failed: false
  property var promptRow: null
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
    scan([alpha, cafe])
    panel.open()
  }

  Timer {
    interval: 300
    running: true
    onTriggered: {
      test.check(test.ssids() === "Alpha,Cafe", "first scan lists by signal (got " + test.ssids() + ")")
      // As a click on the row does.
      panel.selectedIndex = 1
      panel.openPasswordPrompt("Cafe")
      panel.passwordText = "hunter"
      Qt.callLater(test.typing)
    }
  }

  function typing() {
    promptRow = panel.testNetworkList.itemAtIndex(1)
    check(promptRow !== null, "the prompt's row has a delegate")
    // Delta and Echo outrank Cafe, which would push it to the bottom.
    scan([alpha, cafe, delta, echo])
    Qt.callLater(reordered)
  }

  function reordered() {
    check(ssids() === "Alpha,Cafe", "a scan during entry leaves the list order alone (got " + ssids() + ")")
    check(panel.testNetworkList.itemAtIndex(1) === promptRow, "a scan during entry keeps the prompt's delegate")
    check(panel.selectedIndex === 1 && panel.passwordText === "hunter", "the prompt keeps its row and text")
    scan([alpha, delta, echo])
    Qt.callLater(dropped)
  }

  function dropped() {
    check(ssids() === "Alpha,Cafe", "the prompt's network stays listed when a scan drops it (got " + ssids() + ")")
    check(panel.testNetworkList.itemAtIndex(1) === promptRow, "a dropped network keeps the prompt's delegate")
    // The delegate's Column holds the section header, then the NetworkRow.
    if (promptRow) promptRow.children[0].children[1].submitCredentials()
    Qt.callLater(submitted)
  }

  function submitted() {
    check(panel.passwordSsid === "" && panel.actionKind === "", "submitting to a network that left the scan closes the prompt")
    check(ssids() === "Delta,Echo,Alpha", "closing the prompt shows the latest scan (got " + ssids() + ")")
    if (!failed) console.log("RESULT pass")
    done.start()
  }

  Timer { id: done; interval: 200; onTriggered: Qt.quit() }
}
