import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
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

  property var targetScreen: null
  readonly property var liveTargetScreen: targetScreen && Quickshell.screens.indexOf(targetScreen) >= 0 ? targetScreen : null
  readonly property HyprlandMonitor targetMonitor: {
    var screen = liveTargetScreen
    if (!screen) return null
    var monitors = Hyprland.monitors.values
    for (var i = 0; i < monitors.length; i++) {
      if (monitors[i].name === screen.name) return monitors[i]
    }
    return null
  }
  property real queriedScale: 0
  property bool scaleFallbackReady: false
  property bool selectionRevealed: false
  property int selectionSerial: 0
  property bool selectionPending: false
  property string pendingMonitorName: ""
  property string preferredMonitorName: ""
  property var activeMonitorQuery: null

  readonly property real expectedScale: queriedScale > 0 ? queriedScale : (targetMonitor ? targetMonitor.scale : 0)

  // Wait for fullscreen geometry as well as scale so no smaller opening frame
  // is stretched across the output. Fractional scale uses units of 1/120;
  // compare in those units to tolerate floating point rounding.
  readonly property bool contentReady: shown && backingWindowVisible && !!liveTargetScreen
    && width === liveTargetScreen.width && height === liveTargetScreen.height
    && ((expectedScale > 0 && Math.round(devicePixelRatio * 120) === Math.round(expectedScale * 120))
      || scaleFallbackReady)
  property bool contentRevealed: false

  Component.onDestruction: stopActiveQuery()

  onContentReadyChanged: {
    contentRevealed = false
    if (contentReady) {
      scaleFallbackTimer.stop()
      // Resize and scale notifications arrive while Qt is still updating the
      // window. Reveal on the next turn, once its content layout has caught up.
      Qt.callLater(function() {
        if (window.contentReady) window.contentRevealed = true
      })
    }
  }
  onContentRevealedChanged: if (contentRevealed) selectionRevealed = true

  function screenByName(name) {
    if (!name) return null
    for (var i = 0; i < Quickshell.screens.length; i++) {
      if (Quickshell.screens[i].name === name) return Quickshell.screens[i]
    }
    return null
  }

  function focusedScreen() {
    var monitor = Hyprland.focusedMonitor
    var exact = screenByName(monitor ? String(monitor.name || "") : "")
    if (exact) return exact
    return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
  }

  function stopActiveQuery() {
    monitorQueryTimer.stop()
    if (!activeMonitorQuery) return
    var old = activeMonitorQuery
    activeMonitorQuery = null
    old.running = false
    old.destroy()
  }

  function applyResolvedScreen(serial, screen, scale, missingName) {
    if (!shown || !selectionPending || selectionSerial !== serial) return
    monitorQueryTimer.stop()
    selectionPending = false
    pendingMonitorName = missingName || ""
    preferredMonitorName = ""
    queriedScale = scale > 0 ? scale : 0
    scaleFallbackReady = false
    selectionRevealed = false
    targetScreen = screen
    if (screen && !contentReady) scaleFallbackTimer.restart()
  }

  function applyFallbackScreen(serial, preferredName) {
    var monitor = Hyprland.focusedMonitor
    var desired = preferredName || preferredMonitorName || (monitor ? String(monitor.name || "") : "")
    var screen = screenByName(desired) || focusedScreen()
    var missingName = desired && (!screen || screen.name !== desired) ? desired : ""
    applyResolvedScreen(serial, screen, 0, missingName)
  }

  function resolveMonitorQuery(serial, exitCode, output) {
    if (!shown || !selectionPending || selectionSerial !== serial) return
    var focusedName = ""
    var focusedScale = 0
    if (exitCode === 0 && output) {
      try {
        var monitors = JSON.parse(output)
        if (Array.isArray(monitors)) {
          for (var i = 0; i < monitors.length; i++) {
            if (monitors[i] && monitors[i].focused) {
              focusedName = String(monitors[i].name || "")
              focusedScale = Number(monitors[i].scale) || 0
              break
            }
          }
        }
      } catch (error) {}
    }
    var exact = screenByName(focusedName)
    if (exact) {
      applyResolvedScreen(serial, exact, focusedScale, "")
      return
    }
    applyFallbackScreen(serial, focusedName)
  }

  function startMonitorQuery(serial) {
    if (!shown || !selectionPending || selectionSerial !== serial) return
    stopActiveQuery()
    var proc = monitorQueryComponent.createObject(window, { serial: serial })
    if (!proc) {
      applyFallbackScreen(serial, "")
      return
    }
    activeMonitorQuery = proc
    monitorQueryTimer.restart()
    proc.running = true
  }

  function runScreenSelection(serial) {
    if (!shown || !selectionPending || selectionSerial !== serial) return
    Hyprland.refreshMonitors()
    if (Quickshell.screens.length <= 1) {
      applyFallbackScreen(serial, "")
      return
    }
    startMonitorQuery(serial)
  }

  // One path for opening and unplug recovery. Each call bumps selectionSerial
  // so any queued callback or in-flight query from a previous open or unplug
  // cannot write a stale targetScreen.
  function beginScreenSelection(defer) {
    selectionSerial += 1
    var serial = selectionSerial
    selectionPending = shown
    pendingMonitorName = ""
    preferredMonitorName = ""
    queriedScale = 0
    scaleFallbackReady = false
    selectionRevealed = false
    scaleFallbackTimer.stop()
    stopActiveQuery()
    targetScreen = null

    if (!shown) return
    // Deferred callers (unplug recovery) wait one turn so Qt finishes tearing
    // down the removed output's window and screen counts reflect live state.
    if (defer) Qt.callLater(function() { window.runScreenSelection(serial) })
    else runScreenSelection(serial)
  }

  // Live monitor scaling does not emit a Hyprland monitor event, so its cached
  // scale can lag behind Qt. Refresh on opening and on scale changes while open.
  onShownChanged: beginScreenSelection(false)
  onDevicePixelRatioChanged: {
    if (!shown) return
    if (selectionRevealed) {
      queriedScale = 0
      scaleFallbackReady = false
    }
    Hyprland.refreshMonitors()
    if (liveTargetScreen && !contentReady) scaleFallbackTimer.restart()
  }
  // If the compositor closes a showing layer surface (e.g. during output
  // removal before or after screensChanged), remap onto a live output.
  onVisibleChanged: {
    if (!visible && shown && !selectionPending && liveTargetScreen)
      beginScreenSelection(true)
  }

  Component {
    id: monitorQueryComponent

    Process {
      id: proc
      required property int serial
      property string collected: ""
      property bool streamDone: false
      property bool processExited: false
      property int lastExitCode: -1
      property bool finished: false
      command: ["hyprctl", "-j", "monitors"]

      function maybeFinish() {
        if (finished || !processExited) return
        if (lastExitCode === 0 && !streamDone) return
        finished = true
        if (window.activeMonitorQuery === proc) window.activeMonitorQuery = null
        if (serial === window.selectionSerial) {
          monitorQueryTimer.stop()
          window.resolveMonitorQuery(serial, lastExitCode, collected)
        }
        proc.destroy()
      }

      stdout: StdioCollector {
        waitForEnd: true
        onStreamFinished: {
          proc.collected = text
          proc.streamDone = true
          proc.maybeFinish()
        }
      }

      onExited: function(exitCode) {
        proc.lastExitCode = exitCode
        proc.processExited = true
        proc.maybeFinish()
      }
    }
  }

  // Bounded fallback if hyprctl stalls on a multi-output open.
  Timer {
    id: monitorQueryTimer
    interval: 250
    repeat: false
    onTriggered: {
      if (window.shown && window.selectionPending) {
        window.stopActiveQuery()
        window.applyFallbackScreen(window.selectionSerial, "")
      }
    }
  }

  // Bounded fallback if Hyprland's monitor record is missing or holds a stale
  // scale so an overlay never stays permanently transparent.
  Timer {
    id: scaleFallbackTimer
    interval: 250
    repeat: false
    onTriggered: {
      if (window.shown && window.liveTargetScreen && !window.contentReady)
        window.scaleFallbackReady = true
    }
  }

  Connections {
    target: Quickshell
    function onScreensChanged() {
      if (!window.shown) {
        if (window.targetScreen && Quickshell.screens.indexOf(window.targetScreen) < 0)
          window.targetScreen = null
        return
      }
      if (window.selectionPending) {
        if (Quickshell.screens.length <= 1 && window.activeMonitorQuery)
          window.beginScreenSelection(true)
        return
      }
      if (window.pendingMonitorName) {
        var arrived = window.screenByName(window.pendingMonitorName)
        if (arrived && arrived !== window.targetScreen) {
          var expectedName = window.pendingMonitorName
          window.beginScreenSelection(true)
          window.preferredMonitorName = expectedName
          return
        }
      }
      if (Quickshell.screens.indexOf(window.targetScreen) < 0) {
        window.beginScreenSelection(true)
      }
    }
  }

  visible: shown && !!liveTargetScreen
  screen: liveTargetScreen
  anchors { top: true; left: true; bottom: true; right: true }
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: shownLayer
  WlrLayershell.keyboardFocus: shownKeyboardFocus

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
