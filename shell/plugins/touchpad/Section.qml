import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// A titled card of setting rows. Rows are separated by hairlines.
ColumnLayout {
  id: root

  property string title: ""
  property string subtitle: ""
  property color foreground: Commons.Color.foreground
  default property alias rows: body.data

  Layout.fillWidth: true
  spacing: Style.spacing.md

  PanelSectionHeader {
    visible: root.title !== ""
    text: root.title.toUpperCase()
    foreground: root.foreground
    font.letterSpacing: 1
  }

  Text {
    visible: root.subtitle !== ""
    textFormat: Text.PlainText
    text: root.subtitle
    color: Qt.darker(root.foreground, 1.5)
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
    wrapMode: Text.WordWrap
    Layout.fillWidth: true
  }

  BorderSurface {
    Layout.fillWidth: true
    implicitHeight: body.implicitHeight + Style.spacing.sm * 2
    color: Util.alpha(root.foreground, 0.035)
    radius: Style.cornerRadius
    borderSpec: Border.flat(Util.alpha(root.foreground, 0.10), 1)

    ColumnLayout {
      id: body
      x: Style.spacing.rowPaddingX + Style.spacing.xs
      y: Style.spacing.sm
      width: parent.width - x * 2
      spacing: 0
    }
  }
}
