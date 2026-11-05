import QtQuick
import Quickshell
import Quickshell.Networking
import qs.Commons
import qs.Commons as Commons
import "mocks"
import "network" as Network

// A kill-switching VPN makes NetworkManager's physical probe fail, so its
// aggregate connectivity reads "limited" while the tunnel carries the traffic.
// The staged nmcli stub reports a connected tunnel at "full"; the panel must
// read that as internet rather than an outage.
ShellRoot {
  id: test
  property bool failed: false
  property int attempts: 0
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

  Timer {
    interval: 250
    running: true
    onTriggered: {
      NetworkMock.connectivity = NetworkConnectivity.Limited
      // NETWORK_TEST_PREVIEW renders the card for a screenshot instead of
      // asserting, so before and after captures come from one fixture.
      if (Quickshell.env("NETWORK_TEST_PREVIEW")) {
        previewNow()
        return
      }
      test.check(panel.testEnsureContent() !== null, "panel content builds on demand")
      test.check(panel.kind === "wifi", "connected Wi-Fi fixture")
      settle.start()
    }
  }

  // The per-device read is a process, so give it a moment to answer before
  // asserting on what the panel decided.
  Timer {
    id: settle
    interval: 100
    repeat: true
    onTriggered: {
      if (!waited(true)) return
      settle.stop()
      tunnelChecks()
    }
  }

  // Waits for the panel's tunnel verdict to reach `expected`, failing loudly
  // instead of hanging when it never does.
  function waited(expected) {
    if (panel.tunnelCarriesInternet === expected) {
      test.attempts = 0
      return true
    }
    if (++test.attempts < 40) return false
    test.check(false, "panel rereads per-device connectivity")
    Qt.quit()
    return false
  }

  function waitFor(expected, then) {
    test.attempts = 0
    waiting.expected = expected
    waiting.then = then
    waiting.restart()
  }

  Timer {
    id: waiting
    interval: 100
    repeat: true
    property bool expected: false
    property var then: null
    onTriggered: {
      if (!waited(expected)) return
      stop()
      var next = then
      then = null
      next()
    }
  }

  function tunnelChecks() {
    check(panel.nmConnectivity === "limited", "fixture keeps NetworkManager's limited aggregate")
    check(panel.connectivity === "full", "tunnel connectivity clears the limited aggregate")
    check(!panel.restricted && !panel.hasCaptivePortal, "tunnel traffic is not an outage")
    check(!panel.testBarButton.active, "bar icon is not in the warning state")
    check(panel.testMeta.text !== "LIMITED INTERNET ACCESS", "hero does not read as an outage")
    check(!panel.testPoll.running, "a closed panel leaves the idle shell alone")
    Qt.callLater(openedChecks)
  }

  // The staged nmcli alternates: the tunnel reports full on the first read,
  // limited on the second, and so on. Opening the panel rereads it, so a VPN
  // that dropped while the aggregate stayed limited puts the warning back.
  function openedChecks() {
    panel.open()
    check(panel.testPoll.running, "open panel arms the recheck")
    waitFor(false, openedReadChecks)
  }

  function openedReadChecks() {
    check(panel.restricted && panel.connectivity === "limited", "opening the panel rereads a tunnel that stopped being full")
    check(panel.testMeta.text === "LIMITED INTERNET ACCESS", "hero reads as an outage again")
    panel.testPoll.triggered()
    waitFor(true, recheckChecks)
  }

  function recheckChecks() {
    check(!panel.restricted && panel.testMeta.text !== "LIMITED INTERNET ACCESS", "the poll rereads a tunnel that works again")
    panel.testPoll.triggered()
    waitFor(false, doneChecks)
  }

  function doneChecks() {
    check(panel.testBarButton.active, "bar icon warns once the tunnel stops")
    // The VPN coming and going is what the closed panel has to notice: it is
    // the only event left once the panel is shut.
    panel.close()
    NetworkMock.devicesModel.values = [NetworkMock.wifi]
    waitFor(true, deviceChecks)
  }

  function deviceChecks() {
    check(!panel.testPoll.running, "closed panel does not poll for the change")
    check(!panel.restricted && !panel.testBarButton.active, "device change clears the warning on a closed panel")
    if (failed) { Qt.quit(); return }
    console.log("RESULT pass")
    done.start()
  }

  function previewNow() {
    panel.open()
    previewCapture.start()
    previewDone.start()
  }

  // The panel-only capture excludes the host desktop; the details come from
  // fixtures only. NETWORK_TEST_SCREENSHOT=<path>.
  Timer {
    id: previewCapture
    interval: 1500
    onTriggered: {
      var path = Quickshell.env("NETWORK_TEST_SCREENSHOT")
      if (!path) return
      // Content root -> Loader -> content holder -> card.
      var card = panel.testKeys.parent.parent.parent
      card.grabToImage(function(result) {
        if (!result.saveToFile(path)) console.log("RESULT fail save preview")
        Qt.quit()
      })
    }
  }
  Timer { id: previewDone; interval: 15000; onTriggered: Qt.quit() }
  Timer { id: done; interval: 300; onTriggered: Qt.quit() }
}
