function entryName(entry) {
  return String((entry && entry.name) || (entry && entry.id) || "")
}

function entrySubtext(entry) {
  return String((entry && entry.genericName) || "")
}

function entrySortKey(entry) {
  return entryName(entry).toLowerCase()
}

function keywordText(entry) {
  try {
    var keywords = entry && entry.keywords
    if (keywords && typeof keywords.join === "function") return keywords.join(" ")
  } catch (e) {
  }
  return ""
}

function entrySearchText(entry) {
  if (!entry) return ""
  return [entry.name, entry.genericName, entry.comment, keywordText(entry), entry.id].join(" ").toLowerCase()
}

function wordText(value) {
  return String(value || "")
    .replace(/([a-z0-9])([A-Z])/g, "$1 $2")
    .replace(/[._:/\\-]+/g, " ")
    .toLowerCase()
}

function words(value) {
  var values = wordText(value).split(/[^a-z0-9]+/)
  var result = []
  for (var i = 0; i < values.length; i++) {
    if (values[i]) result.push(values[i])
  }
  return result
}

function entryAcronym(entry) {
  var values = words([entry && entry.name, entry && entry.genericName, keywordText(entry), entry && entry.id].join(" "))
  var result = ""
  for (var i = 0; i < values.length; i++) result += values[i].charAt(0)
  return result
}

// Prepared data belongs to one scoring pass; desktop metadata can change between calls.
function prepareEntry(entry, name, rawName) {
  var id = entry && entry.id
  var genericName = entry && entry.genericName
  var comment = entry && entry.comment
  var keywords = keywordText(entry)
  return {
    name: name.toLowerCase(),
    id: String(id || "").toLowerCase(),
    haystack: [rawName, genericName, comment, keywords, id].join(" ").toLowerCase(),
    acronymSource: [rawName, genericName, keywords, id].join(" "),
    acronym: null
  }
}

function preparedAcronym(data) {
  if (data.acronym === null) {
    var values = words(data.acronymSource)
    data.acronym = ""
    for (var i = 0; i < values.length; i++) data.acronym += values[i].charAt(0)
  }
  return data.acronym
}

function preparedScore(data, q, terms) {
  for (var i = 0; i < terms.length; i++) {
    var term = terms[i]
    if (term && data.name.indexOf(term) < 0 && data.id.indexOf(term) < 0 && data.haystack.indexOf(term) < 0
        && !(term.length <= 5 && preparedAcronym(data).indexOf(term) >= 0)) return -1
  }
  var name = data.name
  var id = data.id
  var directName = name.indexOf(q)
  var directId = id.indexOf(q)
  if (directName === 0) return 10000 - name.length
  if (directId === 0) return 9500 - id.length
  if (directName > 0) return 8000 - directName * 10 - name.length
  if (directId > 0) return 7600 - directId * 10 - id.length
  var hayIndex = data.haystack.indexOf(q)
  if (hayIndex >= 0) return 6000 - hayIndex
  var acronym = preparedAcronym(data)
  var acronymIndex = acronym.indexOf(q)
  if (acronymIndex === 0) return 5000 - acronym.length
  if (acronymIndex > 0) return 4600 - acronymIndex * 10 - acronym.length
  return 4000 - name.length
}

function fuzzyScore(entry, query) {
  var q = String(query || "").trim().toLowerCase()
  var terms = q.split(/\s+/)
  if (!q) return 0
  var rawName = entry && entry.name
  var name = String(rawName || (entry && entry.id) || "")
  return preparedScore(prepareEntry(entry, name, rawName), q, terms)
}

function sortedEntries(values, query, hiddenCallback) {
  var q = String(query || "").trim().toLowerCase()
  var terms = q.split(/\s+/)
  var rows = []

  for (var i = 0; i < values.length; i++) {
    var entry = values[i]
    if (!entry || entry.noDisplay) continue
    if (hiddenCallback && hiddenCallback(entry)) continue
    var rawName = entry.name
    var name = String(rawName || entry.id || "")
    if (!name) continue
    var data = q ? prepareEntry(entry, name, rawName) : null
    var score = q ? preparedScore(data, q, terms) : 0
    if (score < 0) continue
    rows.push({ entry: entry, score: score, key: name.toLowerCase(), name: name.toLowerCase() })
  }

  rows.sort(function(a, b) {
    if (q && a.score !== b.score) return b.score - a.score
    if (a.key < b.key) return -1
    if (a.key > b.key) return 1
    if (a.name < b.name) return -1
    if (a.name > b.name) return 1
    return 0
  })

  return rows
}

if (typeof module !== "undefined") {
  module.exports = {
    entryName: entryName,
    entrySubtext: entrySubtext,
    entrySortKey: entrySortKey,
    entrySearchText: entrySearchText,
    entryAcronym: entryAcronym,
    fuzzyScore: fuzzyScore,
    sortedEntries: sortedEntries
  }
}
