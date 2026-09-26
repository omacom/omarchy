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
      if (pillKey(a[j]) !== pillKey(b[j])) return null
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

// Pills give bar widgets their own background, so the bar background can be
// switched off and the widgets still sit on something. `bar.pills` picks how
// widgets share one: "off" draws none, "section" joins neighbours into one
// pill per run, "widget" gives every widget its own.
var PILL_MODES = ["off", "section", "widget"]

function pillMode(value) {
  var mode = String(value || "").trim()
  return PILL_MODES.indexOf(mode) === -1 ? "off" : mode
}

// How one entry takes part in a run: null when it draws nothing (hidden or
// zero-size), which skips it without breaking the run; false when it breaks the
// run and draws no pill (a spacer, even at size 0, or an entry with
// "pill": false); true when it joins.
function pillState(entry, drawn) {
  if (entryId(entry) === "omarchy.spacer") return false
  if (!drawn) return null
  return entrySettings(entry).pill !== false
}

function pillGroup(entry) {
  var group = entrySettings(entry).group
  return group === undefined || group === null ? "" : String(group)
}

// Changing these reshapes the pills, which the in-place settings push cannot.
function pillKey(entry) {
  var settings = entrySettings(entry)
  return JSON.stringify([settings.pill, settings.group])
}

// Segment role per entry, after DMS SegmentRoles.resolve: "none" draws
// nothing, "solo" a whole pill, and a run of two or more "first", "middle"...,
// "last". In section mode neighbours join while their "group" values match, so
// a group key splits a run where no spacer sits.
function pillRoles(entries, states, mode) {
  var list = Array.isArray(entries) ? entries : []
  var roles = list.map(function() { return "none" })
  if (mode !== "section" && mode !== "widget") return roles

  var run = []
  var runGroup = ""
  function close() {
    for (var k = 0; k < run.length; k++) {
      if (run.length === 1) roles[run[k]] = "solo"
      else roles[run[k]] = k === 0 ? "first" : (k === run.length - 1 ? "last" : "middle")
    }
    run = []
  }

  for (var i = 0; i < list.length; i++) {
    var state = states ? states[i] : undefined
    if (state === null || state === undefined) continue
    if (state === false) {
      close()
      continue
    }
    var group = pillGroup(list[i])
    if (mode === "widget" || (run.length > 0 && group !== runGroup)) close()
    runGroup = group
    run.push(i)
  }
  close()
  return roles
}

// Space between a bar end and the outermost drawn widget of a section.
// `states` are the section's pill states in order (null: not drawn, false:
// bare, true: pill). A pill already carries half the pill gap as padding, so
// its end margin is what is left of the inset; a bare widget keeps the
// margin the bar has without pills.
function sectionEndMargin(states, fromEnd, pillsOn, pillInset, pillGap, stockMargin) {
  if (!pillsOn) return stockMargin
  var list = states || []
  for (var n = 0; n < list.length; n++) {
    var state = list[fromEnd ? list.length - 1 - n : n]
    if (state === null || state === undefined) continue
    return state === false ? stockMargin : pillInset - Math.round(pillGap / 2)
  }
  return stockMargin
}

// Offset that centres the widget, not the widget plus its pill padding, in
// `parentLength`. Rounds each half on its own, as anchors.centerIn does, so a
// bar without pills keeps the exact pixel it had.
function anchorOffset(parentLength, slotLength, lead, trail) {
  return Math.round(parentLength / 2) - Math.round((slotLength - lead - trail) / 2) - lead
}

function pillStartsRound(role) {
  return role === "solo" || role === "first"
}

function pillEndsRound(role) {
  return role === "solo" || role === "last"
}

// Text on a pill uses the same two-way WCAG pick as omarchy-bar-text-color:
// the theme's bar text, or the background colour when that reads better.
function hexChannels(hex) {
  var match = /^#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/i.exec(String(hex || ""))
  if (!match) return null
  return [parseInt(match[1], 16), parseInt(match[2], 16), parseInt(match[3], 16)]
}

function toHex(channels) {
  return "#" + channels.map(function(c) {
    var v = Math.max(0, Math.min(255, Math.round(c)))
    return (v < 16 ? "0" : "") + v.toString(16)
  }).join("")
}

// `top` at `alpha` over an opaque `bottom`.
function blendHex(top, alpha, bottom) {
  var t = hexChannels(top)
  var b = hexChannels(bottom)
  if (!t || !b) return ""
  var a = Math.max(0, Math.min(1, Number(alpha)))
  if (!isFinite(a)) a = 1
  return toHex([0, 1, 2].map(function(i) { return t[i] * a + b[i] * (1 - a) }))
}

function luminance(hex) {
  var c = hexChannels(hex)
  if (!c) return NaN
  var linear = c.map(function(v) {
    v = v / 255
    return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4)
  })
  return 0.2126 * linear[0] + 0.7152 * linear[1] + 0.0722 * linear[2]
}

function contrastRatio(a, b) {
  var l1 = luminance(a)
  var l2 = luminance(b)
  if (!isFinite(l1) || !isFinite(l2)) return NaN
  return (Math.max(l1, l2) + 0.05) / (Math.min(l1, l2) + 0.05)
}

function pickTextColor(text, alternative, backdrop) {
  return contrastRatio(alternative, backdrop) > contrastRatio(text, backdrop) ? alternative : text
}

// Floating bar. `setting` is bar.floating from shell.json: true, false, or
// unset. Unset, a theme's [bar] margin decides, as a non-zero margin always
// did, and is used as given. Without a theme margin the bar floats inside the
// space a flush bar already has: half of Hyprland's gaps_out from the screen
// edge, so the gap above the bar matches the gap below it, and the full
// gaps_out at its ends, so they line up with the windows.
var NO_MARGINS = { top: 0, right: 0, bottom: 0, left: 0 }

function hasMargin(margins) {
  return !!margins && (margins.top > 0 || margins.right > 0 || margins.bottom > 0 || margins.left > 0)
}

function barFloating(setting, themeMargins) {
  if (setting === true || setting === false) return setting
  return hasMargin(themeMargins)
}

function barMargins(floating, themeMargins, gaps, position) {
  if (!floating) return NO_MARGINS
  if (hasMargin(themeMargins)) return themeMargins
  if (!hasMargin(gaps)) return NO_MARGINS
  var edge = normalizePosition(position)
  var margins = { top: gaps.top, right: gaps.right, bottom: gaps.bottom, left: gaps.left }
  margins[edge] = Math.round(gaps[edge] / 2)
  return margins
}

// Corner radius of the bar background: only while it floats, a flush bar
// stays square. A theme's [bar] radius wins over Hyprland's rounding, and
// neither rounds past half the bar's thickness.
function barRadius(floating, themeRadius, hyprRadius, barSize) {
  if (!floating) return 0
  var radius = themeRadius === undefined || themeRadius === null ? hyprRadius : themeRadius
  radius = Number(radius)
  if (!isFinite(radius) || radius < 0) radius = 0
  return Math.min(radius, Math.floor(Number(barSize) / 2) || 0)
}

// The default floating bar keeps the windows where a flush bar leaves them:
// it reserves only what a flush bar reserves, so switching floating on or off
// never moves a window. A theme margin is reserved on top of the bar instead.
function floatsInGap(floating, themeMargins) {
  return floating === true && !hasMargin(themeMargins)
}

// Layer-shell margins of the bar window. Only the edges the bar touches take
// a gap: the one it is anchored to, and the two it spans. The remaining side
// is the bar's own far face. Hidden, the anchored edge parks the bar past the
// screen edge, clearing its margin as well as its own size, or the gap leaves
// a sliver of it on screen.
function windowMargins(position, margins, barSize, hidden) {
  var edge = normalizePosition(position)
  var vertical = edge === "left" || edge === "right"
  var anchored = hidden ? -(barSize + margins[edge]) : margins[edge]
  return {
    top: edge === "top" ? anchored : (vertical ? margins.top : 0),
    right: edge === "right" ? anchored : (vertical ? 0 : margins.right),
    bottom: edge === "bottom" ? anchored : (vertical ? margins.bottom : 0),
    left: edge === "left" ? anchored : (vertical ? 0 : margins.left)
  }
}

// Hyprland reserves the exclusive zone plus the anchored edge's margin.
// Floating inside the gap, the zone gives the margin back so the windows stay
// where a flush bar leaves them. Otherwise it is the bar size, which is what
// ExclusionMode.Auto uses: Auto can pick up an explicit zone, so it must not
// differ from it. The zone cannot go below 1, so once the edge margin reaches
// the bar size the bar reserves margin + 1 instead.
function exclusiveZone(inGap, barSize, margins, position) {
  if (!inGap) return barSize
  return Math.max(1, barSize - margins[normalizePosition(position)])
}

if (typeof module !== "undefined") {
  module.exports = {
    pillMode: pillMode,
    pillState: pillState,
    pillGroup: pillGroup,
    pillKey: pillKey,
    pillRoles: pillRoles,
    pillStartsRound: pillStartsRound,
    pillEndsRound: pillEndsRound,
    sectionEndMargin: sectionEndMargin,
    anchorOffset: anchorOffset,
    blendHex: blendHex,
    contrastRatio: contrastRatio,
    pickTextColor: pickTextColor,
    barFloating: barFloating,
    barMargins: barMargins,
    floatsInGap: floatsInGap,
    windowMargins: windowMargins,
    exclusiveZone: exclusiveZone,
    barRadius: barRadius,
    isDrawnSlot: isDrawnSlot,
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
