import QtQuick
import Quickshell
import Quickshell.Io
import "background" as BackgroundPlugin

// Screens taller than wide show backgrounds/portrait/<same name> when the
// theme ships one, and the plain file when it does not. The first screen is
// made portrait here, whatever the desk looks like.
ShellRoot {
  id: shell
  property bool failed: false
  property int step: 0
  readonly property string backgrounds: Quickshell.env("HOME") + "/theme/backgrounds"

  function check(ok, message) {
    if (!ok && !failed) {
      failed = true
      console.log("RESULT fail " + message)
    }
  }

  function panels() {
    for (var child of background.data)
      if (child && child.instances !== undefined) return child.instances
    return []
  }

  // True once every screen rests on its final frame for the file given: the
  // twin on the portrait screen when the theme ships one, else the plain file.
  function settled(name, twin) {
    if (background.incomingBackground || !background.ready) return false
    var screens = panels()
    for (var i = 0; i < screens.length; i++) {
      var want = shell.backgrounds + (i === 0 && twin ? "/portrait/" : "/") + name
      if (screens[i].basePath !== want) return false
    }
    return true
  }

  function finish() {
    if (!shell.failed) console.log("RESULT pass")
    Qt.quit()
  }

  BackgroundPlugin.Background { id: background }

  Process {
    id: addTwin
    command: ["cp", shell.backgrounds + "/portrait/2-green.png", shell.backgrounds + "/portrait/3-lonely.png"]
    onExited: background.setBackground(shell.backgrounds + "/3-lonely.png", true)
  }

  Timer {
    interval: 800
    running: true
    onTriggered: {
      shell.check(background.twinPath(shell.backgrounds + "/1-red.png") === shell.backgrounds + "/portrait/1-red.png", "a theme background has its twin under backgrounds/portrait/")
      shell.check(background.twinPath("/cache/background-transitions/next-42.png") === "/cache/background-transitions/portrait/next-42.png", "a theme switch snapshot has its twin under the snapshot folder")
      shell.check(background.twinPath("/home/me/.config/omarchy/backgrounds/tokyo/3-user.png") === "/home/me/.config/omarchy/backgrounds/tokyo/portrait/3-user.png", "a user background has its twin under its own portrait/")
      shell.check(background.twinPath("/home/me/Pictures/beach.png") === "", "a picture outside a backgrounds folder has no twin")
      shell.check(background.twinPath(shell.backgrounds + "/3-clip.mp4") === "", "a video has no twin")

      var screens = shell.panels()
      shell.check(screens.length > 0, "the plugin built a panel per screen")
      for (var panel of screens) {
        panel.portrait = false
        shell.check(panel.basePath.endsWith("/1-red.png") && panel.basePath.indexOf("/portrait/") === -1, "a landscape screen shows the plain file: " + panel.basePath)
      }
      screens[0].portrait = true
      shell.step = 1
    }
  }

  FrameAnimation {
    running: shell.step > 0
    onTriggered: {
      switch (shell.step) {
      case 1:
        // The twin was probed alongside the plain file, so the portrait
        // screen moves to it without a transition.
        if (!shell.settled("1-red.png", true)) return
        shell.step = 2
        background.setBackground(shell.backgrounds + "/2-green.png", false)
        return
      case 2:
        if (!background.incomingBackground) return
        shell.step = 3
        return
      case 3:
        if (background.incomingBackground) return
        // The reveal ends with the portrait screen on the new twin.
        if (!shell.settled("2-green.png", true)) return
        shell.step = 4
        background.setBackground(shell.backgrounds + "/3-lonely.png", false)
        return
      case 4:
        if (!background.incomingBackground) return
        shell.step = 5
        return
      case 5:
        if (background.incomingBackground) return
        // A background without a twin shows the plain file on every screen.
        if (!shell.settled("3-lonely.png", false)) return
        shell.step = 6
        addTwin.running = true
        return
      case 6:
        // A theme switch keeps the durable path but swaps the files behind
        // it; the forced reload probes the twin again and finds it.
        if (!shell.settled("3-lonely.png", true)) return
        // Every screen portrait, so no landscape screen's ready frame can
        // start the reveal for the others.
        for (var panel of shell.panels()) panel.portrait = true
        shell.step = 7
        background.setBackground(shell.backgrounds + "/4-broken.png", false)
        return
      case 7:
        if (!background.incomingBackground) return
        shell.step = 8
        return
      case 8:
        if (background.incomingBackground || !background.ready) return
        // A twin the probe found but Qt cannot decode gives way to the plain
        // file on the incoming frame, and the reveal still runs.
        for (var screen of shell.panels())
          if (screen.basePath !== shell.backgrounds + "/4-broken.png") return
        shell.step = 9
        shell.finish()
        return
      }
    }
  }

  Timer {
    interval: 12000
    running: true
    onTriggered: {
      shell.check(false, "the portrait twin fixture finishes at step " + shell.step + ": " + shell.panels().map(function(p) { return p.basePath }).join(", "))
      shell.finish()
    }
  }
}
