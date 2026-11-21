import QtQuick
import Quickshell
import "power"

// The real power panel with no battery behind it (the test runs with a
// dead system bus, so UPower has no display device): opening it must
// settle closed again without a binding loop, on laptops too, where
// the runtime smoke check cannot reach this path.
ShellRoot {
  id: test
  property bool failed: false
  property bool writeExited: false
  property int writeRefreshes: 0

  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  Panel {
    id: panel
  }

  Panel {
    id: writePanel
    function refreshChargeLimit() {
      test.check(test.writeExited, "charge-limit refresh waits for the action's exit handlers")
      test.writeRefreshes++
    }
  }

  Timer {
    interval: 300
    running: true
    onTriggered: {
      test.check(panel.batteryPresent === false, "fixture has no battery")

      // Exercise the real panel controller with both completion orders. A
      // transient failure keeps its last good policy and leaves no cursor on
      // a control whose current state is unavailable.
      panel.chargeLimitInfo = { state: "on", policy: "end", start: 0, end: 60 }
      panel.chargeLimitFocused = true
      panel.chargeLimitReading = true
      panel.chargeLimitReadOutput = ""
      panel.chargeLimitReadExitCode = null
      panel.finishChargeLimitRead()
      test.check(panel.chargeLimitReading, "empty stdout waits for process exit")
      panel.chargeLimitReadExitCode = 1
      panel.finishChargeLimitRead()
      test.check(panel.chargeLimitReadFailed && !panel.chargeLimitReading, "failed read settles as unavailable")
      test.check(panel.chargeLimitInfo.state === "on" && panel.chargeLimitInfo.end === 60, "failed read preserves the last good policy")
      test.check(!panel.chargeLimitFocused, "failed read releases the charge cursor")

      panel.chargeLimitReading = true
      panel.chargeLimitReadOutput = null
      panel.chargeLimitReadExitCode = 0
      panel.finishChargeLimitRead()
      test.check(panel.chargeLimitReading && panel.chargeLimitReadFailed, "exit before stdout cannot clear the read failure")
      panel.chargeLimitReadOutput = "state\toff\npolicy\trange\nstart\t75\nend\t80\n"
      panel.finishChargeLimitRead()
      test.check(!panel.chargeLimitReadFailed && panel.chargeLimitInfo.state === "off" && panel.chargeLimitInfo.end === 80, "a complete successful read recovers the actual policy")
      panel.open()

      // The dead system bus makes this real command fail without touching
      // hardware. Refresh must follow the exit signal on failures too.
      writePanel.chargeLimitInfo = { state: "off", policy: "firmware", start: 0, end: 0 }
      writePanel.setChargeLimit(true)
      for (var i = 0; i < writePanel.resources.length; i++) {
        var process = writePanel.resources[i]
        if (process.command && process.command[1] === "on") {
          process.exited.connect(function() { test.writeExited = true })
        }
      }
    }
  }

  Timer {
    interval: 900
    running: true
    onTriggered: {
      test.check(panel.opened === false, "panel without a battery settles closed after open")
      test.check(test.writeExited && test.writeRefreshes === 1, "a completed charge-limit action schedules one refresh")
      console.log(test.failed ? "RESULT fail" : "RESULT pass")
      Qt.quit()
    }
  }
}
