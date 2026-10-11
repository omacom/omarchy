import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.Ui
import qs.Commons

BarWidget {
  id: root
  moduleName: "omarchy.microphone"


  readonly property var source: Pipewire.defaultAudioSource
  // A virtual source is untyped in Quickshell, so it has no PwNode.audio; its
  // volume and mute go through wpctl (UntypedInput).
  readonly property bool viaWpctl: UntypedInput.active
  readonly property bool muted: viaWpctl ? (!UntypedInput.known || UntypedInput.muted) : (source && source.audio ? source.audio.muted : true)
  readonly property real volume: viaWpctl ? UntypedInput.volume : (source && source.audio ? source.audio.volume : 0)
  readonly property var nodes: Pipewire.nodes ? Pipewire.nodes.values : []
  readonly property var nodeNames: {
    var names = []
    for (var i = 0; i < nodes.length; i++)
      if (nodes[i] && nodes[i].name) names.push(String(nodes[i].name))
    return names
  }

  readonly property var activeStreams: {
    var list = []
    for (var i = 0; i < nodes.length; i++) {
      var node = nodes[i]
      if (!node || !node.isStream || node.isSink !== false || node.audio?.muted) continue
      // The shell's own level meters, and a platform's audio processing that
      // records all the time, are not an app using the microphone.
      if (AudioNodes.isShellLevelMeter(node.name) || AudioNodes.platformHides(node.name, nodeNames)) continue
      list.push(node)
    }
    return list
  }

  readonly property bool inUse: activeStreams.length > 0 && !muted

  visible: source !== null
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function toggleMute() {
    if (viaWpctl) {
      if (UntypedInput.known) UntypedInput.setMuted(!UntypedInput.muted)
    }
    else if (source && source.audio) source.audio.muted = !source.audio.muted
  }

  PwObjectTracker { objects: root.source ? [root.source] : [] }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.muted ? "󰍭" : "󰍬"
    active: root.inUse
    tooltipText: root.muted ? "Microphone muted" : (root.inUse ? "Microphone in use" : "Microphone live")
    onPressed: function(b) {
      if (b === Qt.MiddleButton) root.bar.run("omarchy-shell shell toggle omarchy.audio")
      else root.toggleMute()
    }
    onWheelMoved: function(delta) {
      var step = 0.05
      if (root.viaWpctl) {
        if (UntypedInput.known) UntypedInput.setVolume(root.volume + (delta > 0 ? step : -step))
        return
      }
      if (!root.source || !root.source.audio) return
      root.source.audio.volume = Math.max(0, Math.min(1, root.volume + (delta > 0 ? step : -step)))
    }
  }
}
