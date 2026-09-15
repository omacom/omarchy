// Only scalar display data crosses from the plugin host into the reservation host.
function parse(text) {
  if (typeof text !== "string" || text.length > 16384) return null
  var value
  try { value = JSON.parse(text) } catch (_) { return null }
  if (!value || value.version !== 1) return null
  if (value.loading === true) return { loading: true }
  if (!Array.isArray(value.screens) || value.screens.length > 32) return null
  if (["top", "bottom", "left", "right"].indexOf(value.position) < 0) return null
  if (!Number.isInteger(value.size) || value.size < 0 || value.size > 256) return null
  if (typeof value.hidden !== "boolean" || typeof value.ready !== "boolean") return null
  var names = []
  for (var i = 0; i < value.screens.length; i++) {
    var name = value.screens[i]
    if (typeof name !== "string" || name.length > 128 || names.indexOf(name) >= 0) return null
    names.push(name)
  }
  var color = /^#[0-9a-fA-F]{6}$/
  if (!color.test(value.background) || !color.test(value.foreground)) return null
  return { loading: false, screens: names, position: value.position, size: value.size,
    hidden: value.hidden, ready: value.ready, background: value.background, foreground: value.foreground }
}
// SplitParser's empty marker delivers chunks without accumulating an unbounded
// unfinished line in C++. Bound our own buffer before attempting JSON parsing.
function append(pending, chunk) {
  if (pending.length + chunk.length > 65536) return null
  var lines = (pending + chunk).split("\n")
  var rest = lines.pop()
  if (rest.length > 16384 || lines.some(function(line) { return line.length > 16384 })) return null
  return { lines: lines, pending: rest }
}
if (typeof module !== "undefined") module.exports = { parse, append }
