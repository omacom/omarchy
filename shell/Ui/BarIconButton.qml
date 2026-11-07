import QtQuick
import Quickshell
import qs.Commons

WidgetButton {
  id: root

  property Component iconComponent: null
  // Composite widgets can retain their source geometry instead of fitting one icon.
  property bool normalizeIconComponent: true
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
  readonly property bool naturalComponent: iconComponent !== null && !normalizeIconComponent
  readonly property real componentCanvasWidth: naturalComponent ? Math.max(canvasSize, customIcon.paintedWidth) : canvasSize
  readonly property real componentCanvasHeight: naturalComponent ? Math.max(canvasSize, customIcon.paintedHeight) : canvasSize

  labelVisible: false
  hasVisualContent: text !== "" || iconComponent !== null || labelText !== ""
  fontSize: Style.bar.iconFont
  fixedWidth: vertical ? -1 : (naturalComponent ? Math.max(slotSize, content.width + scaledHorizontalMargin * 2) : slotSize)
  fixedHeight: vertical ? (naturalComponent ? Math.max(slotSize, content.height + scaledVerticalPadding * 2) : slotSize) : -1

  Item {
    id: content
    // Exact coordinates preserve the center of odd-width slots.
    x: (root.width - width) / 2
    y: (root.height - height) / 2
    // The icon draws here rather than in WidgetButton's own label, so it takes
    // the press scale here too.
    scale: root.pressScale
    width: root.componentCanvasWidth + (label.visible ? label.implicitWidth + Style.space(4) : 0)
    height: root.componentCanvasHeight

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
      width: root.componentCanvasWidth
      height: root.componentCanvasHeight

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
        normalize: root.normalizeIconComponent
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
