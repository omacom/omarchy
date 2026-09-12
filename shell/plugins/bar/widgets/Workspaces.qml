import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// ─────────────────────────────────────────────────────────────────────────────
// Workspaces widget — Global-workspace-aware rewrite.
//
// TERMINOLOGY
//   AW (Apparent Workspace): what the user sees — AW1 through AW5.
//     Switching to AWN moves EVERY monitor to its corresponding Hyprland WS.
//   WS (Hyprland Workspace): the underlying integer ID Hyprland tracks.
//     Each monitor owns an exclusive range starting at a stable *base*:
//       base is assigned by monitor name (e.g. "eDP-1", "HDMI-1"), not by
//       Hyprland's transient numeric id. See omarchy-monitor-base for details.
//     AWN on monitor M = WS(base(M) + N).
//
// STABLE-BASE SCHEME:
//   Hyprland does not reuse numeric monitor ids after hotplug (#2601).
//   Using the monitor's OS name as a stable key means the same physical monitor
//   always owns the same workspace range regardless of its current numeric id.
//   The base map is persisted in ~/.local/state/omarchy/monitor-bases.json and
//   updated by omarchy-monitor-base sync (called by the switch script and the
//   toggle Lua on every Hyprland reload).
//
// GLOBAL MODE (workspace-global.lua toggle present):
//   - Bar always shows exactly 5 buttons labelled 1-5 (AW slots).
//   - Clicking AWN calls omarchy-hyprland-workspace-global-switch N, which
//     moves all monitors to their slot-N WS simultaneously.
//   - Focused: derived from ANY connected monitor's active workspace minus its
//     stable base (not hardcoded to monitor id 0, which may not exist in
//     clamshell/docked-only mode).
//   - Occupied: AWN is lit if ANY monitor has windows on WS(base(M)+N).
//
// LOCAL MODE (toggle absent):
//   - Falls back to stock omarchy behavior: shows raw Hyprland WS IDs 1-5
//     and clicking dispatches a single-monitor focus to that WS.
// ─────────────────────────────────────────────────────────────────────────────

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  // ── Global-mode flag ───────────────────────────────────────────────────────

  readonly property string globalToggleDir:
    (Quickshell.env("HOME") || "") + "/.local/state/omarchy/toggles/hypr"

  property bool globalMode: false

  Process {
    id: globalFlagProbe
    running: true
    command: ["bash", "-c",
      "[[ -f $HOME/.local/state/omarchy/toggles/hypr/workspace-global.lua ]] && echo yes || echo no"]
    stdout: SplitParser {
      onRead: function(line) { root.globalMode = String(line).trim() === "yes" }
    }
  }

  // Watch the directory so we detect the flag file being created or deleted.
  FileView {
    path: root.globalToggleDir
    watchChanges: true
    printErrors: false
    onFileChanged: globalFlagProbe.running = true
  }

  // ── Stable monitor base map ────────────────────────────────────────────────
  // Loaded from ~/.local/state/omarchy/monitor-bases.json.
  // Maps monitor name → workspace base (e.g. {"eDP-1": 0, "HDMI-1": 10}).
  // Reloaded whenever the file changes (hotplug adds a new monitor name).
  //
  // We read this as plain text rather than spawning jq so the QML side never
  // needs to know or duplicate the offset formula — it just asks "what base
  // does monitor X have?" and gets an integer back.

  property var monitorBaseMap: ({})

  readonly property string basesFilePath:
    (Quickshell.env("HOME") || "") + "/.local/state/omarchy/monitor-bases.json"

  FileView {
    id: basesFileView
    path: root.basesFilePath
    watchChanges: true
    printErrors: false
    onTextChanged: function() {
      try {
        root.monitorBaseMap = JSON.parse(text)
      } catch(e) {
        root.monitorBaseMap = {}
      }
    }
  }

  // Look up the stable base for a monitor by its OS name.
  // Falls back to 0 if the name is not yet in the map (shouldn't happen
  // after sync, but prevents a NaN from propagating into workspace IDs).
  function monitorBase(name) {
    var b = root.monitorBaseMap[name]
    return (b !== undefined && b !== null) ? b : 0
  }

  // ── This bar's monitor identity ────────────────────────────────────────────
  // Needed for:
  //   (a) global mode: derive focused slot from this monitor's active WS
  //   (b) local mode: fullscreen=2 workaround targets this monitor only

  readonly property string thisMonitorName: {
    var win = root.QsWindow ? root.QsWindow.window : null
    return (win && win.screen && win.screen.name) ? String(win.screen.name) : ""
  }

  readonly property int thisMonitorId: {
    var mons = Hyprland.monitors.values
    for (var i = 0; i < mons.length; i++) {
      if (mons[i].name === root.thisMonitorName) return mons[i].id
    }
    return 0
  }

  // ── AW slot list ───────────────────────────────────────────────────────────
  // Global mode: always [1, 2, 3, 4, 5] — stable, independent of which
  // Hyprland WS objects happen to exist at any moment.
  // Local mode: raw Hyprland WS IDs 1-10 (stock omarchy logic).

  function awSlots() {
    if (root.globalMode) {
      return [1, 2, 3, 4, 5]
    }
    // Local mode fallback — stock logic.
    var ids = [1, 2, 3, 4, 5]
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id > 0 && id <= 10 && ids.indexOf(id) === -1) ids.push(id)
    }
    ids.sort(function(l, r) { return l - r })
    return ids
  }

  // ── Focused slot ───────────────────────────────────────────────────────────
  // Global mode: use Hyprland.focusedMonitor.activeWorkspace minus its stable
  // base. The focused monitor always receives IPC events first, so it is never
  // stale — unlike iterating Hyprland.monitors.values and taking the first
  // result, which may be a monitor that hasn't received an update yet.
  //
  // Local mode: match Hyprland.focusedWorkspace.id (stock behavior).

  function awIsFocused(slot) {
    if (!root.globalMode) {
      return Hyprland.focusedWorkspace !== null &&
             Hyprland.focusedWorkspace.id === slot
    }
    // Global mode: the focused monitor's activeWorkspace is always current.
    var mon = Hyprland.focusedMonitor
    if (mon === null || mon.activeWorkspace === null) return false
    return (mon.activeWorkspace.id - root.monitorBase(mon.name)) === slot
  }

  // ── Occupied indicator ────────────────────────────────────────────────────
  // Global mode: AWN is occupied if ANY monitor has windows on WS(base(M)+N).
  // All three bars show the same occupancy state for each slot.
  //
  // Local mode: check raw WS id == slot for windows (stock behavior).

  function awIsOccupied(slot) {
    if (!root.globalMode) {
      var values = Hyprland.workspaces.values
      for (var i = 0; i < values.length; i++) {
        if (values[i].id === slot) {
          return values[i].toplevels.values.length > 0
        }
      }
      return false
    }
    // Global mode: for each workspace that exists, compute which slot it
    // represents on its monitor using the stable base. If that slot matches
    // and it has windows, AW N is occupied.
    var wsList = Hyprland.workspaces.values
    for (var w = 0; w < wsList.length; w++) {
      var ws = wsList[w]
      if (ws.monitor === null) continue
      var wsBase = root.monitorBase(ws.monitor.name)
      var wsSlot = ws.id - wsBase
      if (wsSlot === slot && ws.toplevels.values.length > 0) {
        return true
      }
    }
    return false
  }

  // ── IPC refresh handler ───────────────────────────────────────────────────
  // Quickshell's HyprlandMonitor.activeWorkspace only updates when that monitor
  // generates an IPC event. In a synchronized multi-monitor switch, monitors
  // that didn't have keyboard focus at switch time receive no event and sit
  // stale until something incidental (e.g. cursor hover) triggers one.
  //
  // The switch script calls:
  //   qs ipc call omarchy.workspaces refresh
  // immediately after dispatching all workspace moves (backgrounded, so it
  // doesn't add latency to the switch itself). This forces a full re-query of
  // Hyprland state on every bar simultaneously, fixing the stale highlight.
  //
  // Because each bar is its own Quickshell process, qs ipc call without a
  // --pid flag broadcasts to all running instances — one call covers all bars.

  IpcHandler {
    target: "omarchy.workspaces"

    function refresh(): void {
      Hyprland.refreshMonitors()
      Hyprland.refreshWorkspaces()
    }
  }

  // ── Switch to an AW slot ──────────────────────────────────────────────────
  // Global mode: omarchy-hyprland-workspace-global-switch <slot> handles all
  // monitors, fullscreen=2, and workspace-theft prevention internally.
  //
  // Local mode: single-monitor focus with fullscreen=2 workaround — detect the
  // blocking window by address, stash it to WS999 (no focus change), switch
  // the workspace, then restore it to its original WS by address.

  function switchToAW(slot) {
    if (!root.bar) return

    if (root.globalMode) {
      if (slot < 1 || slot > 10) return
      root.bar.run("omarchy-hyprland-workspace-global-switch " + slot)
      return
    }

    // Local mode fallback.
    var monId = root.thisMonitorId
    var monBase = root.monitorBase(root.thisMonitorName)
    var stashWs = monBase + 99  // monitor-pinned scratch; avoids cross-monitor shadow
    var bashCmd =
      "cjson=$(hyprctl clients -j 2>/dev/null || echo '[]'); " +
      "fs_addr=$(echo \"$cjson\" | jq -r --argjson mid " + monId + " " +
        "'.[] | select(.monitor == $mid and .fullscreen == 2) | .address' " +
        "2>/dev/null | head -1); " +
      "orig_ws=''; " +
      "if [ -n \"$fs_addr\" ]; then " +
      "  orig_ws=$(echo \"$cjson\" | jq -r --arg addr \"$fs_addr\" " +
        "'.[] | select(.address == $addr) | .workspace.id' 2>/dev/null); " +
      "  hyprctl eval \"hl.dispatch(hl.dsp.workspace.move({ workspace = '" + stashWs + "', monitor = '" + root.thisMonitorName + "' }))\" >/dev/null 2>&1 || true; " +
      "  hyprctl eval \"hl.dispatch(hl.dsp.window.move({ workspace = '" + stashWs + "', window = 'address:$fs_addr', follow = false }))\" >/dev/null 2>&1 || true; " +
      "fi; " +
      "hyprctl eval \"hl.dispatch(hl.dsp.focus({ workspace = '" + slot + "' }))\" >/dev/null 2>&1 || true; " +
      "if [ -n \"$fs_addr\" ] && [ -n \"$orig_ws\" ]; then " +
      "  hyprctl eval \"hl.dispatch(hl.dsp.window.move({ workspace = '$orig_ws', window = 'address:$fs_addr', follow = false }))\" >/dev/null 2>&1 || true; " +
      "fi"
    root.bar.run("bash -c " + Util.shellQuote(bashCmd))
  }

  // ── Layout ────────────────────────────────────────────────────────────────

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.awSlots().length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.awSlots()

      WidgetButton {
        required property int modelData  // AW slot number (1-5)

        readonly property bool occupied: root.awIsOccupied(modelData)
        readonly property bool focused:  root.awIsFocused(modelData)

        bar: root.bar
        text: String(modelData)
        opacity: occupied || focused ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function() { root.switchToAW(modelData) }
      }
    }
  }
}
