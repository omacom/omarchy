import QtQuick
import Quickshell
import "services"

ShellRoot {
  id: test
  property var services: ({})
  property var pluginRegistry: null
  property var bar: null
  property bool failed: false
  property bool lifted: false
  property bool fullAtLift: false
  function firstPartyServiceFor(id) { return services[id] || null }
  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  QtObject {
    id: background
    property bool suspended: false
    property bool ready: true
  }
  BackgroundIntro {
    id: intro
    host: test
    onStartupOpacityChanged: if (!test.lifted && startupOpacity < 1) { test.lifted = true; test.fullAtLift = splashBarFull }
  }

  // The stub says Plymouth's bar started 7.5 s before the shell.
  Timer {
    interval: 400
    running: true
    onTriggered: {
      test.check(intro.splashBarShown(), "a boot whose splash showed a bar draws it in the cover")
      test.check(Math.abs(intro.splashBarElapsed() - 7.9) < 0.2, "the bar carries on from where Plymouth's stands, at " + intro.splashBarElapsed() + " s")
      test.services = ({ "omarchy.background": background })
      test.bar = ({})
    }
  }
  Timer {
    interval: 500
    running: true
    onTriggered: test.check(intro.startupOpacity === 1 && intro.splashBarFilling && !intro.splashBarFull, "the cover stays while the bar fills")
  }
  Timer {
    interval: 1600
    running: true
    onTriggered: {
      // Well inside the fill's fallback deadline, so only a finished fill lifts it.
      test.check(test.fullAtLift, "the bar is full before the cover lifts")
      test.check(!intro.startupPending && intro.startupOpacity === 0, "the desktop fades in once the bar is full")
      if (!test.failed) console.log("RESULT pass")
      Qt.quit()
    }
  }
}
