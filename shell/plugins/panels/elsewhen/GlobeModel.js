.pragma library

// Orthographic globe maths: projection, the day/night terminator, and label
// placement. Kept free of QML types so tests/globe_check.js can exercise it.

var DEG = Math.PI / 180

// Earth's obliquity: the tilt of its rotation axis against the plane of its
// orbit. The subsolar calculation below uses it to place the sun; the hero
// icon uses it to sit at the angle the real thing does.
var AXIAL_TILT = 23.44

// Every other vertex of a coastline ring, for drawing while the globe is
// scaled down mid-transition.
//
// The canvas always paints at full size and the item is scaled by a
// transform, so during the zoom the panel is drawing 1337 coastline points
// and then shrinking the result to a few dozen pixels across. Half of them
// land on the same pixel. Rings shorter than the floor are returned whole -
// below it a shape stops being an island and becomes a triangle.
//
// `ring` is flat [lon, lat, lon, lat, ...], and so is the result.
function decimateRing(ring, keepEvery, minPoints) {
  var step = keepEvery === undefined ? 2 : keepEvery
  var floor = minPoints === undefined ? 8 : minPoints
  var n = ring.length / 2
  if (step < 2 || n <= floor) return ring
  var out = []
  for (var i = 0; i < n; i += step) out.push(ring[i * 2], ring[i * 2 + 1])
  // Keep the ring closed on the vertex the original ended on, so the coast
  // does not develop a straight chord back to the start.
  var lastI = (n - 1) * 2
  if (out[out.length - 2] !== ring[lastI] || out[out.length - 1] !== ring[lastI + 1])
    out.push(ring[lastI], ring[lastI + 1])
  return out
}

// A drawn pixel constant that follows the shell's UI scale.
//
// The large globe's radius, padding and labels all scale with the shell's
// base font size, but its stroke widths and marker radii were fixed pixel
// literals. Raising the base size therefore grew the globe and its names
// while the lines and dots stayed put, so they read as proportionally
// thinner - the small globe already avoided this by deriving its widths
// from its own radius, which the large globe cannot do because its radius
// is hundreds of pixels.
//
// The floor is what the small globe uses: below one pixel a stroke stops
// being a thin line and starts dropping out of the raster altogether.
function scalePx(px, scale, minPx) {
  var s = (typeof scale === "number" && isFinite(scale) && scale > 0) ? scale : 1
  var n = px * s
  var floor = (minPx === undefined) ? 1 : minPx
  return n < floor ? floor : n
}

// Orthographic projection of a lat/lon onto a disc of radius r, as seen from
// a viewpoint over (viewLat, spin). `visible` is false for the far hemisphere.
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

// The point on Earth with the sun directly overhead. Low-precision solar
// position: good to a fraction of a degree, which is far finer than a globe
// a few hundred pixels across can show.
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

// The sun's angle above the horizon, in degrees. Negative below it: about
// -6 at the end of civil twilight, -18 at full night.
function solarElevation(lat, lon, sub) {
  var cosz = Math.sin(lat * DEG) * Math.sin(sub.lat * DEG)
           + Math.cos(lat * DEG) * Math.cos(sub.lat * DEG) * Math.cos((lon - sub.lon) * DEG)
  return Math.asin(Math.max(-1, Math.min(1, cosz))) / DEG
}

// True where the sun is above the horizon. The threshold is -0.833 degrees
// rather than 0 to allow for refraction and the sun's disc - the same
// convention sunrise tables use.
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

// Thin out points that crowd each other on screen. Offered in priority order,
// a point is kept only if it clears everything already kept by minDist pixels
// - so a dense region like western Europe keeps a few cities instead of a
// smear of overlapping dots, and the survivors change as the globe turns or
// resizes. Priority is caller-supplied, which is how tracked cities and
// the current selection always survive.
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

// ------------------------------------------------------------------ the moon
//
// Enough to draw a phase, not enough to predict an eclipse: the mean synodic
// month against a known new moon. Good to a few hours, which is far finer
// than a dot a few pixels across can show.

var SYNODIC_MONTH = 29.530588853          // days
var KNOWN_NEW_MOON_JD = 2451550.1         // 2000-01-06 18:14 UTC

// Position through the lunation: 0 new, 0.25 first quarter, 0.5 full,
// 0.75 last quarter.
function moonPhase(ms) {
  var jd = Number(ms) / 86400000 + 2440587.5
  var p = ((jd - KNOWN_NEW_MOON_JD) / SYNODIC_MONTH) % 1
  return p < 0 ? p + 1 : p
}

// Fraction of the disc lit, 0 at new and 1 at full.
function moonIllumination(phase) {
  return (1 - Math.cos(2 * Math.PI * Number(phase))) / 2
}

// What people call the shape in the sky.
//
// The four principal phases are instants, not eighths of a cycle: the moon is
// exactly full for a moment and then it is waning. But nobody says "waning
// gibbous" about a disc that is 99.9% lit, so each principal phase is given a
// day either side of its instant and the crescents and gibbous phases fill the
// gaps between. A day is what the eye cannot tell apart at this size, and it is
// also roughly how long people go on saying "full moon" for.
//
// Every cut here is a convention rather than a fact, which is why the width is
// stated once as a named constant instead of being spread through the tests.
var PRINCIPAL_DAYS = 1.0

function moonPhaseName(phase) {
  var p = Number(phase)
  if (!isFinite(p)) return ""
  p = p % 1
  if (p < 0) p += 1

  var w = PRINCIPAL_DAYS / SYNODIC_MONTH
  var near = function(target) {
    var d = Math.abs(p - target)
    if (d > 0.5) d = 1 - d
    return d <= w
  }

  if (near(0)) return "New moon"
  if (near(0.25)) return "First quarter"
  if (near(0.5)) return "Full moon"
  if (near(0.75)) return "Last quarter"
  if (p < 0.25) return "Waxing crescent"
  if (p < 0.5) return "Waxing gibbous"
  if (p < 0.75) return "Waning gibbous"
  return "Waning crescent"
}

// The outline of the lit part of the moon, as points on a disc of radius r
// centred on the origin.
//
// Two arcs: the limb on the lit side, and the terminator returning. The
// terminator is the same semicircle squashed horizontally by cos(2*pi*phase),
// which is signed - positive gives a crescent bulging away from the limb,
// negative a gibbous bulging past the centre - so one construction covers
// every phase without special cases.
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

// ------------------------------------------------------- clipping to the disc
//
// Shared by both globes. The maths lived in MiniGlobe first; the large globe
// was dropping points at the limb with no interpolation, so its coastlines
// and graticule snapped by up to a segment as it turned.

// The exact point where a segment crosses the horizon, by bisection on the
// projection's own visibility test. Points are [lat, lon].
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

// A polyline split into the runs that are on the near side, each beginning
// and ending exactly on the horizon rather than at the last vertex before it.
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

// One closed polygon for a ring clipped to the visible hemisphere.
//
// Sutherland-Hodgman, keeping the ring whole: splitting it into visible runs
// and closing each separately makes self-intersecting shapes whose area jumps
// as runs split, which reads as continents morphing at the limb. Where the
// shape leaves and re-enters the horizon the limb is followed round rather
// than cut across. `ring` is flat [lon, lat, lon, lat, ...].
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

// Greedy label placement. Cities are offered in rank order, nearest the disc
// centre first, and a label is kept only if its box clears every label
// already placed - so spinning the globe reveals and hides names instead of
// piling them on top of each other.
// `maxX` is the half-width of the drawing area, in the same centred
// coordinates as the candidates. A label that would run off the right edge is
// placed to the left of its dot instead of being allowed to overflow the
// panel - names near the right limb read inward.
// `gap` is the distance from a city's dot to its name. It defaults to the
// 6px this used before it was a parameter, so any caller that does not scale
// its drawing keeps exactly the layout it had.
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
