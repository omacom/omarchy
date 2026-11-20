import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// Four rising signal bars drawn as rounded rectangles, so the mark scales
// with the bar's icon size and takes the theme's colors instead of a font
// glyph. Unlit bars stay faintly drawn: the icon keeps one silhouette, and so
// one painted size and center, whatever the signal.
Item {
  id: root

  property real iconSize: Style.bar.iconSize
  property color color: Commons.Color.foreground
  property color badgeColor: color
  property int level: 0
  property int levelCount: 4
  property bool crossed: false
  property string badge: ""

  width: iconSize
  height: iconSize
  implicitWidth: iconSize
  implicitHeight: iconSize

  readonly property real barWidth: Math.max(1, iconSize * 0.19)
  readonly property real barGap: (iconSize - barWidth * levelCount) / Math.max(1, levelCount - 1)

  Repeater {
    model: root.levelCount

    Rectangle {
      required property int index
      readonly property real fraction: (index + 1) / root.levelCount

      x: index * (root.barWidth + root.barGap)
      y: root.iconSize - height
      width: root.barWidth
      height: Math.max(root.barWidth, root.iconSize * fraction)
      radius: Math.min(width / 2, Math.max(1, root.iconSize * 0.08))
      color: root.color
      opacity: index < root.level ? 1.0 : 0.28

      Behavior on opacity {
        NumberAnimation { duration: Style.duration(160); easing.type: Easing.OutCubic }
      }
    }
  }

  // Corner to corner, short enough to stay inside the icon's box so a crossed
  // icon paints at the same size as a lit one.
  Rectangle {
    visible: root.crossed
    anchors.centerIn: parent
    width: root.iconSize * 1.25
    height: Math.max(1, root.iconSize * 0.14)
    radius: height / 2
    color: root.color
    rotation: -45
  }

  // Roaming or attention marker in the empty corner above the short bars.
  Text {
    visible: root.badge !== ""
    textFormat: Text.PlainText
    x: 0
    y: 0
    text: root.badge
    color: root.badgeColor
    font.family: Style.font.family
    font.pixelSize: Math.max(6, root.iconSize * 0.5)
    font.bold: true
  }
}
