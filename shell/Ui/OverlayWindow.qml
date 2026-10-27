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

  // Exclusive keyboard focus makes Hyprland route every pointer and touch event
  // to this surface, including those aimed at a surface drawn above it, so an
  // on-screen keyboard over the overlay cannot be tapped. A cooperative overlay
  // holds Exclusive only until keyboard focus arrives, then settles on OnDemand,
  // which lets those surfaces be reached. Off by default: an overlay opts in
  // only where yielding the pointer is safe, never for a password prompt.
  // true always cooperates. "auto" cooperates only while something other than
  // the shell's own bar reserves space on the overlay's output, which is what a
  // docked on-screen keyboard does, and is stock everywhere else.
  property var cooperativeFocus: false
  // What the shell itself reserves, in Hyprland's order, so "auto" does not
  // mistake the bar for a competing surface.
  property var ownReservedSpace: [0, 0, 0, 0]
  readonly property bool competingSurface: {
    for (var i = 0; i < 4; i++) {
      // Fractional scales round the two sides separately; allow a pixel.
      if (monitorReservedSpace[i] - (Number(ownReservedSpace && ownReservedSpace[i]) || 0) > 1) return true
    }
    return false
  }
  readonly property bool cooperative: cooperativeFocus === true || (cooperativeFocus === "auto" && competingSurface && cooperationSettled)
  readonly property bool cooperating: shown && cooperative && shownKeyboardFocus === WlrKeyboardFocus.Exclusive
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

  // Hyprland reports the space surfaces reserve as [left, top, right, bottom].
  // Only an overlay that may cooperate reads it.
  readonly property var monitorReservedSpace: {
    var reserved = cooperativeFocus !== false && targetMonitor && targetMonitor.lastIpcObject ? targetMonitor.lastIpcObject.reserved : null
    return reserved && reserved.length === 4 ? reserved : [0, 0, 0, 0]
  }
  // A cooperative overlay also leaves that space alone, so it sits above an
  // on-screen keyboard instead of running underneath it.
  readonly property var reservedSpace: cooperative ? monitorReservedSpace : [0, 0, 0, 0]

  // Wait for fullscreen geometry as well as scale so no smaller opening frame
  // is stretched across the output. Fractional scale uses units of 1/120;
  // compare in those units to tolerate floating point rounding.
  readonly property bool contentReady: shown && backingWindowVisible && !!targetScreen
    && width === targetScreen.width - reservedSpace[0] - reservedSpace[2] && height === targetScreen.height - reservedSpace[1] - reservedSpace[3]
    && !!targetMonitor && Math.round(devicePixelRatio * 120) === Math.round(targetMonitor.scale * 120)
    && cooperationSettled
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
    reservedSpaceFresh = false
    openingSizeSettled = false
    targetScreen = shown ? focusedScreen() : null
    if (shown) Hyprland.refreshMonitors()
  }

  // "auto" opens exactly as a stock overlay does, so it has the keyboard from
  // the first keystroke, and decides whether to cooperate afterwards. Two
  // things have to be in first. The reserved space cached from before the
  // overlay opened may predate a keyboard, so Hyprland must have answered the
  // refresh above. And an overlay that turns cooperative while its first size
  // is still being settled keeps the full screen and covers the keyboard, so
  // that size must have arrived. Content stays transparent until both have.
  property bool reservedSpaceFresh: false
  property bool openingSizeSettled: false
  readonly property bool openingSize: shown && backingWindowVisible && !!targetScreen
    && width === targetScreen.width && height === targetScreen.height
  onOpeningSizeChanged: if (openingSize) openingSizeSettled = true
  readonly property bool cooperationSettled: cooperativeFocus !== "auto" || (reservedSpaceFresh && openingSizeSettled)
  Connections {
    target: window.targetMonitor
    enabled: window.shown && !window.reservedSpaceFresh
    // Next turn, so the bindings reading the answer settle first.
    function onLastIpcObjectChanged() {
      Qt.callLater(function() { if (window.shown) window.reservedSpaceFresh = true })
    }
  }
  // Never hold content back for an answer that does not come.
  Timer {
    interval: 250
    running: window.shown && window.cooperativeFocus === "auto" && !window.reservedSpaceFresh
    onTriggered: window.reservedSpaceFresh = true
  }
  onDevicePixelRatioChanged: if (shown) Hyprland.refreshMonitors()
  // A keyboard appearing or leaving resizes a cooperative overlay; the reserved
  // space cached from Hyprland lags behind in the same way.
  onWidthChanged: if (shown && cooperativeFocus !== false) Hyprland.refreshMonitors()
  onHeightChanged: if (shown && cooperativeFocus !== false) Hyprland.refreshMonitors()

  // Quickshell drops a refresh requested while another is in flight, so the
  // answer to a resize can be the reserved space from before it, and nothing
  // then asks again. Content waits on the two agreeing: keep asking until
  // they do, rather than leave an overlay that is open but never revealed.
  Timer {
    interval: 100
    repeat: true
    running: window.shown && window.cooperative && window.backingWindowVisible && !window.contentReady
    onTriggered: Hyprland.refreshMonitors()
  }

  // A stock-sized overlay is not resized by a keyboard that arrives after it
  // opened, so "auto" asks again when a layer surface comes or goes.
  Connections {
    target: Hyprland
    enabled: window.shown && window.cooperativeFocus === "auto"
    function onRawEvent(event) {
      if (event.name === "openlayer" || event.name === "closelayer") Hyprland.refreshMonitors()
    }
  }

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
  exclusionMode: cooperative ? ExclusionMode.Normal : ExclusionMode.Ignore
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
      // Dismissing unmaps the window, which changes the very property this
      // handler is reporting. Do it on the next turn, outside that binding.
      else if (window.focusHeld) Qt.callLater(function() {
        if (window.shown && window.cooperating && !focusProbe.active) window.dismissRequested()
      })
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
