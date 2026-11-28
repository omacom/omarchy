import QtQuick
import Quickshell
import Quickshell.Io
import "services"
import "background" as BackgroundPlugin

ShellRoot {
  id: test
  property var services: ({ "omarchy.background": background })
  property var bar: ({})
  property bool failed: false
  property bool released: false
  property bool releaseChecked: false
  // The runner holds back the boot intro or the link read on this pipe, and
  // names the event that lets it go, so each order lands deterministically.
  readonly property string releaseOn: Quickshell.env("RELEASE_ON")
  function firstPartyServiceFor(id) { return services[id] || null }
  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }
  function release(event) {
    if (event !== test.releaseOn || test.released) return
    test.released = true
    releaseProc.running = true
  }
  // BackgroundIntro lifts the cover in the handler for whichever of the two
  // prerequisites lands last, so the check runs a single time, after that
  // handler has returned. A cover still up then was left to the deadline.
  function checkRelease() {
    if (!intro.backgroundReady || !intro.startupSettled || test.releaseChecked) return
    test.releaseChecked = true
    Qt.callLater(function() {
      test.check(!intro.cover, "the startup cover lifts once the layer is ready and the boot intro has exited")
    })
  }

  BackgroundPlugin.Background { id: background }
  BackgroundIntro { id: intro; host: test }
  Process {
    id: releaseProc
    command: ["bash", "-c", "printf 'go\\n' >\"$1\"", "_", Quickshell.env("RELEASE_FIFO")]
  }

  Connections {
    target: intro
    function onBackgroundReadyChanged() {
      if (intro.backgroundReady) test.release("ready")
      test.checkRelease()
    }
    function onStartupSettledChanged() {
      if (intro.startupSettled) test.release("settled")
      test.checkRelease()
    }
    // Readiness can lift the cover only once the layer is ready, so a cover
    // lifted while it is not was lifted by the startup deadline instead.
    function onCoverChanged() {
      if (intro.cover) return
      test.check(background.ready && background.displayedBackground === "", "the desktop is released once the layer settles on no wallpaper")
    }
    // checkRelease() sets releaseChecked only once intro.backgroundReady and
    // intro.startupSettled both hold. The fade follows the cover lifting, so
    // releaseChecked is still false here only if one of them never landed and
    // BackgroundIntro's 10 s startup Timer lifted the cover instead.
    function onStartupPendingChanged() {
      if (intro.startupPending) return
      test.check(test.releaseChecked, "the layer is ready and the boot intro has exited before the desktop fades in")
      test.check(!intro.cover && intro.startupOpacity === 0, "a desktop without a wallpaper fades in")
      if (!test.failed) console.log("RESULT pass")
      Qt.quit()
    }
  }

  // Past BackgroundIntro's 10 s startup deadline and its fade, so a desktop
  // that is never revealed fails here rather than at the runner's timeout.
  Timer {
    interval: 12000
    running: true
    onTriggered: {
      test.check(false, "a desktop without a wallpaper is revealed")
      Qt.quit()
    }
  }
}
