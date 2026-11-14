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
  property int geoBefore: 0
  property bool watchingStale: false
  function check(ok, message) {
    if (!ok) { failed = true; requests.reload(); console.log("RESULT fail " + message + " requests=" + requests.text()) }
  }
  function count(prefix) {
    requests.reload()
    return requests.text().split("\n").filter(function(line) { return line.indexOf(prefix) === 0 }).length
  }
  FileView { id: forecastHold; path: Quickshell.env("HOME") + "/hold-forecast"; blockWrites: true; printErrors: false }
  FileView { id: release; path: Quickshell.env("HOME") + "/release-geo"; blockWrites: true; printErrors: false }
  FileView { id: response; path: Quickshell.env("HOME") + "/geo-response"; blockWrites: true; printErrors: false }
  FileView { id: requests; path: Quickshell.env("HOME") + "/requests"; blockAllReads: true; printErrors: false }
  Item {
    Weather.Panel {
      id: panel
      onReportLocationChanged: if (test.watchingStale && reportLocation === "Stale") test.check(false, "obsolete geo answer was displayed")
      onCurrentChanged: if (test.watchingStale && current && String(current.temp_C) === "11") test.check(false, "obsolete forecast was displayed")
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
        response.setText('{"name":"Kandy","latitude":7.29,"longitude":80.63}')
        panel.configuredLocationState = {name: "", latitude: null, longitude: null}
        break
      case 9:
        test.geoBefore = test.count("https://geo.omarchy.org/")
        test.before = test.count("https://wttr.in/")
        NetworkMock.wifi.networks = { values: [] }
        break
      case 10:
        NetworkMock.wifi.networks = { values: [NetworkMock.network] }
        break
      case 11:
        test.check(test.count("https://geo.omarchy.org/") === test.geoBefore, "scan churn does not detect location")
        test.check(test.count("https://wttr.in/") === test.before, "scan churn does not refresh weather")
        forecastHold.setText("hold")
        panel.refreshWeather()
        break
      case 12:
        response.setText('HOLD:{"name":"Stale","latitude":1,"longitude":2}')
        panel.refresh()
        break
      case 13:
        test.check(panel.detectingLocation, "old geo request is in flight")
        test.watchingStale = true
        response.setText('{"name":"Colombo","latitude":6.93,"longitude":79.86}')
        NetworkMock.network.name = "Third Wi-Fi"
        release.setText("release")
        break
      case 14:
        test.check(panel.reportLocation === "Colombo", "new network wins over in-flight geo: " + panel.reportLocation)
        test.check(panel.current && String(panel.current.temp_C) === "29", "new city's temperature is visible, current=" + JSON.stringify(panel.current))
        test.watchingStale = false
        if (!test.failed) console.log("RESULT pass")
        Qt.quit()
      }
    }
  }
}
