import QtQuick
import QtQuick.Shapes
import qs.Commons
import qs.Commons as Commons

// The Omarchy wordmark, drawn from the paths of logo.svg and styled with
// omarchy.org's 5-band stepped vertical gradient snapped to the exact 19 pixel
// rows of the mark (5/19, 7/19, 11/19, 14/19, 19/19). `reveal` brings the
// letters in one after another, and `glint` sweeps a diagonal sheen across.
Item {
  id: root

  property color color: Commons.Color.menu.text
  property color accent: Commons.Color.accent
  property color surface: Commons.Color.menu.background
  property real reveal: 1
  property real glint: 0

  readonly property real markWidth: 1215
  readonly property real markHeight: 285
  readonly property real letterSpan: 0.46

  // Derive omarchy.org's 5 stepped band tones from the active desktop theme,
  // inverting smoothly on light themes just as omarchy.org does for Latte.
  function luma(c) {
    return 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
  }
  function mix(a, b, t) {
    return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, 1)
  }
  function chroma(c) {
    return Math.max(c.r, c.g, c.b) - Math.min(c.r, c.g, c.b)
  }

  readonly property bool lightTheme: luma(surface) > 0.5
  readonly property bool monoAccent: chroma(accent) < 0.06
  // On monochrome themes (Solitude, Vantablack), step gracefully from a bright
  // silver crest through slate down to deep charcoal, matching omarchy.org.
  readonly property color baseLit: monoAccent ? mix(color, surface, lightTheme ? 0.14 : 0.24) : accent
  readonly property color bandCrest: lightTheme ? mix(baseLit, Qt.rgba(0, 0, 0, 1), 0.38)
    : mix(baseLit, Qt.rgba(1, 1, 1, 1), monoAccent ? 0.44 : 0.54)
  readonly property color bandHover: lightTheme ? mix(baseLit, Qt.rgba(0, 0, 0, 1), 0.16)
    : mix(baseLit, Qt.rgba(1, 1, 1, 1), monoAccent ? 0.2 : 0.28)
  readonly property color bandLit: baseLit
  readonly property color bandMid: mix(baseLit, surface, lightTheme ? 0.28 : 0.34)
  readonly property color bandDim: mix(baseLit, surface, lightTheme ? 0.48 : 0.52)
  readonly property color glintPeak: lightTheme ? Qt.rgba(1, 1, 1, 0.52) : Util.alpha(bandCrest, 0.5)
  readonly property color glintClear: Qt.rgba(glintPeak.r, glintPeak.g, glintPeak.b, 0)

  implicitWidth: markWidth
  implicitHeight: markHeight
  height: width * markHeight / markWidth

  readonly property var letters: [
    "m105 30.002h15v14.997h15v180.001h-15v15h-15v15.002h-75v-15.002h-15v-15h-15v-180.001h15v-14.997h15v-15.002h75zm-60 194.998h45v-179.998h-45z",
    "m300 15h60v15h15v14.999h15v180.001h-15v15h-15v15h-15l-.004-209.998h-44.994v-.002h-.002v210.002h-45v-210h-44.998v179.997h-.002v30.003h-15v-15.002h-15v-15h-14.998v-180.001h14.998v-14.999h15v-15h60v-15h45z",
    "m555 225h-15v15h-15v15h-15v-105.001l-44.998.001v105.002h-45.002v-105.002h-15v-30.001h15v-75h15.002v-14.997h15v-15.002h105zm-89.998-105.001h44.998v-74.997h-44.998z",
    "m720 120h-15v15h-14.998v14.999l-60.002.001v15.002l90-.002v.002h.002l-.002 89.998h-15v15h-13v15h-17v-89.998h-45v90l-45-.002v-89.998h-14.998v-30h14.998v-15.002h-14.998v-30.001h14.998v-75h15v-14.997h15v-15.002h105.002zm-90-.001h45v-74.997h-45z",
    "m885 75h-15v15h-15v15h-15v-59.998h-45v179.998h45v-59.998h15v14.997h15v15.001h15v30h-15v15h-15v15.002l-105-.002v-210.001h14.998v-14.997h15.002v-15.002h105z",
    "m960 119.999h45v-104.999h15v15h15v14.999h15v75.001h15v15h-15v90h-15v15h-15v15h-15v-105h-45v105.002l-45-.002v-105h-30v-15h15v-15.001h15v-75h15v-14.997h15v-15.002h15z",
    "m1125 119.999h45v-104.999h15v15h15v15h15v180h-15v15h-15v15.002l-75-.002v-15h-15v-15h-15v-45.001h15v-14.997-.002h30v60h45v-75h-90v-105.001h15v-14.997h15v-15.002h15z"
  ]

  function letterProgress(index) {
    var stagger = (1 - letterSpan) / Math.max(1, letters.length - 1)
    var local = Util.clamp((reveal - index * stagger) / letterSpan, 0, 1)
    return 1 - Math.pow(1 - local, 3)
  }

  // Banded letters (omarchy.org 19-row stepped gradient)
  Item {
    anchors.fill: parent

    Repeater {
      model: root.letters

      Shape {
        required property int index
        required property string modelData
        readonly property real progress: root.letterProgress(index)

        width: root.markWidth
        height: root.markHeight
        scale: root.width / root.markWidth
        transformOrigin: Item.TopLeft
        opacity: progress
        preferredRendererType: Shape.CurveRenderer
        transform: Translate { y: (1 - progress) * 28 }

        ShapePath {
          strokeColor: "transparent"
          fillGradient: LinearGradient {
            x1: 0; y1: 0
            x2: 0; y2: root.markHeight
            GradientStop { position: 0.0;     color: root.bandCrest }
            GradientStop { position: 0.26315; color: root.bandCrest }
            GradientStop { position: 0.26316; color: root.bandHover }
            GradientStop { position: 0.36841; color: root.bandHover }
            GradientStop { position: 0.36842; color: root.bandLit }
            GradientStop { position: 0.57894; color: root.bandLit }
            GradientStop { position: 0.57895; color: root.bandMid }
            GradientStop { position: 0.73683; color: root.bandMid }
            GradientStop { position: 0.73684; color: root.bandDim }
            GradientStop { position: 1.0;     color: root.bandDim }
          }
          PathSvg { path: modelData }
        }
      }
    }
  }

  // Diagonal glint drawn directly as a sweeping vector LinearGradient inside
  // the letter paths — avoids offscreen MultiEffect layer flashes on frame 1.
  Item {
    id: sheen
    anchors.fill: parent
    visible: root.glint > 0 && root.glint < 1
    readonly property real centerX: -280 + (root.markWidth + 560) * root.glint

    Repeater {
      model: root.letters

      Shape {
        required property string modelData

        width: root.markWidth
        height: root.markHeight
        scale: root.width / root.markWidth
        transformOrigin: Item.TopLeft
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
          strokeColor: "transparent"
          fillGradient: LinearGradient {
            x1: sheen.centerX - 165
            y1: 0
            x2: sheen.centerX + 165
            y2: root.markHeight * 0.85
            GradientStop { position: 0.0;  color: root.glintClear }
            GradientStop { position: 0.34; color: root.glintClear }
            GradientStop { position: 0.5;  color: root.glintPeak }
            GradientStop { position: 0.66; color: root.glintClear }
            GradientStop { position: 1.0;  color: root.glintClear }
          }
          PathSvg { path: modelData }
        }
      }
    }
  }
}
