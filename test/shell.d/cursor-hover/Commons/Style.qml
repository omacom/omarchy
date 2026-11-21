pragma Singleton
import QtQuick

// Minimal tokens used by CursorSurface, kept independent of the running
// shell's theme and services.
QtObject {
  property real cornerRadius: 0

  function duration(ms) { return ms }
  function hoverFillFor(foreground, accent) { return "#334455" }
  function selectedFillFor(foreground, accent) { return "#556677" }
}
