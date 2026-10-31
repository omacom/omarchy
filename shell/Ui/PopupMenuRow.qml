import QtQuick
import qs.Commons
import qs.Commons as Commons

// One row of a small popup menu, like the dock's right-click menu: a label,
// a checkmark when `checked`, and `triggered()` on click. The menu owning it
// closes itself in its handler.
Rectangle {
  id: row

  property string text: ""
  property bool checked: false
  signal triggered()

  width: parent ? parent.width : 0
  height: visible ? Style.spacing.popupRowHeight : 0
  radius: Style.cornerRadius
  color: rowMouse.containsMouse ? Style.hoverFill : "transparent"

  Text {
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: Style.spacing.controlPaddingX
    textFormat: Text.PlainText
    text: row.text
    color: Commons.Color.popups.text
    font.family: Style.font.family
    font.pixelSize: Style.font.body
  }

  Text {
    visible: row.checked
    anchors.verticalCenter: parent.verticalCenter
    anchors.right: parent.right
    anchors.rightMargin: Style.spacing.controlPaddingX
    textFormat: Text.PlainText
    text: "✓"
    color: Commons.Color.accent
    font.family: Style.font.family
    font.pixelSize: Style.font.body
  }

  MouseArea {
    id: rowMouse
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: row.triggered()
  }
}
