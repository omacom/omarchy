import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.gpu"

  readonly property var gpu: root.bar && root.bar.shell ? root.bar.shell.serviceFor("omarchy.gpu") : null
  readonly property string label: gpu && gpu.label ? gpu.label : ""
  readonly property bool iconOnly: root.bar && root.bar.vertical

  visible: label !== ""
  implicitWidth: visible ? row.implicitWidth + Style.space(10) : 0
  implicitHeight: barSize

  Row {
    id: row
    anchors.centerIn: parent
    spacing: Style.space(4)
    visible: root.label !== ""

    Text {
      text: "\uf2db"
      textFormat: Text.PlainText
      font.family: root.bar ? root.bar.fontFamily : ""
      font.pixelSize: Style.font.body
      color: root.bar ? root.bar.barForeground : "white"
      anchors.verticalCenter: parent.verticalCenter
    }

    Text {
      text: root.label
      textFormat: Text.PlainText
      font.family: root.bar ? root.bar.fontFamily : ""
      font.pixelSize: Style.font.body
      color: root.bar ? root.bar.barForeground : "white"
      anchors.verticalCenter: parent.verticalCenter
      visible: !root.iconOnly
    }
  }

  TapHandler {
    onTapped: {
      if (root.bar) root.bar.run("omarchy-launch-floating-terminal-with-presentation 'nvtop || btop'")
    }
  }
}
