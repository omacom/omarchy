// The window switcher's state that does not need Quickshell: the order windows
// were last used in, which window a press of Tab lands on, and where each
// window's thumbnail goes.

// Hyprland writes an address with 0x in some places and without in others.
function normalizeAddress(value) {
  var address = String(value || "").trim().toLowerCase()
  return address.indexOf("0x") === 0 ? address.slice(2) : address
}

function without(order, address) {
  var key = normalizeAddress(address)
  return (order || []).filter(function(existing) { return existing !== key })
}

// The window just focused goes first.
function touch(order, address) {
  var key = normalizeAddress(address)
  if (!key) return order || []
  return [key].concat(without(order, key))
}

// The window just minimized goes behind the others, so of the minimized
// windows, which orderWindows lists last, the one minimized last comes last.
function demote(order, address) {
  var key = normalizeAddress(address)
  if (!key) return order || []
  return without(order, key).concat([key])
}

function forget(order, address) {
  return without(order, address)
}

function rankOf(order) {
  var rank = {}
  for (var i = 0; i < (order || []).length; i++) rank[order[i]] = i
  return rank
}

// Omarchy's own helpers stay out of the switcher, as they do out of the dock:
// the Quake console, which Super + grave brings up, and the screensaver.
var HELPER_WORKSPACES = ["special:qconsole", "special:screensaver"]
var HELPER_APP_IDS = ["org.omarchy.screensaver"]

function isHelper(window) {
  return HELPER_WORKSPACES.indexOf(String(window.workspace || "")) >= 0
    || HELPER_APP_IDS.indexOf(String(window.appId || "")) >= 0
}

// Each window's owner, keyed by address, for the windows whose owner is open.
function parentsOf(windows) {
  var known = {}
  for (var i = 0; i < (windows || []).length; i++) {
    if (windows[i]) known[normalizeAddress(windows[i].address)] = true
  }
  var parents = {}
  for (var j = 0; j < (windows || []).length; j++) {
    var window = windows[j]
    if (!window) continue
    var parent = normalizeAddress(window.parent)
    if (parent && known[parent]) parents[normalizeAddress(window.address)] = parent
  }
  return parents
}

function chainIn(parents, address) {
  var chain = []
  var seen = {}
  var current = normalizeAddress(address)
  while (current && !seen[current]) {
    seen[current] = true
    chain.unshift(current)
    current = parents[current]
  }
  return chain
}

// The window and its owners, the topmost owner first.
function lineage(windows, address) {
  return chainIn(parentsOf(windows), address)
}

// The window a dialog belongs to, through any dialogs between: the window
// itself when it has no owner.
function ownerOf(windows, address) {
  return lineage(windows, address)[0] || ""
}

function historyOf(window) {
  return typeof window.focusHistory === "number" ? window.focusHistory : Infinity
}

// The windows to list, most recently used first: every window with no owner,
// whatever workspace or monitor it is on. A dialog comes up with its owner
// rather than on its own, and counts as its owner being used, so a window
// whose dialog was in front comes first. A window that was never put on screen
// is left out: Wine names hidden windows of its own, such as each game's
// "Default IME", and Hyprland reports them without ever showing them. A window
// the order has not seen used since the shell started goes after those it has,
// in Hyprland's own focus history. Minimized windows go last, as minimizing
// sends a window to the back on Windows, so Alt + Tab right after minimizing
// goes to the window that was under it.
//
// windows: [{ address, parent, shown, minimized, workspace, appId,
// focusHistory }], parent the owner's address or empty, shown false for a
// window never put on screen, workspace its workspace's name, focusHistory
// Hyprland's focusHistoryID when known.
function orderWindows(order, windows) {
  var rank = rankOf(order)
  var parents = parentsOf(windows)
  var groups = {}
  var listed = []
  for (var i = 0; i < (windows || []).length; i++) {
    var window = windows[i]
    var address = window ? normalizeAddress(window.address) : ""
    if (!address || parents[address] || window.shown === false || isHelper(window)) continue
    groups[address] = { window: window, index: i, rank: Infinity, history: Infinity }
    listed.push(groups[address])
  }

  for (var j = 0; j < (windows || []).length; j++) {
    var member = windows[j]
    if (!member || member.shown === false) continue
    var group = groups[chainIn(parents, member.address)[0]]
    if (!group) continue
    var memberRank = rank[normalizeAddress(member.address)]
    if (memberRank !== undefined) group.rank = Math.min(group.rank, memberRank)
    group.history = Math.min(group.history, historyOf(member))
  }

  listed.sort(function(left, right) {
    var leftMinimized = left.window.minimized === true
    var rightMinimized = right.window.minimized === true
    if (leftMinimized !== rightMinimized) return leftMinimized ? 1 : -1
    if (left.rank !== right.rank) return left.rank < right.rank ? -1 : 1
    if (left.history !== right.history) return left.history < right.history ? -1 : 1
    return left.index - right.index
  })

  return listed.map(function(entry) { return entry.window })
}

// The dialog to bring up with an owner, or null when it has none: the one of
// its dialogs used last, or else the one opened deepest, and then any dialog
// open on top of that one, as that is what it is waiting on.
function dialogFor(order, windows, address) {
  return deepestDialog(rankOf(order), windows, parentsOf(windows), normalizeAddress(address), {})
}

function deepestDialog(rank, windows, parents, top, seen) {
  if (!top || seen[top]) return null
  seen[top] = true

  var best = null
  var bestRank = Infinity
  var bestDepth = 0
  for (var i = 0; i < (windows || []).length; i++) {
    var window = windows[i]
    if (!window || window.shown === false) continue
    var chain = chainIn(parents, window.address)
    var at = chain.indexOf(top)
    var depth = chain.length - 1 - at
    if (at < 0 || depth <= 0) continue
    var windowRank = rank[normalizeAddress(window.address)]
    if (windowRank === undefined) windowRank = Infinity
    if (!best || windowRank < bestRank || (windowRank === bestRank && depth > bestDepth)) {
      best = window
      bestRank = windowRank
      bestDepth = depth
    }
  }

  if (!best) return null
  return deepestDialog(rank, windows, parents, normalizeAddress(best.address), seen) || best
}

// Where the first press lands. Tab goes to the window used before the one in
// front, so a quick Alt + Tab goes back and forth between two. With no window
// focused, such as on an empty workspace, it goes to the one used last.
// Shift + Tab starts from the other end.
function startIndex(count, delta, firstIsFocused) {
  if (count <= 0) return -1
  if (delta < 0) return count - 1
  return firstIsFocused && count > 1 ? 1 : 0
}

// The index in orderWindows(order, windows) the first press lands on, focused
// the window with the keyboard, or empty. A focused dialog counts as its owner,
// as the list holds the owner.
function firstPick(order, windows, focused, delta) {
  var entries = orderWindows(order, windows)
  var owner = focused ? ownerOf(windows, focused) : ""
  var firstIsFocused = entries.length > 0 && !!owner && normalizeAddress(entries[0].address) === owner
  return startIndex(entries.length, delta, firstIsFocused)
}

function stepIndex(index, count, delta) {
  if (count <= 0) return -1
  return ((index + delta) % count + count) % count
}

// The index left in place after a window leaves the list, keeping the same
// window selected when it is still there.
function indexAfterRemoval(selected, removed, count) {
  if (count <= 0) return -1
  if (removed < selected) return selected - 1
  return Math.min(selected, count - 1)
}

function clamp(value, low, high) {
  return Math.max(low, Math.min(high, value))
}

// Lay the thumbnails out in rows the way Windows does: every thumbnail the
// same height and as wide as its window is for that height, within limits,
// rows filled left to right and each centered. When the rows do not fit, the
// thumbnails shrink until they do, and when they still do not, the height
// stops at maxHeight and the rows scroll: contentHeight is all of them.
//
// aspects: each window's width over its height.
// options: maxWidth, maxHeight, thumbHeight, minThumbHeight, minAspect,
// maxAspect, gap (between items), padding (around a thumbnail in its item),
// header (the height of the title row above a thumbnail).
function layout(aspects, options) {
  var thumbHeight = Math.max(1, options.thumbHeight)
  var minThumbHeight = Math.max(1, Math.min(thumbHeight, options.minThumbHeight || thumbHeight))
  var result = rowsFor(aspects, thumbHeight, options)
  while (result.height > options.maxHeight && thumbHeight > minThumbHeight) {
    thumbHeight = Math.max(minThumbHeight, Math.floor(thumbHeight * 0.9))
    result = rowsFor(aspects, thumbHeight, options)
  }
  result.contentHeight = result.height
  result.height = Math.min(result.height, Math.max(0, options.maxHeight))
  return result
}

function rowsFor(aspects, height, options) {
  var count = (aspects || []).length
  var gap = options.gap || 0
  var padding = options.padding || 0
  var minAspect = options.minAspect || 0.5
  var maxAspect = options.maxAspect || 2.5
  var itemHeight = height + (options.header || 0) + padding * 2

  var widths = []
  for (var i = 0; i < count; i++) {
    var aspect = Number(aspects[i])
    if (!(aspect > 0) || !isFinite(aspect)) aspect = 16 / 9
    widths.push(Math.min(options.maxWidth, Math.round(clamp(aspect, minAspect, maxAspect) * height) + padding * 2))
  }

  var rows = []
  var row = []
  var rowWidth = 0
  for (var j = 0; j < count; j++) {
    var next = row.length === 0 ? widths[j] : rowWidth + gap + widths[j]
    if (row.length > 0 && next > options.maxWidth) {
      rows.push({ indices: row, width: rowWidth })
      row = []
      next = widths[j]
    }
    row.push(j)
    rowWidth = next
  }
  if (row.length > 0) rows.push({ indices: row, width: rowWidth })

  var width = 0
  for (var r = 0; r < rows.length; r++) width = Math.max(width, rows[r].width)

  var items = new Array(count)
  for (var k = 0; k < rows.length; k++) {
    var x = Math.round((width - rows[k].width) / 2)
    var y = k * (itemHeight + gap)
    for (var m = 0; m < rows[k].indices.length; m++) {
      var index = rows[k].indices[m]
      items[index] = { x: x, y: y, width: widths[index], height: itemHeight, row: k }
      x += widths[index] + gap
    }
  }

  return {
    width: width,
    height: rows.length > 0 ? rows.length * itemHeight + (rows.length - 1) * gap : 0,
    thumbHeight: height,
    rows: rows.map(function(entry) { return entry.indices }),
    items: items
  }
}

// Up and Down go to the thumbnail in the row above or below nearest across,
// and stay put at the first or last row.
function rowNeighbor(laidOut, index, delta) {
  var item = laidOut && laidOut.items ? laidOut.items[index] : null
  if (!item) return index
  var row = laidOut.rows[item.row + delta]
  if (!row) return index
  var center = item.x + item.width / 2
  var best = row[0]
  var bestDistance = Infinity
  for (var i = 0; i < row.length; i++) {
    var candidate = laidOut.items[row[i]]
    var distance = Math.abs(candidate.x + candidate.width / 2 - center)
    if (distance < bestDistance) {
      best = row[i]
      bestDistance = distance
    }
  }
  return best
}

// Where the rows scroll to, from contentY, to show the thumbnail at index
// whole. They move only as far as that takes.
function scrollFor(laidOut, index, contentY) {
  var item = laidOut && laidOut.items ? laidOut.items[index] : null
  var limit = laidOut ? Math.max(0, laidOut.contentHeight - laidOut.height) : 0
  var y = clamp(contentY || 0, 0, limit)
  if (!item) return y
  if (item.y < y) return item.y
  if (item.y + item.height > y + laidOut.height) return clamp(item.y + item.height - laidOut.height, 0, limit)
  return y
}

if (typeof module !== "undefined") {
  module.exports = {
    normalizeAddress: normalizeAddress,
    touch: touch,
    demote: demote,
    forget: forget,
    ownerOf: ownerOf,
    lineage: lineage,
    orderWindows: orderWindows,
    dialogFor: dialogFor,
    startIndex: startIndex,
    firstPick: firstPick,
    stepIndex: stepIndex,
    indexAfterRemoval: indexAfterRemoval,
    layout: layout,
    rowNeighbor: rowNeighbor,
    scrollFor: scrollFor
  }
}
