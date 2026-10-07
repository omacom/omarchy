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
      test.services = ({ "omarchy.background": {} })
      intro.prepareTheme("", "theme-one", Qt.btoa('background = "#123456"'), "")
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
      test.services = ({})
    }
  }
  Timer {
    interval: 600
    running: true
    onTriggered: {
      test.check(intro.themeToken === "theme-one", "a leftover renderer still stays covered until video is revealed")
      revealVideo.running = true
    }
  }
  Timer {
    interval: 700
    running: true
    onTriggered: {
      test.check(!intro.cover && intro.checked, "OWE taking the background releases the cover")
      test.check(intro.themeToken === "" && Qt.colorEqual(Commons.Color.background, "#123456"), "first-frame handoff starts the palette and wallpaper fade together")
      test.services = ({ "omarchy.background": {} })
      Qt.callLater(function() { test.check(!intro.cover, "recreating the background cannot cover or retry playback") })
    }
  }
  Timer {
    interval: 1500
    running: true
    onTriggered: {
      intro.prepareTheme("", "failed-theme", Qt.btoa('background = "#654321"'), "")
      intro.finishTheme("failed-theme")
      test.check(Qt.colorEqual(Commons.Color.background, "#654321"), "failed playback still releases its pending palette")
      intro.prepareTheme("", "cancelled-theme", Qt.btoa('background = "#abcdef"'), "")
      intro.cancelTheme()
      intro.finishTheme("cancelled-theme")
      test.check(Qt.colorEqual(Commons.Color.background, "#654321") && !intro.themeToken, "a superseding theme cannot be overwritten by an older completion")
    }
  }
  Timer {
    interval: 1800
    running: true
    onTriggered: {
      intro.prepareTheme("", "cached-theme", Qt.btoa('background = "#abcdef"'), "", Quickshell.env("INTRO_TEST_FIRST_FRAME"))
      test.check(Qt.colorEqual(Commons.Color.background, "#abcdef") && intro.themeFadeStarted, "a cached first frame starts the palette and wallpaper fade without waiting for the renderer")
      test.check(intro.themeToken === "cached-theme" && intro.themeFirstFrame !== "", "the cached frame remains until playback is ready")
      intro.cancelTheme()
      intro.finishTheme("failed-theme")
      test.check(Qt.colorEqual(Commons.Color.background, "#abcdef") && !intro.themeFirstFrame, "cancellation clears the placeholder and rejects an older completion")
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
