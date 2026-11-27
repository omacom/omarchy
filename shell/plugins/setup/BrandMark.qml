import QtQuick
import qs.Commons
import qs.Commons as Commons

// The Omarchy labyrinth emblem from omarchy.org, wearing the exact same 5-band
// stepped vertical gradient derived from the active desktop theme. Drawn with
// pixel-snapped Canvas rectangles so strokes stay razor-sharp at 22-40px across
// Qt 6.10+.
Canvas {
  id: root

  property color foreground: Commons.Color.menu.text
  property color accent: Commons.Color.accent
  property color surface: Commons.Color.menu.background

  function luma(c) { return 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b }
  function mix(a, b, t) {
    return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, 1)
  }
  function chroma(c) { return Math.max(c.r, c.g, c.b) - Math.min(c.r, c.g, c.b) }

  readonly property bool lightTheme: luma(surface) > 0.5
  readonly property bool monoAccent: chroma(accent) < 0.06
  readonly property color baseLit: monoAccent ? mix(foreground, surface, lightTheme ? 0.14 : 0.24) : accent
  readonly property color bandCrest: lightTheme ? mix(baseLit, Qt.rgba(0, 0, 0, 1), 0.38)
    : mix(baseLit, Qt.rgba(1, 1, 1, 1), monoAccent ? 0.44 : 0.54)
  readonly property color bandHover: lightTheme ? mix(baseLit, Qt.rgba(0, 0, 0, 1), 0.16)
    : mix(baseLit, Qt.rgba(1, 1, 1, 1), monoAccent ? 0.2 : 0.28)
  readonly property color bandLit: baseLit
  readonly property color bandMid: mix(baseLit, surface, lightTheme ? 0.26 : 0.3)
  readonly property color bandDim: mix(baseLit, surface, lightTheme ? 0.44 : 0.46)

  implicitWidth: Style.space(22)
  implicitHeight: Style.space(22)
  LayoutMirroring.enabled: false

  onBandCrestChanged: requestPaint()
  onBandLitChanged: requestPaint()
  onBandDimChanged: requestPaint()
  onWidthChanged: requestPaint()
  onHeightChanged: requestPaint()

  onPaint: {
    var ctx = getContext("2d")
    ctx.clearRect(0, 0, width, height)
    var dim = Math.floor(Math.min(width, height))
    if (dim <= 0) return

    var ox = Math.floor((width - dim) / 2)
    var oy = Math.floor((height - dim) / 2)
    var t = Math.max(2, Math.round(dim * 0.085))
    var inner = Math.max(t * 2, Math.round(dim * 0.19))
    var mid = Math.round((dim - t) / 2)
    var outerEnd = dim - t
    var innerEnd = dim - inner - t

    var grad = ctx.createLinearGradient(0, oy, 0, oy + dim)
    grad.addColorStop(0.0, bandCrest.toString())
    grad.addColorStop(0.26315, bandCrest.toString())
    grad.addColorStop(0.26316, bandHover.toString())
    grad.addColorStop(0.36841, bandHover.toString())
    grad.addColorStop(0.36842, bandLit.toString())
    grad.addColorStop(0.57894, bandLit.toString())
    grad.addColorStop(0.57895, bandMid.toString())
    grad.addColorStop(0.73683, bandMid.toString())
    grad.addColorStop(0.73684, bandDim.toString())
    grad.addColorStop(1.0, bandDim.toString())

    ctx.fillStyle = grad

    function bar(x, y, w, h) {
      if (w > 0 && h > 0) ctx.fillRect(ox + x, oy + y, w, h)
    }

    // Outer labyrinth frame with bottom-right entry gap
    var bottomGapStart = mid + t
    var bottomGapEnd = Math.min(outerEnd, bottomGapStart + Math.max(2, Math.round(dim * 0.1)))
    bar(0, 0, dim, t)                                    // top
    bar(0, 0, t, dim)                                    // left
    bar(outerEnd, 0, t, dim)                             // right
    bar(0, outerEnd, bottomGapStart, t)                  // bottom-left
    bar(bottomGapEnd, outerEnd, dim - bottomGapEnd, t)   // bottom-right

    // Cardinal connectors
    bar(mid, 0, t, inner + t)                            // top tick down
    bar(mid, innerEnd, t, dim - innerEnd)                // bottom tick up
    bar(0, mid, inner + t, t)                            // left tick right

    // Inner labyrinth frame with upper-right opening
    var topGapStart = mid + t
    var topGapEnd = Math.max(topGapStart + Math.max(2, Math.round(dim * 0.18)), innerEnd - t)
    bar(inner, inner, topGapStart - inner, t)            // inner top-left
    bar(topGapEnd, inner, innerEnd + t - topGapEnd, t)   // inner top-right
    bar(inner, inner, t, innerEnd + t - inner)           // inner left
    bar(inner, innerEnd, innerEnd + t - inner, t)        // inner bottom
    bar(innerEnd, inner, t, innerEnd + t - inner)        // inner right
  }
}
