// Session-only navigation memory. Durations are milliseconds internally.
function duration(config) {
  config = config || {}
  if (config.memory === false) return 0
  var seconds = config.memorySeconds
  if (typeof seconds !== "number" || !isFinite(seconds) || seconds < 0) seconds = 15
  return seconds * 1000
}

function restore(saved, route, items, now, durationMs) {
  if (!saved || route !== "root" || durationMs <= 0) return null
  var elapsed = now - saved.closedAt
  if (elapsed < 0 || elapsed >= durationMs) return null
  var entry = items[saved.menu]
  if (!entry || entry.kind !== "menu") return null
  return saved
}

if (typeof module !== "undefined") {
  module.exports = { duration: duration, restore: restore }
}
