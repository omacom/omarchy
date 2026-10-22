// Reading what senders put in a notification: where it really came from, and
// rendering only the safe subset of the body markup the spec allows.
.pragma library
.import "Security.js" as Security

var ALLOWED = ["b", "i", "u", "s", "em", "strong"]

var ENTITIES = { amp: "&", lt: "<", gt: ">", quot: "\"", apos: "'", nbsp: " " }

// The body is markup, so senders escape it ("Tom &amp; Jerry"); decode before
// escaping again. Up to three passes, because relays stack escapes (KDE
// Connect re-escapes a WhatsApp &quot; into &amp;quot;).
function decodeEntities(text) {
  var out = Security.bounded(text, Security.MAX_BODY)
  for (var i = 0; i < 3; i++) {
    var once = decodeOnce(out)
    if (once === out) break
    out = once
  }
  return out
}

function decodeOnce(text) {
  return String(text || "")
    .replace(/&#(\d{1,7});/g, function(_, n) {
      var code = parseInt(n, 10)
      return (code > 0 && code < 0x110000) ? String.fromCodePoint(code) : _
    })
    .replace(/&#x([0-9a-f]{1,6});/gi, function(_, n) {
      var code = parseInt(n, 16)
      return (code > 0 && code < 0x110000) ? String.fromCodePoint(code) : _
    })
    .replace(/&([a-z]+);/gi, function(whole, name) {
      var hit = ENTITIES[String(name).toLowerCase()]
      return hit === undefined ? whole : hit
    })
}

function escapeAll(text) {
  return String(text || "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
}

// Everything is escaped first, then only the allowed tags are put back, so
// anything else ("<3") survives as literal text.
function unescapeAllowed(text) {
  var out = text
  for (var i = 0; i < ALLOWED.length; i++) {
    var tag = ALLOWED[i]
    out = out.replace(new RegExp("&lt;" + tag + "&gt;", "gi"), "<" + tag + ">")
    out = out.replace(new RegExp("&lt;/" + tag + "&gt;", "gi"), "</" + tag + ">")
  }
  out = out.replace(/&lt;br\s*\/?&gt;/gi, "<br/>")
  // Anchors keep only their href, and only when Security allows it: a click
  // goes straight to the desktop URL handler, and the sender writes the label.
  // A refused link keeps its text and loses its click.
  out = out.replace(/&lt;a\s+href=(?:&quot;|")([^"&]+)(?:&quot;|")[^&]*&gt;([\s\S]*?)&lt;\/a&gt;/gi,
                    function (whole, href, label) {
                      var safe = Security.safeExternalUrl(href)
                      return safe ? '<a href="' + safe + '">' + label + '</a>' : label
                    })
  return out
}

function hostname(value) { return Security.canonicalHostname(value) }

// A browser body that opens with a link to the site's own origin is the site
// labelling itself. Lift it out as the source.
function liftSource(body) {
  var text = Security.bounded(body, Security.MAX_BODY)
  var m = text.match(/^\s*<a\s+href="([^"]+)"[^>]*>([\s\S]*?)<\/a>\s*/i)
  if (!m) return { source: "", body: text }
  // The origin is the href's host, which must pass the URL policy; the label
  // is the sender's text and never stands in for it.
  var host = Security.hostOf(m[1])
  if (!host) return { source: "", body: text }
  // Only when the label is that host or a bare domain; a real in-body link
  // stays where the sender put it.
  var label = String(m[2]).trim()
  var looksLikeSource = label === host || /^[\w.-]+\.[a-z]{2,}$/i.test(label)
  if (!looksLikeSource) return { source: "", body: text }
  return { source: host, body: text.slice(m[0].length) }
}

function linkify(escaped) {
  return escaped.replace(/(https?:\/\/[^\s<]+)/g, function(url) {
    var safe = Security.safeHttpUrl(decodeEntities(url))
    return safe ? '<a href="' + safe.replace(/&/g, '&amp;') + '">' + url + '</a>' : url
  })
}

// The body as drawn: the permitted subset, newlines honoured, and bare URLs
// made clickable unless the sender wrote its own links.
function render(body) {
  var text = decodeEntities(body)
  // StyledText has no <em>.
  var out = unescapeAllowed(escapeAll(text)).replace(/<(\/?)em>/gi, "<$1i>")
  if (!/<a\b/i.test(out)) out = linkify(out)
  return out.replace(/\r?\n/g, "<br/>")
}

// One line of plain text. Strip only what render() treats as markup (<String>
// and <3 stay literal), then undo our own escaping once without decoding the
// sender's text again.
function oneLine(body) {
  var text = unescapeAllowed(escapeAll(decodeEntities(body)))
  return decodeOnce(text.replace(/<[^>]+>/g, " "))
    .replace(/\s+/g, " ")
    .trim()
}

// Only a browser's leading anchor names a site; any other app's is just a link.
var BROWSERS = /^(google chrome|chromium|brave|brave browser|brave origin|microsoft edge|vivaldi|opera|helium|firefox|zen|librewolf)$/i
function isBrowser(app) {
  return BROWSERS.test(String(app || "").trim())
}

// Who a notification is from, and its body with the sender's own labelling
// taken off.
function identify(row) {
  var app = String(row.app || "")
  var lifted = isBrowser(app) ? liftSource(row.body) : { source: "", body: Security.bounded(row.body, Security.MAX_BODY) }
  return {
    source: lifted.source || app,
    body: lifted.body,
    summary: row.summary
  }
}

// Group on the app's own name, not the desktop-entry hint: Chrome puts a
// per-session temp path there.
function slug(text) {
  return String(text || "").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "")
}

// The group key, rebuilt from a row's fields: per site for a browser,
// otherwise per app.
function regroup(row) {
  var app = String(row.app || "")
  var source = String(row.source || "")
  if (isBrowser(app) && source && source !== app && hostname(source)) return "web:" + hostname(source)
  return "app:" + slug(app)
}
