// Local, colour-only theme identifiers. No commands or markup are stored.
var maximumThemes = 512

function validName(name) {
  return typeof name === "string" && name.length <= 160 && /^[a-z0-9_][a-z0-9._+-]*$/.test(name)
}

function normalize(names) {
  if (!Array.isArray(names) || names.length > maximumThemes) return []
  var result = []
  var seen = Object.create(null)
  for (var i = 0; i < names.length; i++) {
    var name = names[i]
    if (validName(name) && !seen[name]) {
      seen[name] = true
      result.push(name)
    }
  }
  return result
}

function parseState(raw) {
  var empty = { themes: [], favouritesOnly: false }
  if (typeof raw !== "string" || raw.length > 65536) return empty
  try {
    var state = JSON.parse(raw)
    if (!state || Array.isArray(state) || state.version !== 1) return empty
    return { themes: normalize(state.themes), favouritesOnly: state.favouritesOnly === true }
  } catch (error) {
    return empty
  }
}

function serializeState(themes, favouritesOnly) {
  return JSON.stringify({ version: 1, themes: normalize(themes), favouritesOnly: favouritesOnly === true }, null, 2) + "\n"
}

function contains(themes, name) {
  return validName(name) && Array.isArray(themes) && themes.indexOf(name) !== -1
}

function toggle(themes, name) {
  var next = normalize(themes)
  if (!validName(name)) return next
  var index = next.indexOf(name)
  if (index >= 0) next.splice(index, 1)
  else if (next.length < maximumThemes) next.push(name)
  return next
}

function nameForPath(path) {
  return String(path || "").split("/").pop().replace(/\.[^/.]+$/, "")
}

// Filter the stock picker's search results, retaining its order and indexes.
// With the filter off, wallpapers and ordinary theme navigation are unchanged.
function filterIndices(images, indices, themes, favouritesOnly) {
  if (!favouritesOnly) return indices.slice()
  var result = []
  for (var i = 0; i < indices.length; i++) {
    var index = indices[i]
    if (images[index] && contains(themes, nameForPath(images[index].filePath))) result.push(index)
  }
  return result
}

if (typeof module !== "undefined") {
  module.exports = { validName: validName, normalize: normalize, parseState: parseState, serializeState: serializeState, contains: contains, toggle: toggle, filterIndices: filterIndices }
}
