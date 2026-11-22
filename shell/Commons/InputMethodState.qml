pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root
  property var state: ({})

  function cycle(back) {
    if (!watcher.running) return false
    watcher.write(back ? "cycle back\n" : "cycle\n")
    return true
  }

  // One reader and pending selection for every monitor's keyboard widget.
  Process {
    id: watcher
    command: ["/usr/bin/python3", Quickshell.env("OMARCHY_PATH") + "/default/input-methods/indicator.py"]
    running: true
    stdinEnabled: true
    stdout: SplitParser {
      onRead: data => {
        try { root.state = JSON.parse(data) } catch (e) {}
      }
    }
    onExited: {
      root.state = ({})
      restart.restart()
    }
  }

  Timer {
    id: restart
    interval: 5000
    onTriggered: watcher.running = true
  }
}
