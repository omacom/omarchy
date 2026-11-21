import QtQuick
import Quickshell
import Quickshell.Networking
import qs.Commons
import qs.Commons as Commons
import "mocks"
import "network" as Network

// The VPN section reads the snapshot the stubbed omarchy-network-vpn writes
// (two made-up VPNs), walks it with the keyboard and switches a mode. The
// stub rewrites the snapshot the way the real command does when it is done.
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

  property var steps: [
    function() {
      panel.testEnsureContent()
      check(panel.vpnList.length === 2, "the VPN rows come from the snapshot")
      check(panel.vpnUpNames.join() === "Office", "the connected VPN is named")
      check(panel.testBarButton.tooltipText === "VPN: Office", "the bar tooltip names the connected VPN")
      panel.cursorActive = true
      panel.focusSection = "dns"
      panel.testKeys.moveRequested(0, 1)
      check(panel.focusSection === "vpn" && panel.vpnRowIndex === 0 && panel.vpnControlIndex === 0, "down from DNS reaches the first VPN")
      panel.testKeys.moveRequested(0, -1)
      check(panel.focusSection === "dns", "up from the first VPN goes back to DNS")
      panel.testKeys.moveRequested(0, 1)
      panel.testKeys.moveRequested(0, 1)
      panel.testKeys.moveRequested(1, 0)
      panel.testKeys.moveRequested(1, 0)
      panel.testKeys.moveRequested(1, 0)
      check(panel.vpnRowIndex === 1 && panel.vpnControlIndex === 3, "right walks the modes, then Sign in")
      panel.testKeys.moveRequested(0, 1)
      check(panel.vpnRowIndex === 2 && panel.vpnControlIndex === 0, "down from the last VPN reaches Add VPN")
      panel.testKeys.moveRequested(0, -1)
      panel.testKeys.moveRequested(-1, 0)
      check(panel.vpnRowIndex === 1 && panel.vpnControlIndex === 0, "left walks back along the row")
      panel.testKeys.moveRequested(1, 0)
      panel.testKeys.activateRequested(Qt.NoModifier)
      check(panel.vpnPendingId === "u-home" && panel.vpnPendingMode === "split", "Enter on a mode starts the switch")
      panel.setVpnMode("u-office", "off")
      check(panel.vpnPendingId === "u-home", "a second switch waits for the first")
    },
    function() {},
    function() {},
    function() {
      check(panel.vpnPendingId === "", "the switch clears once the command is done")
      var home = panel.vpnList.find(function(v) { return v.id === "u-home" })
      check(home && home.state === "up" && home.mode === "split", "the row follows the rewritten snapshot")
      if (failed) { Qt.quit(); return }
      console.log("RESULT pass")
      if (Quickshell.env("NETWORK_TEST_PREVIEW") === "vpn") {
        panel.open()
        previewCapture.start()
        previewDone.start()
      } else {
        Qt.quit()
      }
    }
  ]
  property int step: 0

  Timer {
    interval: 200
    running: true
    repeat: true
    onTriggered: if (test.step < test.steps.length) test.steps[test.step++]()
  }

  // NETWORK_TEST_PREVIEW=vpn NETWORK_TEST_SCREENSHOT=/tmp/vpn.png saves the
  // card, showing only the made-up VPNs and network details.
  Timer {
    id: previewCapture
    interval: 750
    onTriggered: {
      var path = Quickshell.env("NETWORK_TEST_SCREENSHOT")
      if (!path) return
      var card = panel.testKeys.parent.parent.parent
      card.grabToImage(function(result) {
        test.check(result.saveToFile(path), "save fresh preview screenshot")
        Qt.quit()
      })
    }
  }
  Timer { id: previewDone; interval: 15000; onTriggered: Qt.quit() }
}
