// Whether a notification reaches the screen, and where the deck sits. Pure
// functions over a snapshot row (Store.snapshot).
.pragma library

var CRITICAL = 2

// Omarchy's own action toasts and bare notify-send critical alerts get through
// Do Not Disturb. Critical alone is not enough: chat apps send
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

// "silenced", or "" when the row shows. A verification code always passes: it
// was asked for a moment ago and expires in minutes.
function quietReason(row, doNotDisturb) {
  if (!doNotDisturb) return ""
  if (bypassesQuiet(row)) return ""
  if (String((row && row.code) || "")) return ""
  return "silenced"
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

// The corner the deck hangs from, shell.json's notifications.position, newest
// card nearest it.
var POSITIONS = ["top-right", "top-left", "bottom-right", "bottom-left"]

function normalizePosition(value) {
  var position = String(value || "").trim().toLowerCase()
  return POSITIONS.indexOf(position) >= 0 ? position : "top-right"
}

// The deck hangs from one corner, so it clears the bar only on the two edges
// that corner touches. Answers the distance from each screen edge to the deck.
function deckMargins(corner, barPosition, thickness, gap) {
  var position = normalizePosition(corner)
  var vertical = position.indexOf("top") === 0 ? "top" : "bottom"
  var horizontal = position.indexOf("left") >= 0 ? "left" : "right"
  var at = String(barPosition || "top")
  var edge = Number(gap)
  if (!isFinite(edge)) edge = 0
  var bar = Number(thickness)
  if (!isFinite(bar)) bar = 0
  var margins = { top: 0, bottom: 0, left: 0, right: 0 }
  margins[vertical] = (at === vertical ? bar : 0) + edge
  margins[horizontal] = (at === horizontal ? bar : 0) + edge
  return margins
}

// A bottom corner draws the layout upside down in the deck, so the newest
// card sits nearest the edge. Layout y and height in, the card's displayed
// top edge out.
function flipY(bottom, extent, y, height) {
  if (!bottom) return y
  var total = Number(extent)
  return (isFinite(total) ? total : 0) - y - height
}

// One travel out of the screen edge the deck hangs from: up for a top corner,
// down for a bottom one.
function outward(bottom, travel) {
  return bottom ? travel : -travel
}
