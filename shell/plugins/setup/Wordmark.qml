import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import qs.Commons
import qs.Commons as Commons

// The Omarchy wordmark, drawn from the paths of logo.svg so it stays sharp at
// any size and takes the theme's colors. `reveal` brings the letters in one
// after another, and `glint` sweeps a band of light across them on the slant
// the wallpaper transition cuts at.
Item {
  id: root

  property color color: Commons.Color.foreground
  // Lighter than the letters whatever the theme, like the sheen on About.
  readonly property color glintColor: Qt.tint(color, Qt.rgba(1, 1, 1, 0.75))
  // From 0, no letter showing, to 1, all of them settled.
  property real reveal: 1
  // Where the glint is across the mark: 0 before it, 1 past it.
  property real glint: 0

  // logo.svg's own box, which the paths below are written in.
  readonly property real markWidth: 1215
  readonly property real markHeight: 285
  // How much of the reveal one letter takes; the rest staggers the others.
  readonly property real letterSpan: 0.46

  implicitWidth: markWidth
  implicitHeight: markHeight
  height: width * markHeight / markWidth

  // One path a letter, in reading order.
  readonly property var letters: [
    "m105 30.002h15v14.997h15v180.001h-15v15h-15v15.002h-75v-15.002h-15v-15h-15v-180.001h15v-14.997h15v-15.002h75zm-60 194.998h45v-179.998h-45z",
    "m300 15h60v15h15v14.999h15v180.001h-15v15h-15v15h-15l-.004-209.998h-44.994v-.002h-.002v210.002h-45v-210h-44.998v179.997h-.002v30.003h-15v-15.002h-15v-15h-14.998v-180.001h14.998v-14.999h15v-15h60v-15h45z",
    "m555 225h-15v15h-15v15h-15v-105.001l-44.998.001v105.002h-45.002v-105.002h-15v-30.001h15v-75h15.002v-14.997h15v-15.002h105zm-89.998-105.001h44.998v-74.997h-44.998z",
    "m720 120h-15v15h-14.998v14.999l-60.002.001v15.002l90-.002v.002h.002l-.002 89.998h-15v15h-13v15h-17v-89.998h-45v90l-45-.002v-89.998h-14.998v-30h14.998v-15.002h-14.998v-30.001h14.998v-75h15v-14.997h15v-15.002h105.002zm-90-.001h45v-74.997h-45z",
    "m885 75h-15v15h-15v15h-15v-59.998h-45v179.998h45v-59.998h15v14.997h15v15.001h15v30h-15v15h-15v15.002l-105-.002v-210.001h14.998v-14.997h15.002v-15.002h105z",
    "m960 119.999h45v-104.999h15v15h15v14.999h15v75.001h15v15h-15v90h-15v15h-15v15h-15v-105h-45v105.002l-45-.002v-105h-30v-15h15v-15.001h15v-75h15v-14.997h15v-15.002h15z",
    "m1125 119.999h45v-104.999h15v15h15v15h15v180h-15v15h-15v15.002l-75-.002v-15h-15v-15h-15v-45.001h15v-14.997-.002h30v60h45v-75h-90v-105.001h15v-14.997h15v-15.002h15z"
  ]

  // Each letter eases out on its own stretch of the reveal.
  function letterProgress(index) {
    var stagger = (1 - letterSpan) / Math.max(1, letters.length - 1)
    var local = Util.clamp((reveal - index * stagger) / letterSpan, 0, 1)
    return 1 - Math.pow(1 - local, 3)
  }

  component Letters: Item {
    id: set

    property color fill: "white"
    property bool rising: false

    Repeater {
      model: root.letters

      Shape {
        required property int index
        required property string modelData
        readonly property real progress: set.rising ? root.letterProgress(index) : 1

        width: root.markWidth
        height: root.markHeight
        scale: root.width / root.markWidth
        transformOrigin: Item.TopLeft
        opacity: progress
        preferredRendererType: Shape.CurveRenderer
        transform: Translate { y: (1 - progress) * 36 }

        ShapePath {
          fillColor: set.fill
          strokeColor: "transparent"
          PathSvg { path: modelData }
        }
      }
    }
  }

  Letters {
    anchors.fill: parent
    fill: root.color
    rising: true
  }

  // The glint is the mark again, lighter, showing only where the band is.
  Letters {
    id: lit
    anchors.fill: parent
    fill: root.glintColor
    visible: root.glint > 0 && root.glint < 1
    layer.enabled: visible
    layer.effect: MultiEffect {
      maskEnabled: true
      maskSource: band
      maskThresholdMin: 0.5
      maskSpreadAtMin: 0.35
    }
  }

  Item {
    id: band
    anchors.fill: parent
    visible: false
    layer.enabled: lit.visible

    Rectangle {
      width: parent.width * 0.16
      height: parent.height * 2
      // It runs on well past the last letter, so the slow end of an ease-out
      // is spent off the mark rather than resting on it.
      x: -width * 1.5 + (parent.width * 1.4 + width * 1.5) * root.glint
      anchors.verticalCenter: parent.verticalCenter
      // The lean of the cut the background plugin changes wallpapers with.
      rotation: 10
      color: "white"
    }
  }
}
