function parseEmojis(raw) {
  try {
    var data = JSON.parse(String(raw || ""))
    return Array.isArray(data) ? data : []
  } catch (e) {
    return []
  }
}

// Use counts keyed by emoji, e.g. { "👍": 12 }. Hand edits may be wrong, so
// only positive numeric counts are kept.
function parseUsage(raw) {
  var usage = {}
  try {
    var data = JSON.parse(String(raw || ""))
    if (data && typeof data === "object" && !Array.isArray(data)) {
      for (var key in data) {
        if (typeof data[key] === "number" && data[key] > 0) usage[key] = data[key]
      }
    }
  } catch (e) {}
  return usage
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

// Emojis ranked by use count, topped up from the catalog so the rows stay full.
// Only emojis from the catalog count, so a mistyped key never takes a cell.
// Nothing picked yet means no section at all, rather than rows of filler.
function mostUsed(emojis, counts, count) {
  var catalog = (Array.isArray(emojis) ? emojis : []).map(function(item) { return item && item.e })
  var top = Object.keys(counts)
    .filter(function(emoji) { return catalog.indexOf(emoji) >= 0 })
    .sort(function(a, b) { return counts[b] - counts[a] })
    .slice(0, Math.max(0, count))
  if (top.length === 0) return top
  for (var i = 0; top.length < count && i < catalog.length; i++) {
    if (catalog[i] && top.indexOf(catalog[i]) < 0) top.push(catalog[i])
  }
  return top
}

if (typeof module !== "undefined") {
  module.exports = {
    parseEmojis: parseEmojis,
    parseUsage: parseUsage,
    normalizedQuery: normalizedQuery,
    filterEmojis: filterEmojis,
    mostUsed: mostUsed
  }
}
