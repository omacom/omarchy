// Reach: one keyboard and mouse across your machines. This turns Reach's
// state file into the panel's state, and works out the new row when a machine
// is added, moved or taken out. The row runs left to right and holds this
// machine once anything else is in it.

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

// `$XDG_RUNTIME_DIR/reach.json`: this machine, the row, the machines Reach is
// connected to, and what Circle says about the rest, including which are close by.
function parseStatus(raw) {
  var data = parseJson(raw)
  var me = data ? text(data.me) : ""
  var status = { ok: false, me: "", screens: [], connected: [], circleUp: false, peers: [] }
  if (me === "") return status
  var circle = data.circle && typeof data.circle === "object" ? data.circle : {}
  status.ok = true
  status.me = me
  status.screens = names(data.screens)
  status.connected = names(data.connected)
  status.circleUp = circle.up === true
  status.peers = (Array.isArray(circle.peers) ? circle.peers.slice(0, MAX_ITEMS) : [])
    .filter(function(p) { return p && typeof p === "object" && text(p.name) !== "" })
    .map(function(p) { return { name: text(p.name), online: p.online === true, nearby: p.nearby === true } })
  return status
}

function names(list) {
  return (Array.isArray(list) ? list.slice(0, MAX_ITEMS) : [])
    .map(text)
    .filter(function(s) { return s !== "" })
}

// What `systemctl --user show --property=LoadState --property=ActiveState`
// says about reach.service: installed (a unit file loaded) and running.
function parseUnitState(text) {
  var props = {}
  String(text || "").split("\n").forEach(function(line) {
    var i = line.indexOf("=")
    if (i > 0) props[line.slice(0, i).trim()] = line.slice(i + 1).trim()
  })
  return { installed: props.LoadState === "loaded", running: props.ActiveState === "active" }
}

// How many of the Circle machines are close by.
function nearbyCount(peers) {
  var n = 0
  for (var i = 0; i < peers.length; i++) if (peers[i].nearby) n++
  return n
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
// for a machine Circle doesn't list; `connected` is whether Reach has it.
function tiles(screens, me, peers, connected) {
  var live = connected || []
  return ownRow(screens, me).map(function(name) {
    var self = sameHost(name, me)
    var peer = self ? null : findPeer(peers, name)
    return {
      name: name,
      self: self,
      online: self ? true : (peer ? peer.online : null),
      connected: self || indexOf(live, name) !== -1
    }
  })
}

// The Circle machines not in the row yet: close by first, then online, then by name.
function addable(screens, me, peers) {
  var row = ownRow(screens, me)
  return peers
    .filter(function(p) { return indexOf(row, p.name) === -1 && !sameHost(p.name, me) })
    .sort(function(a, b) {
      if (!!a.nearby !== !!b.nearby) return a.nearby ? -1 : 1
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
    parseStatus: parseStatus,
    parseUnitState: parseUnitState,
    nearbyCount: nearbyCount,
    tiles: tiles,
    addable: addable,
    moveTo: moveTo,
    place: place,
    nudge: nudge,
    remove: remove,
    dropIndex: dropIndex
  }
}
