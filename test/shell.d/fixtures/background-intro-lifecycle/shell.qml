import QtQuick
import Quickshell
import Quickshell.Io
import "services"
import "Commons" as Commons

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
    id: revealVideo
    command: ["touch", Quickshell.env("INTRO_TEST_FRAME_READY")]
  }

  Timer {
    interval: 300
    running: true
    onTriggered: {
      test.check(intro.checked, "startup runs even when OWE left the background disabled for a video")
      test.services = ({ "omarchy.background": retainedBackground })
      intro.prepareTheme(Quickshell.env("INTRO_TEST_COVER"), "theme-one", Qt.btoa('background = "#123456"'), "")
      test.check(intro.themeCoverStatus("theme-one") === "loading", "the cover waits for decoding and presentation")
      test.check(intro.themeStatus("theme-one") === "pending", "app retints wait for the intro reveal")
      test.check(!Qt.colorEqual(Commons.Color.background, "#123456"), "the palette waits for OWE's first frame")
      intro.finishTheme("superseded-theme")
      test.check(intro.themeToken === "theme-one", "an older intro cannot release the pending handoff")
    }
  }
  Timer {
    interval: 500
    running: true
    onTriggered: {
      test.check(intro.cover, "the still stays covered while the launcher waits")
      test.check(intro.themeCoverStatus("theme-one") === "ready", "the outgoing cover is presented before the shell is hidden")
      retainedBackground.suspended = true
    }
  }
  Timer {
    interval: 600
    running: true
    onTriggered: {
      test.check(intro.themeToken === "theme-one", "a leftover renderer still stays covered until video is revealed")
      revealVideo.running = true
      handoffDeadline = Date.now() + 3000
      handoff.start()
    }
  }
  property double handoffDeadline: 0
  property bool openingFadeObserved: false
  Connections {
    target: intro
    function onThemeTokenChanged() {
      if (handoff.running && intro.themeToken === "") {
        Qt.callLater(function() {
          test.check(intro.themeStatus("theme-one") === "pending", "app retints also wait through the opening crossfade")
          test.openingFadeObserved = true
        })
      }
    }
  }
  Timer {
    id: handoff
    interval: 16
    repeat: true
    onTriggered: {
      if (intro.themeToken || !test.openingFadeObserved) {
        if (Date.now() >= test.handoffDeadline) {
          test.check(false, "the ready video releases its cover before the deadline")
          Qt.quit()
        }
        return
      }
      stop()
      test.check(!intro.cover && intro.checked, "OWE taking the background releases the cover")
      test.check(intro.themeToken === "" && Qt.colorEqual(Commons.Color.background, "#123456"), "first-frame handoff starts the palette and wallpaper fade together")
      retainedBackground.suspended = false
      Qt.callLater(function() { test.check(!intro.cover, "resuming the retained background cannot cover or retry playback") })
      completionDeadline = Date.now() + 3000
      completion.start()
    }
  }
  property double completionDeadline: 0
  Timer {
    id: completion
    interval: 16
    repeat: true
    onTriggered: {
      if (intro.themeStatus("theme-one") !== "ready" || !intro.startupSettled) {
        if (Date.now() >= test.completionDeadline) {
          test.check(false, "the fade and launcher complete before the deadline")
          Qt.quit()
        }
        return
      }
      stop()
      test.check(intro.themeStatus("theme-one") === "ready", "the completed crossfade releases app retints")
      intro.prepareTheme("", "failed-theme", Qt.btoa('background = "#654321"'), "")
      intro.finishTheme("failed-theme")
      test.check(Qt.colorEqual(Commons.Color.background, "#654321"), "failed playback still releases its pending palette")
      intro.prepareTheme("", "cancelled-theme", Qt.btoa('background = "#abcdef"'), "")
      intro.cancelTheme()
      intro.finishTheme("cancelled-theme")
      test.check(Qt.colorEqual(Commons.Color.background, "#654321") && !intro.themeToken, "a superseding theme cannot be overwritten by an older completion")
      test.check(!intro.cover, "launcher completion leaves the still uncovered")
      if (!test.failed) console.log("RESULT pass")
      Qt.quit()
    }
  }
}
