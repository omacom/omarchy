import QtQuick
import qs.Commons
import qs.Commons as Commons

// One row of a small popup menu, like the dock's right-click menu: a label,
// a checkmark when `checked`, and `triggered()` on click. The menu owning it
// closes itself in its handler. `highlighted` lights it as hover does, for a
// menu walked with the keyboard. A row that opens more choices in place of
// the menu is marked `submenu`, and the row leading back from them `back`.
Rectangle {
  id: row

  property string text: ""
  property bool checked: false
  property bool highlighted: false
  property bool submenu: false
  property bool back: false
  signal triggered()

  width: parent ? parent.width : 0
  height: visible ? Style.spacing.popupRowHeight : 0
  radius: Style.cornerRadius
  color: rowMouse.containsMouse || highlighted ? Style.hoverFill : "transparent"

  Text {
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: Style.spacing.controlPaddingX
    textFormat: Text.PlainText
    text: row.back ? (Commons.I18n.rightToLeft ? "› " : "‹ ") + row.text : row.text
    color: Commons.Color.popups.text
    font.family: Style.font.family
    font.pixelSize: Style.font.body
  }

  Text {
    visible: row.checked || row.submenu
    anchors.verticalCenter: parent.verticalCenter
    anchors.right: parent.right
    anchors.rightMargin: Style.spacing.controlPaddingX
    textFormat: Text.PlainText
    text: row.submenu ? (Commons.I18n.rightToLeft ? "‹" : "›") : "✓"
    color: row.submenu ? Commons.Color.popups.text : Commons.Color.accent
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
