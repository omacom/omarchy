import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Ui

// Rex's pages, down the left edge.
Rectangle {
  id: root

  property color foreground
  property color accent
  // [{ id, icon, label }]
  property var pages: []
  property string current: ""

  signal picked(string page)

  implicitWidth: Style.space(52)
  color: Util.alpha(foreground, 0.03)

  Rectangle {
    anchors.right: parent.right
    width: 1
    height: parent.height
    color: Util.alpha(root.foreground, 0.08)
  }

  ColumnLayout {
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.topMargin: Style.spacing.panelPadding
    spacing: Style.spacing.md

    Repeater {
      model: root.pages

      Button {
        required property var modelData
        Layout.alignment: Qt.AlignHCenter
        iconText: modelData.icon
        iconSize: Style.font.iconLarge
        tooltipText: modelData.label
        selected: root.current === modelData.id
        onClicked: root.picked(modelData.id)
      }
    }
  }
}
