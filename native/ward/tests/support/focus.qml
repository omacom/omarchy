import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
  id: root
  property int keyCount: 0
  property int heartbeat: 0
  property int mode: WlrKeyboardFocus.None

  Timer { interval: 75; repeat: true; running: true; onTriggered: root.heartbeat += 1 }
  Timer { id: prime; interval: 75; onTriggered: root.mode = WlrKeyboardFocus.OnDemand }

  PanelWindow {
    anchors { top: true; left: true; right: true }
    implicitHeight: 30
    color: "#263442"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    Text { x: 8; y: 6; text: "Prime   Exclusive   None   Unmap"; color: "white"; font.pixelSize: 11 }
    MouseArea {
      anchors.fill: parent
      onClicked: event => {
        prime.stop()
        if (event.x < 120) {
          root.mode = WlrKeyboardFocus.Exclusive
          panel.visible = true
          editor.forceActiveFocus()
          if (event.x < 60) prime.restart()
        } else if (event.x < 180) root.mode = WlrKeyboardFocus.None
        else if (event.x < 240) panel.visible = false
      }
    }
    Rectangle { x: 260; y: 5; width: 20; height: 20; color: editor.Window.active && editor.activeFocus ? "#aaffcc" : "#111122" }
    Rectangle { x: 290; y: 5; width: 20; height: 20; color: ["#ee4422", "#44ee22", "#3388ff", "#ffee44", "#ff44dd", "#ff8800"][Math.min(root.keyCount, 5)] }
    Rectangle { x: 320; y: 5; width: 20; height: 20; color: root.mode === WlrKeyboardFocus.OnDemand ? "#22ccdd" : "#111122" }
    Rectangle { x: 350; y: 5; width: 20; height: 20; color: root.heartbeat % 2 ? "#667788" : "#8899aa" }
  }

  PanelWindow {
    id: panel
    visible: false
    anchors { top: true; left: true; right: true }
    margins.top: 40
    implicitHeight: 100
    color: "#304050"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.mode
    TextInput {
      id: editor
      x: 16; y: 24; width: 350; height: 40
      focus: true
      text: "Panel keyboard focus"
      color: "white"
      font.pixelSize: 18
      Keys.onPressed: event => {
        if (event.key === Qt.Key_E) { root.keyCount += 1; event.accepted = true }
      }
    }
  }
}
