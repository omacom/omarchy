pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "MicrophoneMuteModel.js" as Model

// One controller for every bar surface. Only server-confirmed source state
// drives the mute indicator; writes use the device route through pactl.
Singleton {
  id: root

  property var sources: []
  property bool snapshotKnown: false
  readonly property bool known: snapshotKnown && UntypedInput.sourceEventsRunning
  readonly property bool muted: known && Model.allMuted(sources)
  readonly property bool busy: writing
  property bool writing: false
  property var queue: []
  property bool targetMuted: false
  property bool toggleRequested: false
  property bool readAgain: false
  property string readOutput: ""

  Component.onCompleted: {
    UntypedInput.globalMuteActive = true
    refresh()
  }

  Connections {
    target: UntypedInput
    function onSourceEvent() {
      root.snapshotKnown = false
      root.refresh()
    }
    function onSourceDisconnected() { root.snapshotKnown = false }
  }

  function refresh() {
    if (reader.running || busy) {
      readAgain = true
      return
    }
    readAgain = false
    readOutput = ""
    reader.running = true
  }

  function toggle() {
    if (busy || toggleRequested) return
    // Read again at click time, so newly connected inputs join this action.
    toggleRequested = true
    refresh()
  }

  function writeNext() {
    if (queue.length === 0) {
      writing = false
      refresh()
      return
    }
    var pending = queue.slice()
    var name = pending.shift()
    queue = pending
    writer.command = ["pactl", "set-source-mute", name, targetMuted ? "1" : "0"]
    writer.running = true
  }

  function finishRead(code, output) {
    // A device changed while this snapshot was in flight. Read again before
    // choosing the mute target or showing a confirmed state.
    if (readAgain) {
      snapshotKnown = false
      Qt.callLater(refresh)
      return
    }
    var snapshot = code === 0 ? Model.parseSources(output) : null
    snapshotKnown = snapshot !== null
    sources = snapshot || []
    if (toggleRequested) {
      toggleRequested = false
      if (snapshotKnown && sources.length > 0) {
        targetMuted = !Model.allMuted(sources)
        queue = sources.map(function(source) { return source.name })
        // Do not retain a success icon while an unmute is in flight.
        snapshotKnown = false
        writing = true
        writeNext()
      }
    }
  }

  function finishWrite(code) {
    if (code !== 0) console.warn("Could not change microphone mute state; refreshing confirmed state")
    // Restarting this Process from its own onExited can lose the next write.
    Qt.callLater(writeNext)
  }

  Process {
    id: reader
    command: ["pactl", "--format=json", "list", "sources"]
    environment: ({ LC_ALL: "C" })
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.readOutput = text
    }
    onExited: function(code) { root.finishRead(code, root.readOutput) }
  }

  Process {
    id: writer
    onExited: function(code) { root.finishWrite(code) }
  }
}
