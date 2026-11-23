var RECENT_LIMIT = 16
var FAVORITES_ID = "favorites"
var RECENT_ID = "recent"
var RESULTS_ID = "results"

// Unicode's emoji groups in emoji-test.txt order ("Component" is left out).
// Titles come from the emojis.group.<id> catalog keys.
var GROUPS = [
  { id: "smileys", icon: "\u{F01F5}" },
  { id: "people", icon: "\u{F1822}" },
  { id: "nature", icon: "\u{F03E9}" },
  { id: "food", icon: "\u{F0C84}" },
  { id: "travel", icon: "\u{F001D}" },
  { id: "activities", icon: "\u{F04B8}" },
  { id: "objects", icon: "\u{F0336}" },
  { id: "symbols", icon: "\u{F02D5}" },
  { id: "flags", icon: "\u{F023D}" }
]

// emojis.json is a flat list of { e, k, n, g, t? }: emoji, keywords, Unicode
// name, group id and, when it has them, the five skin-tone variants.
function parseEmojis(raw) {
  try {
    var data = JSON.parse(String(raw || ""))
    return Array.isArray(data) ? data : []
  } catch (e) {
    return []
  }
}

function normalizedQuery(query) {
  return String(query || "").trim().toLowerCase()
}

function keywordText(item) {
  return String((item && item.k) || "").toLowerCase()
}

function filterEmojis(emojis, query, limit) {
  var values = Array.isArray(emojis) ? emojis : []
  var needle = normalizedQuery(query)
  var max = limit === undefined || limit === null ? 1000 : Number(limit)
  if (isNaN(max)) max = 1000
  max = Math.max(0, max)
  if (max === 0) return []

  var out = []

  for (var i = 0; i < values.length; i++) {
    var item = values[i]
    if (!item || !item.e) continue
    if (!needle || keywordText(item).indexOf(needle) >= 0) {
      out.push(item)
      if (out.length >= max) break
    }
  }

  return out
}

// Ranks name hits above keyword hits, and word starts above substrings.
// Every word of the query has to match somewhere.
function scoreEmoji(item, words) {
  var name = String(item.n || "").toLowerCase()
  var keywords = keywordText(item)
  var total = 0
  for (var i = 0; i < words.length; i++) {
    var w = words[i]
    var s = 0
    if (name === w) s = 100
    else if (name.indexOf(w) === 0) s = 80
    else if ((" " + name).indexOf(" " + w) >= 0) s = 60
    else if ((" " + keywords).indexOf(" " + w) >= 0) s = 40
    else if (keywords.indexOf(w) >= 0) s = 15
    if (!s) return 0
    total += s
  }
  return total
}

function rankEmojis(emojis, query, limit) {
  var words = normalizedQuery(query).split(/\s+/).filter(function(w) { return w.length > 0 })
  if (!words.length) return []
  var hits = []
  for (var i = 0; i < emojis.length; i++) {
    var s = emojis[i] && emojis[i].e ? scoreEmoji(emojis[i], words) : 0
    if (s) hits.push({ item: emojis[i], score: s, index: i })
  }
  hits.sort(function(a, b) { return b.score - a.score || a.index - b.index })
  return hits.slice(0, limit || 400).map(function(h) { return h.item })
}

// Every string the grid can show (base and toned) mapped to its entry, so a
// recent or favorite saved with a skin tone still finds its name.
function buildLookup(emojis) {
  var out = {}
  for (var i = 0; i < emojis.length; i++) {
    var item = emojis[i]
    if (!item || !item.e) continue
    out[item.e] = item
    if (item.t) for (var j = 0; j < item.t.length; j++) out[item.t[j]] = item
  }
  return out
}

function displayEmoji(item, tone) {
  return tone > 0 && item.t ? item.t[tone - 1] : item.e
}

// Rows for the grid: each carries its section id and title plus up to
// `columns` emoji. Sections with nothing in them are left out entirely.
// title(id, count) names a section; sections[] records where each starts.
function buildRows(emojis, prefs, filterText, columns, tone, title) {
  var rows = []
  var sections = []

  function addSection(id, cells) {
    if (!cells.length) return
    var name = title(id, cells.length)
    sections.push({ id: id, title: name, firstRow: rows.length })
    for (var i = 0; i < cells.length; i += columns)
      rows.push({ section: name, group: id, cells: cells.slice(i, i + columns) })
  }

  if (normalizedQuery(filterText)) {
    addSection(RESULTS_ID, rankEmojis(emojis, filterText, 400).map(function(item) { return displayEmoji(item, tone) }))
    return { rows: rows, sections: sections }
  }

  addSection(FAVORITES_ID, prefs.favorites.slice())
  addSection(RECENT_ID, prefs.recent.slice())

  var byGroup = {}
  for (var i = 0; i < emojis.length; i++) {
    var item = emojis[i]
    if (!item || !item.e || !item.g) continue
    ;(byGroup[item.g] = byGroup[item.g] || []).push(displayEmoji(item, tone))
  }
  for (var g = 0; g < GROUPS.length; g++) addSection(GROUPS[g].id, byGroup[GROUPS[g].id] || [])
  return { rows: rows, sections: sections }
}

function parsePrefs(raw) {
  var prefs = { recent: [], favorites: [], tone: 0 }
  try {
    var saved = JSON.parse(String(raw || ""))
    var strings = function(list) { return Array.isArray(list) ? list.filter(function(e) { return typeof e === "string" && e }) : [] }
    prefs.recent = strings(saved.recent).slice(0, RECENT_LIMIT)
    prefs.favorites = strings(saved.favorites)
    var tone = Number(saved.tone)
    if (tone >= 0 && tone <= 5) prefs.tone = Math.floor(tone)
  } catch (e) {}
  return prefs
}

function serializePrefs(prefs) {
  return JSON.stringify({ recent: prefs.recent, favorites: prefs.favorites, tone: prefs.tone }, null, 2) + "\n"
}

function withRecent(prefs, emoji) {
  var recent = [emoji].concat(prefs.recent.filter(function(e) { return e !== emoji }))
  return { recent: recent.slice(0, RECENT_LIMIT), favorites: prefs.favorites, tone: prefs.tone }
}

function withFavoriteToggled(prefs, emoji) {
  var favorites = prefs.favorites.indexOf(emoji) >= 0
    ? prefs.favorites.filter(function(e) { return e !== emoji })
    : prefs.favorites.concat([emoji])
  return { recent: prefs.recent, favorites: favorites, tone: prefs.tone }
}

function withTone(prefs, tone) {
  return { recent: prefs.recent, favorites: prefs.favorites, tone: tone }
}

if (typeof module !== "undefined") {
  module.exports = {
    RECENT_LIMIT: RECENT_LIMIT,
    FAVORITES_ID: FAVORITES_ID,
    RECENT_ID: RECENT_ID,
    RESULTS_ID: RESULTS_ID,
    GROUPS: GROUPS,
    parseEmojis: parseEmojis,
    normalizedQuery: normalizedQuery,
    filterEmojis: filterEmojis,
    rankEmojis: rankEmojis,
    buildLookup: buildLookup,
    displayEmoji: displayEmoji,
    buildRows: buildRows,
    parsePrefs: parsePrefs,
    serializePrefs: serializePrefs,
    withRecent: withRecent,
    withFavoriteToggled: withFavoriteToggled,
    withTone: withTone
  }
}
