import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Commons as Commons

// Map a fresh fullscreen surface on each open. Keep its first frames
// transparent until Qt receives the output's scale, so it opens sharp without
// retaining a parked surface that can be closed when a monitor disconnects.
PanelWindow {
  id: window

  // Whether the overlay is showing. Drive this instead of visible.
  property bool shown: false
  property int shownLayer: WlrLayer.Overlay
  property int shownKeyboardFocus: WlrKeyboardFocus.Exclusive

  // Emitted when the user clicks another output while this overlay holds the
  // keyboard. Overlays treat it like a click on their own scrim.
  signal dismissRequested()

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
    focusPrimed = false
    beginFocusPrime()
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

  // An Exclusive overlay is primed with Exclusive on every open, then settles
  // on OnDemand. Exclusive takes the keyboard even from an application that
  // constrained the pointer, and Hyprland focuses OnDemand only when a surface
  // first maps, not when a mapped one changes from None back to OnDemand. But
  // while a layer is Exclusive, Hyprland routes every click on every output to
  // it, so the dismiss twins below would never see one and the other outputs
  // would be dead to the pointer. OnDemand releases that compositor-wide
  // hit-testing. Same approach as KeyboardPanel.
  readonly property bool exclusive: shownKeyboardFocus === WlrKeyboardFocus.Exclusive
  property bool focusPrimed: false
  WlrLayershell.keyboardFocus: exclusive && focusPrimed ? WlrKeyboardFocus.OnDemand : shownKeyboardFocus

  function beginFocusPrime() {
    if (shown && backingWindowVisible) focusPrimeTimer.restart()
  }
  onBackingWindowVisibleChanged: beginFocusPrime()
  onShownKeyboardFocusChanged: { focusPrimed = false; beginFocusPrime() }

  Timer {
    id: focusPrimeTimer
    // Enough for several Qt/Wayland commit cycles after the surface maps while
    // keeping the compositor-wide Exclusive phase imperceptibly short.
    interval: 75
    onTriggered: if (window.shown) window.focusPrimed = true
  }

  // The surface spans only its own output, and the compositor hit-tests
  // pointer input per output, so the overlay's scrim can never see a click on
  // another monitor. Give every other output a transparent twin whose only job
  // is to catch that click and ask the overlay to close. Keyboard focus None:
  // the twins must catch the pointer without taking the keyboard from the
  // overlay when the cursor merely crosses onto their output.
  Variants {
    model: window.shown && window.exclusive ? Quickshell.screens : []

    delegate: Component {
      PanelWindow {
        required property var modelData

        screen: modelData
        // Compare by output name: the target screen must be known before any
        // twin maps, or a twin would cover the overlay's own output.
        visible: window.shown && !!window.targetScreen && modelData.name !== window.targetScreen.name
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; left: true; bottom: true; right: true }

        WlrLayershell.namespace: "omarchy-overlay-dismiss"
        WlrLayershell.layer: WlrLayer.Overlay
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
