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
assert(battery.drainingOnPower({ isPresent: true, state: discharging }, false, discharging), 'battery notices draining while UPower reports external power')
assert(!battery.drainingOnPower({ isPresent: true, state: discharging }, true, discharging), 'battery leaves draining on battery to UPower')
assert(!battery.drainingOnPower({ isPresent: true, state: 2 }, false, discharging), 'battery charging on external power is not draining')

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

// An online supply must not suppress the warning once discharge has settled.
const lowOnPower = { isPresent: true, percentage: 0.08, state: discharging }
assert(!battery.shouldWarnLowBattery(lowOnPower, false, discharging, 10, false, false).notify, 'battery waits out stale discharge after plugging in')
assertDeepEqual(
  battery.shouldWarnLowBattery(lowOnPower, false, discharging, 10, false, true),
  { level: 8, notify: true, notifiedLowBattery: true },
  'battery warns when sustained discharge on external power reaches the threshold'
)
assert(!battery.shouldWarnLowBattery(lowOnPower, false, discharging, 10, true, true).notify, 'battery does not repeat the warning on external power')
assertDeepEqual(
  battery.shouldWarnLowBattery({ ...lowOnPower, state: 2 }, false, discharging, 10, true, true),
  { level: 8, notify: false, notifiedLowBattery: false },
  'battery clears the warning when charging resumes even before the hold resets'
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
JS
