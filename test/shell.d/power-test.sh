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

// Right after plugging in, firmware flaps through not-charging and stalled
// readings; the panel's settled verdict keeps the charging icon and label.
for (const reading of [
  { state: states.PendingCharge },
  { state: states.Discharging },
  { state: states.FullyCharged },
  { state: states.Charging, changeRate: 0, timeToFull: 0 }
]) {
  const flapping = { isPresent: true, percentage: 0.16, ...reading }
  const charging = { isPresent: true, percentage: 0.16, state: states.Charging, changeRate: 13.5, timeToFull: 9360 }
  assertEqual(power.modeLabel(flapping, false, states, undefined, false), 'Charging', 'power keeps charging label while the reading settles')
  assertEqual(power.batteryIcon(flapping, false, states, false), power.batteryIcon(charging, false, states), 'power keeps charging icon while the reading settles')
}
assertEqual(power.modeLabel({ isPresent: true, percentage: 0.8, state: states.PendingCharge }, false, states, undefined, true), 'Threshold', 'power labels a settled threshold')

assertEqual(power.thresholdSettleDelay(1000, 1000), 60000, 'power waits a minute after plug-in before reporting a threshold')
assertEqual(power.thresholdSettleDelay(1000 + 55000, 1000), 10000, 'power still wants a steady reading late in the plug-in window')
assertEqual(power.thresholdSettleDelay(1000 + 600000, 1000), 10000, 'power needs a steady reading long after plug-in')
assertEqual(power.thresholdSettleDelay(5000000, 0), 10000, 'power needs a steady reading when it never saw the plug-in')

// A USB-C charger can drop out for a few seconds right after it goes in.
assertEqual(power.unplugSettleDelay(1000 + 5500, 1000), 6000, 'power waits out a charger dropout just after plug-in')
assertEqual(power.unplugSettleDelay(1000 + 20000, 1000), 0, 'power shows an unplug at once outside the plug-in window')
assertEqual(power.unplugSettleDelay(5000000, 0), 0, 'power shows an unplug at once when it never saw the plug-in')
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
