import QtQuick
import Quickshell
import qs.Commons
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
  function rowIndex(ssid) {
    for (var i = 0; i < panel.wifiNetworks.length; i++) {
      if (panel.wifiNetworks[i].ssid === ssid) return i
    }
    return -1
  }

  // Never opened: the checks drive the panel's own row model and activation.
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

  Timer {
    interval: 250
    running: true
    onTriggered: {
      var index = test.rowIndex("Phone Hotspot")
      test.check(index >= 0 && !panel.wifiNetworks[index].known, "hotspot is listed before its profile attaches")
      test.check(index > test.rowIndex("Neighbor"), "unsaved rows sort by signal")
      // The list itself is unchanged; only the listed network's flag flips.
      NetworkMock.hotspot.known = true
      attached.start()
    }
  }

  Timer {
    id: attached
    interval: 50
    onTriggered: {
      var index = test.rowIndex("Phone Hotspot")
      test.check(index >= 0 && panel.wifiNetworks[index].known, "attached profile marks the listed row known")
      test.check(index < test.rowIndex("Neighbor"), "attached profile moves the row into known networks")
      panel.selectedIndex = index
      panel.activateSelected()
      test.check(panel.passwordSsid === "", "activating the saved network does not ask for its password")
      test.check(NetworkMock.hotspot.connects === 1, "activating the saved network connects with its profile")
      if (!test.failed) console.log("RESULT pass")
      Qt.quit()
    }
  }
}
