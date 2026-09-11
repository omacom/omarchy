import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.microphone"

  readonly property var source: Pipewire.defaultAudioSource
  readonly property bool muted: source && source.audio ? source.audio.muted : true
  readonly property real volume: source && source.audio ? source.audio.volume : 0
  readonly property var nodes: Pipewire.nodes ? Pipewire.nodes.values : []

  readonly property var captureStreams: {
    var list = []
    for (var i = 0; i < nodes.length; i++) {
      var node = nodes[i]
      if (node && node.isStream && node.isSink === false && node.audio) list.push(node)
    }
    return list
  }

  readonly property var activeStreams: captureStreams.filter(node => node.ready && !node.audio.muted)
  readonly property var applicationNames: {
    var names = []
    for (var i = 0; i < activeStreams.length; i++) {
      var name = applicationName(activeStreams[i])
      if (names.indexOf(name) === -1) names.push(name)
    }
    return names.sort()
  }

  readonly property bool inUse: activeStreams.length > 0 && !muted
  readonly property string tooltipText: {
    var status = muted ? "Microphone muted" : (inUse ? "Microphone in use" : "Microphone live")
    return status + (applicationNames.length > 0 ? "\n" + applicationNames.join("\n") : "")
  }

  visible: source !== null
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function toggleMute() {
    if (source && source.audio) source.audio.muted = !source.audio.muted
  }

  function applicationName(node) {
    // PipeWire properties are only safe to read after the tracker binds the node.
    var props = node.ready ? node.properties : {}
    var desktopID = props["application.desktop"] || props["application.id"] || ""
    var binary = props["application.process.binary"] || ""
    var entry = null
    // Re-evaluate the label when the desktop entry catalogue finishes loading.
    if (DesktopEntries.applications.values.length > 0) {
      if (desktopID) entry = DesktopEntries.heuristicLookup(desktopID)
      if (!entry && binary) entry = DesktopEntries.heuristicLookup(binary)
    }
    // Electron apps can advertise "Chromium input"; the executable identifies the app.
    return entry ? entry.name : (binary || props["application.name"] || node.description || node.name || "Unknown application")
  }

  PwObjectTracker { objects: root.source ? [root.source].concat(root.captureStreams) : root.captureStreams }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.muted ? "󰍭" : "󰍬"
    active: root.inUse
    tooltipText: root.tooltipText
    onTooltipTextChanged: if (tooltipHovered && root.bar) root.bar.showTooltip(button, tooltipText)
    onPressed: function(b) {
      if (b === Qt.MiddleButton) root.bar.run("omarchy-shell shell toggle omarchy.audio")
      else root.toggleMute()
    }
    onWheelMoved: function(delta) {
      if (!root.source || !root.source.audio) return
      var step = 0.05
      root.source.audio.volume = Math.max(0, Math.min(1, root.volume + (delta > 0 ? step : -step)))
    }
  }
}
