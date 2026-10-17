pragma Singleton
import QtQuick

QtObject {
  readonly property bool reduceMotion: true
  readonly property int cornerRadius: 0
  readonly property var spacing: ({
    controlHeight: 36, controlPaddingX: 8, controlPaddingY: 4,
    hairline: 1, labelGap: 4, md: 8, panelGap: 12
  })
  readonly property var font: ({
    family: "sans-serif", body: 13, bodySmall: 12, caption: 10,
    subtitle: 15, iconLarge: 18, displayLarge: 28
  })

  function space(value) { return value }
  function duration(value) { return 0 }
  function hoverStateColor(foreground, accent, urgent) { return "#444444" }
  function selectedStateColor(foreground, accent, urgent) { return "#666666" }
  function hoverFillFor(foreground, accent) { return "#444444" }
  function normalFillFor(foreground, accent) { return "#222222" }
  function selectedFillFor(foreground, accent) { return "#666666" }
  function normalBorderFor(foreground, accent) { return "#333333" }
}
