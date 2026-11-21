pragma Singleton
import QtQuick
import Quickshell.Hyprland
import Quickshell.Io
import "ShortcutHints.js" as Model

QtObject {
  id: root

  property var bindings: []

  function forAction(description) {
    return Model.forAction(bindings, description)
  }

  function refresh() {
    bindsProcess.running = true
  }

  function applyBindings(raw) {
    try {
      var parsed = JSON.parse(raw || "[]")
      bindings = Array.isArray(parsed) ? parsed : []
    } catch (e) {
      bindings = []
    }
  }

  Component.onCompleted: refresh()

  Process {
    id: bindsProcess
    command: ["hyprctl", "-j", "binds"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyBindings(text)
    }
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (event && String(event.name) === "configreloaded") root.refresh()
    }
  }
}
