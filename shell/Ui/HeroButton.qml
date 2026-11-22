import QtQuick
import qs.Commons
import qs.Commons as Commons

// The square in a panel hero's corner, such as the agents panel's +: grey
// until hovered or reached by the keyboard, then the accent. The keyboard
// cursor needs more than a shade deeper to read on it.
Rectangle {
  id: heroButton
  signal clicked()
  signal hovered()
  property string glyph: ""
  property string tooltip: ""
  property bool hasCursor: false
  property string fontFamily: Style.font.family
  readonly property bool hot: heroMouse.containsMouse || hasCursor
  readonly property color grey: Qt.darker(Commons.Color.foreground, 1.55)

  implicitWidth: Style.space(34)
  implicitHeight: implicitWidth
  radius: Style.cornerRadius
  color: hot ? Util.alpha(Commons.Color.accent, hasCursor ? 0.3 : 0.12) : Util.alpha(grey, 0.12)
  Behavior on color { ColorAnimation { duration: Style.duration(60) } }
  border.width: hasCursor ? Math.max(1, Style.hoverBorderWidth) : 0
  border.color: Commons.Color.accent

  Text {
    anchors.centerIn: parent
    textFormat: Text.PlainText
    text: heroButton.glyph
    color: heroButton.hot ? Commons.Color.accent : heroButton.grey
    font.family: heroButton.fontFamily
    font.pixelSize: Style.font.heading
  }

  MouseArea {
    id: heroMouse
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onEntered: heroButton.hovered()
    onClicked: heroButton.clicked()
  }

  PanelToolTip {
    visible: heroMouse.containsMouse
    text: heroButton.tooltip
  }
}
