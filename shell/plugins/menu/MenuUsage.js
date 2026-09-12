// Frecency scoring for menu search results.
//
// Ranking a launcher by a raw activation count keeps whatever you used most
// last year ahead of what you use today: the counter only grows, so a stale
// favourite never yields. This applies Mozilla's Places model instead — every
// activation is worth less as it ages, so ranking follows current habit and an
// abandoned entry fades on its own without any pruning pass.
//
// Each activation contributes exp(-lambda * age), with lambda = ln(2)/30, so a
// visit is worth half as much after 30 days. The sum of those decayed
// contributions is the frecency.
//
// Storing that sum directly would mean rewriting every record whenever the
// clock moves. Places' trick, kept here, is to store the score at a fixed
// reference time (the last activation) and decay it on read: a record's live
// score is score * exp(-lambda * (now - scoredAt)). Writes stay O(1) and touch
// only the row that was activated.

var MS_PER_DAY = 86400000
var HALF_LIFE_DAYS = 30
var DECAY_LAMBDA = Math.LN2 / HALF_LIFE_DAYS

// Below this a record is indistinguishable from never-used and is dropped on
// write. One activation decays to 0.001 after ~300 days.
var MIN_SCORE = 0.001

// Weights mirror Places' visit buckets: a deliberate pick counts for more than
// an incidental one. Apps and actions are what the user aimed at; menus and
// links are usually a step on the way somewhere else.
var WEIGHTS = {
  app: 1.0,
  action: 1.0,
  menu: 0.6,
  link: 0.6
}
var DEFAULT_WEIGHT = 1.0

function weightFor(kind) {
  var value = WEIGHTS[String(kind || "")]
  return typeof value === "number" ? value : DEFAULT_WEIGHT
}

function decayFactor(ageMs) {
  var age = Number(ageMs) || 0
  // A record written under a clock ahead of ours must not gain score.
  if (age <= 0) return 1
  return Math.exp(-DECAY_LAMBDA * (age / MS_PER_DAY))
}

function normalizeRecord(record) {
  if (!record || typeof record !== "object") return null
  var score = Number(record.score)
  var scoredAt = Number(record.scoredAt)
  var count = Number(record.count)
  if (!isFinite(score) || score <= 0) return null
  if (!isFinite(scoredAt) || scoredAt <= 0) return null
  return {
    score: score,
    scoredAt: scoredAt,
    count: isFinite(count) && count > 0 ? Math.floor(count) : 1
  }
}

function parse(rawText) {
  var next = {}
  try {
    var parsed = JSON.parse(String(rawText || "{}"))
    var source = parsed && parsed.version === 2 && parsed.records && typeof parsed.records === "object" ? parsed.records : {}
    for (var id in source) {
      var record = normalizeRecord(source[id])
      if (id && record) next[id] = record
    }
  } catch (e) {
    next = {}
  }
  return next
}

function serialize(records) {
  return JSON.stringify({ version: 2, records: records || {} }, null, 2) + "\n"
}

// The live frecency of an item: its stored score decayed to `now`.
function score(records, itemId, now) {
  var record = records && records[String(itemId || "")]
  if (!record) return 0
  return record.score * decayFactor((Number(now) || 0) - record.scoredAt)
}

function lastUsedAt(records, itemId) {
  var record = records && records[String(itemId || "")]
  return record ? record.scoredAt : 0
}

function count(records, itemId) {
  var record = records && records[String(itemId || "")]
  return record ? record.count : 0
}

// Fold one activation into the record, re-basing the stored score onto `now`
// so the next read decays from this moment.
function record(records, itemId, kind, now) {
  var id = String(itemId || "")
  var next = {}
  var source = records || {}
  for (var key in source) next[key] = source[key]
  if (!id) return next

  var stamp = Number(now) || 0
  if (stamp <= 0) return next

  var previous = source[id]
  var carried = previous ? previous.score * decayFactor(stamp - previous.scoredAt) : 0

  next[id] = {
    score: carried + weightFor(kind),
    scoredAt: stamp,
    count: (previous ? previous.count : 0) + 1
  }
  return next
}

// Drops records that have decayed into noise. Callers prune on write so the
// file cannot grow without bound as one-off entries accumulate.
function prune(records, now) {
  var next = {}
  var source = records || {}
  var stamp = Number(now) || 0
  for (var id in source) {
    if (score(source, id, stamp) >= MIN_SCORE) next[id] = source[id]
  }
  return next
}

if (typeof module !== "undefined") {
  module.exports = {
    HALF_LIFE_DAYS: HALF_LIFE_DAYS,
    MIN_SCORE: MIN_SCORE,
    weightFor: weightFor,
    decayFactor: decayFactor,
    parse: parse,
    serialize: serialize,
    score: score,
    lastUsedAt: lastUsedAt,
    count: count,
    record: record,
    prune: prune
  }
}
