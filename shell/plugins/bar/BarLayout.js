// Layout modes for the Omarchy bar: classic, notch, floating, island, split.
//
// Pure functions only, so the numbers can be unit-tested without a shell
// (test/shell.d/bar-layout-test.sh). Bar.qml reads two small files and hands
// them here:
//
//   ~/.config/omarchy/bar-layout/mode         one word, written by omarchy-bar-layout
//   ~/.config/omarchy/bar-layout/layout.json  the tunables below
//
// Anything missing or invalid falls back to the built-in default. Every mode
// works on all four edges: on a left/right bar the same numbers apply across
// the bar's thickness (margin = gap to the screen edge) and along its length.
//
// layout.json is looked up as: built-in default for the mode, then "common",
// then the mode's own object, so one key in "common" changes every mode and one
// key in a mode changes just that mode:
//
//   { "common":   { "opacity": 0.92, "background": "#1e1e2e" },
//     "notch":    { "radius": 14, "padding": 12 },
//     "floating": { "margin": 8, "radius": 12, "border": true, "shadow": false },
//     "island":   { "margin": 6, "radius": "pill", "padding": 8, "spacing": 2 },
//     "split":    { "margin": 6, "radius": "pill", "padding": 8 } }
//
// Units are logical pixels. radius accepts a number, "pill", or "12px".
.pragma library

var MODES = ["classic", "notch", "floating", "island", "split"]

// Alternative spellings of a mode. omarchy-bar-layout keeps the same table, so
// what is typed there means what the bar reads.
var ALIASES = { panel: "island", islands: "split", "split-islands": "split", flat: "classic", default: "classic" }

// A padding of -1 means "the theme's usual inset", which Bar.qml resolves with
// Style.space(8) so it follows font scaling.
var DEFAULT_PADDING = -1

var DEFAULTS = {
  classic:  { radius: 0,   margin: 0, padding: DEFAULT_PADDING, spacing: 0, border: false, shadow: false },
  notch:    { radius: 14,  margin: 0, padding: 12,              spacing: 2, border: false, shadow: false },
  floating: { radius: 12,  margin: 8, padding: DEFAULT_PADDING, spacing: 0, border: true,  shadow: false },
  island:   { radius: 999, margin: 6, padding: 8,               spacing: 2, border: true,  shadow: false },
  split:    { radius: 999, margin: 6, padding: 8,               spacing: 0, border: true,  shadow: false }
}

var COMMON_DEFAULTS = { opacity: 1, background: "" }

// Radius that rounds an end fully: Bar.qml clamps a pill's radius to half its
// height, so anything this large is a pill.
var PILL = 999

// Soft shadow: three translucent rings, so it needs this much room on the
// side of the pill facing the windows.
var HALO = 3

function isMode(name) {
  return MODES.indexOf(String(name)) !== -1
}

function present(value) {
  return value !== undefined && value !== null
}

// Lower-cased, trimmed, aliases resolved; anything unknown is classic.
function normalizeMode(name) {
  var value = String(present(name) ? name : "").trim().toLowerCase()
  if (Object.prototype.hasOwnProperty.call(ALIASES, value)) value = ALIASES[value]
  return isMode(value) ? value : "classic"
}

// layout.json as an object; anything that is not a JSON object is no options.
function parseOptions(text) {
  var raw = String(present(text) ? text : "").trim()
  if (raw === "") return {}
  try {
    var parsed = JSON.parse(raw)
    return (parsed && typeof parsed === "object" && !Array.isArray(parsed)) ? parsed : {}
  } catch (e) {
    return {}
  }
}

function has(object, key) {
  return !!object && typeof object === "object" && Object.prototype.hasOwnProperty.call(object, key)
    && present(object[key])
}

// The first source that sets key, in order of precedence (last wins).
function lookup(key, fallback, common, own) {
  if (has(own, key)) return own[key]
  if (has(common, key)) return common[key]
  return fallback
}

function toNumber(value, fallback, min, max) {
  var n = typeof value === "string" ? parseFloat(value) : value
  if (typeof n !== "number" || !isFinite(n)) return fallback
  return Math.min(max, Math.max(min, n))
}

// Whole logical pixels, so edges land on the pixel grid and the window's
// integer thickness (Bar.qml: thickness) matches what is drawn inside it.
function toPixels(value, fallback, min, max) {
  return Math.round(toNumber(value, fallback, min, max))
}

function toBool(value, fallback) {
  if (value === true || value === 1 || value === "true" || value === "on" || value === "yes") return true
  if (value === false || value === 0 || value === "false" || value === "off" || value === "no") return false
  return fallback
}

// A number, "pill", or "12px".
function parseRadius(value, fallback) {
  if (typeof value === "string" && value.trim().toLowerCase() === "pill") return PILL
  return toPixels(value, fallback, 0, PILL)
}

// "#rrggbb" or "#rrggbbaa" overrides the theme color; anything else (including
// "theme" and "") keeps the theme's own bar background.
function parseBackground(value) {
  var text = String(present(value) ? value : "").trim()
  return /^#([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/.test(text) ? text : ""
}

// Everything Bar.qml needs for one mode, with safe, clamped values.
//   mode        the mode that applies (the same on every bar edge)
//   radius      corner radius in px (999 = pill)
//   margin      gap between the screen edge and the pill; also the gap at each side
//   padding     inner left/right inset of a pill, or -1 for the theme default
//   spacing     extra px between modules (island/split packing)
//   border      1px outline in the bar's text color at low alpha
//   shadow      soft halo; adds `halo` px of window thickness on the inner side
//   opacity     multiplies the pill's fill alpha
//   background  "" for the theme color, or "#rrggbb[aa]"
//   halo        px of room reserved for the shadow (0 when off)
//   extra       window thickness added on top of the bar's own: margin + halo
function metrics(name, options) {
  var mode = normalizeMode(name)
  var opts = options && typeof options === "object" ? options : {}
  var base = DEFAULTS[mode]
  var common = opts.common
  var own = opts[mode]

  var result = {
    mode: mode,
    radius: parseRadius(lookup("radius", base.radius, common, own), base.radius),
    margin: toPixels(lookup("margin", base.margin, common, own), base.margin, 0, 64),
    padding: toPixels(lookup("padding", base.padding, common, own), base.padding, DEFAULT_PADDING, 48),
    spacing: toPixels(lookup("spacing", base.spacing, common, own), base.spacing, 0, 32),
    border: toBool(lookup("border", base.border, common, own), base.border),
    shadow: toBool(lookup("shadow", base.shadow, common, own), base.shadow),
    opacity: toNumber(lookup("opacity", COMMON_DEFAULTS.opacity, common, own), COMMON_DEFAULTS.opacity, 0, 1),
    background: parseBackground(lookup("background", COMMON_DEFAULTS.background, common, own))
  }

  if (mode === "classic") {
    // The stock bar, untouched: nothing detaches, rounds, pads or spaces.
    result.radius = 0
    result.margin = 0
    result.padding = DEFAULT_PADDING
    result.spacing = 0
    result.border = false
    result.shadow = false
    result.opacity = 1
    result.background = ""
  } else if (mode === "notch") {
    // A notch hangs from its screen edge, as wide as its modules: nothing may
    // detach it, outline it or lift it with a shadow. Bar.qml keeps the two
    // corners on the edge square and rounds the ones facing the windows.
    result.margin = 0
    result.border = false
    result.shadow = false
  }

  result.halo = result.shadow ? HALO : 0
  // The halo needs room on the sides and edge too, not only on the inner side.
  if (result.shadow && result.margin < HALO) result.margin = HALO
  result.extra = result.margin + result.halo
  return result
}
