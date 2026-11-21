#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const qml = fs.readFileSync(path.join(root, 'shell/services/AppLibrary.qml'), 'utf8')
const vm = require('vm')
const calls = []
const timer = () => ({ running: true, stop() { this.running = false } })
const context = {
  root: { launchSerial: 1, launchOsdOpen: false },
  launchDelay: timer(),
  launchTimeout: timer(),
  Quickshell: { execDetached(command) { calls.push(command) } }
}
vm.createContext(context)
const close = qml.match(/  function closeLaunchFeedback\(serial\) \{([\s\S]*?)\n  \}/)
context.root.closeLaunchFeedback = vm.runInContext('(function(serial) {' + close[1] + '\n})', context)
const handler = qml.match(/    function onRawEvent\(event\) \{([\s\S]*?)\n    \}/)
const onEvent = vm.runInContext('(function(event) {' + (handler ? handler[1] : '') + '\n})', context)

// A layer app can open and be cancelled without ever changing the active
// toplevel. Its map event must cancel the delayed launch OSD permanently.
onEvent({ name: 'openlayer', data: 'omasnap' })
assertEqual(context.launchDelay.running, false, 'overlay launch cancels the pending OSD')
assertEqual(context.launchTimeout.running, false, 'overlay launch finishes feedback')
assertEqual(calls.length, 0, 'no OSD command is needed before the delay expires')
onEvent({ name: 'closelayer', data: 'omasnap' })
assertEqual(context.launchDelay.running, false, 'Escape cannot leave a delayed OSD behind')

context.launchDelay.running = true
context.launchTimeout.running = true
context.root.launchOsdOpen = true
onEvent({ name: 'openlayer', data: 'another-layer-app' })
assertEqual(context.root.launchOsdOpen, false, 'a late overlay closes visible launch feedback')
assertEqual(calls.length, 1, 'a late overlay issues one close')
assertEqual(calls[0].join(' '), 'omarchy-shell osd close', 'visible feedback is dismissed through IPC')

// The launch OSD itself and other shell surfaces must not count as an app
// arriving; otherwise the OSD would dismiss itself as soon as it appears.
context.launchDelay.running = true
context.launchTimeout.running = true
context.root.launchOsdOpen = true
for (const data of ['omarchy-osd', 'omarchy-notifications', 'omarchy-menu', 'omarchy-dock-apps']) {
  onEvent({ name: 'openlayer', data })
}
onEvent({ name: 'closelayer', data: 'omasnap' })
onEvent({ name: 'configreloaded', data: '' })
assertEqual(context.launchTimeout.running, true, 'shell layers and unrelated events preserve pending launches')
assertEqual(calls.length, 1, 'shell surfaces do not dismiss launch feedback')
JS
