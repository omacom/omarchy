import QtQuick
import Quickshell
import "background" as BackgroundPlugin

ShellRoot {
  id: shell
  property bool failed: false
  property bool revealed: false
  property bool started: false

  function check(ok, message) {
    if (!ok && !failed) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  // One panel per screen, built by the plugin's own Variants.
  function panels() {
    for (var child of background.data)
      if (child && child.instances !== undefined) return child.instances
    return []
  }

  BackgroundPlugin.Background { id: background }

  Timer {
    interval: 800
    running: true
    onTriggered: {
      shell.check(background.ready, "the first background is on screen before the switch")
      background.setBackground(Quickshell.env("HOME") + "/next.png", false)
      shell.started = true
    }
  }

  FrameAnimation {
    running: shell.started
    onTriggered: {
      var screens = shell.panels()
      if (background.incomingBackground) {
        shell.revealed = true
        // Every screen slides, including one whose frame decoded after the
        // others had started. One left out would jump to the new background
        // when the slide ends.
        if (background.revealProgress >= 1) {
          for (var i = 0; i < screens.length; i++)
            shell.check(screens[i].maskReady, "screen " + i + " sat out the reveal")
        }
        return
      }
      if (!shell.revealed) return
      // The incoming frame comes down only once every screen has drawn the new
      // background underneath it, or that screen shows nothing for a moment.
      for (var panel of screens)
        shell.check(panel.backgroundReady, "the transition ended before every screen drew its new background")
      shell.check(background.displayedBackground.endsWith("/next.png"), "the reveal ends on the new background: " + background.displayedBackground)
      if (!shell.failed) console.log("RESULT pass")
      Qt.quit()
    }
  }

  Timer {
    interval: 5000
    running: true
    onTriggered: {
      shell.check(false, "the reveal finishes")
      Qt.quit()
    }
  }
}
