// Weather-driven wallpaper animation profiles.
//
// Panel.qml already resolves the current conditions for the bar pill, so this
// only has to turn a weather code into the handful of numbers the animation
// layer draws with. Kept as plain functions, the same way Model.js is, so
// test/shell.d/weather-test.sh can cover the mapping without a running shell.
//
// The tuning bias throughout is restraint: this sits behind the user's windows
// all day, so every opacity is a wash rather than a picture, and the counts
// stay low enough that a glance reads "it is raining" without the desktop
// asking to be watched.

// Two code vocabularies reach this file. Open-Meteo reports WMO codes (0-99)
// and wttr.in reports its own (113-395); Panel.qml uses whichever source
// answered, exactly as Model.js does for the icon. The ranges do not overlap,
// so one lookup can serve both without the caller saying which it holds.
//
// Each entry is [condition, intensity]. Intensity is the 0..1 scale every
// renderer scales its count and opacity off.
var WMO_CODES = {
  0: ["clear", 0.20], 1: ["clear", 0.25],
  2: ["cloudy", 0.30], 3: ["cloudy", 0.50],
  45: ["fog", 0.50], 48: ["fog", 0.65],
  51: ["drizzle", 0.25], 53: ["drizzle", 0.35], 55: ["drizzle", 0.45],
  56: ["drizzle", 0.30], 57: ["drizzle", 0.40],
  61: ["rain", 0.45], 63: ["rain", 0.60], 65: ["rain", 0.80],
  66: ["rain", 0.50], 67: ["rain", 0.70],
  71: ["snow", 0.30], 73: ["snow", 0.50], 75: ["snow", 0.70], 77: ["snow", 0.35],
  80: ["rain", 0.50], 81: ["rain", 0.65], 82: ["rain", 0.85],
  85: ["snow", 0.45], 86: ["snow", 0.65],
  95: ["storm", 0.70], 96: ["storm", 0.80], 99: ["storm", 0.90]
}

// Grouped the way Model.iconForCode groups them, so the desktop never
// contradicts the glyph in the bar. Sleet and ice pellets draw as snow;
// freezing drizzle and freezing rain draw as their liquid equivalents,
// matching how WMO splits 56/57 from 66/67.
var WTTR_CODES = {
  113: ["clear", 0.22],
  116: ["cloudy", 0.30], 119: ["cloudy", 0.45], 122: ["cloudy", 0.55],
  143: ["fog", 0.45], 248: ["fog", 0.65], 260: ["fog", 0.60],
  176: ["drizzle", 0.35], 185: ["drizzle", 0.30], 263: ["drizzle", 0.25],
  266: ["drizzle", 0.35], 281: ["drizzle", 0.30], 284: ["drizzle", 0.45],
  293: ["rain", 0.35], 296: ["rain", 0.45], 299: ["rain", 0.60],
  302: ["rain", 0.65], 305: ["rain", 0.80], 308: ["rain", 0.85],
  311: ["rain", 0.40], 314: ["rain", 0.60],
  353: ["rain", 0.40], 356: ["rain", 0.70], 359: ["rain", 0.90],
  179: ["snow", 0.30], 182: ["snow", 0.35], 227: ["snow", 0.60],
  230: ["snow", 0.90], 317: ["snow", 0.40], 320: ["snow", 0.55],
  323: ["snow", 0.30], 326: ["snow", 0.40], 329: ["snow", 0.60],
  332: ["snow", 0.65], 335: ["snow", 0.80], 338: ["snow", 0.85],
  350: ["snow", 0.40], 362: ["snow", 0.40], 365: ["snow", 0.55],
  368: ["snow", 0.35], 371: ["snow", 0.70], 374: ["snow", 0.40],
  377: ["snow", 0.55],
  200: ["storm", 0.70], 386: ["storm", 0.70], 389: ["storm", 0.85],
  392: ["storm", 0.70], 395: ["storm", 0.85]
}

function entryForCode(code) {
  var c = parseInt(String(code), 10)
  if (isNaN(c)) return null
  var entry = c < 100 ? WMO_CODES[c] : WTTR_CODES[c]
  return entry === undefined ? null : entry
}

function conditionForCode(code) {
  var entry = entryForCode(code)
  return entry === null ? "" : entry[0]
}

function intensityForCode(code) {
  var entry = entryForCode(code)
  return entry === null ? 0 : entry[1]
}

// Peak opacity of a condition's layer at full intensity. These are the numbers
// that keep the effect calm, so they are named here rather than buried in the
// renderer: rain tops out barely a fifth opaque, and cloud shadow a tenth.
var OPACITY = {
  // Clear and overcast are washes over the whole frame rather than particles,
  // so they need more alpha than rain to register at all — and cloud shadow
  // is darkening, which a dark wallpaper swallows far more readily than it
  // does a pale mist.
  clear:   { base: 0.06, span: 0.06 },
  cloudy:  { base: 0.05, span: 0.10 },
  fog:     { base: 0.05, span: 0.09 },
  drizzle: { base: 0.08, span: 0.08 },
  rain:    { base: 0.10, span: 0.14 },
  snow:    { base: 0.18, span: 0.22 },
  storm:   { base: 0.10, span: 0.14 }
}

function opacityFor(condition, intensity) {
  var range = OPACITY[condition]
  if (!range) return 0
  return range.base + range.span * clamp01(intensity)
}

function clamp01(value) {
  var n = parseFloat(String(value))
  if (isNaN(n)) return 0
  if (n < 0) return 0
  if (n > 1) return 1
  return n
}

// Wind tilts falling precipitation. Three deliberate departures from the
// true angle: a few degrees of lean even in still air, because dead-vertical
// streaks read as a screen artifact rather than rain; a square-root response,
// so an ordinary breeze is visible instead of everything below a gale looking
// identical; and a low ceiling, because past twenty degrees a streak stops
// reading as falling and starts reading as motion blur.
function slantForWind(windKmph, maxDegrees, windDirection) {
  var limit = parseFloat(String(maxDegrees))
  if (isNaN(limit)) limit = 18

  var wind = parseFloat(String(windKmph))
  if (isNaN(wind)) wind = 0

  var magnitude = Math.min(Math.abs(wind), 60) / 60
  var base = limit * 0.28
  var degrees = Math.min(base + Math.sqrt(magnitude) * (limit - base), limit)

  return degrees * slantDirection(windDirection)
}

// Meteorological wind direction is the bearing the wind blows *from*, so the
// horizontal component of its travel is -sin(bearing): a westerly (270) sends
// rain to the right. Only the sign is taken — a northerly still leans, rather
// than snapping to vertical at the one bearing with no sideways component.
// Unknown direction leans right, which is the way most people draw rain.
function slantDirection(windDirection) {
  var bearing = parseFloat(String(windDirection))
  if (isNaN(bearing)) return 1
  return -Math.sin(bearing * Math.PI / 180) < 0 ? -1 : 1
}

// Particle budget, scaled by screen area so a 4K desktop is not sparser than a
// 1080p one, and hard-capped so a very wide display cannot run away with it.
var DENSITY_PER_MEGAPIXEL = {
  clear: 40,
  cloudy: 0,
  fog: 0,
  // Drizzle drops are a third the length of rain drops, so matching rain's
  // count is what keeps the same intensity reading as lighter, not sparser.
  drizzle: 500,
  rain: 520,
  snow: 320,
  storm: 560
}

var MAX_PARTICLES = 700
var REFERENCE_AREA = 1920 * 1080

function particleCount(profile, width, height) {
  if (!profile || !profile.condition) return 0
  var density = DENSITY_PER_MEGAPIXEL[profile.condition]
  if (!density) return 0

  var w = parseFloat(String(width))
  var h = parseFloat(String(height))
  if (isNaN(w) || isNaN(h) || w <= 0 || h <= 0) return 0

  var scaled = density * clamp01(profile.intensity) * ((w * h) / REFERENCE_AREA)
  return Math.max(0, Math.min(Math.round(scaled), MAX_PARTICLES))
}

// The one object the animation layer reads. `condition` picks the renderer;
// everything else is already resolved so no tuning lives in the QML.
function profileFor(code, night, windKmph, windDirection) {
  var condition = conditionForCode(code)
  if (condition === "") return null

  var intensity = intensityForCode(code)
  // Snow drifts rather than slants, so it gets a gentler ceiling than rain.
  var maxSlant = condition === "snow" ? 10 : 18

  return {
    condition: condition,
    intensity: intensity,
    opacity: opacityFor(condition, intensity),
    slant: slantForWind(windKmph, maxSlant, windDirection),
    night: night === true,
    // Thunder is the only thing here allowed to change brightness abruptly,
    // so it is opt-in per profile rather than a property of rain.
    lightning: condition === "storm"
  }
}

// Panel.qml hands over the same `current` object it renders the pill from.
// Open-Meteo's code wins when present; wttr's is the fallback, matching the
// precedence Model.currentIcon already applies to the icon.
function profileForCurrent(current, windKmph) {
  if (!current) return null

  var code = current.openMeteoWeatherCode
  if (code === undefined || code === null) code = current.weatherCode
  if (code === undefined || code === null) return null

  var wind = windKmph
  if (wind === undefined || wind === null) wind = current.windspeedKmph

  // Open-Meteo's is_day is 1 by day and 0 by night; wttr has no flag, so an
  // absent one is treated as day rather than guessing from the clock.
  var night = current.isDay !== undefined && current.isDay !== null
    && Number(current.isDay) === 0

  // Only Open-Meteo reports a bearing. Without one the lean defaults to the
  // right rather than to vertical, so wttr-sourced rain still looks like rain.
  return profileFor(code, night, wind, current.windDirection)
}

// Conditions the preview IPC accepts, and the code each one stands in for.
var PREVIEW_CODES = {
  clear: 0,
  cloudy: 3,
  fog: 45,
  drizzle: 53,
  rain: 63,
  snow: 73,
  storm: 95
}

function previewProfile(name, windKmph) {
  var key = String(name || "").replace(/^\s+|\s+$/g, "").toLowerCase()
  var code = PREVIEW_CODES[key]
  if (code === undefined) return null
  return profileFor(code, false, windKmph === undefined ? 12 : windKmph)
}

function previewNames() {
  var names = []
  for (var key in PREVIEW_CODES) names.push(key)
  return names.sort()
}

if (typeof module !== "undefined") {
  module.exports = {
    conditionForCode: conditionForCode,
    intensityForCode: intensityForCode,
    opacityFor: opacityFor,
    slantForWind: slantForWind,
    particleCount: particleCount,
    profileFor: profileFor,
    profileForCurrent: profileForCurrent,
    previewProfile: previewProfile,
    previewNames: previewNames,
    MAX_PARTICLES: MAX_PARTICLES
  }
}
