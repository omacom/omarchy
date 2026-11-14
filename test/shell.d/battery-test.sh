#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')

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

// Run the service's hook methods with controlled UPower and Process state.
const qml = fs.readFileSync(path.join(root, 'shell/plugins/services/battery/Service.qml'), 'utf8')
const hookMethods = ['initializePowerSource', 'dispatchPowerSourceHook', 'runPendingPowerSourceHook']
const hookCode = hookMethods.map(name =>
  qml.match(new RegExp('  function ' + name + '\\(\\) \\{[\\s\\S]*?\\n  \\}'))[0]
).join('\n')

function hookService(onBattery, ready = false) {
  const service = {
    UPower: { onBattery, displayDevice: { ready } },
    lastPowerSource: '',
    pendingPowerSourceHook: '',
    powerSourceHookProcess: { running: false, command: [] }
  }
  vm.runInNewContext(hookCode, service)
  service.initializePowerSource()
  return service
}

for (const onBattery of [false, true]) {
  const service = hookService(false)
  service.UPower.onBattery = onBattery
  service.dispatchPowerSourceHook()
  assert(!service.powerSourceHookProcess.running, 'initial hydration is silent on ' + (onBattery ? 'battery' : 'AC'))

  service.UPower.displayDevice.ready = true
  service.initializePowerSource()
  service.dispatchPowerSourceHook()
  assert(!service.powerSourceHookProcess.running, 'an unchanged source stays silent after readiness')

  service.UPower.onBattery = !onBattery
  service.dispatchPowerSourceHook()
  assertDeepEqual(service.powerSourceHookProcess.command, ['omarchy-hook', 'power-source-change', onBattery ? 'ac' : 'battery'],
    'the first real transition delivers the new source')
}

const service = hookService(true, true)
const hook = service.powerSourceHookProcess
service.dispatchPowerSourceHook()
assert(!hook.running, 'loading into an initialized shell is silent')
service.UPower.onBattery = false
service.dispatchPowerSourceHook()
for (const onBattery of [true, false, true]) {
  service.UPower.onBattery = onBattery
  service.dispatchPowerSourceHook()
}
service.runPendingPowerSourceHook()
assertDeepEqual(hook.command, ['omarchy-hook', 'power-source-change', 'ac'], 'a queue drain cannot overwrite a running hook')

hook.running = false
service.runPendingPowerSourceHook()
assertDeepEqual(hook.command, ['omarchy-hook', 'power-source-change', 'battery'], 'the queued hook delivers the latest source')
hook.running = false
service.runPendingPowerSourceHook()
assert(!hook.running, 'a deferred drain after the queue is consumed does not start an empty hook')
JS
