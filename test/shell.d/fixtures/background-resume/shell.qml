import QtQuick
import Quickshell
import Quickshell.Io
import "background" as BackgroundPlugin

ShellRoot {
  property string handled: ""
  BackgroundPlugin.Background { id: background }
  FileView { id: command; path: Quickshell.env("RESUME_TEST_COMMAND"); watchChanges: true; onFileChanged: reload() }
  FileView { id: result; path: Quickshell.env("RESUME_TEST_RESULT"); atomicWrites: true }

  Timer { interval: 600; running: true; onTriggered: result.setText("initial") }
  Timer {
    interval: 100
    running: true
    repeat: true
    onTriggered: {
      var next = command.text().trim()
      if (next === handled) return
      handled = next
      if (next === "done") {
        Qt.quit()
      } else if (next.startsWith("suspend")) {
        background.suspended = true
        result.setText(next)
      } else if (next.startsWith("resume")) {
        background.suspended = false
        result.setText(next)
      }
    }
  }
}
