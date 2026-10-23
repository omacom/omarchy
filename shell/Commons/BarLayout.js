// Sections of the bar layout.
//
// left, centerBegin, center, centerEnd and right are the bar itself, as
// Util.barSections runs them. tray is drawn inside the tray's drawer. A
// drawer is a bar entry with "type": "drawer" and an id of its own; its
// widgets are a section too, named drawer:<id> and kept under
// layout.drawers[<id>]. Drawers sit on the bar itself, never inside the tray
// or another drawer, so only the bar's own sections can name one.

var BAR_SECTIONS = ["left", "centerBegin", "center", "centerEnd", "right"]
var BASE_SECTIONS = ["left", "centerBegin", "center", "centerEnd", "right", "tray"]
var DRAWER_PREFIX = "drawer:"

function isPlainObject(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value)
}

function entryId(entry) {
  if (typeof entry === "string") return entry
  if (isPlainObject(entry) && entry.id !== undefined && entry.id !== null) return String(entry.id)
  return ""
}

function validDrawerId(id) {
  return /^[A-Za-z0-9_.-]{1,64}$/.test(String(id || ""))
}

function isDrawerEntry(entry) {
  return isPlainObject(entry) && entry.type === "drawer" && validDrawerId(entryId(entry))
}

function drawerSection(id) {
  return validDrawerId(id) ? DRAWER_PREFIX + String(id) : ""
}

function drawerIdOf(section) {
  var name = String(section || "")
  if (name.indexOf(DRAWER_PREFIX) !== 0) return ""
  var id = name.slice(DRAWER_PREFIX.length)
  return validDrawerId(id) ? id : ""
}

// The sections drawn inside another widget: the tray's and every drawer's.
function isHostedSection(section) {
  return section === "tray" || drawerIdOf(section) !== ""
}

function isSectionName(section) {
  return BASE_SECTIONS.indexOf(String(section || "")) !== -1 || drawerIdOf(section) !== ""
}

// The ids of the drawers placed on the bar, in bar order, each once.
function drawerIds(layout) {
  var ids = []
  if (!isPlainObject(layout)) return ids
  for (var s = 0; s < BAR_SECTIONS.length; s++) {
    var entries = layout[BAR_SECTIONS[s]]
    if (!Array.isArray(entries)) continue
    for (var i = 0; i < entries.length; i++) {
      if (!isDrawerEntry(entries[i])) continue
      var id = entryId(entries[i])
      if (ids.indexOf(id) === -1) ids.push(id)
    }
  }
  return ids
}

// Every section a widget can be in: the fixed ones, then one per drawer
// on the bar. A drawers[] list whose drawer is gone is not a section: its
// widgets are not drawn and not counted as on the bar.
function sectionNames(layout) {
  var names = BASE_SECTIONS.slice()
  var ids = drawerIds(layout)
  for (var i = 0; i < ids.length; i++) names.push(DRAWER_PREFIX + ids[i])
  return names
}

// The entries of one section, or null when the layout has none.
function sectionEntries(layout, section) {
  if (!isPlainObject(layout)) return null
  var id = drawerIdOf(section)
  if (id) {
    var drawers = layout.drawers
    return isPlainObject(drawers) && Array.isArray(drawers[id]) ? drawers[id] : null
  }
  if (BASE_SECTIONS.indexOf(String(section || "")) === -1) return null
  return Array.isArray(layout[section]) ? layout[section] : null
}

// The entries of one section in a layout being edited, created when missing.
// Returns null for a name that is no section.
function ensureSection(layout, section) {
  if (!isPlainObject(layout)) return null
  var id = drawerIdOf(section)
  if (id) {
    if (!isPlainObject(layout.drawers)) layout.drawers = {}
    if (!Array.isArray(layout.drawers[id])) layout.drawers[id] = []
    return layout.drawers[id]
  }
  if (BASE_SECTIONS.indexOf(String(section || "")) === -1) return null
  if (!Array.isArray(layout[section])) layout[section] = []
  return layout[section]
}

// Every section's entries as one plain object keyed by section name.
function sections(layout) {
  var out = {}
  var names = sectionNames(layout)
  for (var i = 0; i < names.length; i++) {
    var entries = sectionEntries(layout, names[i])
    out[names[i]] = Array.isArray(entries) ? entries : []
  }
  return out
}

if (typeof module !== "undefined") {
  module.exports = {
    BAR_SECTIONS: BAR_SECTIONS,
    BASE_SECTIONS: BASE_SECTIONS,
    validDrawerId: validDrawerId,
    isDrawerEntry: isDrawerEntry,
    drawerSection: drawerSection,
    drawerIdOf: drawerIdOf,
    isHostedSection: isHostedSection,
    isSectionName: isSectionName,
    drawerIds: drawerIds,
    sectionNames: sectionNames,
    sectionEntries: sectionEntries,
    ensureSection: ensureSection,
    sections: sections
  }
}
