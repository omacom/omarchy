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
  readonly property Path header: Path {
    PathSvg {
      path: `M23 72 C25 64 24 56 26 48
             M28 40 C35 21 50 11 66 11 C89 11 104 34 105 58 C106 79 99 99 87 112
             M25 89 C27 81 32 75 33 67 C33 56 32 49 37 39 C43 27 53 20 66 20 C84 19 94 36 94 53
             M94 61 C95 79 89 99 79 109 C71 118 61 122 51 120
             M31 96 C31 88 38 81 41 73 C44 64 40 55 44 46 C48 35 56 29 65 29 C78 28 85 40 85 54 C86 71 81 91 72 102 C63 113 47 116 37 107
             M41 76 C44 83 38 88 41 94 C43 102 51 105 58 101 C69 95 73 79 75 65
             M76 58 C77 46 72 38 64 38 C54 38 50 48 51 59 C52 71 47 80 44 86
             M60 65 C60 73 57 82 54 88 C52 93 56 93 59 88 C66 77 67 66 66 55`
    }
  }

  component Impression: Path {
    required property string outline
    required property point from
    required property point to
    PathSvg { path: outline }
  }

  // An original loop print in ten overlapping areas. Each path contains the
  // fragments that take ink together when a touch is accepted.
  readonly property list<Impression> impressions: [
    // Core
    Impression {
      from: Qt.point(61, 100)
      to: Qt.point(61, 35)
      outline: `M60 65.5 C59 72 59 77 56.5 83 C55.5 85.5 53.5 88.5 54 90.5 C54.5 90.5 54.5 91 55 91 C55.5 91 56 91 56.5 90.5 C57.5 90 58 89 58.5 88 C65.5 78 66 66.5 66 55
                M63.5 43.5 C58.5 44.5 56.5 48 55.5 52 C54.5 56.5 55.5 62.5 55.5 67.5 C55 76.5 51 84 46 91.5
                M69 74.5 C70 69 71 62.5 71 56.5 C71 50.5 70 44.5 63.5 43
                M75.5 62.5 C75.5 59 75.5 56 75.5 52.5
                M63.5 38.5 C56.5 40 51.5 46.5 50.5 53.5
                M75.5 52.5 C75.5 46 71.5 37 63.5 38.5
                M51 98 C61.5 98 66 86.5 68 78.5`
    },
    // Right shoulder
    Impression {
      from: Qt.point(62, 20)
      to: Qt.point(84, 91)
      outline: `M50 73.5 C49 79.5 44.5 84 42 89.5
                M75.5 86 C78.5 76 80.5 66 80 55.5
                M81 30 C79 28 77 26.5 74.5 25.5
                M91 86.5 C93 77.5 94 68.5 94 59.5`
    },
    // Lower loop
    Impression {
      from: Qt.point(91, 56)
      to: Qt.point(60, 107)
      outline: `M71.5 83 C73.5 76.5 75 69.5 75.5 62.5
                M66 108.5 C73 104.5 77 97 79 90
                M85.5 86.5 C88 77 89.5 67.5 89.5 58
                M48 102 C59 106 67.5 96.5 70 87`
    },
    // Upper arch
    Impression {
      from: Qt.point(26, 67)
      to: Qt.point(82, 42)
      outline: `M64.5 33.5 C60 34 56 36.5 53 40
                M79 45.5 C78 38.5 71.5 32 64 33.5
                M42.5 49.5 C39.5 58.5 45.5 68.5 39 77
                M80.5 86 C83.5 75 85 64 84.5 52.5
                M28.5 55 C28 59.5 28 63.5 29 68`
    },
    // Left shoulder
    Impression {
      from: Qt.point(59, 122)
      to: Qt.point(59, 20)
      outline: `M47 50 C43.5 58.5 51 65.5 50 73.5
                M64 29 C59.5 29.5 55.5 32 52.5 34.5
                M83.5 44.5 C82.5 35.5 73.5 26.5 64 29
                M52.5 29.5 C47 33.5 42.5 39 40 45.5
                M74 108 C80 102.5 83 94.5 85.5 86.5
                M33.5 51 C31 57.5 34 64 33 70.5
                M41.5 22 C33.5 29.5 28 39.5 25.5 50
                M81.5 120 C92 112 98 99.5 101 87`
    },
    // Heel
    Impression {
      from: Qt.point(23, 47)
      to: Qt.point(95, 101)
      outline: `M50.5 53.5 C51 59 52 64 50.5 69.5
                M42 89.5 C38 94.5 42 101.5 48 102
                M48.5 106.5 C62.5 111 73 98 75 86
                M52.5 34.5 C48 38.5 44.5 44 42.5 49.5
                M38.5 49.5 C35 56.5 39 64 37 71
                M30 84.5 C28.5 88.5 28 93.5 27.5 98
                M35 109 C38 111 41 112.5 44 113.5
                M89.5 58 C89 49.5 88.5 40 83.5 33
                M46.5 23.5 C37 31.5 30.5 43 28.5 55
                M82 113.5 C89.5 106 94 95.5 96.5 85
                M24.5 54 C24 57 24 60.5 24 64
                M104.5 58.5 C103.5 44.5 99.5 30.5 90 20`
    },
    // Flanks
    Impression {
      from: Qt.point(103, 109)
      to: Qt.point(37, 22)
      outline: `M46 91.5 C44.5 94.5 47.5 98.5 51 98
                M50.5 43 C49 45 47.5 47.5 47 50
                M37 80.5 C33.5 85.5 30.5 93.5 33 100 C35 105 41 109 47.5 110
                M84.5 52.5 C84.5 50 84 47 83.5 44.5
                M64.5 24.5 C60.5 25 56.5 27 52.5 29.5
                M74.5 25.5 C71.5 24 68 24 64.5 24.5
                M48.5 27.5 C41 33.5 36 42 33.5 51
                M78.5 110 C85 103.5 88.5 95 91 86.5
                M99 58.5 C98.5 44.5 95 29.5 84 20.5
                M64.5 10.5 C55.5 11.5 48 16 41.5 22
                M101 87 C103 79 104.5 70.5 104.5 62.5
                M95.5 112 C99.5 106 102.5 99.5 104.5 93`
    },
    // Outer arches
    Impression {
      from: Qt.point(42, 23)
      to: Qt.point(92, 100)
      outline: `M43 79 C40 82.5 37 88 36.5 93.5 C36 98.5 38 103.5 45.5 105.5
                M80 55.5 C80 53.5 80 51.5 79.5 49.5
                M37 71 C35.5 75.5 31.5 79.5 30.5 84.5
                M44 113.5 C52.5 117 63 116.5 70.5 110.5
                M94 59.5 C95.5 51.5 90.5 45 86.5 39
                M87.5 31 C86 28.5 84.5 26.5 82 25
                M65.5 15 C58.5 16 52 19 46.5 23.5
                M96.5 85 C98 78 99 70 99.5 62.5
                M84 20.5 C79 16.5 72 14.5 65.5 15
                M24 64 C24 66 23.5 68 23.5 69
                M109 56 C108.5 53 108.5 49.5 107.5 46
                M90 20 C87 17 83.5 14 79.5 12.5`
    },
    // Crown
    Impression {
      from: Qt.point(28, 57)
      to: Qt.point(109, 84)
      outline: `M47 110.5 C53.5 112.5 60.5 112 66 108.5
                M65.5 19.5 C60.5 20 55.5 22.5 51.5 25
                M79 22.5 C75 20 70 19 65.5 19.5
                M26.5 71.5 C25.5 74 25 75.5 24.5 77
                M70.5 121.5 C74.5 119.5 78.5 116.5 82 113.5
                M105.5 89 C108.5 78.5 110 67 109 56`
    },
    // Remaining edge ridges
    Impression {
      from: Qt.point(53, 75)
      to: Qt.point(40, 118)
      outline: `M32.5 70.5 C30 75.5 28 79.5 27 83.5
                M52.5 120 C61 121 69.5 118 75.5 112.5`
    }
  ]

  // Readers can report many more stages than they eventually need. Leave the
  // last ridges for completion while continuing to show progress on long runs.
  readonly property real targetCoverage: {
    if (compact || complete) return 1
    if (samples <= 7) return samples / impressions.length
    const extra = samples - 7
    return (7 + 2.8 * extra / (extra + 4)) / impressions.length
  }
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
    if (compact) {
      c.lineWidth = 3.15
      c.path = header
      c.strokeStyle = ink
      c.stroke()
    } else {
      c.lineWidth = 2.15
      const quiet = paper.hslLightness < 0.5 && samples > 0 ? 0.24 : 0.38
      c.strokeStyle = Qt.tint(paper, Qt.alpha(foreground, quiet))
      for (const impression of impressions) {
        c.path = impression
        c.stroke()
      }

      for (let i = 0; i < impressions.length; ++i) {
        const amount = coverage * impressions.length - i
        if (amount <= 0) break
        const impression = impressions[i]
        if (amount >= 1) {
          c.strokeStyle = ink
        } else {
          // A soft leading edge reveals only this group of ridge fragments.
          // The geometry stays fixed, including the antialiasing at the tips.
          const dx = impression.to.x - impression.from.x
          const dy = impression.to.y - impression.from.y
          const lead = amount * 1.25 - 0.25
          const x = impression.from.x + lead * dx
          const y = impression.from.y + lead * dy
          const brush = c.createLinearGradient(x, y, x + dx / 4, y + dy / 4)
          brush.addColorStop(0, ink)
          brush.addColorStop(1, Qt.alpha(ink, 0))
          c.strokeStyle = brush
        }
        c.path = impression
        c.stroke()
      }
    }
    c.restore()
  }
}
