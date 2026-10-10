import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

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

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function workspaceIsDisplayed(workspaceId) {
    var monitors = Hyprland.monitors.values
    for (var i = 0; i < monitors.length; i++) {
      var active = monitors[i].activeWorkspace
      if (active && active.id === workspaceId) return true
    }

    return false
  }

  function focusWorkspace(id) {
    if (!root.bar) return

    var workspaceId = parseInt(id, 10)
    if (!(workspaceId > 0)) return

    // A workspace already on a monitor: follow it (old behaviour). One that
    // is only remembered on its last monitor would otherwise restore there
    // even when the click was on a different bar.
    var follow = "hl.dsp.focus({ workspace = \"" + workspaceId + "\" })"
    if (root.workspaceIsDisplayed(workspaceId)) {
      root.bar.run("hyprctl dispatch " + Util.shellQuote(follow))
      return
    }

    var barWindow = root.QsWindow ? root.QsWindow.window : null
    var barMonitor = barWindow && barWindow.screen ? Hyprland.monitorFor(barWindow.screen) : null
    var monitorName = barMonitor && barMonitor.name ? String(barMonitor.name).trim() : ""
    if (!/^[A-Za-z0-9:._-]+$/.test(monitorName)) {
      root.bar.run("hyprctl dispatch " + Util.shellQuote(follow))
      return
    }

    var batch = "dispatch hl.dsp.focus({ monitor = \"" + monitorName + "\" }) ; dispatch hl.dsp.focus({ workspace = \"" + workspaceId + "\", on_current_monitor = true })"
    root.bar.run("hyprctl --batch " + Util.shellQuote(batch))
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
        readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData

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
