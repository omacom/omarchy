.pragma library

// Orthographic globe math: projection, the day/night terminator, the moon,
// and label placement.

var DEG = Math.PI / 180

// Earth's obliquity, also the hero icon's lean.
var AXIAL_TILT = 23.44

// Every `keepEvery`th vertex of a flat [lon, lat, ...] ring, for drawing while
// the globe is scaled down. Rings at or under `minPoints` are returned whole.
function decimateRing(ring, keepEvery, minPoints) {
  var step = keepEvery === undefined ? 2 : keepEvery
  var floor = minPoints === undefined ? 8 : minPoints
  var n = ring.length / 2
  if (step < 2 || n <= floor) return ring
  var out = []
  for (var i = 0; i < n; i += step) out.push(ring[i * 2], ring[i * 2 + 1])
  // End on the original last vertex, not a chord back to the start.
  var lastI = (n - 1) * 2
  if (out[out.length - 2] !== ring[lastI] || out[out.length - 1] !== ring[lastI + 1])
    out.push(ring[lastI], ring[lastI + 1])
  return out
}

// A drawn pixel size that follows the shell's UI scale, floored so hairlines
// do not drop out of the raster.
function scalePx(px, scale, minPx) {
  var s = (typeof scale === "number" && isFinite(scale) && scale > 0) ? scale : 1
  var n = px * s
  var floor = (minPx === undefined) ? 1 : minPx
  return n < floor ? floor : n
}

// Orthographic projection onto a disc of radius r seen from over (viewLat, spin).
function project(lat, lon, spin, viewLat, r) {
  var phi = lat * DEG
  var lam = (lon - spin) * DEG
  var p0 = viewLat * DEG
  var cosc = Math.sin(p0) * Math.sin(phi) + Math.cos(p0) * Math.cos(phi) * Math.cos(lam)
  return {
    x: r * Math.cos(phi) * Math.sin(lam),
    y: -r * (Math.cos(p0) * Math.sin(phi) - Math.sin(p0) * Math.cos(phi) * Math.cos(lam)),
    visible: cosc > 0,
    cosc: cosc
  }
}

// The point with the sun directly overhead, good to a fraction of a degree.
function subsolarPoint(ms) {
  var d = new Date(ms)
  var jd = ms / 86400000 + 2440587.5
  var n = jd - 2451545.0
  var L = (280.460 + 0.9856474 * n) % 360            // mean longitude
  var g = ((357.528 + 0.9856003 * n) % 360) * DEG    // mean anomaly
  var lambda = (L + 1.915 * Math.sin(g) + 0.020 * Math.sin(2 * g)) * DEG  // ecliptic longitude
  var eps = (AXIAL_TILT - 0.0000004 * n) * DEG       // obliquity, slowly drifting

  var decl = Math.asin(Math.sin(eps) * Math.sin(lambda)) / DEG

  // Equation of time, in minutes, then the subsolar meridian.
  var alpha = Math.atan2(Math.cos(eps) * Math.sin(lambda), Math.cos(lambda)) / DEG
  var eot = (L - alpha + 540) % 360 - 180            // degrees, wrapped to +-180
  var utcHours = d.getUTCHours() + d.getUTCMinutes() / 60 + d.getUTCSeconds() / 3600
  var lon = -15 * (utcHours - 12) - eot
  lon = ((lon + 540) % 360) - 180

  return { lat: decl, lon: lon }
}

// Degrees above the horizon, negative below it.
function solarElevation(lat, lon, sub) {
  var cosz = Math.sin(lat * DEG) * Math.sin(sub.lat * DEG)
           + Math.cos(lat * DEG) * Math.cos(sub.lat * DEG) * Math.cos((lon - sub.lon) * DEG)
  return Math.asin(Math.max(-1, Math.min(1, cosz))) / DEG
}

// -0.833 allows for refraction and the sun's disc, as sunrise tables do.
function isDaylight(lat, lon, sub) {
  return solarElevation(lat, lon, sub) > -0.833
}

// The great circle 90 degrees from the subsolar point: the day/night line.
function terminator(sub, steps) {
  var n = steps || 180
  var out = []
  var slat = sub.lat * DEG, slon = sub.lon * DEG
  // Build an orthonormal frame around the subsolar axis and sweep a circle.
  var s = [Math.cos(slat) * Math.cos(slon), Math.cos(slat) * Math.sin(slon), Math.sin(slat)]
  var up = Math.abs(s[2]) < 0.9 ? [0, 0, 1] : [1, 0, 0]
  var a = norm(cross(up, s))
  var b = norm(cross(s, a))
  for (var i = 0; i <= n; i++) {
    var t = i / n * 2 * Math.PI
    var v = [a[0] * Math.cos(t) + b[0] * Math.sin(t),
             a[1] * Math.cos(t) + b[1] * Math.sin(t),
             a[2] * Math.cos(t) + b[2] * Math.sin(t)]
    out.push([Math.asin(v[2]) / DEG, Math.atan2(v[1], v[0]) / DEG])
  }
  return out
}

function cross(u, v) {
  return [u[1] * v[2] - u[2] * v[1], u[2] * v[0] - u[0] * v[2], u[0] * v[1] - u[1] * v[0]]
}

function norm(v) {
  var m = Math.hypot(v[0], v[1], v[2]) || 1
  return [v[0] / m, v[1] / m, v[2] / m]
}

// Keep points, in priority order, that clear every kept point by minDist.
// Points marked `keep` always survive.
function declutter(points, minDist) {
  var kept = []
  for (var i = 0; i < points.length; i++) {
    var p = points[i]
    if (p.keep) { kept.push(p); continue }
    var clash = false
    for (var j = 0; j < kept.length; j++) {
      if (Math.hypot(p.x - kept[j].x, p.y - kept[j].y) < minDist) { clash = true; break }
    }
    if (!clash) kept.push(p)
  }
  return kept
}

// ---- the moon

// The mean synodic month against a known new moon: good to a few hours.
var SYNODIC_MONTH = 29.530588853          // days
var KNOWN_NEW_MOON_JD = 2451550.1         // 2000-01-06 18:14 UTC

// Position through the lunation: 0 new, 0.25 first quarter, 0.5 full,
// 0.75 last quarter.
function moonPhase(ms) {
  var jd = Number(ms) / 86400000 + 2440587.5
  var p = ((jd - KNOWN_NEW_MOON_JD) / SYNODIC_MONTH) % 1
  return p < 0 ? p + 1 : p
}

// The lit part of the moon on a disc of radius r at the origin: the limb, then
// the terminator back, a semicircle squashed by the signed cos(2*pi*phase).
function moonLitOutline(phase, r, steps) {
  var n = steps || 24
  var theta = 2 * Math.PI * Number(phase)
  var squash = Math.cos(theta)
  var side = Number(phase) > 0.5 ? -1 : 1     // waning lights the other limb
  var out = []
  var i, t
  for (i = 0; i <= n; i++) {
    t = Math.PI * i / n
    out.push({ x: side * r * Math.sin(t), y: -r * Math.cos(t) })
  }
  for (i = n; i >= 0; i--) {
    t = Math.PI * i / n
    out.push({ x: side * r * squash * Math.sin(t), y: -r * Math.cos(t) })
  }
  return out
}

// ---- clipping to the disc

// Where a [lat, lon] segment crosses the horizon, by bisection.
function limbCrossing(a, b, spin, viewLat, r) {
  // Segments spanning the antimeridian cannot be interpolated in lat/lon.
  if (Math.abs(b[1] - a[1]) > 180) return null
  var lo = 0, hi = 1
  for (var i = 0; i < 8; i++) {
    var m = (lo + hi) / 2
    var p = project(a[0] + (b[0] - a[0]) * m, a[1] + (b[1] - a[1]) * m, spin, viewLat, r)
    if (p.visible) lo = m; else hi = m
  }
  return project(a[0] + (b[0] - a[0]) * lo, a[1] + (b[1] - a[1]) * lo, spin, viewLat, r)
}

// The near-side runs of a polyline, each ending exactly on the horizon.
function visibleSegments(pts, spin, viewLat, r) {
  var out = [], run = [], prev = null, prevVis = false
  function flush() { if (run.length > 1) out.push(run); run = [] }
  for (var i = 0; i < pts.length; i++) {
    var p = project(pts[i][0], pts[i][1], spin, viewLat, r)
    if (p.visible) {
      if (run.length === 0 && prev !== null && !prevVis) {
        var enter = limbCrossing(pts[i], prev, spin, viewLat, r)
        if (enter) run.push(enter)
      }
      run.push(p)
    } else {
      if (run.length > 0 && prev !== null) {
        var exit = limbCrossing(prev, pts[i], spin, viewLat, r)
        if (exit) run.push(exit)
      }
      flush()
    }
    prev = pts[i]; prevVis = p.visible
  }
  flush()
  return out
}

// A flat [lon, lat, ...] ring clipped to the visible hemisphere as one polygon
// that follows the limb, so its area changes smoothly as the globe turns.
function clipRingToDisc(ring, spin, viewLat, r) {
  var pts = []
  for (var k = 0; k < ring.length; k += 2) pts.push([ring[k + 1], ring[k]])
  var out = []
  for (var i = 0; i < pts.length; i++) {
    var A = pts[i], B = pts[(i + 1) % pts.length]
    var pa = project(A[0], A[1], spin, viewLat, r)
    var pb = project(B[0], B[1], spin, viewLat, r)
    if (pa.visible && pb.visible) out.push({ p: pb, limb: false })
    else if (pa.visible) {
      var ex = limbCrossing(A, B, spin, viewLat, r)
      if (ex) out.push({ p: ex, limb: true })
    } else if (pb.visible) {
      var en = limbCrossing(B, A, spin, viewLat, r)
      if (en) out.push({ p: en, limb: true })
      out.push({ p: pb, limb: false })
    }
  }
  if (out.length < 3) return []

  var res = []
  for (var j = 0; j < out.length; j++) {
    res.push(out[j].p)
    var nx = out[(j + 1) % out.length]
    if (!out[j].limb || !nx.limb) continue
    var a0 = Math.atan2(out[j].p.y, out[j].p.x)
    var a1 = Math.atan2(nx.p.y, nx.p.x)
    var d = a1 - a0
    while (d > Math.PI) d -= 2 * Math.PI
    while (d < -Math.PI) d += 2 * Math.PI
    var steps = Math.max(1, Math.round(Math.abs(d) / 0.15))
    for (var t = 1; t < steps; t++) {
      var a = a0 + d * t / steps
      res.push({ x: r * Math.cos(a), y: r * Math.sin(a) })
    }
  }
  return res
}

// Greedy label placement by rank, then nearest the disc center; a label that
// would pass `maxX` flips to the left of its dot. `gap` is dot to name.
function layoutLabels(candidates, charWidth, lineHeight, limit, maxX, gap) {
  var g = (typeof gap === "number" && isFinite(gap) && gap > 0) ? gap : 6
  var placed = []
  var sorted = candidates.slice().sort(function (p, q) {
    if (p.rank !== q.rank) return p.rank - q.rank
    return q.cosc - p.cosc
  })
  for (var i = 0; i < sorted.length; i++) {
    var c = sorted[i]
    var w = c.name.length * charWidth
    var x = c.x + g
    if (maxX !== undefined && x + w > maxX) x = c.x - g - w
    var box = { x: x, y: c.y - lineHeight / 2, w: w, h: lineHeight }
    var clash = false
    for (var j = 0; j < placed.length; j++) {
      var o = placed[j].box
      if (box.x < o.x + o.w && box.x + box.w > o.x && box.y < o.y + o.h && box.y + box.h > o.y) {
        clash = true
        break
      }
    }
    if (clash) continue
    placed.push({ index: c.index, box: box })
    if (limit && placed.length >= limit) break
  }
  return placed
}

// Signed degrees in (-180, 180] to turn from one longitude to another.
function shortestTurn(from, to) {
  var d = ((to - from) % 360 + 360) % 360
  return d > 180 ? d - 360 : d
}

if (typeof module !== "undefined") {
  module.exports = {
    AXIAL_TILT: AXIAL_TILT,
    SYNODIC_MONTH: SYNODIC_MONTH,
    decimateRing: decimateRing,
    scalePx: scalePx,
    project: project,
    subsolarPoint: subsolarPoint,
    solarElevation: solarElevation,
    isDaylight: isDaylight,
    terminator: terminator,
    declutter: declutter,
    moonPhase: moonPhase,
    moonLitOutline: moonLitOutline,
    limbCrossing: limbCrossing,
    visibleSegments: visibleSegments,
    clipRingToDisc: clipRingToDisc,
    layoutLabels: layoutLabels,
    shortestTurn: shortestTurn
  }
}
