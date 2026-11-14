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

const limit = { start: 75, end: 80 }
const noLimit = { start: 0, end: 100 }

assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.PendingCharge }, false, states, limit), 'power detects threshold by pending charge state')
assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0.1, timeToFull: 120 }, false, states, limit), 'power detects threshold by stalled charging')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 1.0, timeToFull: 120 }, false, states), 'power does not flag active charging as threshold')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.5, state: states.Discharging }, false, states), 'power does not flag discharging as threshold')
// Right after plug-in UPower steps through pending-charge and reports 0 W for
// ~10 s; that is only a hold inside a real limit the level has reached.
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.33, state: states.PendingCharge }, false, states, noLimit), 'power does not flag pending charge as threshold without a limit')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.33, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, noLimit), 'power does not flag the unmeasured rate after plug-in as threshold without a limit')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.33, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, limit), 'power does not flag the unmeasured rate as threshold below the limit start')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.33, state: states.PendingCharge }, false, states, limit), 'power does not flag pending charge as threshold below the limit start')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.PendingCharge }, false, states), 'power does not flag threshold when the battery exposes no limit')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.94, state: states.FullyCharged }, false, states, noLimit), 'power does not flag firmware stopping short of full as threshold without a limit')
assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.75, state: states.FullyCharged }, false, states, limit), 'power detects threshold at the limit start')
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.33, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, noLimit),
  power.batteryIcon({ isPresent: true, percentage: 0.33, state: states.Charging, changeRate: 40, timeToFull: 3600 }, false, states, noLimit),
  'power shows the charging icon while the rate is still unmeasured after plug-in'
)
assertEqual(power.modeLabel({ isPresent: true, percentage: 0.8, state: states.PendingCharge }, false, states, null, limit), 'Threshold', 'power labels a held charge')
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
