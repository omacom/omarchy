import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// The card's own buttons. `primary` is where a screen leads: filled in the
// text color, so it leads even in a theme whose accent is quieter than its
// text, where a tinted button reads as switched off.
BorderSurface {
  id: root

  property string text: ""
  property bool primary: false
  // A plain line of text until it is pointed at.
  property bool quiet: false
  // The keyboard is on it.
  property bool hasCursor: false

  property color foreground: Commons.Color.menu.text
  property color surface: Commons.Color.menu.background

  signal clicked()
  signal entered()

  readonly property bool hot: pointer.containsMouse || hasCursor

  implicitWidth: label.implicitWidth + Style.space(quiet ? 14 : 34)
  implicitHeight: label.implicitHeight + Style.space(quiet ? 8 : 15)
  radius: Style.cornerRadius
  color: primary ? Util.alpha(foreground, hot ? 1 : 0.88)
    : hot ? Style.hoverFillFor(foreground, foreground)
    : "transparent"
  borderSpec: primary || quiet ? Border.none() : Border.flat(Util.alpha(foreground, hot ? 0.7 : 0.32), Style.spacing.hairline)

  Behavior on color { ColorAnimation { duration: Style.duration(120) } }

  // Held down, it gives a little, as a Button does.
  scale: pointer.pressed ? 0.97 : 1
  Behavior on scale {
    NumberAnimation {
      duration: Style.duration(160)
      easing.type: Easing.Bezier
      easing.bezierCurve: Style.easeOut
    }
  }

  // Where Enter will land.
  Rectangle {
    visible: root.hasCursor
    anchors.fill: parent
    anchors.margins: -Style.space(3)
    radius: root.radius > 0 ? root.radius + Style.space(3) : 0
    color: "transparent"
    border.width: Style.spacing.hairline
    border.color: Util.alpha(root.foreground, 0.7)
  }

  Text {
    id: label
    textFormat: Text.PlainText
    text: root.text
    color: root.primary ? root.surface : root.quiet && !root.hot ? Util.alpha(root.foreground, 0.66) : root.foreground
    font.family: Style.font.menuFamily
    font.pixelSize: root.quiet ? Style.font.bodySmall : Style.font.body
    font.bold: root.primary
    anchors.centerIn: parent
  }

  MouseArea {
    id: pointer
    anchors.fill: parent
    // Undoes the press scale, so a press near the edge still counts.
    scale: 1 / root.scale
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onEntered: root.entered()
    onClicked: root.clicked()
  }
}
