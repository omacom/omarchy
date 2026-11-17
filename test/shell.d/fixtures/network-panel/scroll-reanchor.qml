import QtQuick
import Quickshell
import Quickshell.Networking
import qs.Commons
import qs.Commons as Commons
import "mocks"
import "network" as Network

// A new access point appearing mid-scan still rebuilds `wifiNetworks` (a row
// the frozen snapshot has never seen). Scrolling the list is a trackpad
// gesture, not a key press, so the cursor's own index never moves either --
// the fix can't key off selectedIndex/currentIndex. The viewport itself must
// stay where it was scrolled to instead of snapping back to the top.
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
    property int calls: 0
    signal connectionFailed(int reason)
    function connect() { calls++ }
    function connectWithPsk(psk) { calls++ }
    function disconnect() { calls++ }
    function forget() { calls++ }
  }

  property Net net0: Net { name: "Net 0"; signalStrength: 0.98 }
  property Net net1: Net { name: "Net 1"; signalStrength: 0.91 }
  property Net net2: Net { name: "Net 2"; signalStrength: 0.84 }
  property Net net3: Net { name: "Net 3"; signalStrength: 0.77 }
  property Net net4: Net { name: "Net 4"; signalStrength: 0.70 }
  property Net net5: Net { name: "Net 5"; signalStrength: 0.63 }
  property Net net6: Net { name: "Net 6"; signalStrength: 0.56 }
  property Net net7: Net { name: "Net 7"; signalStrength: 0.49 }
  property Net net8: Net { name: "Net 8"; signalStrength: 0.42 }
  property Net net9: Net { name: "Net 9"; signalStrength: 0.35 }
  property Net net10: Net { name: "Net 10"; signalStrength: 0.28 }
  property Net net11: Net { name: "Net 11"; signalStrength: 0.21 }
  // Weaker than everything above, so it slots in at the very end and
  // nothing above it shifts position.
  property Net extra: Net { name: "Extra"; signalStrength: 0.05 }
  property var nets: [net0, net1, net2, net3, net4, net5, net6, net7, net8, net9, net10, net11]

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

  property var steps: [
    function() {
      NetworkMock.wifi.connected = false
      NetworkMock.wifi.networks = { values: nets }
    },
    function() {
      panel.open()
      panel.testEnsureContent()
      // A trackpad scroll: the cursor stays on the top row, only the
      // viewport moves.
      panel.testContent.networkList.contentY = 150
    },
    function() {
      check(panel.selectedIndex === 0, "the cursor never moved off the top row")
      var scrolledY = panel.testNetworkListContentY()
      check(scrolledY === 150, "the scroll lands where the test put it (contentY=" + scrolledY + ")")
      test.scrolledY = scrolledY
      NetworkMock.wifi.networks = { values: nets.concat([extra]) }
    },
    function() {
      // Give the reset-then-restore a full tick to settle.
    },
    function() {
      check(panel.selectedIndex === 0, "the cursor still never moved")
      var afterY = panel.testNetworkListContentY()
      check(afterY === test.scrolledY, "the list returns to where it was scrolled instead of snapping back to the top (contentY=" + afterY + ", was " + test.scrolledY + ")")
      extra.known = true
    },
    function() {
      check(panel.selectedIndex === 1 && panel.testNetworkListContentY() === 150,
        "a known access point above an offscreen cursor preserves the browsing viewport")
      extra.known = false
      NetworkMock.wifi.networks = { values: nets }
    },
    function() {
      Qt.callLater(function() { panel.selectByDelta(1) })
      NetworkMock.wifi.networks = { values: nets.concat([extra]) }
    },
    function() {
      var list = panel.testContent.networkList
      var row = list.itemAtIndex(panel.selectedIndex)
      check(panel.selectedIndex === 1 && row && row.y >= list.contentY && row.y + row.height <= list.contentY + list.height,
        "navigation queued before a scan restore leaves the selected row visible")
      list.contentY = 150
      NetworkMock.wifi.networks = { values: nets.concat([extra]) }
      NetworkMock.wifi.networks = { values: nets }
    },
    function() {
      check(panel.testNetworkListContentY() === 150, "a burst of scan updates preserves the original viewport")
      panel.selectedIndex = panel.wifiIndexForSsid("Net 8")
    },
    function() {
      test.scrolledY = panel.testNetworkListContentY()
      NetworkMock.wifi.networks = { values: nets.slice(1) }
    },
    function() {
      var list = panel.testContent.networkList
      var row = list.itemAtIndex(panel.selectedIndex)
      check(panel.wifiNetworks[panel.selectedIndex].ssid === "Net 8" && row && row.y >= list.contentY && row.y + row.height <= list.contentY + list.height,
        "removing an earlier access point keeps the selected network in view")
      check(row && Math.abs(list.contentY - test.scrolledY) <= row.height + list.spacing,
        "removing an earlier access point moves the viewport by at most one row")
    },
    function() {
      net8.known = true
      net8.connected = true
      NetworkMock.wifi.connected = true
    },
    function() {
      var list = panel.testContent.networkList
      var row = list.itemAtIndex(panel.selectedIndex)
      check(panel.selectedIndex === 0, "the cursor follows the connected network to the top")
      check(row && row.y >= list.contentY && row.y + row.height <= list.contentY + list.height,
        "connecting leaves the selected row in view instead of restoring the old scroll offset")
      if (!test.failed) console.log("RESULT pass")
      Qt.quit()
    }
  ]
  property int step: 0
  property real scrolledY: 0

  Timer {
    interval: 150
    running: true
    repeat: true
    onTriggered: test.steps[test.step++]()
  }
}
