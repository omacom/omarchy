import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  // Opt-in: list only the workspaces on this bar's own monitor. Off by default,
  // so single-screen setups and every existing config behave exactly as before.
  readonly property bool monitorOnly: setting("monitorOnly", false) === true

  // The monitor this bar surface is drawn on. One bar exists per screen, so
  // each instance resolves its own. monitorFor() is the reliable route here;
  // matching Hyprland.monitors by name returns null while the widget is still
  // completing and the binding never re-fires.
  readonly property var barMonitor: {
    var window = root.QsWindow ? root.QsWindow.window : null
    return window && window.screen ? Hyprland.monitorFor(window.screen) : null
  }

  // Which workspace this bar should highlight. Per monitor that is the
  // monitor's own active workspace -- the focused monitor is not necessarily
  // the one this bar is on -- otherwise the global focus, as before.
  readonly property int activeId: {
    if (root.monitorOnly && root.barMonitor !== null && root.barMonitor.activeWorkspace !== null)
      return root.barMonitor.activeWorkspace.id
    return Hyprland.focusedWorkspace !== null ? Hyprland.focusedWorkspace.id : -1
  }

  // Connector the workspace currently sits on. lastIpcObject is the raw
  // `hyprctl workspaces -j` entry, whose .monitor is already a connector name.
  function workspaceMonitorName(workspace) {
    if (!workspace) return ""
    if (workspace.lastIpcObject && workspace.lastIpcObject.monitor) return String(workspace.lastIpcObject.monitor)
    if (workspace.monitor && workspace.monitor.name) return String(workspace.monitor.name)
    return ""
  }

  // Whether a slot belongs on this bar. Gating the delegate's visibility keeps
  // the Repeater's model identical across a cross-monitor move, so this cannot
  // churn the model on the very event that triggers the teardown crash in
  // basecamp/omarchy#8547; only a visible flag flips.
  function showsHere(id) {
    if (!root.monitorOnly) return true
    // Unresolved monitor, or the one workspace this monitor is displaying:
    // show it rather than risk rendering an empty bar.
    if (root.barMonitor === null || id === root.activeId) return true
    return root.workspaceMonitorName(root.workspaceById(id)) === String(root.barMonitor.name || "")
  }

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  function workspaceIds() {
    var ids = [1, 2, 3, 4, 5]
    var values = Hyprland.workspaces.values

    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id > 0 && id <= 10 && ids.indexOf(id) === -1) ids.push(id)
    }

    // A monitor with none of 1-10 pinned to it -- the laptop panel when the lid
    // is opened while docked, say -- is handed a fresh workspace above that
    // range, which the cap above drops. Keep it so its bar is not left empty.
    if (root.monitorOnly && root.activeId > 0 && ids.indexOf(root.activeId) === -1) ids.push(root.activeId)

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.workspaceIds().length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      WidgetButton {
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool focused: root.activeId === modelData

        visible: root.showsHere(modelData)
        bar: root.bar
        text: focused ? "\uDB85\uDCFB" : (modelData === 10 ? "0" : String(modelData))
        opacity: occupied || focused ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function() { root.focusWorkspace(modelData) }
      }
    }
  }
}
