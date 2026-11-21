import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import qs.Commons
import qs.Commons as Commons
import "mocks"
import "network" as Network

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

  // Wi-Fi is present but not connected, and nothing is online yet, so the
  // modem will be the only way out and the bar falls back to it.
  Component.onCompleted: {
    NetworkMock.wifi.connected = false
    NetworkMock.network.connected = false
    NetworkMock.network.known = false
    NetworkMock.connectivity = NetworkConnectivity.None
  }

  // ModemManager has not found the modem when the shell starts. It turns up
  // later, and NetworkManager's connectivity change must make the panel look
  // again without the panel being opened.
  Timer {
    interval: 1000
    running: true
    onTriggered: {
      test.check(!panel.mobile.available, "startup probe finds no modem yet")
      test.check(panel.kind === "disconnected", "nothing is connected before the modem")
      modemArrives.running = true
    }
  }

  Process {
    id: modemArrives
    command: ["bash", "-c", "printf 'disconnected\\n' > \"$NETWORK_TEST_STATE\""]
    onExited: {
      NetworkMock.connectivity = NetworkConnectivity.Full
      afterArrival.start()
    }
  }

  // The late probe finds a disconnected modem. The stubbed gdbus then
  // reports it connected, which must reach the panel without any polling.
  Timer {
    id: afterArrival
    interval: 2500
    onTriggered: {
      test.check(panel.testEnsureContent() !== null, "panel content builds on demand")
      test.check(panel.mobile.available, "connectivity change finds the late modem")
      test.check(panel.mobile.state === "connected", "ModemManager event re-probes the modem")
      test.check(panel.kind === "mobile", "modem is the connection when Wi-Fi and wired are down")
      test.check(panel.icon === "󰢽", "bar shows cellular bars for the modem's signal")
      test.check(panel.testMobileRow.visible, "mobile broadband row is shown")
      test.check(panel.testMobileRow.statusText === "LTE · 70% · Connected", "row reads technology, signal and state: " + panel.testMobileRow.statusText)

      // The existing cursor model walks DNS -> modem -> Wi-Fi and back.
      panel.cursorActive = true
      panel.focusSection = "dns"
      panel.testKeys.moveRequested(0, 1)
      test.check(panel.focusSection === "mobile", "down from DNS reaches the modem row")
      panel.testKeys.moveRequested(0, 1)
      test.check(panel.focusSection === "wifi" && panel.selectedIndex === 0, "down from the modem reaches the Wi-Fi list")
      panel.testKeys.moveRequested(0, -1)
      test.check(panel.focusSection === "mobile", "up from the first network returns to the modem row")
      panel.testKeys.activateRequested(Qt.NoModifier)
      test.check(panel.mobileActionKind === "disconnect", "activating a connected modem disconnects it")
      afterDisconnect.start()
    }
  }

  Timer {
    id: afterDisconnect
    interval: 1500
    onTriggered: {
      test.check(panel.mobileActionKind === "", "disconnect finishes")
      test.check(panel.mobile.state === "disconnected" && panel.kind === "disconnected", "disconnected modem leaves no connection")
      test.check(panel.testMobileRow.statusText === "LTE · 70%", "disconnected row keeps signal without state: " + panel.testMobileRow.statusText)
      panel.testKeys.activateRequested(Qt.NoModifier)
      test.check(panel.mobileActionKind === "connect", "activating a disconnected modem connects its profile")
      afterConnect.start()
    }
  }

  Timer {
    id: afterConnect
    interval: 1500
    onTriggered: {
      test.check(panel.mobile.state === "connected" && panel.kind === "mobile", "profile comes back up")
      test.check(panel.testTitle.text === "Test Carrier (lte)", "hero names the mobile connection: " + panel.testTitle.text)
      panel.testKeys.moveRequested(0, -1)
      test.check(panel.focusSection === "dns", "up from the modem row returns to DNS")
      if (failed) { Qt.quit(); return }
      console.log("RESULT pass")
      if (Quickshell.env("NETWORK_TEST_SCREENSHOT")) {
        panel.open()
        previewCapture.start()
      } else {
        Qt.quit()
      }
    }
  }

  // Optional panel-only capture from fixture data alone:
  // NETWORK_TEST_SCREENSHOT=/tmp/mobile.png
  Timer {
    id: previewCapture
    interval: 750
    onTriggered: {
      // Content root -> Loader -> content holder -> card.
      var card = panel.testKeys.parent.parent.parent
      card.grabToImage(function(result) {
        test.check(result.saveToFile(Quickshell.env("NETWORK_TEST_SCREENSHOT")), "save preview screenshot")
        Qt.quit()
      })
    }
  }
}
