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
assertEqual(power.modeLabel({ isPresent: true, percentage: 1, state: states.FullyCharged }, false, states, false), 'Fully charged', 'power labels full battery')
assertEqual(power.localizeReading('13.1W'), '13.1W', 'power keeps battery readings in English digits by default')
assertEqual(power.localizeReading('75-80%', function(v, d) { return '<' + v + '>' }), '<75>-<80>%', 'power localizes every number in a battery reading')
assertEqual(power.localizeReading('13.10W', function(v, d) { return v.toFixed(d).replace('.', ',') }), '13,10W', 'power keeps a reading\'s decimals when localizing')
assertEqual(power.localizeReading(undefined), '', 'power reads a missing battery field as empty')
assertEqual(power.modeLabel({ isPresent: true, percentage: 0.5, state: states.Discharging }, true, states, false), 'On battery', 'power labels battery mode')
assertEqual(power.modeLabel({ isPresent: true, percentage: 0.5, state: states.Discharging }, false, states, false), 'Charging', 'power treats external power as newer than stale discharging state')
assertEqual(power.modeLabel({ isPresent: true, percentage: 0.8, state: states.Charging }, false, states, true), 'Threshold', 'power labels a confirmed threshold hold regardless of device state')
assert(power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging }, false, states, false).length > 0, 'power maps battery icons')
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Discharging }, false, states, false),
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging, changeRate: 1.0, timeToFull: 120 }, false, states, false),
  'power shows charging icon when external power is present before battery state refreshes'
)
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Charging }, true, states, false),
  power.batteryIcon({ isPresent: true, percentage: 0.4, state: states.Discharging }, true, states, false),
  'power shows battery icon when unplugged before battery state refreshes'
)

// FullyCharged can glitch at an arbitrary percentage right after an AC transition.
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.51, state: states.FullyCharged }, false, states, false),
  power.batteryIcon({ isPresent: true, percentage: 0.51, state: states.Charging }, false, states, false),
  'power does not show the full-battery glyph for a FullyCharged reading below 99%'
)
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 1, state: states.FullyCharged }, false, states, false),
  '󰂅',
  'power shows the full-battery glyph at genuine full charge'
)

// A confirmed threshold hold overrides device state entirely.
assertEqual(
  power.batteryIcon({ isPresent: true, percentage: 0.8, state: states.Charging }, false, states, true),
  power.batteryIcon({ isPresent: true, percentage: 0.8, state: states.Discharging }, false, states, true),
  'power shows the non-charging glyph whenever threshold-hold is confirmed, regardless of device state'
)

var confirmDelay = 30000

var start = power.nextChargeThresholdState(true, null, 0, confirmDelay)
assertDeepEqual(start, { activeSince: 0, confirmed: false }, 'threshold confirmation starts the window on the first true reading')

var almostThere = power.nextChargeThresholdState(true, start.activeSince, confirmDelay - 1, confirmDelay)
assert(!almostThere.confirmed, 'threshold confirmation is not granted a moment before the delay elapses')

var confirmedNow = power.nextChargeThresholdState(true, almostThere.activeSince, confirmDelay, confirmDelay)
assert(confirmedNow.confirmed, 'threshold confirmation is granted once the delay fully elapses')

// Literal sequence captured live on a T2 MacBook replug; none of it may confirm.
var replugTrace = [
  { raw: true, t: 0 },     // fully-charged glitch at 51% charge
  { raw: true, t: 1000 },  // charging, but rate still stuck at 0W
  { raw: false, t: 2000 }, // discharging (stale) glitch resets the window
  { raw: true, t: 2100 }   // charging, rate still 0W
]
var replugState = { activeSince: null, confirmed: false }
replugTrace.forEach(function(sample) {
  replugState = power.nextChargeThresholdState(sample.raw, replugState.activeSince, sample.t, confirmDelay)
})
assert(!replugState.confirmed, 'threshold confirmation never fires during a noisy sub-30s replug burst')

// Exit is instant and unconditional, even from an already-confirmed state.
var held = power.nextChargeThresholdState(true, null, 0, confirmDelay)
held = power.nextChargeThresholdState(true, held.activeSince, confirmDelay, confirmDelay)
assert(held.confirmed, 'sanity: threshold hold was confirmed before testing exit')
var released = power.nextChargeThresholdState(false, held.activeSince, confirmDelay + 1, confirmDelay)
assertDeepEqual(released, { activeSince: null, confirmed: false }, 'threshold confirmation clears instantly on exit')
JS
