import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import qs.Commons
import qs.Commons as Commons
import "mocks"
import "weather" as Weather

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
    Weather.Panel {
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

  // The staged retry timers run every 100 ms, so by now the startup fetch has
  // used all its retries against the failing curl.
  Timer {
    interval: 1500
    running: true
    onTriggered: {
      test.check(panel.label === "", "label stays empty while the network is down")
      network.running = true
    }
  }

  Process {
    id: network
    command: ["touch", Quickshell.env("WEATHER_TEST_ONLINE")]
    onExited: {
      NetworkMock.connectivity = NetworkConnectivity.Full
      verify.start()
    }
  }

  Timer {
    id: verify
    interval: 2000
    onTriggered: {
      test.check(panel.label !== "", "label fills once connectivity becomes Full")
      if (!test.failed) console.log("RESULT pass")
      Qt.quit()
    }
  }
}
