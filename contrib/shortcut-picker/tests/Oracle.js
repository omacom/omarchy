// Match key names exactly; only descriptions get substring/fuzzy matching.
function keyName(value) {
  var name = value.toLowerCase()
  var aliases = { control: "ctrl", meta: "super", win: "super", spacebar: "space", enter: "return", esc: "escape" }
  return Object.prototype.hasOwnProperty.call(aliases, name) ? aliases[name] : name
}

function tokens(text) {
  var result = [], pattern = /[^\s+]+/g, match
  while ((match = pattern.exec(text)) !== null)
    result.push({ text: match[0].toLowerCase(), key: keyName(match[0]), start: match.index, length: match[0].length })
  return result
}

function terms(query) {
  var seen = Object.create(null), result = [], parsed = tokens(String(query || ""))
  for (var i = 0; i < parsed.length; i++) {
    if (seen[parsed[i].key]) continue
    seen[parsed[i].key] = true
    result.push(parsed[i])
  }
  return result
}

function positions(start, length) {
  var result = []
  for (var i = 0; i < length; i++) result.push(start + i)
  return result
}

// Quality: whole word, substring, then scattered characters.
function textMatch(term, lower, decorate) {
  var first = lower.indexOf(term), at = first
  while (at >= 0) {
    var before = at > 0 ? lower[at - 1] : ""
    var after = lower[at + term.length] || ""
    if (!/[a-z0-9_]/.test(before) && !/[a-z0-9_]/.test(after))
      return { quality: 0, penalty: at, positions: decorate ? positions(at, term.length) : null }
    at = lower.indexOf(term, at + 1)
  }
  if (first >= 0) return { quality: 1, penalty: first, positions: decorate ? positions(first, term.length) : null }
  var found = decorate ? [] : null, next = 0, last = -1
  for (var i = 0; i < lower.length && next < term.length; i++) {
    if (lower[i] === term[next]) {
      if (decorate) found.push(i)
      last = i
      next++
    }
  }
  return next === term.length
    ? { quality: 2, penalty: last + 1 - term.length, positions: found }
    : null
}

function escapeText(text) {
  return text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;").replace(/ /g, "&nbsp;").replace(/\t/g, "&nbsp;&nbsp;&nbsp;&nbsp;")
}

function highlight(text, matched) {
  // Escape runs of equal formatting, rather than running six replacements for
  // every character. Keep the same UTF-16 offsets and exact markup as before.
  var marked = {}, result = "", active = false, start = 0
  for (var i = 0; i < matched.length; i++) marked[matched[i]] = true
  for (var j = 0; j < text.length; j++) {
    var next = marked[j] === true
    if (active !== next) {
      result += escapeText(text.slice(start, j)) + (next ? "<b><u>" : "</u></b>")
      start = j
      active = next
    }
  }
  return result + escapeText(text.slice(start)) + (active ? "</u></b>" : "")
}

function prepareEntry(label, detail, sourceIndex) {
  label = String(label || "")
  detail = String(detail || "")
  var arrow = label.indexOf("→")
  var descriptionStart = arrow < 0 ? label.length : arrow + 1
  var keys = tokens(arrow < 0 ? label : label.slice(0, arrow)), keyMap = Object.create(null)
  for (var i = 0; i < keys.length; i++)
    if (!keyMap[keys[i].key]) keyMap[keys[i].key] = keys[i]
  return {label:label, detail:detail, value:detail ? label + "\t" + detail : label,
    sourceIndex:sourceIndex, keys:keyMap, keyCount:keys.length,
    description:label.slice(descriptionStart), descriptionStart:descriptionStart,
    descriptionLower:label.slice(descriptionStart).toLowerCase(), detailLower:detail.toLowerCase()}
}

function prepare(options) {
  var entries = []
  for (var i = 0; i < options.length; i++) {
    var parts = String(options[i]).split("\t")
    if (parts.length > 1) parts.shift() // Optional icon, as in omarchy-menu-select.
    entries.push(prepareEntry(parts.shift() || "", parts.join("\t"), i))
  }
  return entries
}

function matchPrepared(queryTerms, entry, decorate) {
  if (!queryTerms.length) return { section: "", score: 0, penalty: 0, labelHtml: "", detailHtml: "" }
  var labelPositions = decorate ? [] : null, detailPositions = decorate ? [] : null, descriptionUsed = false
  var quality = 0, penalty = 0

  for (var i = 0; i < queryTerms.length; i++) {
    var term = queryTerms[i], key = entry.keys[term.key]
    if (key) {
      if (decorate) labelPositions = labelPositions.concat(positions(key.start, key.length))
      continue
    }

    var inLabel = textMatch(term.text, entry.descriptionLower, decorate)
    var inDetail = textMatch(term.text, entry.detailLower, decorate)
    var useDetail = inDetail && (!inLabel || inDetail.quality < inLabel.quality
      || (inDetail.quality === inLabel.quality && inDetail.penalty < inLabel.penalty))
    var found = useDetail ? inDetail : inLabel
    if (!found) return null
    descriptionUsed = true
    quality = Math.max(quality, found.quality)
    penalty += found.penalty
    if (decorate) {
      if (useDetail) detailPositions = detailPositions.concat(found.positions)
      else for (var p = 0; p < found.positions.length; p++) labelPositions.push(entry.descriptionStart + found.positions[p])
    }
  }

  var extraKeys = Math.max(0, entry.keyCount - queryTerms.length)
  return {
    section: descriptionUsed ? "Description matches" : "Shortcut matches",
    score: descriptionUsed ? 2 + quality : (extraKeys ? 1 : 0),
    penalty: descriptionUsed ? penalty : extraKeys,
    labelHtml: decorate ? highlight(entry.label, labelPositions) : "",
    detailHtml: decorate ? highlight(entry.detail, detailPositions) : ""
  }
}

function filterPrepared(entries, queryTerms, decorate) {
  var rows = []
  for (var i = 0; i < entries.length; i++) {
    var entry = entries[i], found = matchPrepared(queryTerms, entry, decorate)
    if (!found) continue
    rows.push({label:entry.label, detail:entry.detail, value:entry.value,
      section:found.section, labelHtml:found.labelHtml, detailHtml:found.detailHtml,
      score:found.score, penalty:found.penalty, sourceIndex:entry.sourceIndex})
  }
  rows.sort(function(a,b) { return a.score-b.score || a.penalty-b.penalty || a.sourceIndex-b.sourceIndex })
  return rows
}

// Eager helpers for callers that need a complete, formatted result set.
function match(queryTerms, label, detail) { return matchPrepared(queryTerms, prepareEntry(label, detail, 0), true) }
function filter(options, query) { return filterPrepared(prepare(options), terms(query), true) }

if (typeof module !== "undefined") {
  module.exports = { terms: terms, match: match, filter: filter,
    prepare: prepare, filterPrepared: filterPrepared, matchPrepared: matchPrepared }
}
