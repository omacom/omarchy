#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const battery = requireFromRoot('shell/plugins/services/battery/BatteryModel.js')
const discharging = 1

assertEqual(battery.batteryPercentage({ isPresent: true, percentage: 0.126 }), 13, 'battery rounds display percentage')
assertEqual(battery.batteryPercentage({ isPresent: false, percentage: 0.5 }), -1, 'battery reports missing battery')
assert(battery.isDischarging({ isPresent: true, state: discharging }, true, discharging), 'battery detects discharging state')
assert(!battery.isDischarging({ isPresent: true, state: discharging }, false, discharging), 'battery requires on-battery state')

assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.08, state: discharging }, true, discharging, 10, false),
  { level: 8, notify: true, notifiedLowBattery: true },
  'battery warns once under threshold'
)
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.08, state: discharging }, true, discharging, 10, true),
  { level: 8, notify: false, notifiedLowBattery: true },
  'battery keeps low-battery notified state'
)
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.4, state: discharging }, true, discharging, 10, true),
  { level: 40, notify: false, notifiedLowBattery: false },
  'battery clears notified state after recovery'
)

const reply = profile => JSON.stringify({ type: 's', data: profile })
assertEqual(battery.parseActiveProfile(reply('power-saver')), 'power-saver', 'battery parses the busctl profile reply')
assertEqual(battery.parseActiveProfile(''), '', 'battery reads a missing daemon as no profile')

// Walk the profile through a session on battery: a startup read, then change
// signals, with the lock video gated on power-saver.
let profile = battery.profileAfterRead('', reply('balanced'), 0, 0)
assert(!battery.isPowerSaverOnBattery(true, profile), 'battery keeps the video on balanced')
profile = 'power-saver'
assert(battery.isPowerSaverOnBattery(true, profile), 'battery stops the video when power-saver arrives on battery')
assert(!battery.isPowerSaverOnBattery(false, profile), 'battery ignores power-saver on AC')
profile = 'balanced'
assert(!battery.isPowerSaverOnBattery(true, profile), 'battery resumes the video when power-saver ends')

// A read that sampled balanced before a power-saver signal must not undo it.
const signalsAtStart = 3
profile = 'power-saver'
profile = battery.profileAfterRead(profile, reply('balanced'), signalsAtStart, signalsAtStart + 1)
assertEqual(profile, 'power-saver', 'battery drops a read made stale by a change signal')
assert(battery.isPowerSaverOnBattery(true, profile), 'battery keeps the video stopped after a stale read')
assertEqual(
  battery.profileAfterRead('balanced', reply('power-saver'), signalsAtStart, signalsAtStart),
  'power-saver',
  'battery takes a read no signal overtook'
)
JS
