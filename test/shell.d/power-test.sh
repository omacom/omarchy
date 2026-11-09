#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const power = requireFromRoot('shell/plugins/panels/power/Model.js')
const states = { Charging: 1, Discharging: 2, FullyCharged: 3, PendingCharge: 4 }

assertEqual(power.selectProfileIndex(0, 1, ['balanced', 'performance']), 1, 'power advances profile selection')
assertEqual(power.selectProfileIndex(1, 1, ['balanced', 'performance']), 1, 'power clamps profile selection')

assertDeepEqual(power.parseKeyValue('time\t2:00\nenergy\t42\n'), { time: '2:00', energy: '42' }, 'power parses key-value output')
assertDeepEqual(
  power.parseProfiles('power-saver\t0\nbalanced\t1\nperformance\t0\n', 5),
  { profiles: ['power-saver', 'balanced', 'performance'], activeProfile: 'balanced', profileIndex: 2 },
  'power parses profile output and clamps selection'
)

assert(power.profileIcon('performance').length > 0, 'power maps profile icons')
assertEqual(power.batteryFraction({ isPresent: true, percentage: 1.5 }), 1, 'power clamps battery fraction')

assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.PendingCharge }, false, states), 'power detects threshold by pending charge state')
assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0.1, timeToFull: 120 }, false, states), 'power detects threshold by stalled charging')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 1.0, timeToFull: 120 }, false, states), 'power does not flag active charging as threshold')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.5, state: states.Discharging }, false, states), 'power does not flag discharging as threshold')
assertEqual(power.modeLabel({ isPresent: true, percentage: 1, state: states.FullyCharged }, false, states), 'Fully charged', 'power labels full battery')
assertEqual(power.localizeReading('13.1W'), '13.1W', 'power keeps battery readings in English digits by default')
assertEqual(power.localizeReading('75-80%', function(v, d) { return '<' + v + '>' }), '<75>-<80>%', 'power localizes every number in a battery reading')
assertEqual(power.localizeReading('13.10W', function(v, d) { return v.toFixed(d).replace('.', ',') }), '13,10W', 'power keeps a reading\'s decimals when localizing')
assertEqual(power.localizeReading(undefined), '', 'power reads a missing battery field as empty')
assertEqual(power.modeLabel({ isPresent: true, percentage: 0.5, state: states.Discharging }, true, states), 'On battery', 'power labels battery mode')
assertEqual(power.modeLabel({ isPresent: true, percentage: 0.5, state: states.Discharging }, false, states), 'Charging', 'power treats external power as newer than stale discharging state')
assert(power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging }, false, states).length > 0, 'power maps battery icons')
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Discharging }, false, states),
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging, changeRate: 1.0, timeToFull: 120 }, false, states),
  'power shows charging icon when external power is present before battery state refreshes'
)
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging }, true, states),
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Discharging }, true, states),
  'power shows battery icon when unplugged before battery state refreshes'
)
JS

run_node_test <<'JS'
const history = requireFromRoot('shell/plugins/panels/power/History.js')
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
const history = requireFromRoot('shell/plugins/panels/power/History.js')

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
