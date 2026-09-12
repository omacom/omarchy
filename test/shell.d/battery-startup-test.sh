#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const batterySource = fs.readFileSync(path.join(root, 'shell/plugins/services/battery/Service.qml'), 'utf8')
const notificationSource = fs.readFileSync(path.join(root, 'shell/plugins/notifications/Service.qml'), 'utf8')
const BatteryModel = requireFromRoot('shell/plugins/services/battery/BatteryModel.js')
const NotificationLogic = requireFromRoot('shell/plugins/notifications/NotificationLogic.js')

function qmlFunction(source, name) {
  const match = source.match(new RegExp(`^  function ${name}\\([^)]*\\) \\{[\\s\\S]*?^  \\}`, 'm'))
  if (!match) throw new Error(`Missing QML function: ${name}`)
  return match[0]
}

const lookupBinding = batterySource.match(/^  readonly property var notificationsService: (\{[\s\S]*?^  \})/m)
const readyBinding = batterySource.match(/^  readonly property bool notificationsReady: (.*)$/m)
if (!lookupBinding || !readyBinding) throw new Error('Missing notification readiness bindings')

function notificationsReady(service) {
  return vm.runInNewContext(readyBinding[1], { notificationsService: service })
}

const replacement = { popupsRestored: false }
const lookupShell = {
  services: {},
  serviceFor() { throw new Error('A literal service lookup bypasses enabled replacements') },
  firstPartyServiceFor(id) {
    if (id !== 'omarchy.notifications') throw new Error(`Unexpected service: ${id}`)
    return replacement
  }
}
assertEqual(
  vm.runInNewContext(`(function() ${lookupBinding[1]})()`, { shell: lookupShell }),
  replacement,
  'battery looks up the enabled notification replacement'
)
assert(!notificationsReady(null), 'battery waits while the notification service is absent')
assert(!notificationsReady(replacement), 'battery waits for a replacement that supports restoration readiness')
replacement.popupsRestored = true
assert(notificationsReady(replacement), 'battery accepts a replacement after restoration completes')
assert(notificationsReady({}), 'battery retains best-effort warnings with older notification replacements')

// Run the production function bodies with a controllable event queue. This
// makes the restore's disk-read/model-insertion gap deterministic without
// starting another shell or changing the desktop's notification history.
function startup(level, charging) {
  const later = []
  const rows = []
  const commands = []
  const service = { restoredPopups: {}, popupsRestored: false }
  const context = {
    BatteryModel,
    NotificationLogic,
    NotificationUrgency: { Normal: 1 },
    UPowerDeviceState: { Discharging: 1 },
    UPower: { displayDevice: { isPresent: true, percentage: level / 100, state: charging ? 2 : 1 }, onBattery: !charging },
    batteryThreshold: 10,
    persisted: { notifiedLowBattery: false },
    staleWarningSwept: false,
    service,
    popupModel: {
      get count() { return rows.length },
      get: index => rows[index],
      append: row => rows.push(row)
    },
    Qt: { callLater: fn => later.push(fn) },
    durationFor: () => 0,
    clearLowBatteryWarning() {
      commands.push('--clear')
      rows.splice(0)
    },
    sendLowBatteryWarning(value) {
      commands.push(String(value))
      rows.splice(0, rows.length, { summary: 'Time to recharge!', body: `Battery is down to ${value}%` })
    }
  }
  context.root = context
  Object.defineProperty(context, 'notificationsReady', { get: () => notificationsReady(service) })
  const readyHandler = batterySource.match(/^  onNotificationsReadyChanged: (.*)$/m)
  if (!readyHandler) throw new Error('Missing notification readiness handler')
  let ready = false
  Object.defineProperty(service, 'popupsRestored', {
    get: () => ready,
    set(value) {
      if (value === ready) return
      ready = value
      vm.runInContext(readyHandler[1], context)
    }
  })
  vm.createContext(context)
  vm.runInContext(qmlFunction(batterySource, 'checkBattery'), context)
  vm.runInContext(qmlFunction(notificationSource, 'restorePopups'), context)
  return { context, rows, commands, later, service }
}

const oldWarning = JSON.stringify({
  originalId: 7,
  summary: 'Time to recharge!',
  body: 'Battery is down to 8%',
  urgency: 2,
  timestamp: Date.now() - 1000
})

for (const charging of [true, false]) {
  const test = startup(charging ? 80 : 7, charging)
  const label = charging ? 'charging restart' : 'low-battery restart'
  test.context.checkBattery()
  assertDeepEqual(test.commands, [], `${label} waits for the restore read`)
  assert(!test.context.staleWarningSwept, `${label} does not spend its startup sweep early`)
  assert(!test.context.persisted.notifiedLowBattery, `${label} does not consume its warning latch early`)

  test.context.restorePopups(oldWarning)
  test.context.checkBattery()
  assertDeepEqual(test.commands, [], `${label} also waits for deferred popup insertion`)
  assert(!test.service.popupsRestored, `${label} stays unready until the popup is inserted`)

  test.later.shift()()
  assertEqual(test.rows.length, 1, `${label} inserts the restored warning before becoming ready`)
  assert(test.service.popupsRestored, `${label} completes restoration`)
  test.later.shift()()
  assertDeepEqual(test.commands, [charging ? '--clear' : '7'], `${label} reconciles immediately after restoration`)
  assertEqual(test.rows.length, charging ? 0 : 1, `${label} leaves no stale or duplicate warning`)
  test.context.checkBattery()
  assertEqual(test.commands.length, 1, `${label} does not repeat its reconciliation on the next tick`)
}

const empty = startup(7, false)
empty.context.restorePopups('')
while (empty.later.length) empty.later.shift()()
assert(empty.service.popupsRestored, 'empty notification history completes restoration too')
assertDeepEqual(empty.commands, ['7'], 'empty notification history does not suppress the initial low-battery warning')
JS
