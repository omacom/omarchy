function text(value) {
  return String(value || "").toLowerCase()
}

function itemNamed(item, name) {
  if (!item) return false
  return text(item.id).indexOf(name) !== -1
    || text(item.title).indexOf(name) !== -1
    || text(item.tooltipTitle).indexOf(name) !== -1
}

function entryId(entry) {
  if (typeof entry === "string") return entry
  if (entry && typeof entry === "object") {
    var id = entry.id
    if (id !== undefined && id !== null && String(id) !== "") return String(id)
  }
  return ""
}

function layoutHasWidget(layout, id) {
  var sections = ["left", "centerBegin", "center", "centerEnd", "right", "tray"]
  for (var s = 0; s < sections.length; s++) {
    var entries = layout && layout[sections[s]]
    if (!Array.isArray(entries)) continue
    for (var i = 0; i < entries.length; i++) {
      if (entryId(entries[i]) === id) return true
    }
  }
  return false
}

// A bar widget that stands in for an app's tray item takes its place: the app's
// own icon would only show the same thing twice.
var widgetsForTrayItems = [
  { widget: "omarchy.dropbox", item: "dropbox" },
  { widget: "superwhisper.panel", item: "superwhisper" }
]

// LocalSend's item shows no state, offers only Open and Quit, and its primary
// click is a no-op, so Share > Receive is the whole surface. Hiding it by hand
// doesn't stick either: LocalSend picks a fresh tray id every launch.
function ownedByOmarchy(item, layout) {
  if (itemNamed(item, "localsend")) return true
  for (var i = 0; i < widgetsForTrayItems.length; i++) {
    var owner = widgetsForTrayItems[i]
    if (itemNamed(item, owner.item) && layoutHasWidget(layout, owner.widget)) return true
  }
  return false
}

// Whether a double-click's second click activates the item again. Wine turns
// two activates in quick succession into a double-click, which Windows apps
// like Battle.net need before they reopen, so Wine items (Ids "wine-...") get
// it. A native app that toggles its window on each activate, like qBittorrent,
// would open and hide again, so it gets one.
function activatesOnDoubleClick(item) {
  return !!item && !item.onlyMenu && String(item.id || "").indexOf("wine-") === 0
}

// The stretch of the tray section, from `start` and `length` long along the
// bar, that the drawer's clip, from `clipStart` and `clipLength` long, shows:
// { start, length }, or null while it shows none of it. An empty section
// shows once it is within a pixel of the clip's edge, as the drawer eases to
// rest.
function shownSpan(clipStart, clipLength, start, length) {
  var from = Math.max(start, clipStart)
  var to = Math.min(start + length, clipStart + clipLength)
  if (to < from) {
    if (from - to > 1) return null
    from = to
  }
  return { start: from, length: to - from }
}

// Electron apps often share one StatusNotifier id (chrome_status_icon_1). While an
// id is shared, pin and hide follow the icon's label so one icon does not claim
// the others. A unique id keeps the bare id as its key, so a changing title never
// loses the setting.
function itemLabel(item) {
  if (!item) return ""
  var title = String(item.title || "").replace(/[\r\n]/g, " ").trim()
  if (title) return title
  return String(item.tooltipTitle || "").replace(/[\r\n]/g, " ").trim()
}

function stateKey(item, shared) {
  var id = String(item && item.id || "")
  var label = itemLabel(item)
  if (!id) return label
  if (!shared || !label || label === id) return id
  return id + "\n" + label
}

// A stored key applies when it is this icon's key. A unique id also honors a
// labelled key saved while a sibling shared the id.
function keyMatches(k, item, shared) {
  var id = String(item && item.id || "")
  if (k === stateKey(item, shared)) return true
  var label = itemLabel(item)
  return !shared && !!id && !!label && k === id + "\n" + label
}

function appliesStored(keys, item, shared) {
  if (!Array.isArray(keys) || !item) return false
  return keys.some(function(k) { return keyMatches(k, item, shared) })
}

// Flips one icon's pin or hide. Only keys that belong to this icon change, so a
// sibling's saved setting survives; pinning also clears this icon from the other list.
function toggleStored(keys, others, item, shared) {
  var on = appliesStored(keys, item, shared)
  var mine = function(k) { return keyMatches(k, item, shared) }
  keys = keys.filter(function(k) { return !mine(k) })
  if (!on) {
    others = others.filter(function(k) { return !mine(k) })
    keys.push(stateKey(item, shared))
  }
  return { keys: keys, others: others }
}

if (typeof module !== "undefined") {
  module.exports = {
    shownSpan: shownSpan,
    itemNamed: itemNamed,
    entryId: entryId,
    layoutHasWidget: layoutHasWidget,
    ownedByOmarchy: ownedByOmarchy,
    itemLabel: itemLabel,
    stateKey: stateKey,
    appliesStored: appliesStored,
    toggleStored: toggleStored,
    activatesOnDoubleClick: activatesOnDoubleClick
  }
}
