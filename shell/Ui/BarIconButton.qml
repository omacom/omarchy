import QtQuick
import Quickshell
import qs.Commons

WidgetButton {
  id: root

  property Component iconComponent: null
  property real slotSize: Style.bar.iconSlot
  property real opticalSize: Style.bar.iconCanvas
  property bool debugOpticalBounds: Quickshell.env("OMARCHY_DEBUG_BAR_ICONS") === "1"
  // Measured against the slot, which the open-panel underline centers on.
  readonly property real opticalCenterErrorX: glyph.visible ? opticalCanvas.x + glyph.paintedCenterX - root.width / 2 : 0
  readonly property real glyphPaintedWidth: glyph.visible ? glyph.tightWidth : 0
  readonly property real glyphBaselineY: glyph.visible ? glyph.baselineY : 0
  readonly property int glyphFontSize: glyph.visible ? glyph.renderedFontSize : 0

  labelVisible: false
  hasVisualContent: text !== "" || iconComponent !== null
  fontSize: Style.bar.iconFont
  fixedWidth: vertical ? -1 : slotSize
  fixedHeight: vertical ? slotSize : -1

  Item {
    id: opticalCanvas
    // Placed exactly, not anchored: centerIn snaps an even canvas in an odd slot
    // to a whole pixel, pulling every glyph off the open-panel underline.
    x: (root.width - width) / 2
    y: (root.height - height) / 2
    width: root.opticalSize
    height: root.opticalSize

    OpticalGlyph {
      id: glyph
      anchors.fill: parent
      visible: root.iconComponent === null
      text: root.text
      fontFamily: root.fontFamily
      fontSize: root.fontSize
      color: root.active && root.useActiveColor ? root.activeColor : root.foreground
      rotation: root.textRotation
      debugBounds: root.debugOpticalBounds
    }

    Loader {
      anchors.fill: parent
      visible: root.iconComponent !== null
      sourceComponent: root.iconComponent
    }

    Rectangle {
      visible: root.debugOpticalBounds && root.iconComponent !== null
      anchors.fill: parent
      color: "transparent"
      border.width: 1
      border.color: "#4488ff"
    }
  }

  Rectangle {
    visible: root.debugOpticalBounds
    anchors.fill: parent
    color: "transparent"
    border.width: 1
    border.color: "#ff4455"
  }
}
