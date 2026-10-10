// Store full text rather than history indices: copying or filtering can reorder
// the history while the picker is open. The array order is the marking order.
function textEntry(entry) {
  return entry && entry.type === "text" && typeof entry.text === "string" && entry.text.trim().length > 0
}

function position(selected, entry) {
  if (!textEntry(entry)) return -1
  for (var i = 0; i < selected.length; i++) {
    if (selected[i].text === entry.text) return i
  }
  return -1
}

function toggle(selected, entry) {
  var next = selected.slice()
  if (!textEntry(entry)) return next
  var index = position(next, entry)
  if (index >= 0) next.splice(index, 1)
  else next.push({ type: "text", text: entry.text })
  return next
}

function remove(selected, entry) {
  var next = selected.slice()
  var index = position(next, entry)
  if (index >= 0) next.splice(index, 1)
  return next
}

function retain(selected, history) {
  return selected.filter(function(entry) { return position(history, entry) >= 0 })
}

function join(selected) {
  return selected.map(function(entry) { return entry.text }).join("\n")
}

function preview(selected, limit) {
  var result = ""
  for (var i = 0; i < selected.length && result.length < limit; i++) {
    if (i > 0) result += "\n"
    result += selected[i].text.slice(0, Math.max(0, limit - result.length))
  }
  return result.slice(0, limit)
}

if (typeof module !== "undefined") {
  module.exports = { position: position, toggle: toggle, remove: remove, retain: retain, join: join, preview: preview }
}
