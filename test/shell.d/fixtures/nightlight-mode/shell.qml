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

  Loader {
    id: unavailableService
    active: false
    sourceComponent: Component { Service {} }
  }

  Timer {
    id: retryObservation
    interval: 800
    onTriggered: applyCount.running = true
  }

  Process {
    id: applyCount
    command: ["bash", "-c", 'wc -l < "$HYPRSUNSET_CALL_LOG"']
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var count = parseInt(text.trim(), 10)
        if (count !== 1) {
          console.log("RESULT fail unavailable hyprsunset received " + count + " apply attempts")
          Qt.quit()
        } else {
          makeAvailable.running = true
        }
      }
    }
  }

  Process {
    id: makeAvailable
    command: ["touch", Quickshell.env("HYPRSUNSET_AVAILABLE")]
    onExited: {
      unavailableService.item.refresh()
      recoveryCount.running = true
    }
  }

  Process {
    id: recoveryCount
    command: ["bash", "-c", 'until [[ $(<"$HYPRSUNSET_STATE") == "4000" ]]; do sleep 0.05; done; wc -l < "$HYPRSUNSET_CALL_LOG"']
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var count = parseInt(text.trim(), 10)
        if (count !== 2 || unavailableService.item.temperature !== 4000) {
          console.log("RESULT fail explicit refresh did not recover automatic night light")
          Qt.quit()
        } else {
          failNextApply.running = true
        }
      }
    }
  }

  Process {
    id: failNextApply
    command: ["touch", Quickshell.env("HYPRSUNSET_FAIL_NEXT")]
    onExited: {
      unavailableService.item.setNightlight(false)
      unavailableService.item.setNightlight(true)
      pendingResult.running = true
    }
  }

  Process {
    id: pendingResult
    command: ["bash", "-c", 'until (( $(wc -l < "$HYPRSUNSET_SUCCESS_LOG") >= 2 )); do sleep 0.05; done; tail -n 2 "$HYPRSUNSET_CALL_LOG"']
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        if (text.trim() !== "6500\n4000" || unavailableService.item.scheduled || unavailableService.item.temperature !== 4000)
          console.log("RESULT fail newer manual temperature lost after failed apply: " + text)
        else
          console.log("RESULT pass")
        Qt.quit()
      }
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
          Qt.quit()
        } else {
          prepareAutomatic.running = true
        }
      }
    }
  }

  Process {
    id: prepareAutomatic
    command: ["bash", "-c", 'printf "solar\\n" > "$OMARCHY_NIGHTLIGHT_STATE"']
    onExited: {
      unavailableService.active = true
      retryObservation.start()
    }
  }
}
