#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const battery = requireFromRoot('shell/plugins/services/battery/BatteryModel.js')
const discharging = 1

assertEqual(battery.batteryPercentage({ isPresent: true, percentage: 0.126 }), 13, 'battery rounds display percentage')
assertEqual(battery.batteryPercentage({ isPresent: false, percentage: 0.5 }), -1, 'battery reports missing battery')
assert(battery.isDischarging({ isPresent: true, state: discharging }, true, discharging), 'battery detects discharging state')
assert(!battery.isDischarging({ isPresent: true, state: discharging }, false, discharging), 'battery requires on-battery state')

assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.08, state: discharging }, true, discharging, 10, false),
  { level: 8, notify: true, notifiedLowBattery: true },
  'battery warns once under threshold'
)
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.08, state: discharging }, true, discharging, 10, true),
  { level: 8, notify: false, notifiedLowBattery: true },
  'battery keeps low-battery notified state'
)
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.4, state: discharging }, true, discharging, 10, true),
  { level: 40, notify: false, notifiedLowBattery: false },
  'battery clears notified state after recovery'
)

const reply = profile => JSON.stringify({ type: 's', data: profile })
assertEqual(battery.parseActiveProfile(reply('power-saver')), 'power-saver', 'battery parses the busctl profile reply')
assertEqual(battery.parseActiveProfile(''), '', 'battery reads a missing daemon as no profile')

assertEqual(battery.profileAfterRead('', reply('balanced'), 0, 0), 'balanced', 'battery takes its startup read')

// A read that sampled balanced before a power-saver signal must not undo it.
const signalsAtStart = 3
assertEqual(
  battery.profileAfterRead('power-saver', reply('balanced'), signalsAtStart, signalsAtStart + 1),
  'power-saver',
  'battery drops a read made stale by a change signal'
)
assertEqual(
  battery.profileAfterRead('balanced', reply('power-saver'), signalsAtStart, signalsAtStart),
  'power-saver',
  'battery takes a read no signal overtook'
)
JS

run_node_test <<'JS'
const history = requireFromRoot('shell/plugins/services/battery/History.js')
const now = 1800000000
const hour = 3600
const line = (kind, rows) => kind + '\t' + JSON.stringify(rows)

const junk = history.parseHistory([
  'charge\t<img src="https://example.invalid/x">',
  line('rate', [[now - 10 * 24 * hour, 5, 2], [now + 24 * hour, 5, 2], ['<b>1</b>', 5, 2], [now - 60, -1, 2], [now - 30, 4.5, 9]])
].join('\n'), now)
assertEqual(junk.charge.length + junk.rate.length, 0, 'battery history drops markup, out-of-range times, values and states')
assertEqual(history.parseHistory(line('rate', Array.from({ length: 6000 }, (_, i) => [now - i, 5, 2])), now).rate.length, 5000, 'battery history caps the points it keeps')

// Unplugged at 100%, awake for an hour to 90%, asleep four hours (88% on
// waking), awake to 80%, asleep three hours on the charger (100% on waking),
// awake for an hour to 95%.
const t = h => now - 10 * hour + h * hour
const rate = []
for (let s = t(0); s <= t(1); s += 30) rate.push([s, 5, 2])
for (let s = t(5); s <= t(6); s += 30) rate.push([s, 6, 2])
for (let s = t(9); s <= t(10); s += 30) rate.push([s, 5, 2])
const charge = [[t(0), 100, 2], [t(1), 90, 2], [t(5), 88, 2], [t(6), 80, 2], [t(9), 100, 2], [t(10), 95, 2]]
const data = history.parseHistory(line('charge', charge) + '\n' + line('rate', rate), now)
const tl = history.timeline(data, now)

assertDeepEqual(tl.sleeps.map(s => [s.start, s.end, s.charged]), [[t(1), t(5), false], [t(6), t(9), true]], 'battery history finds sleeps from gaps in the samples')
assertDeepEqual(tl.segments.map(s => s.source), ['battery', 'ac', 'battery'], 'battery history counts a sleep that woke up charged as time on AC')

const lastCharge = history.lastSession(data, tl, 'ac', now)
assertDeepEqual([lastCharge.fromPct, lastCharge.toPct, lastCharge.ongoing], [80, 100, false], 'battery history reports a charge made while asleep')

const drain = history.drainSince(data, tl, t(0), now)
assertDeepEqual([drain.awakeSec, drain.usedPct, drain.sleepPct], [3 * hour, 23, 2], 'battery history keeps sleep out of the awake drain')

const runs = history.graphRuns(history.graphPoints(data.charge, t(0), now), tl.sleeps)
assertEqual(runs.length, 3, 'battery history splits the graph line at each sleep')
assertDeepEqual(runs[1][0], { t: t(5), v: 88 }, 'battery history picks the line up at the level on waking')
JS

run_node_test <<'JS'
const history = requireFromRoot('shell/plugins/services/battery/History.js')

// A sleep that began before the window still breaks the line at its start.
const clipped = history.graphRuns([{ t: 100, v: 60 }, { t: 400, v: 50 }, { t: 1000, v: 45 }], [{ start: 0, end: 400 }])
assertDeepEqual(clipped[0], [{ t: 100, v: 60 }], 'battery history breaks the line at a sleep that began before the window')
assertDeepEqual(clipped[1][0], { t: 400, v: 50 }, 'battery history picks the line up on waking inside the window')

// Every sleep between two readings breaks the line, not only the last.
const runs = history.graphRuns([{ t: 0, v: 50 }, { t: 1000, v: 40 }], [{ start: 100, end: 300 }, { start: 400, end: 900 }])
assertDeepEqual(runs.map(run => [run[0].t, run[run.length - 1].t]), [[0, 100], [300, 400], [900, 1000]], 'battery history breaks the line at every sleep')
assertDeepEqual([runs[1][0].v, runs[2][0].v], [50, 40], 'battery history holds the level through an earlier sleep and takes the reading on waking')
assertDeepEqual(history.graphRuns([{ t: 0, v: 50 }, { t: 1000, v: 100 }, { t: 1060, v: 99 }], [{ start: 200, end: 1000 }])[1][0], { t: 1000, v: 100 }, 'battery history takes the reading made on waking, not the one after')
JS

run_node_test <<'JS'
const history = requireFromRoot('shell/plugins/services/battery/History.js')
const now = 1800000000
const rate = []
for (let s = now - 7200; s <= now; s += 30) rate.push([s, 5, 2])
const data = history.parseHistory('charge\t' + JSON.stringify([[now - 7200, 80, 2], [now - 3600, 70, 2], [now - 60, 61, 2]]) + '\nrate\t' + JSON.stringify(rate), now)
const views = history.views(data, history.timeline(data, now), now)

// The power panel draws straight from these, so each window must carry its
// own start, points from that start to now, and runs to stroke.
assertDeepEqual(Object.keys(views.windows), ['6h', '24h', '3d'], 'battery history works out every window the panel offers')
const day = views.windows['24h']
assertDeepEqual([day.start, day.span, day.points[day.points.length - 1].t, day.runs.length], [now - 86400, 86400, now, 1], 'battery history gives each window its start, span, points up to now and runs')
assertEqual(views.lastBattery.fromPct, 80, 'battery history works out the last run on battery once for every window')
JS
