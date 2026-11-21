import QtQuick
import Quickshell
import Quickshell.Io
import "services"

ShellRoot {
  id: test
  property bool failed: false
  property var services: ({})
  readonly property string newVideo: Quickshell.env("VIDEO_TEST_NEW")
  function firstPartyServiceFor(id) { return services[id] || null }
  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  // A video replaces a video: OWE holds the desktop before and after, so the
  // shell's background never turns ready, and the cover lifts once OWE shows
  // the new video, even paused on its first frame.
  QtObject { id: videoBackground; property bool suspended: true; property bool ready: true }
  BackgroundIntro { id: intro; host: test }

  Process { id: showNew; command: ["cp", Quickshell.env("VIDEO_TEST_NEW_STATUS"), Quickshell.env("VIDEO_TEST_SHOWN")] }

  // Each step runs a set delay after the one before it ran, always in order;
  // see switch-sequence.qml.
  property int step: 0
  readonly property var steps: [
    { delay: 100, run: function() {
      test.services = ({ "omarchy.background": videoBackground })
      intro.prepareTheme(Quickshell.env("INTRO_TEST_COVER"), "switch", "", "")
    } },
    { delay: 100, run: function() {
      intro.finishTheme("switch", true, test.newVideo)
    } },
    { delay: 400, run: function() {
      test.check(intro.themeToken === "switch", "the cover stays while OWE still shows the outgoing video")
      showNew.running = true
    } },
    { delay: 600, run: function() {
      test.check(intro.themeToken === "", "the cover opens once OWE shows the new video")
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
