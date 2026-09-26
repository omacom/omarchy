import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  // The output this bar is drawn on. One bar surface exists per monitor, so
  // this is what tells the copies of this widget apart.
  readonly property string screenName: {
    var window = root.QsWindow ? root.QsWindow.window : null
    return window && window.screen ? String(window.screen.name || "") : ""
  }

  function monitor() {
    if (!root.screenName) return null

    var values = Hyprland.monitors.values
    for (var i = 0; i < values.length; i++) {
      if (String(values[i].name || "") === root.screenName) return values[i]
    }

    return null
  }

  // Which display has the keyboard. Every bar marks what its own display is
  // showing, so this is what keeps all of them from claiming to be the one
  // being typed into.
  readonly property bool keyboardHere: {
    var focused = Hyprland.focusedMonitor
    return !!focused && String(focused.name || "") === root.screenName
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
        // What this bar's own display is showing, which is not the same as the
        // focused workspace: with a second display, marking
        // Hyprland.focusedWorkspace leaves every bar but one pointing at
        // a workspace that is not even on it.
        readonly property bool current: {
          var active = root.monitor() ? root.monitor().activeWorkspace : null
          return !!active && active.id === modelData
        }

        bar: root.bar
        text: current ? "\uDB85\uDCFB" : (modelData === 10 ? "0" : String(modelData))
        // The display holding the keyboard marks its workspace at full
        // strength and the others sit back, so the desk still says where you
        // are typing without any bar losing track of its own display. With
        // one display there is nothing to fade and this reads as it did.
        opacity: current ? (root.keyboardHere ? 1 : 0.75) : (occupied ? 1 : 0.5)
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function() { root.focusWorkspace(modelData) }
      }
    }
  }
}
