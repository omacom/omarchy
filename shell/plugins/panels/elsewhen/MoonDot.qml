import QtQuick
import qs.Commons
import "GlobeModel.js" as Solar

// The night marker on a row's daylight strip, drawn as the moon's current
// phase rather than a plain dot.
//
// The whole disc is always drawn, faintly, so the marker never disappears at
// new moon and never stops being findable on the strip; the lit part is then
// filled solid on top. So the phase reads as a bite taken out of the dot,
// which is the point - it is the same marker carrying one more fact, not an
// extra thing on the row.
Item {
  id: root

  property real phase: 0            // 0 new, 0.25 first quarter, 0.5 full
  property color color: Color.foreground
  // The unlit part is painted in the card's own colour, so the bite reads as
  // absence rather than as a second grey shape.
  property color shadowColor: Color.popups.background

  onPhaseChanged: canvas.requestPaint()
  onColorChanged: canvas.requestPaint()
  onShadowColorChanged: canvas.requestPaint()

  Canvas {
    id: canvas
    anchors.fill: parent
    renderStrategy: Canvas.Cooperative

    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      var r = Math.min(width, height) / 2
      if (r <= 0) return
      ctx.translate(width / 2, height / 2)
      var c = root.color

      // The whole disc, faint: the moon is still there when it is new.
      ctx.beginPath()
      ctx.arc(0, 0, r, 0, Math.PI * 2)
      ctx.fillStyle = Qt.rgba(c.r, c.g, c.b, 0.22)
      ctx.fill()

      // The lit part, solid.
      var lit = Solar.moonLitOutline(root.phase, r, 28)
      if (lit.length > 2) {
        ctx.beginPath()
        ctx.moveTo(lit[0].x, lit[0].y)
        for (var i = 1; i < lit.length; i++) ctx.lineTo(lit[i].x, lit[i].y)
        ctx.closePath()
        ctx.fillStyle = c
        ctx.fill()
      }
    }
  }
}
