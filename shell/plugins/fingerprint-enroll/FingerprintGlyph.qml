import QtQuick

// A fingerprint drawn as thin concentric ridges, each split into short
// segments. `progress` (0..1) fills segments in a fixed scattered order, so
// the print appears to fill in from several directions at once rather than
// wiping from the bottom, the way Touch ID enrolment does.
Canvas {
  id: root

  property real progress: 0
  property color ridgeColor: "#555555"
  property color fillColor: "#ffffff"
  property bool scanning: false
  property int ridges: 11
  property real lineWidth: Math.max(1.5, width * 0.016)

  // animated copy of progress
  property real shown: 0
  property var segments: []
  readonly property int filledCount: Math.round(root.shown * root.segments.length)

  NumberAnimation {
    id: shownAnim
    target: root
    property: "shown"
    duration: 450
    easing.type: Easing.OutCubic
  }

  onProgressChanged: {
    shownAnim.stop()
    shownAnim.from = root.shown
    shownAnim.to = Math.max(0, Math.min(1, root.progress))
    shownAnim.start()
  }
  onShownChanged: requestPaint()
  onRidgeColorChanged: requestPaint()
  onFillColorChanged: requestPaint()
  onScanningChanged: requestPaint()
  onWidthChanged: { build(); requestPaint() }
  onHeightChanged: { build(); requestPaint() }
  Component.onCompleted: { build(); requestPaint() }

  // Build the ridge segments once per size. Each ridge is an ellipse arc
  // open at the bottom; inner ridges are nearly closed loops, outer ones
  // are arches, which is what makes the shape read as a fingertip.
  function build() {
    var W = root.width, H = root.height
    if (W <= 0 || H <= 0) return
    var segs = []
    var cx = W / 2
    var n = root.ridges
    for (var i = 0; i < n; i++) {
      var s = 0.10 + 0.90 * i / (n - 1)
      var rx = W * 0.47 * s
      var ry = H * 0.50 * s
      // the core of a print sits above the middle of the fingertip
      var cy = H * 0.50 - (1 - s) * H * 0.05
      // gaps are about one line width, so the ridges read as continuous
      // lines with a few breaks, like a real print
      var gapAngle = root.lineWidth * 1.6 / Math.max(rx, 1)
      var pieces = 3 + Math.round(i * 0.9)
      var offset = i * 0.7                       // stagger the breaks ridge to ridge
      for (var p = 0; p < pieces; p++) {
        var a0 = offset + 2 * Math.PI * p / pieces + gapAngle / 2
        var a1 = offset + 2 * Math.PI * (p + 1) / pieces - gapAngle / 2
        var pts = []
        var steps = Math.max(6, Math.ceil((a1 - a0) / 0.05))
        for (var k = 0; k <= steps; k++) {
          var t = a0 + (a1 - a0) * k / steps
          // egg shape: narrower towards the top, fuller towards the bottom
          var egg = 1 + 0.16 * Math.sin(t)
          pts.push([cx + rx * Math.cos(t) * egg, cy + ry * Math.sin(t)])
        }
        segs.push(pts)
      }
    }
    // scattered but deterministic fill order: a stride coprime with the
    // count walks the list in a pattern that looks random and never repeats
    var total = segs.length
    var stride = 37
    while (gcd(stride, total) !== 1) stride += 2
    var rank = new Array(total)
    for (var q = 0; q < total; q++) rank[(q * stride + 11) % total] = q
    for (var r = 0; r < total; r++) segs[r].rank = rank[r]
    root.segments = segs
  }

  function gcd(a, b) { return b === 0 ? a : gcd(b, a % b) }

  onPaint: {
    var ctx = getContext("2d")
    ctx.reset()
    // the bottom ridges run off the edge: the finger continues below
    ctx.beginPath()
    ctx.rect(0, 0, root.width, root.height * 0.93)
    ctx.clip()
    ctx.lineWidth = root.lineWidth
    ctx.lineCap = "round"
    ctx.lineJoin = "round"
    var segs = root.segments
    var filled = root.filledCount
    for (var pass = 0; pass < 2; pass++) {
      ctx.strokeStyle = pass === 0 ? root.ridgeColor : root.fillColor
      ctx.globalAlpha = pass === 0 ? (root.scanning ? 1.0 : 0.8) : 1.0
      for (var i = 0; i < segs.length; i++) {
        var on = segs[i].rank < filled
        if ((pass === 1) !== on) continue
        var pts = segs[i]
        ctx.beginPath()
        ctx.moveTo(pts[0][0], pts[0][1])
        for (var k = 1; k < pts.length; k++) ctx.lineTo(pts[k][0], pts[k][1])
        ctx.stroke()
      }
    }
  }
}
