import QtQuick
import Quickshell
import qs.Commons
import qs.Commons as Commons
import "mocks"
import "network" as Network

// Offline, the panel brings the first-run Wi-Fi card back when it closes, but
// only after the card opened it. Closed mid-connect, how the connection ends
// decides. The runner logs each card it is asked for.
ShellRoot {
  id: test
  property bool failed: false
  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
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

  // Each step runs after the last one's detached commands have landed, and a
  // marker names the scenario in the log, so the runner can tell which one
  // brought the card back.
  function mark(name) { Quickshell.execDetached(["omarchy-provision-first-run-card", name]) }
  function offline() {
    NetworkMock.network.connected = false
    NetworkMock.wifi.connected = false
  }
  // Opened by the card, then closed while the connection is still going.
  function closeMidConnect() {
    panel.cardOpened = true
    panel.open()
    panel.runNetworkAction("connect", NetworkMock.network, function() {})
    panel.close()
    check(panel.cardRetryPending, "closing mid-connect keeps the retry pending")
  }

  property int step: 0
  property var steps: [
    function() { offline(); check(panel.kind === "disconnected", "the fixture starts offline"); mark("plain") },
    function() { panel.open(); panel.close() },
    function() { mark("idle") },
    function() {
      panel.cardOpened = true
      panel.open()
      panel.close()
      check(!panel.cardOpened && !panel.cardRetryPending, "closing idle settles at once")
    },
    function() { mark("success") },
    function() { closeMidConnect() },
    function() {
      NetworkMock.network.connected = true
      NetworkMock.wifi.connected = true
      panel.checkActionCompletion(NetworkMock.network)
      check(!panel.cardRetryPending && panel.actionKind === "", "a connection that lands clears the retry")
    },
    function() { offline(); mark("failure") },
    function() { closeMidConnect() },
    function() {
      panel.failNetworkAction(NetworkMock.network, 0)
      check(!panel.cardRetryPending, "a failed connection settles the retry")
    },
    function() { mark("timeout") },
    function() { closeMidConnect() },
    function() {
      panel.testActionTimeout.stop()
      panel.testActionTimeout.triggered()
      check(!panel.cardRetryPending, "a timed-out connection settles the retry")
    },
    function() { mark("reopened") },
    function() { closeMidConnect() },
    function() {
      panel.open()
      panel.failNetworkAction(NetworkMock.network, 0)
      check(!panel.cardRetryPending && panel.cardOpened, "a failure seen in the open panel waits for it to close")
    },
    function() { mark("reopened-closing") },
    function() { panel.close() },
    function() {
      if (!failed) console.log("RESULT pass")
      Qt.quit()
    }
  ]

  Timer {
    interval: 300
    running: true
    repeat: true
    onTriggered: test.steps[test.step++]()
  }
}
