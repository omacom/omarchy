import QtQuick
import Quickshell
import "services"

ShellRoot {
  id: test
  property bool failed: false
  property var services: ({})
  function firstPartyServiceFor(id) { return services[id] || null }
  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  QtObject { id: background; property bool suspended: false }
  BackgroundIntro { id: intro; host: test }

  // A login with no intro whose shell was not up for OWE's handoff: OWE
  // draws the still itself and keeps the shell's background off.
  Timer {
    interval: 100
    running: true
    onTriggered: test.services = ({ "omarchy.background": background })
  }
  Timer {
    interval: 300
    running: true
    onTriggered: {
      test.check(intro.cover, "the cover stays while the launcher runs")
      background.suspended = true
    }
  }
  Timer {
    interval: 2600
    running: true
    onTriggered: {
      test.check(intro.startupSettled, "the launcher has finished")
      test.check(!intro.cover, "OWE's still releases the cover while the shell's background stays off")
      if (!test.failed) console.log("RESULT pass")
      Qt.quit()
    }
  }
}
