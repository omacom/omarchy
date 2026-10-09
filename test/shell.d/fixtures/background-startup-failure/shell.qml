import QtQuick
import Quickshell
import "services"
import "background" as BackgroundPlugin

ShellRoot {
  id: test
  property var services: ({ "omarchy.background": background })
  property var bar: ({})
  property bool failed: false
  property bool linkRead: false
  function firstPartyServiceFor(id) { return services[id] || null }
  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  BackgroundPlugin.Background { id: background }
  BackgroundIntro { id: intro; host: test }

  // The version moves before a selected wallpaper is displayed, so the check
  // runs once the call that moved it has returned.
  Connections {
    target: background
    function onBackgroundVersionChanged() {
      if (test.linkRead) return
      test.linkRead = true
      Qt.callLater(function() {
        test.check(background.displayedBackground.endsWith("broken.png"), "the unreadable wallpaper is selected")
      })
    }
  }

  // The startup deadline lifts the cover whatever the layer reports, so a
  // cover lifted while the layer is not ready was lifted by the deadline.
  Connections {
    target: intro
    function onCoverChanged() {
      if (intro.cover) return
      test.check(!background.ready && intro.startupPending, "the failed image cannot release startup through readiness")
    }
    function onStartupPendingChanged() {
      if (intro.startupPending) return
      test.check(test.linkRead, "the unreadable wallpaper's link is read")
      test.check(!background.ready, "the unreadable wallpaper never becomes ready")
      test.check(!intro.cover && intro.startupOpacity === 0, "the deadline fades the cover away despite the failed wallpaper")
      if (!test.failed) console.log("RESULT pass")
      Qt.quit()
    }
  }

  // Past BackgroundIntro's 10 s startup deadline and its fade, so a cover the
  // deadline never lifts fails here rather than at the runner's timeout.
  Timer {
    interval: 12000
    running: true
    onTriggered: {
      test.check(false, "the deadline fades the cover away despite the failed wallpaper")
      Qt.quit()
    }
  }
}
