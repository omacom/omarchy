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

// A minimized window goes last, as minimizing sends it to the back on Windows:
// Alt + Tab right after minimizing goes to the window that was under it.
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

// The windows to list, most recently used first: every window with no owner,
// whatever workspace or monitor it is on. A dialog comes up with its owner
// rather than on its own. A window the order has not seen used since the
// shell started goes after those it has, in Hyprland's own focus history.
//
// windows: [{ address, parent, focusHistory }], parent the owner's address or
// empty, focusHistory Hyprland's focusHistoryID when known.
function orderWindows(order, windows) {
  var rank = rankOf(order)
  var listed = []
  for (var i = 0; i < (windows || []).length; i++) {
    var window = windows[i]
    if (!window || !normalizeAddress(window.address) || normalizeAddress(window.parent)) continue
    listed.push({ window: window, index: i, rank: rank[normalizeAddress(window.address)] })
  }

  listed.sort(function(left, right) {
    var leftKnown = left.rank !== undefined
    var rightKnown = right.rank !== undefined
    if (leftKnown !== rightKnown) return leftKnown ? -1 : 1
    if (leftKnown) return left.rank - right.rank
    var leftHistory = typeof left.window.focusHistory === "number" ? left.window.focusHistory : Infinity
    var rightHistory = typeof right.window.focusHistory === "number" ? right.window.focusHistory : Infinity
    if (leftHistory !== rightHistory) return leftHistory < rightHistory ? -1 : 1
    return left.index - right.index
  })

  return listed.map(function(entry) { return entry.window })
}

// The dialog to bring up with an owner: the one of its open dialogs used last,
// or null when it has none.
function dialogFor(order, windows, address) {
  var owner = normalizeAddress(address)
  var rank = rankOf(order)
  var best = null
  var bestRank = Infinity
  for (var i = 0; i < (windows || []).length; i++) {
    var window = windows[i]
    if (!window || normalizeAddress(window.parent) !== owner || !owner) continue
    var windowRank = rank[normalizeAddress(window.address)]
    if (windowRank === undefined) windowRank = Infinity
    if (!best || windowRank < bestRank) {
      best = window
      bestRank = windowRank
    }
  }
  return best
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
// thumbnails shrink until they do.
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

if (typeof module !== "undefined") {
  module.exports = {
    normalizeAddress: normalizeAddress,
    touch: touch,
    demote: demote,
    forget: forget,
    orderWindows: orderWindows,
    dialogFor: dialogFor,
    startIndex: startIndex,
    stepIndex: stepIndex,
    indexAfterRemoval: indexAfterRemoval,
    layout: layout,
    rowNeighbor: rowNeighbor
  }
}
