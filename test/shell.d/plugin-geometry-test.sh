#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const scope = vm.createContext({})
const manager = fs.readFileSync(path.join(root, 'shell/services/SandboxedPlugins.qml'), 'utf8')
const observerActive = manager.match(/active: (Object\.values\(root\.instances\)\.some\([^\n]+)\n/)[1]
function observes(instances) { return vm.runInNewContext(observerActive, {root: {instances}}) }
assert(!observes({}), 'no worker means no desktop polling')
assert(!observes({one: {error: '', nativeSession: {ready: true, desktopGeometry: false}}}), 'ungranted worker does not enable polling')
assert(observes({one: {error: '', nativeSession: {ready: true, desktopGeometry: true}}}), 'admitted running observation enables polling')
assert(!observes({one: {error: 'revoked', nativeSession: {ready: false, desktopGeometry: true}}}), 'failed or revoked worker cannot keep polling alive')
vm.runInContext(fs.readFileSync(path.join(root, 'shell/services/PluginGeometry.js'), 'utf8'), scope)
const ids = new WeakMap()
let serial = 0
function identity(object) {
  if (!ids.has(object)) ids.set(object, ++serial)
  return ids.get(object)
}
const monitor = {x: -1536.5, y: 0, scale: 1.25, name: 'private-output',
  lastIpcObject: {reserved: [0, 0, 0, 32.5], specialWorkspace: {id: 0}}}
const first = {id: 4, name: 'private-workspace', monitor}
const second = {id: 5, name: 'another-workspace', monitor}
monitor.activeWorkspace = first
const screen = {width: 1536, height: 864}
const window = {address: 'secret-handle', title: 'secret-title', workspace: first,
  lastIpcObject: {at: [-1400.5, 200.25], size: [600, 400], mapped: true, hidden: false, fullscreen: 0, pid: 1234}}
const outputs = [{screen, monitor}]
const snapshot = (windows = [window]) => scope.snapshot(outputs, [first, second], windows, identity)
const initial = JSON.parse(JSON.stringify(snapshot()))
assertEqual(initial.outputs[0].rect.x, -1536.5, 'geometry keeps negative logical origins')
assertEqual(initial.outputs[0].scale, 1.25, 'geometry keeps fractional output scale')
assertEqual(initial.windows[0].rect.y, 200.25, 'geometry keeps fractional window positions')
assertEqual(initial.outputs[0].reserved[3], 32.5, 'geometry keeps logical reserved edges')
assertDeepEqual(initial.outputs[0].activeWorkspaces, [initial.workspaces[0].id], 'active workspaces use opaque IDs')
for (const secret of ['secret-handle', 'secret-title', 'private-output', 'private-workspace', 'pid', 'address', 'title'])
  assert(!JSON.stringify(initial).includes(secret), 'geometry excludes ' + secret)
initial.windows[0].rect.x = 0
assertEqual(window.lastIpcObject.at[0], -1400.5, 'snapshots are detached from host objects')
window.lastIpcObject.at[0] += 120
window.workspace = second
monitor.activeWorkspace = second
const moved = snapshot()
assertEqual(moved.windows[0].id, initial.windows[0].id, 'moving windows preserve opaque identity')
assertEqual(moved.windows[0].workspace, initial.workspaces[1].id, 'workspace moves preserve association')
assertEqual(snapshot([]).windows.length, 0, 'closed windows leave the snapshot')
const replacement = {...window}
assert(snapshot([replacement]).windows[0].id !== moved.windows[0].id, 'a new window cannot reuse an old compositor address as identity')
window.lastIpcObject.at[0] = Infinity
assertEqual(snapshot(), null, 'invalid observations become unavailable, not zero coordinates')
window.lastIpcObject.at[0] = 10
window.workspace = {id: 99}
assertEqual(snapshot(), null, 'incomplete workspace references become unavailable')
window.workspace = first
assertEqual(snapshot(Array(257).fill(window)), null, 'excess windows are rejected rather than truncated')
monitor.lastIpcObject.specialWorkspace.id = first.id
const special = snapshot()
assertEqual(special.outputs[0].activeWorkspaces.length, 2, 'normal and special workspaces may both be active')
const large = Array.from({length: 256}, () => ({...window, lastIpcObject: {...window.lastIpcObject,
  at: [123456.12345678912, -123456.12345678912], size: [65432.12345678912, 65432.12345678912]}}))
const manySpaces = [first, second, ...Array.from({length: 254}, (_, id) => ({id: id + 10, monitor}))]
assertEqual(scope.snapshot(outputs, manySpaces, large, identity), null, 'the byte ceiling also binds within the count ceiling')
pass('desktop geometry projection keeps identity, scope and coordinate semantics')
JS
