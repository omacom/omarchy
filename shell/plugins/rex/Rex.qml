import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Commons as Commons
import "views"

// Rex, the offline regular expression workbench. Launched from Apps
// (applications/Rex.desktop) through omarchy-launch-rex, or directly:
//   omarchy-shell shell summon omarchy.rex '{"pattern":"\\d+"}'
//
// The window is an ordinary tiled toplevel. Everything that can take time —
// running a pattern on an engine, reading a large file — happens off the UI
// thread, because this window lives in the same process as the bar.
Item {
  id: root

  property var shell: null
  property var manifest: null

  readonly property string pluginId: (manifest && manifest.id) || "omarchy.rex"

  readonly property color foreground: Commons.Color.foreground
  readonly property color background: Commons.Color.background
  readonly property color accent: Commons.Color.accent
  readonly property color dim: Qt.darker(foreground, 1.5)

  property bool closingFromHost: false

  // The session being worked on: everything a saved pattern carries.
  property string pattern: ""
  property string testText: ""

  // ---- lifecycle ----------------------------------------------------------

  function open(payloadJson) {
    closingFromHost = false
    var payload = {}
    try { payload = JSON.parse(payloadJson || "{}") || {} } catch (e) {}
    if (typeof payload.pattern === "string" && payload.pattern !== "") pattern = payload.pattern
    if (typeof payload.text === "string") testText = payload.text

    window.visible = true
    Qt.callLater(function() { if (window.visible) workbench.focusPattern() })
  }

  // Host-initiated close (`shell hide`): the host already knows.
  function close() {
    closingFromHost = true
    window.visible = false
    closingFromHost = false
  }

  // ---- window -------------------------------------------------------------

  FloatingWindow {
    id: window
    title: "Rex"
    color: root.background
    implicitWidth: Style.space(1280)
    implicitHeight: Style.space(820)
    minimumSize: Qt.size(Style.space(720), Style.space(480))
    visible: false

    // Closing the window from the compositor ends the session; tell the host
    // so the plugin unloads and `toggle` keeps working.
    onVisibleChanged: {
      if (!visible && !root.closingFromHost && root.shell && typeof root.shell.hide === "function")
        root.shell.hide(root.pluginId)
    }

    Workbench {
      id: workbench
      anchors.fill: parent
      foreground: root.foreground
      background: root.background
      accent: root.accent
      pattern: root.pattern
      testText: root.testText
      onPatternEdited: function(value) { root.pattern = value }
      onTestTextEdited: function(value) { root.testText = value }
    }
  }
}
