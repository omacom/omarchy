import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.Commons
import qs.Ui

BarIndicator {
  id: root

  property bool recording: false

  // While recording, a glow behind the ring follows the microphone the
  // recorder takes in, so a take that hears nothing (a muted or wrong input)
  // shows a still ring before it is wasted. The microphone is the source linked
  // into the recorder's own capture stream, not whatever the default input is
  // now. Desktop audio comes from a sink and is left out, so a recording without
  // a microphone shows no glow. Only the copy shown in the bar listens.
  readonly property bool listening: recording && belongsInBlock

  // Tracked, because a node's properties, which name the program behind it,
  // stay empty until it is bound.
  readonly property var captureStreams: {
    if (!listening || !Pipewire.nodes) return []
    var nodes = Pipewire.nodes.values
    var streams = []
    for (var i = 0; i < nodes.length; i++) {
      if (nodes[i] && nodes[i].isStream && !nodes[i].isSink) streams.push(nodes[i])
    }
    return streams
  }

  // The level meter reads typed nodes only, which `audio` marks.
  readonly property var recordedMicrophone: {
    if (!listening || !Pipewire.linkGroups) return null
    var groups = Pipewire.linkGroups.values
    for (var i = 0; i < groups.length; i++) {
      var source = groups[i].source
      var stream = groups[i].target
      if (!source || !stream || !isRecorder(stream)) continue
      if (source.isSink || source.isStream || !source.audio) continue
      return source
    }
    return null
  }

  // 0 to 1. Rises at once with each syllable and falls back over a few
  // frames, so speech reads as a pulse rather than a flicker.
  property real microphoneLevel: 0

  function isRecorder(node) {
    var binary = node.properties ? node.properties["application.process.binary"] : ""
    return binary === "gpu-screen-recorder" || binary === "wf-recorder"
  }

  // Quickshell reports the peak on the cubic scale PipeWire volumes use, so
  // 60 * log10 of it is decibels. A quiet room sits below -45 dBFS and speech
  // near the microphone up to about -15, which spans the whole glow.
  function followPeak(peak) {
    var level = peak > 0 ? Math.max(0, Math.min(1, (60 * Math.log(peak) / Math.LN10 + 45) / 30)) : 0
    microphoneLevel = level > microphoneLevel ? level : microphoneLevel + (level - microphoneLevel) * 0.15
  }

  onRecordedMicrophoneChanged: if (!recordedMicrophone) microphoneLevel = 0

  active: recording
  activeText: "󰻂"
  inactiveText: "󰻂"
  activeTooltipText: I18n.t("bar.stopRecording")
  inactiveTooltipText: I18n.t("bar.screenRecording")

  function refresh() {
    if (!root.bar || statusProc.running) return
    statusProc.command = ["omarchy-capture-screenrecording", "--status"]
    statusProc.running = true
  }

  onBarChanged: refresh()
  Component.onCompleted: refresh()

  Connections {
    target: root.indicatorHost
    ignoreUnknownSignals: true
    function onRefreshRequested() { root.refresh() }
  }

  Process {
    id: statusProc
    onExited: function(exitCode) {
      root.recording = exitCode === 0
    }
  }

  PwObjectTracker { objects: root.captureStreams }

  PwNodePeakMonitor {
    node: root.recordedMicrophone
    enabled: !!root.recordedMicrophone
    onPeakChanged: root.followPeak(peak)
  }

  Rectangle {
    // Grows at most a little past the ring, clear of the bar's edges.
    readonly property real size: root.glyphPaintedWidth * (1 + 0.4 * root.microphoneLevel)

    z: -1
    visible: root.listening && root.microphoneLevel > 0.02
    width: size
    height: size
    radius: size / 2
    x: (root.width - width) / 2 + root.opticalCenterErrorX
    y: (root.height - height) / 2 + root.opticalCenterErrorY
    color: root.foreground
    opacity: 0.5 * root.microphoneLevel
  }

  onPressed: function() {
    if (root.bar) {
      root.bar.run(root.recording ? "omarchy-capture-screenrecording --stop-recording" : "omarchy-menu toggle trigger.capture.screenrecord")
    }
  }
}
