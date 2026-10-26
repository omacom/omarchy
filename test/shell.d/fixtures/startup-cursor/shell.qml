import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "services"

ShellRoot {
  id: test
  property var bar: ({})
  property var services: ({ "omarchy.background": background })
  function firstPartyServiceFor(id) { return background }
  QtObject { id: background; property bool suspended: false; property bool ready: false }
  BackgroundIntro {
    id: intro
    host: test
    onStartupPendingChanged: if (!startupPending) phase.setText("revealed")
  }
  FileView {
    id: release
    path: Quickshell.env("CURSOR_TEST_STAGE") + "/release"
    watchChanges: true
    onLoaded: background.ready = text().trim() === "reveal"
    onFileChanged: reload()
  }
  FileView {
    id: phase
    path: Quickshell.env("CURSOR_TEST_STAGE") + "/phase"
    atomicWrites: true
  }
  PanelWindow {
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Bottom
    mask: Region {}
    color: "magenta"
  }
  Component.onCompleted: phase.setText("holding")
}
