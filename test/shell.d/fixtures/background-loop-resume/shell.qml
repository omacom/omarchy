import QtQuick
import Quickshell
import "background" as BackgroundPlugin

ShellRoot {
  id: shell
  property bool failed: false
  readonly property string home: Quickshell.env("HOME")

  function check(ok, message) {
    if (!ok && !failed) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  // OWE takes the desktop for `during`, the layer is handed `after`, and OWE
  // gives the desktop back: the layer cuts back at full opacity or fades in.
  function handBack(during, after) {
    background.currentBackground = during
    background.suspended = true
    background.currentBackground = after
    background.suspended = false
    return background.resumeOpacity
  }

  BackgroundPlugin.Background { id: background }

  Timer {
    interval: 800
    running: true
    onTriggered: {
      const still = shell.home + "/backgrounds/1-sky.png"
      const loop = shell.home + "/backgrounds/loops/1-sky.mp4"
      shell.check(shell.handBack(still, still) === 1, "an intro ends on its still as it always has, with no fade")
      shell.check(shell.handBack(shell.home + "/clip.mp4", still) === 1, "a video of the user's own gives way to a still as it always has, with no fade")
      shell.check(shell.handBack(loop, still) === 1, "a theme loop gives way to its own still with a cut")
      shell.check(shell.handBack(loop, shell.home + "/backgrounds/2-sea.png") === 0, "a theme loop gives way to a different picture with a fade")

      // OWE stays suspended from one video to the next, so what fades is
      // decided by the video it plays last, not the one it started with.
      background.currentBackground = loop
      background.suspended = true
      background.currentBackground = shell.home + "/clip.mp4"
      background.currentBackground = shell.home + "/backgrounds/2-sea.png"
      background.suspended = false
      shell.check(background.resumeOpacity === 1, "a loop that gave way to a video of the user's own hands back as that video, with no fade")
      background.currentBackground = shell.home + "/clip.mp4"
      background.suspended = true
      background.currentBackground = loop
      background.currentBackground = shell.home + "/backgrounds/2-sea.png"
      background.suspended = false
      shell.check(background.resumeOpacity === 0, "a video that gave way to a loop hands back as that loop, with a fade into a different picture")
      if (!shell.failed) console.log("RESULT pass")
      Qt.quit()
    }
  }

  Timer {
    interval: 5000
    running: true
    onTriggered: {
      shell.check(false, "the fixture finishes")
      Qt.quit()
    }
  }
}
