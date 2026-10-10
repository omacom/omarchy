import QtQuick

// Owned by one bar surface, including its timer: removing a screen cannot
// leave a hover or a delayed collapse behind on another monitor.
Item {
  id: root

  property int barHoverCount: 0
  property int centerHoverCount: 0
  readonly property bool barHovered: barHoverCount > 0
  readonly property bool centerSectionHovered: centerHoverCount > 0
  property bool centerSectionRevealHeld: false

  // Revealing widens the center section and may slide a neighbour under a
  // stationary pointer. Hold the peek anywhere on this surface, even over
  // empty space, until the pointer leaves it.
  function setCenterSectionHovered(hovered) {
    centerHoverCount = Math.max(0, centerHoverCount + (hovered ? 1 : -1))
    if (hovered) {
      centerSectionRevealTimer.stop()
      centerSectionRevealHeld = true
    } else {
      centerSectionRevealTimer.restart()
    }
  }

  function setBarHovered(hovered) {
    barHoverCount = Math.max(0, barHoverCount + (hovered ? 1 : -1))
    if (barHoverCount === 0) centerSectionRevealTimer.restart()
  }

  Timer {
    id: centerSectionRevealTimer
    interval: 120
    // A pending leave may fire after the pointer comes back; it may only
    // collapse an existing reveal, never open one from bar hover alone.
    onTriggered: if (!root.centerSectionHovered && !root.barHovered) root.centerSectionRevealHeld = false
  }
}
