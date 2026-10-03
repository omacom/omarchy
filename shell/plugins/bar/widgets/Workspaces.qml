import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Commons
import qs.Ui
import "WorkspacesModel.js" as WorkspacesModel

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  // Numbered workspaces bound to each monitor by Hyprland workspace rules.
  property var ruleIdsByMonitor: ({})

  readonly property var hyprlandMonitor: {
    var window = root.QsWindow.window
    return window && window.screen ? Hyprland.monitorFor(window.screen) : null
  }

  Component.onCompleted: reloadRules()

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (!event || !event.name) return
      var name = String(event.name)
      if (name === "configreloaded" || name.indexOf("monitoradded") === 0 || name.indexOf("monitorremoved") === 0) root.reloadRules()
    }
  }

  Process {
    id: rulesProcess
    running: false
    command: ["sh", "-c", "printf '{\"rules\":%s,\"monitors\":%s}' \"$(hyprctl workspacerules -j)\" \"$(hyprctl monitors -j)\""]

    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyRules(text)
    }
  }

  function reloadRules() {
    if (!rulesProcess.running) rulesProcess.running = true
  }

  function applyRules(output) {
    var data
    try { data = JSON.parse(output) } catch (e) { return }
    root.ruleIdsByMonitor = WorkspacesModel.monitorRuleIds(data.rules || [], data.monitors || [])
  }

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  function workspaceIds() {
    var values = Hyprland.workspaces.values
    var workspaces = []
    for (var i = 0; i < values.length; i++) {
      workspaces.push({ id: values[i].id, monitor: values[i].monitor ? values[i].monitor.name : "" })
    }

    return WorkspacesModel.workspaceIds(root.ruleIdsByMonitor, root.hyprlandMonitor ? root.hyprlandMonitor.name : "", workspaces)
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
        // Each bar marks the workspace shown on its own monitor.
        readonly property var shownWorkspace: root.hyprlandMonitor ? root.hyprlandMonitor.activeWorkspace : Hyprland.focusedWorkspace
        readonly property bool focused: shownWorkspace !== null && shownWorkspace.id === modelData

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
