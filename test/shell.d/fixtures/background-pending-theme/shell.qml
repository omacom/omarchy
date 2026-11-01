import QtQuick
import Quickshell
import qs.Commons
import qs.Commons as Commons
import "background" as BackgroundPlugin

ShellRoot {
  id: shell
  function firstPartyServiceFor(id) { return id === "omarchy.background" ? background : null }
  property bool failed: false
  function check(ok, message) {
    if (!ok) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }
  BackgroundPlugin.Background { id: background }

  // APPLY_THEME_FUNCTION

  Timer {
    interval: 600
    running: true
    onTriggered: {
      var oldColors = Qt.btoa('accent = "#ff0000"\nbackground = "#000000"\nforeground = "#ffffff"\n')
      var newColors = Qt.btoa('accent = "#123456"\nbackground = "#000000"\nforeground = "#ffffff"\n')
      background.transitionBackgroundWithTheme("", "/missing-still.png", "/missing-still.png", oldColors, "")
      shell.applyTheme(newColors, "")
    }
  }
  Timer {
    interval: 1300
    running: true
    onTriggered: {
      shell.check(Qt.colorEqual(Commons.Color.accent, "#123456"), "previous colors returned: " + Commons.Color.accent)

      // OWE fades the last still into a video and suspends this layer after
      // the video's first frame. Until then the stills must cover the desktop,
      // also when the video is chosen during a reveal.
      background.setBackground(Quickshell.env("HOME") + "/next.png", false)
      background.setBackground("/backgrounds/clip.mp4", false)
      shell.check(background.displayedBackground.endsWith("/still.png") && background.incomingBackground.endsWith("/next.png"),
                  "a video keeps the reveal's stills: " + background.displayedBackground)
      revealEnd.running = true
    }
  }
  Timer {
    id: revealEnd
    interval: 50
    repeat: true
    property int ticks: 0
    onTriggered: {
      ticks += 1
      if (background.incomingBackground && ticks < 80) return
      running = false
      shell.check(background.displayedBackground.endsWith("/next.png"), "the reveal ends on its still, not on the video: " + background.displayedBackground)
      if (!shell.failed) console.log("RESULT pass")
      Qt.quit()
    }
  }
}
