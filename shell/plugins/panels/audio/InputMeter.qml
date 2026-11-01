import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "Model.js" as Model

// Peak level of a PipeWire source, on the same scale as PwNodePeakMonitor.peak
// so the panel's meter bar can read either one.
//
// PwNodePeakMonitor is used whenever it can work. For a source it cannot meter
// (see Model.needsProcessMeter) the input-peak script captures the node through
// pw-record instead.
Item {
  id: root

  property var node: null
  property bool active: false

  readonly property real peak: usesProcess ? processPeak : nativeMonitor.peak

  readonly property bool usesProcess: Model.needsProcessMeter(
    node && node.audio ? node.audio.channels : null, PwAudioChannel.AuxRangeStart)

  readonly property string scriptPath: Quickshell.env("OMARCHY_PATH") + "/shell/plugins/panels/audio/input-peak"

  // What input-peak should be capturing right now, or [] for nothing. The
  // process is driven from this rather than from a `running` binding so a
  // change of source (or of channel count) restarts it with new arguments.
  readonly property var processCommand: {
    if (!active || !node || !usesProcess) return []
    return ["bash", scriptPath, String(node.name), String(node.audio.channels.length)]
  }
  readonly property string processKey: processCommand.join("\n")
  onProcessKeyChanged: {
    quickExits = 0
    syncProcess()
  }
  Component.onCompleted: syncProcess()

  property real processPeak: 0
  // A capture that keeps failing within a second of starting is given up on
  // until the source changes or the panel reopens, rather than respawned forever.
  property real startedAt: 0
  property int quickExits: 0

  function syncProcess() {
    var want = processCommand
    if (want.length === 0) {
      meterProcess.running = false
      return
    }
    // Quickshell treats running=false followed by running=true as a
    // restart once the old process has exited, with whatever command is
    // set by then. Setting running=true even when the command is unchanged
    // re-arms a start that a stop cancelled while the old process exits.
    if (meterProcess.running && meterProcess.command.join("\n") !== processKey)
      meterProcess.running = false
    meterProcess.command = want
    meterProcess.running = true
  }

  // The script reports each channel of the captured signal with its volume
  // already applied; the bar shows what the mic picks up, not the slider.
  function applyProcessSample(line) {
    var peak = Model.processMeterPeak(line, node && node.audio ? node.audio.volumes : [])
    if (peak >= 0) processPeak = peak
  }

  PwNodePeakMonitor {
    id: nativeMonitor
    node: root.node
    enabled: root.active && !!root.node && !root.usesProcess
  }

  Process {
    id: meterProcess
    stdout: SplitParser {
      onRead: function(line) { root.applyProcessSample(line) }
    }
    onRunningChanged: {
      if (running) {
        root.startedAt = Date.now()
        return
      }
      root.processPeak = 0
      root.quickExits = Date.now() - root.startedAt < 1000 ? root.quickExits + 1 : 0
      if (root.processKey !== "" && root.quickExits < 5) retryTimer.restart()
    }
  }

  // pw-record exits on its own when PipeWire restarts or the node drops out
  // under it; nothing else would start it again while the panel stays open.
  Timer {
    id: retryTimer
    interval: 1000
    onTriggered: if (!meterProcess.running) root.syncProcess()
  }
}
