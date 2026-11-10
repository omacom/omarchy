import QtQuick
import Quickshell
import Quickshell.Io
import "services"

ShellRoot {
  id: test
  property bool failed: false
  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  // A shell whose bar fades itself in: `late` builds its widgets after the
  // intro is on screen, `early` before.
  component Host: QtObject {
    property var services: ({})
    function firstPartyServiceFor(id) { return services[id] || null }
    property bool pluginWidgetsLoaded: false
    property var bar: QtObject {
      property bool startupRevealed: false
      property int startupRevealDuration: 0
      property int layoutRevision: 0
    }
  }

  Host { id: late }
  Host { id: early; pluginWidgetsLoaded: true }
  QtObject { id: lateBackground; property bool suspended: false }
  QtObject { id: earlyBackground; property bool suspended: false }
  BackgroundIntro { id: lateIntro; host: late }
  BackgroundIntro { id: earlyIntro; host: early }

  Process {
    id: showFrame
    command: ["touch", Quickshell.env("INTRO_TEST_SHOWN")]
  }

  // Each step runs a set delay after the one before it ran, always in order;
  // see switch-sequence.qml.
  property int step: 0
  readonly property var steps: [
    { delay: 100, run: function() {
      late.services = ({ "omarchy.background": lateBackground })
      early.services = ({ "omarchy.background": earlyBackground })
    } },
    { delay: 200, run: function() {
      lateBackground.suspended = true
      earlyBackground.suspended = true
    } },
    { delay: 400, run: function() {
      test.check(!earlyIntro.barRevealed, "a built bar waits for the desktop to reveal")
      showFrame.running = true
    } },
    { delay: 300, run: function() {
      test.check(lateIntro.revealing || !lateIntro.startupPending, "the desktop reveals while the bar's widgets build")
      test.check(!lateIntro.barRevealed, "a bar still building stays hidden")
      test.check(earlyIntro.barRevealed && earlyIntro.barRevealDuration === 0, "a bar built before the reveal is uncovered with the desktop")
      late.pluginWidgetsLoaded = true
    } },
    { delay: 150, run: function() {
      test.check(!lateIntro.barRevealed, "a built bar waits for its widgets to fill in")
      late.bar.layoutRevision += 1
    } },
    { delay: 120, run: function() {
      test.check(!lateIntro.barRevealed, "a widget filling in restarts the wait")
    } },
    { delay: 330, run: function() {
      test.check(lateIntro.barRevealed, "a bar that holds still fades in")
      test.check(lateIntro.barRevealDuration > 0, "a bar built after the reveal fades in on its own")
      test.check(!lateIntro.startupSettling, "startup work waits no longer once the bar shows")
    } },
    { delay: 500, run: function() {
      test.check(!lateIntro.startupPending && !earlyIntro.startupPending, "both logins finish revealing")
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
