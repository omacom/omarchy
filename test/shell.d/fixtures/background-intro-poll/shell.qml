import QtQuick
import Quickshell
import Quickshell.Io
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

  QtObject { id: retainedBackground; property bool suspended: false }
  BackgroundIntro { id: intro; host: test }

  Process {
    id: mark
    command: ["touch", Quickshell.env("INTRO_TEST_MARK")]
  }

  // A login: the intro launcher is still running when the background
  // service appears, then OWE takes the background for the intro video and
  // hands it back once the launcher has finished.
  Timer {
    interval: 100
    running: true
    onTriggered: test.services = ({ "omarchy.background": retainedBackground })
  }
  Timer {
    interval: 300
    running: true
    onTriggered: {
      test.check(intro.cover, "the cover stays while the launcher runs")
      retainedBackground.suspended = true
    }
  }
  Timer {
    interval: 1300
    running: true
    onTriggered: {
      test.check(intro.startupSettled, "the launcher has finished")
      retainedBackground.suspended = false
    }
  }
  Timer {
    interval: 1400
    running: true
    onTriggered: {
      test.check(!intro.cover && !intro.themeToken, "the handed-back background releases the cover")
      mark.running = true
    }
  }
  Timer {
    interval: 2400
    running: true
    onTriggered: {
      if (!test.failed) console.log("RESULT pass")
      Qt.quit()
    }
  }
}
