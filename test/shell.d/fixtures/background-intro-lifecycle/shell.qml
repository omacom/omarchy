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

  BackgroundIntro { id: intro; host: test }

  Timer {
    interval: 300
    running: true
    onTriggered: {
      test.check(intro.checked, "startup runs even when OWE left the background disabled for a video")
      test.services = ({ "omarchy.background": {} })
    }
  }
  Timer {
    interval: 500
    running: true
    onTriggered: {
      test.check(intro.cover, "the still stays covered while the launcher waits")
      test.services = ({})
    }
  }
  Timer {
    interval: 700
    running: true
    onTriggered: {
      test.check(!intro.cover && intro.checked, "OWE taking the background releases the cover")
      test.services = ({ "omarchy.background": {} })
      Qt.callLater(function() { test.check(!intro.cover, "recreating the background cannot cover or retry playback") })
    }
  }
  Timer {
    interval: 2300
    running: true
    onTriggered: {
      test.check(!intro.cover, "launcher completion leaves the still uncovered")
      if (!test.failed) console.log("RESULT pass")
      Qt.quit()
    }
  }
}
