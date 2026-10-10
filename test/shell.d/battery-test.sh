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
  { level: 8, notify: true, dismiss: false, notifiedLowBattery: true },
  'battery warns once under threshold'
)
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.08, state: discharging }, true, discharging, 10, true),
  { level: 8, notify: false, dismiss: false, notifiedLowBattery: true },
  'battery keeps low-battery notified state'
)
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.4, state: discharging }, true, discharging, 10, true),
  { level: 40, notify: false, dismiss: true, notifiedLowBattery: false },
  'battery clears notified state after recovery'
)
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.08, state: discharging }, false, discharging, 10, true),
  { level: 8, notify: false, dismiss: true, notifiedLowBattery: false },
  'battery dismisses the warning when the charger is plugged in'
)
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.4, state: discharging }, false, discharging, 10, false),
  { level: 40, notify: false, dismiss: false, notifiedLowBattery: false },
  'battery has nothing to dismiss when no warning was sent'
)
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: false }, false, discharging, 10, true),
  { level: -1, notify: false, dismiss: true, notifiedLowBattery: false },
  'battery dismisses a sent warning when the battery disappears'
)
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.4, state: discharging }, false, discharging, 10, false, true),
  { level: 40, notify: false, dismiss: true, notifiedLowBattery: false },
  'battery dismisses a restored warning in the checks after a shell restart'
)
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: true, percentage: 0.08, state: discharging }, true, discharging, 10, false, true),
  { level: 8, notify: true, dismiss: false, notifiedLowBattery: true },
  'battery still warns after a shell restart when low'
)
assertDeepEqual(
  battery.shouldWarnLowBattery({ isPresent: false }, false, discharging, 10, false, true),
  { level: -1, notify: false, dismiss: false, notifiedLowBattery: false },
  'battery waits for a known level before dismissing after a shell restart'
)
assertEqual(battery.remainingRestartChecks(3, 40), 2, 'battery counts a restart check with a known level')
assertEqual(battery.remainingRestartChecks(3, -1), 3, 'battery keeps restart checks while the battery is unknown')
assertEqual(battery.remainingRestartChecks(0, 40), 0, 'battery restart checks stop at zero')
JS

summary_in_script=$(sed -n 's/.*-u critical "\([^"]*\)".*/\1/p' "$ROOT/bin/omarchy-battery-low")
summary_in_service=$(sed -n 's/.*lowBatterySummary: "\([^"]*\)".*/\1/p' "$ROOT/shell/plugins/services/battery/Service.qml")
[[ -n $summary_in_script && $summary_in_script == "$summary_in_service" ]] || fail 'battery service dismisses the summary omarchy-battery-low sends'
pass 'battery service dismisses the summary omarchy-battery-low sends'
