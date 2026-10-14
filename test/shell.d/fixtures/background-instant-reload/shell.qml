import QtQuick
import Quickshell
import Quickshell.Io
import "background" as BackgroundPlugin

ShellRoot {
  property bool reloaded: false
  BackgroundPlugin.Background { id: background }
  FileView { id: command; path: Quickshell.env("RELOAD_TEST_COMMAND"); watchChanges: true; onFileChanged: reload() }
  FileView { id: result; path: Quickshell.env("RELOAD_TEST_RESULT"); atomicWrites: true }

  Timer { interval: 600; running: true; onTriggered: result.setText("initial") }
  Timer { id: settled; interval: 600; onTriggered: result.setText("reloaded") }
  Timer {
    interval: 100
    running: true
    repeat: true
    onTriggered: {
      if (command.text().trim() === "done") {
        Qt.quit()
      } else if (command.text().trim() === "reload" && !reloaded) {
        reloaded = true
        background.setBackground(background.currentBackground, true)
        settled.start()
      }
    }
  }
}
