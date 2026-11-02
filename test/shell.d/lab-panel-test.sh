#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')

const Model = requireFromRoot('shell/plugins/panels/lab/Model.js')
const panel = fs.readFileSync(path.join(root, 'shell/plugins/panels/lab/Panel.qml'), 'utf8')
const vm = require('vm')
const commandText = 'printf "%s\\n" "hello world"; printf "%s" "literal $value"'
const commandContext = vm.createContext({guestCommandField:{text:commandText},root:{runCommand(command,args){this.command=command;this.args=args}}})
const workbenchClick = panel.match(/ActionButton[^\n]*guestCommandField.text[^\n]*onClicked: ([^\n]+) }/)[1]
vm.runInContext(workbenchClick, commandContext)
assertEqual(commandContext.root.command, 'omarchy-lab-vm', 'workbench uses the guest command-string interface')
assertDeepEqual(Array.from(commandContext.root.args), ['session',commandText], 'workbench preserves its complete shell command as one session argument')


assertDeepEqual(
  Model.parseStatus(''),
  Model.defaultStatus(),
  'Lab panel has a complete offline state'
)

const parsed = Model.parseStatus(JSON.stringify({
  installed: true,
  domainRunning: true,
  viewerActive: true,
  fullscreen: true,
  state: 'running',
  display: '3840x1080',
  windowWidth: 3840,
  windowHeight: 1127,
  zoom: 125,
  autoResize: true,
  cursor: 'local',
  audio: false,
  usbRedirection: false,
  keepInBar: true,
  aspect: '32:9'
}))
assertEqual(parsed.display, '3840x1080', 'Lab panel accepts a live guest display')
assertEqual(parsed.aspect, '32:9', 'Lab panel accepts a common aspect ratio')
assertEqual(parsed.zoom, 125, 'Lab panel accepts viewer zoom')
assertEqual(parsed.keepInBar, true, 'Lab panel accepts a persistent bar preference')
assertEqual(Model.statusText(parsed), 'Guest running · 3840x1080', 'Lab panel summarizes the live guest')

assertEqual(
  Model.healthText(JSON.stringify({
    severity: 'ok',
    domain: {ip: '192.168.122.55'},
    guest: {failedUnits: [], memory: {totalBytes: 100, availableBytes: 75}}
  })),
  'OK · 192.168.122.55 · 25% memory · 0 failed units',
  'Lab panel summarizes structured guest health'
)
assertEqual(Model.networkText('{"mode":"isolated","link":"up","ip":"192.168.123.12"}'), 'ISOLATED · up · 192.168.123.12', 'Lab panel summarizes isolation state')
const resources = Model.parseResources('{"profile":"performance","running":true,"cpus":{"maximum":8,"configured":8,"live":8},"memory":{"maximumBytes":17179869184,"configuredBytes":17179869184},"host":{"cpus":32,"memoryBytes":132070244352,"balancedCpus":4,"balancedMemoryBytes":8589934592,"performanceCpus":8,"performanceMemoryBytes":17179869184,"fullCpus":16,"fullMemoryBytes":34359738368,"safeCpus":24,"safeMemoryBytes":98784247808}}')
assertEqual(resources.available, true, 'Lab panel recognizes available resource status')
assertEqual(Model.resourceText(resources), 'Performance · 8 vCPU · 16 GiB', 'Lab panel summarizes the current resource allocation')
assertDeepEqual(Model.profileAllocation(resources, 'light'), {cpus: 2, memoryGiB: 4}, 'Lab panel explains the light allocation')
assertDeepEqual(Model.profileAllocation(resources, 'balanced'), {cpus: 4, memoryGiB: 8}, 'Lab panel explains the balanced allocation')
assertDeepEqual(Model.profileAllocation(resources, 'performance'), {cpus: 8, memoryGiB: 16}, 'Lab panel explains the performance allocation')
assertDeepEqual(Model.profileAllocation(resources, 'full'), {cpus: 16, memoryGiB: 32}, 'Lab panel explains the full allocation')
assertEqual(Model.resourceLimitsText(resources), 'Host: 32 cores / 123 GiB · custom limit: 24 cores / 92 GiB · VM ceiling: 8 cores / 16 GiB', 'Lab panel distinguishes host limits from the current VM ceiling')
assertDeepEqual(Model.profileAllocation(Model.parseResources('{"cpus":{"maximum":2,"configured":2},"memory":{"maximumBytes":4294967296,"configuredBytes":4294967296},"host":{"cpus":2,"memoryBytes":4294967296,"balancedCpus":2,"balancedMemoryBytes":4294967296,"performanceCpus":2,"performanceMemoryBytes":4294967296,"fullCpus":2,"fullMemoryBytes":4294967296,"safeCpus":2,"safeMemoryBytes":4294967296}}'), 'balanced'), {cpus: 2, memoryGiB: 4}, 'Lab panel caps named profiles to safe limits on smaller hardware')
assertEqual(Model.resourceText('broken'), 'Resources unavailable', 'Lab panel keeps malformed resource state unavailable')
assertEqual(Model.worktreeOptions('{"worktrees":[{"path":"/work/omarchy","branch":"feature/lab","dirty":true}]}')[0].value, '/work/omarchy', 'Lab panel consumes agent worktree JSON')
assertDeepEqual(
  Model.branchOptions('{"branches":[{"branch":"feature/responsive-theme-assets","commit":"4fd6479e4c2c12470ae784bee2b4ca82d9eec3d3","checkedOut":false,"dirty":false}]}')[0],
  {value: 'feature/responsive-theme-assets', label: 'feature/responsive-theme-assets', description: '4fd6479e4c · local branch'},
  'Lab panel builds searchable options from local branches'
)
assertEqual(Model.checkpointOptions('{"checkpoints":[{"name":"clean","createdAt":"today"}]}')[0].value, 'clean', 'Lab panel consumes agent checkpoint JSON')
assertEqual(Model.scenarioOptions('{"scenarios":[{"name":"smoke","description":"Check it"}]}')[0].value, 'smoke', 'Lab panel consumes agent scenario JSON')

const invalid = Model.parseStatus('{"display":"wide","aspect":"5:4","zoom":999,"cursor":"remote","keepInBar":"yes"}')
assertEqual(invalid.display, '', 'Lab panel rejects malformed display state')
assertEqual(invalid.aspect, '', 'Lab panel rejects unsupported aspect state')
assertEqual(invalid.zoom, 100, 'Lab panel bounds invalid zoom state')
assertEqual(invalid.cursor, 'auto', 'Lab panel rejects invalid cursor state')
assertEqual(invalid.keepInBar, false, 'Lab panel rejects an invalid bar preference')
assertDeepEqual(Model.parseBarStatus('{"viewerActive":false,"keepInBar":true}'), { viewerActive: false, keepInBar: true }, 'Lab bar consumes lightweight viewer state')
assertDeepEqual(Model.parseBarStatus('broken'), { viewerActive: false, keepInBar: false }, 'Lab bar fails closed on malformed state')

assertEqual(Model.viewerPresent([{title: 'omarchy-lab — console', lastIpcObject: {class: 'virt-viewer'}}], 'omarchy-lab'), true, 'native viewer window makes the Lab indicator active')
assertEqual(Model.viewerPresent([{title: 'other-vm', lastIpcObject: {class: 'virt-viewer'}}], 'omarchy-lab'), false, 'another viewer is outside this Lab indicator')
assertEqual(Model.viewerPresent([{title: 'omarchy-lab', lastIpcObject: {class: 'foot'}}], 'omarchy-lab'), false, 'a matching title in another application is not the viewer')
assertEqual(Model.viewerPresent([], 'omarchy-lab'), false, 'closing the viewer clears the indicator')
assertEqual(Model.viewerPresent([{title: 'omarchy-lab — console', lastIpcObject: {}, wayland: {appId: 'virt-viewer'}}], 'omarchy-lab'), true, 'the native Wayland app ID is used before the IPC snapshot is populated')
JS
