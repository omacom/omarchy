// Background effects: things the shell draws over a still background, read
// from a sidecar beside it. backgrounds/effects/<stem>.json pairs with
// backgrounds/<stem>.<ext> by name, the same way a background finds its intro
// in backgrounds/intros/. The sidecar is data only, so a theme cloned from git
// may ship one.
//
// Each top-level key names one effect type and holds its entries:
//
// {
//   "eyes": [
//     {
//       "center": [1783, 1295],   // the eye's middle, in image pixels
//       "radius": [40, 36],       // its white, painted over the image's own
//       "color": "#cba4f5",
//       "pupil": {
//         "radius": [16, 15],
//         "color": "#171723",
//         "rest": [6.5, -1.5],    // where the image paints it, from center
//         "travel": [21, 19],     // optional, how far it may roll
//         // optional, a catchlight that moves with the pupil
//         "highlight": { "radius": 5, "offset": [-6.5, -3.5], "color": "#cba4f5" }
//       }
//     }
//   ]
// }
//
// Coordinates are in the image's own pixels, as an image editor shows them.
// A radius or offset is one number for a circle or [x, y] for an ellipse.
//
// A new effect type adds its parser to `parsers` below and its component to
// BackgroundEffects.qml.

var maxEntries = 32
var maxWarnings = 8

function sidecarPath(backgroundPath) {
  var path = String(backgroundPath || "")
  var slash = path.lastIndexOf("/")
  var name = path.slice(slash + 1)
  var dot = name.lastIndexOf(".")
  if (slash < 0 || dot <= 0) return ""
  // The stills the picker offers; the shell draws a GIF's first frame.
  if (!/\.(jpe?g|png|gif|bmp|webp)$/i.test(name)) return ""
  return path.slice(0, slash) + "/effects/" + name.slice(0, dot) + ".json"
}

function finiteNumber(value) {
  return typeof value === "number" && isFinite(value) ? value : null
}

function pair(value, positive) {
  var x, y
  if (Array.isArray(value)) {
    if (value.length !== 2) return null
    x = finiteNumber(value[0])
    y = finiteNumber(value[1])
  } else {
    x = y = finiteNumber(value)
  }
  if (x === null || y === null) return null
  if (positive && (x <= 0 || y <= 0)) return null
  return { x: x, y: y }
}

// Takes #rrggbb or #rrggbbaa, as CSS and image editors write them, and
// returns what a QML color reads, which puts the alpha first: #aarrggbb.
function color(value) {
  var text = String(value || "")
  if (/^#[0-9a-f]{6}$/i.test(text)) return text
  if (/^#[0-9a-f]{8}$/i.test(text)) return "#" + text.slice(7) + text.slice(1, 7)
  return ""
}

// Each parser returns the entry, or a string saying what is wrong with it.
function parseEye(raw) {
  if (!raw || typeof raw !== "object") return "not an object"
  var center = pair(raw.center, false)
  if (!center) return "center must be [x, y]"
  var radius = pair(raw.radius, true)
  if (!radius) return "radius must be a positive number or [x, y]"
  var sclera = color(raw.color)
  if (!sclera) return "color must be #rrggbb or #rrggbbaa"

  var pupilRaw = raw.pupil
  if (!pupilRaw || typeof pupilRaw !== "object") return "pupil is missing"
  var pupilRadius = pair(pupilRaw.radius, true)
  if (!pupilRadius) return "pupil.radius must be a positive number or [x, y]"
  if (pupilRadius.x >= radius.x || pupilRadius.y >= radius.y) return "pupil.radius must be smaller than radius"
  var pupilColor = color(pupilRaw.color)
  if (!pupilColor) return "pupil.color must be #rrggbb or #rrggbbaa"

  // By default the pupil may roll until a tenth of its size from the rim.
  var travel = pupilRaw.travel === undefined
    ? { x: radius.x - pupilRadius.x * 1.1, y: radius.y - pupilRadius.y * 1.1 }
    : pair(pupilRaw.travel, false)
  if (!travel || travel.x < 0 || travel.y < 0) return "pupil.travel must be a number or [x, y], not negative"
  // The pupil never leaves the white: it may roll until it touches the rim.
  var room = { x: radius.x - pupilRadius.x, y: radius.y - pupilRadius.y }
  if (travel.x > room.x || travel.y > room.y) return "pupil.travel must keep the pupil inside radius"

  var rest = pupilRaw.rest === undefined ? { x: 0, y: 0 } : pair(pupilRaw.rest, false)
  if (!rest) return "pupil.rest must be a number or [x, y]"
  if (Math.abs(rest.x) > room.x || Math.abs(rest.y) > room.y) return "pupil.rest must keep the pupil inside radius"

  var highlight = null
  if (pupilRaw.highlight !== undefined) {
    var highlightRaw = pupilRaw.highlight
    if (!highlightRaw || typeof highlightRaw !== "object") return "pupil.highlight must be an object"
    var highlightRadius = pair(highlightRaw.radius, true)
    var highlightOffset = pair(highlightRaw.offset === undefined ? 0 : highlightRaw.offset, false)
    var highlightColor = color(highlightRaw.color)
    if (!highlightRadius || !highlightOffset || !highlightColor) return "pupil.highlight needs radius, color and an optional offset"
    highlight = { radius: highlightRadius, offset: highlightOffset, color: highlightColor }
  }

  return {
    center: center,
    radius: radius,
    color: sclera,
    pupil: { radius: pupilRadius, color: pupilColor, rest: rest, travel: travel, highlight: highlight }
  }
}

var parsers = {
  eyes: parseEye
}

// Returns { effects: { eyes: [...] }, warnings: [...] }. A malformed entry is
// dropped on its own, so one typo does not take the rest down, and an effect
// this version does not know is skipped, so a sidecar written for a newer
// Omarchy still shows what this one can draw.
// Both the entries looked at and the warnings kept are bounded, so a huge
// broken file cannot stall the shell or flood its log.
function parse(text) {
  var effects = {}
  var warnings = []
  for (var type in parsers) effects[type] = []

  function warn(message) {
    if (warnings.length < maxWarnings) warnings.push(message)
    else if (warnings.length === maxWarnings) warnings.push("further problems not listed")
  }

  var data
  try {
    data = JSON.parse(String(text || ""))
  } catch (e) {
    return { effects: effects, warnings: ["not valid JSON: " + e.message] }
  }
  if (!data || typeof data !== "object" || Array.isArray(data)) {
    return { effects: effects, warnings: ["the file must hold an object of effects"] }
  }

  for (var key in data) {
    // Only the types listed here, not names every object inherits.
    var parser = Object.prototype.hasOwnProperty.call(parsers, key) ? parsers[key] : null
    if (!parser) {
      warn("unknown effect \"" + key + "\" skipped")
      continue
    }
    if (!Array.isArray(data[key])) {
      warn(key + " must be a list")
      continue
    }
    var count = Math.min(data[key].length, maxEntries)
    for (var i = 0; i < count; i++) {
      var entry = parser(data[key][i])
      if (typeof entry === "string") warn(key + "[" + i + "] skipped: " + entry)
      else effects[key].push(entry)
    }
    if (data[key].length > maxEntries) warn(key + " beyond the first " + maxEntries + " skipped")
  }
  return { effects: effects, warnings: warnings }
}

// Where an image point lands on a screen showing the image with
// PreserveAspectCrop: scaled to cover, centered, the overflow cropped.
function cropTransform(imageWidth, imageHeight, screenWidth, screenHeight) {
  if (!(imageWidth > 0 && imageHeight > 0 && screenWidth > 0 && screenHeight > 0)) return null
  var scale = Math.max(screenWidth / imageWidth, screenHeight / imageHeight)
  return {
    scale: scale,
    x: (screenWidth - imageWidth * scale) / 2,
    y: (screenHeight - imageHeight * scale) / 2
  }
}

// The pupil's offset from the eye's center, in image pixels. Without a
// pointer it stays where the image paints it. With one, it rolls toward the
// pointer: barely when the pointer is on the eye, nearly to the rim when it
// is far away. reach is the distance, in the same units as dx and dy, at
// which the pupil is halfway to the rim.
function pupilOffset(eye, dx, dy, reach) {
  if (dx === null || dy === null || dx === undefined || dy === undefined) return { x: eye.pupil.rest.x, y: eye.pupil.rest.y }
  var distance = Math.sqrt(dx * dx + dy * dy)
  if (distance < 1e-6 || !(reach > 0)) return { x: 0, y: 0 }
  var pull = distance / (distance + reach)
  return {
    x: dx / distance * eye.pupil.travel.x * pull,
    y: dy / distance * eye.pupil.travel.y * pull
  }
}

if (typeof module !== "undefined") {
  module.exports = {
    maxEntries: maxEntries,
    maxWarnings: maxWarnings,
    sidecarPath: sidecarPath,
    parse: parse,
    cropTransform: cropTransform,
    pupilOffset: pupilOffset
  }
}
