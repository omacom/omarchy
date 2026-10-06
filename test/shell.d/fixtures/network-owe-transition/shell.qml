import QtQuick
import Quickshell
import qs.Commons
import "mocks"
import "network" as Network
import "network/Model.js" as Model

// Drives the bar state through an OWE transition-mode scan cycle: the
// connected network drops out of the device's list between scans while the
// device itself stays connected. The runner stubs nmcli to answer, in order,
// 57, then a slow stale 11, then 33.
ShellRoot {
  id: test
  property bool failed: false
  property int checksBefore: 0
  property var listed: ({ values: [NetworkMock.network] })
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
        property color foreground: Color.foreground
        property color barForeground: Color.foreground
        property color urgent: Color.urgent
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

  function unlist() { NetworkMock.wifi.networks = { values: [] } }
  function relist() { NetworkMock.wifi.networks = test.listed }

  Timer {
    interval: 250
    running: true
    onTriggered: {
      test.check(panel.kind === "wifi" && panel.signalStrength === 80, "listed network supplies its own strength")
      test.check(!panel.testApPoll.running, "a network with its own strength adds no polling")
      test.check(panel.connectionKey === "wifi:test-wifi", "Wi-Fi connection key follows the device")
      test.checksBefore = NetworkMock.checks
      test.unlist()
      Qt.callLater(test.unlistedChecks)
    }
  }

  function unlistedChecks() {
    check(panel.kind === "wifi", "connected device keeps Wi-Fi when no network is listed as connected")
    check(panel.icon !== "󰤮", "unlisted network does not flicker to the disconnected icon")
    check(panel.testApPoll.running, "missing strength starts the in-use access point poll")
    check(panel.connectionKey === "wifi:test-wifi", "connection key survives the listed network disappearing")
    firstReading.start()
  }

  Timer {
    id: firstReading
    interval: 600
    onTriggered: {
      test.check(panel.activeApSignal === 57 && panel.signalStrength === 57, "in-use access point strength fills the gap")
      test.check(panel.icon === Model.wifiIconFor(57), "bar icon follows the in-use access point strength")
      test.relist()
      Qt.callLater(test.relistedChecks)
    }
  }

  function relistedChecks() {
    check(panel.signalStrength === 80 && !panel.testApPoll.running, "a relisted network takes over and stops the poll")
    check(NetworkMock.checks === checksBefore, "scan churn schedules no extra connectivity checks")
    // Second nmcli read is slow; drop the link while it is in flight.
    unlist()
    Qt.callLater(dropWhileReading)
  }

  function dropWhileReading() {
    NetworkMock.wifi.connected = false
    Qt.callLater(function() {
      check(panel.kind === "disconnected" && panel.icon === "󰤮", "a real disconnect still shows disconnected")
      check(panel.activeApSignal === -1 && !panel.testApPoll.running, "disconnect clears the cached strength and stops polling")
      NetworkMock.wifi.connected = true
      staleReading.start()
    })
  }

  Timer {
    id: staleReading
    interval: 1500
    onTriggered: {
      test.check(panel.activeApSignal === 33, "a read from before the reset is discarded and re-read (got " + panel.activeApSignal + ")")
      NetworkMock.wifi.connected = false
      Qt.callLater(test.finalChecks)
    }
  }

  function finalChecks() {
    check(panel.activeApSignal === -1 && !panel.testApPoll.running, "final disconnect clears the reading")
    if (!failed) console.log("RESULT pass")
    done.start()
  }

  Timer { id: done; interval: 200; onTriggered: Qt.quit() }
}
