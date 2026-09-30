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
  // so it follows the focused monitor. It moves while parked: changing screen
  // recreates the layer surface, and one recreated in the same step that shows
  // it came back on the bottom layer without keyboard focus, so the open was
  // invisible and the next press closed it.
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

  function followFocusedScreen() {
    if (!shown) targetScreen = focusedScreen() || targetScreen
  }

  Component.onCompleted: followFocusedScreen()
  // After the layer binding has settled, so a hidden surface parks on the bottom layer.
  onShownChanged: Qt.callLater(followFocusedScreen)

  Connections {
    target: Hyprland
    function onFocusedMonitorChanged() { window.followFocusedScreen() }
  }

  // The compositor closes a layer surface whose output goes away, and
  // Quickshell answers by hiding the window for good. Unplugging the monitor
  // an overlay last opened on -- or the last monitor, leaving no output at all
  // -- would otherwise leave that overlay dead until the shell restarted. Map
  // it again once a real screen is there to hold it; Qt's placeholder screen
  // is not one, and the compositor would only close the surface again.
  function hasRealScreen() {
    for (var i = 0; i < Quickshell.screens.length; i++) {
      var candidate = Quickshell.screens[i]
      if (candidate && candidate.name && candidate.width > 0 && candidate.height > 0) return true
    }
    return false
  }

  function remap() {
    if (visible || !hasRealScreen()) return
    if (Quickshell.screens.indexOf(targetScreen) < 0) targetScreen = null
    visible = true
  }

  // Focus can move to a monitor before Quickshell lists its screen, so the
  // focus handler keeps the previous target and this retries once the list
  // catches up. Deferred with the hide path: a screen can leave while Qt is
  // still tearing that surface down, and mapping again inside the close would
  // reuse it.
  function recoverSurface() {
    followFocusedScreen()
    remap()
  }

  onVisibleChanged: if (!visible) Qt.callLater(recoverSurface)

  Connections {
    target: Quickshell
    function onScreensChanged() { Qt.callLater(window.recoverSurface) }
  }

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
