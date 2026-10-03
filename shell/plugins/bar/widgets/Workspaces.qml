import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.Commons
import qs.Ui
import "WorkspacesModel.js" as WorkspacesModel

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
        id: workspaceButton
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData
        readonly property bool urgent: workspace !== null && workspace.urgent === true
        readonly property real baseOpacity: WorkspacesModel.baseOpacity(occupied, focused)
        readonly property bool shouldFlash: WorkspacesModel.shouldFlash(urgent, focused)

        bar: root.bar
        text: focused ? "\uDB85\uDCFB" : (modelData === 10 ? "0" : String(modelData))
        opacity: shouldFlash ? flashOpacity : baseOpacity

        // The flash drives its own opacity and the base widget's 140ms easing
        // would smear the pulse into a laggy damped oscillation, so the change
        // behavior only applies while the button is not flashing.
        Behavior on opacity {
          enabled: !shouldFlash
          NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
        }

        // Opacity the flash animation walks between baseOpacity and the minimum.
        property real flashOpacity: baseOpacity

        // Pulse the button while an urgent window sits on an unfocused
        // workspace, so the attention request returns when the workspace is
        // visited or the urgency clears.
        SequentialAnimation {
          id: flashAnimation
          running: shouldFlash
          loops: Animation.Infinite
          NumberAnimation {
            target: workspaceButton
            property: "flashOpacity"
            from: baseOpacity
            to: WorkspacesModel.FLASH_MIN_OPACITY
            duration: WorkspacesModel.FLASH_DIRECTION_MS
            easing.type: Easing.InOutQuad
          }
          NumberAnimation {
            target: workspaceButton
            property: "flashOpacity"
            from: WorkspacesModel.FLASH_MIN_OPACITY
            to: baseOpacity
            duration: WorkspacesModel.FLASH_DIRECTION_MS
            easing.type: Easing.InOutQuad
          }
        }

        // Restarting from the resting opacity guarantees the first pulse step
        // never jumps from a value the previous flash stopped at.
        onShouldFlashChanged: {
          if (shouldFlash) flashOpacity = baseOpacity
        }

        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function() { root.focusWorkspace(modelData) }
      }
    }
  }
}
