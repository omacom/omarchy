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

  QtObject { id: retainedBackground; property bool suspended: false }
  BackgroundIntro { id: intro; host: test }

  // A launcher that announces a reported first frame and never reports it,
  // as a new owe CLI beside a daemon that predates the report would: the
  // cover falls back to polling OWE rather than waiting out its deadline.
  // Each step runs a set delay after the one before it ran, always in order;
  // see switch-sequence.qml.
  property int step: 0
  readonly property var steps: [
    { delay: 100, run: function() {
      test.services = ({ "omarchy.background": retainedBackground })
    } },
    { delay: 200, run: function() {
      test.check(intro.introReported, "the launcher announces that it will report the first frame")
      retainedBackground.suspended = true
    } },
    { delay: 1000, run: function() {
      test.check(intro.cover, "the cover first waits for the report")
    } },
    { delay: 1500, run: function() {
      test.check(!intro.cover, "without a report the frame poll releases the cover")
      if (!test.failed) console.log("RESULT pass")
      Qt.quit()
    } }
  ]
  Timer {
    interval: test.steps[0].delay
    running: true
    onTriggered: {
      test.steps[test.step].run()
      test.step++
      if (test.step < test.steps.length) {
        interval = test.steps[test.step].delay
        start()
      }
    }
  }
}
