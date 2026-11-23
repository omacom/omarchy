import QtQuick
import Quickshell.Io

Item {
  id: root

  property string path: ""
  property int revision: 0
  property var candidates: []
  property bool busy: false
  property int generation: 0
  property int timeoutSeconds: 10
  signal resolved()

  function refresh() {
    generation += 1
    busy = true
    if (!scan.running) Qt.callLater(root.start)
  }

  function start() {
    if (scan.running) return
    scan.generation = generation
    scan.command = ["timeout", String(timeoutSeconds), "python",
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
      // The scanner flushes one candidate at a time. A bounded scan may end
      // before the last file, but must not discard already discovered images.
      var lines = String(output.text || "").split("\n")
      for (var i = 0; i < lines.length; i++) {
        try { next.push(JSON.parse(lines[i])) } catch (error) {}
      }
      root.candidates = next
      root.busy = false
      root.resolved()
    }
  }
}
