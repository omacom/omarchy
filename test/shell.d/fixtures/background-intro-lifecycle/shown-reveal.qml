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
    id: showFrame
    command: ["touch", Quickshell.env("INTRO_TEST_SHOWN")]
  }

  // A login whose launcher reports the intro's first frame: OWE takes the
  // background, the launcher says "shown", and the cover lifts on that line
  // without a single frame poll, asking OWE to play the held clip as it does.
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
    { delay: 400, run: function() {
      test.check(intro.cover && intro.startupPending, "the cover waits for the first frame")
      showFrame.running = true
    } },
    { delay: 300, run: function() {
      test.check(!intro.cover, "the reported first frame releases the cover")
      test.check(intro.revealing || !intro.startupPending, "the login reveal starts on the reported first frame")
    } },
    { delay: 700, run: function() {
      test.check(!intro.startupPending, "the login reveal finishes")
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
