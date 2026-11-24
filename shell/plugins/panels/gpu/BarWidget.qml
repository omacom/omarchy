import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.gpu"

  readonly property var gpuService: bar?.shell?.firstPartyServiceFor("omarchy.gpu")
  readonly property string label: gpuService ? gpuService.label : ""

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
      visible: !(root.bar && root.bar.vertical)
    }
  }

  TapHandler {
    onTapped: {
      if (root.bar) root.bar.run("omarchy-launch-floating-terminal-with-presentation 'nvtop || btop'")
    }
  }
}
