import QtQuick
import qs.Commons
import qs.Commons as Commons

// Living architectural pixel field aligned to the wordmark's 81-column pixel
// grid, inspired by omarchy.org's hero. A gentle diagonal aurora wave cascades
// cells through the 5 theme bands, subtle pixel gliders drift along grid tracks,
// and pointer movement leaves a soft luminous wake.
Canvas {
  id: root

  property real cellSize: Style.space(6)
  property real originX: 0
  property real originY: 0
  property color dimColor: Util.alpha(Commons.Color.accent, 0.45)
  property color midColor: Util.alpha(Commons.Color.accent, 0.65)
  property color litColor: Util.alpha(Commons.Color.accent, 0.88)
  property color hoverColor: Commons.Color.menu.text
  property real pointerX: -1000
  property real pointerY: -1000
  property bool pointerInside: false
  property real phase: 0

  // Short decaying pointer trail for a living hover wake across the grid.
  property var trail: []

  LayoutMirroring.enabled: false

  function pushTrail(px, py) {
    if (Style.reduceMotion) return
    var next = trail.slice(0, 7)
    next.unshift({ x: px, y: py })
    trail = next
  }

  // Deterministic constellation & small architectural clusters (x, y, offset, tier)
  // framing the card perimeter while keeping the central wordmark/CTA zone calm.
  readonly property var seeds: [
    // Top-left structured cluster & stepped accents
    [0.03, 0.06, 0.1, 1], [0.05, 0.06, 0.3, 2], [0.07, 0.09, 1.3, 2], [0.09, 0.05, 2.5, 0],
    [0.12, 0.11, 0.8, 1], [0.14, 0.11, 1.0, 2], [0.16, 0.07, 3.1, 0], [0.19, 0.13, 1.9, 2],
    [0.23, 0.08, 4.2, 1], [0.27, 0.12, 2.8, 0], [0.04, 0.15, 4.9, 1], [0.06, 0.18, 0.6, 2],
    [0.10, 0.19, 1.4, 1], [0.14, 0.22, 3.7, 0], [0.03, 0.25, 2.1, 1], [0.08, 0.29, 4.4, 0],
    // Upper horizon wave band (above wordmark)
    [0.31, 0.06, 1.1, 1], [0.35, 0.10, 3.5, 0], [0.39, 0.07, 5.0, 2], [0.41, 0.07, 5.2, 1],
    [0.45, 0.11, 0.4, 1], [0.49, 0.06, 2.9, 2], [0.53, 0.10, 4.1, 0], [0.57, 0.07, 4.4, 2],
    [0.61, 0.11, 1.7, 1], [0.65, 0.06, 3.3, 1], [0.69, 0.10, 0.9, 0],
    // Top-right structured cluster & stepped accents
    [0.73, 0.12, 3.2, 0], [0.77, 0.08, 0.9, 1], [0.81, 0.13, 4.6, 2], [0.83, 0.13, 4.8, 1],
    [0.86, 0.07, 2.3, 1], [0.89, 0.11, 5.4, 0], [0.92, 0.06, 1.5, 2], [0.95, 0.09, 3.8, 1],
    [0.95, 0.11, 4.0, 2], [0.88, 0.18, 0.5, 1], [0.93, 0.17, 4.1, 0], [0.96, 0.23, 2.7, 1],
    [0.91, 0.27, 1.0, 2], [0.94, 0.31, 3.4, 0],
    // Left & right living flank columns
    [0.03, 0.37, 2.2, 0], [0.06, 0.42, 3.4, 2], [0.04, 0.49, 1.2, 1], [0.08, 0.54, 4.0, 0],
    [0.05, 0.61, 4.8, 1], [0.07, 0.61, 5.0, 2], [0.09, 0.69, 2.0, 2], [0.04, 0.74, 0.7, 1],
    [0.96, 0.38, 0.7, 1], [0.93, 0.45, 3.9, 2], [0.95, 0.52, 1.8, 0], [0.91, 0.59, 4.5, 1],
    [0.95, 0.65, 2.6, 2], [0.92, 0.72, 5.1, 1], [0.96, 0.77, 1.3, 0],
    // Bottom-left & bottom-right framing corners
    [0.04, 0.82, 2.4, 1], [0.08, 0.87, 0.3, 2], [0.10, 0.87, 0.5, 1], [0.13, 0.83, 4.3, 0],
    [0.17, 0.90, 1.6, 2], [0.21, 0.86, 3.6, 1], [0.26, 0.91, 2.0, 0], [0.11, 0.93, 5.2, 1],
    [0.05, 0.92, 1.1, 0],
    [0.74, 0.90, 3.0, 0], [0.79, 0.87, 1.4, 1], [0.83, 0.91, 4.5, 2], [0.87, 0.84, 2.2, 2],
    [0.89, 0.84, 2.4, 1], [0.92, 0.88, 0.9, 1], [0.95, 0.82, 3.3, 0], [0.90, 0.93, 5.6, 1],
    [0.95, 0.92, 4.2, 2]
  ]

  // Quiet horizontal pixel gliders drifting along grid tracks in the top/bottom margins.
  readonly property var gliders: [
    { y: 0.09, start: 0.08, span: 0.42, speed: 1, offset: 0.0, dir: 1 },
    { y: 0.14, start: 0.52, span: 0.40, speed: 1, offset: 0.55, dir: -1 },
    { y: 0.88, start: 0.06, span: 0.24, speed: 1, offset: 0.28, dir: 1 },
    { y: 0.89, start: 0.70, span: 0.24, speed: 1, offset: 0.78, dir: -1 }
  ]

  NumberAnimation on phase {
    from: 0
    to: Math.PI * 2
    duration: Style.duration(10400)
    loops: Animation.Infinite
    running: root.visible && !Style.reduceMotion
  }

  onPhaseChanged: requestPaint()
  onDimColorChanged: requestPaint()
  onMidColorChanged: requestPaint()
  onLitColorChanged: requestPaint()
  onHoverColorChanged: requestPaint()
  onPointerXChanged: if (pointerInside) { pushTrail(pointerX, pointerY); requestPaint() }
  onPointerYChanged: if (pointerInside) { pushTrail(pointerX, pointerY); requestPaint() }
  onPointerInsideChanged: { if (!pointerInside) trail = []; requestPaint() }
  onWidthChanged: requestPaint()
  onHeightChanged: requestPaint()

  onPaint: {
    var ctx = getContext("2d")
    ctx.clearRect(0, 0, width, height)
    if (width <= 0 || height <= 0) return

    var step = Math.max(4, Math.round(cellSize))
    var size = Math.max(3, step - 1)
    var ox = originX % step
    var oy = originY % step

    // Keep the central wordmark, copy, and buttons clean and effortless to read.
    var quietLeft = width * 0.13
    var quietRight = width * 0.87
    var quietTop = height * 0.20
    var quietBottom = height * 0.83

    // 1. Subtle breathing elliptical aura behind the OMARCHY wordmark,
    // strictly inside the card bounds so alpha reaches 0 before any edge.
    var breath = Style.reduceMotion ? 0.6 : 0.5 + 0.5 * Math.sin(phase * 2)
    var auraRx = width * 0.42
    var auraRy = height * 0.36
    ctx.save()
    ctx.translate(width * 0.5, height * 0.42)
    ctx.scale(1, auraRy / auraRx)
    var aura = ctx.createRadialGradient(0, 0, step * 2, 0, 0, auraRx)
    aura.addColorStop(0.0, Util.alpha(litColor, 0.075 + 0.045 * breath).toString())
    aura.addColorStop(0.55, Util.alpha(midColor, 0.025 + 0.015 * breath).toString())
    aura.addColorStop(1.0, Util.alpha(dimColor, 0).toString())
    ctx.fillStyle = aura
    ctx.beginPath()
    ctx.arc(0, 0, auraRx, 0, Math.PI * 2)
    ctx.fill()
    ctx.restore()

    // 2. Ultra-subtle grid lattice dots around the outer frame for architectural texture.
    ctx.fillStyle = dimColor.toString()
    ctx.globalAlpha = 0.09
    var latticeStep = step * 4
    for (var lx = ox + latticeStep; lx < width - 6; lx += latticeStep) {
      for (var ly = oy + latticeStep; ly < height - 6; ly += latticeStep) {
        if (lx > quietLeft && lx < quietRight && ly > quietTop && ly < quietBottom) continue
        ctx.fillRect(Math.round(lx), Math.round(ly), 1, 1)
      }
    }

    // 3. Living pixel constellation with diagonal aurora wave + pointer wake.
    for (var i = 0; i < seeds.length; i++) {
      var s = seeds[i]
      var rawX = s[0] * width
      var rawY = s[1] * height
      var gx = ox + Math.round((rawX - ox) / step) * step
      var gy = oy + Math.round((rawY - oy) / step) * step

      if (gx < 4 || gx + size > width - 4 || gy < 4 || gy + size > height - 4) continue
      if (gx + size > quietLeft && gx < quietRight && gy + size > quietTop && gy < quietBottom) continue

      // Diagonal wave sweeping across the field + individual shimmer.
      var diag = (s[0] * 3.4 + s[1] * 2.2) * Math.PI
      var aurora = Style.reduceMotion ? 0.65 : 0.5 + 0.5 * Math.sin(phase - diag)
      var shimmer = Style.reduceMotion ? 0.72 : 0.45 + 0.55 * Math.sin(phase * 2 + s[2])
      var energy = 0.58 * aurora + 0.42 * shimmer

      // Pointer proximity + soft fading trail wake.
      var near = 0
      if (pointerInside) {
        var dx = gx + size / 2 - pointerX
        var dy = gy + size / 2 - pointerY
        var dist = Math.sqrt(dx * dx + dy * dy)
        var radius = step * 14
        if (dist < radius) near = 1 - dist / radius
        for (var tr = 1; tr < trail.length; tr++) {
          var tdx = gx + size / 2 - trail[tr].x
          var tdy = gy + size / 2 - trail[tr].y
          var tdist = Math.sqrt(tdx * tdx + tdy * tdy)
          var tradius = step * 10
          if (tdist < tradius) {
            var wake = (1 - tdist / tradius) * (1 - tr / trail.length) * 0.75
            if (wake > near) near = wake
          }
        }
      }

      var tier = s[3]
      if (near > 0.25) {
        ctx.fillStyle = hoverColor.toString()
        ctx.globalAlpha = 0.32 + 0.62 * near
      } else if (tier === 2 || energy > 0.78) {
        ctx.fillStyle = energy > 0.84 ? hoverColor.toString() : litColor.toString()
        ctx.globalAlpha = 0.34 + 0.52 * energy
      } else if (tier === 1) {
        ctx.fillStyle = midColor.toString()
        ctx.globalAlpha = 0.3 + 0.44 * energy
      } else {
        ctx.fillStyle = dimColor.toString()
        ctx.globalAlpha = 0.26 + 0.34 * energy
      }
      ctx.fillRect(Math.round(gx), Math.round(gy), size, size)
    }

    // 4. Subtle 3-pixel gliders drifting quietly along grid tracks in top/bottom horizons.
    if (!Style.reduceMotion) {
      var norm = phase / (Math.PI * 2)
      for (var g = 0; g < gliders.length; g++) {
        var gl = gliders[g]
        var prog = (norm * gl.speed + gl.offset) % 1
        var envelope = Math.sin(Math.PI * prog)
        if (envelope < 0.05) continue
        var pos = gl.dir > 0 ? gl.start + prog * gl.span : gl.start + (1 - prog) * gl.span
        var headX = ox + Math.round((pos * width - ox) / step) * step
        var headY = oy + Math.round((gl.y * height - oy) / step) * step

        for (var seg = 0; seg < 3; seg++) {
          var sx = headX - gl.dir * seg * step
          if (sx < 4 || sx + size > width - 4) continue
          ctx.fillStyle = seg === 0 ? hoverColor.toString() : seg === 1 ? litColor.toString() : midColor.toString()
          ctx.globalAlpha = envelope * (seg === 0 ? 0.75 : seg === 1 ? 0.46 : 0.22)
          ctx.fillRect(Math.round(sx), Math.round(headY), size, size)
        }
      }
    }

    ctx.globalAlpha = 1
  }
}
