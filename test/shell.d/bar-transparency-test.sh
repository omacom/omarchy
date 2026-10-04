#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(root + '/shell/plugins/bar/Bar.qml', 'utf8')
// Execute the actual QML functions with compositor/process stand-ins. A color
// must remain usable on an empty output even when focus moves to a busy one.
const functions = source.slice(source.indexOf('  function setRequestedTransparency('), source.indexOf('  onTransparentOnlyWhenWorkspaceEmptyChanged:'))
const collector = source.slice(source.indexOf('    id: transparentForegroundProc'), source.indexOf('    target: Hyprland'))
const onRead = collector.match(/onRead: function\(line\) \{([\s\S]*?)\n      \}/)[1]
const onSharedRunningChanged = collector.match(/onRunningChanged: \{([\s\S]*?)\n    \}/)[1]
const surface = source.slice(source.indexOf('  component BarPanel:'))
const onTransparentChanged = surface.match(/onTransparentChanged: \{([\s\S]*?)\n    \}/)[1]
const surfaceSampler = surface.slice(surface.indexOf('    function scheduleTransparentForegroundRefresh()'), surface.indexOf('    function showTooltip('))
const surfaceTimer = surface.match(/id: transparentForegroundTimer[\s\S]*?onTriggered: \{([\s\S]*?)\n      \}/)[1]
const surfaceProcess = surface.slice(surface.indexOf('    Process {\n      id: transparentForegroundProc'))
const onSurfaceRunningChanged = surfaceProcess.match(/onRunningChanged: \{([\s\S]*?)\n      \}/)[1]
const onSurfaceRead = surfaceProcess.match(/onRead: function\(line\) \{([\s\S]*?)\n        \}/)[1]

function monitor(name, occupied) {
  return { name, activeWorkspace: { toplevels: { values: occupied ? [{}] : [] } } }
}

function scene(conditional = true) {
  const empty = monitor('DP-1', false)
  const busy = monitor('DP-2', true)
  let refreshes = 0
  const state = {
    requestedTransparent: true,
    transparentOnlyWhenWorkspaceEmpty: conditional,
    transparencyRevision: 0,
    visibleSpecialWorkspaceNames: {},
    useTransparentForeground: false,
    foregroundRefreshPending: false,
    transparent: false,
    themeForeground: '#ffffff',
    themeContrastForeground: '#101315',
    transparentForeground: '#ffffff',
    position: 'top',
    barSize: 26,
    colorHex: value => value,
    Qt: { callLater: callback => callback() },
    Hyprland: { focusedMonitor: busy, monitors: { values: [empty, busy] }, workspaces: { values: [] } },
    transparentForegroundTimer: { restart() { refreshes++ }, stop() {} },
    transparentForegroundProc: { running: false, command: [] }
  }
  state.root = state
  vm.createContext(state)
  vm.runInContext(functions + '\nfunction receiveForeground(line) {' + onRead + '\n}' +
    '\nfunction helperRunningChanged() {' + onSharedRunningChanged + '\n}', state)
  return { state, empty, busy, refreshes: () => refreshes }
}

const mixed = scene()
mixed.state.syncTransparency()
assertEqual(mixed.refreshes(), 1, 'an empty secondary monitor requests contrast while the occupied monitor is focused')
assertEqual(mixed.state.transparent, false, 'the focused occupied monitor remains opaque')
mixed.state.refreshTransparentForeground()
assertEqual(mixed.state.transparentForegroundProc.running, true, 'the shared helper runs for an unfocused empty monitor')
mixed.state.receiveForeground('not a color')
assertEqual(mixed.state.useTransparentForeground, false, 'invalid helper output cannot enable contrast')
mixed.state.receiveForeground('#101315')
assertEqual(mixed.state.useTransparentForeground, true, 'the helper result is accepted for an unfocused empty monitor')
assertEqual(mixed.state.transparent, false, 'accepting shared contrast does not make the occupied monitor transparent')

mixed.state.Hyprland.focusedMonitor = mixed.empty
mixed.state.syncTransparency()
assertEqual(mixed.state.transparent, true, 'focusing the empty monitor uses conditional transparency immediately')
mixed.state.Hyprland.focusedMonitor = mixed.busy
mixed.state.syncTransparency()
assertEqual(mixed.state.useTransparentForeground, true, 'focusing an occupied monitor preserves shared contrast')
assertEqual(mixed.state.transparentForeground, '#101315', 'focus changes retain the sampled wallpaper color')
assertEqual(mixed.refreshes(), 1, 'focus changes reuse the available shared color')
assertEqual(mixed.state.shouldBeTransparent(mixed.empty), true, 'the empty monitor stays transparent after focus moves away')
mixed.state.transparentForegroundProc.running = false
mixed.state.scheduleTransparentForegroundRefresh()
mixed.state.refreshTransparentForeground()
assertEqual(mixed.refreshes(), 2, 'wallpaper changes can refresh contrast with an occupied monitor focused')
assertEqual(mixed.state.transparentForegroundProc.running, true, 'wallpaper refresh starts the shared helper for the empty monitor')

mixed.empty.activeWorkspace.toplevels.values.push({})
mixed.state.syncTransparency()
assertEqual(mixed.state.useTransparentForeground, false, 'shared contrast is released once every monitor is occupied')
mixed.state.receiveForeground('#101315')
assertEqual(mixed.state.useTransparentForeground, false, 'a late helper result cannot enable contrast when all monitors are occupied')
assertEqual(mixed.state.transparent, false, 'a late helper result cannot make an occupied monitor transparent')

const pending = scene()
// A previous valid sample is already in use, so routine workspace syncs reuse
// it. A theme change still has to supersede an in-flight refresh.
pending.state.useTransparentForeground = true
pending.state.transparent = true
pending.state.refreshTransparentForeground()
pending.state.themeForeground = '#fefefe'
pending.state.scheduleTransparentForegroundRefresh()
assertEqual(pending.state.foregroundRefreshPending, true, 'shared sampler remembers a changed theme while its helper runs')
pending.state.foregroundRefreshPending = false
pending.state.refreshTransparentForeground() // Debounce expires while the old helper is busy.
assertEqual(pending.state.foregroundRefreshPending, true, 'shared sampler also remembers a debounce that expires while busy')
pending.state.receiveForeground('#101315')
pending.state.transparentForegroundProc.running = false
pending.state.running = false
pending.state.helperRunningChanged()
assertEqual(pending.refreshes(), 1, 'shared sampler schedules exactly one retry after the old helper exits')
pending.state.refreshTransparentForeground()
assertEqual(pending.state.transparentForegroundProc.command[3], '#fefefe', 'shared retry uses the latest theme color')
assertEqual(pending.state.foregroundRefreshPending, false, 'shared retry consumes the pending request')

pending.state.themeForeground = '#ededed'
pending.state.scheduleTransparentForegroundRefresh()
pending.state.refreshTransparentForeground()
pending.state.setRequestedTransparency(false)
assertEqual(pending.state.foregroundRefreshPending, false, 'disabling transparency immediately cancels the pending shared refresh')
pending.state.transparentForegroundProc.running = false
pending.state.helperRunningChanged()
assertEqual(pending.refreshes(), 1, 'disabled transparency does not start another helper')

// Repeat the same busy-helper transition through the actual per-surface QML
// functions and handlers; a source-text assertion would not catch a lost retry.
let surfaceRefreshes = 0
const perSurface = {
  root: { transparentForegroundPerMonitor: true, position: 'top', barSize: 26,
    themeForeground: '#ffffff', themeContrastForeground: '#101315', colorHex: value => value },
  transparentForegroundProc: { running: true, command: [] },
  transparentForegroundTimer: { restart() { surfaceRefreshes++ }, stop() {} },
  transparentForeground: '#ffffff',
  useTransparentForeground: true,
  foregroundRefreshPending: false
}
perSurface.barWindow = perSurface
perSurface.transparent = true
perSurface.screen = { width: 1920, height: 1200 }
perSurface.hyprlandMonitor = monitor('DP-1', false)
vm.createContext(perSurface)
vm.runInContext(surfaceSampler + '\nfunction timerTriggered() {' + surfaceTimer + '\n}' +
  '\nfunction helperRunningChanged() {' + onSurfaceRunningChanged + '\n}' +
  '\nfunction receiveForeground(line) {' + onSurfaceRead + '\n}', perSurface)
perSurface.root.themeForeground = '#fefefe'
perSurface.scheduleTransparentForegroundRefresh()
assertEqual(perSurface.foregroundRefreshPending, true, 'per-monitor sampler remembers a theme change while busy')
perSurface.foregroundRefreshPending = false
perSurface.timerTriggered()
assertEqual(perSurface.foregroundRefreshPending, true, 'per-monitor sampler also remembers a debounce that expires while busy')
perSurface.receiveForeground('#101315')
perSurface.transparentForegroundProc.running = false
perSurface.running = false
perSurface.helperRunningChanged()
assertEqual(surfaceRefreshes, 1, 'per-monitor sampler schedules a retry after the helper exits')
perSurface.timerTriggered()
assertEqual(perSurface.transparentForegroundProc.command[3], '#fefefe', 'per-monitor retry uses the latest theme color')
assertEqual(perSurface.transparentForegroundProc.command[6], '1920x1200', 'per-monitor retry keeps logical screen dimensions')

perSurface.root.transparentForegroundPerMonitor = false
perSurface.scheduleTransparentForegroundRefresh()
perSurface.transparentForegroundProc.running = false
perSurface.helperRunningChanged()
assertEqual(perSurface.foregroundRefreshPending, false, 'disabling per-monitor sampling clears pending refreshes')
assertEqual(surfaceRefreshes, 1, 'disabling per-monitor sampling prevents another retry')

const startup = scene()
startup.state.Hyprland.monitors.values = []
startup.state.syncTransparency()
assertEqual(startup.refreshes(), 0, 'startup waits for Hyprland monitor state')
startup.state.Hyprland.monitors.values = [startup.empty, startup.busy]
let localRefreshes = 0
vm.runInNewContext(onTransparentChanged, {
  root: startup.state,
  Qt: startup.state.Qt,
  scheduleTransparentForegroundRefresh() { localRefreshes++ }
})
assertEqual(startup.refreshes(), 1, 'an initially transparent surface wakes shared sampling without a raw event')
assertEqual(localRefreshes, 1, 'surface transparency changes still refresh the per-monitor sampler')

const special = scene()
special.state.visibleSpecialWorkspaceNames = { 'DP-1': 'special:scratchpad' }
special.state.Hyprland.workspaces.values = [{ name: 'special:scratchpad', toplevels: { values: [{}] } }]
special.state.syncTransparency()
assertEqual(special.refreshes(), 0, 'a visible populated scratchpad does not request shared transparency')
special.state.visibleSpecialWorkspaceNames = { 'DP-1': '' }
special.state.syncTransparency()
assertEqual(special.refreshes(), 1, 'hiding the scratchpad requests contrast for the now-empty monitor')
special.state.setRequestedTransparency(false)
assertEqual(special.state.useTransparentForeground, false, 'disabling transparency clears shared contrast')
special.state.receiveForeground('#101315')
assertEqual(special.state.transparent, false, 'a late helper result cannot re-enable disabled transparency')

const standard = scene(false)
standard.state.syncTransparency()
assertEqual(standard.state.transparent, false, 'ordinary transparency waits for the wallpaper helper')
standard.state.receiveForeground('#101315')
assertEqual(standard.state.transparent, true, 'ordinary transparency activates after a valid helper result')
JS
