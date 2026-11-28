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

assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, true, 'off'), 'power does not flag stalled charging as threshold when limit is off')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, true, 'once'), 'power does not flag stalled charging as threshold during a one-time top-up')
assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, true, 'on'), 'power flags stalled charging as threshold when limit is on')
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, true, 'off'),
  power.batteryIcon({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 1.0, timeToFull: 120 }, false, states, true, 'off'),
  'power keeps charging icon when limit is off and charge rate is low'
)
assertEqual(
  power.modeLabel({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, undefined, true, 'once'),
  'Charging',
  'power keeps charging label during a one-time top-up when charge rate is low'
)

assertEqual(power.chargeLimitFraction({ limit_mode: 'threshold', limit_end: '80' }), 0.8, 'power computes numeric charge limit fraction for the bar tick')
assertEqual(power.chargeLimitFraction({ limit_mode: 'firmware', limit_end: '80' }), 0, 'power omits bar tick for firmware-only conservation mode')
assertEqual(power.chargeLimitHeader({ limit_mode: 'threshold', limit_end: '80' }), 'CHARGE LIMIT · 80%', 'power formats charge limit section header with cap percentage')
assertEqual(power.chargeLimitHeader({ limit_mode: 'firmware' }), 'CHARGE LIMIT', 'power omits percentage on firmware-only charge limit header')

assertEqual(
  power.formatSleepShort({ sleep_duration: '8h 12m', sleep_drain_pct_hr: '0.4%/h', sleep_drain_w: '0.3W', sleep_mode: 's2idle', sleep_s0ix: '97%' }),
  '0.4%/h',
  'power keeps grid sleep reading compact'
)
assertEqual(
  power.formatSleepTooltip({ sleep_duration: '8h 12m', sleep_drain_pct: '3.3%', sleep_drain_pct_hr: '0.4%/h', sleep_drain_w: '0.3W', sleep_mode: 's2idle', sleep_s0ix: '97%' }),
  '8h 12m · −3.3% · 0.4%/h · 0.3W · S0ix 97%',
  'power puts full sleep drain breakdown and S0ix in tooltip'
)
assertEqual(
  power.formatSleepTooltip({ sleep_duration: '3h', sleep_drain_pct_hr: '0.2%/h', sleep_mode: 'deep' }),
  '3h · 0.2%/h',
  'power omits S0ix for non-s2idle sleeps'
)
assertEqual(power.formatSleepShort({}), '', 'power hides sleep reading when empty')
assert(power.isLowS0ix({ sleep_mode: 's2idle', sleep_s0ix: '64%' }), 'power flags low S0ix residency under 80%')
assert(!power.isLowS0ix({ sleep_mode: 's2idle', sleep_s0ix: '97%' }), 'power does not flag healthy S0ix residency')
assert(!power.isLowS0ix({ sleep_mode: 'deep', sleep_s0ix: '0%' }), 'power ignores S0ix outside s2idle')

assertDeepEqual(
  power.moveFocus('profile', 1, 0, -1, true, false, 3),
  { focusRow: 'limit', profileIndex: 1 },
  'power moves keyboard focus up from profile row to charge limit toggle'
)
assertDeepEqual(
  power.moveFocus('profile', 1, 0, -1, true, true, 3),
  { focusRow: 'topup', profileIndex: 1 },
  'power moves keyboard focus up from profile row to top-up button when visible'
)
assertDeepEqual(
  power.moveFocus('topup', 1, 0, -1, true, true, 3),
  { focusRow: 'limit', profileIndex: 1 },
  'power moves keyboard focus up from top-up button to charge limit toggle'
)
assertDeepEqual(
  power.moveFocus('limit', 1, 0, 1, true, true, 3),
  { focusRow: 'topup', profileIndex: 1 },
  'power moves keyboard focus down from charge limit toggle to top-up button'
)
assertDeepEqual(
  power.moveFocus('limit', 1, 1, 0, true, false, 3),
  { focusRow: 'limit', profileIndex: 1 },
  'power leaves profile index untouched on sideways key while on charge limit toggle'
)
assertDeepEqual(
  power.moveFocus('profile', 0, 0, 1, false, false, 3),
  { focusRow: 'profile', profileIndex: 1 },
  'power keeps profile-row vertical movement when charge limit is unsupported'
)
JS
