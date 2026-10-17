import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
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

  // Whether a slot belongs on this bar. Gating the delegate's visibility keeps
  // the Repeater's model identical across a cross-monitor move, so this cannot
  // churn the model on the very event that triggers the teardown crash in
  // basecamp/omarchy#8547; only a visible flag flips.
  function showsHere(id) {
    if (!root.monitorOnly) return true
    // Unresolved monitor, or the one workspace this monitor is displaying:
    // show it rather than risk rendering an empty bar.
    if (root.barMonitor === null || id === root.activeId) return true
    // workspace.monitor, not lastIpcObject.monitor: Quickshell updates the
    // former on a cross-monitor move, but lastIpcObject keeps the old monitor
    // until some unrelated event refreshes it. A workspace with no monitor
    // (mid output teardown) is hidden rather than claimed by this bar.
    var workspace = root.workspaceById(id)
    return workspace !== null && workspace.monitor !== null && workspace.monitor.name === root.barMonitor.name
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

  // A wheel notch moves one entry along the row, and a touchpad adds up its
  // smaller deltas until they make a notch's worth.
  property real wheelAccumulator: 0

  function scrollWorkspaces(delta) {
    var wheel = Util.wheelSteps(root.wheelAccumulator, delta)
    root.wheelAccumulator = wheel.remainder
    if (wheel.steps === 0) return

    // Holds at either end rather than wrapping, so a touchpad swipe that runs
    // long stops on the last workspace.
    var ids = root.workspaceIds()
    var index = ids.indexOf(root.focusedWorkspaceId())
    if (index === -1) return
    var target = ids[Util.clamp(index - wheel.steps, 0, ids.length - 1)]
    if (target !== ids[index]) root.focusWorkspace(target)
  }

  // The focused workspace shows its layout: a square tiles, a circle scrolls,
  // and a triangle floats. Clicking it cycles to the next one, as Super + L does.
  property string focusedMode: "dwindle"
  property bool modeStale: false

  function modeGlyph(mode) {
    if (mode === "scrolling") return "\uDB81\uDF65"
    if (mode === "floating") return "\uDB81\uDD36"
    return "\uDB85\uDCFB"
  }

  // A layout only changes through the layout commands, which ask for a refresh,
  // or a config reload, so each workspace's mode is read once and cached rather
  // than running the script on every workspace switch.
  property var modeCache: ({})
  property int modeGeneration: 0
  property int modeProcWorkspace: -1
  property int modeProcGeneration: 0

  function focusedWorkspaceId() {
    return Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1
  }

  function showFocusedMode() {
    var mode = root.modeCache[root.focusedWorkspaceId()]
    if (mode !== undefined) root.focusedMode = mode
    else readMode()
  }

  function readMode() {
    if (modeProc.running) {
      root.modeStale = true
      return
    }
    var id = root.focusedWorkspaceId()
    if (id === -1) return
    root.modeProcWorkspace = id
    root.modeProcGeneration = root.modeGeneration
    modeProc.command = ["omarchy-hyprland-workspace-layout-current", String(id)]
    modeProc.running = true
  }

  function refresh() {
    root.modeCache = ({})
    root.modeGeneration++
    readMode()
  }

  function cycleLayout() {
    if (root.bar) root.bar.run("omarchy-hyprland-workspace-layout-toggle")
  }

  Component.onCompleted: refresh()

  Connections {
    target: Hyprland
    function onFocusedWorkspaceChanged() { root.showFocusedMode() }
    function onRawEvent(event) {
      if (event && String(event.name) === "configreloaded") root.refresh()
    }
  }

  Process {
    id: modeProc
    stdout: StdioCollector {
      onStreamFinished: {
        var mode = text.trim()
        // A read that started before a refresh may predate the change.
        if (!mode || root.modeProcGeneration !== root.modeGeneration) return
        root.modeCache[root.modeProcWorkspace] = mode
        if (root.modeProcWorkspace === root.focusedWorkspaceId()) root.focusedMode = mode
      }
    }
    onExited: {
      if (!root.modeStale) return
      root.modeStale = false
      // Deferred: the process still reports running while it signals exit.
      Qt.callLater(root.showFocusedMode)
    }
  }

  // Super + L and the default layout change the mode without a focus change,
  // so they ask every bar to read it again.
  ShellIpc {
    target: "omarchy.workspaces"

    function refresh(): void { root.broadcast("refresh") }
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
        text: focused ? root.modeGlyph(root.focusedMode) : (modelData === 10 ? "0" : String(modelData))
        opacity: occupied || focused ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function() {
          if (focused) root.cycleLayout()
          else root.focusWorkspace(modelData)
        }
        onWheelMoved: function(delta) { root.scrollWorkspaces(delta) }
      }
    }
  }
}
