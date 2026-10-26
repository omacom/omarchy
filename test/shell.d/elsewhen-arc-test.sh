#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const { layout } = requireFromRoot('shell/plugins/panels/elsewhen/Arc.js')

const near = (a, b, eps) => Math.abs(a - b) <= (eps === undefined ? 0.01 : eps)
const mono = (count, width) => new Array(count).fill(width === undefined ? 6 : width)
const RISE = 6

// ---- a flat line

const flat = layout(mono(10), 0, true)
assert(flat.height === 0 && flat.width === 60, 'elsewhen lays a flat line out full width with no height')
assertEqual(flat.chars.map(c => c.x).join(), '0,6,12,18,24,30,36,42,48,54', 'elsewhen lays a flat line out end to end')
assert(flat.chars.every(c => c.rotation === 0), 'elsewhen turns nothing on a flat line')
assertEqual(layout([], 6, true).chars.length, 0, 'elsewhen lays out empty text')
assertEqual(layout(mono(4), -3, true).height, 0, 'elsewhen treats a negative rise as flat')

// ---- the rise

for (const count of [20, 30, 50, 90]) {
  const r = layout(mono(count), RISE, true)
  const ys = r.chars.map(c => c.y)
  const dip = Math.max(...ys) - (ys[0] + ys[ys.length - 1]) / 2
  assert(near(r.height, RISE, 0.05), `elsewhen bends ${count} characters by the rise`, r.height)
  // The end glyphs sit half a character in from the ends of the arc.
  assert(dip > RISE * 0.85 && dip <= RISE, `elsewhen dips ${count} glyphs by about the rise`, dip)
}

// ---- shape

const smile = layout(mono(30), RISE, true)
const frown = layout(mono(30), RISE, false)
const last = smile.chars.length - 1
assert(smile.chars[15].y > smile.chars[0].y && frown.chars[15].y < frown.chars[0].y, 'elsewhen dips a smile and raises a frown')
assert(smile.chars.every((c, i) => near(c.y, smile.height - frown.chars[i].y) && near(c.rotation, -frown.chars[i].rotation) && near(c.x, frown.chars[i].x)), 'elsewhen mirrors a smile and a frown')
assert(smile.chars.every((c, i) => near(c.y, smile.chars[last - i].y) && near(c.rotation, -smile.chars[last - i].rotation)), 'elsewhen bends symmetrically')
assert(smile.chars.every((c, i) => i === 0 || c.x > smile.chars[i - 1].x) && near(smile.chars[0].x, 0), 'elsewhen advances from the left edge')
// Qt turns clockwise for a positive angle.
assert(smile.chars[0].rotation > 0 && smile.chars[last].rotation < 0, 'elsewhen leans into each end')
assert(near(smile.chars[14].rotation, -smile.chars[15].rotation), 'elsewhen levels the middle')

const offTangent = []
for (let i = 1; i < smile.chars.length; i++) {
  const dy = smile.chars[i].y - smile.chars[i - 1].y
  const dx = smile.chars[i].x - smile.chars[i - 1].x
  const turn = (smile.chars[i].rotation + smile.chars[i - 1].rotation) / 2
  if (!near(Math.atan2(dy, dx) * 180 / Math.PI, turn, 0.1)) offTangent.push(i)
}
assertDeepEqual(offTangent, [], 'elsewhen turns each character along the arc')

// ---- proportional text and reserved width

const prop = layout([4, 4, 4, 16, 16, 16].concat(mono(24)), RISE, true)
assert(near(prop.chars[1].x - prop.chars[0].x, 4, 0.1) && near(prop.chars[4].x - prop.chars[3].x, 16, 0.1), 'elsewhen keeps proportional advances')

const wide = layout(mono(40), 20, true)
assert(wide.chars.every(c => c.x >= -0.001 && c.x + 6 <= wide.width + 0.001), 'elsewhen reserves width for every box')
assert(wide.width < 240 && wide.width > 230, 'elsewhen narrows the arc only a little', wide.width)

const absurd = layout(mono(10), 1000, true)
assert(isFinite(absurd.height) && absurd.height <= 15.01, 'elsewhen clamps an absurd rise', absurd.height)
assert(absurd.chars.length === 10 && absurd.chars.every(c => isFinite(c.x) && isFinite(c.y) && isFinite(c.rotation)), 'elsewhen still lays out every character under an absurd rise')
JS
