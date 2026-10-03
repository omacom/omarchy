function isPlainObject(value) {
  return !!value && typeof value === "object" && !Array.isArray(value)
}

function normalizePosition(value) {
  var next = String(value || "").trim()
  return /^(top|bottom|left|right)$/.test(next) ? next : "top"
}

function entrySettings(entry) {
  if (!isPlainObject(entry)) return {}
  var copy = {}
  for (var key in entry) {
    if (key === "id") continue
    copy[key] = entry[key]
  }
  return copy
}

function entryId(entry) {
  if (typeof entry === "string") return entry
  if (isPlainObject(entry)) {
    var id = entry["id"]
    if (id !== undefined && id !== null && String(id) !== "") return String(id)
  }
  return ""
}

function pinTrayToInner(entries, section) {
  var trayEntry = null
  var result = []
  var values = Array.isArray(entries) ? entries : []
  for (var i = 0; i < values.length; i++) {
    if (entryId(values[i]) === "omarchy.tray") trayEntry = values[i]
    else result.push(values[i])
  }
  if (trayEntry) {
    if (section === "right") result.unshift(trayEntry)
    else result.push(trayEntry)
  }
  return result
}

function moduleString(entry, key, fallback) {
  var settings = entrySettings(entry)
  var value = settings[key]
  return value === undefined || value === null ? fallback : String(value)
}

function entryIndex(entries, name) {
  if (!Array.isArray(entries)) return -1
  for (var i = 0; i < entries.length; i++) {
    if (entryId(entries[i]) === name) return i
  }
  return -1
}

function entriesBefore(entries, name) {
  var index = entryIndex(entries, name)
  return index <= 0 ? [] : entries.slice(0, index)
}

function entriesAfter(entries, name) {
  var index = entryIndex(entries, name)
  return index === -1 ? [] : entries.slice(index + 1)
}

// A shell.json write that only changes inline widget settings (the battery
// percentage toggle, a clock format change) must not rebuild the bar.
// Compare two normalized layouts: when the structure is unchanged — same
// entry ids in the same order per region — return the settings-only changes
// as {region, index, entry}. Return null when the change is structural, or
// touches an entry a live settings push cannot safely reach: custom modules
// read their entry directly rather than an injected settings property, and
// a duplicated id makes the push ambiguous.
function inlineSettingsDelta(current, next) {
  if (!isPlainObject(current) || !isPlainObject(next)) return null
  var regions = ["left", "center", "right"]
  var counts = {}
  for (var r = 0; r < regions.length; r++) {
    var entries = Array.isArray(next[regions[r]]) ? next[regions[r]] : []
    for (var i = 0; i < entries.length; i++) {
      var id = entryId(entries[i])
      counts[id] = (counts[id] || 0) + 1
    }
  }
  var changes = []
  for (var s = 0; s < regions.length; s++) {
    var region = regions[s]
    var a = Array.isArray(current[region]) ? current[region] : []
    var b = Array.isArray(next[region]) ? next[region] : []
    if (a.length !== b.length) return null
    for (var j = 0; j < a.length; j++) {
      if (entryId(a[j]) !== entryId(b[j])) return null
      if (JSON.stringify(a[j]) === JSON.stringify(b[j])) continue
      if (customModuleType(a[j]) || customModuleType(b[j])) return null
      if (counts[entryId(b[j])] > 1) return null
      changes.push({ region: region, index: j, entry: b[j] })
    }
  }
  return changes
}

function expandPath(value, home) {
  var path = String(value || "")
  if (path === "") return ""
  if (path.indexOf("~/") === 0) return home + path.substring(1)
  if (path.indexOf("$HOME/") === 0) return home + path.substring(5)
  return path
}

function customModuleSafeName(name) {
  var value = String(name || "")
  return value !== "" && value.indexOf("..") === -1 && value[0] !== "/"
}

function customModuleType(entry) {
  var settings = entrySettings(entry)
  var type = String(settings.type || "")
  if (type) return type
  if (settings.exec) return "command"
  if (settings.source) return "qml"
  return ""
}

function customModulePath(entry, home, configDir) {
  var settings = entrySettings(entry)
  var name = entryId(entry)
  var source = settings.source ? expandPath(settings.source, home) : ""
  if (!source && customModuleSafeName(name))
    source = String(configDir || "") + "/bar/modules/" + String(name) + ".qml"
  return source
}

// A center module is mounted twice once an anchor is set: the copy that is
// actually drawn, and a zero-size placeholder holding its place in the flow
// beside the anchor. Panel routing has to pick the drawn one — it is the only
// one that can anchor a popup, carry the open-panel mark, or be found again
// by switchPanelFrom — and fall back to the placeholder only when nothing is
// on screen. The order the two are registered in is not stable across a live
// bar reconfiguration, so picking the first match is not good enough.
function isDrawnSlot(slot) {
  return !!slot && slot.visible === true && slot.width > 0 && slot.height > 0
}

function pickDrawnSlot(slots) {
  var placeholder = null
  var list = slots || []
  for (var i = 0; i < list.length; i++) {
    if (!list[i]) continue
    if (isDrawnSlot(list[i])) return list[i]
    if (!placeholder) placeholder = list[i]
  }
  return placeholder
}

// A bar surface is built per monitor, so a panel hotkey has several live
// copies of the same widget to route to, and the panel opens on whichever
// monitor's copy answers. Candidates are `{ slot, screenName, opened }`.
//
// An open copy wins first: hide and toggle have to reach the panel the user
// can actually see, wherever it was opened from. Otherwise the focused
// monitor's copy wins, so a summon lands where the user is working instead of
// on whichever output registered its slot first. Neither narrowing applies on
// a single monitor, or when the focused output has no bar of its own.
function pickPanelSlot(candidates, focusedScreen) {
  var rows = Array.isArray(candidates) ? candidates : []
  var pool = rows.filter(function(row) { return row && row.opened === true })
  if (pool.length === 0) pool = rows.filter(function(row) { return !!row })

  var focused = String(focusedScreen || "")
  if (focused) {
    var onFocused = pool.filter(function(row) { return row.screenName === focused })
    if (onFocused.length > 0) pool = onFocused
  }

  return pickDrawnSlot(pool.map(function(row) { return row.slot }))
}

// Resolve a pointer anywhere along the bar to the closest insertion edge.
// Requiring the pointer to sit inside another widget makes the empty space
// around a centered group a dead zone, even though it visually reads as the
// most natural place to drop.
function nearestDropTarget(candidates, point, vertical) {
  var rows = Array.isArray(candidates) ? candidates : []
  var axis = vertical ? Number(point && point.y) : Number(point && point.x)
  if (!isFinite(axis)) return null

  var best = null
  var bestDistance = Infinity
  for (var i = 0; i < rows.length; i++) {
    var row = rows[i]
    if (!row || !row.slot) continue

    var start = Number(vertical ? row.y : row.x)
    var size = Number(vertical ? row.height : row.width)
    if (!isFinite(start) || !isFinite(size) || size <= 0) continue

    var beforeDistance = Math.abs(axis - start)
    var afterDistance = Math.abs(axis - (start + size))
    var after = afterDistance < beforeDistance
    var distance = after ? afterDistance : beforeDistance
    if (distance < bestDistance) {
      best = { slot: row.slot, after: after }
      bestDistance = distance
    }
  }
  return best
}

// Camera-cutout depths measured on real hardware, keyed by physical panel
// size. Apple's notched panels expose more rows above the 16:10 area than
// the cutout actually covers (Apple's own menu bar extends below the notch
// too), so a measured panel gets its exact cutout and an unmeasured panel
// keeps the full strip — which errs taller, never shorter.
var measuredNotchPanels = [
  // MacBook Pro 14" (3024x1964): 64 of the 74 rows above the 16:10 area.
  { width: 3024, height: 1964, cutoutRows: 64 },
  // MacBook Pro 16" (3456x2234): 64 of the 74 rows above the 16:10 area.
  { width: 3456, height: 2234, cutoutRows: 64 }
]

function measuredCutoutRows(physicalWidth, physicalHeight) {
  for (var i = 0; i < measuredNotchPanels.length; i++) {
    var panel = measuredNotchPanels[i]
    // Logical sizes are rounded, so the reconstructed physical size can be
    // a couple of pixels off at fractional scales.
    if (Math.abs(physicalWidth - panel.width) <= 4 && Math.abs(physicalHeight - panel.height) <= 4)
      return panel.cutoutRows
  }
  return 0
}

// Apple's notched laptop panels are a 16:10 display plus a camera strip above
// it, so whatever extends beyond the 16:10 area is the notch strip. Hyprland
// applies the display scale to both axes, so the scale cancels out and the
// strip height falls straight out of the logical screen size.
//
// Callers gate on the machine being Apple Silicon; this only guards against
// panels the formula does not describe: external monitors (not eDP), 16:10
// or wider panels (no leftover), and taller aspect ratios (rotated or 3:2
// panels), where the leftover is far more than a camera strip. Every notched
// Apple panel's strip is ~3.8% of its height, so 5% is a comfortable bound.
function notchHeight(screenName, logicalWidth, logicalHeight, devicePixelRatio) {
  if (String(screenName || "").indexOf("eDP") !== 0) return 0

  var width = Number(logicalWidth)
  var height = Number(logicalHeight)
  if (!(width > 0) || !(height > 0)) return 0

  var strip = height - (width * 10) / 16
  if (strip <= 0 || strip > height / 20) return 0

  var scale = Number(devicePixelRatio)
  if (scale > 0) {
    var cutout = measuredCutoutRows(Math.round(width * scale), Math.round(height * scale))
    if (cutout > 0) return Math.ceil(cutout / scale)
  }
  return Math.ceil(strip)
}

if (typeof module !== "undefined") {
  module.exports = {
    isDrawnSlot: isDrawnSlot,
    pickDrawnSlot: pickDrawnSlot,
    pickPanelSlot: pickPanelSlot,
    nearestDropTarget: nearestDropTarget,
    notchHeight: notchHeight,
    normalizePosition: normalizePosition,
    entrySettings: entrySettings,
    entryId: entryId,
    pinTrayToInner: pinTrayToInner,
    moduleString: moduleString,
    entryIndex: entryIndex,
    entriesBefore: entriesBefore,
    entriesAfter: entriesAfter,
    inlineSettingsDelta: inlineSettingsDelta,
    expandPath: expandPath,
    customModuleSafeName: customModuleSafeName,
    customModuleType: customModuleType,
    customModulePath: customModulePath
  }
}
