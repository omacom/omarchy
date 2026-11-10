pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "AudioNodesModel.js" as Model

// Volume and mute of the default input when Quickshell gives it no
// PwNode.audio: Quickshell types only exact media classes, so a virtual source
// (an Audio/Source/Virtual, such as EasyEffects' or a platform's microphone
// mapping) has no volume or mute there. They go through wpctl instead, once for
// the whole shell. Reads and writes name the node by id, a reply for a node no
// longer tracked is dropped, and writes run one at a time with only the latest
// volume kept, so a slider drag cannot land on another input later.
Singleton {
  id: root

  readonly property var source: Pipewire.defaultAudioSource
  // The default input is untyped, so this drives it.
  readonly property bool active: !!source && !source.audio
  // Every handler reads nodeId itself: a property bound to it could still hold
  // its old value when onNodeIdChanged runs.
  readonly property int nodeId: active ? source.id : -1

  property bool known: false
  property real volume: 0
  property bool muted: false

  property int generation: 0
  property int readGeneration: -1
  property bool readAgain: false
  property var pendingVolume: null
  property var pendingMute: null

  // pactl subscribe is started again when it ends, unless it keeps ending at
  // once (no pipewire-pulse), which would only respawn it forever.
  property real subscribedAt: 0
  property int quickExits: 0

  onNodeIdChanged: reset()
  Component.onCompleted: reset()

  function reset() {
    generation++
    known = false
    pendingVolume = null
    pendingMute = null
    quickExits = 0
    events.running = nodeId >= 0
    refresh()
  }

  function refresh() {
    if (nodeId < 0) return
    if (reader.running || writer.running) {
      readAgain = true
      return
    }
    readGeneration = generation
    reader.command = ["wpctl", "get-volume", String(nodeId)]
    reader.running = true
  }

  function setVolume(value) {
    if (nodeId < 0) return
    volume = Math.max(0, Math.min(1, value))
    pendingVolume = [String(nodeId), volume.toFixed(2)]
    flush()
  }

  function setMuted(value) {
    if (nodeId < 0 || !known) return
    muted = value
    pendingMute = [String(nodeId), value ? "1" : "0"]
    flush()
  }

  function flush() {
    if (reader.running || writer.running) return true
    var args = null
    if (pendingMute !== null) {
      args = ["wpctl", "set-mute"].concat(pendingMute)
      pendingMute = null
    } else if (pendingVolume !== null) {
      args = ["wpctl", "set-volume"].concat(pendingVolume)
      pendingVolume = null
    }
    if (!args) return false
    writer.command = args
    writer.running = true
    return true
  }

  function settle() {
    if (flush()) return
    if (readAgain) {
      readAgain = false
      refresh()
    }
  }

  Process {
    id: reader
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var level = Model.parseWpctlVolume(text)
        if (!level || root.nodeId < 0 || root.readGeneration !== root.generation) return
        if (root.pendingVolume !== null || root.pendingMute !== null || writer.running) return
        root.volume = level.volume
        root.muted = level.muted
        root.known = true
      }
    }
    onExited: root.settle()
  }

  Process {
    id: writer
    onExited: {
      root.readAgain = true
      root.settle()
    }
  }

  // The volume keys, the mute key and other apps change the node too. pactl
  // translates its events, so they are read in the C locale.
  Process {
    id: events
    command: ["pactl", "subscribe"]
    environment: ({ LC_ALL: "C" })
    onRunningChanged: if (running) root.subscribedAt = Date.now()
    onExited: {
      root.quickExits = Date.now() - root.subscribedAt < 1000 ? root.quickExits + 1 : 0
      if (root.nodeId >= 0 && root.quickExits < 5) resubscribe.start()
    }
    stdout: SplitParser {
      onRead: function(line) {
        if (String(line).indexOf(" on source #") !== -1) root.refresh()
      }
    }
  }

  Timer {
    id: resubscribe
    interval: 2000
    onTriggered: if (root.nodeId >= 0 && !events.running) {
      events.running = true
      root.refresh()
    }
  }
}
