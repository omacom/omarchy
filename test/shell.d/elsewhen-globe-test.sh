#!/bin/bash

# ELSEWHEN_ONLINE=1 also checks day and night against Open-Meteo's is_day.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const https = require('https')
const { Solar: G } = requireFromRoot('test/shell.d/elsewhen/solar.js')

const dataDir = path.join(root, 'shell/plugins/panels/elsewhen')
const cities = JSON.parse(fs.readFileSync(path.join(dataDir, 'cities.json'), 'utf8'))
const land = JSON.parse(fs.readFileSync(path.join(dataDir, 'world.json'), 'utf8')).filter(r => r.length >= 40)
const DEG = Math.PI / 180

// ---- projection

const center = G.project(0, 0, 0, 0, 100)
assert(Math.abs(center.x) < 1e-9 && Math.abs(center.y) < 1e-9 && center.visible, 'elsewhen projects the view center to the origin')
assertEqual(G.project(0, 180, 0, 0, 100).visible, false, 'elsewhen hides the antipode')
assert(G.project(90, 0, 0, 0, 100).y < -99, 'elsewhen puts north up at zero tilt')
assert(G.project(0, 45, 0, 0, 100).x > 0, 'elsewhen puts east to the right')
assert(Math.abs(G.project(0, 45, 45, 0, 100).x) < 1e-9, 'elsewhen spin follows the point')
assert([[12, 34], [-56, 78], [80, -170]].every(([lat, lon]) => {
  const q = G.project(lat, lon, 20, 15, 100)
  return Math.hypot(q.x, q.y) <= 100.0001
}), 'elsewhen projects inside the disc')

// ---- the sun

const jun = G.subsolarPoint(Date.UTC(2026, 5, 21, 12, 0, 0))
assert(Math.abs(jun.lat - 23.44) < 0.5, 'elsewhen puts the June solstice sun near +23.4', jun.lat)
assert(Math.abs(G.subsolarPoint(Date.UTC(2026, 11, 21, 12, 0, 0)).lat + 23.44) < 0.5, 'elsewhen puts the December solstice sun near -23.4')
assert(Math.abs(G.subsolarPoint(Date.UTC(2026, 2, 20, 12, 0, 0)).lat) < 1, 'elsewhen puts the equinox sun near the equator')
assert(Math.abs(jun.lon) < 5, 'elsewhen puts the noon UTC sun near Greenwich', jun.lon)
assert(Math.abs(G.subsolarPoint(Date.UTC(2026, 5, 21, 18, 0, 0)).lon + 90) < 5, 'elsewhen puts the 18:00 UTC sun near 90W')

assert(Math.abs(G.solarElevation(jun.lat, jun.lon, jun) - 90) < 0.01, 'elsewhen has the sun overhead at the subsolar point')
assert(G.solarElevation(-jun.lat, jun.lon + 180, jun) < -89, 'elsewhen has the antipode in deepest night')
assertEqual(G.isDaylight(jun.lat, jun.lon, jun), true, 'elsewhen has daylight at the subsolar point')
assertEqual(G.isDaylight(-jun.lat, jun.lon + 180, jun), false, 'elsewhen has night at the antipode')
assert([[0, 0], [51, 0], [-33, 151], [78, -68]].every(([lat, lon]) => Math.abs(G.solarElevation(lat, lon, jun)) <= 90.01), 'elsewhen keeps elevation in range')

const sub = G.subsolarPoint(Date.now())
const term = G.terminator(sub, 60)
assertEqual(term.length, 61, 'elsewhen closes the terminator')
assert(term.every(([lat, lon]) => {
  const cosz = Math.sin(lat * DEG) * Math.sin(sub.lat * DEG) + Math.cos(lat * DEG) * Math.cos(sub.lat * DEG) * Math.cos((lon - sub.lon) * DEG)
  return Math.abs(cosz) < 1e-9
}), 'elsewhen draws the terminator 90 degrees from the sun')

// ---- labels and scale

const placed = G.layoutLabels([
  { index: 0, name: 'AAAA', x: 0, y: 0, rank: 1, cosc: 1 },
  { index: 1, name: 'BBBB', x: 2, y: 2, rank: 1, cosc: 0.9 },
  { index: 2, name: 'CCCC', x: 0, y: 80, rank: 1, cosc: 0.8 }
], 7, 12)
assertDeepEqual(placed.map(p => p.index), [0, 2], 'elsewhen drops an overlapping label')

const wide = [{ index: 0, name: 'Bangkok', x: 120, y: 0, rank: 1, cosc: 1 }]
const free = G.layoutLabels(wide, 7, 12, 10)[0].box
const bounded = G.layoutLabels(wide, 7, 12, 10, 150)[0].box
assert(free.x + free.w > 150, 'elsewhen lets an unbounded label overflow')
assert(bounded.x + bounded.w <= 150 && bounded.x < 120 && bounded.x + bounded.w > 60, 'elsewhen flips a bounded label to the left of its dot')
const lagos = [{ index: 0, name: 'Lagos', x: -40, y: 0, rank: 1, cosc: 1 }]
assertEqual(G.layoutLabels(lagos, 7, 12, 10, 150)[0].box.x, -34, 'elsewhen leaves a label that fits with the default gap')
assertEqual(G.layoutLabels(lagos, 7, 12, 10, 150, 10)[0].box.x, -30, 'elsewhen uses a scaled gap')
assertEqual(G.layoutLabels(lagos, 7, 12, 10, 150, 0)[0].box.x, -34, 'elsewhen falls back to the default gap')

assertDeepEqual([G.scalePx(1.4, 1), G.scalePx(1.4, 2), G.scalePx(7.5, 1.5)], [1.4, 2.8, 11.25], 'elsewhen scales drawn sizes')
const ratio = s => G.scalePx(7.5, s) / G.scalePx(2.2, s)
assert(Math.abs(ratio(1) - ratio(1.67)) < 1e-9, 'elsewhen keeps drawn proportions at any scale')
assertDeepEqual([G.scalePx(1, 0.5), G.scalePx(1, 0.5, 0.25)], [1, 0.5], 'elsewhen floors hairlines at an overridable pixel')
assertDeepEqual([G.scalePx(2.5, 0), G.scalePx(2.5, undefined), G.scalePx(2.5, NaN)], [2.5, 2.5, 2.5], 'elsewhen treats a nonsense scale as 1')

assertDeepEqual([[0, 90], [0, -90], [170, -170], [-170, 170], [0, 180], [0, -180], [10, 190], [0, 540]].map(([a, b]) => G.shortestTurn(a, b)), [90, -90, 20, -20, 180, 180, 180, 180], 'elsewhen turns the short way round')
assert(Math.abs(G.shortestTurn(1080 + 5, 10) - 5) < 1e-9, 'elsewhen turns the short way from a wound-up spin')

// ---- clipping to the disc

const R = 28
const DISC = Math.PI * R * R
const area = poly => {
  let a = 0
  for (let i = 0; i < poly.length; i++) {
    const j = (i + 1) % poly.length
    a += poly[i].x * poly[j].y - poly[j].x * poly[i].y
  }
  return Math.abs(a) / 2
}
let worst = 0
let previous = null
for (let spin = 0; spin < 360; spin += 0.25) {
  const total = land.reduce((sum, ring) => sum + area(G.clipRingToDisc(ring, spin, 0, R)), 0)
  if (previous !== null) worst = Math.max(worst, Math.abs(total - previous))
  previous = total
}
assert(worst < DISC * 0.01, 'elsewhen clipped land area changes smoothly as the globe turns', `${worst.toFixed(2)} px2 per 0.25 degrees`)
assert(land.every(ring => G.clipRingToDisc(ring, 137, 0, R).every(p => Math.hypot(p.x, p.y) <= R + 0.01)), 'elsewhen keeps clipped polygons inside the disc')
assertEqual(G.clipRingToDisc([0, 0, 1, 0, 1, 1], 180, 0, R).length, 0, 'elsewhen clips a far-side ring to nothing')
assert(G.visibleSegments([[0, -170], [0, -90], [0, 0], [0, 90], [0, 170]], 0, 0, R).every(run => run.every(p => Math.hypot(p.x, p.y) <= R + 0.01)), 'elsewhen breaks polylines at the horizon')

const ring = []
for (let a = 0; a < 40; a++) ring.push(Math.cos(a / 40 * 2 * Math.PI) * 30, Math.sin(a / 40 * 2 * Math.PI) * 20)
const half = G.decimateRing(ring, 2, 8)
assert(half.length / 2 <= ring.length / 4 + 1 && half.length % 2 === 0, 'elsewhen halves a ring into lon,lat pairs')
assert(half[0] === ring[0] && half[1] === ring[1], 'elsewhen starts a decimated ring on the same vertex')
assert(half[half.length - 2] === ring[ring.length - 2] && half[half.length - 1] === ring[ring.length - 1], 'elsewhen ends a decimated ring on its own last vertex')
const originals = new Set()
for (let i = 0; i < ring.length; i += 2) originals.add(ring[i] + ',' + ring[i + 1])
let kept = true
for (let i = 0; i < half.length; i += 2) if (!originals.has(half[i] + ',' + half[i + 1])) kept = false
assert(kept, 'elsewhen keeps only original vertices')
const tiny = [0, 0, 1, 0, 1, 1, 0, 1]
assert(G.decimateRing(tiny, 2, 8) === tiny && G.decimateRing(ring, 1, 8) === ring, 'elsewhen leaves small rings and step 1 alone')
const bbox = poly => poly.reduce((b, p) => [Math.min(b[0], p.x), Math.min(b[1], p.y), Math.max(b[2], p.x), Math.max(b[3], p.y)], [Infinity, Infinity, -Infinity, -Infinity])
const coarse = G.clipRingToDisc(half, 10, 0, R)
const full = bbox(G.clipRingToDisc(ring, 10, 0, R))
assert(coarse.length >= 3 && bbox(coarse).every((v, i) => Math.abs(v - full[i]) < R * 0.03), 'elsewhen clips a decimated ring to the same ground')
assert(land.every(r => {
  const d = G.decimateRing(r, 2, 8)
  return d.length % 2 === 0 && d.length >= 6 && d.length <= r.length
}), 'elsewhen decimates every world.json ring')

// ---- the moon

const eclipses = [
  ['2017-08-21T18:26Z', 0.0],
  ['2024-04-08T18:17Z', 0.0],
  ['2019-01-21T05:12Z', 0.5],
  ['2022-11-08T10:59Z', 0.5],
  ['2021-05-26T11:19Z', 0.5]
]
const offByDays = eclipses.map(([iso, want]) => {
  let d = Math.abs(G.moonPhase(Date.parse(iso)) - want)
  if (d > 0.5) d = 1 - d
  return d * G.SYNODIC_MONTH
})
assert(offByDays.every(d => d <= 1), 'elsewhen puts eclipses within a day of new and full moon', offByDays.join(', '))
assert([0, 1e12, Date.now(), Date.UTC(1970, 0, 1)].every(ms => { const p = G.moonPhase(ms); return p >= 0 && p < 1 }), 'elsewhen keeps the moon phase in [0, 1)')
const now = Date.now()
const drift = Math.abs(G.moonPhase(now) - G.moonPhase(now + G.SYNODIC_MONTH * 86400000))
assert(drift < 1e-6 || drift > 1 - 1e-6, 'elsewhen repeats the phase after a synodic month')

const MOON_R = 40
const illumination = phase => (1 - Math.cos(2 * Math.PI * phase)) / 2
const inside = (poly, x, y) => {
  let c = false
  for (let i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    const a = poly[i], b = poly[j]
    if (((a.y > y) !== (b.y > y)) && (x < (b.x - a.x) * (y - a.y) / (b.y - a.y) + a.x)) c = !c
  }
  return c
}
const measure = phase => {
  const poly = G.moonLitOutline(phase, MOON_R, 96)
  let lit = 0, disc = 0, left = 0, right = 0
  for (let y = -MOON_R; y <= MOON_R; y += 0.5)
    for (let x = -MOON_R; x <= MOON_R; x += 0.5) {
      if (x * x + y * y > MOON_R * MOON_R) continue
      disc++
      if (!inside(poly, x, y)) continue
      lit++
      if (x < 0) left++; else right++
    }
  return { frac: lit / disc, left, right }
}
const phases = [0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875]
const measured = phases.map(measure)
assert(phases.every((p, i) => Math.abs(measured[i].frac - illumination(p)) < 0.03), 'elsewhen draws the lit area the phase calls for')
assert(measured[1].right > measured[1].left * 20 && measured[2].left < measured[2].right * 0.05, 'elsewhen lights the right limb while waxing')
assert(measured[7].left > measured[7].right * 20 && measured[6].right < measured[6].left * 0.05, 'elsewhen lights the left limb while waning')
assert(measured[0].frac < 0.01 && measured[4].frac > 0.99, 'elsewhen draws new moon dark and full moon lit')
assert([0, 0.2, 0.4, 0.6, 0.8].every(p => G.moonLitOutline(p, MOON_R, 48).every(q => Math.hypot(q.x, q.y) <= MOON_R + 1e-6)), 'elsewhen keeps the moon outline inside its disc')

// ---- day and night against Open-Meteo

if (process.env.ELSEWHEN_ONLINE) {
  const lats = cities.map(c => c[2]).join(',')
  const lons = cities.map(c => c[3]).join(',')
  https.get(`https://api.open-meteo.com/v1/forecast?latitude=${lats}&longitude=${lons}&current=is_day`, res => {
    let body = ''
    res.on('data', d => body += d)
    res.on('end', () => {
      const feed = JSON.parse(body)
      const sun = G.subsolarPoint(Date.now())
      // Open-Meteo's flag lags up to 15 minutes, so only disagreements away from the horizon count.
      const wrong = []
      feed.forEach((entry, i) => {
        const theirs = (entry.current || {}).is_day
        const mine = G.isDaylight(cities[i][2], cities[i][3], sun) ? 1 : 0
        if (theirs !== undefined && mine !== theirs && Math.abs(G.solarElevation(cities[i][2], cities[i][3], sun)) > 4) wrong.push(cities[i][0])
      })
      assertDeepEqual(wrong, [], 'elsewhen agrees with Open-Meteo about day and night')
    })
  }).on('error', error => fail('elsewhen reaches Open-Meteo', error.message))
}
JS
