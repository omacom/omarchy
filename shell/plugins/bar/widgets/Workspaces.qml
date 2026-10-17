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

  // Separate workspaces give each monitor its own 1–10. Hyprland ids stay
  // global: monitor slot N owns N*10+1 through N*10+10. The state file is
  // written by default/hypr/monitor-workspaces.lua while the toggle is on.
  property bool separate: false
  property var slotsByDescription: ({})
  property int slotCount: 10
  property int screenRevision: 0
  // The window's screen, remembered after the bar has been placed. Reading
  // QsWindow while the row's size is being measured loops, and walking parents
  // never reaches the panel, so a click would aim at workspaces 1–10.
  property var hostScreenObject: null

  function stateHome() {
    var home = Quickshell.env("HOME") || ""
    var dir = Quickshell.env("XDG_STATE_HOME")
    if (!dir || dir.length === 0) dir = home + "/.local/state"
    return dir + "/omarchy"
  }

  function clearState() {
    separate = false
    slotsByDescription = ({})
    slotCount = 10
  }

  function applyStateText() {
    var raw = stateFile.text()
    if (!raw || raw.length === 0) {
      clearState()
      return
    }

    try {
      var parsed = JSON.parse(raw)
      separate = !!(parsed && parsed.enabled === true)
      slotsByDescription = (parsed && parsed.monitors) ? parsed.monitors : ({})
      slotCount = (parsed && parsed.count > 0) ? parsed.count : 10
    } catch (e) {
      clearState()
    }
  }

  // The bar's PanelWindow is an ancestor and already knows its screen.
  // Asking QsWindow for the window during a size binding loops, because the
  // window attachment lays this item out to learn its implicit size.
  function rememberScreen() {
    var attached = root.QsWindow
    var window = attached ? attached.window : null
    var screen = window ? window.screen : null
    if (!screen) return
    var changed = root.hostScreenObject !== screen
    root.hostScreenObject = screen
    if (changed) root.screenRevision++
  }

  function hostScreen() {
    if (root.hostScreenObject) return root.hostScreenObject

    var item = root
    var guard = 0
    while (item && guard < 24) {
      if (item.screen) return item.screen
      item = item.parent
      guard++
    }
    return null
  }

  function screenMonitor() {
    var screen = hostScreen()
    if (!screen) return null

    var matched = Hyprland.monitorFor(screen)
    if (matched) return matched

    var monitors = Hyprland.monitors.values
    for (var i = 0; i < monitors.length; i++) {
      if (monitors[i].name === screen.name) return monitors[i]
    }

    return null
  }

  function monitorIndex(monitor) {
    if (!separate || !monitor || !monitor.description) return -1
    var slots = slotsByDescription || {}
    var index = slots[monitor.description]
    if (index === undefined || index === null || index < 0) return -1
    return index
  }

  function localNumber(index, id) {
    if (index < 0 || id <= 0) return -1
    var local = id - index * slotCount
    if (local < 1 || local > slotCount) return -1
    return local
  }

  function globalIdFor(shown) {
    var index = monitorIndex(screenMonitor())
    if (index < 0) return shown
    return index * slotCount + shown
  }

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  function workspaceIds() {
    var monitor = screenMonitor()
    var index = monitorIndex(monitor)
    var values = Hyprland.workspaces.values
    var ids = [1, 2, 3, 4, 5]

    if (index < 0) {
      for (var i = 0; i < values.length; i++) {
        var id = values[i].id
        if (id > 0 && id <= 10 && ids.indexOf(id) === -1) ids.push(id)
      }

      ids.sort(function(left, right) { return left - right })
      return ids
    }

    var active = monitor.activeWorkspace
    var activeLocal = active ? localNumber(index, active.id) : -1
    if (activeLocal > 0 && ids.indexOf(activeLocal) === -1) ids.push(activeLocal)

    for (var j = 0; j < values.length; j++) {
      var workspace = values[j]
      if (!workspace.monitor || workspace.monitor.name !== monitor.name) continue
      var local = localNumber(index, workspace.id)
      if (local < 1 || ids.indexOf(local) !== -1) continue
      var windows = workspace.toplevels && workspace.toplevels.values
      if (windows && windows.length > 0) ids.push(local)
    }

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  // The number shown for the workspace this bar is on. Shared mode uses the
  // keyboard focus. Separate mode uses the workspace open on this screen.
  function currentShownId() {
    var monitor = screenMonitor()
    var index = monitorIndex(monitor)
    if (index < 0) return focusedWorkspaceId()
    var active = monitor.activeWorkspace
    if (!active) return -1
    return localNumber(index, active.id)
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
    var ids = root.shownIds
    var index = ids.indexOf(root.currentShownId())
    if (index === -1) return
    var target = ids[Util.clamp(index - wheel.steps, 0, ids.length - 1)]
    if (target !== ids[index]) root.focusWorkspace(root.globalIdFor(target))
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

  Component.onCompleted: {
    refresh()
    Qt.callLater(root.rememberScreen)
  }

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

  // Read the reactive sources here so the row follows workspace, focus, and
  // toggle changes. The numbers themselves are computed in workspaceIds().
  readonly property var shownIds: {
    var screen = hostScreenObject
    var workspaces = Hyprland.workspaces.values
    var monitors = Hyprland.monitors.values
    var focused = Hyprland.focusedMonitor
    var enabled = separate
    var slots = slotsByDescription
    var revision = screenRevision
    return workspaceIds(workspaces, monitors, focused, enabled, slots, revision, screen)
  }

  // The panel may not own the widget on the first completion.
  Timer {
    interval: 50
    running: root.hostScreenObject === null
    repeat: false
    onTriggered: root.rememberScreen()
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  FileView {
    id: stateFile
    path: root.stateHome() + "/monitor-workspaces.json"
    watchChanges: true
    printErrors: false
    onLoaded: root.applyStateText()
    onFileChanged: reload()
    onLoadFailed: root.clearState()
  }

  // FileView cannot observe a file that does not exist yet. The state
  // directory does, and the toggle creates the json on the next reload.
  FileView {
    id: stateDir
    path: root.stateHome()
    watchChanges: true
    printErrors: false
    onFileChanged: stateFile.reload()
  }

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.shownIds.length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.shownIds

      WidgetButton {
        required property int modelData

        readonly property int slotIndex: root.monitorIndex(root.screenMonitor())
        readonly property int globalId: slotIndex >= 0 ? slotIndex * root.slotCount + modelData : modelData
        readonly property var workspace: root.workspaceById(globalId)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property var monitor: root.screenMonitor()
        readonly property bool keyboardHere: monitor !== null && Hyprland.focusedMonitor !== null && monitor.name === Hyprland.focusedMonitor.name
        readonly property bool activeSlot: {
          if (slotIndex < 0) return Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData
          var active = monitor ? monitor.activeWorkspace : null
          return active !== null && root.localNumber(slotIndex, active.id) === modelData
        }
        // The layout glyph marks the keyboard focus. The other screen keeps
        // its active number at full opacity so both bars show where they are.
        readonly property bool glyph: slotIndex < 0 ? activeSlot : (keyboardHere && activeSlot)

        bar: root.bar
        text: glyph ? root.modeGlyph(root.focusedMode) : (modelData === 10 ? "0" : String(modelData))
        opacity: occupied || glyph || (slotIndex >= 0 && activeSlot) ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function() {
          if (glyph) root.cycleLayout()
          else root.focusWorkspace(globalId)
        }
        onWheelMoved: function(delta) { root.scrollWorkspaces(delta) }
      }
    }
  }
}
