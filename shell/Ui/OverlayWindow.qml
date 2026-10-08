import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// Map a fresh fullscreen surface on each open. Keep its first frames
// transparent until Qt receives the output's scale, so it opens sharp without
// retaining a parked surface that can be closed when a monitor disconnects.
PanelWindow {
  id: window

  // Whether the overlay is showing. Drive this instead of visible.
  property bool shown: false
  property int shownLayer: WlrLayer.Overlay
  property int shownKeyboardFocus: WlrKeyboardFocus.Exclusive

  // Exclusive keyboard focus makes Hyprland route every pointer and touch event
  // to this surface, including those aimed at a surface drawn above it, so an
  // on-screen keyboard over the overlay cannot be tapped. A cooperative overlay
  // holds Exclusive only until keyboard focus arrives, then settles on OnDemand,
  // which lets those surfaces be reached. Off by default: an overlay opts in
  // only where yielding the pointer is safe, never for a password prompt.
  property bool cooperativeFocus: false
  readonly property bool cooperating: shown && cooperativeFocus && shownKeyboardFocus === WlrKeyboardFocus.Exclusive
  property bool focusHeld: false
  // Asks the owner to dismiss through its own cancel path: a click landed on
  // another output, or keyboard focus left.
  signal dismissRequested()

  onCooperatingChanged: focusHeld = cooperating && focusProbe.active

  property var targetScreen: null
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
    targetScreen = shown ? focusedScreen() : null
    if (shown) Hyprland.refreshMonitors()
  }
  onDevicePixelRatioChanged: if (shown) Hyprland.refreshMonitors()

  Connections {
    target: Quickshell
    function onScreensChanged() {
      if (window.shown && Quickshell.screens.indexOf(window.targetScreen) < 0) {
        window.targetScreen = null
        // Let the removed output finish closing its old window before mapping
        // a replacement, rather than recreating it during Qt's teardown.
        Qt.callLater(function() {
          if (window.shown && !window.targetScreen) window.targetScreen = window.focusedScreen()
        })
      }
    }
  }

  visible: shown && !!targetScreen && !!targetMonitor
  screen: targetScreen
  anchors { top: true; left: true; bottom: true; right: true }
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: shownLayer
  WlrLayershell.keyboardFocus: cooperating && focusHeld ? WlrKeyboardFocus.OnDemand : shownKeyboardFocus

  // OnDemand lets keyboard focus leave, where Exclusive refuses the change. When
  // a focus keybinding or another surface takes the keyboard, ask to be
  // dismissed rather than stay drawn while keystrokes go elsewhere. Returning
  // to Exclusive would take focus back, but also from a password prompt.
  Item {
    id: focusProbe
    readonly property bool active: Window.active

    onActiveChanged: {
      // A closing overlay loses focus too, and has already cleared shown.
      if (!window.shown || !window.visible || !window.cooperating) return
      if (active) window.focusHeld = true
      else if (window.focusHeld) window.dismissRequested()
    }
  }

  // OnDemand also stops routing clicks on other outputs here. Give each of
  // them a transparent twin that catches the click, as Ui/KeyboardPanel.qml
  // does. Keyboard focus is None so the pointer merely crossing onto another
  // output does not move focus to a window there.
  Variants {
    model: window.cooperating ? Quickshell.screens : []

    delegate: Component {
      PanelWindow {
        required property var modelData

        screen: modelData
        visible: window.cooperating && window.visible && modelData.name !== window.targetScreen.name
        anchors { top: true; left: true; bottom: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "omarchy-overlay-dismiss"
        WlrLayershell.layer: window.shownLayer
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        MouseArea {
          anchors.fill: parent
          acceptedButtons: Qt.AllButtons
          onPressed: window.dismissRequested()
        }
      }
    }
  }

  // Opacity preserves keyboard handling while the scale arrives, including
  // search keystrokes and Escape pressed immediately after opening.
  Binding {
    target: window.contentItem
    property: "opacity"
    value: window.contentRevealed ? 1 : 0
  }
}
