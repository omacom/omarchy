function text(value) {
  return String(value || "").toLowerCase()
}

function iconNeedsTint(icon) {
  var name = String(icon || "").split("?")[0]
  // Cloudflare's connected icon is solid white, but lacks the symbolic suffix.
  // Its other status icons use meaningful colors and must stay untouched.
  return name.slice(-9) === "-symbolic" || /(^|\/)zero-trust-connected$/.test(name)
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
  var sections = ["left", "center", "right"]
  for (var s = 0; s < sections.length; s++) {
    var entries = layout && layout[sections[s]]
    if (!Array.isArray(entries)) continue
    for (var i = 0; i < entries.length; i++) {
      if (entryId(entries[i]) === id) return true
    }
  }
  return false
}

// LocalSend's item shows no state, offers only Open and Quit, and its primary
// click is a no-op, so Share > Receive is the whole surface. Hiding it by hand
// doesn't stick either: LocalSend picks a fresh tray id every launch.
function ownedByOmarchy(item, layout) {
  return itemNamed(item, "localsend")
    || (layoutHasWidget(layout, "omarchy.dropbox") && itemNamed(item, "dropbox"))
}

if (typeof module !== "undefined") {
  module.exports = {
    iconNeedsTint: iconNeedsTint,
    itemNamed: itemNamed,
    entryId: entryId,
    layoutHasWidget: layoutHasWidget,
    ownedByOmarchy: ownedByOmarchy
  }
}
