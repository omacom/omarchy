// The sole external-navigation policy. QML JS has no WHATWG URL constructor;
// accept a deliberately narrow ASCII grammar, not every browser URL spelling.
.pragma library
var MAX_APP_NAME=256, MAX_SUMMARY=2048, MAX_BODY=32768
var MAX_ACTIONS=16, MAX_ACTION_LABEL=256, MAX_ACTION_ID=256, MAX_SOURCE=253
var MAX_URL=4096, MAX_CODES=8
function bounded(value, max) { return typeof value === 'string' ? value.slice(0,max) : '' }
function containsControlChars(s) { return /[\x00-\x20\x7f-\x9f\\]/.test(s) }
function canonicalHostname(raw) {
  if (typeof raw !== 'string' || raw.length > MAX_SOURCE) return ''
  var h=raw.toLowerCase().replace(/\.$/,'')
  if (!/^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?(?:\.[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?)+$/.test(h)) return ''
  // WHATWG parses a numeric-looking last label (decimal, octal, 0x hex) as an
  // IPv4 address, so "0x7f.0x0.0x0.0x1" would reach 127.0.0.1.
  if (/^(?:0x[0-9a-f]*|[0-9]+)$/i.test(h.split('.').pop())) return ''
  return h
}
function urlHasUserInfo(s) { return /^[a-z]+:\/\/[^/?#]*@/i.test(s) }
function safeHttpUrl(raw) {
  if (typeof raw !== 'string' || raw.length > MAX_URL || containsControlChars(raw)) return ''
  // Reject nested escapes and encoded controls; never decode and re-authorize.
  if (/%(?:0[0-9a-f]|1[0-9a-f]|7f|25|5c)/i.test(raw) || /[<>"']/.test(raw)) return ''
  var m=raw.match(/^(https?):\/\/([^/?#]+)([^]*)$/i)
  if (!m || urlHasUserInfo(raw)) return ''
  var a=m[2].match(/^([^:%@]+)(?::([0-9]{1,5}))?$/)
  if (!a) return ''
  var h=canonicalHostname(a[1])
  if (!h || (a[2] && (+a[2]<1 || +a[2]>65535))) return ''
  // Invalid escapes can acquire different meaning in different URL handlers.
  if (/%(?![0-9a-f]{2})/i.test(m[3])) return ''
  return m[1].toLowerCase()+'://'+h+(a[2]?':'+String(+a[2]):'')+(m[3]||'/')
}
function safeMailtoUrl(raw) {
  if (typeof raw !== 'string' || raw.length > MAX_URL || containsControlChars(raw)) return ''
  // One address only: no headers, attachments, percent encoding or URI queries.
  var m=raw.match(/^mailto:([a-z0-9.!#$&'*+\/=?^_`{|}~-]{1,64})@([^?\/#]+)$/i)
  if (!m || /[?#]/.test(m[1])) return ''
  var h=canonicalHostname(m[2]); return h ? 'mailto:'+m[1]+'@'+h : ''
}
function safeExternalUrl(raw) { return /^mailto:/i.test(raw) ? safeMailtoUrl(raw) : safeHttpUrl(raw) }
function hostOf(raw) {
  var u=safeHttpUrl(raw), m=u.match(/^https?:\/\/([^/:?#]+)/)
  return m ? m[1] : ''
}
function openExternalUrl(raw, open) {
  var safe=safeExternalUrl(raw)
  return safe ? open(safe) : false
}

// The omarchy-exec-argv hint (omarchy-notification-send --exec). Structural
// only: fails closed on a malformed or oversized argv or a leading-dash
// program, but does not judge intent. Any session-bus sender may set it (see
// docs/notifications.md); Util.execArgv never re-parses it as a shell string.
function parseExecArgv(value) {
  if (Array.isArray(value)) {
    try { value = JSON.stringify(value) } catch (e) { return null }
  }
  var text = String(value || "")
  if (!text || text.length > MAX_BODY) return null

  var parsed
  try { parsed = JSON.parse(text) } catch (e) { return null }
  if (!Array.isArray(parsed) || parsed.length === 0 || parsed.length > 32) return null
  for (var i = 0; i < parsed.length; i++) {
    // A NUL cannot travel in an argv: Qt would cut the argument short there.
    if (typeof parsed[i] !== "string" || parsed[i].length > MAX_URL || parsed[i].indexOf("\u0000") >= 0) return null
  }
  if (!parsed[0] || parsed[0].charAt(0) === "-") return null
  return parsed
}

// The omarchy-actions hint (omarchy-notification-send --action): up to three
// buttons, each a label and an argv held to the same rules as the click.
var MAX_EXEC_ACTIONS = 3
function parseExecActions(value) {
  var text = String(value || "")
  if (!text || text.length > MAX_BODY) return null
  var parsed
  try { parsed = JSON.parse(text) } catch (e) { return null }
  if (!Array.isArray(parsed) || parsed.length === 0 || parsed.length > MAX_EXEC_ACTIONS) return null
  var out = []
  for (var i = 0; i < parsed.length; i++) {
    var entry = parsed[i]
    if (!entry || typeof entry !== "object" || typeof entry.label !== "string") return null
    var label = entry.label.slice(0, MAX_ACTION_LABEL)
    var argv = parseExecArgv(entry.argv)
    if (!label.trim() || !argv) return null
    out.push({ label: label, argv: argv })
  }
  return out
}

// The omarchy-glyph hint: a few code points for the icon slot.
function safeGlyph(value) {
  var text = typeof value === "string" ? value : ""
  if (!text || text.length > 16 || /[\x00-\x1f\x7f-\x9f]/.test(text)) return ""
  return text
}

// A sender's picture as a local file: the image-path hint, which Quickshell
// hands over as image://icon//path, or a file:// URL. It is decoded in the
// shell like every other image the shell draws, which is fine now that nothing
// is fetched: a native sender runs as you and could open the file itself, and
// a sandboxed one can only name a file for you to see, never read it back.
// Kernel interfaces and service state are refused by their spelling, as a read
// there can block (/dev/tty), never end (/dev/zero) or turn up secrets
// (/proc/self/environ); a symlink to them takes a sender that already writes
// your files. Nothing else
// is assumed: Chromium's temp files (/tmp/.org.chromium.Chromium.*) carry no
// extension.
var MAX_IMAGE_PATH = 1024
var KERNEL_PATHS = /^\/(?:proc|sys|dev)(?:\/|$)/
var RUN_PATHS = /^\/(?:var\/)?run(?:\/|$)/
function localImagePath(raw) {
  var text = typeof raw === "string" && raw.length <= MAX_IMAGE_PATH * 3 ? raw : ""
  if (text.indexOf("image://icon/") === 0) text = text.slice("image://icon/".length)
  if (/^file:\/\//i.test(text)) {
    if (!/^file:\/\/\//i.test(text) || /[?#]/.test(text)) return ""
    try { text = decodeURIComponent(text.slice("file://".length)) } catch (e) { return "" }
  }
  if (!text || text.length > MAX_IMAGE_PATH || text.charAt(0) !== "/" || /[\x00-\x1f\x7f-\x9f]/.test(text)) return ""
  // One spelling per file: no empty, `.` or `..` segment.
  var parts = text.slice(1).split("/")
  for (var i = 0; i < parts.length; i++)
    if (parts[i] === "" || parts[i] === "." || parts[i] === "..") return ""
  if (KERNEL_PATHS.test(text)) return ""
  // /run holds sockets and other services' state; only a runtime dir, which
  // only its owner can read, keeps images there.
  if (RUN_PATHS.test(text) && !/^\/run\/user\/[0-9]+\/./.test(text)) return ""
  return text
}

// The file:// URL Qt loads a local image path from, each segment escaped.
function localImageUrl(path) {
  var text = localImagePath(path)
  return text ? "file://" + text.split("/").map(encodeURIComponent).join("/") : ""
}
