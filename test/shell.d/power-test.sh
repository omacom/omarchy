#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const power = requireFromRoot('shell/plugins/panels/power/Model.js')
const states = { Unknown: 0, Charging: 1, Discharging: 2, FullyCharged: 3, PendingCharge: 4 }

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
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, false), 'power does not read a rate from before the charger arrived as a threshold')
assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, true), 'power detects threshold by stalled charging once the rate is fresh')
assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.PendingCharge }, false, states, false), 'power detects threshold by pending charge state before the rate is fresh')
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, false),
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging, changeRate: 1.0, timeToFull: 120 }, false, states),
  'power shows charging icon while the charge rate is not fresh yet'
)
assertEqual(power.modeLabel({ isPresent: true, percentage: 0.4, state: states.Charging, changeRate: 0 }, false, states, undefined, false), 'Charging', 'power labels charging while the charge rate is not fresh yet')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.5, state: states.Discharging }, false, states), 'power does not flag discharging as threshold')
assertEqual(power.modeLabel({ isPresent: true, percentage: 1, state: states.FullyCharged }, false, states), 'Fully charged', 'power labels full battery')
assertEqual(power.localizeReading('13.1W'), '13.1W', 'power keeps battery readings in English digits by default')
assertEqual(power.localizeReading('75-80%', function(v, d) { return '<' + v + '>' }), '<75>-<80>%', 'power localizes every number in a battery reading')
assertEqual(power.localizeReading('13.10W', function(v, d) { return v.toFixed(d).replace('.', ',') }), '13,10W', 'power keeps a reading\'s decimals when localizing')
assertEqual(power.localizeReading(undefined), '', 'power reads a missing battery field as empty')

const discharging = { isPresent: true, percentage: 0.4, state: states.Discharging }
const charging = { ...discharging, state: states.Charging, changeRate: 1, timeToFull: 120 }
const unknown = { ...discharging, state: states.Unknown }

assert(power.drawingFromBattery(discharging, false, states), 'power detects a battery draining with a charger online')
assert(!power.drawingFromBattery(charging, true, states), 'power detects charging with a stale on-battery flag')
assert(power.drawingFromBattery(unknown, true, states), 'power falls back to the source when the battery state is unknown')
assert(!power.drawingFromBattery({ isPresent: false }, true, states), 'power reports no draw without a battery')
assertEqual(power.modeLabel(discharging, false, states), 'On battery', 'power labels a discharging battery when a charger is reported online')
assertEqual(power.modeLabel(charging, true, states), 'Charging', 'power labels charging before the on-battery flag catches up')
assertEqual(power.batteryIcon(discharging, false, states), power.batteryIcon(discharging, true, states), 'power uses the ordinary battery icon when a charger is reported online')
assertEqual(power.batteryIcon(charging, true, states), power.batteryIcon(charging, false, states), 'power uses the charging icon before the on-battery flag catches up')
assert(power.batteryIcon(discharging, false, states) !== power.batteryIcon(charging, true, states), 'power shows different icons for charging and discharging at the same level')
JS
