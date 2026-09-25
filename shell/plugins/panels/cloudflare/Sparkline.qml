import QtQuick
import qs.Commons

// A small line chart with a soft fill underneath, for a metric's recent
// history. Scales to its own max, so the shape reads even when values are
// small; an all-zero series draws as a flat baseline. With no values yet it
// draws a faint baseline, holding the chart's place while it loads.
Canvas {
  id: root

  property var values: []
  property color color: Color.foreground
  property real lineWidth: 1.25
  property real fillOpacity: 0.16

  implicitHeight: Style.space(24)
  antialiasing: true

  onValuesChanged: requestPaint()
  onColorChanged: requestPaint()
  onWidthChanged: requestPaint()
  onHeightChanged: requestPaint()

  onPaint: {
    var ctx = getContext("2d")
    ctx.reset()
    var points = Array.isArray(values) ? values : []
    if (width <= 0 || height <= 0) return
    if (points.length === 0) {
      ctx.beginPath()
      ctx.moveTo(0, height - lineWidth)
      ctx.lineTo(width, height - lineWidth)
      ctx.lineWidth = lineWidth
      ctx.strokeStyle = Qt.rgba(root.color.r, root.color.g, root.color.b, 0.25)
      ctx.stroke()
      return
    }

    var max = 0
    for (var i = 0; i < points.length; i++) max = Math.max(max, Number(points[i]) || 0)
    var top = lineWidth
    var bottom = height - lineWidth
    var step = points.length > 1 ? width / (points.length - 1) : 0

    function yFor(value) {
      return max > 0 ? bottom - (Number(value) || 0) / max * (bottom - top) : bottom
    }

    ctx.beginPath()
    ctx.moveTo(0, yFor(points[0]))
    for (var j = 1; j < points.length; j++) ctx.lineTo(j * step, yFor(points[j]))
    if (points.length === 1) ctx.lineTo(width, yFor(points[0]))

    ctx.lineWidth = lineWidth
    ctx.lineJoin = "round"
    ctx.strokeStyle = root.color
    ctx.stroke()

    ctx.lineTo(width, height)
    ctx.lineTo(0, height)
    ctx.closePath()
    ctx.fillStyle = Qt.rgba(root.color.r, root.color.g, root.color.b, fillOpacity)
    ctx.fill()
  }
}
