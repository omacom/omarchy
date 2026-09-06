import QtQuick
import Quickshell
import "Nightlight"

ShellRoot {
  id: harness

  property double now: Date.parse("2026-08-30T12:00:00-07:00")
  property int displayTemperature: 6500
  property int stage: 0
  property int evaluations: 0

  function fail(message) {
    console.log("RESULT fail " + message)
    Qt.quit()
  }

  Component.onCompleted: {
    // Advance wall time without advancing Qt's timers, as system suspend does.
    serviceLoader.active = true
  }

  Loader {
    id: serviceLoader
    active: false
    sourceComponent: Component {
      Service {
        shell: harness

        function refresh() {
          harness.evaluations += 1
          temperature = harness.displayTemperature
          var night = harness.now >= Date.parse("2026-08-30T19:20:00-07:00")
            && harness.now < Date.parse("2026-08-31T06:25:00-07:00")
          applySchedule({
            scheduled: true,
            night: night,
            timezone: "America/Los_Angeles",
            nextEvent: night ? "sunrise" : "sunset",
            nextEventAt: night ? "2026-08-31T06:25:00-07:00"
              : (harness.stage === 0 ? "2026-08-30T19:20:00-07:00" : "2026-08-31T19:19:00-07:00")
          })
        }

        function runApply(temp) {
          harness.displayTemperature = temp
        }
      }
    }
  }

  Timer {
    interval: 1500
    running: true
    repeat: true
    onTriggered: {
      if (harness.stage === 0) {
        if (harness.displayTemperature !== 6500) {
          harness.fail("daylight did not start at 6500K")
          return
        }
        if (harness.evaluations !== 1) {
          harness.fail("an unchanged wall clock repeatedly evaluated the schedule")
          return
        }
        harness.stage = 1
        harness.now = Date.parse("2026-08-30T22:00:00-07:00")
      } else if (harness.stage === 1) {
        if (harness.displayTemperature !== 4000) {
          harness.fail("waking after sunset left the display at " + harness.displayTemperature + "K")
          return
        }
        harness.stage = 2
        harness.displayTemperature = 6500
        harness.now = Date.parse("2026-08-30T23:00:00-07:00")
      } else if (harness.stage === 2) {
        if (harness.displayTemperature !== 4000) {
          harness.fail("a nighttime display reset was not corrected after wake")
          return
        }
        harness.stage = 3
        harness.now = Date.parse("2026-08-31T08:00:00-07:00")
      } else if (harness.stage === 3) {
        if (harness.displayTemperature !== 6500) {
          harness.fail("waking after sunrise left the display at " + harness.displayTemperature + "K")
          return
        }
        harness.stage = 4
        harness.now = Date.parse("2026-08-30T22:00:00-07:00")
      } else if (harness.stage === 4) {
        if (harness.displayTemperature !== 4000) {
          harness.fail("moving the clock backward into nighttime did not warm the display")
          return
        }
        harness.stage = 5
        serviceLoader.item.scheduled = false
        harness.displayTemperature = 6500
        harness.now = Date.parse("2026-08-30T23:00:00-07:00")
      } else {
        if (harness.displayTemperature !== 6500) {
          harness.fail("resume overrode manual daylight mode")
          return
        }
        console.log("RESULT pass")
        Qt.quit()
      }
    }
  }
}
