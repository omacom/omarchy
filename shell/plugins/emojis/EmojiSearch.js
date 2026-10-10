function parseEmojis(raw) {
  try {
    var data = JSON.parse(String(raw || ""))
    return Array.isArray(data) ? data : []
  } catch (e) {
    return []
  }
}

// Favorites are a hand-ordered list, e.g. ["👍", "🔥"]. The file order is the
// on-screen order, so a pinned emoji is always in the cell you remember.
function parseFavorites(raw) {
  var out = []
  try {
    var data = JSON.parse(String(raw || ""))
    if (Array.isArray(data)) {
      for (var i = 0; i < data.length; i++) {
        var emoji = typeof data[i] === "string" ? data[i].trim() : ""
        if (emoji && out.indexOf(emoji) < 0) out.push(emoji)
      }
    }
  } catch (e) {}
  return out
}

// Adding appends, so pinning a new emoji never moves the ones already there.
function toggleFavorite(favorites, emoji) {
  var list = Array.isArray(favorites) ? favorites.slice() : []
  if (!emoji) return list
  var at = list.indexOf(emoji)
  if (at >= 0) list.splice(at, 1)
  else list.push(emoji)
  return list
}

// Drops `emoji` into the slot `before` holds now: the pins it passes move up,
// so the emoji lands in the cell the pointer was released over.
function moveFavorite(favorites, emoji, before) {
  var list = Array.isArray(favorites) ? favorites.slice() : []
  var from = list.indexOf(emoji)
  var to = list.indexOf(before)
  if (from < 0 || to < 0 || from === to) return list
  list.splice(from, 1)
  list.splice(to, 0, emoji)
  return list
}

// Whether the file on disk is one the picker may replace later: a JSON array.
// A file that is missing, broken or some other shape is shown as no favorites and
// then left alone, so the next pin cannot overwrite what we failed to read — the
// same rule the shell applies to a shell.json it could not parse.
function favoritesAreValid(raw) {
  try {
    return Array.isArray(JSON.parse(String(raw || "")))
  } catch (e) {
    return false
  }
}

// Only emojis in the catalog can render, so a mistyped entry never takes a cell.
// A pinned list is shown as it is: three favorites are three cells, not a row
// padded out with emojis nobody chose.
function favoriteEmojis(emojis, favorites) {
  var catalog = (Array.isArray(emojis) ? emojis : []).map(function(item) { return item && item.e })
  var list = Array.isArray(favorites) ? favorites : []
  var out = []
  for (var i = 0; i < list.length; i++) {
    if (catalog.indexOf(list[i]) >= 0 && out.indexOf(list[i]) < 0) out.push(list[i])
  }
  return out
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

// The grid is one flat list of cells: a heading owns a whole row, a section that
// ends part-way through a row is padded out to the row end (otherwise every row
// after it shifts sideways by the remainder), and every other cell is an emoji.
// Building it here rather than in the QML keeps the layout, and the movement over
// it, in one place a test can drive.
function buildCells(emojis, favorites, query, limit, columns) {
  var width = columns > 0 ? columns : 1
  var cells = []

  function heading(text) {
    while (cells.length % width !== 0) cells.push({ emoji: "", heading: "" })
    for (var i = 0; i < width; i++) cells.push({ emoji: "", heading: i === 0 ? text : "" })
  }

  function section(list) {
    for (var i = 0; i < list.length; i++) cells.push({ emoji: list[i], heading: "" })
  }

  // Searching is a lookup, so the pinned row steps aside for the matches.
  var pinned = normalizedQuery(query) ? [] : favoriteEmojis(emojis, favorites)
  if (pinned.length > 0) {
    heading("Favorites")
    section(pinned)
    heading("All")
  }
  section(filterEmojis(emojis, query, limit).map(function(item) { return item.e }))

  return cells
}

function cellAt(cells, index) {
  return index >= 0 && index < cells.length ? cells[index] : null
}

function isEmojiCell(cells, index) {
  var cell = cellAt(cells, index)
  return !!(cell && cell.emoji)
}

// Steps a cell at a time until an emoji cell, or off the grid: -1 lets the caller
// wrap around instead of parking the cursor on a heading it cannot stand on.
function stepTarget(cells, index, step) {
  if (!step) return -1
  while (index >= 0 && index < cells.length && !isEmojiCell(cells, index)) index += step
  return index >= 0 && index < cells.length ? index : -1
}

// Row movement resolves inside the target row band rather than by index maths: a
// heading row, a padded row end and a short pinned row all hold cells the cursor
// may not stand on, so the band's nearest emoji to the current column wins. Bands
// with no emoji at all are skipped, and -1 means there is nothing that way.
function rowTarget(cells, columns, index, rowDelta) {
  var width = columns > 0 ? columns : 1
  if (!rowDelta || !isEmojiCell(cells, index)) return -1

  var column = index % width
  var band = Math.floor(index / width) + rowDelta

  while (band >= 0 && band * width < cells.length) {
    var start = band * width
    var end = Math.min(start + width, cells.length)
    var best = -1
    var bestDistance = 0
    for (var i = start; i < end; i++) {
      if (!isEmojiCell(cells, i)) continue
      var distance = Math.abs((i % width) - column)
      if (best < 0 || distance < bestDistance) {
        best = i
        bestDistance = distance
      }
    }
    if (best >= 0) return best
    band += rowDelta
  }

  return -1
}

// A page that would run past the end of the grid clamps to it instead of staying
// put, so a short result set can still be paged to its boundary — which is what
// the index arithmetic did before the rows were resolved by band.
function pageTarget(cells, columns, index, rowDelta) {
  var target = rowTarget(cells, columns, index, rowDelta)
  if (target >= 0 || !rowDelta || !isEmojiCell(cells, index)) return target
  return rowDelta > 0 ? stepTarget(cells, cells.length - 1, -1) : stepTarget(cells, 0, 1)
}

if (typeof module !== "undefined") {
  module.exports = {
    parseEmojis: parseEmojis,
    parseFavorites: parseFavorites,
    favoritesAreValid: favoritesAreValid,
    toggleFavorite: toggleFavorite,
    moveFavorite: moveFavorite,
    favoriteEmojis: favoriteEmojis,
    normalizedQuery: normalizedQuery,
    filterEmojis: filterEmojis,
    buildCells: buildCells,
    isEmojiCell: isEmojiCell,
    stepTarget: stepTarget,
    rowTarget: rowTarget,
    pageTarget: pageTarget
  }
}
