import QtQuick
import Quickshell
import Quickshell.Networking
import qs.Commons
import qs.Commons as Commons
import "mocks"
import "network" as Network

// Changes listed networks' state the way NetworkManager does on its own --
// autoconnect, a drop, a profile saved or deleted elsewhere -- without the
// list itself changing, and checks the rows keep up. The panel stays closed,
// so no row delegate exists to notice anything.
ShellRoot {
  id: test
  property bool failed: false
  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  component Net: QtObject {
    property string name
    property bool connected: false
    property bool known: false
    property bool stateChanging: false
    property real signalStrength: 0.5
    property int security: WifiSecurityType.Wpa2Psk
    signal connectionFailed(int reason)
    function connect() {}
    function connectWithPsk(psk) {}
    function disconnect() {}
    function forget() {}
  }

  property Net home: Net { name: "Home"; known: true; signalStrength: 0.9 }
  property Net cafe: Net { name: "Cafe"; signalStrength: 0.3 }
  property Net guest: Net { name: "Guest"; security: WifiSecurityType.Open; signalStrength: 0.4 }

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

  function row(ssid) {
    for (var i = 0; i < panel.wifiNetworks.length; i++) {
      if (panel.wifiNetworks[i].ssid === ssid) return panel.wifiNetworks[i]
    }
    return null
  }

  // Each step changes something, then the next one checks it after the
  // deferred rebuild has run.
  property var steps: [
    function() {
      NetworkMock.wifi.connected = false
      NetworkMock.wifi.networks = { values: [home, cafe, guest] }
    },
    function() {
      check(row("Home") && row("Home").known && !row("Home").connected, "rows start from the listed networks")
      home.connected = true
      NetworkMock.wifi.connected = true
    },
    function() {
      check(row("Home").connected, "a network that connects on its own is marked connected")
      panel.selectedIndex = panel.wifiIndexForSsid("Cafe")
      cafe.known = true
    },
    function() {
      check(row("Cafe").known, "a profile saved elsewhere marks the row known")
      check(panel.wifiNetworks[panel.selectedIndex].ssid === "Cafe", "the cursor follows its network through the re-sort")
      home.connected = false
      NetworkMock.wifi.connected = false
    },
    function() {
      check(!row("Home").connected, "a network that drops loses its connected mark")
      cafe.known = false
    },
    function() {
      check(!row("Cafe").known, "a profile deleted elsewhere marks the row unknown")
      home.connected = true
      NetworkMock.wifi.connected = true
    },
    function() {
      panel.connectDirectly("Home")
      check(panel.actionKind === "", "connecting a network that is already connected settles at once")
      panel.connectDirectly("Guest")
      check(panel.actionKind === "connect", "a connect is tracked while it is in flight")
      home.connected = false
      guest.connected = true
    },
    function() {
      check(panel.actionKind === "" && panel.failureReason === "", "a connect completes with no row delegate to notice it")
      if (!test.failed) console.log("RESULT pass")
      Qt.quit()
    }
  ]
  property int step: 0

  Timer {
    interval: 100
    running: true
    repeat: true
    onTriggered: test.steps[test.step++]()
  }
}
