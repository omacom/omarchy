function clampBrightness(value) {
  var n = Number(value)
  if (!isFinite(n)) return 1
  return Math.max(1, Math.min(100, Math.round(n)))
}

function normalizeScale(scale) {
  var n = parseFloat(String(scale || ""))
  if (!isFinite(n)) return ""
  return String(Math.round(n * 100) / 100)
}

function gcd(a, b) {
  while (b) {
    var remainder = a % b
    a = b
    b = remainder
  }
  return a
}

function cleanScale(scale, width, height) {
  var requested = Number(scale)
  var modeWidth = Number(width)
  var modeHeight = Number(height)
  if (!isFinite(requested) || !isFinite(modeWidth) || !isFinite(modeHeight)
      || requested <= 0 || modeWidth <= 0 || modeHeight <= 0) return ""

  var divisor = gcd(Math.round(modeWidth * 120), Math.round(modeHeight * 120))
  var scaleUnits = Math.round(requested * 120)
  if (scaleUnits > divisor) scaleUnits = divisor
  while (divisor % scaleUnits !== 0) scaleUnits++
  return normalizeScale(scaleUnits / 120)
}

function matchingScaleIndex(scales, currentScale, width, height) {
  var current = Number(currentScale)
  if (!Array.isArray(scales) || !isFinite(current)) return -1

  var bestIndex = -1
  var bestDistance = Infinity
  var normalizedCurrent = normalizeScale(current)
  for (var i = 0; i < scales.length; i++) {
    if (cleanScale(scales[i], width, height) !== normalizedCurrent) continue

    var distance = Math.abs(Number(scales[i]) - current)
    if (distance < bestDistance) {
      bestIndex = i
      bestDistance = distance
    }
  }
  return bestIndex
}

function availableScales(scales, width, height) {
  if (!Array.isArray(scales) || Number(width) <= 0 || Number(height) <= 0) return scales || []

  var byEffectiveScale = {}
  for (var i = 0; i < scales.length; i++) {
    var requested = Number(scales[i])
    var effective = Number(cleanScale(requested, width, height))

    if (!isFinite(requested) || !isFinite(effective)) continue

    var key = normalizeScale(effective)
    var existing = byEffectiveScale[key]
    if (!existing || Math.abs(requested - effective) < existing.distance) {
      byEffectiveScale[key] = {
        value: String(scales[i]),
        index: i,
        distance: Math.abs(requested - effective)
      }
    }
  }

  return Object.keys(byEffectiveScale)
    .map(function(key) { return byEffectiveScale[key] })
    .sort(function(a, b) { return a.index - b.index })
    .map(function(candidate) { return candidate.value })
}

// The obvious resolutions for a display, smallest first so the row reads like a
// slider: its native one, then the smaller modes with the same shape down to
// 1080p, so nothing comes out stretched. Odd legacy and tiled modes stay out,
// and the list stops at a handful. The current resolution always shows, so the
// panel can mark it.
var RESOLUTION_LIMIT = 5
var RESOLUTION_MIN_HEIGHT = 1080

function resolutionOptions(availableModes, width, height) {
  if (!Array.isArray(availableModes)) return []

  var sizes = {}
  for (var i = 0; i < availableModes.length; i++) {
    var match = /^(\d+)x(\d+)@/.exec(String(availableModes[i]))
    if (!match) continue
    var w = Number(match[1])
    var h = Number(match[2])
    if (w > 0 && h > 0) sizes[w + "x" + h] = { w: w, h: h }
  }

  var all = Object.keys(sizes).map(function(key) { return sizes[key] })
  if (all.length === 0) return []
  all.sort(function(a, b) { return b.w * b.h - a.w * a.h || b.w - a.w })

  var native = all[0]
  var aspect = native.w / native.h
  var options = all.filter(function(size) {
    return size.h >= RESOLUTION_MIN_HEIGHT && Math.abs(size.w / size.h - aspect) < 0.01
  }).slice(0, RESOLUTION_LIMIT).map(function(size) { return size.w + "x" + size.h })

  var current = Number(width) + "x" + Number(height)
  if (sizes[current] && options.indexOf(current) < 0) {
    options.push(current)
    options.sort(function(a, b) { return sizes[b].w * sizes[b].h - sizes[a].w * sizes[a].h })
  }
  return options.reverse()
}

// Short pill label: the names people know (4K, 1440p), else the height.
function resolutionLabel(resolution) {
  var match = /^(\d+)x(\d+)$/.exec(String(resolution))
  if (!match) return String(resolution)
  var w = Number(match[1])
  var h = Number(match[2])
  if (h >= 4320) return "8K"
  if (w >= 6000) return "6K"
  if (w >= 5120 && h >= 2880) return "5K"
  if (w >= 3840 && h >= 2160) return "4K"
  return h + "p"
}

// ---- Layout ----
// Rects are { name, x, y, w, h } in Hyprland's layout space: logical pixels,
// after each display's scale.

// A display's footprint in the layout: its mode divided by its scale, turned on
// its side when it's rotated a quarter turn.
function logicalRect(display) {
  var scale = Number(display.scale) || 1
  var w = Math.round(Number(display.width) / scale)
  var h = Math.round(Number(display.height) / scale)
  if (Number(display.transform) % 2 === 1) {
    var turned = w
    w = h
    h = turned
  }
  return { name: String(display.name), x: Number(display.x) || 0, y: Number(display.y) || 0, w: w, h: h }
}

// A plain copy: an array handed through a QML property is no longer one
// Array.isArray or the array methods accept.
function copyRects(rects) {
  var list = []
  for (var i = 0; rects && i < rects.length; i++)
    list.push({ name: rects[i].name, x: rects[i].x, y: rects[i].y, w: rects[i].w, h: rects[i].h })
  return list
}

function overlaps(a, b) {
  return a.x < b.x + b.w && b.x < a.x + a.w && a.y < b.y + b.h && b.y < a.y + a.h
}

function layoutBounds(rects) {
  var bounds = { x: Infinity, y: Infinity, right: -Infinity, bottom: -Infinity }
  for (var i = 0; i < rects.length; i++) {
    bounds.x = Math.min(bounds.x, rects[i].x)
    bounds.y = Math.min(bounds.y, rects[i].y)
    bounds.right = Math.max(bounds.right, rects[i].x + rects[i].w)
    bounds.bottom = Math.max(bounds.bottom, rects[i].y + rects[i].h)
  }
  bounds.w = bounds.right - bounds.x
  bounds.h = bounds.bottom - bounds.y
  return bounds
}

// Shift the layout so it starts at 0x0, as Hyprland's own does.
function normalizeLayout(rects) {
  var bounds = layoutBounds(rects)
  return rects.map(function(rect) {
    return { name: rect.name, x: rect.x - bounds.x, y: rect.y - bounds.y, w: rect.w, h: rect.h }
  })
}

// Along an edge it shares with another display: keep at least a pixel of the
// edge shared, and take the other's start, center or end when within snap.
function alignAlong(pos, size, start, length, snap) {
  var aligned = Math.round(Math.max(start - size + 1, Math.min(start + length - 1, pos)))
  var targets = [start, start + (length - size) / 2, start + length - size]
  var best = aligned
  var bestDistance = snap
  for (var i = 0; i < targets.length; i++) {
    var distance = Math.abs(aligned - targets[i])
    if (distance <= bestDistance) {
      best = Math.round(targets[i])
      bestDistance = distance
    }
  }
  return best
}

// Where a display dropped with its corner at (x, y) lands: against a side of
// one of the others, at the spot nearest the drop that overlaps nothing.
// Returns the whole layout, normalized, or null when nothing fits.
function dropDisplay(rects, name, x, y, snap) {
  var all = copyRects(rects)
  var moving = null
  var others = []
  for (var i = 0; i < all.length; i++) {
    if (all[i].name === name) moving = all[i]
    else others.push(all[i])
  }
  if (!moving || others.length === 0) return null

  var best = null
  var bestDistance = Infinity
  for (var j = 0; j < others.length; j++) {
    var other = others[j]
    var alongY = alignAlong(y, moving.h, other.y, other.h, snap)
    var alongX = alignAlong(x, moving.w, other.x, other.w, snap)
    var candidates = [
      { x: other.x - moving.w, y: alongY },
      { x: other.x + other.w, y: alongY },
      { x: alongX, y: other.y - moving.h },
      { x: alongX, y: other.y + other.h }
    ]
    for (var c = 0; c < candidates.length; c++) {
      var placed = { name: name, x: candidates[c].x, y: candidates[c].y, w: moving.w, h: moving.h }
      if (others.some(function(rect) { return overlaps(placed, rect) })) continue
      var distance = Math.hypot(placed.x - x, placed.y - y)
      if (distance < bestDistance) {
        best = placed
        bestDistance = distance
      }
    }
  }
  if (!best) return null

  return normalizeLayout(all.map(function(rect) { return rect.name === name ? best : rect }))
}

// Move a display to one side of all the others, centered along it.
function placeDisplay(rects, name, side) {
  var all = copyRects(rects)
  var moving = null
  for (var i = 0; i < all.length; i++)
    if (all[i].name === name) moving = all[i]
  var others = all.filter(function(rect) { return rect.name !== name })
  if (!moving || others.length === 0) return null

  var bounds = layoutBounds(others)
  var centerX = Math.round(bounds.x + (bounds.w - moving.w) / 2)
  var centerY = Math.round(bounds.y + (bounds.h - moving.h) / 2)
  var point = side === "left" ? { x: bounds.x - moving.w, y: centerY }
    : side === "right" ? { x: bounds.right, y: centerY }
    : side === "above" ? { x: centerX, y: bounds.y - moving.h }
    : { x: centerX, y: bounds.bottom }
  return dropDisplay(all, name, point.x, point.y, Infinity)
}

// Whether two layouts put every display in the same place.
function sameLayout(a, b) {
  if (!a || !b || a.length !== b.length) return false
  for (var i = 0; i < a.length; i++) {
    var match = null
    for (var j = 0; j < b.length; j++)
      if (b[j].name === a[i].name) match = b[j]
    if (!match || match.x !== a[i].x || match.y !== a[i].y) return false
  }
  return true
}

// What to call a display: the built-in panel by what it is, since laptops
// report a panel code as its model, and any other by its model, else its make,
// else its connector.
function displayTitle(display, builtInLabel) {
  var name = String((display && display.name) || "")
  if (/^(eDP|LVDS|DSI)-/.test(name)) return builtInLabel || "Built-in Display"
  var model = String(display.model || "").trim()
  if (model && !/^(0x)?[0-9a-f]+$/i.test(model)) return model
  return String(display.make || "").trim() || name
}

// tr is an optional translate(key, english) from the QML side (I18n.t);
// without it the English text stands, which is what the Node tests assert.
function brightnessName(percent, tr) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  var p = Math.round(percent)
  if (p >= 95) return t("monitor.level.sunBlast", "Sun blast")
  if (p >= 80) return t("monitor.level.solarFlare", "Solar flare")
  if (p >= 65) return t("monitor.level.goldenHour", "Golden hour")
  if (p >= 45) return t("monitor.level.evenDay", "Even day")
  if (p >= 30) return t("monitor.level.softGlow", "Soft glow")
  if (p >= 20) return t("monitor.level.lampLight", "Lamp light")
  if (p >= 10) return t("monitor.level.candlelit", "Candlelit")
  return t("monitor.level.nightOwl", "Night owl")
}

function parseDisplays(raw) {
  var displays = []
  try {
    displays = raw ? JSON.parse(String(raw)) : []
  } catch (e) {
    displays = []
  }
  if (!Array.isArray(displays)) displays = []

  var count = 0
  for (var i = 0; i < displays.length; i++) {
    if (displays[i] && displays[i].enabled) count++
  }

  return {
    displays: displays,
    enabledDisplayCount: count
  }
}

if (typeof module !== "undefined") {
  module.exports = {
    clampBrightness: clampBrightness,
    normalizeScale: normalizeScale,
    cleanScale: cleanScale,
    matchingScaleIndex: matchingScaleIndex,
    availableScales: availableScales,
    resolutionOptions: resolutionOptions,
    resolutionLabel: resolutionLabel,
    displayTitle: displayTitle,
    logicalRect: logicalRect,
    copyRects: copyRects,
    normalizeLayout: normalizeLayout,
    dropDisplay: dropDisplay,
    placeDisplay: placeDisplay,
    sameLayout: sameLayout,
    brightnessName: brightnessName,
    parseDisplays: parseDisplays
  }
}
