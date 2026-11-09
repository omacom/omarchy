import QtQuick
import Quickshell
import Quickshell.Networking
import qs.Commons
import qs.Commons as Commons
import "mocks"
import "network" as Network

// Drives the real network panel's Wi-Fi rows through the right-click context
// menu. The list holds a connected KEMENKEU and a known, disconnected SVI: a
// right click on a row opens the menu beside it, Escape closes it, Forget is
// absent on the connected row, and Forget on the known row reaches that
// network's forget().
ShellRoot {
  id: test
  property bool failed: false
  property string forgotSsid: ""
  property string connectedSsid: ""

  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  function keysOf(menu) {
    var keys = []
    var items = menu.items || []
    for (var i = 0; i < items.length; i++) keys.push(items[i].key)
    return keys.join("|")
  }

  // Two rows shaped like Model.wifiRow() reads: a connected KEMENKEU and a
  // known, disconnected SVI that can be forgotten. forget() records the row so
  // the fixture can prove the menu reached the right network.
  property QtObject kemenkeu: QtObject {
    property string name: "KEMENKEU"
    property bool connected: true
    property bool known: true
    property bool stateChanging: false
    property real signalStrength: 0.9
    property int security: WifiSecurityType.Open
    signal connectionFailed(int reason)
    function forget() { test.forgotSsid = "KEMENKEU" }
  }

  property QtObject svi: QtObject {
    property string name: "SVI"
    property bool connected: false
    property bool known: true
    property bool stateChanging: false
    property real signalStrength: 0.6
    property int security: WifiSecurityType.Open
    signal connectionFailed(int reason)
    function forget() { test.forgotSsid = "SVI" }
  }

  // Unknown secured network: Connect must prompt for the passphrase rather than
  // call a bare connect() that would fail without the PSK.
  property QtObject cafe: QtObject {
    property string name: "CAFE"
    property bool connected: false
    property bool known: false
    property bool stateChanging: false
    property real signalStrength: 0.7
    property int security: WifiSecurityType.Wpa2Psk
    signal connectionFailed(int reason)
    function connect() { test.connectedSsid = "CAFE" }
    function forget() { test.forgotSsid = "CAFE" }
  }

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

  Timer {
    interval: 250
    running: true
    onTriggered: {
      NetworkMock.wifi.networks = ({ values: [test.kemenkeu, test.svi, test.cafe] })
      panel.testEnsureContent()
      panel.open()
      Qt.callLater(test.startChecks)
    }
  }

  function startChecks() {
    check(panel.testContent !== null, "panel content builds")
    check(panel.wifiNetworks.length === 3, "all rows are listed")
    check(panel.wifiNetworks[0].ssid === "KEMENKEU" && panel.wifiNetworks[0].connected, "connected KEMENKEU sorts first")
    check(panel.wifiNetworks[1].ssid === "SVI" && !panel.wifiNetworks[1].connected, "disconnected SVI sorts next")
    check(panel.wifiNetworks[2].ssid === "CAFE" && !panel.wifiNetworks[2].known, "unknown secured CAFE sorts last")
    if (failed) { finish(); return }
    menuTimer.start()
  }

  // Give the panel window a frame to map before the popup opens inside it.
  Timer {
    id: menuTimer
    interval: 350
    onTriggered: test.runChecks()
  }

  function runChecks() {
    var menu = panel.testContent.testMenu
    check(!!menu, "context menu built with the content")

    // --- connected row: the profile is in use, so no Forget ---
    clickRow(0)
    check(menu.popupOpen, "right-click opens the menu")
    check(keysOf(menu) === "disconnect|modify", "connected row offers disconnect and modify, never forget")
    pressEscape(menu)
    check(!menu.popupOpen, "Escape closes the menu")

    // --- known disconnected row: Forget is offered ---
    clickRow(1)
    check(menu.popupOpen, "right-click opens the known row's menu")
    check(keysOf(menu) === "connect|modify|forget", "known row offers connect, modify and forget")
    pressEscape(menu)
    check(!menu.popupOpen, "Escape closes the known row's menu")

    // --- Forget wires up to the row's own network ---
    clickRow(1)
    menu.setHighlight(2)
    menu.activateHighlighted()
    check(test.forgotSsid === "SVI", "Forget forgets the right-clicked profile")
    check(!menu.popupOpen, "activation closes the menu")

    // --- unknown secured row: Connect prompts instead of a bare connect() ---
    clickRow(2)
    check(keysOf(menu) === "connect", "unknown secured row offers only connect")
    menu.setHighlight(0)
    menu.activateHighlighted()
    check(panel.passwordSsid === "CAFE", "Connect on an unknown secured row opens the passphrase prompt")
    check(test.connectedSsid === "", "Connect does not call connect() without the passphrase")

    finish()
  }

  function clickRow(index) {
    var mouse = panel.testContent.testRowMouse(index)
    check(!!mouse && (mouse.acceptedButtons & Qt.RightButton) === Qt.RightButton, "row " + index + " accepts right clicks")
    panel.testContent.testRowGesture(index, Qt.RightButton)
  }

  function pressEscape(menu) {
    menu.handleKey({ key: Qt.Key_Escape, text: "", modifiers: 0, accepted: false })
  }

  function finish() {
    console.log(failed ? "RESULT fail" : "RESULT pass")
    Qt.quit()
  }
}
