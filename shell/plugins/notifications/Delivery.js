// Whether a notification reaches the screen, and where the deck sits. Pure
// functions over a snapshot row (Store.snapshot).
.pragma library
.import "Security.js" as Security

var CRITICAL = 2
var NORMAL = 1

// Omarchy's own action toasts and bare notify-send critical alerts get through
// Do Not Disturb. Critical alone is not enough: chat apps send
// critical to force visibility, under their own app name.
function bypassesQuiet(row) {
  var app = String((row && row.app) || "")
  if (app === "omarchy-action") return true
  return app === "notify-send" && Number(row.urgency) === CRITICAL
}

// The web pushes browsers relay arrive as critical under the browser's own
// name (Chromium, Google Chrome, Firefox, Brave and the like): the site wanted
// attention, and the urgency the page asked for never travels. That critical
// asks to be seen, not to hold the screen, so for how long the card stays it
// counts as normal. A sender's own critical still waits for you.
var BROWSER_APPS = /\b(chrome|chromium|firefox|zen|brave|edge|vivaldi|helium)\b/

// The urgency that decides a card's lifetime, not how it draws.
function expiryUrgency(row, urgency) {
  if (Number(urgency) !== CRITICAL) return urgency
  var app = String((row && row.app) || "").toLowerCase()
  return BROWSER_APPS.test(app) ? NORMAL : urgency
}

// The buttons a card offers, in the order it draws them and the number keys
// count them: copying each code it found, then an Omarchy sender's --action
// buttons, then the sender's own actions. A code's label is left to the card,
// which translates it.
function deeds(row, senderActions) {
  var out = []
  var codes = String((row && (row.codes || row.code)) || "").split(" ")
  for (var c = 0; c < codes.length; c++)
    if (codes[c]) out.push({ kind: "code", value: codes[c], label: "" })
  var exec = Security.parseExecActions(row && row.execActions) || []
  for (var e = 0; e < exec.length; e++)
    out.push({ kind: "exec", value: e, label: exec[e].label })
  var actions = senderActions || []
  for (var i = 0; i < actions.length; i++)
    out.push({ kind: "action", value: String(actions[i].id), label: String(actions[i].text || "") })
  return out
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

// The deck hangs from the top-right corner, so it clears the bar only on the
// two edges it touches.
function deckMargins(barPosition, thickness, gap) {
  var position = String(barPosition || "top")
  var edge = Number(gap)
  if (!isFinite(edge)) edge = 0
  var bar = Number(thickness)
  if (!isFinite(bar)) bar = 0
  return {
    top: (position === "top" ? bar : 0) + edge,
    right: (position === "right" ? bar : 0) + edge
  }
}
