import QtQuick
import Quickshell
import qs.Commons

WidgetButton {
  id: root

  property Component iconComponent: null
  // Drawn over the normalized mark and left out of its bounds: a badge, count or state mark.
  property Component badgeComponent: null
  property real slotSize: Style.bar.iconSlot
  property real opticalSize: Style.bar.iconCanvas
  property real iconSize: Math.min(Style.bar.iconSize, opticalSize)
  readonly property real visualIconSize: Style.bar.iconSize
  readonly property real canvasSize: Math.max(visualIconSize, opticalSize)
  property string labelText: ""
  property bool debugOpticalBounds: Quickshell.env("OMARCHY_DEBUG_BAR_ICONS") === "1"
  // A label shifts the icon within the centered group.
  readonly property real opticalCenterErrorX:
    content.x + opticalCanvas.x + (glyph.visible ? glyph.paintedCenterX : customIcon.width / 2 + customIcon.centerErrorX) - root.width / 2
      - (label.visible ? (label.implicitWidth + Style.space(4)) / 2 : 0)
  readonly property real opticalCenterErrorY:
    content.y + (glyph.visible ? glyph.paintedCenterY : customIcon.height / 2 + customIcon.centerErrorY) - root.height / 2
  readonly property real glyphPaintedWidth: glyph.visible ? glyph.paintedWidth : 0
  readonly property real glyphPaintedHeight: glyph.visible ? glyph.paintedHeight : 0
  readonly property real glyphBaselineY: glyph.visible ? glyph.baselineY : 0
  readonly property int glyphFontSize: glyph.visible ? glyph.renderedFontSize : 0
  readonly property real componentPaintedWidth: customIcon.visible ? customIcon.paintedWidth : 0
  readonly property real componentPaintedHeight: customIcon.visible ? customIcon.paintedHeight : 0
  readonly property rect componentSourceBounds: customIcon.sourceBounds

  labelVisible: false
  hasVisualContent: text !== "" || iconComponent !== null || labelText !== ""
  fontSize: Style.bar.iconFont
  fixedWidth: vertical ? -1 : slotSize
  fixedHeight: vertical ? slotSize : -1

  Item {
    id: content
    // Exact coordinates preserve the center of odd-width slots.
    x: (root.width - width) / 2
    y: (root.height - height) / 2
    width: root.canvasSize + (label.visible ? label.implicitWidth + Style.space(4) : 0)
    height: root.canvasSize

    Text {
      id: label
      visible: root.labelText !== ""
      textFormat: Text.PlainText
      text: root.labelText
      font.family: root.fontFamily
      font.pixelSize: root.fontSize
      color: root.active && root.useActiveColor ? root.activeColor : root.foreground
      y: (parent.height - height) / 2
        + (labelMetrics.descent - labelMetrics.ascent + labelMetrics.tightBoundingRect("0").height) / 2
      renderType: Text.NativeRendering
    }

    FontMetrics {
      id: labelMetrics
      font: label.font
    }

    Item {
      id: opticalCanvas
      x: label.visible ? label.implicitWidth + Style.space(4) : 0
      width: root.canvasSize
      height: root.canvasSize

      OpticalGlyph {
        id: glyph
        anchors.fill: parent
        visible: root.iconComponent === null
        text: root.text
        fontFamily: root.fontFamily
        fontSize: root.fontSize
        paintedSize: root.visualIconSize
        color: root.active && root.useActiveColor ? root.activeColor : root.foreground
        rotation: root.textRotation
        debugBounds: root.debugOpticalBounds
      }

      BarIconContent {
        id: customIcon
        anchors.fill: parent
        visible: root.iconComponent !== null
        sourceComponent: root.iconComponent
        sourceSize: root.opticalSize
      }

      // The painted mark's box after normalization. A badge anchors to it.
      Item {
        id: markFrame
        visible: badge.active
        // textRotation turns the glyph but not this box, so the box takes the turned mark's extent.
        readonly property real turn: glyph.visible ? root.textRotation * Math.PI / 180 : 0
        readonly property real turnCos: Math.abs(Math.cos(turn))
        readonly property real turnSin: Math.abs(Math.sin(turn))
        width: glyph.visible ? glyph.paintedWidth * turnCos + glyph.paintedHeight * turnSin : customIcon.paintedWidth
        height: glyph.visible ? glyph.paintedWidth * turnSin + glyph.paintedHeight * turnCos : customIcon.paintedHeight
        x: (glyph.visible ? glyph.paintedCenterX : customIcon.width / 2 + customIcon.centerErrorX) - width / 2
        y: (glyph.visible ? glyph.paintedCenterY : customIcon.height / 2 + customIcon.centerErrorY) - height / 2

        Loader {
          id: badge
          anchors.fill: parent
          active: root.badgeComponent !== null
          sourceComponent: root.badgeComponent
        }
      }

      Rectangle {
        visible: root.debugOpticalBounds && root.iconComponent !== null
        anchors.fill: parent
        color: "transparent"
        border.width: 1
        border.color: "#4488ff"
      }
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
