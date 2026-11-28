#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const battery = requireFromRoot('shell/plugins/services/battery/BatteryModel.js')
const discharging = 1
const charging = 2

assertEqual(battery.batteryPercentage({ isPresent: true, percentage: 0.126 }), 13, 'battery rounds display percentage')
assertEqual(battery.batteryPercentage({ isPresent: false, percentage: 0.5 }), -1, 'battery reports missing battery')
assert(battery.isDischarging({ isPresent: true, state: discharging }, discharging), 'battery detects discharging state, plugged in or not')
assert(!battery.isDischarging({ isPresent: true, state: charging }, discharging), 'battery ignores non-discharging state')
assert(!battery.isDischarging({ isPresent: false, state: discharging }, discharging), 'battery requires a present battery')

const thresholds = [20, 10]
const at = (percentage, state) => ({ isPresent: true, percentage, state })

assertDeepEqual(
  battery.shouldWarnLowBattery(at(0.08, discharging), discharging, thresholds, 0),
  { level: 8, notify: true, warnedAt: 10 },
  'battery warns once under threshold, plugged in or not'
)
assertDeepEqual(
  battery.shouldWarnLowBattery(at(0.08, charging), discharging, thresholds, 0),
  { level: 8, notify: false, warnedAt: 0 },
  'battery does not warn while charging'
)
assertDeepEqual(
  battery.shouldWarnLowBattery(at(0.08, discharging), discharging, thresholds, 10),
  { level: 8, notify: false, warnedAt: 10 },
  'battery keeps low-battery notified state'
)
assertDeepEqual(
  battery.shouldWarnLowBattery(at(0.4, discharging), discharging, thresholds, 10),
  { level: 40, notify: false, warnedAt: 0 },
  'battery clears notified state after recovery'
)
assertDeepEqual(
  battery.shouldWarnLowBattery(at(0.12, discharging), discharging, thresholds, 0),
  { level: 12, notify: true, warnedAt: 20 },
  'battery warns at 20% for a pack that cuts out above 10%'
)

let warnedAt = 0
let levels = []
for (let percent = 30; percent >= 2; percent--) {
  const result = battery.shouldWarnLowBattery(at(percent / 100, discharging), discharging, thresholds, warnedAt)
  warnedAt = result.warnedAt
  if (result.notify) levels.push(result.level)
}
assertDeepEqual(levels, [20, 10], 'battery warns once at each threshold through one discharge')

let warned = 0
let warnings = 0
for (const state of [discharging, charging, discharging, charging, discharging]) {
  const result = battery.shouldWarnLowBattery(at(0.08, state), discharging, thresholds, warned)
  warned = result.warnedAt
  warnings += Number(result.notify)
}
assertEqual(warnings, 1, 'battery warns only once across AC flaps while low')
assertEqual(
  battery.shouldWarnLowBattery(at(0.1, charging), discharging, thresholds, 10).warnedAt,
  10,
  'charging at the warning threshold does not re-arm the latch'
)
assertEqual(
  battery.shouldWarnLowBattery(null, discharging, thresholds, 10).warnedAt,
  10,
  'a missing reading does not re-arm the low-battery warning'
)
const recovered = battery.shouldWarnLowBattery(at(0.11, charging), discharging, thresholds, 10)
assertEqual(recovered.warnedAt, 20, 'battery re-arms the 10% warning after recovering above it')
assertDeepEqual(
  battery.shouldWarnLowBattery(at(0.1, discharging), discharging, thresholds, recovered.warnedAt),
  { level: 10, notify: true, warnedAt: 10 },
  'battery warns at 10% again after recovering above it, without repeating 20%'
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

const fullyCharged = 4
assert(
  battery.shouldRearmChargeLimit(true, { isPresent: true, percentage: 1.0, state: fullyCharged }, false, false, fullyCharged),
  'battery re-arms charge limit once a one-time top-up reaches fully charged'
)
assert(
  battery.shouldRearmChargeLimit(true, { isPresent: true, percentage: 0.996, state: charging }, false, false, fullyCharged),
  'battery re-arms charge limit once a one-time top-up rounds to 100%'
)
assert(
  !battery.shouldRearmChargeLimit(true, { isPresent: true, percentage: 0.88, state: charging }, false, false, fullyCharged),
  'battery keeps one-time top-up active while still charging below 100%'
)
assert(
  battery.shouldRearmChargeLimit(true, { isPresent: true, percentage: 0.88, state: discharging }, true, false, fullyCharged),
  'battery re-arms charge limit when unplugged after a one-time top-up'
)
assert(
  !battery.shouldRearmChargeLimit(false, { isPresent: true, percentage: 1.0, state: fullyCharged }, false, false, fullyCharged),
  'battery does not re-arm charge limit when one-time top-up is not active'
)
JS
