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

assertEqual(power.historyDevicePath('BAT0'), '/org/freedesktop/UPower/devices/battery_BAT0', 'power names the battery history device')
assertEqual(power.historyDevicePath('macsmc-battery'), '/org/freedesktop/UPower/devices/battery_macsmc_battery', 'power names a battery whose native path has dashes')

const historyReply = rows => JSON.stringify({ type: 'a(udu)', data: [rows] })
assertDeepEqual(
  power.parseHistory(historyReply([[300, 96, 2], [200, 0, 0], [200, 98, 4], [100, 99, 4]])),
  [{ time: 100, value: 99 }, { time: 200, value: 98 }, { time: 300, value: 96 }],
  'power orders the history oldest first and skips the row UPower writes when it starts'
)
assertEqual(power.parseHistory(''), null, 'power reads a missing history reply as none')

// A 100-second window ending at 1000: 80% from before it opens, 60% at 950,
// then the live level carries the line to now.
assertDeepEqual(
  power.historyPoints([{ time: 800, value: 80 }, { time: 950, value: 60 }], 1000, 100, 60),
  [{ x: 0, y: 0.2 }, { x: 0.5, y: 0.2 }, { x: 0.5, y: 0.4 }, { x: 1, y: 0.4 }],
  'power holds each charge reading until the next and opens on the level before the window'
)
assertDeepEqual(
  power.historyPoints([], 1000, 100, 75),
  [{ x: 0, y: 0.25 }, { x: 1, y: 0.25 }],
  'power holds the live level across a window with no readings'
)
assertDeepEqual(
  power.historyPoints([{ time: 950, value: 60 }], 1000, 100, 55),
  [{ x: 0.5, y: 0.4 }, { x: 1, y: 0.4 }, { x: 1, y: 0.45 }],
  'power starts the line at the first reading when nothing came before it, and ends on the live level'
)

// The same window read under the pointer: nothing before the first reading,
// 80% at the start, 60% from the step on, and the live level at now.
const steps = power.historyPoints([{ time: 21600, value: 80 }, { time: 25200, value: 60 }], 28800, 7200, 55)
assertEqual(power.historyReadout(steps, 0.25, 7200), '80% · 1h 30m ago', 'power reads the level before a step under the pointer')
assertEqual(power.historyReadout(steps, 0.5, 7200), '60% · 1h 0m ago', 'power reads the new level on a step under the pointer')
assertEqual(power.historyReadout(steps, 1, 7200), '55% · now', 'power reads the live level at the end of the chart')
assertEqual(power.historyReadout(power.historyPoints([{ time: 950, value: 60 }], 1000, 100, 55), 0.2, 100), '', 'power says nothing before the first reading')
JS
