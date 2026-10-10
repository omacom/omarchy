import QtQuick
import Quickshell.Io

Item {
  id: root
  property string omarchyPath: ""
  property var shell: null
  property var manifest: null
  property var pluginRegistry: null

  Process {
    command: ["python3", root.omarchyPath + "/shell/plugins/keyboard-backlight/monitor.py"]
    running: root.omarchyPath !== ""
    stdout: SplitParser {
      onRead: function(line) {
        try {
          var payload = JSON.parse(line)
          if (root.shell) root.shell.summon("omarchy.osd", JSON.stringify(payload))
        } catch (error) {
          console.warn("keyboard-backlight: invalid brightness event", error)
        }
      }
    }
  }
}
