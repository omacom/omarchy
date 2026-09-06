#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/plugins/services/nightlight/Service.qml'), 'utf8')
const context = vm.createContext({
  root: {
    temperature: 4000,
    nightTemperature: 4000,
    dayTemperature: 6500,
    manualScheduleDisablePending: false
  },
  statusProbe: { running: false },
  scheduleProbe: { running: false },
  scheduleTimer: { stop() {}, restart() {} },
  applied: []
})

// Run the service's actual functions and exit handler, controlling only process completion order.
for (const match of source.matchAll(/^  function (\w+)\(([^)]*)\) \{([\s\S]*?)^  \}/gm)) {
  vm.runInContext(`root.${match[1]} = function(${match[2]}) {${match[3]}}`, context)
}
const statusExit = source.match(/id: statusProbe[\s\S]*?(onExited: function\(exitCode\) \{[\s\S]*?^    \})/m)
assert(statusExit !== null, 'nightlight status probe has an exit handler')
vm.runInContext(`finishStatus = ${statusExit[1].replace('onExited: ', '')}`, context)
vm.runInContext('root.applyTemperature = function(temp) { applied.push(temp); root.temperature = temp }', context)

context.root.refresh()
assertEqual(context.statusProbe.running, true, 'refresh reads the actual display temperature')
assertEqual(context.scheduleProbe.running, false, 'schedule waits for the display probe instead of using cached night temperature')

// The display reverted to daylight while asleep, although the cache still said 4000K.
context.root.temperature = 6500
context.statusProbe.running = false
context.finishStatus(0)
assertEqual(context.scheduleProbe.running, true, 'completed display probe starts schedule evaluation')
context.root.applySchedule({
  scheduled: true,
  night: true,
  nextEvent: 'sunrise',
  nextEventAt: '2026-08-31T06:25:00-07:00'
})
assertDeepEqual(context.applied, [4000], 'nighttime resume corrects a display reset despite the formerly warm cache')

context.scheduleProbe.running = false
context.root.manualScheduleDisablePending = true
context.finishStatus(0)
assertEqual(context.scheduleProbe.running, false, 'pending manual mode does not restart automatic scheduling')

context.root.manualScheduleDisablePending = false
context.finishStatus(1)
assertEqual(context.root.temperature, null, 'failed display probe invalidates cached temperature')
assertEqual(context.scheduleProbe.running, true, 'failed display probe still lets sunset mode restore hyprsunset')
JS
