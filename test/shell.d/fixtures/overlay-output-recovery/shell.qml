import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Ui

ShellRoot {
  id: root
  property int keyCount: 0
  property int visibilityChanges: 0
  readonly property var focusedMonitor: Hyprland.focusedMonitor

  Connections {
    target: overlay
    function onVisibleChanged() { root.visibilityChanges += 1 }
  }

  OverlayWindow {
    id: overlay
    WlrLayershell.namespace: "omarchy-overlay-recovery-test"

    Rectangle {
      anchors.fill: parent
      color: "#182030"

      Text {
        anchors.centerIn: parent
        text: "Overlay recovered"
        color: "white"
        font.pixelSize: 32
      }

      Item {
        anchors.fill: parent
        focus: true
        Keys.onPressed: function(event) {
          root.keyCount += 1
          event.accepted = true
        }
      }
    }
  }

  IpcHandler {
    target: "fixture"
    function show(): void { overlay.shown = true }
    function park(): void { overlay.shown = false }
    function state(): string {
      return JSON.stringify({
        shown: overlay.shown,
        visible: overlay.visible,
        width: overlay.width,
        height: overlay.height,
        screen: overlay.screen ? overlay.screen.name : "",
        focusedMonitor: root.focusedMonitor ? root.focusedMonitor.name : "",
        keyCount: root.keyCount,
        keyboardFocus: overlay.WlrLayershell.keyboardFocus,
        visibilityChanges: root.visibilityChanges,
        screens: Quickshell.screens.map(function(screen) {
          return { name: screen.name, width: screen.width, height: screen.height }
        })
      })
    }
  }
}
