import QtQuick
import Quickshell
import "background" as BackgroundPlugin

ShellRoot {
  id: test
  property bool failed: false
  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  BackgroundPlugin.Background { id: background }

  Timer {
    interval: 600
    running: true
    onTriggered: {
      test.check(background.displayedBackground.endsWith("/still.png"), "the still is on screen")

      // OWE fades this still into the video, so the layer keeps it until OWE
      // has the first frame and suspends the layer.
      background.setBackground("/backgrounds/clip.mp4", false)
      test.check(background.currentBackground === "/backgrounds/clip.mp4", "the video is the current background")
      test.check(background.displayedBackground.endsWith("/still.png"), "the still stays on screen for the video")

      // A suspended layer shows nothing, so a video replaces the still at once.
      background.suspended = true
      background.setBackground("/backgrounds/other.mp4", false)
      test.check(background.displayedBackground === "/backgrounds/other.mp4", "a suspended layer takes the video at once")

      if (!test.failed) console.log("RESULT pass")
      Qt.quit()
    }
  }
}
