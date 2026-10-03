import QtQuick
import Quickshell.Io

Item {
  id: root

  property string path: ""
  property int revision: 0
  property var candidates: []
  property bool busy: false
  property int generation: 0
  signal resolved()

  function refresh() {
    generation += 1
    busy = true
    if (!scan.running) Qt.callLater(root.start)
  }

  function start() {
    if (scan.running) return
    scan.generation = generation
    scan.command = ["timeout", "10", "python",
      decodeURIComponent(Qt.resolvedUrl("variant-images.py").toString().replace(/^file:\/\//, "")), path]
    scan.running = true
  }

  onPathChanged: refresh()
  onRevisionChanged: refresh()

  Process {
    id: scan
    property int generation: 0
    stdout: StdioCollector { id: output; waitForEnd: true }
    onExited: function(exitCode, exitStatus) {
      if (generation !== root.generation) {
        root.start()
        return
      }
      var next = []
      if (exitCode === 0) {
        try { next = JSON.parse(output.text) } catch (error) {}
      }
      root.candidates = next
      root.busy = false
      root.resolved()
    }
  }
}
