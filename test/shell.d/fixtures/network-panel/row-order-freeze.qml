import QtQuick
import Quickshell
import Quickshell.Networking
import qs.Commons
import qs.Commons as Commons
import "mocks"
import "network" as Network

// A scan that nudges a signal across a neighbor's rounded value used to
// reshuffle the list on every tick, even though nothing a person would call
// a change actually happened. While the panel is open, row order (and each
// row's displayed signal) must hold steady against whatever's on screen. And
// opening the panel must never show a snapshot held from before it was last
// closed -- that first rebuild has to be driven by the real `onOpenedChanged`
// call site, not a direct call to `refresh()`.
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

  property Net netA: Net { name: "A"; signalStrength: 0.51 }
  property Net netB: Net { name: "B"; signalStrength: 0.50 }

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

  function order() {
    var out = []
    for (var i = 0; i < panel.wifiNetworks.length; i++) out.push(panel.wifiNetworks[i].ssid)
    return out.join(",")
  }

  function rowSignal(ssid) {
    for (var i = 0; i < panel.wifiNetworks.length; i++) {
      if (panel.wifiNetworks[i].ssid === ssid) return panel.wifiNetworks[i].signal
    }
    return -1
  }

  property var steps: [
    function() {
      // Built while the panel is still closed, the way a real adapter's scan
      // results arrive before anyone opens the panel to look at them.
      NetworkMock.wifi.connected = false
      NetworkMock.wifi.networks = { values: [netA, netB] }
    },
    function() {
      check(order() === "A,B", "rows start sorted by signal, strongest first (" + order() + ")")
      // The adapter keeps scanning while the panel is closed; change the
      // live network object in place, the way `onWifiStateKeyChanged` sees
      // it, rather than reassigning `networks`, so nothing here rebuilds on
      // its own -- the panel has no snapshot of this yet.
      netA.signalStrength = 0.10
      // The real call site: `onOpenedChanged` is what must re-sort by the
      // current signal on open, not a snapshot held from before a close.
      panel.open()
    },
    function() {
      check(order() === "B,A", "opening re-sorts by the current signal instead of a snapshot held from before (" + order() + ")")
      check(rowSignal("A") === 10, "opening shows the current signal instead of one held from before (" + rowSignal("A") + ")")
      // Now the panel is open: a scan pushes A's signal back above B's, the
      // kind of noise a real scan produces constantly, with nothing else
      // about the networks changing. Unfrozen, this would flip the order
      // back to A,B; frozen, B,A must hold.
      netA.signalStrength = 0.52
      NetworkMock.wifi.networks = { values: [netA, netB] }
    },
    function() {
      check(order() === "B,A", "row order holds steady across a scan while the panel is open (" + order() + ")")
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
