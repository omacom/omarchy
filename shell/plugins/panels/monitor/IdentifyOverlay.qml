import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons

// Stateless visual overlay; it never changes display settings or takes input.
Item {
  id: root
  property var displays: []
  property string targetName: ""
  visible: false
  function show(name) { targetName = name || ""; visible = true; identifyTimer.restart() }
  function displayNumber(name) {
    for (var i = 0; i < displays.length; i++) if (displays[i].name === name) return String(i + 1)
    return ""
  }
  function displayName(name) {
    for (var i = 0; i < displays.length; i++) if (displays[i].name === name) return displays[i].model || name
    return name
  }
  Timer {
    id: identifyTimer
    interval: root.targetName === "" ? 4000 : 2000
    onTriggered: root.visible = false
  }

  Variants {
    model: root.visible ? Quickshell.screens : []
    delegate: PanelWindow {
      id: identityWindow
      required property var modelData
      screen: modelData
      visible: root.visible && root.displayNumber(modelData.name) !== ""
        && (root.targetName === "" || root.targetName === modelData.name)
      implicitWidth: Math.min(Style.space(270), modelData.width - 40)
      implicitHeight: Style.space(230)
      color: "transparent"
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.namespace: "omarchy-display-identify"
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      mask: Region {}

      Rectangle {
        anchors.fill: parent
        radius: Style.space(16)
        color: Color.background
        border.color: Color.accent
        border.width: 3
        Column {
          anchors.centerIn: parent
          width: parent.width - Style.space(24)
          spacing: Style.space(6)
          Text {
            width: parent.width
            text: root.displayNumber(identityWindow.modelData.name)
            horizontalAlignment: Text.AlignHCenter
            color: Color.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.baseSize * 6
            font.bold: true
          }
          Text {
            width: parent.width
            text: root.displayName(identityWindow.modelData.name)
            textFormat: Text.PlainText
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            color: Color.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.title
          }
          Text {
            width: parent.width
            text: identityWindow.modelData.name
            horizontalAlignment: Text.AlignHCenter
            color: Color.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
          }
        }
      }
    }
  }

}
