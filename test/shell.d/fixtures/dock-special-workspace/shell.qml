import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "plugins/dock"

// Both the dock window and its Hyprland event handler are production code.
// The containing compositor is private; no real workspace is switched.
ShellRoot {
  id: test
  property int step: 0
  property int attempts: 0
  property var firstDock: null
  property var secondDock: null

  Dock { id: dock }
  Window {
    id: scratchpadWindow
    visible: true
    width: 320
    height: 200
    title: "dock-special-workspace-test"
  }
  Process { id: command }
  FileView {
    id: result
    path: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  }

  function finish(ok, message) {
    poll.stop()
    result.setText(JSON.stringify({ ok: ok, message: message }))
  }

  function toggleScratchpad() {
    command.command = ["hyprctl", "dispatch", 'hl.dsp.workspace.toggle_special("scratchpad")']
    command.running = true
    test.attempts = 0
  }

  Timer {
    id: poll
    interval: 50
    running: true
    repeat: true
    onTriggered: {
      if (++test.attempts > 100) {
        test.finish(false, "Timed out at step " + test.step + ": " + [
          "both floating workspaces show a dock",
          "opening the scratchpad hides only its monitor's dock",
          "closing the scratchpad restores its monitor's dock"
        ][test.step])
        return
      }
      if (test.step === 0) {
        if (Quickshell.screens.length !== 2 || Hyprland.toplevels.values.length === 0) return
        var firstScreen = Quickshell.screens.find(function(screen) { return screen.name === scratchpadWindow.screen.name })
        var secondScreen = Quickshell.screens.find(function(screen) { return screen !== firstScreen })
        test.firstDock = dock.dockOn(firstScreen)
        test.secondDock = dock.dockOn(secondScreen)
        if (!test.firstDock || !test.secondDock || !test.firstDock.shown || !test.secondDock.shown) return
        command.command = ["hyprctl", "--batch",
          'dispatch hl.dsp.focus({ monitor = "' + test.firstDock.monitor.name + '" }); ' +
          'dispatch hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }); ' +
          'dispatch hl.dsp.workspace.toggle_special("scratchpad")']
        command.running = true
        test.step = 1
        test.attempts = 0
      } else if (test.step === 1) {
        if (command.running || test.firstDock.shown || test.firstDock.monitor.lastIpcObject.specialWorkspace.name !== "special:scratchpad") return
        if (!test.secondDock.shown) {
          test.finish(false, "The other monitor's dock was hidden")
          return
        }
        test.toggleScratchpad()
        test.step = 2
      } else if (!command.running && test.firstDock.shown && !test.firstDock.monitor.lastIpcObject.specialWorkspace.name) {
        test.finish(test.secondDock.shown, "Both docks return after closing the scratchpad")
      }
    }
  }
}
