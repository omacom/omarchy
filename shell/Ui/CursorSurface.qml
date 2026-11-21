import QtQuick
import qs.Commons
import qs.Commons as Commons

// Shared visual chrome for keyboard-and-mouse-navigable items inside a panel.
// Contract: items must NOT read `containsMouse` for color/border. Pointer
// enter claims the panel's cursor at the root and pointer leave releases it
// (see Cursor.applyHover); visuals derive from `hasCursor` / `current`. That
// keeps a single highlight on screen and clears it when the pointer leaves.
//
// The row owns the pointer source: its HoverHandler reports hover for the
// whole row, including child controls, and emits `hovered(bool)` so the panel
// can claim and release the cursor in one place. `pointerInside` lets an
// inline action tell a handoff (pointer still on the row) from a real leave.
//
// Cursor paint is always the shared hover-cursor fill plus optional
// hover-cursor border. `outline` remains as a compatibility flag for
// callers that used to request border-only rows, but slider rows still
// receive the same hover-cursor background as every other row.
BorderSurface {
  id: root

  signal hovered(bool isHovered)
  readonly property alias pointerInside: rowHover.hovered

  property bool hasCursor: false
  // False when the row's click target is disabled, so hover does not claim
  // a cursor the row cannot act on.
  property bool hoverEnabled: true
  property bool current: false
  property bool outline: false
  property bool bordered: false

  property color foreground: Commons.Color.foreground
  property color accent: Commons.Color.accent
  property color fill: Style.hoverFillFor(foreground, accent)
  property color currentFill: Style.selectedFillFor(foreground, accent)

  radius: Style.cornerRadius

  color: hasCursor ? fill : (current ? currentFill : "transparent")
  borderSpec: root.hasCursor
    ? Border.controlSpec("hover-cursor", root.foreground, root.accent)
    : (root.current
      ? Border.controlSpec("selected", root.foreground, root.accent)
      : (root.bordered
        ? Border.controlSpec("normal", root.foreground, root.accent)
        : Border.none()))

  Behavior on color {
    ColorAnimation { duration: Style.duration(60) }
  }

  HoverHandler {
    id: rowHover
    enabled: root.hoverEnabled && root.visible && root.enabled
    onHoveredChanged: root.hovered(hovered)
  }

  // A delegate removed from its model or a panel closing can take the row
  // away without a pointer leave. Release the cursor it still owns.
  Component.onDestruction: if (rowHover.hovered) root.hovered(false)
}
