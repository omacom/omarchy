import QtQuick

// Theme and size are supplied by the native bar. This component only paints.
Item {
  id: root
  property real fraction: 0
  property bool known: false
  property bool stale: false
  property color foreground: "white"
  property color trackColor: "gray"
  property color ringColor: foreground
  property color attentionColor: ringColor
  property string glyph: ""
  property string fontFamily: "monospace"
  property real glyphSize: width * 0.45
  property string activity: "unknown"

  onFractionChanged: canvas.requestPaint()
  onKnownChanged: canvas.requestPaint()
  onStaleChanged: canvas.requestPaint()
  onTrackColorChanged: canvas.requestPaint()
  onRingColorChanged: canvas.requestPaint()

  Canvas {
    id: canvas
    anchors.fill: parent
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      var line = Math.max(1.5, width / 12)
      var radius = Math.max(0, Math.min(width, height) / 2 - line)
      ctx.lineWidth = line
      ctx.strokeStyle = root.trackColor
      ctx.beginPath()
      ctx.arc(width / 2, height / 2, radius, 0, Math.PI * 2)
      ctx.stroke()
      if (root.known) {
        ctx.globalAlpha = root.stale ? 0.4 : 1
        ctx.strokeStyle = root.ringColor
        ctx.lineCap = "round"
        ctx.beginPath()
        ctx.arc(width / 2, height / 2, radius, -Math.PI / 2,
          -Math.PI / 2 + Math.PI * 2 * Math.max(0, Math.min(1, root.fraction)))
        ctx.stroke()
      }
    }
  }

  Text {
    anchors.centerIn: parent
    textFormat: Text.PlainText
    text: root.glyph
    font.family: root.fontFamily
    font.pixelSize: root.glyphSize
    color: root.foreground
    opacity: root.stale ? 0.55 : 1
  }

  Rectangle {
    visible: root.activity === "waiting" || root.activity === "working"
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    width: Math.max(5, parent.width / 4)
    height: width
    radius: width / 2
    color: root.activity === "waiting" ? root.attentionColor : root.ringColor
    // A hollow dot means working; a filled dot means input is needed.
    Rectangle {
      visible: root.activity === "working"
      anchors.centerIn: parent
      width: parent.width / 2
      height: width
      radius: width / 2
      color: root.trackColor
    }
  }
}
