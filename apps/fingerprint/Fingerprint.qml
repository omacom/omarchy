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
  // This original loop is shared by the small badge and the enrollment guide.
  readonly property Path ridges: Path {
    PathSvg {
      path: `M113.5 71.5 C105.5 74.5 99 78.5 91.5 82.5 C83.5 86.5 74.5 90.5 66 87 C62 85 58.5 82 57.5 78.5 C56.5 74.5 58.5 70 60.5 66 C63 62.5 65 59 65.5 54.5 C66 52 65.5 49 64 47 C63 45.5 61 44.5 60 45.5 C58.5 46 58.5 48 59 50.5 C59 53 59.5 55.5 59.5 57.5 C59 61.5 56 65.5 54.5 69.5 C52.5 73.5 52 78.5 54.5 82.5 C56 86 59.5 89 63 90.5 C72 93.5 81 89.5 90 86.5 C98 83.5 105.5 81 113.5 77.5
             M112.5 61.5 C105 64 98 68 90.5 71.5 C87 73.5 83 75 78.5 76 C76.5 77 74 77.5 72 77.5 C69.5 77.5 67.5 76.5 67 74.5 C66.5 73.5 67.5 71.5 68.5 69.5 C69.5 67.5 70.5 65.5 71.5 64 C73.5 60 74.5 56 74.5 51 C74.5 46.5 74 41.5 71 38 C68.5 35 64 34 60 35 C56.5 36.5 53.5 40 51.5 43 C50 45 49.5 46.5 49 48.5 C49 51 49.5 53 50 55.5 C50 57 50 58.5 49.5 60.5 C49 62 48 64 47 66 C45 70 44 75 44.5 79.5 C45 87.5 50 95 57 99 C66.5 104 80 102.5 85.5 92
             M93 96.5 C100 94 106.5 91 113.5 88
             M110 53 C104.5 54 99.5 58 93.5 59 C90.5 60 87.5 59.5 85.5 58 C84 56 83.5 52.5 83.5 49.5 C83 43 82 37.5 79 32.5 C76 27.5 70.5 24 65 25
             M61 25.5 C55.5 27.5 50 31 46 36 C42 41 40.5 47.5 40 54 C40 55.5 40 57.5 39.5 59 C39.5 60.5 39.5 62 39 63.5 C38 66.5 37 70 36 73 C35 80 36 87 39 93.5 C41.5 99 45.5 104.5 50.5 107.5 C56 111 63.5 112.5 70.5 112 C84 111.5 96.5 106.5 108.5 101
             M108 44.5 C104.5 46.5 99 47 95.5 45 C92.5 43.5 92 39.5 90.5 35.5 C88 28.5 84 21.5 78 17.5 C71 13.5 61.5 14.5 54 18 C47.5 21.5 42.5 26.5 38.5 32.5 C34 39 30.5 46.5 30 54 C30 56.5 30 58.5 29.5 61 C29.5 63 29 64.5 28.5 66.5 C27 70.5 26.5 75 26.5 79.5 C26.5 95 35 110.5 47.5 119
             M56 122 C69.5 123.5 83 121.5 95.5 117.5
             M104 34.5 C97.5 32 96.5 24.5 93 20
             M47 11 C38.5 18 30 27 25.5 37 C23 43 21.5 49 20.5 55.5 C20 59 19.5 62.5 19 65.5 C18.5 69 17.5 72 16.5 75`
    }
    // Leave space between ridges in the small header mark.
    PathSvg {
      path: drawing.compact ? "" : `M113.5 66 C105.5 69.5 97.5 73.5 89.5 77.5 C85.5 79.5 81.5 82 77 82.5 C72 83.5 66.5 82.5 63.5 79.5 C62.5 77.5 62 75.5 62.5 73 C62.5 71 64 69 65 67 C67.5 63 69.5 59 70 54.5 C70.5 49.5 70 43.5 66 41 C64 39.5 61.5 39.5 59.5 40.5 C57.5 41 56 42.5 55 44.5 C54 47 54 49.5 54.5 52 C54.5 54 55 56.5 54.5 58.5 C54.5 60.5 53.5 62.5 52 64.5 C51 66.5 50 68.5 49.5 70.5 C48 75.5 48 80.5 50.5 85 C52.5 89 55.5 92.5 59.5 94.5 C68 99 78.5 96 88 92.5 C97 89.5 105 86.5 114 82.5
             M111.5 57 C107 58.5 102.5 61 98.5 62.5 C94 64.5 89.5 66.5 84.5 67.5 C83.5 68 82 68 80.5 68.5 C79 69 78 69.5 77 69 C75.5 69 76.5 66 77 63.5 C78.5 58 79 53 78.5 47 C78.5 42 77 36.5 73.5 33.5 C70.5 30 65 29.5 60.5 30.5 C51.5 33 44.5 43 44.5 52 C45 54.5 45.5 57 45 59 C44.5 61.5 43.5 63.5 43 65.5 C40.5 70.5 39.5 76 40 81.5 C41 90.5 47 99.5 54.5 103.5 C63.5 108.5 75 107 85 104.5 C94.5 102 102.5 98.5 111.5 94
             M109 48.5 C106.5 49.5 104.5 50 102.5 51 C100 52 97.5 53 95 53 C92.5 52.5 90.5 51 89 49 C88 47.5 88 45 87.5 42.5 C86 34 81 24 73.5 21 C65 18 54.5 22 47.5 28.5 C44.5 31 42.5 34.5 40 38 C38.5 40 37.5 42.5 37.5 45 C37.5 48 40 51.5 39.5 54.5
             M35.5 60.5 C26 77 32 101.5 47.5 112 C51 114.5 55.5 116 60 117 C65.5 118 71.5 117.5 77 117 C86.5 115.5 96 112 104 109
             M106.5 40 C101 42 97.5 38.5 95 34.5 C93 30.5 92 26 89.5 22.5 C85 14.5 75.5 10 67 10 C49.5 9.5 34 27.5 28.5 42
             M26.5 46 C26 51 25.5 56 24.5 61 C24 65.5 22.5 70 22 74.5 C21 83.5 23 93.5 27 101.5`
    }
  }

  // Each accepted sample grows the impression. Readers can finish at different counts.
  readonly property real targetCoverage: compact || complete ? 1 : 0.88 * samples / (samples + 2)
  property real coverage: targetCoverage
  Behavior on coverage {
    enabled: !drawing.compact && (drawing.complete || drawing.samples > 0)
    NumberAnimation { duration: 190; easing.type: Easing.OutCubic }
  }
  Accessible.ignored: true

  onInkChanged: requestPaint()
  onPaperChanged: requestPaint()
  onForegroundChanged: requestPaint()
  onCompactChanged: requestPaint()
  onContactChanged: requestPaint()
  onCompleteChanged: requestPaint()
  onCoverageChanged: requestPaint()

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

    c.lineCap = "round"
    c.lineJoin = "round"
    c.lineWidth = compact ? 3.15 : 2.15
    c.path = ridges
    const quiet = paper.hslLightness < 0.5 && samples > 0 ? 0.30 : 0.38
    c.strokeStyle = compact ? ink : Qt.tint(paper, Qt.alpha(foreground, quiet))
    c.stroke()

    if (!compact && coverage > 0) {
      if (coverage < 1) {
        // Grow a single patch from the core. Its shoulder and heel arrive later.
        // Each direction only expands, even when the reader needs many touches.
        c.beginPath()
        for (let i = 0; i < 64; ++i) {
          const angle = i * 2 * Math.PI / 64
          const shoulder = Math.max(0, Math.cos(angle + 0.85))
          const heel = Math.max(0, Math.cos(angle - 1.9))
          const delay = 0.4 * shoulder * shoulder + 0.27 * heel * heel
          const reach = 0.55 * Math.sqrt(coverage)
                      + 0.45 * Math.sqrt(Math.max(0, coverage - delay) / (1 - delay))
          const x = 60 + 58 * reach * Math.cos(angle)
          const y = 67 + 66 * reach * Math.sin(angle)
          if (i === 0) c.moveTo(x, y)
          else c.lineTo(x, y)
        }
        c.closePath()
        c.clip()
      }
      c.path = ridges
      c.strokeStyle = ink
      c.stroke()
    }
    c.restore()
  }
}
