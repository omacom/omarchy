import QtQuick
import qs.Commons
import qs.Commons as Commons

Item {
  id: root

  property string text: ""
  property string fontFamily: Style.font.family
  property real fontSize: Style.font.body
  property real paintedSize: 0
  property color color: Commons.Color.foreground
  property bool debugBounds: false

  readonly property int renderedFontSize: Math.max(1, Math.round(fontSize))
  // Tight bounds come back in whole pixels, which at bar sizes adds up to a
  // pixel of ink that isn't there and shifts the glyph's center. Measuring a
  // hundred times larger keeps them to the outline.
  readonly property int metricsScale: 100
  readonly property rect ink: Qt.rect(glyphMetrics.tightBoundingRect.x / metricsScale,
    glyphMetrics.tightBoundingRect.y / metricsScale,
    glyphMetrics.tightBoundingRect.width / metricsScale,
    glyphMetrics.tightBoundingRect.height / metricsScale)
  readonly property real tightWidth: Math.max(1, root.ink.width)
  readonly property real tightHeight: Math.max(1, root.ink.height)
  readonly property real paintedScale: paintedSize > 0
    ? Math.min(paintedSize, width, height) / Math.max(tightWidth, tightHeight)
    : 1
  readonly property real paintedWidth: tightWidth * paintedScale
  readonly property real paintedHeight: tightHeight * paintedScale
  readonly property real horizontalCorrection: glyph.implicitWidth / 2 - (root.ink.x + tightWidth / 2)
  readonly property real paintedCenterX: glyph.x + (root.ink.x + tightWidth / 2) * paintedScale
  readonly property real paintedCenterY: glyph.y + (glyph.baselineOffset + root.ink.y + tightHeight / 2) * paintedScale
  readonly property real baselineY: glyph.y + glyph.baselineOffset * paintedScale

  TextMetrics {
    id: glyphMetrics
    font.family: root.fontFamily
    font.pixelSize: root.renderedFontSize * root.metricsScale
    text: root.text
  }

  Text {
    id: glyph
    textFormat: Text.PlainText
    // Bar icons fit their painted bounds. Text labels retain their line box.
    x: root.width / 2 - (root.ink.x + root.tightWidth / 2) * root.paintedScale
    y: root.paintedSize > 0
      ? root.height / 2 - (baselineOffset + root.ink.y + root.tightHeight / 2) * root.paintedScale
      : Math.round((root.height - height) / 2)
    text: root.text
    color: root.color
    font.family: root.fontFamily
    font.pixelSize: root.renderedFontSize
    transformOrigin: Item.TopLeft
    scale: root.paintedScale
    // Scaled icons use distance fields: at bar sizes the curve renderer's
    // antialiasing overshoots where a corner meets a straight edge, so the
    // flat top of a rounded square steps up at its ends.
    renderType: root.paintedSize > 0 ? Text.QtRendering : Text.NativeRendering
  }

  Rectangle {
    visible: root.debugBounds
    anchors.fill: parent
    color: "transparent"
    border.width: 1
    border.color: "#4488ff"
  }

  Rectangle {
    visible: root.debugBounds
    x: 0
    y: Math.round(root.baselineY)
    width: parent.width
    height: 1
    color: "#44ff88"
  }
}
