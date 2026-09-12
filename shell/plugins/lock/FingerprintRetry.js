var INITIAL_MS = 250
var MAX_MS = 8000

function nextInterval(previous) {
  var n = Number(previous)
  if (!isFinite(n) || n < INITIAL_MS) return INITIAL_MS
  return Math.min(n * 2, MAX_MS)
}

if (typeof module !== "undefined") {
  module.exports = {
    INITIAL_MS: INITIAL_MS,
    MAX_MS: MAX_MS,
    nextInterval: nextInterval
  }
}
