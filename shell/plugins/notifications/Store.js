// Pure functions over notifications: what to keep from one, how to write it
// out, how to read it back.
.pragma library
.import "Security.js" as Security
.import "Markup.js" as Markup
.import "Detect.js" as Detect

var QSIMAGE = /^image:\/\/qsimage\/[0-9]+\/[0-9]+$/

// Everything a card draws and a history entry needs, read defensively from an
// arbitrary sender.
function snapshot(n, key, urgencyEnum) {
  var expire = Number(n.expireTimeout || 0)
  if (!isFinite(expire) || expire < 0) expire = 0
  // `-i some-icon` arrives as image "image://icon/some-icon": a theme name to
  // look up, not a picture (drawn raw it is a checkerboard). Pull the name out
  // before the qsimage check discards it. An absolute path (Chromium's site
  // icon) is kept as that path, once it passes Security.localImagePath.
  var img = Security.bounded(n.image, 256)
  var named = ""
  if (img.indexOf("image://icon/") === 0 && !/^image:\/\/icon\/(?:\/|file:)/i.test(img)) {
    named = img.substring("image://icon/".length)
    img = ""
  } else if (!QSIMAGE.test(img)) {
    // Read whole: a path cut short names another file.
    img = Security.localImagePath(n.image)
  }
  var hints = n.hints || {}
  var raw = { app: Security.bounded(n.appName, Security.MAX_APP_NAME), summary: Security.bounded(n.summary, Security.MAX_SUMMARY),
              body: Security.bounded(n.body, Security.MAX_BODY) }
  // The real source, and the body with the browser's origin anchor lifted off.
  // Detection scans the lifted body so Chrome does not offer to open the site
  // it announced itself with.
  var id = Markup.identify(raw)
  var found = Detect.scan(id.summary, id.body)
  // The hint may arrive as a list, which normalise() would read as no string.
  var argv = Security.parseExecArgv(hints["omarchy-exec-argv"])
  return normalise({
    key: key,
    originalId: n.id || 0,
    // A terminal relaying a notification owns a window; its pid says which.
    senderPid: Number(hints["sender-pid"] || 0) || 0,
    execArgv: argv ? JSON.stringify(argv) : "",
    glyph: hints["omarchy-glyph"],
    transient: hints["transient"] === true || hints["transient"] === 1,
    app: raw.app,
    // Else the desktop-entry hint, which names the app's .desktop file and so,
    // usually, its icon. normalise() drops it when it is a path (Chrome's).
    appIcon: Security.bounded(n.appIcon || named || n.desktopEntry, 256),
    summary: id.summary,
    body: id.body,
    // What the sender sent, so a replay keeps the source anchor.
    rawBody: raw.body,
    source: id.source,
    code: found.code,
    codes: found.codes,
    link: found.link,
    image: img,
    urgency: typeof n.urgency === "number" ? n.urgency : urgencyEnum.Normal,
    expireTimeout: expire,
    ts: Date.now() / 1000
  })
}

// The fields an in-place update (replaces_id) must write through to the row.
var ROLES = ["originalId", "senderPid", "execArgv", "glyph", "transient", "app", "appIcon", "summary", "body", "rawBody", "bodyRich",
             "bodyLine", "source", "groupKey", "image", "urgency",
             "expireTimeout", "duration", "ts",
             "code", "codes", "link"]

function applyTo(model, index, row) {
  var current = model.get(index)
  for (var i = 0; i < ROLES.length; i++) {
    var role = ROLES[i]
    if (current[role] !== row[role]) model.setProperty(index, role, row[role])
  }
}

// A restored row has no live sender, and its original timeout has long run
// out. It gets a short grace instead; critical still waits for you.
var RESTORE_GRACE = 20000

// Every field a row can have, with its default. A ListModel fixes its roles
// from the first row it sees and silently drops keys that row lacked, so every
// row goes through normalise() and carries every field.
var SHAPE = {
  key: "", originalId: 0, senderPid: 0, execArgv: "", glyph: "", transient: false, app: "", appIcon: "", summary: "", body: "",
  bodyRich: "", bodyLine: "", rawBody: "", source: "", groupKey: "", image: "",
  code: "", codes: "", link: "",
  urgency: 1, expireTimeout: 0, duration: 0, ts: 0,
  restored: false
}

function normalise(row) {
  var out = {}
  for (var k in SHAPE) {
    var value = row ? row[k] : undefined
    if (typeof SHAPE[k] === "string") out[k] = Security.bounded(value, Security.MAX_BODY)
    else if (typeof SHAPE[k] === "number") out[k] = typeof value === "number" && isFinite(value) ? value : SHAPE[k]
    else out[k] = value === true
  }
  out.app = out.app.slice(0, Security.MAX_APP_NAME)
  out.summary = out.summary.slice(0, Security.MAX_SUMMARY)
  out.source = out.source.slice(0, Security.MAX_SOURCE)
  out.appIcon = /^[a-zA-Z0-9_.-]{1,256}$/.test(out.appIcon) ? out.appIcon : ""
  out.link = Security.safeHttpUrl(out.link)
  out.glyph = Security.safeGlyph(out.glyph)
  var argv = Security.parseExecArgv(out.execArgv)
  out.execArgv = argv ? JSON.stringify(argv) : ""
  out.codes = out.codes.split(" ").slice(0, Security.MAX_CODES).join(" ")
  // qsimage is in-process pixels; anything else must be a local path the
  // policy accepts, kept in its one canonical spelling.
  out.image = QSIMAGE.test(out.image) ? out.image : Security.localImagePath(out.image)
  // Derived fields are recomputed, never trusted: a stored row from an older
  // build picks up today's rendering and grouping rules.
  out.bodyRich = Markup.render(out.body)
  out.bodyLine = Markup.oneLine(out.body)
  out.groupKey = Markup.regroup(out)
  return out
}

function restored(entry) {
  if (!entry || !entry.key) return null
  var row = normalise(entry)
  // persistable() drops the link so a stored entry cannot
  // assert capabilities. Recompute them from the text and re-validate. Codes
  // are not recomputed: a redacted entry has nothing left to find.
  var found = Detect.scan(row.summary, row.body)
  row.link = found.link
  row = normalise(row)
  row.duration = row.urgency === 2 ? 0 : RESTORE_GRACE
  row.restored = true
  return row
}

// ------------------------------------------------------------ persistence
//
// Service.qml keeps three files in ~/.local/state/omarchy/notifications/:
// live.json (the rows on screen, oldest first, restored after a restart),
// history.json (closed rows, newest first) and quiet.json. A row goes through
// persistable() on the way out and again on the way back in, so one an older
// build or another program wrote is held to today's rules.

var KEY = /^[A-Za-z0-9_-]{1,120}$/
var LIVE_LIMIT = 100
var HISTORY_LIMIT = 100
var RETENTION_HOURS = [0, 1, 24, 168]
// A live row is what a restored card draws; a history row is a one-line
// preview in the panel, so its text is cut much shorter.
var LIVE_ROW_CHARS = 16384
var HISTORY_ROW_CHARS = 4096
// The closing reasons that mean "this never reached the screen".
var HELD_REASONS = ["snoozed", "silenced"]

// What a stored row keeps. Derived text is recomputed on restore; codes,
// links and images never persist, so a stored row cannot assert a
// capability.
var STORED = ["key", "originalId", "senderPid", "execArgv", "glyph", "app", "appIcon", "summary", "body",
              "rawBody", "source", "groupKey", "urgency", "expireTimeout", "duration", "ts"]

function storedSize(row) { return JSON.stringify(row).length }

// Long text is cut until the row fits: the body first, then the click
// command, then the summary.
function persistable(row, limit) {
  var clean = sanitiseForPersistence(row), out = {}
  for (var i = 0; i < STORED.length; i++) out[STORED[i]] = clean[STORED[i]]
  if (out.rawBody === out.body) out.rawBody = ""
  limit = limit || LIVE_ROW_CHARS
  while (storedSize(out) > limit && (out.body || out.rawBody)) {
    out.body = out.body.slice(0, Math.floor(out.body.length * 3 / 4))
    out.rawBody = out.rawBody.slice(0, Math.floor(out.rawBody.length * 3 / 4))
  }
  if (storedSize(out) > limit) out.execArgv = ""
  while (storedSize(out) > limit && out.summary)
    out.summary = out.summary.slice(0, Math.floor(out.summary.length * 3 / 4))
  return out
}

// A closed row for history, stamped with when and why it closed.
function closedEntry(row, reason, now) {
  var out = persistable(row, HISTORY_ROW_CHARS)
  out.closed_ts = now
  out.closed_reason = /^[a-z]{1,32}$/.test(String(reason)) ? String(reason) : ""
  return out
}

function retentionHours(hours) {
  return RETENTION_HOURS.indexOf(hours) >= 0 ? hours : 24
}

// Every entry is somebody's message, so history keeps only the recent past:
// whichever of the count and the retention hours bites first.
function retain(entries, hours, now) {
  var keep = retentionHours(hours), cutoff = now - keep * 3600, out = []
  for (var i = 0; keep && i < entries.length && out.length < HISTORY_LIMIT; i++)
    if (entries[i].closed_ts > cutoff) out.push(entries[i])
  return out
}

function addHistory(entries, entry, hours, now) {
  return retain([entry].concat(entries), hours, now)
}

function held(entries, limit) {
  var out = []
  for (var i = 0; i < entries.length && out.length < limit; i++)
    if (HELD_REASONS.indexOf(entries[i].closed_reason) >= 0) out.push(entries[i])
  return out
}

// A newer row for the same key replaces the old one in place; the oldest go
// once there are more than the deck can hold.
function putLive(entries, row) {
  var out = [], replaced = false
  for (var i = 0; i < entries.length; i++) {
    if (entries[i].key === row.key) { out.push(row); replaced = true }
    else out.push(entries[i])
  }
  if (!replaced) out.push(row)
  return out.slice(-LIVE_LIMIT)
}

function liveEntry(entries, key) {
  for (var i = 0; i < entries.length; i++) if (entries[i].key === key) return entries[i]
  return null
}

function dropLive(entries, key) {
  return entries.filter(function(entry) { return entry.key !== key })
}

// Rows read back at startup sit under any that arrived while the file was
// being read: those are newer.
function mergeLive(stored, current) {
  var out = stored.slice()
  for (var i = 0; i < current.length; i++) out = putLive(out, current[i])
  return out
}

// A stored file, read defensively: anything but an array of keyed objects is
// nothing, an oversized file is not parsed at all, and every row is
// re-sanitised. History rows must also carry when they closed.
function parseStored(text, limit, rowChars, history) {
  var raw = String(text || "")
  if (!raw.trim() || raw.length > limit * rowChars * 2) return []
  var value
  try { value = JSON.parse(raw) } catch (e) { return [] }
  if (!Array.isArray(value)) return []
  var out = [], seen = Object.create(null)
  for (var i = 0; i < value.length && out.length < limit; i++) {
    var entry = value[i]
    if (!entry || typeof entry !== "object" || Array.isArray(entry)) continue
    if (typeof entry.key !== "string" || !KEY.test(entry.key)) continue
    if (history) {
      if (typeof entry.closed_ts !== "number" || !isFinite(entry.closed_ts)) continue
      out.push(closedEntry(entry, entry.closed_reason, entry.closed_ts))
    } else if (!seen[entry.key]) {
      seen[entry.key] = true
      out.push(persistable(entry, rowChars))
    }
  }
  return out
}

function parseLive(text) { return parseStored(text, LIVE_LIMIT, LIVE_ROW_CHARS, false) }
function parseHistory(text) { return parseStored(text, HISTORY_LIMIT, HISTORY_ROW_CHARS, true) }

function serialise(entries) { return JSON.stringify(entries) + "\n" }

// Rows for the panel and for replay: every field a ListModel row has.
function displayRows(entries) {
  return entries.map(normalise)
}

// quiet.json: snoozed sources, Do Not Disturb, when silencing began, and
// whether codes get through. null when there is nothing usable in it.
function parseQuiet(text) {
  var raw = String(text || "")
  if (!raw.trim() || raw.length > 262144) return null
  var read
  try { read = JSON.parse(raw) } catch (e) { return null }
  if (!read || typeof read !== "object" || Array.isArray(read)) return null
  var snoozes = {}, given = read.snoozes
  if (given && typeof given === "object" && !Array.isArray(given)) {
    for (var k in given) {
      if (k === "__proto__") continue
      var entry = given[k], until = entry ? Number(entry.until) : NaN
      if (!entry || typeof entry !== "object" || !isFinite(until)) continue
      var since = Number(entry.since || 0)
      snoozes[k] = { until: until, label: Security.bounded(String(entry.label || k), 256),
                     since: isFinite(since) ? since : 0 }
    }
  }
  var silencedSince = Number(read.silencedSince || 0)
  return { snoozes: snoozes, dnd: read.dnd === true, silencedSince: isFinite(silencedSince) ? silencedSince : 0,
           codesBypassQuiet: typeof read.codesBypassQuiet === "boolean" ? read.codesBypassQuiet : null }
}

function serialiseQuiet(state) {
  return JSON.stringify({ snoozes: state.snoozes, dnd: !!state.dnd, silencedSince: Number(state.silencedSince || 0),
                          codesBypassQuiet: !!state.codesBypassQuiet }) + "\n"
}

// What a redacted row says, stored in English like any stored value and
// translated where it is shown.
var REDACTED_SUMMARY = "Verification notification"
var REDACTED_BODY = "[redacted]"

function redacted(row) {
  return !!row && row.summary === REDACTED_SUMMARY && (row.body === REDACTED_BODY || row.bodyLine === REDACTED_BODY)
}

// A secret-bearing notification persists only as a placeholder, so encoded
// variants, URLs and sender metadata cannot leak it.
function sanitiseForPersistence(row) {
  var out = normalise(row)
  // Strip literal markup before detection so long attributes cannot push a
  // code outside the keyword window in a legacy/raw-only entry. A row already
  // redacted stays exactly as it was written.
  var secret = out.codes || out.code || redacted(out) || Detect.codes(
      Markup.decodeEntities(out.summary + " " + out.rawBody + " " + out.body)
        .replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim()).length
  if (secret) {
    for (var k in SHAPE) if (typeof SHAPE[k] === "string" && k !== "key") out[k] = ""
    out.summary = REDACTED_SUMMARY
    out.body = REDACTED_BODY
    out.rawBody = out.body
    out.bodyLine = out.body
    out.bodyRich = out.body
  }
  out.image = ""
  return out
}
