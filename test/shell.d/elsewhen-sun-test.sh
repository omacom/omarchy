#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const { Sun } = requireFromRoot('test/shell.d/elsewhen/solar.js')

const noonAt = ([y, mo, d], offset) => Date.UTC(y, mo - 1, d, 12) - offset * 60000
const within = (got, want, slack) => Math.abs(got - want) <= slack

// Open-Meteo's published sunrise and sunset in UTC:
// name, lat, lon, local date, UTC offset in minutes, rise, set, minutes of slack.
// Past 64 north the sun meets the horizon at a shallow angle and needs more slack.
const REFERENCE = [
  ['Chicago', 41.85, -87.65, [2026, 8, 31], -300, '2026-08-31T11:15', '2026-09-01T00:26', 2],
  ['Auckland', -36.85, 174.76, [2026, 8, 31], 720, '2026-08-30T18:43', '2026-08-31T05:59', 2],
  ['Copenhagen', 55.68, 12.57, [2026, 8, 31], 120, '2026-08-31T04:13', '2026-08-31T18:07', 2],
  ['Tokyo', 35.69, 139.69, [2026, 8, 31], 540, '2026-08-30T20:12', '2026-08-31T09:11', 2],
  ['Quito', -0.22, -78.51, [2026, 8, 31], -300, '2026-08-31T11:10', '2026-08-31T23:17', 2],
  ['Kashgar', 39.47, 75.99, [2026, 8, 31], 480, '2026-08-31T00:23', '2026-08-31T13:29', 2],
  ['Reykjavik', 64.15, -21.94, [2025, 12, 21], 0, '2025-12-21T11:21', '2025-12-21T15:30', 2],
  ['Sydney', -33.87, 151.21, [2025, 12, 21], 660, '2025-12-20T18:40', '2025-12-21T09:05', 2],
  ['Nairobi', -1.29, 36.82, [2026, 3, 20], 180, '2026-03-20T03:36', '2026-03-20T15:43', 2],
  ['Anchorage', 61.22, -149.90, [2026, 6, 21], -480, '2026-06-21T12:19', '2026-06-22T07:43', 2],
  ['Ushuaia', -54.80, -68.30, [2026, 6, 21], -180, '2026-06-21T12:58', '2026-06-21T20:11', 2],
  ['Nuuk', 64.18, -51.72, [2026, 8, 31], -120, '2026-08-31T08:06', '2026-08-31T22:47', 5],
  ['Anadyr', 64.73, 177.51, [2026, 8, 31], 720, '2026-08-30T16:47', '2026-08-31T07:35', 5]
]
const misses = []
for (const [name, lat, lon, date, offset, rise, set, slack] of REFERENCE) {
  const times = Sun.sunTimes(lat, lon, noonAt(date, offset), offset)
  if (times.kind !== 'normal') { misses.push(`${name} has no sunrise`); continue }
  const riseOff = Math.abs(times.riseMs - Date.parse(rise + 'Z')) / 60000
  const setOff = Math.abs(times.setMs - Date.parse(set + 'Z')) / 60000
  if (riseOff > slack) misses.push(`${name} sunrise out by ${riseOff.toFixed(1)} min`)
  if (setOff > slack) misses.push(`${name} sunset out by ${setOff.toFixed(1)} min`)
}
assertDeepEqual(misses, [], 'elsewhen matches published sunrise and sunset times')

// ---- the poles

const longyear = (date, offset) => Sun.sunTimes(78.22, 15.63, noonAt(date, offset), offset)
const midnightSun = longyear([2026, 6, 21], 120)
const polarNight = longyear([2025, 12, 21], 60)
assertEqual(midnightSun.kind, 'midnightSun', 'elsewhen knows the midnight sun')
assertEqual(polarNight.kind, 'polarNight', 'elsewhen knows the polar night')
assertDeepEqual(Sun.litSpans(midnightSun), [{ x0: 0, x1: 1 }], 'elsewhen lights the whole bar under the midnight sun')
assertDeepEqual(Sun.litSpans(polarNight), [], 'elsewhen lights nothing in the polar night')
assert(Sun.litAt(midnightSun, 3 * 60) && !Sun.litAt(polarNight, 12 * 60), 'elsewhen reads daylight at the poles')
assertEqual(Sun.eventMark(midnightSun.riseMinutes), null, 'elsewhen marks no sunrise that does not happen')

// ---- the strip

const chicago = Sun.sunTimes(41.85, -87.65, noonAt([2026, 8, 31], -300), -300)
const span = Sun.litSpans(chicago)
assertEqual(span.length, 1, 'elsewhen draws one band for an ordinary city')
assert(within(span[0].x0 * 1440, 375, 2) && within(span[0].x1 * 1440, 1166, 2), 'elsewhen draws the band from sunrise to sunset on the local clock')
assert(within(chicago.dayMinutes, 791, 2), 'elsewhen measures the length of the day')
assertDeepEqual([5, 12, 22, 0].map(h => Sun.litAt(chicago, h * 60)), [false, true, false, false], 'elsewhen reads daylight through the day')

const kashgar = Sun.sunTimes(39.47, 75.99, noonAt([2026, 8, 31], 480), 480)
assertEqual(Sun.litSpans(kashgar).length, 1, 'elsewhen draws one band for a zone far from its sun')
assert(within(kashgar.riseMinutes, 503, 2) && within(kashgar.setMinutes, 1289, 2), 'elsewhen keeps a far-off sun on its own clock')

const solstice = Sun.sunTimes(64.15, -21.94, noonAt([2026, 6, 21], 0), 0)
const ends = Sun.litSpans(solstice)
assert(solstice.setMinutes > 1440, 'elsewhen sets the Reykjavik solstice sun after midnight')
assertEqual(ends.length, 2, 'elsewhen lights a bar at both ends')
assert(within(ends[0].x0 * 1440, 0, 0.01) && within(ends[0].x1 * 1440, 4, 1), 'elsewhen lights the minutes after midnight')
assert(within(ends[1].x0 * 1440, 175, 1) && within(ends[1].x1 * 1440, 1440, 0.01), 'elsewhen lights from sunrise to the end of the bar')
assertDeepEqual([0, 60, 180].map(m => Sun.litAt(solstice, m)), [true, false, true], 'elsewhen reads daylight on a bar lit at both ends')

assertEqual(Sun.eventMark(solstice.setMinutes), null, 'elsewhen marks no sunset past midnight')
assertDeepEqual([-30, 1500, 0, 1440].map(Sun.eventMark), [null, null, 0, 1], 'elsewhen marks only events on the bar')
JS
