import QtQuick

// Owned by one bar surface, including its timer: removing a screen cannot
// leave a hover or a delayed collapse behind on another monitor.
Item {
  id: root

  property int barHoverCount: 0
  readonly property bool barHovered: barHoverCount > 0
  property bool centerSectionRevealHeld: false

  // Open from anywhere on this bar, widgets included. Revealing can slide
  // a widget under a stationary pointer, so hold until the whole bar is left.
  function setBarHovered(hovered) {
    barHoverCount = Math.max(0, barHoverCount + (hovered ? 1 : -1))
    if (barHoverCount > 0) {
      centerSectionRevealTimer.stop()
      centerSectionRevealHeld = true
    } else {
      centerSectionRevealTimer.restart()
    }
  }

  Timer {
    id: centerSectionRevealTimer
    interval: 120
    // A pointer that dips off this bar and straight back leaves its peek open.
    onTriggered: if (!root.barHovered) root.centerSectionRevealHeld = false
  }
}
