function stripJsonc(raw) {
  return String(raw || "")
    .replace(/^\s*\/\/[^\n]*(\n|$)/gm, "")
    .replace(/,(\s*[}\]])/g, "$1")
}

function normalizeAliases(value) {
  if (Array.isArray(value)) return value.filter(function(v) { return v })
  if (typeof value === "string" && value) return [value]
  return []
}

function normalizeItem(id, raw) {
  var value = raw || {}
  var aliases = normalizeAliases(value.aliases)
  var parent = value.parent
  if (parent === undefined)
    parent = id.indexOf(".") >= 0 ? id.split(".").slice(0, -1).join(".") : "root"
  if (id === "root") parent = ""

  var kind = value.action ? "action" : (value.target ? "link" : "menu")

  return {
    id: id,
    parent: parent,
    kind: kind,
    icon: value.icon || "",
    iconFont: value.iconFont || "",
    label: value.label || id,
    title: value.title || "",
    target: value.target || "",
    description: value.description || "",
    action: value.action || "",
    provider: value.provider || "",
    aliases: aliases,
    when: value.when || "",
    checked: value.checked || "",
    disabled: value.disabled || ""
  }
}

function parseMenuJsonc(raw) {
  var stripped = stripJsonc(raw)
  if (!stripped.trim()) return []

  var parsed
  try {
    parsed = JSON.parse(stripped)
  } catch (e) {
    return []
  }
  if (typeof parsed !== "object" || parsed === null) return []

  var source = (parsed.items && typeof parsed.items === "object" && !Array.isArray(parsed.items))
    ? parsed.items
    : parsed
  var out = []
  for (var id in source) {
    var entry = source[id]
    if (!entry || typeof entry !== "object" || Array.isArray(entry)) continue
    out.push(normalizeItem(id, entry))
  }
  return out
}

function mergeMenuSources(defaultItems, userItems) {
  var nextItems = ({})
  var nextOrder = []
  var sources = [defaultItems || [], userItems || []]

  for (var s = 0; s < sources.length; s++) {
    var src = sources[s]
    for (var i = 0; i < src.length; i++) {
      var entry = src[i]
      if (!entry || !entry.id) continue
      if (!nextItems[entry.id]) nextOrder.push(entry.id)
      var prior = nextItems[entry.id] || {}
      var merged = {}
      for (var k in prior) merged[k] = prior[k]
      for (var k2 in entry) merged[k2] = entry[k2]
      merged.id = entry.id
      nextItems[entry.id] = merged
    }
  }

  if (!nextItems.root) {
    nextItems.root = { id: "root", parent: "", kind: "menu", icon: "", iconFont: "", label: "Go", title: "", target: "", description: "", aliases: [], when: "", checked: "", disabled: "", action: "", provider: "" }
    nextOrder.unshift("root")
  }
  for (var k3 = 0; k3 < nextOrder.length; k3++) nextItems[nextOrder[k3]].order = k3

  return {
    items: nextItems,
    itemOrder: nextOrder
  }
}

// Both merges below return fresh items/itemOrder objects for the caller to
// assign in one go. They must never write into the maps they are handed: those
// live in QML `var` properties, and an in-place write into such an object is
// occasionally dropped by the engine — the key lands with an undefined value.
// A lost write used to leave an id in itemOrder with no item behind it, and
// the next merge then kept that orphan and appended a second row for the same
// app, so the launcher listed it twice (and again on every later rescan).

// Swaps every app row for the current set. Rows keep the order they arrive in;
// ids already claimed (including duplicate desktop ids) are listed once.
function mergeAppRows(items, itemOrder, appRows) {
  var source = items || ({})
  var order = Array.isArray(itemOrder) ? itemOrder : []
  var rows = Array.isArray(appRows) ? appRows : []
  var nextItems = ({})
  var nextOrder = []

  for (var i = 0; i < order.length; i++) {
    var id = order[i]
    var existing = source[id]
    // Orphans (an id with no item) are dropped rather than carried forward,
    // so a single lost write cannot compound into a duplicate row.
    if (!existing || existing.kind === "app") continue
    nextItems[id] = existing
    nextOrder.push(id)
  }

  for (var j = 0; j < rows.length; j++) {
    var row = rows[j]
    if (!row || !row.id || nextItems[row.id]) continue
    row.order = nextOrder.length
    nextItems[row.id] = row
    nextOrder.push(row.id)
  }

  return { items: nextItems, itemOrder: nextOrder }
}

// Swaps the rows one provider contributed, leaving every other item untouched.
// Rows carry the id of the submenu that produced them, so a provider that runs
// again drops its previous batch — a plugin that was just enabled disappears
// from the Enable list — without disturbing static children declared in JSONC.
function swapProviderRows(items, itemOrder, menuId, rows) {
  var source = items || ({})
  var order = Array.isArray(itemOrder) ? itemOrder : []
  var incoming = Array.isArray(rows) ? rows : []
  var nextItems = ({})
  var nextOrder = []

  for (var i = 0; i < order.length; i++) {
    var id = order[i]
    var existing = source[id]
    if (!existing || existing.providerMenu === menuId) continue
    nextItems[id] = existing
    nextOrder.push(id)
  }

  for (var j = 0; j < incoming.length; j++) {
    var row = incoming[j]
    if (!row || !row.id || nextItems[row.id]) continue
    row.providerMenu = menuId
    row.order = nextOrder.length
    nextItems[row.id] = row
    nextOrder.push(row.id)
  }

  return { items: nextItems, itemOrder: nextOrder }
}

function item(items, id) {
  return items && items[id] ? items[id] : null
}

// Routes may name a real id (`system`, `setup.power`) or an alias declared in
// JSONC (`power-menu`, `settings`). An exact id beats any alias, and app rows
// are never routable: their aliases carry .desktop Keywords and GenericName
// for search, so an installed application could otherwise shadow a menu route
// (htop ships `Keywords=system;...`). Unknown strings fall through as the
// literal input so misspellings still attempt to open that id.
function resolveRoute(items, itemOrder, input) {
  var raw = String(input || "").toLowerCase().replace(/_/g, "-")
  if (!raw || raw === "go" || raw === "menu") return "root"
  if (item(items, raw)) return raw
  var order = Array.isArray(itemOrder) ? itemOrder : []
  for (var i = 0; i < order.length; i++) {
    var entry = item(items, order[i])
    if (!entry || entry.kind === "app" || !entry.aliases) continue
    for (var j = 0; j < entry.aliases.length; j++) {
      var alias = String(entry.aliases[j] || "").toLowerCase().replace(/_/g, "-")
      if (alias === raw) return entry.id
    }
  }
  return raw
}

function slugify(value) {
  return String(value || "").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "") || "item"
}

function depthFor(items, id) {
  var depth = 0
  var current = item(items, id)
  var guard = 0

  while (current && current.parent && current.parent !== "root" && guard < 32) {
    depth += 1
    current = item(items, current.parent)
    guard += 1
  }

  return depth
}

function pathFor(items, id) {
  var labels = []
  var current = item(items, id)
  var guard = 0

  while (current && current.id !== "root" && guard < 32) {
    labels.unshift(current.label)
    current = item(items, current.parent)
    guard += 1
  }

  return labels.join(" › ")
}

function parentPathFor(items, id) {
  var entry = item(items, id)
  if (!entry || !entry.parent || entry.parent === "root") return ""
  return pathFor(items, entry.parent)
}

function isDescendantOf(items, id, ancestorId) {
  if (ancestorId === "root") return id !== "root"

  var current = item(items, id)
  var guard = 0
  while (current && current.parent && guard < 32) {
    if (current.parent === ancestorId) return true
    current = item(items, current.parent)
    guard += 1
  }

  return false
}

function childCount(items, itemOrder, id) {
  var count = 0
  var order = Array.isArray(itemOrder) ? itemOrder : []
  for (var i = 0; i < order.length; i++) {
    var entry = item(items, order[i])
    if (entry && entry.parent === id) count += 1
  }
  return count
}

function isVisible(items, itemOrder, whenResults, entry, depth) {
  if (!entry) return false
  if (entry.when && whenResults && whenResults[entry.id] === false) return false
  if (entry.kind !== "menu" && entry.kind !== "link") return true
  if (entry.provider) return true

  var guard = depth || 0
  if (guard >= 32) return false

  var target = entry.kind === "link" ? entry.target : entry.id
  var order = Array.isArray(itemOrder) ? itemOrder : []
  for (var i = 0; i < order.length; i++) {
    var child = item(items, order[i])
    if (child && child.parent === target && isVisible(items, itemOrder, whenResults, child, guard + 1)) return true
  }

  return false
}

// A `disabled:` row stays listed but goes dim and unselectable. The
// Install submenus use it so software already on the machine reads as
// installed rather than disappearing from the list it was installed from.
function isDisabled(disabledResults, entry) {
  if (!entry || !entry.disabled) return false
  return !!(disabledResults && disabledResults[entry.id])
}

// A disabled row is software you already have, which is the same thing the ✓
// says everywhere else in the menu, so it earns the same marker.
function labelFor(entry, checkedResults, disabledResults) {
  if (!entry) return ""
  var marked = (entry.checked && checkedResults && checkedResults[entry.id]) || isDisabled(disabledResults, entry)
  return marked ? entry.label + " ✓" : entry.label
}

function searchableToken(value) {
  return String(value || "").replace(/[._-]+/g, " ")
}

function leafIdFor(id) {
  var parts = String(id || "").split(".")
  return parts.length > 0 ? parts[parts.length - 1] : id
}

function nameSearchText(entry) {
  if (!entry) return ""
  var aliases = []
  var values = Array.isArray(entry.aliases) ? entry.aliases : []
  for (var i = 0; i < values.length; i++) aliases.push(searchableToken(values[i]))
  return [entry.label, searchableToken(leafIdFor(entry.id)), aliases.join(" ")].join(" ").toLowerCase()
}

function termInSearchWords(term, text) {
  var words = String(text || "").toLowerCase().split(/\s+/)
  for (var i = 0; i < words.length; i++) {
    if (words[i] === term) return true
  }
  return false
}

function descriptionTextMatches(query, text) {
  var terms = String(query || "").toLowerCase().trim().split(/\s+/)
  for (var i = 0; i < terms.length; i++) {
    if (terms[i] && !termInSearchWords(terms[i], text)) return false
  }
  return true
}

function matchesQuery(entry, query, visible) {
  if (!entry || entry.id === "root") return false
  if (!visible) return false

  var nameText = nameSearchText(entry)
  var descriptionText = String(entry.description || "").toLowerCase()
  var terms = String(query || "").toLowerCase().trim().split(/\s+/)

  for (var i = 0; i < terms.length; i++) {
    if (!terms[i]) continue
    if (nameText.indexOf(terms[i]) >= 0) continue
    if (termInSearchWords(terms[i], descriptionText)) continue
    return false
  }

  return true
}

function searchScore(items, entry, query) {
  var needle = String(query || "").toLowerCase().trim()
  var label = entry.label.toLowerCase()
  var nameText = nameSearchText(entry)
  var descriptionText = String(entry.description || "").toLowerCase()
  var score = 80

  if (label === needle) score = entry.parent === "root" ? 2 : 0
  // An installed app whose name contains the query as a whole word ("zen"
  // for Zen Browser) beats exact-labeled menu entries like Install > Zen.
  else if (entry.kind === "app" && label.split(/\s+/).indexOf(needle) >= 0) score = 0
  else if (label.indexOf(needle) === 0) score = 10
  else if (label.indexOf(needle) >= 0) score = 30
  else if (nameText.indexOf(needle) >= 0) score = 40
  else if (descriptionTextMatches(needle, descriptionText)) score = 60

  if (entry.kind === "menu" || entry.kind === "link") score -= 2
  // App rows sort after all menu items, so they lose the tiebreak below to an
  // equal match. Outrank those, but stay inside the tier so better ones win.
  if (entry.kind === "app") score -= 5

  return score * 1000 + depthFor(items, entry.id) * 25 + entry.order
}

function displayRow(items, itemOrder, checkedResults, disabledResults, entry, detail, score, section) {
  var target = entry.kind === "link" ? entry.target : entry.id
  return {
    itemId: entry.id,
    disabled: isDisabled(disabledResults, entry),
    kind: entry.kind,
    icon: entry.icon,
    iconFont: entry.iconFont || "",
    appIcon: entry.appIcon || "",
    appId: entry.appId || "",
    label: labelFor(entry, checkedResults, disabledResults),
    target: target,
    detail: detail || "",
    path: pathFor(items, entry.id),
    childCount: (entry.kind === "menu" || entry.kind === "link") ? childCount(items, itemOrder, target) : 0,
    action: entry.action || "",
    provider: entry.provider || "",
    score: score || 0,
    section: section || ""
  }
}

// ------------------------------------------------------- keybinding chords
//
// The keybindings guide reads both directions: typed words find a shortcut,
// and a shortcut pressed physically finds its description. Both sides have to
// agree on one spelling of a chord, so everything below reduces to the same
// canonical string -- modifiers in the order `omarchy-menu-keybindings` prints
// them, then the key:
//
//   SUPER+SHIFT+F
//   CTRL+ALT+DELETE
//   PRINT
//
// Qt's enum values are written out rather than read off the `Qt` namespace:
// this file is plain JavaScript that Node loads directly in the shell tests,
// where no Qt exists.
var CHORD_MOD_SHIFT = 0x02000000
var CHORD_MOD_CONTROL = 0x04000000
var CHORD_MOD_ALT = 0x08000000
var CHORD_MOD_META = 0x10000000
var CHORD_MOD_KEYPAD = 0x20000000
var CHORD_MOD_GROUP_SWITCH = 0x40000000
var CHORD_KNOWN_MODIFIERS = CHORD_MOD_SHIFT | CHORD_MOD_CONTROL | CHORD_MOD_ALT
  | CHORD_MOD_META | CHORD_MOD_KEYPAD | CHORD_MOD_GROUP_SWITCH

// The order `modmask_to_text` in `bin/omarchy-menu-keybindings` emits, so a
// captured chord and a rendered row sort their modifiers alike.
var CHORD_MOD_ORDER = ["SUPER", "SHIFT", "CTRL", "ALT"]

// A modifier held down is not a chord on its own. AltGr arrives as its own
// keysym on some stacks and as Ctrl+Alt on others, so it never names a key.
var CHORD_MODIFIER_KEYS = {
  0x01000020: true, // Shift
  0x01000021: true, // Control
  0x01000022: true, // Meta
  0x01000023: true, // Alt
  0x01000024: true, // CapsLock
  0x01000025: true, // NumLock
  0x01000026: true, // ScrollLock
  0x01001103: true  // AltGr
}

// Keys whose Omarchy spelling is not simply the character they type. The
// names on the right are what `hyprctl binds` reports and the guide renders,
// including `~` for the key Hyprland calls grave.
var CHORD_KEY_NAMES = {
  0x20: "SPACE",
  0x2c: "COMMA",
  0x2d: "MINUS",
  0x2e: "PERIOD",
  0x2f: "SLASH",
  0x3b: "SEMICOLON",
  0x3d: "EQUAL",
  0x5b: "BRACKETLEFT",
  0x5c: "BACKSLASH",
  0x5d: "BRACKETRIGHT",
  0x60: "~",
  0x27: "APOSTROPHE",
  0x01000000: "ESCAPE",
  0x01000001: "TAB",
  0x01000002: "TAB",
  0x01000003: "BACKSPACE",
  0x01000004: "RETURN",
  0x01000005: "RETURN",
  0x01000006: "INSERT",
  0x01000007: "DELETE",
  0x01000009: "PRINT",
  0x01000010: "HOME",
  0x01000011: "END",
  0x01000012: "LEFT",
  0x01000013: "UP",
  0x01000014: "RIGHT",
  0x01000015: "DOWN",
  0x01000016: "PRIOR",
  0x01000017: "NEXT"
}

// XKB keycodes Hyprland uses for `code:N` binds and that Qt reports as
// `nativeScanCode`. When Shift is held Qt often emits Key_Exclam instead of
// Key_1; the scan code is what still names the physical key.
var CHORD_SCAN_KEY_NAMES = {
  10: "1", 11: "2", 12: "3", 13: "4", 14: "5",
  15: "6", 16: "7", 17: "8", 18: "9", 19: "0",
  20: "MINUS", 21: "EQUAL",
  24: "Q", 25: "W", 26: "E", 27: "R", 28: "T",
  29: "Y", 30: "U", 31: "I", 32: "O", 33: "P",
  67: "F1", 68: "F2", 69: "F3", 70: "F4", 71: "F5", 72: "F6",
  73: "F7", 74: "F8", 75: "F9", 76: "F10", 77: "F11", 78: "F12"
}

// Keys that mean a chord with no modifier at all, because they carry no text
// and the guide has nothing else to do with them. Deliberately an allowlist:
// arrows, Enter, Tab, Backspace, Delete and the paging keys steer the menu and
// must keep doing that.
function chordStandsAlone(key) {
  if (key === 0x01000009) return true                    // Print
  if (key >= 0x01000030 && key <= 0x0100003b) return true // F1..F12
  return false
}

function chordStandsAloneScan(nativeScanCode) {
  var scan = Number(nativeScanCode) || 0
  return scan >= 67 && scan <= 78
}

// The name the guide would print for a Qt key, or "" when this file cannot
// say. An unknown key reports no match rather than being mapped to a
// neighbouring row: naming the wrong action is worse than naming none.
function chordKeyName(key) {
  var code = Number(key)

  if (CHORD_MODIFIER_KEYS[code]) return ""
  if (CHORD_KEY_NAMES[code]) return CHORD_KEY_NAMES[code]
  if (code >= 0x30 && code <= 0x39) return String.fromCharCode(code) // 0..9
  if (code >= 0x41 && code <= 0x5a) return String.fromCharCode(code) // A..Z
  if (code >= 0x01000030 && code <= 0x0100003b) return "F" + (code - 0x01000030 + 1)

  return ""
}

function chordKeyNameFromScan(nativeScanCode) {
  var scan = Number(nativeScanCode) || 0
  return CHORD_SCAN_KEY_NAMES[scan] || ""
}

// Canonical spelling for a modifier list plus a key, whatever order the
// modifiers arrived in.
function normalizeChord(modifiers, key) {
  var held = {}
  var list = Array.isArray(modifiers) ? modifiers : []

  for (var i = 0; i < list.length; i++) {
    var name = String(list[i] || "").trim().toUpperCase()
    if (name === "CONTROL") name = "CTRL"
    if (name === "WIN" || name === "META" || name === "MOD") name = "SUPER"
    if (CHORD_MOD_ORDER.indexOf(name) < 0) return ""
    held[name] = true
  }

  var parts = []
  for (var m = 0; m < CHORD_MOD_ORDER.length; m++) {
    if (held[CHORD_MOD_ORDER[m]]) parts.push(CHORD_MOD_ORDER[m])
  }

  var keyName = String(key || "").trim().toUpperCase()
  if (!keyName) return ""
  parts.push(keyName)

  return parts.join("+")
}

// Canonical spelling for a physical key press. Returns "" when the key is a
// modifier on its own or one this file cannot name. Prefer the scan code when
// Super/Ctrl/Alt is held (or for bare F-keys) so Shift+digit and Fn-layer
// F-keys still match Hyprland's code:N / Fn rows.
function normalizeChordFromEvent(key, modifiers, nativeScanCode) {
  var mask = Number(modifiers) || 0
  if (mask & ~CHORD_KNOWN_MODIFIERS) return ""
  if (mask & (CHORD_MOD_KEYPAD | CHORD_MOD_GROUP_SWITCH)) return ""

  var keyName = chordKeyName(key)
  var scanName = chordKeyNameFromScan(nativeScanCode)
  var useScan = !!(mask & (CHORD_MOD_META | CHORD_MOD_CONTROL | CHORD_MOD_ALT))
    || chordStandsAlone(Number(key))
    || chordStandsAloneScan(nativeScanCode)
  if (useScan && scanName) keyName = scanName
  if (!keyName) return ""

  var held = []
  if (mask & CHORD_MOD_META) held.push("SUPER")
  if (mask & CHORD_MOD_SHIFT) held.push("SHIFT")
  if (mask & CHORD_MOD_CONTROL) held.push("CTRL")
  if (mask & CHORD_MOD_ALT) held.push("ALT")

  return normalizeChord(held, keyName)
}

// Whether a key press is asking "what does this shortcut do?" rather than
// typing into the filter.
//
// Shift plus a printable key is text, or capitals could not be searched for.
// Bare Escape is never a chord: it is the way out of an inhibited keyboard.
// SUPER+ESCAPE (and other modified Escapes) remain inspectable chords.
function printableEventText(text) {
  var value = String(text || "")
  return value.length === 1 && value.charCodeAt(0) >= 32 && value.charCodeAt(0) !== 127
}

function isMenuControlKey(key) {
  return key === 0x01000000 || // Escape
    key === 0x01000001 ||      // Tab
    key === 0x01000003 ||      // Backspace
    key === 0x01000004 ||      // Return
    key === 0x01000005 ||      // Enter
    key === 0x01000007 ||      // Delete
    (key >= 0x01000010 && key <= 0x01000017) // Home..PageDown
}

// Classify before QML decides which path may consume the event. Unsupported
// means the press is swallowed without updating the chord UI; QML treats it as
// a silent no-op rather than a sticky banner. Bare Escape stays the way out of
// an inhibited keyboard; Escape with Super/Ctrl/Alt is a chord (e.g. SUPER+ESCAPE).
function classifyKeyEvent(key, modifiers, text, autoRepeat, nativeScanCode) {
  var code = Number(key)
  var mask = Number(modifiers) || 0
  if (autoRepeat) return "repeat"
  if (CHORD_MODIFIER_KEYS[code]) return "modifier"
  if (code === 0x01000000
      && !(mask & (CHORD_MOD_META | CHORD_MOD_CONTROL | CHORD_MOD_ALT)))
    return "control"
  if (mask & ~CHORD_KNOWN_MODIFIERS) return "unsupported"

  // Shift-only printable input is search text. Group-switch/AltGr is text too;
  // Qt stacks that expose AltGr only as Ctrl+Alt still provide translated text.
  if (printableEventText(text)
      && (!(mask & (CHORD_MOD_META | CHORD_MOD_CONTROL | CHORD_MOD_ALT))
          || (!(mask & CHORD_MOD_META) && (mask & CHORD_MOD_GROUP_SWITCH))
          || (!(mask & CHORD_MOD_META)
            && (mask & (CHORD_MOD_CONTROL | CHORD_MOD_ALT)) === (CHORD_MOD_CONTROL | CHORD_MOD_ALT))))
    return "text"

  if (mask & (CHORD_MOD_KEYPAD | CHORD_MOD_GROUP_SWITCH)) return "unsupported"

  var asksForChord = !!(mask & (CHORD_MOD_META | CHORD_MOD_CONTROL | CHORD_MOD_ALT))
    || ((mask & CHORD_MOD_SHIFT) && code === 0x01000002)
    || chordStandsAlone(code)
    || chordStandsAloneScan(nativeScanCode)
  if (!asksForChord)
    return isMenuControlKey(code) ? "control" : (code >= 0x01000000 ? "unsupported" : "control")

  return normalizeChordFromEvent(code, mask, nativeScanCode) ? "chord" : "unsupported"
}

function isChordEvent(key, modifiers, text, nativeScanCode) {
  return classifyKeyEvent(key, modifiers, text, false, nativeScanCode) === "chord"
}

// Structured records travel beside display strings. Formatting can now change
// without changing lookup semantics, and excluded rows remain text-searchable.
function findRowsForChord(options, chord) {
  var wanted = String(chord || "")
  var matches = []
  var unsupported = false
  var reasons = []
  if (!wanted) return { matches: matches, unsupported: false, reasons: reasons }

  var list = Array.isArray(options) ? options : []
  for (var i = 0; i < list.length; i++) {
    var option = list[i] || {}
    var chords = Array.isArray(option.chords) ? option.chords : []
    for (var c = 0; c < chords.length; c++) {
      if (String(chords[c]) !== wanted) continue
      if (option.inspectable === true) {
        matches.push(i)
      } else {
        unsupported = true
        var reason = String(option.reason || "")
        if (reason && reasons.indexOf(reason) < 0) reasons.push(reason)
      }
      break
    }
  }

  return { matches: matches, unsupported: unsupported, reasons: reasons }
}

// A canonical chord written the way the guide prints it, for the header line
// that reports what was pressed.
function formatChord(chord) {
  var parts = String(chord || "").split("+")
  if (parts.length < 2) return parts[0] || ""

  var key = parts[parts.length - 1]
  return parts.slice(0, parts.length - 1).join(" ") + " + " + key
}

// Commands a `checked:` expression reads a value out of. Every sibling row
// asks the same one -- Defaults > Browser has seven rows all comparing
// against `omarchy-default-browser` -- so the batch runs it once and the rows
// read the captured answer.
//
// The capture has to be eager. These are read inside `$(...)`, and a value
// cached while one expression runs lives in that subshell only, so a lazy
// memo never survives to the expression after it.
var GUARD_READERS = [
  "omarchy-channel-current",
  "omarchy-default-agent",
  "omarchy-default-browser",
  "omarchy-default-editor",
  "omarchy-default-terminal",
  "omarchy-dns"
]

// Package and command presence account for most of what the guards ask, and
// asked one at a time they are almost all fork: the shipped menu spends over
// a second on them. Answer them inside the guard process instead. These
// shadow the real commands for the batch only, so they have to agree with
// them everywhere, including for no arguments at all (present is true of
// nothing, missing is not).
//
// `pacman -Q` resolves a name through what installed packages provide, not
// just what they are called -- with gvim installed it reports `vim` as
// present -- so the set has to carry provides too, or `install.editor.vim`
// comes back and offers to install what is already there. A version
// constraint (`bash>=1`) is not a name any set can answer, so it goes to
// pacman itself; no shipped guard writes one.
//
// `pacman -Qi` wraps a long list across continuation lines whenever COLUMNS
// is set in the environment, which a login shell may well have done, so the
// parser follows the indented lines rather than reading the first one and
// dropping half of what is installed.
function guardHelpers() {
  return 'declare -A __omarchy_pkgs=()\n'
    + 'mapfile -t __omarchy_pkg_names < <({ pacman -Qq; LC_ALL=C pacman -Qi'
    + " | awk '/^[A-Za-z]/ { provides = ($0 ~ /^Provides/); sub(/^[^:]*: /, \"\") }"
    + ' provides && $0 != "None" { n = split($0, p, " ");'
    + ' for (i = 1; i <= n; i++) { sub(/[<>=].*/, "", p[i]); print p[i] } }\'; } 2>/dev/null)\n'
    + 'for __omarchy_pkg in "${__omarchy_pkg_names[@]}"; do __omarchy_pkgs[$__omarchy_pkg]=1; done\n'
    + '__omarchy_pkg_has() { [[ -n ${__omarchy_pkgs[$1]-} ]] && return 0; '
    + '[[ $1 == *[\\<\\>=]* ]] && { pacman -Q "$1" &>/dev/null; return; }; return 1; }\n'
    + 'omarchy-pkg-present() { local p; for p in "$@"; do __omarchy_pkg_has "$p" || return 1; done; return 0; }\n'
    + 'omarchy-pkg-missing() { local p; for p in "$@"; do __omarchy_pkg_has "$p" || return 0; done; return 1; }\n'
    + 'omarchy-cmd-present() { local c; for c in "$@"; do command -v "$c" &>/dev/null || return 1; done; return 0; }\n'
    + 'omarchy-cmd-missing() { local c; for c in "$@"; do command -v "$c" &>/dev/null || return 0; done; return 1; }\n'
}

// Substitute the captured answer into the expression rather than shadowing
// the reader with a function. `$(reader)` and the variable holding what it
// printed are interchangeable -- both strip trailing newlines, both split the
// same way unquoted -- while a function would also catch `command -v reader`,
// `VAR=x reader`, and every other form, and answer those wrong. Anything but
// the plain substitution is left alone to run the real command.
function guardPrelude(guards) {
  var prelude = guardHelpers()

  for (var i = 0; i < GUARD_READERS.length; i++) {
    // The guards arrive already substituted, so what marks a reader as wanted
    // is the slot standing in for it, not the call it replaced.
    if (guards.indexOf(guardReaderSlot(i)) < 0) continue
    // `|| :` so a reader that exits nonzero cannot take the batch down with
    // it under a login shell that turned on errexit.
    prelude += "__omarchy_read_" + i + "=$(" + GUARD_READERS[i] + " 2>/dev/null) || :\n"
  }

  return prelude
}

function guardReaderSlot(index) {
  return "${__omarchy_read_" + index + "}"
}

function substituteGuardReaders(expression) {
  for (var i = 0; i < GUARD_READERS.length; i++)
    expression = expression.split("$(" + GUARD_READERS[i] + ")").join(guardReaderSlot(i))

  return expression
}

function guardLine(id, tag, expression) {
  return "if { " + substituteGuardReaders(expression) + "; } >/dev/null 2>&1; then echo "
    + id + ":" + tag + ":1; else echo " + id + ":" + tag + ":0; fi\n"
}

// One bash script for every `when:`, `checked:` and `disabled:` in the menu,
// reporting `<id>:<w|c|d>:<0|1>` per line. Speed is the whole point: the menu
// opens on the last evaluation's answers, so however long this takes is how
// long a row can contradict the state it describes.
function guardScript(items) {
  var guards = ""
  var ids = Object.keys(items || {})

  for (var i = 0; i < ids.length; i++) {
    var entry = items[ids[i]]
    if (!entry) continue
    if (entry.when) guards += guardLine(ids[i], "w", entry.when)
    if (entry.checked) guards += guardLine(ids[i], "c", entry.checked)
    if (entry.disabled) guards += guardLine(ids[i], "d", entry.disabled)
  }

  return guards ? guardPrelude(guards) + guards : ""
}

if (typeof module !== "undefined") {
  module.exports = {
    guardReaders: GUARD_READERS,
    guardScript: guardScript,
    stripJsonc: stripJsonc,
    normalizeAliases: normalizeAliases,
    normalizeItem: normalizeItem,
    parseMenuJsonc: parseMenuJsonc,
    mergeMenuSources: mergeMenuSources,
    mergeAppRows: mergeAppRows,
    swapProviderRows: swapProviderRows,
    item: item,
    resolveRoute: resolveRoute,
    slugify: slugify,
    depthFor: depthFor,
    pathFor: pathFor,
    parentPathFor: parentPathFor,
    isDescendantOf: isDescendantOf,
    childCount: childCount,
    isVisible: isVisible,
    isDisabled: isDisabled,
    labelFor: labelFor,
    searchableToken: searchableToken,
    leafIdFor: leafIdFor,
    nameSearchText: nameSearchText,
    termInSearchWords: termInSearchWords,
    descriptionTextMatches: descriptionTextMatches,
    matchesQuery: matchesQuery,
    searchScore: searchScore,
    displayRow: displayRow,
    normalizeChord: normalizeChord,
    normalizeChordFromEvent: normalizeChordFromEvent,
    chordKeyNameFromScan: chordKeyNameFromScan,
    classifyKeyEvent: classifyKeyEvent,
    isChordEvent: isChordEvent,
    findRowsForChord: findRowsForChord,
    formatChord: formatChord
  }
}
