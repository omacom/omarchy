import QtQuick

// This is an illustration. fprintd supplies contact and accepted scans, never a print image.
Canvas {
  id: drawing
  required property color ink
  required property color paper
  required property color foreground
  property bool compact: false
  property bool contact: false
  property bool complete: false
  property int samples: 0
  Accessible.ignored: true

  onInkChanged: requestPaint()
  onPaperChanged: requestPaint()
  onForegroundChanged: requestPaint()
  onCompactChanged: requestPaint()
  onContactChanged: requestPaint()
  onCompleteChanged: requestPaint()
  onSamplesChanged: requestPaint()

  onPaint: {
    const c = getContext("2d")
    c.reset()
    const scale = Math.min(width, height) / 132
    if (scale <= 0) return
    c.save()
    c.translate((width - 132 * scale) / 2, (height - 132 * scale) / 2)
    c.scale(scale, scale)

    if (!compact) {
      // The four corners mark the sensor area. Contact changes their weight.
      c.strokeStyle = complete || contact ? ink : Qt.tint(paper, Qt.alpha(foreground, 0.42))
      c.lineWidth = contact ? 2 : 1
      for (const x of [4, 128]) {
        for (const y of [4, 128]) {
          const dx = x < 66 ? 1 : -1
          const dy = y < 66 ? 1 : -1
          c.beginPath()
          c.moveTo(x + dx * 10, y)
          c.lineTo(x, y)
          c.lineTo(x, y + dy * 10)
          c.stroke()
        }
      }
    }

    c.translate(66, 66)
    c.rotate(0.22)
    // Print-shaped clipping lets the outer ridges enter and leave at the fingertip.
    c.beginPath()
    c.moveTo(-2, -54)
    c.bezierCurveTo(26, -56, 42, -35, 44, -4)
    c.bezierCurveTo(47, 28, 31, 52, 6, 55)
    c.bezierCurveTo(-20, 59, -42, 42, -44, 13)
    c.bezierCurveTo(-47, -20, -33, -51, -2, -54)
    c.clip()

    c.lineCap = "round"
    c.lineJoin = "round"
    c.lineWidth = compact ? 1.95 : 1.6
    const quiet = Qt.tint(paper, Qt.alpha(foreground, 0.58))
    // Contact lights the sensor corners. Accepted scans ink successive ridges;
    // only the reader's completion event inks the entire illustration.
    const acceptedRidges = Math.min(2 * samples, 12)
    const turn = 2 * Math.PI
    const pitch = compact ? 5.6 : 4.1
    // One off-centre whorl. The small breaks represent creases in an illustrative
    // ink impression; nothing in this geometry is derived from a person's finger.
    for (let ridge = 0; ridge * pitch < 72; ++ridge) {
      c.strokeStyle = compact || complete || ridge < acceptedRidges ? ink : quiet
      c.beginPath()
      let move = true
      for (let step = 0; step <= 64; ++step) {
        const t = step / 64
        const angle = turn * t
        const r = 1.2 + pitch * (ridge + t)
        const sin = Math.sin(angle)
        const cos = Math.cos(angle)
        const x = -4 + r * (cos * (0.76 + 0.24 * sin) + 0.20 * sin)
        const y = -9 + r * (sin * (1.02 - 0.11 * cos) + 0.13) + 0.0036 * r * r * Math.max(0, sin)
        if ((ridge === 4 && step > 38 && step < 43) ||
            (ridge === 8 && step > 10 && step < 13) ||
            (ridge === 11 && step > 54 && step < 56)) {
          move = true
          continue
        }
        if (move) c.moveTo(x, y)
        else c.lineTo(x, y)
        move = false
      }
      c.stroke()
    }
    c.restore()
  }
}
