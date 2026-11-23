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

  // A login whose intro ends on a still: the launcher is still running
  // when the background service appears, then OWE takes the background for
  // the intro and hands it back once the launcher has finished.
  // Wait for launcher completion instead of assuming its process exits in
  // the gap between two timer ticks.
  readonly property var steps: [
    { delay: 100, run: function() {
      test.services = ({ "omarchy.background": retainedBackground })
    } },
    { delay: 200, run: function() {
      test.check(intro.cover, "the cover stays while the launcher runs")
      retainedBackground.suspended = true
    } },
    { until: function() { return intro.startupSettled },
      waitFor: "the intro launcher to finish", run: function() {
      test.check(intro.startupSettled, "the launcher has finished")
      retainedBackground.suspended = false
    } },
    { delay: 100, run: function() {
      test.check(!intro.cover && !intro.themeToken, "the handed-back background releases the cover")
      mark.running = true
    } },
    { delay: 1000, run: function() {
      if (!test.failed) console.log("RESULT pass")
      Qt.quit()
    } }
  ]
  StepSequence { steps: test.steps }
}
