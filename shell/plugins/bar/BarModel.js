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

// Display cutouts (a camera notch at the top of a laptop panel) are described
// by the platform's own package, in /usr/share/omarchy-platform/display-cutouts.json:
//
//   { "panels": [ { "connector": "eDP", "width": 3024, "height": 1964, "top": 64 } ] }
//
// A panel matches a screen whose connector name starts with `connector` and
// whose mode is width x height physical pixels; `top` is how many physical rows
// at its top the cutout covers. Anything malformed is dropped.
function parseCutouts(text) {
  var parsed
  try {
    parsed = JSON.parse(String(text || ""))
  } catch (error) {
    return []
  }
  var panels = parsed && Array.isArray(parsed.panels) ? parsed.panels : []
  var cutouts = []
  for (var i = 0; i < panels.length; i++) {
    var panel = panels[i] || {}
    var width = Number(panel.width)
    var height = Number(panel.height)
    var top = Number(panel.top)
    if (typeof panel.connector !== "string" || panel.connector === "") continue
    if (!(width > 0) || !(height > 0) || !(top > 0) || top >= height) continue
    cutouts.push({ connector: panel.connector, width: width, height: height, top: top })
  }
  return cutouts
}

// The cutout at the top of this screen, in logical pixels, or 0. `mode` is the
// output's physical mode as Hyprland reports it ({ width, height, transform }).
// Qt's devicePixelRatio is a whole number even at a fractional scale, so the
// logical size times it rebuilds the mode only at whole scales; that stands in
// just until Hyprland's answer arrives. A mode Hyprland reports that matches no
// panel has no cutout.
function cutoutTop(cutouts, screenName, logicalWidth, logicalHeight, devicePixelRatio, mode) {
  var name = String(screenName || "")
  var logical = Number(logicalWidth)
  var logicalTall = Number(logicalHeight)
  if (!(logical > 0) || !(logicalTall > 0)) return 0
  var width = Number(mode && mode.width)
  var height = Number(mode && mode.height)
  if (width > 0 && height > 0) {
    // Turned a quarter or upside down, the cutout is on another edge.
    var transform = Number(mode.transform) || 0
    if (transform !== 0 && transform !== 4) return 0
    if ((width > height) !== (logical > logicalTall)) return 0
  } else {
    var scale = Number(devicePixelRatio) > 0 ? Number(devicePixelRatio) : 1
    width = Math.round(logical * scale)
    height = Math.round(logicalTall * scale)
  }
  var list = Array.isArray(cutouts) ? cutouts : []
  for (var i = 0; i < list.length; i++) {
    var panel = list[i]
    if (name.indexOf(panel.connector) !== 0) continue
    // Logical sizes are rounded, so a rebuilt mode can be a couple of pixels off.
    if (Math.abs(width - panel.width) <= 4 && Math.abs(height - panel.height) <= 4)
      return Math.ceil(panel.top * logical / width)
  }
  return 0
}

// The height a top bar on this screen must reach to cover its cutout, or a
// calibrated [bar] notch-height in its place. A screen without a cutout, or a
// bar on another edge, has no floor, so a calibration never reaches an
// external monitor.
function notchFloor(cutouts, position, screenName, logicalWidth, logicalHeight, devicePixelRatio, mode, calibrated) {
  if (position !== "top") return 0
  var top = cutoutTop(cutouts, screenName, logicalWidth, logicalHeight, devicePixelRatio, mode)
  if (!(top > 0)) return 0
  return Number(calibrated) > 0 ? Math.round(Number(calibrated)) : top
}

// A cutout covers the middle of a top bar, so that bar draws its center
// section beside the right one.
function centerBesideRight(cutouts, position, screenName, logicalWidth, logicalHeight, devicePixelRatio, mode) {
  return position === "top" && cutoutTop(cutouts, screenName, logicalWidth, logicalHeight, devicePixelRatio, mode) > 0
}

// Whether a top bar can't tell its floor yet: Hyprland hasn't reported the
// screen's mode, the logical size times Qt's ratio matched no panel (as at a
// fractional scale), and a described panel's connector matches the screen, so
// the mode may still bring a cutout. Such a bar waits for the mode before it
// maps rather than guess a floor. A screen no entry's connector matches never
// waits.
function cutoutPending(cutouts, position, screenName, logicalWidth, logicalHeight, devicePixelRatio, mode) {
  if (position !== "top") return false
  if (Number(mode && mode.width) > 0 && Number(mode && mode.height) > 0) return false
  var name = String(screenName || "")
  var list = Array.isArray(cutouts) ? cutouts : []
  var described = false
  for (var i = 0; i < list.length; i++) {
    if (name.indexOf(list[i].connector) === 0) described = true
  }
  return described && !(cutoutTop(cutouts, screenName, logicalWidth, logicalHeight, devicePixelRatio, mode) > 0)
}

// The bar's thickness on the screen with this name, from the sizes a bar
// publishes by screen name, or `fallback` (its configured size) for a screen
// it has none for.
function barSizeFor(sizes, screenName, fallback) {
  var name = String(screenName || "")
  var size = sizes && Object.prototype.hasOwnProperty.call(sizes, name) ? Number(sizes[name]) : 0
  return size > 0 ? size : fallback
}

if (typeof module !== "undefined") {
  module.exports = {
    barSizeFor: barSizeFor,
    centerBesideRight: centerBesideRight,
    cutoutPending: cutoutPending,
    cutoutTop: cutoutTop,
    isDrawnSlot: isDrawnSlot,
    notchFloor: notchFloor,
    parseCutouts: parseCutouts,
    pickDrawnSlot: pickDrawnSlot,
    pickPanelSlot: pickPanelSlot,
    nearestDropTarget: nearestDropTarget,
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
