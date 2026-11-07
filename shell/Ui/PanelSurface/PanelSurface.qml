pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Commons

// One transparent overlay window per output that every KeyboardPanel draws
// its card into. Quickshell destroys a layer-shell window when it hides, so a
// window per panel built a new GL context, swapchain and glyph atlas on every
// open and held the whole shell still for up to 200ms; shrinking kept windows
// instead still cost one context per panel. These are made once, the first
// time the pointer reaches a panel's icon or a panel opens, and never resized.
//
// The panels keep their own behaviour. This only holds what has to be set on
// a window: the input region (everything but the bar strip while a panel is
// open anywhere, so a click outside closes it and a click on the bar reaches
// the bar; nothing otherwise) and keyboard focus (for the
// panel open on this output, primed by the panel). An idle surface steps aside
// under a fullscreen window, since Hyprland won't scan a game out past any
// overlay surface.
Singleton {
  id: root

  property bool wanted: false
  // Every panel that has opened, oldest open first.
  property var panels: []
  // Every panel, opened or not: one on each output says where its bar is.
  property var known: []
  property int stackTop: 0
  // Output name -> the item cards on that output are parented to.
  property var layers: ({})
  // Output name -> its window.
  property var windows: ({})

  // Moves the panel to the top and returns its z, so the card that opened last
  // is drawn over one still fading out.
  function raise(panel) {
    wanted = true
    panels = panels.filter(function(p) { return p !== panel }).concat([panel])
    return ++stackTop
  }

  function track(panel) {
    known = known.concat([panel])
  }

  function forget(panel) {
    panels = panels.filter(function(p) { return p !== panel })
    known = known.filter(function(p) { return p !== panel })
  }

  readonly property bool anyOpen: panels.some(function(p) { return p.open })

  function onOutput(panel, name) {
    return !!panel.screen && panel.screen.name === name
  }

  function fullscreenOn(output) {
    var monitor = Hyprland.monitorFor(output)
    return !!monitor && !!monitor.activeWorkspace && monitor.activeWorkspace.hasFullscreen
  }

  function panelName(panel) {
    return String(panel.owner && (panel.owner.moduleName || panel.owner.ipcTarget) || "")
  }

  // Which panels are drawn, for scripts: the windows stay mapped between opens,
  // so the compositor can't tell.
  ShellIpc {
    target: "panels"

    function probe(): string {
      return JSON.stringify({
        open: root.panels.filter(function(p) { return p.open }).map(root.panelName),
        drawn: root.panels.filter(function(p) { return p.inUse }).map(root.panelName),
        surfaces: Object.keys(root.windows).map(function(name) {
          return { display: name, mapped: root.windows[name].visible && root.windows[name].backingWindowVisible }
        }) })
    }
  }

  Variants {
    model: root.wanted ? Quickshell.screens : []

    delegate: Component {
      PanelWindow {
        id: surface
        required property var modelData
        readonly property string outputName: modelData.name
        readonly property var openPanel: {
          var open = root.panels.filter(function(p) { return p.open && root.onOutput(p, surface.outputName) })
          return open.length > 0 ? open[open.length - 1] : null
        }
        readonly property bool drawing: root.panels.some(function(p) { return p.inUse && root.onOutput(p, surface.outputName) })
        // Where this output's bar is, from a panel on it: the built-in bar's
        // first, since only it knows its notch floor and when it is hidden.
        readonly property var barSource: {
          var any = null
          for (var i = 0; i < root.known.length; i++) {
            var p = root.known[i]
            if (!p.bar || !root.onOutput(p, surface.outputName)) continue
            if (typeof p.bar.barSizeFor === "function") return p
            if (!any) any = p
          }
          return any
        }
        readonly property string barPos: barSource ? barSource.barPos : "top"
        // A fullscreen window covers the bar, so there is no bar to click there.
        readonly property real barStrip: barSource && !root.fullscreenOn(modelData) ? barSource.barStripSize : 0
        readonly property bool barVertical: barPos === "left" || barPos === "right"

        screen: modelData
        visible: drawing || root.anyOpen || !root.fullscreenOn(modelData)
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        anchors {
          top: true
          bottom: true
          left: true
          right: true
        }

        WlrLayershell.namespace: "omarchy-keyboard-panel"
        WlrLayershell.layer: WlrLayer.Overlay
        // See KeyboardPanel's focus prime. An output with no panel open takes
        // no focus: it only catches the click that closes a panel elsewhere.
        WlrLayershell.keyboardFocus: openPanel
          ? (openPanel.focusPrimed ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.Exclusive)
          : WlrKeyboardFocus.None

        // The bar strip is left out, so a click on the bar does there what it
        // does with no panel open, whichever plugin the widget comes from;
        // the bar closes the panel on a click that lands on no widget.
        mask: Region {
          width: root.anyOpen ? surface.modelData.width : 0
          height: root.anyOpen ? surface.modelData.height : 0

          Region {
            x: surface.barPos === "right" ? surface.modelData.width - surface.barStrip : 0
            y: surface.barPos === "bottom" ? surface.modelData.height - surface.barStrip : 0
            width: surface.barVertical ? surface.barStrip : surface.modelData.width
            height: surface.barVertical ? surface.modelData.height : surface.barStrip
            intersection: Intersection.Subtract
          }
        }

        Item {
          id: layer
          anchors.fill: parent
        }

        Component.onCompleted: {
          root.layers = Object.assign({}, root.layers, { [outputName]: layer })
          root.windows = Object.assign({}, root.windows, { [outputName]: surface })
        }
        Component.onDestruction: {
          var layers = Object.assign({}, root.layers)
          var windows = Object.assign({}, root.windows)
          delete layers[outputName]
          delete windows[outputName]
          root.layers = layers
          root.windows = windows
        }
      }
    }
  }
}
