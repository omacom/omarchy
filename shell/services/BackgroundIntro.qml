import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

// OWE destroys and recreates the background service during playback, so the
// startup process and cover state belong to the persistent shell host.
Item {
  id: root

  property var host: null
  property bool cover: true
  property bool checked: false
  readonly property bool backgroundActive: !!(host && host.services && host.firstPartyServiceFor("omarchy.background"))

  Component.onCompleted: {
    checked = true
    introProc.running = true
  }

  onBackgroundActiveChanged: {
    if (!backgroundActive && checked) cover = false
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData
      visible: root.cover
      color: "black"
      mask: Region {}
      anchors { top: true; bottom: true; left: true; right: true }
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Bottom
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      WlrLayershell.namespace: "omarchy-background"
    }
  }

  Process {
    id: introProc
    command: ["omarchy-theme-bg-boot-intro"]
    onExited: root.cover = false
  }
}
