import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Commons as Commons

// A fullscreen overlay whose surface outlives each open. Closed, the surface
// parks as a 1x1, input-less, content-less layer below windows: small enough
// to cost nothing, off the overlay layer so it never blocks direct scanout for
// fullscreen apps. Opening only resizes and raises it, so the compositor can
// grant it exclusive keyboard focus immediately rather than after a fresh
// surface maps — keys typed straight after summoning reach the overlay.
// Keep its first frames transparent until Qt receives the output's scale, so
// it opens sharp.
PanelWindow {
  id: window

  // Whether the overlay is showing. Drive this instead of visible.
  property bool shown: false
  property int shownLayer: WlrLayer.Overlay
  property int shownKeyboardFocus: WlrKeyboardFocus.Exclusive

  // Park on the focused screen from the start, so the first open does not
  // move (and remap) the surface: a screen change on open would let the
  // first keys typed at once reach the window behind the overlay again.
  property var targetScreen: focusedScreen()
  property Region emptyRegion: Region {}
  readonly property var targetMonitor: {
    var monitors = Hyprland.monitors.values
    for (var i = 0; i < monitors.length; i++) {
      if (targetScreen && monitors[i].name === targetScreen.name) return monitors[i]
    }
    return null
  }

  // Wait for fullscreen geometry as well as scale so no smaller opening frame
  // is stretched across the output. Fractional scale uses units of 1/120;
  // compare in those units to tolerate floating point rounding.
  readonly property bool contentReady: shown && backingWindowVisible && !!targetScreen
    && width === targetScreen.width && height === targetScreen.height
    && !!targetMonitor && Math.round(devicePixelRatio * 120) === Math.round(targetMonitor.scale * 120)
  property bool contentRevealed: false

  onContentReadyChanged: {
    contentRevealed = false
    // Resize and scale notifications arrive while Qt is still updating the
    // window. Reveal on the next turn, once its content layout has caught up.
    if (contentReady) Qt.callLater(function() {
      if (window.contentReady) window.contentRevealed = true
    })
  }

  function focusedScreen() {
    var monitor = Hyprland.focusedMonitor
    var name = monitor ? String(monitor.name || "") : ""
    for (var i = 0; i < Quickshell.screens.length; i++) {
      if (Quickshell.screens[i].name === name) return Quickshell.screens[i]
    }
    return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
  }

  // Live monitor scaling does not emit a Hyprland monitor event, so its cached
  // scale can lag behind Qt. Refresh on opening and on scale changes while open.
  onShownChanged: {
    if (shown) {
      var screen = focusedScreen()
      if (screen && screen !== targetScreen) targetScreen = screen
      Hyprland.refreshMonitors()
    }
  }
  onDevicePixelRatioChanged: if (shown) Hyprland.refreshMonitors()

  Connections {
    target: Quickshell
    function onScreensChanged() {
      if (!window.targetScreen) {
        window.targetScreen = window.focusedScreen()
        return
      }
      if (Quickshell.screens.indexOf(window.targetScreen) < 0) {
        window.targetScreen = null
        // Let the removed output finish closing its old window before mapping
        // a replacement, rather than recreating it during Qt's teardown.
        Qt.callLater(function() {
          if (!window.targetScreen) window.targetScreen = window.focusedScreen()
        })
      }
    }
  }

  visible: !!targetScreen && !!targetMonitor
  screen: targetScreen
  anchors { top: true; left: true; bottom: shown; right: shown }
  implicitWidth: 1
  implicitHeight: 1
  mask: shown ? null : emptyRegion
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: shown ? shownLayer : WlrLayer.Bottom
  WlrLayershell.keyboardFocus: shown ? shownKeyboardFocus : WlrKeyboardFocus.None

  // Opacity preserves keyboard handling while the scale arrives, including
  // search keystrokes and Escape pressed immediately after opening.
  Binding {
    target: window.contentItem
    property: "opacity"
    value: window.contentRevealed ? 1 : 0
  }

  // Right-to-left languages read the overlay mirrored.
  Binding {
    target: window.contentItem
    property: "LayoutMirroring.enabled"
    value: Commons.I18n.rightToLeft
  }
  Binding {
    target: window.contentItem
    property: "LayoutMirroring.childrenInherit"
    value: true
  }
}
