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

  QtObject { id: retainedBackground; property bool suspended: true; property bool ready: true }
  BackgroundIntro { id: intro; host: test }

  // A switch finished while OWE still holds the desktop, as when a change
  // without an intro of its own cuts a playing one short: the cover waits for
  // the shell's wallpaper to be back and decoded before it fades.
  // Each step runs a set delay after the one before it ran, always in order;
  // see switch-sequence.qml.
  property int step: 0
  readonly property var steps: [
    { delay: 100, run: function() {
      test.services = ({ "omarchy.background": retainedBackground })
      intro.prepareTheme(Quickshell.env("INTRO_TEST_COVER"), "switch", "", "")
    } },
    { delay: 100, run: function() {
      intro.finishTheme("switch", true)
    } },
    { delay: 100, run: function() {
      test.check(intro.themeToken === "switch", "the cover stays while OWE holds the desktop")
      retainedBackground.ready = false
      retainedBackground.suspended = false
    } },
    { delay: 100, run: function() {
      test.check(intro.themeToken === "switch", "the cover stays while the new still decodes")
      retainedBackground.ready = true
    } },
    { delay: 100, run: function() {
      // The cover opens with the background's slanted cut rather than fading.
      test.check(intro.themeToken === "", "the cover opens once the still is on screen")
      test.check(intro.themeBackground !== "" && intro.themeOpacity === 1 && intro.themeCutProgress > 0,
                 "the cover stays drawn while the cut opens")
      test.check(intro.themeStatus("switch") === "pending", "the switch is pending until the cut ends")
    } },
    { delay: 1100, run: function() {
      test.check(intro.themeBackground === "" && intro.themeStatus("switch") === "ready", "the cover is gone once the cut ends")
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
