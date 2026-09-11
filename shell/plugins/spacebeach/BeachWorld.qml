import QtQuick

// A code-drawn lunar coast. No bitmap is loaded or persisted: every contour
// responds to the active Omarchy theme and the real machine telemetry handed
// in by SpaceBeach.qml.
Item {
  id: root

  property color voidColor: "#080b0d"
  property color inkColor: "#d9dedf"
  property color accentColor: "#8ccbd0"
  property color mutedColor: "#718086"
  property real tide: 0.35
  property real wind: 0.2
  property bool running: false
  property bool reduceMotion: false
  property real phase: 0

  function fract(value) {
    return value - Math.floor(value)
  }

  function random(index, salt) {
    return fract(Math.sin(index * 91.733 + salt * 17.117) * 43758.5453)
  }

  Timer {
    // Fifteen bounded ocean frames per second keep motion legible without
    // uploading the full-screen chart on every tick.
    interval: 66
    repeat: true
    running: root.running && !root.reduceMotion
    onTriggered: root.phase = (root.phase + 0.016 + Math.min(0.025, root.wind * 0.012)) % (Math.PI * 2)
  }

  Canvas {
    id: chart
    anchors.fill: parent

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    Component.onCompleted: requestPaint()

    Connections {
      target: root
      function onVoidColorChanged() { chart.requestPaint() }
      function onInkColorChanged() { chart.requestPaint() }
      function onAccentColorChanged() { chart.requestPaint() }
      function onMutedColorChanged() { chart.requestPaint() }
      function onTideChanged() { chart.requestPaint() }
    }

    onPaint: {
      var ctx = getContext("2d")
      var width = chart.width
      var height = chart.height
      if (width <= 0 || height <= 0) return

      ctx.reset()
      ctx.fillStyle = root.voidColor
      ctx.fillRect(0, 0, width, height)

      // Sparse stars, deterministically placed so the coast has a visual
      // identity without pretending to be a live astronomical map.
      for (var i = 0; i < 82; i++) {
        var sx = root.random(i, 2) * width
        var sy = root.random(i, 7) * height * 0.48
        var sr = 0.35 + root.random(i, 11) * 1.1
        var glow = 0.42 + 0.18 * Math.sin(i * 1.73)
        ctx.globalAlpha = 0.2 + glow
        ctx.fillStyle = i % 13 === 0 ? root.accentColor : root.inkColor
        ctx.beginPath()
        ctx.arc(sx, sy, sr, 0, Math.PI * 2)
        ctx.fill()
      }

      // Moon: three offset rings make a surveyor's instrument rather than a
      // decorative stock illustration.
      var moonX = width * 0.79
      var moonY = height * 0.18
      var moonR = Math.min(width, height) * 0.082
      ctx.globalAlpha = 0.08
      ctx.fillStyle = root.inkColor
      ctx.beginPath()
      ctx.arc(moonX, moonY, moonR * 1.5, 0, Math.PI * 2)
      ctx.fill()
      ctx.globalAlpha = 0.78
      ctx.fillStyle = root.inkColor
      ctx.beginPath()
      ctx.arc(moonX, moonY, moonR, 0, Math.PI * 2)
      ctx.fill()
      ctx.globalAlpha = 0.38
      ctx.strokeStyle = root.voidColor
      ctx.lineWidth = 1
      for (var ring = 1; ring <= 4; ring++) {
        ctx.beginPath()
        var ringWidth = moonR * (0.2 + ring * 0.17)
        var ringHeight = moonR * (0.11 + ring * 0.12)
        ctx.ellipse(moonX - ringWidth, moonY - ringHeight, ringWidth * 2, ringHeight * 2)
        ctx.stroke()
      }

      var horizon = height * (0.43 + Math.min(0.07, root.tide * 0.05))
      var shore = height * (0.72 - Math.min(0.1, root.tide * 0.08))

      // The sand is an isobath chart: history is literally drawn as layers.
      ctx.globalAlpha = 0.055
      ctx.fillStyle = root.inkColor
      ctx.beginPath()
      ctx.moveTo(0, shore)
      for (var bx = 0; bx <= width; bx += 14) {
        var by = shore + Math.sin(bx * 0.009 + 1.3) * 9 + Math.sin(bx * 0.027) * 3
        ctx.lineTo(bx, by)
      }
      ctx.lineTo(width, height)
      ctx.lineTo(0, height)
      ctx.closePath()
      ctx.fill()

      for (var contour = 0; contour < 9; contour++) {
        ctx.globalAlpha = 0.055 + contour * 0.008
        ctx.strokeStyle = contour === 0 ? root.accentColor : root.inkColor
        ctx.lineWidth = contour === 0 ? 1.2 : 0.65
        ctx.beginPath()
        for (var cx = -20; cx <= width + 20; cx += 14) {
          var cy = shore + 15 + contour * 23 + Math.sin(cx * 0.012 + contour * 0.56) * (8 + contour) + Math.sin(cx * 0.031 - contour) * 3
          if (cx === -20) ctx.moveTo(cx, cy)
          else ctx.lineTo(cx, cy)
        }
        ctx.stroke()
      }

      // A single cyan meridian ties the beach to the selected moment.
      ctx.globalAlpha = 0.28
      ctx.strokeStyle = root.accentColor
      ctx.lineWidth = 1
      ctx.beginPath()
      ctx.moveTo(width * 0.5, horizon - 18)
      ctx.lineTo(width * 0.5, height)
      ctx.stroke()
      ctx.globalAlpha = 1
    }
  }

  // Only the water moves. Its backing texture covers roughly two fifths of
  // the screen; the stars, moon, sand, and meridian stay cached above.
  Canvas {
    id: ocean
    x: 0
    y: root.height * 0.4
    width: root.width
    height: Math.max(1, root.height * 0.4)

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onYChanged: requestPaint()
    Component.onCompleted: requestPaint()

    Connections {
      target: root
      function onAccentColorChanged() { ocean.requestPaint() }
      function onMutedColorChanged() { ocean.requestPaint() }
      function onTideChanged() { ocean.requestPaint() }
      function onPhaseChanged() { ocean.requestPaint() }
      function onReduceMotionChanged() { ocean.requestPaint() }
    }

    onPaint: {
      var ctx = getContext("2d")
      var width = ocean.width
      var height = ocean.height
      if (width <= 0 || height <= 0) return

      ctx.reset()
      ctx.clearRect(0, 0, width, height)
      var absoluteHeight = root.height
      var horizon = absoluteHeight * (0.43 + Math.min(0.07, root.tide * 0.05)) - ocean.y
      var shore = absoluteHeight * (0.72 - Math.min(0.1, root.tide * 0.08)) - ocean.y

      ctx.globalAlpha = 0.15
      ctx.fillStyle = root.accentColor
      ctx.fillRect(0, horizon, width, Math.max(0, shore - horizon))
      for (var wave = 0; wave < 8; wave++) {
        var wy = horizon + (shore - horizon) * (wave + 1) / 9
        ctx.globalAlpha = 0.1 + wave * 0.018
        ctx.strokeStyle = wave % 3 === 0 ? root.accentColor : root.mutedColor
        ctx.lineWidth = wave % 3 === 0 ? 1.4 : 0.7
        ctx.beginPath()
        for (var x = -10; x <= width + 10; x += 12) {
          var y = wy + Math.sin(x * 0.016 + root.phase * (1 + wave * 0.04) + wave * 0.8) * (2 + wave * 0.45)
          if (x === -10) ctx.moveTo(x, y)
          else ctx.lineTo(x, y)
        }
        ctx.stroke()
      }
      ctx.globalAlpha = 1
    }
  }
}
