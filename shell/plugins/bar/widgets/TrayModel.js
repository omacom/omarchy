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

if (typeof module !== "undefined") {
  module.exports = {
    shownSpan: shownSpan,
    itemNamed: itemNamed,
    entryId: entryId,
    layoutHasWidget: layoutHasWidget,
    ownedByOmarchy: ownedByOmarchy
  }
}
