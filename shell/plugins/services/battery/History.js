// Battery history for the battery service: parses omarchy-battery-history
// and turns it into what the power panel shows (graph points, charge
// sessions, drain figures), so the panel needs no script of its own. Times
// are unix seconds.

// UPower history states.
var UNKNOWN = 0, CHARGING = 1, DISCHARGING = 2, EMPTY = 3, FULL = 4, PENDING_CHARGE = 5, PENDING_DISCHARGE = 6

var MAX_RAW = 1024 * 1024
var MAX_POINTS = 5000
var SPAN = 3 * 24 * 3600
// No sample for this long while on battery means the machine was asleep (or
// off): while awake UPower records the rate about every 30 s.
var SLEEP_GAP = 15 * 60
// Percent gained across a sleep that marks it as charged while asleep.
var CHARGE_GAIN = 3

function sourceOf(state) {
  if (state === CHARGING || state === FULL || state === PENDING_CHARGE) return "ac"
  if (state === DISCHARGING || state === EMPTY || state === PENDING_DISCHARGE) return "battery"
  return ""
}

function parseSeries(json, nowSec, maxValue) {
  var data
  try { data = JSON.parse(json) } catch (e) { return [] }
  if (!Array.isArray(data)) return []
  var out = []
  var oldest = nowSec - SPAN - 3600
  for (var i = 0; i < data.length && out.length < MAX_POINTS; i++) {
    var p = data[i]
    if (!Array.isArray(p) || p.length !== 3) continue
    var t = Number(p[0]), v = Number(p[1]), s = Number(p[2])
    if (!isFinite(t) || Math.floor(t) !== t || t < oldest || t > nowSec + 300) continue
    if (!isFinite(v) || v < 0 || v > maxValue) continue
    if (!isFinite(s) || Math.floor(s) !== s || s < 0 || s > 6) continue
    // UPower logs a 0% reading in the unknown state when the battery device
    // goes away (at shutdown, say), beside the real level; it is no reading.
    if (maxValue === 100 && v === 0 && s === UNKNOWN) continue
    out.push({ t: t, v: v, s: s })
  }
  out.sort(function(a, b) { return a.t - b.t })
  return out
}

// omarchy-battery-history output -> { charge: [{t, v, s}], rate: [{t, v, s}] }, oldest first.
function parseHistory(raw, nowSec) {
  var result = { charge: [], rate: [] }
  var text = String(raw || "")
  if (text.length > MAX_RAW) return result
  var lines = text.split("\n")
  for (var i = 0; i < lines.length; i++) {
    var tab = lines[i].indexOf("\t")
    if (tab <= 0) continue
    var kind = lines[i].substring(0, tab)
    var body = lines[i].substring(tab + 1)
    if (kind === "charge") result.charge = parseSeries(body, nowSec, 100)
    else if (kind === "rate") result.rate = parseSeries(body, nowSec, 500)
  }
  return result
}

// Splits the history into runs on AC and on battery, and finds the stretches
// where the machine slept. Returns { segments: [{source, start, end}], sleeps: [{start, end}] }.
function timeline(history, nowSec) {
  var merged = history.charge.concat(history.rate).slice()
  merged.sort(function(a, b) { return a.t - b.t })

  var segments = []
  var sleeps = []
  var source = ""
  var prev = null
  for (var i = 0; i < merged.length; i++) {
    var p = merged[i]
    var src = sourceOf(p.s) || source
    if (prev && source === "battery" && p.t - prev.t > SLEEP_GAP) sleeps.push({ start: prev.t, end: p.t })
    if (src && src !== source) {
      if (segments.length) segments[segments.length - 1].end = p.t
      segments.push({ source: src, start: p.t, end: p.t })
      source = src
    }
    prev = p
  }
  if (segments.length) segments[segments.length - 1].end = Math.max(segments[segments.length - 1].end, nowSec)

  // UPower records nothing while the machine sleeps, and a Mac charges while
  // suspended: a sleep that wakes up CHARGE_GAIN or more higher was spent on
  // AC, so it becomes an "ac" run of its own and counts as a charge.
  for (var j = 0; j < sleeps.length; j++) {
    var sl = sleeps[j]
    sl.charged = chargeAt(history.charge, sl.end) - chargeAt(history.charge, sl.start) >= CHARGE_GAIN
    if (sl.charged) segments = carve(segments, sl.start, sl.end, "ac")
  }
  return { segments: segments, sleeps: sleeps }
}

// Puts [start, end] on `source`, splitting whatever runs it overlaps, then
// merges neighbours on the same source.
function carve(segments, start, end, source) {
  var out = []
  for (var i = 0; i < segments.length; i++) {
    var seg = segments[i]
    if (seg.end <= start || seg.start >= end) { out.push(seg); continue }
    if (seg.start < start) out.push({ source: seg.source, start: seg.start, end: start })
    if (!out.length || out[out.length - 1].end !== start || out[out.length - 1].source !== source) {
      out.push({ source: source, start: Math.max(start, seg.start), end: Math.min(end, seg.end) })
    } else {
      out[out.length - 1].end = Math.min(end, seg.end)
    }
    if (seg.end > end) out.push({ source: seg.source, start: end, end: seg.end })
  }
  var merged = []
  for (var k = 0; k < out.length; k++) {
    var last = merged[merged.length - 1]
    if (out[k].end <= out[k].start && k < out.length - 1) continue
    if (last && last.source === out[k].source && last.end === out[k].start) last.end = out[k].end
    else merged.push({ source: out[k].source, start: out[k].start, end: out[k].end })
  }
  return merged
}

// Charge (%) at time t: the last reading at or before t, else the first after.
function chargeAt(charge, t) {
  if (!charge.length) return -1
  var value = charge[0].v
  for (var i = 0; i < charge.length && charge[i].t <= t; i++) value = charge[i].v
  return value
}

function sleptWithin(sleeps, start, end) {
  var total = 0
  for (var i = 0; i < sleeps.length; i++) {
    var a = Math.max(start, sleeps[i].start), b = Math.min(end, sleeps[i].end)
    if (b > a) total += b - a
  }
  return total
}

function meanRate(rate, start, end, source) {
  var sum = 0, n = 0
  for (var i = 0; i < rate.length; i++) {
    var p = rate[i]
    if (p.t < start || p.t > end || sourceOf(p.s) !== source || p.v <= 0) continue
    sum += p.v
    n++
  }
  return n ? sum / n : -1
}

// The newest run of the given source ("ac" or "battery"), described:
// { start, end, ongoing, fromPct, toPct, awakeSec, avgWatts } or null.
function lastSession(history, tl, source, nowSec) {
  for (var i = tl.segments.length - 1; i >= 0; i--) {
    var seg = tl.segments[i]
    if (seg.source !== source) continue
    var ongoing = i === tl.segments.length - 1
    var end = ongoing ? nowSec : seg.end
    // The level it started from: the reading at the switch or just before
    // it, whichever is further from where the run went (a sleep that charged
    // starts on the last reading before it; a plug-in may already log the
    // first charging reading at the switch).
    var before = chargeAt(history.charge, seg.start - 1), at = chargeAt(history.charge, seg.start)
    var fromPct = source === "ac" ? Math.min(before, at) : Math.max(before, at)
    var toPct = chargeAt(history.charge, end)
    return {
      start: seg.start,
      end: end,
      ongoing: ongoing,
      fromPct: fromPct,
      toPct: toPct,
      awakeSec: Math.max(0, end - seg.start - sleptWithin(tl.sleeps, seg.start, end)),
      avgWatts: meanRate(history.rate, seg.start, end, source)
    }
  }
  return null
}

function dropBetween(charge, a, b) {
  return Math.max(0, chargeAt(charge, a) - chargeAt(charge, b))
}

// Drain on battery since `since`, awake and asleep kept apart:
// { awakeSec, usedPct, pctPerHour, avgWatts, sleepSec, sleepPct },
// or null with under ten awake minutes to go on.
function drainSince(history, tl, since, nowSec) {
  var awake = 0, used = 0, slept = 0, sleepUsed = 0
  for (var i = 0; i < tl.segments.length; i++) {
    var seg = tl.segments[i]
    if (seg.source !== "battery") continue
    var a = Math.max(seg.start, since)
    var b = Math.min(i === tl.segments.length - 1 ? nowSec : seg.end, nowSec)
    if (b <= a) continue
    var total = dropBetween(history.charge, a, b)
    var asleep = 0, asleepSec = 0
    for (var j = 0; j < tl.sleeps.length; j++) {
      var sa = Math.max(a, tl.sleeps[j].start), sb = Math.min(b, tl.sleeps[j].end)
      if (sb <= sa) continue
      asleepSec += sb - sa
      asleep += dropBetween(history.charge, sa, sb)
    }
    asleep = Math.min(asleep, total)
    awake += Math.max(0, b - a - asleepSec)
    used += total - asleep
    slept += asleepSec
    sleepUsed += asleep
  }
  if (awake < 10 * 60) return null
  return {
    awakeSec: awake,
    usedPct: used,
    pctPerHour: used / (awake / 3600),
    avgWatts: meanRate(history.rate, since, nowSec, "battery"),
    sleepSec: slept,
    sleepPct: sleepUsed
  }
}

// Points to plot over [start, now], with the level carried in from before
// the window and out to now: [{t, v}].
function graphPoints(charge, start, nowSec) {
  if (!charge.length) return []
  var pts = [{ t: start, v: chargeAt(charge, start) }]
  for (var i = 0; i < charge.length; i++) {
    if (charge[i].t > start && charge[i].t <= nowSec) pts.push({ t: charge[i].t, v: charge[i].v })
  }
  pts.push({ t: nowSec, v: pts[pts.length - 1].v })
  return pts
}

// The graph points cut into runs at every sleep that overlaps them, each
// sleep clipped to the plotted span. UPower logs the charge only when it
// changes, so the level holds at the last reading up to the sleep, and a
// change made while asleep shows up as the first reading after waking. The
// panel joins the runs with a dashed line, for time nothing was recorded.
// [[{t, v}]].
function graphRuns(points, sleeps) {
  if (!points.length) return []
  var first = points[0].t, last = points[points.length - 1].t
  var cuts = []
  for (var j = 0; j < sleeps.length; j++) {
    var a = Math.max(sleeps[j].start, first), b = Math.min(sleeps[j].end, last)
    if (b > a) cuts.push({ start: a, end: b })
  }
  cuts.sort(function(p, q) { return p.start - q.start })

  function levelAt(t) {
    var v = points[0].v
    for (var k = 0; k < points.length && points[k].t <= t; k++) v = points[k].v
    return v
  }

  var runs = []
  var run = []
  var i = 0
  for (var c = 0; c < cuts.length; c++) {
    var cut = cuts[c]
    if (cut.start < (run.length ? run[run.length - 1].t : -Infinity)) continue
    while (i < points.length && points[i].t <= cut.start) run.push(points[i++])
    if (!run.length || run[run.length - 1].t < cut.start) run.push({ t: cut.start, v: levelAt(cut.start) })
    runs.push(run)
    while (i < points.length && points[i].t < cut.end) i++
    // A reading on or soon after waking is the change made while asleep; a
    // later one changed while awake, so the level picks up where it was.
    var next = points[i]
    var wake = next && next.t - cut.end <= 120 ? next.v : levelAt(cut.end)
    run = [{ t: cut.end, v: wake }]
    if (next && next.t === cut.end) i++
  }
  while (i < points.length) run.push(points[i++])
  runs.push(run)
  return runs
}

// Whole hours and minutes, for "%1h %2m" style labels.
function splitDuration(sec) {
  var m = Math.max(0, Math.round(sec / 60))
  return { h: Math.floor(m / 60), m: m % 60 }
}

// The graph windows the power panel offers, in seconds.
var WINDOWS = { "6h": 6 * 3600, "24h": 24 * 3600, "3d": 3 * 24 * 3600 }

// Everything the power panel shows, from one read:
// { lastCharge, lastBattery, windows: { "6h": { start, span, points, runs, drain }, ... } }.
function views(history, tl, nowSec) {
  var out = {
    lastCharge: lastSession(history, tl, "ac", nowSec),
    lastBattery: lastSession(history, tl, "battery", nowSec),
    windows: {}
  }
  for (var key in WINDOWS) {
    var start = nowSec - WINDOWS[key]
    var points = graphPoints(history.charge, start, nowSec)
    out.windows[key] = {
      start: start,
      span: WINDOWS[key],
      points: points,
      runs: graphRuns(points, tl.sleeps),
      drain: drainSince(history, tl, start, nowSec)
    }
  }
  return out
}

if (typeof module !== "undefined") {
  module.exports = {
    SPAN: SPAN,
    SLEEP_GAP: SLEEP_GAP,
    sourceOf: sourceOf,
    parseHistory: parseHistory,
    timeline: timeline,
    chargeAt: chargeAt,
    lastSession: lastSession,
    drainSince: drainSince,
    graphPoints: graphPoints,
    graphRuns: graphRuns,
    WINDOWS: WINDOWS,
    views: views,
    carve: carve,
    splitDuration: splitDuration
  }
}
