import QtQuick
import Quickshell
import Quickshell.Networking
import qs.Commons
import qs.Commons as Commons
import "mocks"
import "network" as Network

// Where the VPNs sit and how the keyboard reaches them: up front, before the
// Wi-Fi networks, once there is a connection; last, past the networks,
// without one. On a card the screen cuts short, the panel scrolls and keeps
// the keyboard's row on screen. Also the credentials prompt taking the
// cursor and keyboard, and a VPN that belongs to another widget (Tailscale)
// opening that widget.
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

  property var summoned: []

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
        property QtObject shell: QtObject {
          function summon(id) { test.summoned = test.summoned.concat([id]); return true }
        }
        function requestPopout(owner) { activePopout = owner }
        function releasePopout(owner) { activePopout = null }
        function registerClickTarget(target) {}
        function unregisterClickTarget(target) {}
        function hideTooltip(target) {}
        function showTooltip(target, text) {}
      }
    }
  }

  // Whether `item` shows in the scrolled panel's window: its top edge, and
  // most of it, since a cursor row can still be growing into its highlight.
  function onScreen(item) {
    var flick = panel.testContent.panelFlick
    var top = item.mapToItem(flick.contentItem, 0, 0).y
    var shown = Math.min(top + item.height, flick.contentY + flick.height) - Math.max(top, flick.contentY)
    return top >= flick.contentY - 1 && shown >= item.height * 0.75
  }

  function profile(n) {
    return { id: "00000000-0000-4000-8000-00000000000" + n, provider: "networkmanager", name: "Office " + n, type: "vpn", state: "" }
  }
  readonly property var tailscaleEntry: ({ id: "tailscale", provider: "tailscale", name: "Tailscale", type: "tailscale", state: "login", exitNode: "", opens: "omarchy.tailscale" })

  property var steps: [
    function() {
      NetworkMock.wifi.connected = false
      NetworkMock.network.connected = false
      NetworkMock.wifi.networks = { values: [home, cafe] }
      NetworkVpnMock.connections = [profile(1), profile(2), profile(3), profile(4), profile(5), profile(6), tailscaleEntry]
      test.check(panel.testEnsureContent() !== null, "panel content builds")
      // Laid out for real, in its window, on a short screen: the card is
      // capped well below what the panel holds.
      panel.open()
      panel.testCard.contentHeight = Style.space(260)
    },
    function() {
      var flick = panel.testContent.panelFlick
      check(panel.kind === "disconnected", "fixture starts without a connection")
      check(panel.vpnPlacement === "bottom", "VPNs wait at the bottom without a connection")
      check(JSON.stringify(panel.listSections) === '["wifi","vpn"]', "the Wi-Fi networks come before the VPNs without a connection")
      check(flick.height > 0 && flick.contentHeight > flick.height && flick.interactive, "a panel taller than its card scrolls")

      panel.cursorActive = true
      panel.focusSection = "dns"
      panel.testKeys.moveRequested(0, 1)
      check(panel.focusSection === "wifi", "j from DNS reaches the networks first")
      panel.testKeys.moveRequested(0, 1)
      panel.testKeys.moveRequested(0, 1)
      check(panel.focusSection === "vpn" && panel.vpnIndex === 0, "j off the last network reaches the first VPN")
      for (var i = 0; i < 10; i++) panel.testKeys.moveRequested(0, 1)
      check(panel.focusSection === "vpn" && panel.vpnIndex === 6, "j stops on the last VPN")
    },
    function() {
      var flick = panel.testContent.panelFlick
      var vpnList = panel.testVpnList
      check(vpnList.height < vpnList.contentHeight, "seven VPNs scroll within a capped list")
      check(flick.contentY > 0, "the panel scrolls down to the VPNs at its bottom")
      check(vpnList.currentItem && onScreen(vpnList.currentItem), "the keyboard's last VPN row is on screen")
      for (var k = 0; k < 7; k++) panel.testKeys.moveRequested(0, -1)
      check(panel.focusSection === "wifi" && panel.selectedIndex === panel.wifiNetworks.length - 1, "k off the first VPN climbs back to the last network")
      for (var i = 0; i < 4 && panel.focusSection !== "dns"; i++) panel.testKeys.moveRequested(0, -1)
      check(panel.focusSection === "dns", "k climbs from the networks back to DNS")
    },
    function() {
      check(onScreen(panel.testContent.testDns), "DNS, back above the scrolled lists, is on screen again")

      home.connected = true
      NetworkMock.wifi.connected = true
    },
    function() {
      check(panel.kind === "wifi", "fixture connects")
      check(panel.vpnPlacement === "top", "VPNs move up front once connected")
      check(JSON.stringify(panel.listSections) === '["vpn","wifi"]', "the VPNs come before the networks once connected")

      panel.focusSection = "dns"
      panel.testKeys.moveRequested(0, 1)
      check(panel.focusSection === "vpn" && panel.vpnIndex === 0, "j from DNS reaches the first VPN once connected")
      for (var i = 0; i < 7; i++) panel.testKeys.moveRequested(0, 1)
      check(panel.focusSection === "wifi" && panel.selectedIndex === 0, "j off the last VPN carries on into the networks")
    },
    function() {
      var networks = panel.testContent.testNetworkList
      check(networks.currentItem && onScreen(networks.currentItem), "the keyboard's network, below the VPNs, is on screen")
      panel.testKeys.moveRequested(0, -1)
      check(panel.focusSection === "vpn" && panel.vpnIndex === 6, "k off the first network climbs back to the last VPN")
      panel.vpnIndex = 0
      panel.testKeys.moveRequested(0, -1)
      check(panel.focusSection === "dns", "k off the first VPN returns to DNS")

      NetworkVpnMock.credentialsUser = "alice"
      NetworkVpnMock.credentialsNeedUser = true
      NetworkVpnMock.credentialsId = profile(4).id
    },
    function() {
      check(panel.focusSection === "vpn" && panel.vpnIndex === 3, "the credentials prompt takes the cursor to its row")
      check(panel.vpnUserText === "alice", "the prompt starts from the profile's user name")
      check(panel.testKeys.blocked, "the prompt's fields own the keyboard while it is open")
      panel.cancelVpnCredentials()
    },
    function() {
      check(NetworkVpnMock.credentialsId === "" && !panel.testKeys.blocked, "cancelling hands the keyboard back")
      panel.activateVpn(tailscaleEntry)
      check(JSON.stringify(test.summoned) === '["omarchy.tailscale"]', "Tailscale's row opens the Tailscale widget")
      check(!panel.opened, "the network panel closes for the widget it opened")
      if (!test.failed) console.log("RESULT pass")
      Qt.quit()
    }
  ]
  property int step: 0

  Timer {
    interval: 150
    running: true
    repeat: true
    onTriggered: test.steps[test.step++]()
  }
}
