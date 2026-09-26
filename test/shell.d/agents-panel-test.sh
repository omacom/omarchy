#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const limitReset = requireFromRoot('shell/plugins/agents/LimitResetModel.js')
const panelSource = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const mainSource = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
const manifest = JSON.parse(fs.readFileSync(root + '/shell/plugins/agents/manifest.json', 'utf8'))

assert(/function launchAgent\(\)/.test(panelSource), 'agents panel launches the default agent')
assert(/root\.bar\.run\("omarchy-agent --pick"\)/.test(panelSource), 'agents panel uses the desktop agent launcher')
assert(/if \(buttonCode === Qt\.RightButton\) root\.launchAgent\(\)/.test(panelSource), 'agents right click launches the agent')
assert(/else if \(buttonCode === Qt\.MiddleButton\) root\.selectProvider\(root\.providerIndex \+ 1\)/.test(panelSource), 'agents middle click still advances the subscription')
assert(/else root\.toggle\(\)/.test(panelSource), 'agents left click still toggles the panel')
assert(!/if \(buttonCode === Qt\.RightButton\) root\.refreshNow\(\)/.test(panelSource), 'agents right click no longer refreshes')
assert(/function scheduleLimitResetNotifications\(\)/.test(mainSource), 'agents schedule future limit resets')
assert(/function announcePassedLimitResets\(\)/.test(mainSource), 'agents announce passed limit resets')
assert(/Quickshell\.execDetached\(\["omarchy-notification-send"/.test(mainSource), 'agents use the Omarchy notification helper')
assertEqual(manifest.barWidget.defaults.notifyOnLimitReset, true, 'agents enable reset notifications by default')
assert(manifest.barWidget.schema.some(field => field.key === 'notifyOnLimitReset' && field.type === 'boolean'), 'agents expose the reset notification toggle')

const now = Date.parse('2026-09-18T12:00:00Z')
const enabled = () => true
const disabled = () => false
const record = (resetAt, label = 'weekly') => ({ id: 'codex', name: 'Codex', limits: resetAt ? [{ label, resetsAt: resetAt }] : [] })
const first = limitReset.schedule({}, [record('2026-09-18T12:10:00Z')], now, true, enabled)
assertEqual(Object.keys(first).length, 1, 'agents queue a future reset')

const transient = limitReset.schedule(first, [record()], now, true, enabled)
assertEqual(Object.keys(transient).length, 1, 'agents retain a reset across an empty transient fetch')

const disabledProvider = limitReset.schedule(first, [record('2026-09-18T12:10:00Z')], now, true, disabled)
assertEqual(Object.keys(disabledProvider).length, 1, 'agents retain a queued reset while its provider is disabled')
const suppressed = limitReset.announce(disabledProvider, Date.parse('2026-09-18T12:11:00Z'), true, disabled)
assertEqual(suppressed.notifications.length, 0, 'agents suppress a due reset for a disabled provider')
assertEqual(Object.keys(suppressed.pending).length, 0, 'agents remove a disabled provider reset at announce time')

const replaced = limitReset.schedule(first, [record('2026-09-18T12:20:00Z')], now, true, enabled)
assertEqual(Object.keys(replaced).length, 1, 'agents replace an obsolete deadline')
assertEqual(Object.values(replaced)[0].deadline, Date.parse('2026-09-18T12:20:00Z'), 'agents keep the replacement deadline')
const renamed = limitReset.schedule(replaced, [record('2026-09-18T12:30:00Z', 'monthly')], now, true, enabled)
assertEqual(Object.keys(renamed).length, 1, 'agents remove an old label when the provider response changes')
assertEqual(Object.values(renamed)[0].label, 'monthly', 'agents retain the authoritative replacement label')
const dueRefresh = limitReset.schedule(first, [record('2026-09-18T11:59:00Z')], Date.parse('2026-09-18T12:11:00Z'), true, enabled)
assertEqual(Object.keys(dueRefresh).length, 1, 'agents retain a due reset across a refresh before the timer')
const dueAndFuture = limitReset.schedule(first, [record('2026-09-18T12:20:00Z')], Date.parse('2026-09-18T12:11:00Z'), true, enabled)
assertEqual(Object.keys(dueAndFuture).length, 2, 'agents retain the due reset alongside a newly reported future reset')

const announced = limitReset.announce(first, Date.parse('2026-09-18T12:11:00Z'), true, enabled)
assertEqual(announced.notifications.length, 1, 'agents announce a passed reset')
assertEqual(Object.keys(announced.pending).length, 0, 'agents remove an announced reset')

const toggledOff = limitReset.announce(first, Date.parse('2026-09-18T12:11:00Z'), false)
assertEqual(toggledOff.notifications.length, 0, 'disabling reset notifications suppresses stale announcements')
assertEqual(Object.keys(toggledOff.pending).length, 0, 'disabling reset notifications clears stale pending state')
JS
