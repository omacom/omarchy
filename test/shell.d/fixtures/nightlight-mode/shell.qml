import QtQuick
import Quickshell
import Quickshell.Io
import "Nightlight"

ShellRoot {
  id: harness

  property int temperature: 6500

  Service {
    id: service

    function refresh() {}

    function runApply(temp) {
      harness.temperature = temp
    }
  }

  Component.onCompleted: Qt.callLater(function() {
    service.scheduleLoaded = true
    service.setScheduleEnabled(true)
    service.setNightlight(true)
    settled.start()
  })

  Timer {
    id: settled
    interval: 20
    repeat: true
    onTriggered: {
      if (service.requestedSchedule !== null) return
      stop()
      savedMode.running = true
    }
  }

  Process {
    id: savedMode
    command: ["bash", "-c", 'cat "$OMARCHY_NIGHTLIGHT_STATE" "$OMARCHY_NIGHTLIGHT_STATE.writes"']
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        if (text.trim() !== "manual\nenable\ndisable" || harness.temperature !== 4000) {
          console.log("RESULT fail newer manual selection lost: " + text + " temperature=" + harness.temperature)
        } else {
          console.log("RESULT pass")
        }
        Qt.quit()
      }
    }
  }
}
