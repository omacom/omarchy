import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons as Commons
import "weather" as Weather

ShellRoot {
  id: test
  property int stage: 0
  property int attempts: 0
  property int stoppedAt: 0
  property string stoppedRequests: ""

  function check(ok, message) {
    if (!ok) {
      console.log("RESULT fail " + message)
      Qt.quit()
    }
  }

  function findRadar(item) {
    if ("stationCache" in item) return item
    for (var i = 0; i < item.children.length; i++) {
      var found = findRadar(item.children[i])
      if (found) return found
    }
    return null
  }

  FileView {
    id: requests
    path: Quickshell.env("HOME") + "/network-urls"
    printErrors: false
  }

  Process {
    id: stoppedProcesses
    command: ["/bin/bash", "-c", 'while read -r radar_pid; do if kill -0 "$radar_pid" 2>/dev/null; then exit 1; fi; done <"$HOME/radar-pids"']
    onExited: function(exitCode) {
      test.check(exitCode === 0, "disabling radar cancels its pending transport process")
      console.log("RESULT pass")
      Qt.quit()
    }
  }

  QtObject {
    id: bar
    property color barForeground: foreground
    property color foreground: Commons.Color.popups.text
    property string fontFamily: Commons.Style.fontFamily
  }

  Weather.Panel {
    id: weather
    bar: bar
    settings: ({ radarEnabled: false })
    Component.onCompleted: controller.show()
  }

  Timer {
    interval: 100
    repeat: true
    running: true
    onTriggered: {
      test.attempts++
      if (test.attempts > 100) {
        test.check(false, "settings scenario timed out at " + test.stage)
        return
      }
      var radar = test.findRadar(weather)
      var urls = requests.text()
      requests.reload()
      if (test.stage === 0 && test.attempts > 7) {
        test.check(!weather.radarEnabled && !radar && urls === "", "explicit false creates no radar or NWS, IEM, or MIERUNE requests")
        weather.settings = {}
        test.stage++
      } else if (test.stage === 1 && radar && radar.ready(1) && urls.includes("/iem/")) {
        test.check(weather.radarEnabled && radar.implicitHeight > 0, "omitted radar setting loads visible frames by default")
        test.check(urls.includes("/nws/") && urls.includes("/scans/") && urls.includes("/mierune/") && urls.includes("/iem/"), "default radar requests station scans and both tile sources " + urls)
        radar.refreshedAt = 0
        radar.refresh()
        test.stage++
      } else if (test.stage === 2 && urls.split("/scans/").length === 3) {
        test.check(radar && radar.request, "refresh has a pending transport request")
        weather.settings = { radarEnabled: false }
        test.stoppedAt = test.attempts
        test.stage++
      } else if (test.stage === 3 && test.attempts > test.stoppedAt + 3) {
        test.check(!radar && !weather.radarEnabled, "turning radar off destroys its component")
        test.stoppedRequests = urls
        test.stage++
      } else if (test.stage === 4 && test.attempts > test.stoppedAt + 10) {
        test.check(urls === test.stoppedRequests, "disabled radar sends no further requests")
        test.stage++
        stoppedProcesses.running = true
      }
    }
  }
}
