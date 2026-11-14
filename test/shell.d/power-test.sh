#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const power = requireFromRoot('shell/plugins/panels/power/Model.js')
const states = { Charging: 1, Discharging: 2, FullyCharged: 4, PendingCharge: 5 }

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
assertEqual(power.modeLabel({ isPresent: true, percentage: 0.5, state: states.Discharging }, false, states), 'On battery', 'power reports discharge despite line power being online')
assert(power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging }, false, states).length > 0, 'power maps battery icons')
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Discharging }, false, states),
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Discharging }, true, states),
  'power reports the same discharge icon with either line-power state'
)
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging, changeRate: 1.0, timeToFull: 120 }, true, states),
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging, changeRate: 1.0, timeToFull: 120 }, false, states),
  'power reports the same charging icon with either line-power state'
)
assertEqual(power.modeLabel({ isPresent: true, percentage: 0.5, state: states.Charging }, true, states), 'Charging', 'power reports charging despite a stale on-battery flag')
assertEqual(power.modeLabel({ isPresent: true, percentage: 1, state: states.Discharging }, false, states), 'On battery', 'a full battery can already be discharging')
assert(!power.isDischarging(null, true, states), 'a missing battery does not discharge')
assert(!power.isDischarging({ isPresent: false, state: states.Discharging }, true, states), 'an absent battery does not discharge')
assert(!power.isDischarging({ isPresent: true, state: states.FullyCharged }, true, states), 'a fully charged state is idle despite a stale daemon flag')
for (const onBattery of [false, true]) {
  assertEqual(power.isDischarging({ isPresent: true, state: 0 }, onBattery, states), onBattery, 'unknown flow falls back to plug status')
}
assert(power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Discharging }, false, states) !== power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging, changeRate: 1, timeToFull: 120 }, false, states), 'charging and discharging have different icons at the same level')
JS
