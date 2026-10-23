// Whether a notification reaches the screen, and where the deck sits. Pure
// functions over a snapshot row (Store.snapshot).
.pragma library

var CRITICAL = 2

// Omarchy's own action toasts and bare notify-send critical alerts get through
// Do Not Disturb and every snooze. Critical alone is not enough: chat apps send
// critical to force visibility, under their own app name.
function bypassesQuiet(row) {
  var app = String((row && row.app) || "")
  if (app === "omarchy-action") return true
  return app === "notify-send" && Number(row.urgency) === CRITICAL
}

// Nobody looks back at these (the `transient` hint, or an unnamed sender), so
// quiet drops them rather than holding them.
function isEphemeral(row) {
  if (row && row.transient === true) return true
  var app = String((row && row.app) || "")
  return app === "notify-send" || app === "omarchy-action"
}

// "silenced", "snoozed", or "" when the row shows. A verification code may
// pass either: it was asked for a moment ago and expires in minutes.
function quietReason(row, state) {
  var reason = state.doNotDisturb ? "silenced"
             : (state.globalSnoozed || state.sourceSnoozed) ? "snoozed" : ""
  if (!reason) return ""
  if (bypassesQuiet(row)) return ""
  if (state.codesBypassQuiet && String((row && row.code) || "")) return ""
  return reason
}

// A summary that opens with its own glyph ("󰂚  Silenced": one code point, two
// spaces) already carries its mark, so the card drops the icon slot.
// Omarchy's own marks (default/fonts/omarchy) sit at U+E900 and up, where the
// Nerd Font has devicons, so a glyph there must be drawn in the icon font by
// name, as the menu does with iconFont, or it renders as a devicon.
function omarchyGlyph(glyph) {
  var code = String(glyph || "").codePointAt(0)
  return code >= 0xe900 && code <= 0xe9ff
}

function summaryStartsWithGlyph(summary) {
  var text = String(summary || "").replace(/^\s+/, "")
  if (!text) return false
  var offset = 1
  var first = text.charCodeAt(0)
  if (first >= 0xd800 && first <= 0xdbff && text.length > 1) offset = 2
  var spaces = 0
  while (offset < text.length && text.charAt(offset) === " ") {
    spaces++
    offset++
  }
  return spaces >= 2
}

// The bar's thickness on one screen (a notch can thicken it on one only), 0
// when hidden, the default when there is no bar.
function barThickness(bar, screenName, defaultBarSize) {
  if (!bar) return Number(defaultBarSize) || 0
  if (bar.barHidden) return 0
  var size = Number(typeof bar.barSizeFor === "function" ? bar.barSizeFor(screenName) : bar.barSize)
  if (!isFinite(size) || size <= 0) size = Number(defaultBarSize) || 0
  return Math.max(0, size)
}

// Where the deck can hang: the four corners, the four edge midpoints, and the
// middle of the screen.
var POSITIONS = [
  "top-left", "top-center", "top-right",
  "middle-left", "middle-center", "middle-right",
  "bottom-left", "bottom-center", "bottom-right"
]

// `auto` keeps the deck beside the bar: a top bar leaves it top-right, a left
// bar bottom-left, and a bottom or right bar bottom-right.
function effectivePosition(position, barPosition) {
  var chosen = String(position || "auto")
  if (chosen === "auto") {
    var bar = String(barPosition || "top")
    if (bar === "left") return "bottom-left"
    if (bar === "bottom" || bar === "right") return "bottom-right"
    return "top-right"
  }
  return POSITIONS.indexOf(chosen) >= 0 ? chosen : effectivePosition("auto", barPosition)
}

// Which edges a position anchors to. A centred axis anchors to neither edge.
function sides(position) {
  var parts = String(position || "top-right").split("-")
  var vertical = parts[0], horizontal = parts[1]
  return {
    top: vertical === "top",
    bottom: vertical === "bottom",
    left: horizontal === "left",
    right: horizontal === "right",
    centerX: horizontal === "center",
    centerY: vertical === "middle"
  }
}

// A deck in a corner clears the bar only on the edges it touches. A centred
// axis ignores the bar's thickness: the middle of the screen is the middle.
function deckMargins(barPosition, thickness, gap, position) {
  var bar = String(barPosition || "top")
  var edge = Number(gap)
  if (!isFinite(edge)) edge = 0
  var size = Number(thickness)
  if (!isFinite(size)) size = 0
  var at = sides(position)
  return {
    top: at.top ? edge + (bar === "top" ? size : 0) : 0,
    right: at.right ? edge + (bar === "right" ? size : 0) : 0,
    bottom: at.bottom ? edge + (bar === "bottom" ? size : 0) : 0,
    left: at.left ? edge + (bar === "left" ? size : 0) : 0
  }
}
