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
  { level: 8, notify: true, clear: false, notifiedLowBattery: true },
  'battery warns once under threshold'
)
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.08, state: discharging }, true, discharging, 10, true),
  { level: 8, notify: false, clear: false, notifiedLowBattery: true },
  'battery keeps low-battery notified state'
)
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.4, state: discharging }, true, discharging, 10, true),
  { level: 40, notify: false, clear: true, notifiedLowBattery: false },
  'battery clears notified state after recovery'
)
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.08, state: discharging }, false, discharging, 10, true),
  { level: 8, notify: false, clear: true, notifiedLowBattery: false },
  'battery clears the warning once the charger is plugged in'
)
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.4, state: discharging }, true, discharging, 10, false),
  { level: 40, notify: false, clear: false, notifiedLowBattery: false },
  'battery leaves notifications alone when it never warned'
)
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: false, percentage: 0.08, state: discharging }, true, discharging, 10, true),
  { level: -1, notify: false, clear: true, notifiedLowBattery: false },
  'battery clears the warning when the battery goes away'
)

// A shell restart forgets the notified flag but restores the critical toast,
// so the first check after startup clears on its own.
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.4, state: discharging }, true, discharging, 10, false, true),
  { level: 40, notify: false, clear: true, notifiedLowBattery: false },
  'battery clears a restored warning on the first check after a restart'
)
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.08, state: discharging }, true, discharging, 10, false, true),
  { level: 8, notify: true, clear: false, notifiedLowBattery: true },
  'battery still warns on the first check when it starts up low'
)
JS
