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
    if (entry && entry.keywords && typeof entry.keywords.join === "function") return entry.keywords.join(" ")
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

var documentCache = typeof WeakMap !== "undefined" ? new WeakMap() : null

function clearDocumentCache() {
  documentCache = typeof WeakMap !== "undefined" ? new WeakMap() : null
}

function invalidateEntry(entry) {
  if (entry && documentCache && typeof documentCache.delete === "function") {
    documentCache.delete(entry)
  }
}

function buildEntryDocument(entry) {
  if (!entry) return null
  var name = entryName(entry)
  var rawKeywords = keywordText(entry)
  var comment = String((entry && entry.comment) || "")
  var genericName = String((entry && entry.genericName) || "")

  if (documentCache && documentCache.has(entry)) {
    var cached = documentCache.get(entry)
    if (cached &&
        cached.name === name &&
        cached.rawKeywords === rawKeywords &&
        cached.comment === comment &&
        cached.genericName === genericName) {
      return cached
    }
  }

  var nameLower = name.toLowerCase()
  var id = String((entry && entry.id) || "")
  var idLower = id.toLowerCase()
  var nameWords = words(name)
  var idWords = words(id)
  var searchText = entrySearchText(entry)
  var acronym = entryAcronym(entry)

  var doc = {
    entry: entry,
    name: name,
    nameLower: nameLower,
    id: id,
    idLower: idLower,
    nameWords: nameWords,
    idWords: idWords,
    searchText: searchText,
    acronym: acronym,
    sortKey: nameLower,
    rawKeywords: rawKeywords,
    comment: comment,
    genericName: genericName
  }

  if (documentCache) {
    documentCache.set(entry, doc)
  }
  return doc
}

function termMatchesDoc(doc, term) {
  if (!term) return true
  if (doc.nameLower.indexOf(term) >= 0) return true
  if (doc.idLower.indexOf(term) >= 0) return true
  if (doc.searchText.indexOf(term) >= 0) return true
  return term.length <= 5 && doc.acronym.indexOf(term) >= 0
}

function allTermsMatchDoc(doc, query) {
  var terms = String(query || "").toLowerCase().trim().split(/\s+/)
  for (var i = 0; i < terms.length; i++) {
    if (terms[i] && !termMatchesDoc(doc, terms[i])) return false
  }
  return true
}

function termMatches(entry, term) {
  var doc = buildEntryDocument(entry)
  if (!doc) return false
  return termMatchesDoc(doc, term)
}

function allTermsMatch(entry, query) {
  var doc = buildEntryDocument(entry)
  if (!doc) return false
  return allTermsMatchDoc(doc, query)
}

function fuzzyScoreDoc(doc, query) {
  var q = String(query || "").trim().toLowerCase()
  if (!q) return 0
  if (!allTermsMatchDoc(doc, q)) return -1

  var name = doc.nameLower
  var id = doc.idLower

  // Full name prefix match: top tier
  var directName = name.indexOf(q)
  if (directName === 0) return 10000 - name.length

  // Word-prefix match on name words (e.g. "Google Chrome" on "chr" ranks above generic substring)
  for (var w = 0; w < doc.nameWords.length; w++) {
    if (doc.nameWords[w].indexOf(q) === 0) {
      return 9800 - w * 20 - name.length
    }
  }

  // ID direct prefix match
  var directId = id.indexOf(q)
  if (directId === 0) return 9500 - id.length

  // Word-prefix match on ID words (e.g. org.gnome.Calculator -> calculator)
  for (var iw = 0; iw < doc.idWords.length; iw++) {
    if (doc.idWords[iw].indexOf(q) === 0) {
      return 9200 - iw * 20 - id.length
    }
  }

  // Substring match on name
  if (directName > 0) return 8000 - directName * 10 - name.length

  // Substring match on ID
  if (directId > 0) return 7600 - directId * 10 - id.length

  // Substring match on search text (genericName, comment, keywords)
  var hayIndex = doc.searchText.indexOf(q)
  if (hayIndex >= 0) return 6000 - hayIndex

  // Acronym match
  var acronym = doc.acronym
  var acronymIndex = acronym.indexOf(q)
  if (acronymIndex === 0) return 5000 - acronym.length
  if (acronymIndex > 0) return 4600 - acronymIndex * 10 - acronym.length

  return 4000 - name.length
}

function fuzzyScore(entry, query) {
  var doc = buildEntryDocument(entry)
  if (!doc) return -1
  return fuzzyScoreDoc(doc, query)
}

function sortedEntries(values, query, hiddenCallback) {
  var q = String(query || "").trim()
  var rows = []

  for (var i = 0; i < values.length; i++) {
    var entry = values[i]
    if (!entry || entry.noDisplay) continue
    if (hiddenCallback && hiddenCallback(entry)) continue
    var doc = buildEntryDocument(entry)
    if (!doc || !doc.name) continue
    var score = fuzzyScoreDoc(doc, q)
    if (score < 0) continue
    rows.push({ entry: entry, score: score, key: doc.sortKey, name: doc.nameLower })
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
    sortedEntries: sortedEntries,
    buildEntryDocument: buildEntryDocument,
    clearDocumentCache: clearDocumentCache,
    invalidateEntry: invalidateEntry
  }
}
