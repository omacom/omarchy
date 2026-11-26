import QtQuick

Canvas {
  id: drawing
  required property color ink
  required property color paper
  required property color foreground
  property int samples: 0
  property bool complete: false
  property bool contact: false
  property bool compact: false
  Accessible.ignored: true
  onInkChanged: requestPaint()
  onPaperChanged: requestPaint()
  onForegroundChanged: requestPaint()
  onSamplesChanged: requestPaint()
  onCompleteChanged: requestPaint()
  onContactChanged: requestPaint()
  onCompactChanged: requestPaint()
  // Illustrative paths. The reader only sends contact and enrollment status.
  readonly property var ridges: [
    [[18, 59], [26, 15, 92, 7, 110, 55]],
    [[15, 80], [17, 53, 30, 28, 59, 25], [82, 21, 102, 38, 108, 60], [110, 66, 111, 75, 111, 81]],
    [[20, 96], [26, 84, 20, 68, 31, 51], [46, 26, 81, 27, 95, 50], [105, 68, 99, 90, 111, 102]],
    [[26, 106], [38, 90, 27, 71, 41, 53], [55, 36, 79, 40, 89, 57], [99, 75, 89, 89, 105, 111]],
    [[33, 115], [45, 102, 38, 88, 41, 71], [44, 48, 67, 44, 79, 58], [92, 72, 79, 99, 99, 119]],
    [[42, 121], [52, 109, 47, 87, 50, 71], [52, 57, 64, 52, 74, 63], [83, 75, 69, 100, 90, 124]],
    [[54, 126], [62, 111, 54, 89, 58, 72], [60, 64, 68, 62, 69, 72], [69, 79, 65, 86, 68, 99]],
    [[62, 110], [63, 115, 63, 122, 62, 128]],
    [[71, 106], [72, 112, 76, 122, 81, 127]]
  ]
  onPaint: {
    const c = getContext("2d")
    c.reset()
    const s = Math.min(width / 150, height / 150)
    c.translate((width - 128 * s) / 2, (height - 144 * s) / 2)
    c.scale(s, s)
    c.fillStyle = Qt.alpha(ink, contact || complete ? 0.16 : 0.08)
    c.beginPath()
    c.arc(64, 74, 68, 0, Math.PI * 2)
    c.fill()
    c.lineWidth = compact ? 5.5 : 3.5
    c.lineCap = "round"
    for (let i = 0; i < ridges.length; ++i) {
      const ridge = ridges[i]
      c.strokeStyle = complete || compact || i < Math.min(samples, ridges.length - 1) ? ink : Qt.alpha(foreground, 0.35)
      c.beginPath()
      c.moveTo(ridge[0][0], ridge[0][1])
      for (let j = 1; j < ridge.length; ++j) c.bezierCurveTo(...ridge[j])
      c.stroke()
    }
    if (complete) {
      c.fillStyle = ink
      c.beginPath()
      c.arc(110, 117, 14, 0, Math.PI * 2)
      c.fill()
      c.strokeStyle = paper
      c.beginPath()
      c.moveTo(103, 117)
      c.lineTo(108, 122)
      c.lineTo(117, 111)
      c.stroke()
    }
  }
}
