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

assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.PendingCharge }, false, states, undefined, undefined, limit), 'power detects threshold by pending charge state')
assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0.1, timeToFull: 120 }, false, states, undefined, undefined, limit), 'power detects threshold by stalled charging')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 1.0, timeToFull: 120 }, false, states, true, undefined, limit), 'power does not flag active charging as threshold')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, false, undefined, limit), 'power does not read a rate from before the charger arrived as a threshold')
assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, true, undefined, limit), 'power detects threshold by stalled charging once the rate is fresh')
assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.PendingCharge }, false, states, false, undefined, limit), 'power detects threshold by pending charge state before the rate is fresh')
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, false, undefined, limit),
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging, changeRate: 1.0, timeToFull: 120 }, false, states, true, undefined, limit),
  'power shows charging icon while the charge rate is not fresh yet'
)
assertEqual(power.modeLabel({ isPresent: true, percentage: 0.4, state: states.Charging, changeRate: 0 }, false, states, undefined, false), 'Charging', 'power labels charging while the charge rate is not fresh yet')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.5, state: states.Discharging }, false, states), 'power does not flag discharging as threshold')
// Right after plug-in UPower steps through pending-charge and reports 0 W for
// ~10 s; that is only a hold inside a real limit the level has reached.
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.33, state: states.PendingCharge }, false, states, undefined, undefined, noLimit), 'power does not flag pending charge as threshold without a limit')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.33, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, undefined, undefined, noLimit), 'power does not flag the unmeasured rate after plug-in as threshold without a limit')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.33, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, undefined, undefined, limit), 'power does not flag the unmeasured rate as threshold below the limit start')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.33, state: states.PendingCharge }, false, states, undefined, undefined, limit), 'power does not flag pending charge as threshold below the limit start')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.PendingCharge }, false, states), 'power does not flag threshold when the battery exposes no limit')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.94, state: states.FullyCharged }, false, states, undefined, undefined, noLimit), 'power does not flag firmware stopping short of full as threshold without a limit')
assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.75, state: states.FullyCharged }, false, states, undefined, undefined, limit), 'power detects threshold at the limit start')
// Batteries with only an end threshold (or start 0) charge until end, so a hold
// can only happen there.
const endOnly = { start: NaN, end: 80 }
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.33, state: states.PendingCharge }, false, states, undefined, undefined, endOnly), 'power does not flag pending charge as threshold far below an end-only limit')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.33, state: states.PendingCharge }, false, states, undefined, undefined, { start: 0, end: 80 }), 'power does not flag pending charge as threshold far below a limit starting at 0')
assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.PendingCharge }, false, states, undefined, undefined, endOnly), 'power detects threshold at an end-only limit')
// applesmc exposes only an end threshold of 100 while UPower reports its 75/80
// defaults (MacBookPro12,1, #10193): the SMC holding below full, and the
// unmeasured rate after plug-in, are not a threshold.
const appleSmc = { start: NaN, end: 100 }
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.93, state: states.FullyCharged, changeRate: 0 }, false, states, undefined, undefined, appleSmc), 'power does not flag the SMC holding below full as threshold with an end-only limit of 100')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.79, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, true, undefined, appleSmc), 'power does not flag the unmeasured rate as threshold with an end-only limit of 100')
assertEqual(power.modeLabel({ isPresent: true, percentage: 0.93, state: states.FullyCharged, changeRate: 0 }, false, states, null, undefined, undefined, appleSmc) === 'Threshold', false, 'power does not label the SMC holding below full as a held charge')
// With two batteries the combined level says nothing about either one: each is
// checked against its own limit, and the pair is held only when neither can
// still charge.
const bothHeld = [{ fraction: 0.8, start: 75, end: 80 }, { fraction: 0.6, start: 55, end: 60 }]
const oneCharging = [{ fraction: 0.8, start: 75, end: 80 }, { fraction: 0.3, start: 75, end: 80 }]
assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.7, state: states.PendingCharge }, false, states, undefined, undefined, bothHeld), 'power detects threshold when every battery is inside its own limit')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.55, state: states.PendingCharge }, false, states, undefined, undefined, oneCharging), 'power does not flag threshold while one battery is still below its limit')
assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.9, state: states.PendingCharge }, false, states, undefined, undefined, [{ fraction: 0.8, start: 75, end: 80 }, { fraction: 1, start: 0, end: 100 }]), 'power detects threshold when the other battery is already full')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.6, state: states.PendingCharge }, false, states, undefined, undefined, [{ fraction: 0.8, start: 75, end: 80 }, { fraction: 0.4, start: 0, end: 100 }]), 'power does not flag threshold while a battery without a limit can still charge')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.PendingCharge }, false, states, undefined, undefined, []), 'power does not flag threshold when no battery limits were read')
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.33, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, undefined, undefined, noLimit),
  power.batteryIcon({ isPresent: true, percentage: 0.33, state: states.Charging, changeRate: 40, timeToFull: 3600 }, false, states, undefined, undefined, noLimit),
  'power shows the charging icon while the rate is still unmeasured after plug-in'
)
assertEqual(power.modeLabel({ isPresent: true, percentage: 0.8, state: states.PendingCharge }, false, states, null, undefined, undefined, limit), 'Threshold', 'power labels a held charge')
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
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging, changeRate: 1.0, timeToFull: 120 }, false, states, true, undefined, limit),
  'power shows charging icon when external power is present before battery state refreshes'
)
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging }, true, states),
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Discharging }, true, states),
  'power shows battery icon when unplugged before battery state refreshes'
)

assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, true, 'off', limit), 'power does not flag stalled charging as threshold when limit is off')
assert(!power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, true, 'once', limit), 'power does not flag stalled charging as threshold during a one-time top-up')
assert(power.chargeThresholdActive({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, true, 'on', limit), 'power flags stalled charging as threshold when limit is on')
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, true, 'off', limit),
  power.batteryIcon({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 1.0, timeToFull: 120 }, false, states, true, 'off', limit),
  'power keeps charging icon when limit is off and charge rate is low'
)
assertEqual(
  power.modeLabel({ isPresent: true, percentage: 0.8, state: states.Charging, changeRate: 0, timeToFull: 0 }, false, states, undefined, true, 'once', limit),
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
