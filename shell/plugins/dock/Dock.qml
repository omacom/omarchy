import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import "DockModel.js" as DockModel

// An app dock that shows on floating workspaces. A floating workspace has no
// tiles to hand the apps out, so the dock gives back a place to find them:
// pinned apps, running apps, and a grid of every app.
Item {
  id: root

  property var shell: null
  property var manifest: null

  readonly property var appLibrary: shell ? shell.appLibrary : null
  readonly property var dockConfig: shell && shell.shellConfig && shell.shellConfig.dock ? shell.shellConfig.dock : ({})
  readonly property var defaultDockConfig: shell && shell.defaultsConfig && shell.defaultsConfig.dock ? shell.defaultsConfig.dock : ({})
  readonly property string position: DockModel.normalizePosition(dockConfig.position)
  readonly property bool vertical: DockModel.isVertical(position)
  readonly property bool autohide: dockConfig.autohide === true

  // The dock's order for the session, as desktop ids, set when the user moves
  // an app: a drag moves it, and keeping it in the dock puts it at the end. An
  // app the order does not know yet goes at the end. Pins are saved in this
  // order.
  property var order: []

  // A reorder shows at once rather than when the saved config comes back.
  property var pendingPins: null
  onDockConfigChanged: pendingPins = null

  // Entries that can claim a terminal app's window or a Chromium PWA window.
  readonly property var matchableEntries: {
    var values = DesktopEntries.applications.values
    var out = []
    for (var i = 0; i < values.length; i++) {
      var entry = values[i]
      var exec = String(entry.execString || "")
      if (entry.runInTerminal || exec.indexOf("--app-id=") >= 0 || exec.indexOf("://") >= 0 || exec.indexOf("webapp") >= 0)
        out.push({ id: entry.id, execString: entry.execString, command: entry.command, runInTerminal: entry.runInTerminal })
    }
    return out
  }

  property var entryCache: ({})
  onMatchableEntriesChanged: entryCache = ({})

  function entryForAppId(appId) {
    var id = String(appId || "").trim()
    if (!id) return null
    if (entryCache[id] !== undefined) return entryCache[id] ? DesktopEntries.byId(entryCache[id]) : null
    var entry = DesktopEntries.heuristicLookup(id)
    if (!entry) {
      var claimed = DockModel.claimingEntryId(id, root.matchableEntries)
      if (claimed) entry = DesktopEntries.byId(claimed)
    }
    if (!entry && id.indexOf("steam_app_") === 0)
      entry = DesktopEntries.heuristicLookup(id.slice("steam_app_".length))
    entryCache[id] = entry ? String(entry.id) : ""
    return entry || null
  }

  function fallbackIconForKey(key) {
    var k = String(key || "")
    if (k === "org.omarchy.agent") return "foot"
    if (k.indexOf("steam_app_") === 0) return k.slice("steam_app_".length)
    return k
  }

  function displayNameFor(item) {
    if (!item) return ""
    var entry = entryFor(item)
    if (entry && entry.name) return String(entry.name)
    if (item.key === "org.omarchy.agent") return Commons.I18n.t("dock.agentTerminal")
    var wins = item.windows || []
    if (wins.length > 0 && wins[0].title) return String(wins[0].title)
    if (item.key.indexOf("steam_app_") === 0) return item.key.slice("steam_app_".length)
    return String(item.key || "")
  }

  function clickModeFor(key) {
    return root.appLibrary && key ? root.appLibrary.dockClickMode(key) : ""
  }

  // Lazy terminal process + cwd inspection triggered only when opening a
  // multi-window terminal menu, so an idle dock spawns no background processes.
  readonly property string homeDir: Quickshell.env("HOME") || ""
  property var pidInfo: ({})

  function terminalPidList(windows) {
    var pids = []
    for (var i = 0; i < (windows || []).length; i++) {
      var w = windows[i]
      if (!w || !(w.pid > 0)) continue
      var cls = String(w.appId || "").toLowerCase()
      if (cls === "org.omarchy.agent" || cls === "foot" || cls === "kitty" || cls === "alacritty" || cls.indexOf("ghostty") >= 0) {
        if (pids.indexOf(w.pid) === -1) pids.push(w.pid)
      }
    }
    pids.sort(function(a, b) { return a - b })
    return pids
  }

  function pidInspectScript(pids) {
    if (!pids || pids.length === 0) return "true"
    return [
      "ps_out=$(ps -eo pid=,ppid=,args= 2>/dev/null);",
      "for p in " + pids.join(" ") + "; do",
      "  child=$(printf \"%s\\n\" \"$ps_out\" | awk -v pp=\"$p\" '$2 == pp { print $1; exit }');",
      "  [[ -z $child ]] && child=$p;",
      "  args=$(printf \"%s\\n\" \"$ps_out\" | awk -v id=\"$child\" '$1 == id { $1=\"\"; $2=\"\"; sub(/^ +/, \"\"); print; exit }');",
      "  cwd=$(readlink -f \"/proc/$child/cwd\" 2>/dev/null || true);",
      "  printf \"%s\\t%s\\t%s\\n\" \"$p\" \"$cwd\" \"$args\";",
      "done"
    ].join(" ")
  }

  function parsePidOutput(rawText) {
    var next = Object.assign({}, root.pidInfo)
    var lines = String(rawText || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i]
      if (!line) continue
      var parts = line.split("\t")
      if (parts.length < 3) continue
      var pid = String(parts[0] || "").trim()
      var cwd = String(parts[1] || "").trim()
      var args = String(parts[2] || "").trim()
      if (!pid) continue
      var cwdBase = cwd ? (root.homeDir && cwd === root.homeDir ? "~" : cwd.split("/").pop()) : ""
      var prog = args ? args.split(/\s+/)[0].split("/").pop() : ""
      var promptMatch = /--prompt-interactive\s+(.+)$/.exec(args)
      var hint = promptMatch ? promptMatch[1].replace(/^['"]|['"]$/g, "") : ""
      if (hint.length > 26) hint = hint.slice(0, 25) + "…"
      next[pid] = { prog: prog, cwd: cwdBase, hint: hint }
    }
    if (JSON.stringify(next) !== JSON.stringify(root.pidInfo)) root.pidInfo = next
  }

  function inspectPidsForItem(key) {
    var item = itemFor(key)
    if (!item || item.windows.length < 2) return
    var pids = terminalPidList(item.windows)
    if (pids.length === 0 || pidProc.running) return
    pidProc.command = ["bash", "-c", root.pidInspectScript(pids)]
    pidProc.running = true
  }

  function formatWindowLabel(window, fallbackKey) {
    if (!window) return String(fallbackKey || "")
    return String(window.displayTitle || window.title || fallbackKey || "")
  }

  Process {
    id: pidProc
    property string buffer: ""
    stdout: SplitParser { onRead: function(line) { pidProc.buffer += line + "\n" } }
    onStarted: buffer = ""
    onExited: root.parsePidOutput(buffer)
  }

  // Extract normalized windows from Hyprland.toplevels with lastIpcObject
  // fallback so XWayland clients are matched alongside Wayland windows.
  readonly property var rawWindows: {
    var appsRevision = DesktopEntries.applications.values.length
    var pinned = (root.pendingPins || DockModel.pinnedIds(dockConfig, defaultDockConfig)).filter(function(id) {
      return !!DesktopEntries.byId(id)
    })
    var windows = []
    var toplevels = Hyprland.toplevels.values
    for (var i = 0; i < toplevels.length; i++) {
      var item = toplevels[i]
      var wl = item.wayland
      if (wl && wl.parent) continue
      var ipc = item.lastIpcObject || ({})
      var appId = (wl && wl.appId) ? String(wl.appId) : String(ipc.class || ipc.initialClass || "")
      if (!appId) continue
      var ws = item.workspace || ipc.workspace
      var wsId = ws && ws.id !== undefined ? Number(ws.id) : -1
      var wsName = ws && ws.name !== undefined ? String(ws.name) : ""
      var winMonitor = item.monitor || (ws && ws.monitor ? ws.monitor : null)
      var monitorName = winMonitor && winMonitor.name ? String(winMonitor.name) : ""
      var monitorId = winMonitor && winMonitor.id !== undefined
        ? Number(winMonitor.id)
        : (ipc.monitor !== undefined ? Number(ipc.monitor) : -1)
      var title = (wl && wl.title) ? String(wl.title) : String(ipc.title || ipc.initialTitle || appId)
      var focusId = ipc.focusHistoryID !== undefined ? Number(ipc.focusHistoryID) : 9999
      var activated = wl ? !!wl.activated : (focusId === 0)
      var entry = root.entryForAppId(appId)
      windows.push({
        key: entry ? DockModel.standInKey(entry.id, entry.categories, pinned) : appId,
        appId: appId,
        hasEntry: !!entry && !entry.noDisplay,
        workspaceId: wsId,
        workspaceName: wsName,
        monitorName: monitorName,
        monitorId: monitorId,
        minimized: DockModel.isMinimizedWorkspace(wsName),
        activated: activated,
        floating: !!(ipc.floating),
        pinned: !!(ipc.pinned),
        fullscreen: Number(ipc.fullscreen || 0),
        focusHistoryID: focusId,
        pid: ipc.pid !== undefined ? Number(ipc.pid) : 0,
        tags: Array.isArray(ipc.tags) ? ipc.tags : [],
        title: title,
        address: DockModel.normalizeAddress(item.address || ipc.address),
        toplevel: wl || null
      })
    }
    return windows
  }

  onRawWindowsChanged: {
    var livePids = {}
    for (var i = 0; i < rawWindows.length; i++) {
      if (rawWindows[i].pid > 0) livePids[String(rawWindows[i].pid)] = true
    }
    var pruned = {}
    var removed = false
    for (var pid in root.pidInfo) {
      if (livePids[pid]) pruned[pid] = root.pidInfo[pid]
      else removed = true
    }
    if (removed) root.pidInfo = pruned
  }

  // A pinned app that is not installed has nothing to launch, so it is left
  // out until it is. Windows are matched to the desktop entry that claims them.
  readonly property var items: {
    var appsRevision = DesktopEntries.applications.values.length
    var pinned = (root.pendingPins || DockModel.pinnedIds(dockConfig, defaultDockConfig)).filter(function(id) {
      return !!DesktopEntries.byId(id)
    })

    return DockModel.orderItems(DockModel.buildItems(pinned, root.rawWindows, root.pidInfo), root.order)
  }

  readonly property var itemsByKey: {
    var byKey = {}
    for (var i = 0; i < root.items.length; i++) byKey[root.items[i].key] = root.items[i]
    return byKey
  }

  function itemFor(key) {
    return root.itemsByKey[key] || null
  }

  // The dock's slots follow this model rather than the items list itself, so
  // a slot survives a window opening or closing instead of being rebuilt
  // under the pointer, and a reorder moves slots rather than replacing them.
  property alias itemModel: itemModel

  ListModel { id: itemModel }

  onItemsChanged: syncItemModel()

  function shownKeys() {
    return root.items.map(function(item) { return item.key })
  }

  function syncItemModel() {
    var keys = root.items.map(function(item) { return item.key })
    for (var i = 0; i < keys.length; i++) {
      if (i < itemModel.count && itemModel.get(i).key === keys[i]) continue
      var found = -1
      for (var j = i + 1; j < itemModel.count; j++) {
        if (itemModel.get(j).key === keys[i]) { found = j; break }
      }
      if (found >= 0) itemModel.move(found, i, 1)
      else itemModel.insert(i, { key: keys[i] })
    }
    if (itemModel.count > keys.length) itemModel.remove(keys.length, itemModel.count - keys.length)
    root.settleLaunches()
  }

  // An app launched from the dock pulses its dot until a new window of it
  // shows up, or for ten seconds if none does.
  property var launches: ({})
  readonly property int launchTimeout: 10000

  function isLaunching(key) {
    return root.launches[key] !== undefined
  }

  function settleLaunches() {
    var next = {}
    var changed = false
    var now = Date.now()
    for (var key in root.launches) {
      var launch = root.launches[key]
      var item = root.itemsByKey[key]
      var windows = item ? item.windows.length : 0
      if (windows > launch.windows || now - launch.at > root.launchTimeout) changed = true
      else next[key] = launch
    }
    if (changed) root.launches = next
  }

  Timer {
    interval: 1000
    repeat: true
    running: Object.keys(root.launches).length > 0
    onTriggered: root.settleLaunches()
  }

  function entryFor(item) {
    return item ? DesktopEntries.byId(item.key) : null
  }

  function iconFor(item) {
    var entry = entryFor(item)
    var icon = entry && entry.icon ? entry.icon : (item ? fallbackIconForKey(item.key) : "")
    return root.appLibrary ? root.appLibrary.iconSource(icon) : Quickshell.iconPath(icon, true)
  }

  function launch(item) {
    var entry = entryFor(item)
    if (!entry) return
    var next = Object.assign({}, root.launches)
    next[item.key] = { at: Date.now(), windows: item.windows.length }
    root.launches = next
    root.launchEntry(entry)
  }

  function launchEntry(entry) {
    if (entry && root.appLibrary) root.appLibrary.launch(entry.id, entry.name)
  }

  function activate(item, targetWorkspaceId) {
    if (!item) return
    var workspaceId = Number(targetWorkspaceId)
    if (!(workspaceId >= 1)) {
      var monitor = Hyprland.focusedMonitor
      workspaceId = monitor && monitor.activeWorkspace ? monitor.activeWorkspace.id : -1
    }
    var mode = root.appLibrary ? root.appLibrary.dockClickMode(item.key) : ""
    var index = DockModel.pickClickWindow(mode, item.windows.map(function(window) {
      return {
        workspaceId: window.workspaceId,
        minimized: window.minimized,
        activated: window.activated,
        address: window.address
      }
    }), workspaceId)
    if (index < 0) {
      root.launch(item)
      return
    }
    root.bringForward(item.windows[index], workspaceId)
  }

  property var pendingNoAnimUnsets: []

  function scheduleNoAnimUnset(address) {
    if (pendingNoAnimUnsets.indexOf(address) < 0)
      pendingNoAnimUnsets = pendingNoAnimUnsets.concat([address])
    noAnimUnsetTimer.restart()
  }

  function flushNoAnimUnsets() {
    noAnimUnsetTimer.stop()
    var addresses = pendingNoAnimUnsets
    pendingNoAnimUnsets = []
    for (var i = 0; i < addresses.length; i++)
      Hyprland.dispatch("hl.dsp.window.set_prop({ prop = \"no_anim\", value = \"unset\", window = \"address:" + addresses[i] + "\" })")
  }

  // If the dock is disabled or reloaded within 400ms of restoring a minimized
  // window, flush pending resets immediately so no_anim isn't left stuck on.
  Component.onDestruction: {
    flushNoAnimUnsets()
    pidProc.running = false
  }

  Timer {
    id: noAnimUnsetTimer
    interval: 400
    repeat: false
    onTriggered: root.flushNoAnimUnsets()
  }

  // A window the dock brings forward lands on top of the others, focused; a
  // minimized one first comes back to the clicked dock's workspace.
  function bringForward(window) {
    if (!window) return
    var address = String(window.address || "").trim()
    if (address && address.indexOf("0x") !== 0) address = "0x" + address
    if (!/^0x[0-9a-f]+$/i.test(address)) {
      if (window.toplevel && typeof window.toplevel.activate === "function") window.toplevel.activate()
      return
    }
    var target = "window = \"address:" + address + "\""
    if (window.minimized) {
      var workspace = arguments.length > 1 ? Number(arguments[1]) : -1
      if (!(workspace >= 1)) {
        var monitor = Hyprland.focusedMonitor
        workspace = monitor && monitor.activeWorkspace ? monitor.activeWorkspace.id : -1
      }
      if (!(workspace >= 1)) return
      // A restored window is simply there again, without animating in.
      Hyprland.dispatch("hl.dsp.window.set_prop({ prop = \"no_anim\", value = \"1\", " + target + " })")
      var tags = window.tags || []
      for (var i = 0; i < tags.length; i++) {
        var tag = String(tags[i] || "")
        if (/^omarchy-minimized-from-[0-9]+$/.test(tag))
          Hyprland.dispatch("hl.dsp.window.tag({ tag = \"-" + tag + "\", " + target + " })")
      }
      Hyprland.dispatch("hl.dsp.window.move({ workspace = \"" + workspace + "\", " + target + " })")
      scheduleNoAnimUnset(address)
    }
    Hyprland.dispatch("hl.dsp.focus({ " + target + " })")
    Hyprland.dispatch("hl.dsp.window.alter_zorder({ mode = \"top\", " + target + " })")
  }

  function dispatchSteps(steps) {
    if (!steps || steps.length === 0) return
    for (var i = 0; i < steps.length; i++) Hyprland.dispatch(steps[i])
    hyprRefreshDebounce.restart()
  }

  function restorePrefixSteps(window, destWorkspace) {
    var address = DockModel.normalizeAddress(window && window.address)
    if (!address || !window.minimized || !(destWorkspace >= 1)) return []
    var target = "window = \"address:" + address + "\""
    var steps = []
    var tags = window.tags || []
    for (var i = 0; i < tags.length; i++) {
      var tag = String(tags[i] || "")
      if (/^omarchy-minimized-from-[0-9]+$/.test(tag))
        steps.push("hl.dsp.window.tag({ tag = \"-" + tag + "\", " + target + " })")
    }
    steps.push("hl.dsp.window.move({ workspace = \"" + destWorkspace + "\", " + target + " })")
    return steps
  }

  function closeWindow(window) {
    if (!window) return
    if (window.toplevel && typeof window.toplevel.close === "function") {
      window.toplevel.close()
    } else {
      var address = DockModel.normalizeAddress(window.address)
      if (address) Hyprland.dispatch("hl.dsp.window.close({ window = \"address:" + address + "\" })")
    }
    hyprRefreshDebounce.restart()
  }

  function minimizeWindow(window) {
    var address = DockModel.normalizeAddress(window && window.address)
    if (!address) return
    Util.execArgv(["omarchy-hyprland-window-minimize", address])
    hyprRefreshDebounce.restart()
  }

  function toggleMaximize(window, targetWorkspaceId) {
    var address = DockModel.normalizeAddress(window && window.address)
    if (!address) return
    var target = "window = \"address:" + address + "\""
    var steps = restorePrefixSteps(window, targetWorkspaceId)
    steps.push("hl.dsp.window.fullscreen({ mode = \"maximized\", action = \"toggle\", " + target + " })")
    steps.push("hl.dsp.focus({ " + target + " })")
    dispatchSteps(steps)
  }

  function toggleFullscreen(window, targetWorkspaceId) {
    var address = DockModel.normalizeAddress(window && window.address)
    if (!address) return
    var target = "window = \"address:" + address + "\""
    var steps = restorePrefixSteps(window, targetWorkspaceId)
    steps.push("hl.dsp.window.fullscreen({ mode = \"fullscreen\", action = \"toggle\", " + target + " })")
    steps.push("hl.dsp.focus({ " + target + " })")
    dispatchSteps(steps)
  }

  function toggleFloating(window, targetWorkspaceId) {
    var address = DockModel.normalizeAddress(window && window.address)
    if (!address) return
    var target = "window = \"address:" + address + "\""
    var steps = restorePrefixSteps(window, targetWorkspaceId)
    steps.push("hl.dsp.window.float({ action = \"toggle\", " + target + " })")
    steps.push("hl.dsp.focus({ " + target + " })")
    dispatchSteps(steps)
  }

  function togglePin(window, targetWorkspaceId) {
    var address = DockModel.normalizeAddress(window && window.address)
    if (!address) return
    var target = "window = \"address:" + address + "\""
    var steps = restorePrefixSteps(window, targetWorkspaceId)
    if (!window.floating) steps.push("hl.dsp.window.float({ action = \"on\", " + target + " })")
    steps.push("hl.dsp.window.pin({ " + target + " })")
    steps.push("hl.dsp.window.alter_zorder({ mode = \"top\", " + target + " })")
    dispatchSteps(steps)
  }

  function placeWindow(window, mode, monitor, targetWorkspaceId) {
    var address = DockModel.normalizeAddress(window && window.address)
    if (!address) return
    var target = "window = \"address:" + address + "\""
    var steps = restorePrefixSteps(window, targetWorkspaceId)
    if (!window.floating) steps.push("hl.dsp.window.float({ action = \"on\", " + target + " })")
    if (window.fullscreen > 0) steps.push("hl.dsp.window.fullscreen({ mode = \"maximized\", action = \"unset\", " + target + " })")

    var targetMonitor = window.minimized ? monitor : monitorForWindow(window, monitor)
    if (mode === "center") {
      steps.push("hl.dsp.window.center({ " + target + " })")
    } else if (targetMonitor && targetMonitor.width && targetMonitor.height) {
      var scale = targetMonitor.scale > 0 ? targetMonitor.scale : 1
      var w = Math.floor(targetMonitor.width / scale)
      var h = Math.floor(targetMonitor.height / scale)
      if ((targetMonitor.transform || 0) % 2 === 1) {
        var tmp = w; w = h; h = tmp
      }
      var res = (targetMonitor.lastIpcObject && targetMonitor.lastIpcObject.reserved) ? targetMonitor.lastIpcObject.reserved : [0, 0, 0, 0]
      var left = res[0] || 0, top = res[1] || 0, right = res[2] || 0, bottom = res[3] || 0
      var gap = 12
      var areaW = Math.max(400, w - left - right - gap * 3)
      var areaH = Math.max(300, h - top - bottom - gap * 2)
      var halfW = Math.floor(areaW / 2)
      var posX = mode === "left" ? (left + gap) : (left + gap * 2 + halfW)
      var posY = top + gap
      steps.push("hl.dsp.window.resize({ x = " + halfW + ", y = " + areaH + ", relative = false, " + target + " })")
      steps.push("hl.dsp.window.move({ x = " + posX + ", y = " + posY + ", relative = false, " + target + " })")
    }
    steps.push("hl.dsp.focus({ " + target + " })")
    steps.push("hl.dsp.window.alter_zorder({ mode = \"top\", " + target + " })")
    dispatchSteps(steps)
  }

  function moveWindowToWorkspace(window, destWorkspace, follow) {
    var address = DockModel.normalizeAddress(window && window.address)
    var ws = Number(destWorkspace)
    if (!address || !(ws >= 1)) return
    var target = "window = \"address:" + address + "\""
    var steps = []
    var tags = window.tags || []
    for (var i = 0; i < tags.length; i++) {
      var tag = String(tags[i] || "")
      if (/^omarchy-minimized-from-[0-9]+$/.test(tag))
        steps.push("hl.dsp.window.tag({ tag = \"-" + tag + "\", " + target + " })")
    }
    steps.push("hl.dsp.window.move({ workspace = \"" + ws + "\", follow = " + (follow ? "true" : "false") + ", " + target + " })")
    if (follow) {
      steps.push("hl.dsp.focus({ " + target + " })")
      steps.push("hl.dsp.window.alter_zorder({ mode = \"top\", " + target + " })")
    }
    dispatchSteps(steps)
  }

  function moveWindowToScratchpad(window) {
    var address = DockModel.normalizeAddress(window && window.address)
    if (!address) return
    dispatchSteps(["hl.dsp.window.move({ workspace = \"special:scratchpad\", follow = false, window = \"address:" + address + "\" })"])
  }

  function monitorForWindow(window, fallbackMonitor) {
    var monitors = Hyprland.monitors.values || []
    if (!window) return fallbackMonitor || null
    var name = String(window.monitorName || "")
    var monId = window.monitorId !== undefined ? Number(window.monitorId) : -1
    for (var i = 0; i < monitors.length; i++) {
      if ((name && monitors[i].name === name) || (monId >= 0 && Number(monitors[i].id) === monId))
        return monitors[i]
    }
    var wsId = window.workspaceId >= 1 ? window.workspaceId : DockModel.minimizedOriginWorkspace(window.tags)
    if (wsId >= 1) {
      var workspaces = Hyprland.workspaces.values || []
      for (var j = 0; j < workspaces.length; j++) {
        if (workspaces[j].id === wsId && workspaces[j].monitor) return workspaces[j].monitor
      }
    }
    return fallbackMonitor || null
  }

  function moveWindowToNextMonitor(window, currentMonitor) {
    var address = DockModel.normalizeAddress(window && window.address)
    var monitors = Hyprland.monitors.values || []
    if (!address || monitors.length < 2) return
    var sourceMonitor = monitorForWindow(window, currentMonitor)
    var idx = -1
    for (var i = 0; i < monitors.length; i++) {
      if (sourceMonitor && monitors[i].name === sourceMonitor.name) { idx = i; break }
    }
    var next = monitors[(idx + 1) % monitors.length]
    var destWs = next && next.activeWorkspace ? next.activeWorkspace.id : -1
    if (destWs >= 1) moveWindowToWorkspace(window, destWs, false)
  }

  function quit(item) {
    if (!item) return
    var windows = item.windows.slice()
    for (var i = 0; i < windows.length; i++) closeWindow(windows[i])
  }

  function openApps() {
    appGrid.open()
  }

  readonly property var pinnedKeys: root.pendingPins || DockModel.pinnedIds(root.dockConfig, root.defaultDockConfig)

  function isPinned(key) {
    return root.pinnedKeys.indexOf(key) >= 0
  }

  // Moves an app to a slot in the dock's order, pinning it there; the pins are
  // saved in the new order. The index counts the slots once the app has left
  // its own.
  function placeAt(key, index) {
    if (!key) return
    root.order = DockModel.orderWithKeyAt(root.shownKeys(), key, index)
    var pinned = {}
    root.pinnedKeys.forEach(function(other) { pinned[other] = true })
    pinned[key] = true
    root.savePins(DockModel.pinsInOrder(root.order, pinned, root.pinnedKeys))
  }

  // A reorder shows at once; the saved config catches up after.
  function savePins(pins) {
    root.pendingPins = pins
    Util.execDetached("omarchy-dock pinned " + pins.map(function(id) { return Util.shellQuote(id) }).join(" "))
  }

  function moveItem(fromIndex, toIndex) {
    if (fromIndex !== toIndex) root.placeAt(root.shownKeys()[fromIndex], toIndex)
  }

  // An app dropped before the slot at index, counted as the slots stand.
  function pinAt(key, index) {
    var from = root.shownKeys().indexOf(key)
    root.placeAt(key, from >= 0 && from < index ? index - 1 : index)
  }

  // Keeping an app in the dock puts it at the end; taking one out leaves it in
  // its slot while it still runs.
  function setPinned(key, pinned) {
    if (!key) return
    if (pinned) {
      root.placeAt(key, root.shownKeys().length)
    } else {
      root.pendingPins = root.pinnedKeys.filter(function(other) { return other !== key })
      Util.execDetached("omarchy-dock unpin " + Util.shellQuote(key))
    }
  }

  // Each workspace's layout is read once and cached. It only changes through
  // the layout commands, which ask the dock to refresh, or a config reload.
  // A refresh reads every layout again but keeps the old ones until the new
  // ones arrive: a theme switch reloads the config, and clearing them would
  // hide the dock in the middle of the switch.
  property var modes: ({})
  property var readModes: ({})
  property var pendingModes: []
  property int modeGeneration: 0
  property int modeProcWorkspace: -1
  property int modeProcGeneration: 0

  function isFloating(workspaceId) {
    return root.modes[workspaceId] === "floating"
  }

  function readMode(workspaceId) {
    if (!(workspaceId >= 1) || root.readModes[workspaceId]) return
    root.readModes[workspaceId] = true
    root.pendingModes.push(workspaceId)
    root.readNextMode()
  }

  function readNextMode() {
    if (modeProc.running || root.pendingModes.length === 0) return
    root.modeProcWorkspace = root.pendingModes.shift()
    root.modeProcGeneration = root.modeGeneration
    modeProc.command = ["omarchy-hyprland-workspace-layout-current", String(root.modeProcWorkspace)]
    modeProc.running = true
  }

  function refresh() {
    root.readModes = ({})
    root.pendingModes = []
    root.modeGeneration++
    var monitors = Hyprland.monitors.values
    for (var i = 0; i < monitors.length; i++) {
      if (monitors[i].activeWorkspace) root.readMode(monitors[i].activeWorkspace.id)
    }
    // Read the rest ahead of time, so the dock shows or hides the moment the
    // user switches to one.
    var workspaces = Hyprland.workspaces.values
    for (var j = 0; j < workspaces.length; j++) root.readMode(workspaces[j].id)
  }

  Component.onCompleted: {
    refresh()
    syncItemModel()
  }

  Process {
    id: modeProc
    stdout: StdioCollector {
      onStreamFinished: {
        var mode = text.trim()
        // A read that started before a refresh may predate the change.
        if (root.modeProcGeneration !== root.modeGeneration) return
        // A failed read is tried again the next time it is asked for.
        if (!mode) {
          delete root.readModes[root.modeProcWorkspace]
          return
        }
        var next = Object.assign({}, root.modes)
        next[root.modeProcWorkspace] = mode
        root.modes = next
      }
    }
    // Deferred: the process still reports running while it signals exit.
    onExited: Qt.callLater(root.readNextMode)
  }

  Timer {
    id: hyprRefreshDebounce
    interval: 50
    onTriggered: {
      Hyprland.refreshMonitors()
      Hyprland.refreshWorkspaces()
      Hyprland.refreshToplevels()
    }
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      var name = event ? String(event.name) : ""
      if (name === "configreloaded") {
        root.refresh()
        hyprRefreshDebounce.restart()
      } else if (
        name === "fullscreen" ||
        name === "openwindow" ||
        name === "closewindow" ||
        name === "movewindow" ||
        name === "movewindowv2" ||
        name === "activewindow" ||
        name === "windowtitlev2" ||
        name === "workspacev2" ||
        name === "moveworkspacev2" ||
        name === "changeworkspaceid" ||
        name === "focusedmon"
      ) {
        hyprRefreshDebounce.restart()
      }
    }
  }

  ShellIpc {
    target: "omarchy.dock"

    // The layout commands call this after changing a workspace's mode.
    function refresh(): void { root.refresh() }
    function apps(): void { appGrid.toggle() }
  }

  // An app dragged out of the app grid: the grid holds the pointer and
  // reports where it is, and the dock on that screen shows where it would land.
  function dockOn(screen) {
    var windows = docks.instances
    for (var i = 0; i < windows.length; i++) {
      if (windows[i].screen === screen) return windows[i]
    }
    return null
  }

  function moveExternalDrag(screen, x, y) {
    var windows = docks.instances
    for (var i = 0; i < windows.length; i++) {
      if (windows[i].screen === screen) windows[i].moveExternalDrag(x, y)
      else windows[i].endExternalDrag()
    }
  }

  function dropExternalDrag(screen, x, y, key) {
    var target = root.dockOn(screen)
    if (target) target.dropExternalDrag(x, y, key)
    root.endExternalDrag()
  }

  function endExternalDrag() {
    var windows = docks.instances
    for (var i = 0; i < windows.length; i++) windows[i].endExternalDrag()
  }

  Variants {
    id: docks
    model: Quickshell.screens

    delegate: Component {
      DockWindow {
        required property var modelData

        screen: modelData
        dock: root
      }
    }
  }

  AppGrid {
    id: appGrid
    appLibrary: root.appLibrary
    dock: root
  }
}
