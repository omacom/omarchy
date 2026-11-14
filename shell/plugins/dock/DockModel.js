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

// A terminal app's window carries the app id its launcher gave the terminal,
// which no desktop entry names as its class. The entry that passes that app id
// claims it, and so does a terminal entry for the command Omarchy's TUI
// launcher named it after (org.omarchy.nvim for nvim). Entries are
// { id, execString, command, runInTerminal }.
function claimingEntryId(appId, entries) {
  var id = String(appId || "")
  if (!id) return ""
  var list = entries || []
  var flag = "--app-id=" + id
  for (var i = 0; i < list.length; i++) {
    var words = String(list[i].execString || "").split(/\s+/)
    if (words.indexOf(flag) >= 0) return list[i].id
  }
  if (id.indexOf("org.omarchy.") !== 0) return ""
  var command = id.slice("org.omarchy.".length)
  for (var j = 0; j < list.length; j++) {
    var program = String((list[j].command || [])[0] || "")
    if (list[j].runInTerminal && program.slice(program.lastIndexOf("/") + 1) === command) return list[j].id
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
function buildItems(pinned, windows) {
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
// is focused moves on to the next in that order. Windows are
// { workspaceId, minimized, activated }.
function pickWindow(windows, workspaceId) {
  var list = windows || []
  if (list.length === 0) return -1

  function rank(window) {
    if (window.minimized) return 1
    return window.workspaceId === workspaceId ? 0 : 2
  }

  var order = list.map(function(window, index) { return index })
  order.sort(function(a, b) { return rank(list[a]) - rank(list[b]) || a - b })

  for (var i = 0; i < order.length; i++) {
    if (list[order[i]].activated) return order[(i + 1) % order.length]
  }
  return order[0]
}

// An app with windows has a thin strip with as many segments as it has
// windows, up to this many.
var INDICATOR_SEGMENTS = 6

// The indicator's segments: "previewed", "focused", "open" or "minimized". Windows in
// front of the user in their order, then the minimized ones. An app with more
// windows than segments gives up plain open ones first, then minimized ones,
// so focused and previewed windows always keep their segments. Windows are
// { address, minimized, activated }; previewAddress identifies the preview
// independently of its position, including after minimized windows move last.
function indicatorSegments(windows, previewAddress) {
  var open = []
  var minimized = []
  var list = windows || []
  for (var i = 0; i < list.length; i++) {
    var previewed = previewAddress !== undefined && previewAddress !== null
      && previewAddress !== "" && String(list[i].address) === String(previewAddress)
    var kind = previewed ? "previewed" : list[i].minimized ? "minimized" : list[i].activated ? "focused" : "open"
    if (list[i].minimized) minimized.push(kind)
    else open.push(kind)
  }
  var segments = open.concat(minimized)
  var spare = ["open", "minimized", "focused"]
  for (var j = 0; j < spare.length; j++) {
    while (segments.length > INDICATOR_SEGMENTS) {
      var at = segments.lastIndexOf(spare[j])
      if (at < 0) break
      segments.splice(at, 1)
    }
  }
  return segments
}

// Keep saved or dragged preview sizes within the supported range.
function previewScale(value) {
  var scale = Number(value)
  if (!isFinite(scale) || !(scale > 0)) return 1
  return Math.max(0.45, Math.min(1.75, scale))
}

// Keep the previewed window across insertions, removals and reordering. If it
// disappears, choose its next neighbor, or the preceding one at the end.
function previewSelection(previous, selected, next) {
  var address = (previous || [])[selected]
  var index = next.indexOf(address)
  return index >= 0 ? index : Math.max(0, Math.min(selected, next.length - 1))
}

// The previews of an app's windows stand side by side in a strip of slanted
// slices, like the image picker's carousel: the selected one wide, the rest
// narrow and overlapping. The strip is as wide as it is for any selection, so
// moving the selection never moves what is under the pointer. options are the
// selected slice's width (expanded), a narrow slice's width (slice), the
// overlap between narrow slices (overlap), the most room there is (maxWidth)
// and the least a slice may advance (minStep).
function stripMetrics(count, options) {
  var o = options || {}
  var expanded = o.expanded > 0 ? o.expanded : 0
  var overlap = o.overlap > 0 ? o.overlap : 0
  var minStep = o.minStep > 0 ? o.minStep : 1
  var slice = o.slice > 0 ? o.slice : 0
  var step = slice - overlap
  var others = Math.max(0, count - 1)
  if (others > 0 && o.maxWidth > 0 && expanded + others * step > o.maxWidth) {
    step = Math.max(minStep, (o.maxWidth - expanded) / others)
    slice = step + overlap
    // Past the narrowest slices the selected one gives way too.
    if (expanded + others * step > o.maxWidth) expanded = Math.max(slice, o.maxWidth - others * step)
  }
  return { expanded: expanded, slice: slice, step: step, width: expanded + others * step }
}

// Where each slice stands for a selection, from the strip's left edge. A narrow
// slice is centered against the selected one.
function stripLayout(count, selected, options) {
  var o = options || {}
  var m = stripMetrics(count, o)
  var height = o.expandedHeight > 0 ? o.expandedHeight : 0
  var sliceHeight = o.sliceHeight > 0 ? o.sliceHeight : 0
  var current = Math.max(0, Math.min(count - 1, selected))
  var cards = []
  for (var i = 0; i < count; i++) {
    var chosen = i === current
    var x = i <= current ? i * m.step : current * m.step + m.expanded + (i - current - 1) * m.step + (m.step - m.slice)
    cards.push({
      x: x,
      y: chosen ? 0 : (height - sliceHeight) / 2,
      width: chosen ? m.expanded : m.slice,
      height: chosen ? height : sliceHeight,
      selected: chosen
    })
  }
  return { width: m.width, expanded: m.expanded, slice: m.slice, step: m.step, cards: cards }
}

// The slice at a point along the strip, as it stands for the current
// selection, or -1 off either end. Where slices overlap the one in front takes
// the point: the selected slice, then the ones nearer to it. A slice that is
// picked this way spans the point once it is selected, so asking again with the
// new selection gives the same slice.
function stripIndexAt(count, selected, x, options) {
  if (!(count > 0)) return -1
  var layout = stripLayout(count, selected, options)
  var current = Math.max(0, Math.min(count - 1, selected))
  var chosen = layout.cards[current]
  if (x >= chosen.x && x <= chosen.x + chosen.width) return current
  if (x < 0 || x > layout.width) return -1
  if (x < chosen.x) return Math.max(0, Math.min(current - 1, Math.floor(x / layout.step)))
  for (var i = current + 1; i < count; i++) {
    if (x <= layout.cards[i].x + layout.cards[i].width) return i
  }
  return count - 1
}

if (typeof module !== "undefined") {
  module.exports = {
    normalizePosition: normalizePosition,
    isVertical: isVertical,
    normalizeId: normalizeId,
    pinnedIds: pinnedIds,
    isDockWindow: isDockWindow,
    isMinimizedWorkspace: isMinimizedWorkspace,
    claimingEntryId: claimingEntryId,
    standInKey: standInKey,
    buildItems: buildItems,
    orderItems: orderItems,
    orderWithKeyAt: orderWithKeyAt,
    dropIndex: dropIndex,
    pinsInOrder: pinsInOrder,
    pickWindow: pickWindow,
    indicatorSegments: indicatorSegments,
    previewScale: previewScale,
    previewSelection: previewSelection,
    stripLayout: stripLayout,
    stripIndexAt: stripIndexAt
  }
}
