import QtQuick
import Quickshell
import Quickshell.Networking
import qs.Commons
import qs.Ui
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

  // Same collapsing Text/header shape as the list, so a height bind would
  // warn even if KeyboardPanel never maps delegates in this fixture.
  Column {
    width: 320
    spacing: 4

    PanelSectionHeader {
      visible: true
      text: "KNOWN NETWORKS"
      foreground: Color.foreground
      fontFamily: Style.font.family
    }

    Text {
      textFormat: Text.PlainText
      text: "Connected"
      visible: true
      width: parent.width
      color: Color.foreground
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
    }
  }

  Timer {
    interval: 250
    running: true
    onTriggered: {
      check(panel.wifiNetworks.length === 3, "fixture projects the mocked wifi rows")
      check(panel.wifiSectionTitle(0) === "KNOWN NETWORKS", "connected/known rows get a section header")
      check(panel.wifiSectionTitle(2) === "OTHER NETWORKS", "unknown rows get a section header")
      check(NetworkMock.guest.connectCalls === 0, "construction does not activate a connection")

      panel.connectDirectly("Cafe")
      check(NetworkMock.cafe.connectCalls === 0, "closed panel does not activate")
      panel.setBand("5")

      panel.open()
      panel.layoutBusy = true
      panel.connectDirectly("Cafe")
      check(NetworkMock.cafe.connectCalls === 0, "settling list does not activate")
      panel.setBand("5")

      panel.layoutBusy = false
      panel.connectDirectly("Guest Wi-Fi")
      check(NetworkMock.guest.connectCalls === 0, "already-connected network does not reconnect")

      panel.connectDirectly("Cafe")
      check(NetworkMock.cafe.connectCalls === 1, "open settled panel can activate a disconnected known network")
      panel.clearNetworkAction()

      NetworkMock.cafe.signalStrength = 0.2
      NetworkMock.wifi.networks = { values: [NetworkMock.guest, NetworkMock.cafe] }
      check(panel.layoutBusy, "a real list change marks the layout busy")
      panel.connectDirectly("Cafe")
      check(NetworkMock.cafe.connectCalls === 1, "list churn does not activate during settle")
      panel.setBand("5")

      if (failed) {
        Qt.quit()
        return
      }
      console.log("RESULT pass")
      done.start()
    }
  }

  Timer {
    id: done
    interval: 300
    onTriggered: Qt.quit()
  }
}
