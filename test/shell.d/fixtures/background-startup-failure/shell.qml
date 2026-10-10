import QtQuick
import Quickshell
import "services"
import "background" as BackgroundPlugin

ShellRoot {
  id: test
  property var services: ({ "omarchy.background": background })
  property var bar: ({})
  property bool failed: false
  function firstPartyServiceFor(id) { return services[id] || null }
  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  BackgroundPlugin.Background { id: background }
  BackgroundIntro { id: intro; host: test }

  Timer {
    interval: 600
    running: true
    onTriggered: {
      test.check(background.displayedBackground.endsWith("deleted.png"), "the missing wallpaper is selected")
      test.check(!background.ready && intro.startupPending && intro.cover, "the failed image cannot release startup through readiness")
    }
  }
  Timer {
    interval: 11000
    running: true
    onTriggered: {
      test.check(!background.ready, "the missing wallpaper never becomes ready")
      test.check(!intro.startupPending && !intro.cover && intro.startupOpacity === 0, "the deadline fades the cover away despite the failed wallpaper")
      if (!test.failed) console.log("RESULT pass")
      Qt.quit()
    }
  }
}
