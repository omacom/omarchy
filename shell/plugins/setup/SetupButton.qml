import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// Welcome's buttons. Primary buttons indicate keyboard focus with a subtle
// label underline instead of a boxy double border, and hover stays visual
// without moving keyboard focus.
BorderSurface {
  id: root

  property string text: ""
  property bool primary: false
  property bool quiet: false
  property bool hasCursor: false

  property color foreground: Commons.Color.menu.text
  property color surface: Commons.Color.menu.background
  property color accent: Commons.Color.accent

  signal clicked()

  readonly property bool hot: pointer.containsMouse || hasCursor

  implicitWidth: label.implicitWidth + Style.space(quiet ? 16 : 34)
  implicitHeight: label.implicitHeight + Style.space(quiet ? 10 : 16)
  radius: Style.cornerRadius
  color: primary ? Util.alpha(foreground, hot ? 1 : 0.88)
    : hot ? Style.hoverFillFor(foreground, accent)
    : "transparent"
  borderSpec: primary ? Border.none()
    : quiet ? (hasCursor ? Border.flat(Util.alpha(foreground, 0.5), Style.spacing.hairline) : Border.none())
    : Border.flat(Util.alpha(foreground, hasCursor ? 0.72 : hot ? 0.5 : 0.28), Style.spacing.hairline)

  Accessible.role: Accessible.Button
  Accessible.name: root.text
  Accessible.onPressAction: root.clicked()

  Behavior on color { ColorAnimation { duration: Style.duration(120) } }

  scale: pointer.pressed ? 0.97 : 1
  Behavior on scale {
    NumberAnimation {
      duration: Style.duration(160)
      easing.type: Easing.Bezier
      easing.bezierCurve: Style.easeOut
    }
  }

  Text {
    id: label
    textFormat: Text.PlainText
    text: root.text
    color: root.primary ? root.surface
      : root.quiet && !root.hot ? Util.alpha(root.foreground, 0.62)
      : root.foreground
    font.family: Style.font.menuFamily
    font.pixelSize: root.quiet ? Style.font.bodySmall : Style.font.body
    font.bold: root.primary
    anchors.centerIn: parent
  }

  // Crisp focus bar beneath the label on primary buttons so keyboard focus
  // reads cleanly on both sharp and rounded themes without a double-box look.
  Rectangle {
    visible: root.primary && root.hasCursor
    width: label.implicitWidth
    height: Math.max(1, Style.space(1.5))
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: label.bottom
    anchors.topMargin: Style.space(2)
    color: Util.alpha(root.surface, 0.55)
  }

  MouseArea {
    id: pointer
    anchors.fill: parent
    scale: 1 / root.scale
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
