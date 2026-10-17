.pragma library

// Summaries of benchmark runs: times in milliseconds, one per run.

function median(times) {
  if (!times.length) return null
  var sorted = times.slice().sort(function(a, b) { return a - b })
  var mid = sorted.length >> 1
  return sorted.length % 2 ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2
}

function minimum(times) {
  return times.length ? Math.min.apply(null, times) : null
}

// Throughput in MB of text per second, from the median.
function throughput(chars, ms) {
  if (!ms) return null
  return chars * 2 / 1048576 / (ms / 1000)
}

// Rows sorted fastest first, with each one's share of the slowest median for
// drawing bars; failed rows go last.
function rank(rows) {
  var done = rows.filter(function(r) { return r.median !== null && !r.error })
  var slowest = 0
  for (var i = 0; i < done.length; i++) slowest = Math.max(slowest, done[i].median)
  var out = rows.map(function(r) {
    var copy = {}
    for (var k in r) copy[k] = r[k]
    copy.share = r.median !== null && slowest > 0 ? r.median / slowest : 0
    return copy
  })
  out.sort(function(a, b) {
    if (a.error && !b.error) return 1
    if (b.error && !a.error) return -1
    if (a.median === null) return 1
    if (b.median === null) return -1
    return a.median - b.median
  })
  return out
}

if (typeof module !== "undefined") module.exports = { median: median, minimum: minimum, throughput: throughput, rank: rank }
