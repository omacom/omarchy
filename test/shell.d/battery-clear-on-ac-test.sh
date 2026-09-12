#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const qml = fs.readFileSync(path.join(root, 'shell/plugins/services/battery/Service.qml'), 'utf8')
const state = { lowBatteryClearPending: false }
const persisted = { notifiedLowBattery: false }
const dismissal = { running: false, command: [] }
let next = { notifiedLowBattery: false, notify: false }
let warnings = 0
const context = vm.createContext({ root: state, persisted, clearWarningProcess: dismissal, UPower: {}, UPowerDeviceState: {}, batteryThreshold: 10, BatteryModel: { shouldWarnLowBattery: () => next }, sendLowBatteryWarning: () => warnings++ })
for (const name of ['checkBattery', 'clearLowBatteryWarning']) {
  const match = qml.match(new RegExp('function ' + name + '\\(([^)]*)\\) \\{([\\s\\S]*?)\\n  \\}'))
  assert(match, name + ' exists')
  state[name] = vm.runInContext('(function(' + match[1] + ') {' + match[2] + '})', context)
  context[name] = state[name]
}
state.checkBattery()
assertEqual(dismissal.running, false, 'AC startup without a warning does not dismiss anything')
next = { notifiedLowBattery: true, notify: true, level: 5 }
state.checkBattery()
assertEqual(warnings, 1, 'low battery sends warning')
next = { notifiedLowBattery: false, notify: false }
state.checkBattery()
assertDeepEqual(dismissal.command, ['omarchy-notification-dismiss', 'Time to recharge!'], 'leaving low battery invokes dismissal from checkBattery')
assertEqual(state.lowBatteryClearPending, true, 'notification insertion race retains dismissal intent')
dismissal.command = []
state.checkBattery()
assertDeepEqual(dismissal.command, [], 'busy dismissal process is not overwritten')
dismissal.running = false
state.checkBattery()
assertEqual(dismissal.running, true, 'next poll retries dismissal after busy or silently timed-out process')
dismissal.running = false
next = { notifiedLowBattery: true, notify: true, level: 5 }
state.checkBattery()
assertEqual(state.lowBatteryClearPending, false, 'new low-battery episode cancels old dismissal intent')
assertEqual(dismissal.running, false, 'old dismissal does not remove the new warning')
JS
