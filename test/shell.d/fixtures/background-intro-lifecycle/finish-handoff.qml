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
  Timer {
    interval: 100
    running: true
    onTriggered: {
      test.services = ({ "omarchy.background": retainedBackground })
      intro.prepareTheme(Quickshell.env("INTRO_TEST_COVER"), "switch", "", "")
    }
  }
  Timer {
    interval: 200
    running: true
    onTriggered: intro.finishTheme("switch")
  }
  Timer {
    interval: 300
    running: true
    onTriggered: {
      test.check(intro.themeToken === "switch", "the cover stays while OWE holds the desktop")
      retainedBackground.ready = false
      retainedBackground.suspended = false
    }
  }
  Timer {
    interval: 400
    running: true
    onTriggered: {
      test.check(intro.themeToken === "switch", "the cover stays while the new still decodes")
      retainedBackground.ready = true
    }
  }
  Timer {
    interval: 500
    running: true
    onTriggered: {
      test.check(intro.themeToken === "", "the cover fades once the still is on screen")
      if (!test.failed) console.log("RESULT pass")
      Qt.quit()
    }
  }
}
