import QtQuick

// Hyprland leaves an already-mapped layer surface at its old global position
// when its monitor moves within the layout: undocking disables the internal
// panel, the external monitor shifts to x=0, and long-lived surfaces such as
// the bar and background keep rendering at the old offset — or entirely
// off-screen — until they are unmapped and remapped. Watch the screen's
// origin and pulse `remapping` when it moves; the owning window folds that
// into its `visible` binding so the compositor re-places the surface at the
// monitor's new origin.
Item {
  id: root

  required property var window
  readonly property var screen: window ? window.screen : null

  // Fold into the window's binding: visible: <shown> && !guard.remapping
  property bool remapping: false

  visible: false

  // A layout reshuffle can move the monitor more than once before it lands.
  // Let the positions settle before the single remap pulse.
  Timer {
    id: settleTimer
    interval: 200
    onTriggered: root.remapping = true
  }

  // Hold the surface unmapped for a beat so the compositor processes the
  // unmap before the remap instead of coalescing them into a no-op.
  Timer {
    interval: 50
    running: root.remapping
    onTriggered: root.remapping = false
  }

  // Quickshell signals x and y on every geometry change, so a rotation or mode
  // change that keeps the origin would remap too. Only a moved origin does.
  property int lastX: 0
  property int lastY: 0

  function syncOrigin() {
    if (!screen) return
    lastX = screen.x
    lastY = screen.y
  }

  function originMoved() {
    if (!screen || (screen.x === lastX && screen.y === lastY)) return
    lastX = screen.x
    lastY = screen.y
    settleTimer.restart()
  }

  Component.onCompleted: syncOrigin()
  onScreenChanged: syncOrigin()

  Connections {
    target: root.screen
    function onXChanged() { root.originMoved() }
    function onYChanged() { root.originMoved() }
  }
}
