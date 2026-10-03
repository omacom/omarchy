pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
  id: root

  signal resumed()

  property Process watcher: Process {
    id: watcher
    running: true
    command: [
      "setpriv", "--pdeathsig", "TERM", "dbus-monitor", "--system",
      "type='signal',sender='org.freedesktop.login1',interface='org.freedesktop.login1.Manager',member='PrepareForSleep'"
    ]
    stdout: SplitParser {
      onRead: function(line) {
        if (String(line).trim() === "boolean false") root.resumed()
      }
    }
    onExited: restartTimer.restart()
  }

  property Timer restartTimer: Timer {
    id: restartTimer
    interval: 1000
    repeat: false
    onTriggered: if (!watcher.running) watcher.running = true
  }
}
