// The dock's state that does not need Quickshell: where it sits, which apps it
// shows, and which window a click brings forward.

var POSITIONS = ["top", "bottom", "left", "right"]

function normalizePosition(value) {
  var position = String(value || "").trim().toLowerCase()
  return POSITIONS.indexOf(position) >= 0 ? position : "bottom"
}

function isVertical(position) {
  var normalized = normalizePosition(position)
  return normalized === "left" || normalized === "right"
}

function normalizeId(value) {
  var id = String(value || "").trim()
  if (id.slice(-8) === ".desktop") id = id.slice(0, -8)
  return id
}

function normalizeAddress(address) {
  var value = String(address || "").trim()
  if (!/^(0x)?[0-9a-fA-F]+$/.test(value)) return ""
  return value.indexOf("0x") === 0 ? value : "0x" + value
}

function minimizedOriginWorkspace(tags) {
  var list = tags || []
  for (var i = 0; i < list.length; i++) {
    var match = /^omarchy-minimized-from-([1-9][0-9]*)$/.exec(String(list[i] || ""))
    if (match) return parseInt(match[1], 10)
  }
  return -1
}

function slotOf(workspaceId) {
  var id = Number(workspaceId)
  if (!(id >= 1)) return -1
  return ((id - 1) % 10) + 1
}

function itemStats(windows) {
  var list = windows || []
  var minimized = 0
  var activated = false
  for (var i = 0; i < list.length; i++) {
    if (list[i].minimized) minimized++
    if (list[i].activated || (list[i].toplevel && list[i].toplevel.activated)) activated = true
  }
  return {
    total: list.length,
    minimized: minimized,
    open: list.length - minimized,
    activated: activated
  }
}

// Prioritizes active, then open, then minimized windows within the slot cap.
function representativeDots(windows, cap) {
  var list = (windows || []).slice()
  var limit = cap > 0 ? cap : 4
  list.sort(function(a, b) {
    var aa = !!(a.activated || (a.toplevel && a.toplevel.activated))
    var ba = !!(b.activated || (b.toplevel && b.toplevel.activated))
    if (aa !== ba) return aa ? -1 : 1
    if (!!a.minimized !== !!b.minimized) return a.minimized ? 1 : -1
    var af = isFinite(a.focusHistoryID) ? a.focusHistoryID : 9999
    var bf = isFinite(b.focusHistoryID) ? b.focusHistoryID : 9999
    return af - bf
  })
  return list.slice(0, limit)
}

function pinnedIds(dockConfig, defaultsConfig) {
  var source = dockConfig && Array.isArray(dockConfig.pinned) ? dockConfig.pinned
    : (defaultsConfig && Array.isArray(defaultsConfig.pinned) ? defaultsConfig.pinned : [])
  var ids = []
  for (var i = 0; i < source.length; i++) {
    var id = normalizeId(source[i])
    if (id && ids.indexOf(id) === -1) ids.push(id)
  }
  return ids
}

// Only app windows on regular workspaces belong in the dock. Helpers without a
// visible desktop entry, such as the agent window, and anything parked on a
// special workspace, such as the scratchpad, stay out of it. A minimized window
// always belongs, entry or not, since the dock is the only way back to it.
function isDockWindow(window) {
  if (!window || !window.key) return false
  if (window.minimized === true) return true
  return window.hasEntry === true && window.workspaceId >= 1
}

// Minimizing moves a window to this special workspace, and the dock brings it
// back.
var MINIMIZED_WORKSPACE = "special:minimized"

function isMinimizedWorkspace(name) {
  return String(name || "") === MINIMIZED_WORKSPACE
}

function extractChromeWebappHost(appId) {
  var match = /^chrome-([A-Za-z0-9._-]+)__-[A-Za-z0-9._-]+$/.exec(String(appId || ""))
  return match ? match[1].toLowerCase() : ""
}

// A terminal app's window carries the app id its launcher gave the terminal,
// or a Chromium PWA window carries chrome-<host>__-<profile>, which no desktop
// entry names as its class. Entries are { id, execString, command, runInTerminal }.
function claimingEntryId(appId, entries) {
  var id = String(appId || "")
  if (!id) return ""
  var list = entries || []
  var flag = "--app-id=" + id
  for (var i = 0; i < list.length; i++) {
    var exec = String(list[i].execString || "")
    if (exec.indexOf(flag) >= 0) {
      var words = exec.split(/\s+/)
      for (var w = 0; w < words.length; w++) {
        if (words[w].replace(/^['"]|['"]$/g, "") === flag) return list[i].id
      }
    }
  }
  if (id.indexOf("org.omarchy.") === 0) {
    var command = id.slice("org.omarchy.".length)
    for (var j = 0; j < list.length; j++) {
      var program = String((list[j].command || [])[0] || "")
      if (list[j].runInTerminal && program.slice(program.lastIndexOf("/") + 1) === command) return list[j].id
    }
  }
  var host = extractChromeWebappHost(id)
  if (host) {
    for (var k = 0; k < list.length; k++) {
      var cmdText = (String(list[k].execString || "") + " " + String((list[k].command || []).join(" "))).toLowerCase()
      if (cmdText.indexOf("://" + host) >= 0 || cmdText.indexOf("." + host) >= 0) return list[k].id
    }
  }
  return ""
}

// The launcher's Terminal and Browser open the default terminal and browser,
// whose windows carry that app's own id. A pinned Terminal or Browser claims
// the windows of any app in its category, unless that app is pinned itself.
var STAND_INS = [
  { id: "omarchy-terminal", category: "TerminalEmulator" },
  { id: "omarchy-browser", category: "WebBrowser" }
]

function standInKey(key, categories, pinned) {
  var pins = pinned || []
  if (pins.indexOf(key) >= 0) return key
  for (var i = 0; i < STAND_INS.length; i++) {
    var standIn = STAND_INS[i]
    if (key !== standIn.id && pins.indexOf(standIn.id) >= 0 && (categories || []).indexOf(standIn.category) >= 0)
      return standIn.id
  }
  return key
}

// Pinned apps come first, in pin order, whether or not they run. Running apps
// that are not pinned follow in the order their first window appeared. Each
// window is { key, hasEntry, workspaceId, ... } where key is the desktop id of
// the entry that claims it.
function buildItems(pinned, windows, pidInfo) {
  var items = []
  var byKey = {}

  function itemFor(key, isPinned) {
    if (!byKey[key]) {
      byKey[key] = { key: key, pinned: isPinned, windows: [] }
      items.push(byKey[key])
    }
    return byKey[key]
  }

  for (var i = 0; i < (pinned || []).length; i++) {
    if (pinned[i]) itemFor(pinned[i], true)
  }

  for (var j = 0; j < (windows || []).length; j++) {
    var window = windows[j]
    if (isDockWindow(window)) itemFor(window.key, false).windows.push(window)
  }

  // Sort each app's windows by active/open/MRU and assign #N labels for duplicates.
  var infoMap = pidInfo || ({})
  for (var k = 0; k < items.length; k++) {
    var wins = items[k].windows
    wins.sort(function(a, b) {
      if (!!a.activated !== !!b.activated) return a.activated ? -1 : 1
      if (!!a.minimized !== !!b.minimized) return a.minimized ? 1 : -1
      var fa = isFinite(a.focusHistoryID) ? a.focusHistoryID : 9999
      var fb = isFinite(b.focusHistoryID) ? b.focusHistoryID : 9999
      return fa - fb
    })
    var labels = []
    var counts = {}
    for (var m = 0; m < wins.length; m++) {
      var w = wins[m]
      var info = w.pid > 0 ? infoMap[String(w.pid)] : null
      var base = String(w.title || items[k].key || "")
      if (info) {
        var parts = []
        if (info.prog) parts.push(info.prog)
        if (info.cwd) parts.push(info.cwd)
        if (info.hint) parts.push(info.hint)
        var sub = parts.join(" · ")
        if (sub && base.toLowerCase() === "foot") base = sub
        else if (sub) base = base + " — " + sub
      }
      labels.push(base)
      counts[base] = (counts[base] || 0) + 1
    }
    var seen = {}
    for (var n = 0; n < wins.length; n++) {
      var lbl = labels[n]
      if (counts[lbl] > 1) {
        seen[lbl] = (seen[lbl] || 0) + 1
        wins[n].displayTitle = lbl.length > 20
          ? ("#" + seen[lbl] + " · " + lbl)
          : (lbl + " #" + seen[lbl])
      } else {
        wins[n].displayTitle = lbl
      }
    }
  }

  return items
}

// Puts the items in the dock's own order, which the dock keeps for the
// session: an app keeps its slot while it stays in the dock, and an app that
// joins goes at the end. Items the order does not know yet follow in the order
// buildItems gave them.
function orderItems(items, order) {
  var byKey = {}
  for (var i = 0; i < (items || []).length; i++) byKey[items[i].key] = items[i]
  var result = []
  var placed = {}
  for (var j = 0; j < (order || []).length; j++) {
    var key = order[j]
    if (byKey[key] && !placed[key]) {
      result.push(byKey[key])
      placed[key] = true
    }
  }
  for (var k = 0; k < (items || []).length; k++) {
    if (!placed[items[k].key]) result.push(items[k])
  }
  return result
}

// The order with key moved to index, counted once key has left its old slot.
function orderWithKeyAt(order, key, index) {
  var keys = (order || []).filter(function(other) { return other !== key })
  keys.splice(Math.max(0, Math.min(keys.length, index)), 0, key)
  return keys
}

// Where a dragged icon lands: its own slot moved by however many slots the
// pointer has travelled, kept within the dock.
function dropIndex(fromIndex, offset, slotSize, count) {
  if (count <= 0 || !(slotSize > 0)) return fromIndex
  var target = fromIndex + Math.round(offset / slotSize)
  return Math.max(0, Math.min(count - 1, target))
}

// The pins to save for the dock's order: the pinned apps in that order, then
// pins the dock is not showing, because their app is not installed, as they
// were. pinned holds the pinned desktop ids as keys.
function pinsInOrder(order, pinned, allPinned) {
  var result = (order || []).filter(function(key) { return pinned[key] === true })
  for (var i = 0; i < (allPinned || []).length; i++) {
    if (result.indexOf(allPinned[i]) === -1 && (order || []).indexOf(allPinned[i]) === -1) result.push(allPinned[i])
  }
  return result
}

// The window a click on an app brings forward. Windows on the workspace in
// front of the user come first, then minimized ones, which come back to it,
// and only then those on other workspaces. Clicking again while one of them
// is focused moves on to the next in a stable order independent of focus MRU.
// Windows are { workspaceId, minimized, activated, address? }.
function pickWindow(windows, workspaceId) {
  var list = windows || []
  if (list.length === 0) return -1

  function rank(window) {
    if (window.minimized) return 1
    return window.workspaceId === workspaceId ? 0 : 2
  }

  var order = list.map(function(window, index) { return index })
  order.sort(function(a, b) {
    var dr = rank(list[a]) - rank(list[b])
    if (dr !== 0) return dr
    var aa = normalizeAddress(list[a].address).toLowerCase()
    var ab = normalizeAddress(list[b].address).toLowerCase()
    if (aa && ab && aa !== ab) return aa < ab ? -1 : 1
    return a - b
  })

  for (var i = 0; i < order.length; i++) {
    if (list[order[i]].activated) return order[(i + 1) % order.length]
  }
  return order[0]
}


// The window a click on the app brings forward, or -1 to launch it instead.
// The mode is the app's X-Omarchy-Dock-Click: "new" launches, since each
// window is wanted fresh, and "workspace" brings back a window only from the
// workspace in front of the user, since one elsewhere was opened for other
// work. Either way a minimized window comes back first, since the dock is
// the only way back to it. Any other mode picks among all the app's windows.
function pickClickWindow(mode, windows, workspaceId) {
  var list = windows || []
  if (mode !== "new" && mode !== "workspace") return pickWindow(list, workspaceId)

  var candidates = []
  for (var i = 0; i < list.length; i++) {
    if (list[i].minimized || (mode === "workspace" && list[i].workspaceId === workspaceId)) candidates.push(i)
  }
  var picked = pickWindow(candidates.map(function(index) { return list[index] }), workspaceId)
  return picked < 0 ? -1 : candidates[picked]
}

if (typeof module !== "undefined") {
  module.exports = {
    normalizePosition: normalizePosition,
    isVertical: isVertical,
    normalizeId: normalizeId,
    normalizeAddress: normalizeAddress,
    pinnedIds: pinnedIds,
    isDockWindow: isDockWindow,
    isMinimizedWorkspace: isMinimizedWorkspace,
    minimizedOriginWorkspace: minimizedOriginWorkspace,
    slotOf: slotOf,
    itemStats: itemStats,
    representativeDots: representativeDots,
    extractChromeWebappHost: extractChromeWebappHost,
    claimingEntryId: claimingEntryId,
    standInKey: standInKey,
    buildItems: buildItems,
    orderItems: orderItems,
    orderWithKeyAt: orderWithKeyAt,
    dropIndex: dropIndex,
    pinsInOrder: pinsInOrder,
    pickWindow: pickWindow,
    pickClickWindow: pickClickWindow
  }
}
