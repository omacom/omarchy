import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

// OWE destroys and recreates the background service during playback, so the
// startup process and cover state belong to the persistent shell host.
Item {
  id: root

  property var host: null
  property bool cover: String(bootMarker.text() || "").trim() !== (Quickshell.env("OMARCHY_BOOT_ID") || String(bootId.text() || "").trim())
  property bool checked: false
  readonly property bool backgroundActive: !!(host && host.services && host.firstPartyServiceFor("omarchy.background"))

  // Snapshot startup state: the launcher records this boot before playback.
  FileView {
    id: bootMarker
    path: Quickshell.env("HOME") + "/.local/state/omarchy/background-intro.boot-id"
    blockLoading: true
    watchChanges: false
    printErrors: false
  }

  FileView {
    id: bootId
    path: "/proc/sys/kernel/random/boot_id"
    blockLoading: true
    watchChanges: false
  }

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
