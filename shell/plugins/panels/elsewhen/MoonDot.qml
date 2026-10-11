import QtQuick
import qs.Commons
import qs.Commons as Commons
import "GlobeModel.js" as Solar

// The night marker drawn as the moon's current phase. The faint full disc
// keeps it findable at new moon; the lit part is filled solid on top.
Item {
  id: root

  property real phase: 0            // 0 new, 0.25 first quarter, 0.5 full
  property color color: Commons.Color.foreground

  onPhaseChanged: canvas.requestPaint()
  onColorChanged: canvas.requestPaint()

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

      // The whole disc, faint.
      ctx.beginPath()
      ctx.arc(0, 0, r, 0, Math.PI * 2)
      ctx.fillStyle = Util.alpha(c, 0.22)
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
