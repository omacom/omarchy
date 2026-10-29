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

// Where an icon goes, given whether it is on the hidden and pinned lists:
// "hidden", "pinned" or "drawer". Hidden wins over pinned, as the manager
// never leaves an icon on both lists. An icon on neither list goes to the
// drawer, or stays in the bar when the tray's `unlisted` setting is
// "visible"; any other value means the drawer.
function placement(isHidden, isPinned, unlisted) {
  if (isHidden) return "hidden"
  if (isPinned) return "pinned"
  return unlisted === "visible" ? "pinned" : "drawer"
}

// Whether the tray shows its chevron: while the drawer has something to open
// onto (app icons, widgets in the tray section, or the slot a widget drag
// offers), and while every icon is hidden, as the chevron is then the only
// way left into the manager.
function showsChevron(drawerCount, sectionCount, dragging, pinnedCount, allCount) {
  return drawerCount > 0 || sectionCount > 0 || dragging || (pinnedCount === 0 && allCount > 0)
}

// The entry a pin or hide writes back. The write replaces the whole entry,
// so it carries the tray's other settings, such as `unlisted`, along.
function trayEntry(settings, pinned, hidden) {
  var entry = {}
  for (var key in settings) entry[key] = settings[key]
  entry.pinned = pinned
  entry.hidden = hidden
  return entry
}

if (typeof module !== "undefined") {
  module.exports = {
    shownSpan: shownSpan,
    itemNamed: itemNamed,
    entryId: entryId,
    layoutHasWidget: layoutHasWidget,
    ownedByOmarchy: ownedByOmarchy,
    placement: placement,
    showsChevron: showsChevron,
    trayEntry: trayEntry
  }
}
