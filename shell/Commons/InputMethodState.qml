pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
  id: root
  property var state: ({})
  property string keybindings: ""
  property bool bindingsRequested: false
  property bool bindingsPending: false

  function requestKeybindings() {
    if (bindingsRequested) return
    bindingsRequested = true
    refreshKeybindings()
  }

  function refreshKeybindings() {
    keybindings = ""
    if (bindingsQuery.running) {
      bindingsPending = true
      return
    }
    bindingsPending = false
    bindingsQuery.running = true
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (root.bindingsRequested && event.name === "configreloaded") root.refreshKeybindings()
    }
  }

  Process {
    id: bindingsQuery
    command: ["timeout", "5", "hyprctl", "binds"]
    stdout: StdioCollector { id: bindingsOutput }
    onExited: function(exitCode, exitStatus) {
      if (root.bindingsPending) root.refreshKeybindings()
      else if (exitCode === 0 && exitStatus === 0) root.keybindings = bindingsOutput.text
    }
  }

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
