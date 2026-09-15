import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
  id: root
  property bool demoted: false
  property int barClicks: 0
  property int popupClicks: 0

  // Deliberately create frontmost first, background last.
  PanelWindow {
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.layer: root.demoted ? WlrLayer.Bottom : WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    mask: Region { item: marker }
    Rectangle {
      id: marker
      x: 240; y: 14; width: 32; height: 48; radius: 6
      color: root.demoted ? "#ee5599" : "#ff7744"
      NumberAnimation on x { from: 240; to: 310; duration: 2000; loops: Animation.Infinite; running: !root.demoted }
      Rectangle { x: 7; y: 10; width: 5; height: 5; color: "white" }
      Rectangle { x: 20; y: 10; width: 5; height: 5; color: "white" }
      MouseArea { anchors.fill: parent; onClicked: root.demoted = true }
    }
  }
  PanelWindow {
    anchors { top: true; left: true; right: true }
    margins { top: 8; left: 16; right: 24 }
    implicitHeight: 36
    color: root.barClicks ? "#44ee22" : "#20bfa5"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    MouseArea { anchors.fill: parent; onClicked: root.barClicks++ }
    Text { x: 8; anchors.verticalCenter: parent.verticalCenter; text: "Private bar" }
    Rectangle {
      id: trigger
      x: parent.width - 30; y: 4; width: 24; height: 28; color: "#607080"
      MouseArea { anchors.fill: parent; onClicked: popup.visible = true }
    }
    PopupWindow {
      id: popup
      visible: false
      implicitWidth: 100; implicitHeight: 60
      color: root.popupClicks === 0 ? "#8a2be2" : root.popupClicks === 1 ? "#bb6633" : "#22ccdd"
      anchor.item: trigger
      anchor.rect.x: root.popupClicks ? -400 : trigger.width
      anchor.rect.y: trigger.height
      anchor.adjustment: PopupAdjustment.Slide
      Text { anchors.centerIn: parent; text: "Edge popup"; color: "white" }
      MouseArea { anchors.fill: parent; onClicked: root.popupClicks++ }
    }
  }
  FloatingWindow {
    implicitWidth: 160; implicitHeight: 100; color: "#304050"
    TextInput { id: input; x: 10; y: 20; width: 140; height: 30; color: "white"; font.pixelSize: 20; text: "INPUT" }
    Rectangle { x: 10; y: 65; width: 20; height: 20; color: input.text.indexOf("e") >= 0 ? "#ffee44" : "#ff3300" }
    Rectangle { x: 40; y: 65; width: 20; height: 20; color: input.text.indexOf("r") >= 0 ? "#eeeeff" : "#ff3300" }
    Rectangle { x: 70; y: 65; width: 20; height: 20; color: input.activeFocus ? "#88ffdd" : "#ff3300" }
  }
  PanelWindow {
    anchors { top: true; bottom: true; left: true; right: true }
    color: "#223344"
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    mask: Region {}
  }
}
