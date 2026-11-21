import QtQuick
import Quickshell
import "tailscale" as Tailscale

// Drives the Tailscale widget's service against a stand-in tailscale that
// refuses up/down from anyone but its operator, and a stand-in pkexec. The
// action under test comes from TAILSCALE_TEST_ACTION ("up" or "down"); the
// shell script reads what ran from the stand-ins' logs.
ShellRoot {
  id: test
  readonly property string action: Quickshell.env("TAILSCALE_TEST_ACTION") || "up"
  property int phase: 0
  property int ticks: 0

  Tailscale.Service {
    id: service
    settings: ({ refreshIntervalSec: 3600 })
  }

  // Every status line the widget shows, for the script to read.
  Connections {
    target: service
    function onActionStatusChanged() { if (service.actionStatus !== "") console.log("STATUS " + service.actionStatus) }
  }

  Timer {
    interval: 100
    running: true
    repeat: true
    onTriggered: {
      test.ticks++
      if (test.phase === 0 && service.installed && service.backendState !== "Unknown" && !service.busy) {
        test.phase = 1
        if (test.action === "down") service.down()
        else service.loginOrUp()
      } else if (test.phase === 1 && test.ticks > 30 && !service.busy) {
        console.log("RESULT done")
        Qt.quit()
      }
      if (test.ticks > 100) {
        console.log("RESULT timeout")
        Qt.quit()
      }
    }
  }
}
