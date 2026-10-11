.pragma library
.import "Flavors.js" as Flavors
.import "Tests.js" as Tests

// What Rex keeps in ~/.local/share/rex/: the session it reopens
// with, saved patterns, and recent ones. Every file carries a version, and
// everything read back is normalized, so a hand-edited or older file never
// breaks Rex.

var VERSION = 1
// Test text kept with a session or saved pattern; a larger text is better
// reopened from its file.
var MAX_TEXT = 65536
var MAX_HISTORY = 200

function str(value, fallback) {
  return typeof value === "string" ? value : (fallback || "")
}

function list(value) {
  return Array.isArray(value) ? value : []
}

// The parts of the workbench a session or a saved pattern holds.
function normalizeWork(raw) {
  var r = raw && typeof raw === "object" ? raw : {}
  var flavor = Flavors.exists(r.flavor) ? r.flavor : Flavors.DEFAULT_FLAVOR
  return {
    pattern: str(r.pattern),
    flavor: flavor,
    flags: Flavors.validFlags(flavor, list(r.flags)),
    text: str(r.text).substr(0, MAX_TEXT),
    textFile: str(r.textFile),
    replacement: str(r.replacement),
    listTemplate: str(r.listTemplate, "$&\n"),
    tests: list(r.tests).map(Tests.normalize),
    all: r.all !== false,
  }
}

function normalizeSession(raw) {
  var r = raw && typeof raw === "object" ? raw : {}
  var work = normalizeWork(r)
  work.tool = ["", "substitute", "list", "split"].indexOf(r.tool) >= 0 ? r.tool : ""
  work.sideTab = ["matches", "explain", "optimize", "tests"].indexOf(r.sideTab) >= 0 ? r.sideTab : "matches"
  work.page = str(r.page, "workbench")
  return work
}

function normalizeEntry(raw, now) {
  var r = raw && typeof raw === "object" ? raw : {}
  var entry = normalizeWork(r)
  entry.id = str(r.id) || ("p" + (now || Date.now()).toString(36) + Math.floor(Math.random() * 1e6).toString(36))
  entry.name = str(r.name).trim() || entry.pattern.substr(0, 40) || "Untitled"
  entry.description = str(r.description)
  entry.tags = list(r.tags).filter(function(t) { return typeof t === "string" && t.trim() !== "" }).map(function(t) { return t.trim() })
  entry.created = typeof r.created === "number" ? r.created : (now || Date.now())
  entry.updated = typeof r.updated === "number" ? r.updated : entry.created
  return entry
}

function parse(text) {
  try { return JSON.parse(text) } catch (e) { return null }
}

function readSession(text) {
  var doc = parse(text)
  return doc ? normalizeSession(doc.session || doc) : null
}

function writeSession(session) {
  return JSON.stringify({ version: VERSION, session: normalizeSession(session) }, null, 2) + "\n"
}

function readLibrary(text) {
  var doc = parse(text)
  var entries = doc ? list(doc.patterns) : []
  return entries.map(function(e) { return normalizeEntry(e) })
}

function writeLibrary(entries) {
  return JSON.stringify({ version: VERSION, patterns: entries.map(function(e) { return normalizeEntry(e) }) }, null, 2) + "\n"
}

// Saving under a name that exists replaces that entry.
function save(entries, work, name, now) {
  var at = -1
  for (var i = 0; i < entries.length; i++) if (entries[i].name === name) at = i
  var entry = normalizeEntry({}, now)
  var w = normalizeWork(work)
  for (var k in w) entry[k] = w[k]
  entry.name = String(name || "").trim() || entry.pattern.substr(0, 40) || "Untitled"
  if (at >= 0) {
    entry.id = entries[at].id
    entry.created = entries[at].created
    entry.tags = entries[at].tags
    entry.description = entries[at].description
  }
  entry.updated = now || Date.now()
  var out = entries.slice()
  if (at >= 0) out[at] = entry
  else out.unshift(entry)
  return out
}

function remove(entries, id) {
  return entries.filter(function(e) { return e.id !== id })
}

function search(entries, query) {
  var q = String(query || "").toLowerCase().trim()
  if (q === "") return entries
  return entries.filter(function(e) {
    return e.name.toLowerCase().indexOf(q) >= 0 || e.pattern.toLowerCase().indexOf(q) >= 0
      || e.description.toLowerCase().indexOf(q) >= 0
      || e.tags.some(function(t) { return t.toLowerCase().indexOf(q) >= 0 })
  })
}

function readHistory(text) {
  var doc = parse(text)
  return (doc ? list(doc.history) : []).filter(function(h) { return h && typeof h.pattern === "string" && h.pattern !== "" })
    .map(function(h) { return { pattern: h.pattern, flavor: Flavors.exists(h.flavor) ? h.flavor : Flavors.DEFAULT_FLAVOR, flags: list(h.flags), time: typeof h.time === "number" ? h.time : 0 } })
}

function writeHistory(history) {
  return JSON.stringify({ version: VERSION, history: history }, null, 2) + "\n"
}

// The newest pattern first; the same pattern and flavor only once.
function remember(history, item, now) {
  var out = [{ pattern: item.pattern, flavor: item.flavor, flags: list(item.flags).slice(), time: now || Date.now() }]
  for (var i = 0; i < history.length && out.length < MAX_HISTORY; i++) {
    var h = history[i]
    if (h.pattern === item.pattern && h.flavor === item.flavor) continue
    out.push(h)
  }
  return out
}

if (typeof module !== "undefined") module.exports = {
  VERSION: VERSION, MAX_TEXT: MAX_TEXT, MAX_HISTORY: MAX_HISTORY,
  normalizeSession: normalizeSession, normalizeEntry: normalizeEntry,
  readSession: readSession, writeSession: writeSession,
  readLibrary: readLibrary, writeLibrary: writeLibrary,
  save: save, remove: remove, search: search,
  readHistory: readHistory, writeHistory: writeHistory, remember: remember,
}
