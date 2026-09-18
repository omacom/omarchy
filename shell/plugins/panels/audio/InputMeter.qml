import QtQuick
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

  readonly property string scriptPath: Qt.resolvedUrl("input-peak").toString().replace(/^file:\/\//, "")

  // What input-peak should be capturing right now, or [] for nothing. The
  // process is driven from this rather than from a `running` binding so a
  // change of source (or of channel count) restarts it with new arguments.
  readonly property var processCommand: {
    if (!active || !node || !usesProcess) return []
    return ["bash", scriptPath, String(node.name), String(node.audio.channels.length)]
  }
  readonly property string processKey: processCommand.join("\n")
  onProcessKeyChanged: syncProcess()
  Component.onCompleted: syncProcess()

  property real processPeak: 0

  function syncProcess() {
    var want = processCommand
    if (meterProcess.running) {
      if (meterProcess.command.join("\n") === processKey) return
      // Quickshell treats running=false followed by running=true as a
      // restart once the old process has exited, with whatever command is
      // set by then.
      meterProcess.running = false
      if (want.length > 0) {
        meterProcess.command = want
        meterProcess.running = true
      }
    } else if (want.length > 0) {
      meterProcess.command = want
      meterProcess.running = true
    }
  }

  // The script reports the captured signal, which already has the source's
  // volume applied. Match PwNodePeakMonitor: cube-root the magnitude, then
  // divide the volume back out so the bar shows what the mic is picking up
  // rather than where the slider sits.
  function applyProcessSample(line) {
    var raw = parseFloat(line)
    if (!isFinite(raw)) return
    var volume = node && node.audio ? node.audio.volume : 1
    var visual = Math.cbrt(Math.max(0, raw))
    if (volume > 0.001) visual /= volume
    processPeak = visual
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
    onRunningChanged: if (!running) root.processPeak = 0
  }
}
