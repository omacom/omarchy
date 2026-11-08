import QtQuick
import Quickshell
import qs.Commons
import qs.Commons as Commons
import "mocks"
import "network" as Network

// Offline, the panel brings the first-run Wi-Fi card back when it closes, but
// only after the card opened it. The runner logs each card it is asked for.
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

  Component.onCompleted: {
    NetworkMock.network.connected = false
    NetworkMock.wifi.connected = false
    check(panel.kind === "disconnected", "the fixture starts offline")
    panel.open()
    panel.close()
    panel.cardOpened = true
    panel.open()
    panel.close()
    check(!panel.cardOpened, "closing forgets that the card opened the panel")
    // execDetached returns before the stub has written.
    done.start()
  }

  Timer {
    id: done
    interval: 500
    onTriggered: {
      if (!test.failed) console.log("RESULT pass")
      Qt.quit()
    }
  }
}
