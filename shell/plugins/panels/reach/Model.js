// Reach: one keyboard and mouse across your machines. This turns
// `reach status --json` and `circle status --json` into the panel's state,
// and works out the new row when a machine is added, moved or taken out.
// The row runs left to right and holds this machine once anything else is in it.

var MAX_ITEMS = 64
var MAX_TEXT = 255

function text(value) {
  var s = typeof value === "string" ? value : ""
  return s.length > MAX_TEXT ? s.substring(0, MAX_TEXT) : s
}

function shortName(name) {
  return String(name || "").split(".")[0].toLowerCase()
}

function sameHost(a, b) {
  return shortName(a) !== "" && shortName(a) === shortName(b)
}

function parseJson(raw) {
  try {
    var data = JSON.parse(String(raw || ""))
    return data && typeof data === "object" && !Array.isArray(data) ? data : null
  } catch (e) {
    return null
  }
}

// `reach status --json`: {"me": "...", "screens": [...], ...}.
function parseReach(raw) {
  var data = parseJson(raw)
  var me = data ? text(data.me) : ""
  if (me === "") return { ok: false, me: "", screens: [] }
  var screens = (Array.isArray(data.screens) ? data.screens.slice(0, MAX_ITEMS) : [])
    .map(text)
    .filter(function(s) { return s !== "" })
  return { ok: true, me: me, screens: screens }
}

// `circle status --json`: the other machines on Circle, by name, and whether
// each is online. Empty when Circle isn't there, signed in, or on.
function parseCircle(raw) {
  var data = parseJson(raw)
  if (!data || data.phase !== "running") return []
  var peers = Array.isArray(data.peers) ? data.peers.slice(0, MAX_ITEMS) : []
  return peers
    .filter(function(p) { return p && typeof p === "object" && text(p.name) !== "" })
    .map(function(p) { return { name: text(p.name), online: p.online === true } })
}

function indexOf(screens, name) {
  for (var i = 0; i < screens.length; i++) if (sameHost(screens[i], name)) return i
  return -1
}

function findPeer(peers, name) {
  for (var i = 0; i < peers.length; i++) if (sameHost(peers[i].name, name)) return peers[i]
  return null
}

// The row this machine sees: the arrangement if it's in it, otherwise just itself.
function ownRow(screens, me) {
  return indexOf(screens, me) === -1 ? [me] : screens.slice()
}

// One tile per machine in the row, left to right. `online` is unknown (null)
// for a machine Circle doesn't list.
function tiles(screens, me, peers) {
  return ownRow(screens, me).map(function(name) {
    var self = sameHost(name, me)
    var peer = self ? null : findPeer(peers, name)
    return { name: name, self: self, online: self ? true : (peer ? peer.online : null) }
  })
}

// The Circle machines not in the row yet: online ones first, then by name.
function addable(screens, me, peers) {
  var row = ownRow(screens, me)
  return peers
    .filter(function(p) { return indexOf(row, p.name) === -1 && !sameHost(p.name, me) })
    .sort(function(a, b) {
      if (a.online !== b.online) return a.online ? -1 : 1
      return a.name.localeCompare(b.name)
    })
}

// A row of just this machine is no row at all.
function finish(row) {
  return row.length < 2 ? [] : row
}

// Put `name` at `index` in the row (clamped), moving it if it's already in.
function moveTo(screens, me, name, index) {
  var row = ownRow(screens, me).filter(function(s) { return !sameHost(s, name) })
  var i = Math.max(0, Math.min(row.length, Math.round(index)))
  row.splice(i, 0, indexOf(screens, name) === -1 ? name : screens[indexOf(screens, name)])
  return finish(row)
}

// Add `name` at the far `side` ("left" or "right") of the row.
function place(screens, me, name, side) {
  var row = ownRow(screens, me)
  return moveTo(screens, me, name, side === "left" ? 0 : row.length)
}

// Move `name` one step toward `delta` (-1 left, 1 right).
function nudge(screens, me, name, delta) {
  var row = ownRow(screens, me)
  var i = indexOf(row, name)
  if (i === -1) return finish(row)
  return moveTo(screens, me, name, i + (delta < 0 ? -1 : 1))
}

// Take `name` out of the row. This machine can't be taken out of its own row.
function remove(screens, me, name) {
  if (sameHost(name, me)) return finish(ownRow(screens, me))
  return finish(ownRow(screens, me).filter(function(s) { return !sameHost(s, name) }))
}

// Where a tile dragged to `centerX` would land, given the tiles' current
// centers left to right, the dragged one (at `from`) included.
function dropIndex(centers, from, centerX) {
  var index = 0
  for (var i = 0; i < centers.length; i++) {
    if (i === from) continue
    if (centerX > centers[i]) index++
  }
  return index
}

if (typeof module !== "undefined") {
  module.exports = {
    parseReach: parseReach,
    parseCircle: parseCircle,
    tiles: tiles,
    addable: addable,
    moveTo: moveTo,
    place: place,
    nudge: nudge,
    remove: remove,
    dropIndex: dropIndex
  }
}
