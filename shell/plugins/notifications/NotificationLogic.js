function isChromiumDerived(app, appIcon) {
  var source = (String(app || "") + "\n" + String(appIcon || "")).toLowerCase()
  return source.indexOf("chrom") >= 0 || source.indexOf("brave") >= 0 ||
         source.indexOf("vivaldi") >= 0 || source.indexOf("microsoft-edge") >= 0 ||
         source.indexOf("opera") >= 0
}

// True when a `<...>` run is an image tag, so the name is read the way Qt's
// parser reads it: after the `<`, the leading run of letters and digits.
//
// Skip everything up to that run rather than matching the separator, because
// there is no JavaScript expression for what Qt skips. QQuickStyledText calls
// skipSpace(), which is QChar::isSpace(), and that set is not `\s`: Qt counts
// U+0085 NEL and `\s` does not, while `\s` counts U+FEFF and Qt does not. A
// name read with `\s` therefore misses a tag written as `<`, U+0085, `img`:
// Qt skips the NEL, reads `img` and issues the GET, while the regex finds no
// name at all and the tag is kept. Measured against Qt 6.11.2.
//
// Over-skipping is the safe direction. It can only classify more runs as
// images, and dropping a run never manufactures a tag: a dropped run joins two
// stretches of text that each contain no `<`.
function isImageTag(tag) {
  var name = /^<[^A-Za-z0-9]*([A-Za-z0-9]+)/.exec(tag)
  return !!name && name[1].toLowerCase() === "img"
}

// The body renders as StyledText so notifications can use the markup the
// body-markup capability advertises (see Service.qml). StyledText honours
// <img src>, and a remote src makes the shell issue an unauthenticated GET
// with no user action, so image tags go before the renderer sees them.
//
// Work in whole tags, never in substrings of one. A `<` opens a tag that runs
// to the next `>`, nested `<` and all, and only a tag whose own name is `img`
// is dropped.
//
// That is the conservative bound, not Qt's exact one: Qt lets a `>` inside a
// quoted attribute value pass without closing the tag, so a Qt tag can be
// longer than the run taken here. Do not "correct" this to match Qt. Taking
// the shorter run only ever splits one Qt tag into several, and a split can
// only expose an `<img` to be dropped, never hide one — whereas honouring
// quotes would let `<b title="a>b"><img src="http://host/x.png">` through.
//
// Deleting a substring is what makes a naive `/<img[^>]*>/g` unsafe. Given
//
//   <im<img src="http://a/decoy.png">g src="http://a/beacon.png">
//
// Qt reads ONE malformed tag named `im` and renders nothing, but removing the
// inner match closes the surviving halves up into `<img src=".../beacon.png">`
// — a live tag the input never contained. The stripper would be manufacturing
// the very thing it exists to remove.
//
// Because every `<` opens a tag, the text between tags never contains one, so
// dropping a tag cannot splice its neighbours into a new one. That makes a
// single pass sufficient, with no re-scanning and no input bound to police.
function stripImageTags(text) {
  var out = ""
  var i = 0

  while (i < text.length) {
    var open = text.indexOf("<", i)
    if (open === -1) {
      out += text.slice(i)
      break
    }

    out += text.slice(i, open)

    // An unterminated tag at the end of the string still reaches the renderer,
    // which closes it itself, so treat the remainder as one tag.
    var close = text.indexOf(">", open)
    var tag = close === -1 ? text.slice(open) : text.slice(open, close + 1)

    if (!isImageTag(tag)) out += tag
    i = close === -1 ? text.length : close + 1
  }

  return out
}

// What the card renders, and the last thing to touch the string before Qt parses
// it. The newline rewrite belongs here rather than in the card because it inserts
// `<br/>` into text stripImageTags chose to KEEP, and a kept tag may hold a `<` of
// its own: `<x`, newline, `<img src="http://…">` is one tag named `x` to both the
// stripper and Qt, until the rewrite splits it into `<x<br/>` and a live image tag
// the input never contained. Measured against Qt 6.11.2 — the rewritten form
// fetches, the original does not. So strip again after, and what Qt parses is what
// was checked last.
function styledBody(body, app, appIcon) {
  return stripImageTags(sanitizeBody(body, app, appIcon).replace(/\r\n|\r|\n/g, "<br/>"))
}

function sanitizeBody(body, app, appIcon) {
  var text = stripImageTags(String(body || ""))
  if (!isChromiumDerived(app, appIcon)) return text

  return text
    .replace(/^\s*<a\b[^>]*>\s*(?:https?:\/\/|www\.)?(?:[a-z0-9-]+\.)+[a-z]{2,}(?::\d+)?(?:\/[^<\s]*)?\s*<\/a>\s*/i, "")
    .replace(/^\s*(?:https?:\/\/|www\.)?(?:[a-z0-9-]+\.)+[a-z]{2,}(?::\d+)?(?:\/\S*)?\s+/i, "")
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

function shouldBypassDnd(notification, criticalUrgency) {
  var appName = String((notification && notification.appName) || "")
  if (appName === "omarchy-action") return true
  return appName === "notify-send" && notification && notification.urgency === criticalUrgency
}

function isEphemeralApp(appName) {
  var name = String(appName || "")
  return name === "notify-send" || name === "omarchy-action"
}

function stringHint(hints, name) {
  try {
    if (hints) {
      var value = hints[name]
      if (value !== undefined && value !== null) return String(value)
    }
  } catch (e) {
  }
  return ""
}

function glyphFromHints(hints) {
  return stringHint(hints, "omarchy-glyph")
}

// The click action: a JSON argv string from omarchy-notification-send
// --exec. Carried as data so a toast restored after a shell restart stays
// clickable (a libnotify action can't — its sender is gone). Run via
// Util.execArgv as bash positional parameters, never a shell string, so
// attacker-controlled values (a title, a filename) can't become commands.
function execArgvFromHints(hints) {
  return stringHint(hints, "omarchy-exec-argv")
}

// Validate a persisted omarchy-exec-argv into a runnable argv, or null. This is
// a STRUCTURAL check only: it fails closed on a malformed hint (non-array, a
// non-string or empty program, or a leading-dash program that argv would read as
// an option). It does not judge intent — a well-formed ["bash","-c",…] is
// accepted. WHICH senders may set this hint is a separate boundary: any
// session-bus process can, by the freedesktop protocol's design (see
// docs/notifications.md), which is equivalent to same-uid code execution.
function parseExecArgv(value) {
  var text = String(value || "")
  if (!text) return null

  var parsed
  try {
    parsed = JSON.parse(text)
  } catch (e) {
    return null
  }

  if (!Array.isArray(parsed) || parsed.length === 0) return null
  for (var i = 0; i < parsed.length; i++) {
    if (typeof parsed[i] !== "string") return null
  }
  if (!parsed[0] || parsed[0].charAt(0) === "-") return null
  return parsed
}

function shouldRenderCompactGlyph(glyph, iconSource, singleLineToast) {
  return String(glyph || "").length > 0 && String(iconSource || "").length === 0 && !!singleLineToast
}

function snapshotOf(notification, timestamp) {
  var n = notification || {}
  var id = n.id || 0
  var expireTimeout = Number(n.expireTimeout || 0)
  if (!isFinite(expireTimeout) || expireTimeout < 0) expireTimeout = 0
  return {
    id: id,
    originalId: id,
    app: n.appName || "",
    appIcon: n.appIcon || "",
    summary: String(n.summary || ""),
    body: n.body || "",
    image: n.image || "",
    glyph: glyphFromHints(n.hints),
    execArgv: execArgvFromHints(n.hints),
    urgency: n.urgency,
    expireTimeout: expireTimeout,
    timestamp: timestamp === undefined ? Date.now() : timestamp
  }
}

// Everything the popup card draws, and therefore everything an in-place
// update has to write through to the row and its file.
var POPUP_ROLES = ["app", "appIcon", "summary", "body", "image", "glyph", "execArgv", "urgency", "expireTimeout"]

function popupRoles() {
  return POPUP_ROLES
}

// Whether a refresh has anything to write. Each property a client updates
// emits its own signal, and the catch-up refresh after a row is inserted
// usually finds the object exactly as it was snapshotted — without this,
// one update would rewrite the file several times over.
function popupRowChanged(row, updated) {
  var current = row || {}
  var next = updated || {}
  for (var i = 0; i < POPUP_ROLES.length; i++) {
    var role = POPUP_ROLES[i]
    if (current[role] !== next[role]) return true
  }
  return false
}

// The same message from the same sender under a new id. A web app open in
// several tabs (HEY, Gmail, Calendar) fires one notification per tab for a
// single reminder, all within the same moment — what the user means by that
// is one toast, not a stack of identical ones. The image and click target
// count too: every screen recording toast shares its text but previews and
// opens a different file.
var DUPLICATE_ROLES = ["app", "summary", "body", "image", "execArgv"]

function isDuplicatePopup(row, snapshot) {
  if (!row || !snapshot || row.originalId === snapshot.originalId) return false
  for (var i = 0; i < DUPLICATE_ROLES.length; i++) {
    var role = DUPLICATE_ROLES[i]
    if ((row[role] || "") !== (snapshot[role] || "")) return false
  }
  return true
}

// A client updating a notification through replaces_id keeps the identity of
// the popup it took over: the file name is the timestamp and id the popup was
// first persisted under, and the restore, replace and archive paths all key
// off that name. Only what the card draws comes from the updated object.
function replacementSnapshot(notification, originalId, timestamp) {
  var updated = snapshotOf(notification, timestamp)
  updated.id = originalId
  updated.originalId = originalId
  return updated
}

function historyEntry(value, normalUrgency) {
  var e = value || {}
  return {
    id: e.id || 0,
    originalId: e.originalId || e.id || 0,
    app: e.app || "",
    appIcon: e.appIcon || "",
    summary: e.summary || "",
    body: e.body || "",
    image: e.image || "",
    glyph: e.glyph || "",
    execArgv: e.execArgv || "",
    urgency: typeof e.urgency === "number" ? e.urgency : normalUrgency,
    expireTimeout: 0,
    timestamp: e.timestamp || 0
  }
}

// notifications.json holds nothing but the last-set DND preference now that
// history is a directory of files. Older versions kept `pending`/`past`
// (and, older still, `entries`) arrays in there; their presence is reported
// so the service can rewrite the file without the dead payload.
function parseSettings(raw) {
  var text = String(raw || "").trim()
  if (!text) return { error: false, dnd: null, legacy: false }

  try {
    var parsed = JSON.parse(text)
    return {
      error: false,
      dnd: parsed && typeof parsed.dnd === "boolean" ? parsed.dnd : null,
      legacy: !!(parsed && (parsed.pending || parsed.past || parsed.entries))
    }
  } catch (e) {
    return { error: true, errorMessage: String(e), dnd: null, legacy: false }
  }
}

// ---------------------------------------------------- popup persistence
//
// Each on-screen popup is mirrored to its own file under
// ~/.local/state/omarchy/notifications/ so toasts survive shell restarts
// (e.g. the restart `omarchy-update` performs). The file exists exactly as
// long as the popup is on screen: it is written when the toast appears and
// moved into the history/ subdirectory when the toast expires, is dismissed,
// or its action is invoked. History is those moved files, newest last-10.

function popupEntry(value, normalUrgency) {
  var entry = historyEntry(value, normalUrgency)
  var expire = Number((value || {}).expireTimeout || 0)
  if (!isFinite(expire) || expire < 0) expire = 0
  entry.expireTimeout = expire
  // Absolute expiry deadline, set only when a restore resets a surviving
  // popup's display lifetime. Kept out of the entry entirely when unset so
  // restored rows match the roles of freshly received ones.
  var deadline = Number((value || {}).deadline || 0)
  if (isFinite(deadline) && deadline > 0) entry.deadline = deadline
  return entry
}

function popupFileName(entry) {
  return imageStem(entry) + ".json"
}

// ---------------------------------------------------- persisted images
//
// A notification's images only exist while it is live: Chromium-family
// senders (all Omarchy web apps) delete their scoped /tmp files on close,
// and image-data hints surface as in-process image:// URLs that die with
// the server object. Persisted entries therefore reference their own
// copies, named by the entry's file stem so cleanup can find them from
// the JSON file name alone.

var PERSISTED_IMAGE_ROLES = ["appIcon", "image"]

function imageStem(entry) {
  var e = entry || {}
  return String(e.timestamp || 0) + "-" + String(e.originalId || 0)
}

// The filesystem path behind a file-backed image value, or "" for anything
// a copy can't capture: themed icon names, in-process image:// URLs, empty.
function localImageFile(value) {
  var s = String(value || "")
  if (s.indexOf("file://") === 0) {
    s = s.slice(7)
    try { s = decodeURIComponent(s) } catch (e) {}
  }
  return s.charAt(0) === "/" ? s : ""
}

// The entry as it should hit the disk, plus the copies that make it true.
// File-backed images redirect to their copy under imagesDir; dead image://
// URLs drop to "" (the card falls back to the app icon). Already-redirected
// values map onto themselves and produce no copy, keeping restores no-ops.
function persistablePopup(entry, imagesDir) {
  var e = entry || {}
  var out = {}
  for (var key in e) out[key] = e[key]
  var copies = []
  for (var i = 0; i < PERSISTED_IMAGE_ROLES.length; i++) {
    var role = PERSISTED_IMAGE_ROLES[i]
    var value = String(out[role] || "")
    if (!value) continue
    var source = localImageFile(value)
    if (source) {
      var copy = String(imagesDir || "") + imageStem(e) + "-" + role
      if (source !== copy) copies.push({ from: source, to: copy })
      out[role] = "file://" + copy
    } else if (value.indexOf("image://") === 0) {
      out[role] = ""
    }
  }
  return { entry: out, copies: copies }
}

function serializePopup(entry, normalUrgency) {
  // Compact (single-line) on purpose: restore cats every file together and
  // parses line by line, which only works when each file is one line.
  return JSON.stringify(popupEntry(entry, normalUrgency))
}

// UTF-8 byte length of a string, without Buffer, so it works under QML too.
// String.length is UTF-16 code units, which undercounts any non-ASCII text
// once the arguments are passed to execve as UTF-8. A valid surrogate pair is
// four bytes; a lone surrogate is counted as the three-byte replacement
// character the argument encoders emit for it, never skipped as if it were
// half of a pair.
function utf8Bytes(value) {
  var s = value === undefined || value === null ? "" : String(value)
  var bytes = 0
  for (var i = 0; i < s.length; i++) {
    var code = s.charCodeAt(i)
    if (code < 0x80) bytes += 1
    else if (code < 0x800) bytes += 2
    else if (code >= 0xd800 && code <= 0xdbff &&
      i + 1 < s.length && s.charCodeAt(i + 1) >= 0xdc00 && s.charCodeAt(i + 1) <= 0xdfff) {
      bytes += 4
      i += 1
    } else bytes += 3
  }
  return bytes
}

// Every argv string a persist item contributes — name, json, copy count and
// each copy's from/to — plus a small allowance for the pointer and NUL that
// execve adds per argument.
function persistItemBytes(item) {
  var it = item || {}
  var copies = Array.isArray(it.copies) ? it.copies : []
  var bytes = utf8Bytes(it.name) + utf8Bytes(it.json) + utf8Bytes(String(copies.length))
  for (var i = 0; i < copies.length; i++) {
    var copy = copies[i] || {}
    bytes += utf8Bytes(copy.from) + utf8Bytes(copy.to)
  }
  return bytes + 8 * (3 + copies.length * 2)
}

// Linux caps a single argument at MAX_ARG_STRLEN (32 pages, 128 KiB on 4 KiB
// pages), the terminating NUL included. Leave a page of headroom so an entry
// that only just fits is still isolated rather than failing with a batch.
var PERSIST_MAX_ARG_BYTES = 131072 - 4096

// The largest single argument a persist item contributes. An item over the
// per-argument limit cannot be passed at all, so it must be kept out of any
// batch holding items that can.
function persistItemMaxArgBytes(item) {
  var it = item || {}
  var copies = Array.isArray(it.copies) ? it.copies : []
  var max = Math.max(utf8Bytes(it.name), utf8Bytes(it.json), utf8Bytes(String(copies.length)))
  for (var i = 0; i < copies.length; i++) {
    var copy = copies[i] || {}
    max = Math.max(max, utf8Bytes(copy.from), utf8Bytes(copy.to))
  }
  return max
}

// Group persist items into batches that each stay within maxCount entries and
// maxBytes of UTF-8 argument bytes. Restoring a large backlog must not run one
// shell process per entry, and bounding each command's argv keeps it
// comfortably below typical ARG_MAX. An item too large to pass as a single
// argument is isolated into a batch of its own: it still fails, but cannot
// take valid neighbours down with it and cost them their reset deadlines.
// Every batch takes at least one item, even when that item alone is over the
// byte cap.
function persistItemBatches(items, maxCount, maxBytes) {
  var list = Array.isArray(items) ? items : []
  var count = Number(maxCount)
  if (!isFinite(count) || count < 1) count = 256
  var cap = Number(maxBytes)
  if (!isFinite(cap) || cap < 1) cap = 524288
  var out = []
  var start = 0
  while (start < list.length) {
    // Too big for a single argument: its own batch, so it fails alone.
    if (persistItemMaxArgBytes(list[start]) > PERSIST_MAX_ARG_BYTES) {
      out.push([list[start]])
      start += 1
      continue
    }
    var end = start + 1
    var size = persistItemBytes(list[start])
    while (end < list.length && end - start < count) {
      // Never let an unpasseable item join, and keep the total under the cap.
      if (persistItemMaxArgBytes(list[end]) > PERSIST_MAX_ARG_BYTES) break
      var itemBytes = persistItemBytes(list[end])
      if (size + itemBytes > cap) break
      size += itemBytes
      end += 1
    }
    out.push(list.slice(start, end))
    start = end
  }
  return out
}

// A FIFO job queue with amortised O(1) enqueue and dequeue. The obvious
// concat()/slice() pair rebuilt the whole array on every operation, which made
// queueing a restore backlog quadratic in its length. The consumed prefix is
// reclaimed only once at least half the array is consumed, so the occasional
// slice still amortises to O(1) per job.
function createJobQueue(compactThreshold) {
  var items = []
  var head = 0
  var threshold = Number(compactThreshold)
  if (!isFinite(threshold) || threshold < 1) threshold = 64
  return {
    size: function() { return items.length - head },
    enqueue: function(item) { items.push(item) },
    dequeue: function() {
      if (head >= items.length) {
        items = []
        head = 0
        return null
      }
      var item = items[head]
      head += 1
      if (head >= threshold && head * 2 >= items.length) {
        items = items.slice(head)
        head = 0
      }
      return item
    }
  }
}

// ---------------------------------------------------- persisted file jobs
//
// These are the `bash -c` jobs the shell runs one at a time for persisted
// popups. Building them here keeps the shell text pure and executable by
// tests, and leaves the QML free of it.

function copyPairScript() {
  return "copy_pair() {\n" +
    "  if [[ -f $1 ]] && timeout 5 head -c 5242881 -- \"$1\" > \"$2.tmp\" 2>/dev/null &&\n" +
    "     (( $(stat -c%s -- \"$2.tmp\") <= 5242880 )); then mv -f -- \"$2.tmp\" \"$2\"; else rm -f -- \"$2.tmp\"; fi\n" +
    "}\n"
}

function copyImagesScript() {
  return copyPairScript() +
    "while (( $# >= 2 )); do copy_pair \"$1\" \"$2\"; shift 2; done\n"
}

function trimHistoryScript() {
  return "ls -1 \"$hist\" 2>/dev/null | sort -n | head -n \"-$limit\" | while IFS= read -r stale; do rm -f \"$hist/$stale\" \"$imgs/${stale%.json}\"-*; done"
}

// One job writes any number of persisted entries and copies their images. Each
// entry contributes name/json/copy-count then its from/to pairs.
function persistBatchCommand(items, dir, imagesDir) {
  var list = Array.isArray(items) ? items : []
  var command = ["bash", "-c",
    "mkdir -p \"$1\" \"$2\" || exit 0\n" +
    "dir=\"$1\" imgs=\"$2\"\n" +
    "shift 2\n" +
    copyPairScript() +
    "while (( $# > 0 )); do\n" +
    "  name=\"$1\" json=\"$2\" n=\"$3\"\n" +
    "  shift 3\n" +
    "  for (( c=0; c<n; c++ )); do copy_pair \"$1\" \"$2\"; shift 2; done\n" +
    "  printf '%s\\n' \"$json\" > \"$dir/$name\"\n" +
    "done", "--",
    String(dir || ""), String(imagesDir || "")]
  for (var i = 0; i < list.length; i++) {
    var item = list[i] || {}
    var copies = Array.isArray(item.copies) ? item.copies : []
    command.push(String(item.name || ""), String(item.json || ""), String(copies.length))
    for (var j = 0; j < copies.length; j++)
      command.push(String((copies[j] || {}).from || ""), String((copies[j] || {}).to || ""))
  }
  return command
}

// One job moves any number of live popup files into history and trims it. The
// names sort numerically by their leading timestamp.
function archiveBatchCommand(names, historyDir, limit, stateDir, imagesDir) {
  var list = Array.isArray(names) ? names : []
  var command = ["bash", "-c",
    "mkdir -p \"$1\" || exit 0\n" +
    "hist=\"$1\" limit=\"$2\" src=\"$3\" imgs=\"$4\"\n" +
    "shift 4\n" +
    "while (( $# > 0 )); do mv -f \"$src/$1\" \"$hist/$1\" 2>/dev/null; shift; done\n" +
    trimHistoryScript(), "--",
    String(historyDir || ""), String(limit), String(stateDir || ""), String(imagesDir || "")]
  for (var i = 0; i < list.length; i++) command.push(String(list[i] || ""))
  return command
}

// Parse the concatenation of every persisted popup file into entries,
// newest-first. Deliberately NO dedupe by originalId: ids restart from 1
// with every server process, so two files sharing an id are usually
// different generations — dropping the older one would silently discard a
// restored critical alert the moment a fresh notification reuses its id.
// The one case that leaves a genuine duplicate (a crash between a
// replacement's write and the replaced file's delete) merely re-shows a
// superseded toast, which expires or is dismissed and cleans itself up.
function parsePopupFiles(raw, normalUrgency) {
  var lines = String(raw || "").split("\n")
  var entries = []
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i].trim()
    if (!line) continue
    try {
      var value = JSON.parse(line)
      if (value && typeof value === "object") entries.push(popupEntry(value, normalUrgency))
    } catch (e) {
      // A torn write from a crash mid-save — skip the line, keep the rest.
    }
  }
  entries.sort(function(a, b) { return (b.timestamp || 0) - (a.timestamp || 0) })
  return entries
}

// A persisted popup whose lifetime already ran out would have expired on
// screen had the shell kept running, so it is not restored. duration 0 means
// the popup never expires (critical urgency) and always survives restarts.
// A restore-reset deadline outranks the original timestamp: without it, a
// second restart would judge a re-shown toast by a clock that no longer
// governs its display and drop it while it is still on screen.
function popupExpired(entry, duration, now) {
  var deadline = Number((entry || {}).deadline || 0)
  if (isFinite(deadline) && deadline > 0) return Number(now) >= deadline
  var lifetime = Number(duration || 0)
  if (!isFinite(lifetime) || lifetime <= 0) return false
  return (Number(now) - Number((entry || {}).timestamp || 0)) >= lifetime
}

// Startup must never hydrate an unbounded number of live rows: every append
// into popupModel does synchronous delegate-model insertion work on the main
// thread, so restoring a large backlog held the event loop hostage until it
// finished and the shell looked dead from the user's side.
//
// Persisted entries arrive newest-first (see parsePopupFiles), so the newest
// `limit` become the toasts and everything older comes back for archiving. The
// caller chooses that limit (Service.restorePopupLimit); it is deliberately not
// historyLimit, because "how much history is kept" and "how many live rows may
// be restored" are different policies that only happen to share a value. Order
// is preserved on both sides; nothing is dropped or duplicated between them.
//
// A non-finite or negative limit falls back to the default rather than
// disabling the cap, so the boundary can never be handed an unbounded value.
function splitRestoredEntries(entries, limit) {
  var max = limit === undefined || limit === null ? 10 : Number(limit)
  if (!isFinite(max) || max < 0) max = 10
  max = Math.floor(max)
  var rows = Array.isArray(entries) ? entries : []
  return { live: rows.slice(0, max), archive: rows.slice(max) }
}

function popupPlacement(barPosition, barClearance, gapsOut) {
  var position = String(barPosition || "top")
  var clearance = Number(barClearance)
  var gap = Number(gapsOut)
  if (!isFinite(clearance)) clearance = 0
  if (!isFinite(gap)) gap = 0

  return {
    anchors: { top: true, bottom: false, left: false, right: true },
    margins: {
      top: position === "top" ? clearance : gap,
      bottom: gap,
      left: gap,
      right: position === "right" ? clearance : gap
    }
  }
}

// The archived files are the history. They are read back exactly like the
// live popup files, then normalized into history rows: replaying a toast
// must not inherit the original's expire timeout or restore deadline, so it
// gets the standard on-screen lifetime for its urgency instead.
//
// liveRows are the toasts still on screen when the replay was asked for.
// They belong in it — they're the newest notifications there are — but the
// directory read races their archival, so they're carried across by hand and
// keyed by file name (timestamp + id) to drop the copy the read already saw.
function historyRows(raw, liveRows, normalUrgency, limit) {
  var max = limit === undefined || limit === null ? 10 : Number(limit)
  if (isNaN(max)) max = 10
  max = Math.max(0, max)

  var out = []
  var seen = {}
  function collect(rows) {
    for (var i = 0; i < rows.length; i++) {
      var entry = rows[i]
      if (!entry) continue
      var key = popupFileName(entry)
      if (seen[key]) continue
      seen[key] = true
      out.push(historyEntry(entry, normalUrgency))
    }
  }

  collect(Array.isArray(liveRows) ? liveRows : [])
  collect(parsePopupFiles(raw, normalUrgency))
  out.sort(function(a, b) { return (b.timestamp || 0) - (a.timestamp || 0) })
  return out.slice(0, max)
}

if (typeof module !== "undefined") {
  module.exports = {
    isChromiumDerived: isChromiumDerived,
    sanitizeBody: sanitizeBody,
    styledBody: styledBody,
    summaryStartsWithGlyph: summaryStartsWithGlyph,
    shouldBypassDnd: shouldBypassDnd,
    isEphemeralApp: isEphemeralApp,
    stringHint: stringHint,
    glyphFromHints: glyphFromHints,
    execArgvFromHints: execArgvFromHints,
    parseExecArgv: parseExecArgv,
    shouldRenderCompactGlyph: shouldRenderCompactGlyph,
    snapshotOf: snapshotOf,
    popupRoles: popupRoles,
    popupRowChanged: popupRowChanged,
    isDuplicatePopup: isDuplicatePopup,
    replacementSnapshot: replacementSnapshot,
    historyEntry: historyEntry,
    parseSettings: parseSettings,
    historyRows: historyRows,
    popupEntry: popupEntry,
    popupFileName: popupFileName,
    imageStem: imageStem,
    localImageFile: localImageFile,
    persistablePopup: persistablePopup,
    serializePopup: serializePopup,
    utf8Bytes: utf8Bytes,
    persistItemBytes: persistItemBytes,
    persistItemMaxArgBytes: persistItemMaxArgBytes,
    PERSIST_MAX_ARG_BYTES: PERSIST_MAX_ARG_BYTES,
    persistItemBatches: persistItemBatches,
    createJobQueue: createJobQueue,
    copyPairScript: copyPairScript,
    copyImagesScript: copyImagesScript,
    trimHistoryScript: trimHistoryScript,
    persistBatchCommand: persistBatchCommand,
    archiveBatchCommand: archiveBatchCommand,
    parsePopupFiles: parsePopupFiles,
    popupExpired: popupExpired,
    splitRestoredEntries: splitRestoredEntries,
    popupPlacement: popupPlacement
  }
}
