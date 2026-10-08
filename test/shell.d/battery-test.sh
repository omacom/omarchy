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

assertEqual(battery.lidAwakeBatteryFloor(10, 10), 10, 'lid awake accepts a battery floor')
assertEqual(battery.lidAwakeBatteryFloor(0, 10), 0, 'lid awake lets users disable the battery floor')
assertEqual(battery.lidAwakeBatteryFloor(101, 10), 10, 'lid awake falls back for an out-of-range battery floor')
assertEqual(battery.lidAwakeBatteryFloor('not a number', 10), 10, 'lid awake falls back for an invalid battery floor')
assert(
  battery.hasReachedLidAwakeBatteryFloor({ isPresent: true, percentage: 0.1, state: discharging }, true, discharging, 10),
  'lid awake reaches its floor while discharging'
)
assert(
  !battery.hasReachedLidAwakeBatteryFloor({ isPresent: true, percentage: 0.1, state: discharging }, false, discharging, 10),
  'lid awake ignores its floor on AC power'
)
assert(
  !battery.hasReachedLidAwakeBatteryFloor({ isPresent: true, percentage: 0.05, state: discharging }, true, discharging, 0),
  'lid awake does not disarm when its floor is disabled'
)
JS

run_node_test <<'JS'
const fs = require('fs')
const service = fs.readFileSync(root + '/shell/plugins/services/battery/Service.qml', 'utf8')

assert(
  /target:\s*"battery"[\s\S]*function checkLidAwakeFloor\(\): void[\s\S]*root\.checkLidAwakeBatteryFloor\(\)/.test(service),
  'battery exposes an immediate Lid Awake floor check'
)
assert(
  /persisted\.lidAwakeFloorReached = true[\s\S]*root\.sendLidAwakeBatteryFloorWarning\(\)/.test(service),
  'every successful low-battery disarm sends an alert'
)
JS
