function nameForPath(path) {
  return String(path || "").split("/").pop().replace(/\.[^/.]+$/, "")
}

function labelForPath(path) {
  return nameForPath(path).replace(/[-_]+/g, " ").replace(/\b\w/g, function(match) { return match.toUpperCase() })
}

// Extra (user-installed) theme names, one per line, as listed from the user
// themes directory: the set omarchy-theme-remove can delete.
function parseThemeNames(text) {
  var names = []
  var lines = String(text || "").split("\n")
  for (var i = 0; i < lines.length; i++) {
    var name = lines[i].trim()
    if (name) names.push(name)
  }
  return names
}

// A user directory shadowing a stock theme holds customizations, not an
// extra theme: removing it from here would silently revert to stock (and a
// shadow can even list twice, once per preview extension), so only themes
// with no stock twin can be deleted from the picker.
function canDeleteTheme(name, extraNames, stockNames) {
  if (!name || !Array.isArray(extraNames) || extraNames.indexOf(name) === -1) return false
  return !Array.isArray(stockNames) || stockNames.indexOf(name) === -1
}

// Where selection lands when the selected image goes away: the previous
// match in list order, or the next one when the first match is deleted.
function replacementSelectionPath(images, selectedIndex, filterText) {
  var values = Array.isArray(images) ? images : []
  if (selectedIndex < 0 || selectedIndex >= values.length) return ""
  for (var i = selectedIndex - 1; i >= 0; i--) {
    if (itemMatches(values, i, filterText)) return values[i].filePath
  }
  for (var i = selectedIndex + 1; i < values.length; i++) {
    if (itemMatches(values, i, filterText)) return values[i].filePath
  }
  return ""
}

function loadRows(rows) {
  var images = []
  var seen = {}
  var paths = String(rows || "").split("\n")

  for (var i = 0; i < paths.length; i++) {
    var row = paths[i]
    if (!row) continue

    var columns = row.split("\t")
    var path = columns[0]
    if (!path) continue

    var fileName = path.split("/").pop()
    if (seen[fileName]) continue
    seen[fileName] = true

    images.push({
      filePath: path,
      fileName: fileName,
      thumbnailPath: columns[1] || path
    })
  }

  return images
}

function itemMatches(images, index, filterText) {
  if (!Array.isArray(images) || index < 0 || index >= images.length) return false
  var needle = String(filterText || "").toLowerCase()
  if (!needle) return true

  var path = String(images[index].filePath || "")
  return nameForPath(path).toLowerCase().indexOf(needle) !== -1
      || labelForPath(path).toLowerCase().indexOf(needle) !== -1
}

function firstMatchingIndex(images, filterText) {
  var values = Array.isArray(images) ? images : []
  for (var i = 0; i < values.length; i++) {
    if (itemMatches(values, i, filterText)) return i
  }

  return -1
}

function filteredPosition(images, index, filterText) {
  if (!filterText) return index

  var position = 0
  for (var i = 0; i < index; i++) {
    if (itemMatches(images, i, filterText)) position++
  }

  return position
}

function selectedFilteredPosition(images, selectedIndex, filterText) {
  if (!filterText) return selectedIndex
  return itemMatches(images, selectedIndex, filterText) ? filteredPosition(images, selectedIndex, filterText) : 0
}

function indexForSelectedImage(images, selectedImage) {
  var values = Array.isArray(images) ? images : []
  for (var i = 0; i < values.length; i++) {
    if (values[i].filePath === selectedImage) return i
  }

  return 0
}

function nextSelectedIndexForFilter(images, selectedIndex, filterText) {
  if (itemMatches(images, selectedIndex, filterText)) return selectedIndex
  return firstMatchingIndex(images, filterText)
}

function matchingIndices(images, filterText) {
  var indices = []
  for (var i = 0; i < images.length; i++) {
    if (itemMatches(images, i, filterText)) indices.push(i)
  }
  return indices
}

// Keep the rendered carousel independent of the size of the collection.
function visibleWindow(indices, selectedIndex, radius) {
  var position = indices.indexOf(selectedIndex)
  if (position < 0) position = 0
  var items = []
  for (var i = Math.max(0, position - radius); i < Math.min(indices.length, position + radius + 1); i++) {
    items.push({ imageIndex: indices[i], relativeIndex: i - position })
  }
  return items
}

// Preserve overlapping delegates as selection moves, including their decoded
// images. Replacing the entire model on every keypress makes previews flicker.
function syncWindow(model, items) {
  var wanted = {}
  for (var i = 0; i < items.length; i++) wanted[items[i].imageIndex] = true
  for (var i = model.count - 1; i >= 0; i--) {
    if (!wanted[model.get(i).imageIndex]) model.remove(i)
  }
  for (var i = 0; i < items.length; i++) {
    var existing = i
    while (existing < model.count && model.get(existing).imageIndex !== items[i].imageIndex) existing++
    if (existing === model.count) {
      model.insert(i, items[i])
    } else {
      if (existing !== i) model.move(existing, i, 1)
      model.setProperty(i, "relativeIndex", items[i].relativeIndex)
    }
  }
}

if (typeof module !== "undefined") {
  module.exports = {
    nameForPath: nameForPath,
    labelForPath: labelForPath,
    parseThemeNames: parseThemeNames,
    canDeleteTheme: canDeleteTheme,
    replacementSelectionPath: replacementSelectionPath,
    loadRows: loadRows,
    itemMatches: itemMatches,
    firstMatchingIndex: firstMatchingIndex,
    filteredPosition: filteredPosition,
    selectedFilteredPosition: selectedFilteredPosition,
    indexForSelectedImage: indexForSelectedImage,
    nextSelectedIndexForFilter: nextSelectedIndexForFilter,
    matchingIndices: matchingIndices,
    visibleWindow: visibleWindow,
    syncWindow: syncWindow
  }
}
