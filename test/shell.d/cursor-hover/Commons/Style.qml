pragma Singleton
import QtQuick

// Minimal state tokens used by CursorSurface and the real Border.controlSpec.
// Values are fixed; the test checks cursor state, not theme output.
QtObject {
  property real cornerRadius: 0
  property var styleOverrides: ({})

  readonly property int normalBorderWidth: 1
  readonly property int hoverBorderWidth: 1
  readonly property int selectedBorderWidth: 0
  readonly property int focusBorderWidth: 1

  readonly property real normalBorderAlpha: 0.4
  readonly property real hoverBorderAlpha: 0.25
  readonly property real selectedBorderAlpha: 1.0
  readonly property real focusBorderAlpha: 0.25

  function duration(ms) { return ms }
  function normalStateColor(foreground, accent, urgent) { return foreground }
  function hoverStateColor(foreground, accent, urgent) { return foreground }
  function selectedStateColor(foreground, accent, urgent) { return foreground }
  function focusStateColor(foreground, accent, urgent) { return foreground }

  function hoverFillFor(foreground, accent, urgent) { return "#334455" }
  function selectedFillFor(foreground, accent, urgent) { return "#556677" }
}
