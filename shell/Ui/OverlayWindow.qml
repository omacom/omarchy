import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// A fullscreen overlay whose surface outlives each open. A fresh surface draws
// its first frames before the compositor sends its fractional scale, so an
// overlay mapped per open flashed blurry until the scale arrived. Closed, the
// surface parks as a 1x1, input-less, content-less layer below windows: small
// enough to cost nothing, off the overlay layer so it never blocks direct
// scanout for fullscreen apps. Opening only resizes and raises it.
PanelWindow {
  id: window

  // Whether the overlay is showing. Drive this instead of visible.
  property bool shown: false
  property int shownLayer: WlrLayer.Overlay
  property int shownKeyboardFocus: WlrKeyboardFocus.Exclusive

  // The surface no longer lands on the focused output by being mapped there,
  // so it follows the focused monitor each time it is shown. Unset until the
  // first show lets the compositor choose.
  property var targetScreen: null
  property Region emptyRegion: Region {}

  function focusedScreen() {
    var monitor = Hyprland.focusedMonitor
    var name = monitor ? String(monitor.name || "") : ""
    for (var i = 0; i < Quickshell.screens.length; i++) {
      if (Quickshell.screens[i].name === name) return Quickshell.screens[i]
    }
    return null
  }

  onShownChanged: if (shown) targetScreen = focusedScreen() || targetScreen

  visible: true
  screen: targetScreen
  anchors { top: true; left: true; bottom: shown; right: shown }
  implicitWidth: 1
  implicitHeight: 1
  mask: shown ? null : emptyRegion
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: shown ? shownLayer : WlrLayer.Bottom
  WlrLayershell.keyboardFocus: shown ? shownKeyboardFocus : WlrKeyboardFocus.None

  // Draw nothing until the surface has actually grown. A frame drawn while it
  // is still 1x1 holds only the scrim's color, which the compositor would
  // stretch across the whole screen until the fullscreen frame arrives.
  Binding {
    target: window.contentItem
    property: "visible"
    value: window.shown && window.width > 1 && window.height > 1
  }
}
