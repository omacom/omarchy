import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import "weather" as Weather
import "mocks"

ShellRoot {
  id: test
  property int phase: 0
  property bool failed: false
  property int before: 0
  function check(ok, message) {
    if (!ok) { failed = true; console.log("RESULT fail " + message) }
  }
  function count(prefix) {
    requests.reload()
    return requests.text().split("\n").filter(function(line) { return line.indexOf(prefix) === 0 }).length
  }
  FileView { id: response; path: Quickshell.env("HOME") + "/geo-response"; blockWrites: true; printErrors: false }
  FileView { id: requests; path: Quickshell.env("HOME") + "/requests"; blockAllReads: true; printErrors: false }
  Item {
    Weather.Panel {
      id: panel
      bar: QtObject {
        property color foreground: Commons.Color.foreground
        property color barForeground: Commons.Color.foreground
        property string fontFamily: Style.font.family
        property string position: "top"
        property int barSize: 24
        property bool vertical: false
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
    interval: 900
    repeat: true
    running: true
    onTriggered: {
      switch (test.phase++) {
      case 0:
        test.check(panel.reportLocation === "Bukit Jalil", "startup detects initial city: " + panel.reportLocation)
        response.setText('{"name":"Colombo","latitude":6.93,"longitude":79.86}')
        break
      case 1: panel.open(); break
      case 2:
        test.check(panel.reportLocation === "Colombo", "opening refreshes automatic city: " + panel.reportLocation)
        response.setText('{"name":"Kandy","latitude":7.29,"longitude":80.63}')
        break
      case 3: NetworkMock.network.name = "Second Wi-Fi"; break
      case 4:
        test.check(panel.reportLocation === "Kandy", "network switch refreshes city: " + panel.reportLocation)
        test.before = test.count("https://wttr.in/")
        panel.refresh()
        break
      case 5:
        test.check(test.count("https://wttr.in/") > test.before, "unchanged geo refreshes weather")
        response.setText("FAIL")
        break
      case 6:
        test.before = test.count("https://wttr.in/")
        panel.refresh()
        break
      case 7:
        test.check(panel.reportLocation === "Kandy", "failed lookup retains city")
        test.check(test.count("https://wttr.in/") > test.before, "failed geo refreshes weather")
        panel.configuredLocationState = {name: "Malibu", latitude: 34.02577, longitude: -118.7804}
        test.before = test.count("https://geo.omarchy.org/")
        panel.refresh()
        break
      case 8:
        test.check(panel.reportLocation === "Malibu", "refresh preserves pinned city")
        test.check(test.count("https://geo.omarchy.org/") === test.before, "pinned refresh skips geo")
        if (!test.failed) console.log("RESULT pass")
        Qt.quit()
      }
    }
  }
}
