#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const Model = requireFromRoot('shell/plugins/panels/monitor/Model.js')

const source = fs.readFileSync(path.join(root, 'shell/plugins/panels/monitor/Panel.qml'), 'utf8')
const method = source.match(/^  function toggleDisplay\(name, enabled\) \{[\s\S]*?^  \}/m)
if (!method) fail('monitor panel provides toggleDisplay')

function toggle(name, enabled, count = 2, busy = false, displays = [
  { name, enabled },
  ...(count > 1 ? [{ name: 'HDMI-A-1', enabled: true }] : [])
]) {
  let running = busy
  let starts = 0
  const actionProc = {
    command: null,
    get running() { return running },
    set running(value) { running = value; if (value) starts++ }
  }
  const invoke = vm.runInNewContext('(' + method[0] + ')', {
    root: { enabledDisplayCount: count, displays }, actionProc, Model
  })
  invoke(name, enabled)
  return { command: actionProc.command, starts }
}

// Only the disabled field may change: supplying automatic mode, position or
// scale here overwrites the existing rule instead of restoring the display.
assertDeepEqual(
  toggle('DP-2', false).command,
  ['hyprctl', 'eval', 'hl.monitor({ output = "DP-2", disabled = false })'],
  're-enabling a display leaves its mode, position, scale and transform untouched'
)
assertDeepEqual(
  toggle('DP-2', true).command,
  ['hyprctl', 'eval', 'hl.monitor({ output = "DP-2", disabled = true })'],
  'disabling a display only changes its disabled state'
)
assertEqual(toggle('DP-2', false).starts, 1, 'enabling starts the display action')
assertEqual(toggle('DP-2', true).starts, 1, 'disabling starts the display action')

assertEqual(toggle('', false).command, null, 'an empty output name cannot enable a display')
assertEqual(toggle('', true).command, null, 'an empty output name cannot disable a display')
assertEqual(toggle('DP-2', true, 1).command, null, 'the only enabled display cannot be disabled')
assertEqual(toggle('DP-2', true, 0).starts, 0, 'an output cannot be disabled without an enabled peer')
assertEqual(toggle('DP-2', false, 1).starts, 1, 'a disabled display can be enabled beside the last active output')
assertEqual(toggle('DP-2', false, 0).starts, 1, 'a disabled display can be recovered with no enabled outputs')

const unusualName = 'DP-"quoted\\output'
assertDeepEqual(
  toggle(unusualName, false).command,
  ['hyprctl', 'eval', 'hl.monitor({ output = ' + JSON.stringify(unusualName) + ', disabled = false })'],
  'output quotes and backslashes stay escaped in the Lua expression'
)
assertEqual(toggle('DP-2', false, 2, true).starts, 0, 'an already running display action is not launched twice')

// Run the actual handler and the row's eligibility binding against the same
// topology, so a disabled mouse row cannot hide an unsafe keyboard action.
const rowBinding = source.match(/readonly property bool canToggle: (.*)/)[1]
for (const [label, name, enabled, displays, allowed] of [
  ['last physical beside headless', 'DP-1', true, [
    { name: 'DP-1', enabled: true }, { name: 'HEADLESS-1', enabled: true }
  ], false],
  ['disabled physical peer', 'DP-1', true, [
    { name: 'DP-1', enabled: true }, { name: 'HDMI-A-1', enabled: false },
    { name: 'HEADLESS-1', enabled: true }, { name: 'HEADLESS-2', enabled: true }
  ], false],
  ['fallback is not a physical peer', 'DP-1', true, [
    { name: 'DP-1', enabled: true }, { name: 'FALLBACK', enabled: true }
  ], false],
  ['another physical stays enabled', 'DP-1', true, [
    { name: 'DP-1', enabled: true }, { name: 'HDMI-A-1', enabled: true },
    { name: 'HEADLESS-1', enabled: true }
  ], true],
  ['headless can turn off beside physical', 'HEADLESS-1', true, [
    { name: 'DP-1', enabled: true }, { name: 'HEADLESS-1', enabled: true }
  ], true],
  ['headless-only session retains another output', 'HEADLESS-1', true, [
    { name: 'HEADLESS-1', enabled: true }, { name: 'HEADLESS-2', enabled: true }
  ], true],
  ['last headless cannot rely on fallback', 'HEADLESS-1', true, [
    { name: 'HEADLESS-1', enabled: true }, { name: 'FALLBACK', enabled: true }
  ], false],
  ['recover physical beside headless', 'DP-1', false, [
    { name: 'DP-1', enabled: false }, { name: 'HEADLESS-1', enabled: true }
  ], true]
]) {
  const count = displays.filter(d => d.enabled).length
  assertEqual(toggle(name, enabled, count, false, displays).starts, allowed ? 1 : 0,
    'display action: ' + label)
  assertEqual(vm.runInNewContext(rowBinding, {
    display: { name, enabled }, root: { displays, enabledDisplayCount: count }, Model
  }), allowed, 'display row: ' + label)
}
JS
