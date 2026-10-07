import QtQuick
import Quickshell
import Quickshell.Wayland
import "services"

ShellRoot {
  id: test
  property var bar: ({})
  property var services: ({ "omarchy.background": background })
  function firstPartyServiceFor(id) { return background }
  QtObject { id: background; property bool suspended: false; property bool ready: false }
  BackgroundIntro { id: intro; host: test }
  PanelWindow {
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Bottom
    mask: Region {}
    color: "magenta"
  }
  Timer { interval: 1500; running: true; onTriggered: background.ready = true }
}
