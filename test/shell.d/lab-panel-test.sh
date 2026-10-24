#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')

const Model = requireFromRoot('shell/plugins/panels/lab/Model.js')
const manifest = requireFromRoot('shell/plugins/panels/lab/manifest.json')
const panel = fs.readFileSync(path.join(root, 'shell/plugins/panels/lab/Panel.qml'), 'utf8')
const widget = fs.readFileSync(path.join(root, 'shell/plugins/panels/lab/BarWidget.qml'), 'utf8')
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

assertDeepEqual(manifest.kinds, ['panel', 'bar-widget'], 'Lab plugin exposes a panel and bar widget')
assertEqual(manifest.keepLoaded, true, 'Lab panel preserves its moved position across close and reopen')
assert(panel.includes('viewerCommand: labCommand("omarchy-lab-viewer")') && panel.includes('Quickshell.env("OMARCHY_PATH") + "/bin/" + name'), 'Lab panel resolves its controller through the native Omarchy runtime')
assert(panel.includes('resetArmed') && panel.includes('Confirm reset'), 'Lab reset requires a second confirmation')
assert(panel.includes('["Console", "Develop", "Environment", "Capture", "Automate"]'), 'Lab panel exposes the complete workbench as keyboard-navigable pages')
assert(panel.includes('readonly property real currentPageHeight'), 'Lab panel sizes itself to the active workbench page')
assert(panel.includes('Layout.maximumHeight: root.currentPageHeight'), 'Lab panel keeps short pages compact while retaining overflow scrolling')
assert(panel.includes('cardContent.implicitHeight + Style.space(40)'), 'Lab panel derives its card height from visible content')
assert(!panel.includes('Style.space(760)'), 'Lab panel does not reserve a fixed tall whitespace area')
assert(panel.includes('pageScroll.contentItem.contentY = 0'), 'Lab panel resets page scroll through the ScrollView flickable')
assert(panel.includes('tooltipText: I18n.t("lab.refreshLabStatus")') && panel.includes('tooltipText: I18n.t("lab.closeLabControls")'), 'Lab header uses compact labeled icon actions')
assert(!panel.includes('text: "Refresh"; iconText:') && !panel.includes('text: "Close"; iconText:'), 'Lab header avoids redundant icon-and-label controls')
assert(panel.includes('Item { Layout.fillWidth: true }'), 'Lab header keeps utility actions aligned to the trailing edge')
assert(panel.includes('DragHandler') && panel.includes('onTranslationChanged'), 'Lab card can be dragged by its header')
assert(panel.includes('anchors.horizontalCenterOffset: root.cardOffsetX') && panel.includes('anchors.verticalCenterOffset: root.cardOffsetY'), 'Lab card applies its movable position through center offsets')
assert(panel.includes('sequence: "Alt+Left"') && panel.includes('sequence: "Alt+Home"'), 'Lab card also supports keyboard movement and recentering')
assert(panel.includes('horizontalLimit') && panel.includes('verticalLimit'), 'Lab card movement stays constrained to the visible screen')
assert(panel.includes('if (!opened || keyCatcher.width <= 0 || keyCatcher.height <= 0) return'), 'Lab card is not recentered when its hidden surface collapses')
assert(panel.includes('text: I18n.t("lab.keepInBar")') && panel.includes('["set", "keep-in-bar"'), 'Lab panel exposes the persistent bar preference')
assert(panel.includes('SearchableDropdown') && panel.includes('[root.labCommand("omarchy-lab-checkout"), "branches", "--json"]'), 'Lab Develop page offers searchable local branches')
assert(panel.includes('["deploy", "--branch", root.selectedBranch]'), 'Lab Develop page deploys the selected local branch')
assert(panel.includes('[root.selectedBranch, "--branch"]'), 'Lab checkpoint deployment scenario uses the selected branch')
assert(['light', 'balanced', 'performance', 'full'].every(profile => panel.includes('I18n.t("lab.' + profile + 'ResourcesDescription")')), 'Lab resource presets show their CPU and memory allocations and recommendation')
assert(panel.includes('columns: 2') && panel.includes('rowSpacing: Style.space(8)'), 'Lab resource presets use a readable two-column grid')
assert(panel.includes('I18n.t("lab.recommendedForMostDevelopmentAndUITesting")'), 'Lab resource presets explain the recommended choice')
assert(panel.includes('Model.resourceLimitsText(root.resources, root.t, I18n.formatNumber)'), 'Lab resources distinguish host limits from the current VM ceiling')
assert(panel.includes('NumberField') && panel.includes('I18n.t("lab.cpuRange")') && panel.includes('I18n.t("lab.memoryRange")'), 'Lab custom resources use labeled bounded number controls')
assert(panel.includes('to: root.maximumResourceCpus') && panel.includes('to: root.maximumResourceMemoryGiB'), 'Lab custom resource controls respect the host-safe limits')
assert(panel.includes('enabled: root.resources.available && !root.busy'), 'Lab resource controls stay disabled until allocation limits are available')
assert(panel.includes('root.resources.profile === "balanced"'), 'Lab highlights the active resource profile')
assert(panel.includes('root.resources.profile === "performance"'), 'Lab highlights the active performance profile')
assert(!panel.includes('placeholderText: "vCPU"') && !panel.includes('placeholderText: "RAM GiB"'), 'Lab avoids unlabeled raw resource fields')
for (const command of ['omarchy-lab-health', 'omarchy-lab-checkout', 'omarchy-lab-checkpoint', 'omarchy-lab-network', 'omarchy-lab-resource', 'omarchy-lab-gold', 'omarchy-lab-capture', 'omarchy-lab-transfer', 'omarchy-lab-action', 'omarchy-lab-scenario']) {
  assert(panel.includes(command), `Lab panel delegates ${command} features to the scriptable CLI`)
}
assert(panel.includes('armOrRun') && panel.includes('Confirm promote') && panel.includes('Confirm rebuild'), 'Lab panel confirms destructive gold-image operations')
assert(widget.includes('Hyprland.toplevels.values') && widget.includes('id: viewerSettings') && widget.includes('watchChanges: true') && !widget.includes('id: statusProc') && !widget.includes('Timer {'), 'Lab bar uses native window changes and settings watches without idle commands')
assertEqual(Model.viewerPresent([{title: 'omarchy-lab — console', lastIpcObject: {class: 'virt-viewer'}}], 'omarchy-lab'), true, 'native viewer window makes the Lab indicator active')
assertEqual(Model.viewerPresent([{title: 'other-vm', lastIpcObject: {class: 'virt-viewer'}}], 'omarchy-lab'), false, 'another viewer is outside this Lab indicator')
assertEqual(Model.viewerPresent([{title: 'omarchy-lab', lastIpcObject: {class: 'foot'}}], 'omarchy-lab'), false, 'a matching title in another application is not the viewer')
assertEqual(Model.viewerPresent([], 'omarchy-lab'), false, 'closing the viewer clears the indicator')
assertEqual(Model.viewerPresent([{title: 'omarchy-lab — console', lastIpcObject: {}, wayland: {appId: 'virt-viewer'}}], 'omarchy-lab'), true, 'the native Wayland app ID is used before the IPC snapshot is populated')
assert(widget.includes('function refreshSettings()') && widget.includes('viewerSettings.reload()') && widget.includes('root.broadcast("refreshSettings")'), 'settings IPC reload reaches every active bar instance')
assert(widget.includes('readonly property bool shown: viewerActive || keepInBar'), 'Lab bar widget can remain visible while the viewer is closed')
assert(widget.includes('implicitWidth: shown ? button.implicitWidth : 0'), 'Lab bar widget takes no space unless active or pinned')
assert(widget.includes('if (!root.viewerActive)'), 'Pinned Lab bar actions open the controls while the viewer is closed')
JS
