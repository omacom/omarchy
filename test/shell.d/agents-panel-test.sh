#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const limitReset = requireFromRoot('shell/plugins/agents/LimitResetModel.js')
const panelSource = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const mainSource = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
const notifierSource = fs.readFileSync(root + '/shell/plugins/agents/LimitResetNotifier.qml', 'utf8')
const manifest = JSON.parse(fs.readFileSync(root + '/shell/plugins/agents/manifest.json', 'utf8'))

assert(/function launchAgent\(\)/.test(panelSource), 'agents panel launches the default agent')
assert(/root\.bar\.run\("omarchy-agent --pick"\)/.test(panelSource), 'agents panel uses the desktop agent launcher')
assert(/if \(buttonCode === Qt\.RightButton\) root\.launchAgent\(\)/.test(panelSource), 'agents right click launches the agent')
assert(/else if \(buttonCode === Qt\.MiddleButton\) root\.refreshNow\(\)/.test(panelSource), 'agents middle click refreshes the limits')
assert(/else root\.toggle\(\)/.test(panelSource), 'agents left click still toggles the panel')
assert(!/if \(buttonCode === Qt\.RightButton\) root\.refreshNow\(\)/.test(panelSource), 'agents right click no longer refreshes')
assert(/function scheduleLimitResetNotifications\(\)/.test(mainSource), 'agents schedule future limit resets')
assert(/function announcePassedLimitResets\(\)/.test(notifierSource), 'agents announce passed limit resets')
assert(/Quickshell\.execDetached\(\["omarchy-notification-send"/.test(notifierSource), 'agents use the Omarchy notification helper')
assertEqual(manifest.barWidget.defaults.notifyOnLimitReset, true, 'agents enable reset notifications by default')
assert(manifest.barWidget.schema.some(field => field.key === 'notifyOnLimitReset' && field.type === 'boolean'), 'agents expose the reset notification toggle')

const now = Date.parse('2026-09-18T12:00:00Z')
const enabled = () => true
const disabled = () => false
const record = (resetAt, label = 'weekly') => ({ id: 'codex', name: 'Codex', limits: resetAt ? [{ label, resetsAt: resetAt }] : [] })
const first = limitReset.schedule({}, [record('2026-09-18T12:10:00Z')], now, true, enabled)
assertEqual(Object.keys(first).length, 1, 'agents queue a future reset')

assertDeepEqual(limitReset.schedule(first, [], now, false, enabled), {}, 'disabled scheduling clears queued deadlines')

const transient = limitReset.schedule(first, [record()], now, true, enabled)
assertEqual(Object.keys(transient).length, 1, 'agents retain a reset across an empty transient fetch')

const disabledProvider = limitReset.schedule(first, [record('2026-09-18T12:10:00Z')], now, true, disabled)
assertEqual(Object.keys(disabledProvider).length, 1, 'agents retain a queued reset while its provider is disabled')
const suppressed = limitReset.announce(disabledProvider, Date.parse('2026-09-18T12:11:00Z'), true, disabled)
assertEqual(suppressed.notifications.length, 0, 'agents suppress a due reset for a disabled provider')
assertEqual(Object.keys(suppressed.pending).length, 0, 'agents remove a disabled provider reset at announce time')

const removed = limitReset.schedule(first, [], now, true, enabled)
assertDeepEqual(removed, {}, 'agents remove deadlines for absent records')
assertEqual(limitReset.announce(removed, Date.parse('2026-09-18T12:11:00Z'), true, enabled).notifications.length, 0,
  'removed providers never announce retained deadlines')
const removedDue = limitReset.schedule(first, [], Date.parse('2026-09-18T12:11:00Z'), true, enabled)
assertDeepEqual(removedDue, {}, 'record removal also clears already-due resets')
const sibling = { id: 'codex-team', name: 'Codex Team', limits: [{ label: 'weekly', resetsAt: '2026-09-18T12:10:00Z' }] }
const sharedPrefix = limitReset.schedule(first, [record('2026-09-18T12:10:00Z'), sibling], now, true, enabled)
const siblingOnly = limitReset.schedule(sharedPrefix, [{ id: 'codex-team', limits: [] }], now, true, enabled)
assertEqual(Object.keys(siblingOnly).length, 1, 'removing a provider preserves a present ID sharing its prefix')
assertEqual(Object.values(siblingOnly)[0].providerName, 'Codex Team', 'prefix sibling retains its own deadline across empty limits')
assertDeepEqual(limitReset.schedule(first, [null, {}], now, true, enabled), {}, 'invalid records cannot preserve a removed provider')
assertDeepEqual(limitReset.schedule(first, [], now, true, disabled), {}, 'absent disabled providers are removed too')

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

const multiAccount = {
  id: 'codex', name: 'Codex',
  limits: [{ label: 'weekly', resetsAt: '2026-09-18T12:10:00Z' }],
  accounts: [
    { id: 'personal', accountId: 'subscription-personal', label: 'Personal', active: true, limits: [{ label: 'weekly', resetsAt: '2026-09-18T12:10:00Z' }] },
    { id: 'work', accountId: 'subscription-work', label: 'Work', active: false, limits: [{ label: 'weekly', resetsAt: '2026-09-18T12:20:00Z' }] }
  ]
}
const accountDeadlines = limitReset.schedule({}, [multiAccount], now, true, enabled)
assertEqual(Object.keys(accountDeadlines).length, 2, 'agents queue active and inactive account deadlines without duplicating top-level limits')
const unreadableFallback = limitReset.schedule({}, [{
  id: 'codex', name: 'Codex', accountRegistryStatus: 'unreadable',
  limits: [{ label: 'weekly', resetsAt: '2026-09-18T12:30:00Z' }]
}], now, true, enabled)
assertEqual(Object.keys(unreadableFallback).length, 1, 'unreadable registries still schedule top-level limits when no account deadline is known')
const recoveredRegistry = limitReset.schedule(unreadableFallback, [multiAccount], now, true, enabled)
assertEqual(Object.keys(recoveredRegistry).length, 2, 'a readable account inventory replaces the unidentified fallback deadline')
assertDeepEqual(limitReset.announce(recoveredRegistry, Date.parse('2026-09-18T12:21:00Z'), true, enabled).notifications.map(n => n.title).sort(),
  ['Codex (Personal) limit reset', 'Codex (Work) limit reset'], 'registry recovery announces each account once without the fallback duplicate')
const expandedAccounts = limitReset.schedule(first, [multiAccount], now, true, enabled)
assertEqual(Object.keys(expandedAccounts).length, 2, 'adding a second account replaces the legacy provider deadline without duplicating it')
assertDeepEqual(limitReset.announce(expandedAccounts, Date.parse('2026-09-18T12:21:00Z'), true, enabled).notifications.map(n => n.title).sort(),
  ['Codex (Personal) limit reset', 'Codex (Work) limit reset'], 'account expansion announces only the account-specific deadlines')
const accountDue = limitReset.announce(accountDeadlines, Date.parse('2026-09-18T12:21:00Z'), true, enabled)
assertDeepEqual(accountDue.notifications.map(notification => notification.title).sort(),
  ['Codex (Personal) limit reset', 'Codex (Work) limit reset'], 'agents identify the account whose limit reset')

const afterAccountRemoval = limitReset.schedule(accountDeadlines, [{
  id: 'codex', name: 'Codex', accounts: [multiAccount.accounts[0]], limits: multiAccount.limits
}], now, true, enabled)
assertEqual(Object.keys(afterAccountRemoval).length, 1, 'agents discard deadlines for accounts removed from an authoritative account list')
assertEqual(Object.values(afterAccountRemoval)[0].accountId, 'personal', 'agents preserve the remaining account deadline')
const transientAccount = limitReset.schedule(accountDeadlines, [{
  id: 'codex', name: 'Codex', accounts: [
    { id: 'personal', accountId: 'subscription-personal', label: 'Personal', active: true, limits: [] },
    multiAccount.accounts[1]
  ]
}], now, true, enabled)
assertEqual(Object.keys(transientAccount).length, 2, 'agents retain an account deadline across a transient empty limits response')
const unreadableRegistry = limitReset.schedule(accountDeadlines, [{
  id: 'codex', name: 'Codex', accountRegistryStatus: 'unreadable',
  limits: [{ label: 'weekly', resetsAt: '2026-09-18T12:30:00Z' }]
}], now, true, enabled)
assertEqual(Object.keys(unreadableRegistry).length, 2, 'agents retain per-account deadlines when the registry is unreadable')
assertDeepEqual(limitReset.announce(unreadableRegistry, Date.parse('2026-09-18T12:21:00Z'), true, enabled).notifications.map(n => n.title).sort(),
  ['Codex (Personal) limit reset', 'Codex (Work) limit reset'], 'fallback active-account limits do not displace registered-account resets')
const missingRegistry = limitReset.schedule(accountDeadlines, [{
  id: 'codex', name: 'Codex', accountRegistryStatus: 'missing',
  limits: [{ label: 'weekly', resetsAt: '2026-09-18T12:30:00Z' }]
}], now, true, enabled)
assertEqual(Object.keys(missingRegistry).length, 2, 'agents preserve per-account deadlines when the registry is missing')
assertEqual(Object.keys(limitReset.schedule({}, [{
  id: 'codex', name: 'Codex', accountRegistryStatus: 'missing', limits: multiAccount.limits
}], now, true, enabled)).length, 1, 'legacy installs without a registry still schedule top-level limits')
const singleAccountRegistry = limitReset.schedule(accountDeadlines, [{
  id: 'codex', name: 'Codex', accountRegistryStatus: 'available',
  limits: [{ label: 'weekly', resetsAt: '2026-09-18T12:30:00Z' }]
}], now, true, enabled)
assertEqual(Object.keys(singleAccountRegistry).length, 1, 'a readable single-account registry retires obsolete per-account deadlines')
assertEqual(Object.values(singleAccountRegistry)[0].deadline, Date.parse('2026-09-18T12:30:00Z'),
  'a readable single-account registry schedules its current top-level deadline')
const changedIdentity = limitReset.schedule(accountDeadlines, [{id: 'codex', name: 'Codex', accounts: [
  {id: 'personal', accountId: 'new-subscription', label: 'Personal', limits: []}, multiAccount.accounts[1]
]}], now, true, enabled)
assertEqual(Object.keys(changedIdentity).length, 1, 'a changed login with empty limits retires the old subscription deadline')
assertEqual(Object.values(changedIdentity)[0].accountId, 'work', 'a changed login preserves the other account deadline')
const signedOut = limitReset.schedule(accountDeadlines, [{id: 'codex', name: 'Codex', accounts: [
  {...multiAccount.accounts[0], accountId: ''}, multiAccount.accounts[1]
]}], now, true, enabled)
assertEqual(Object.keys(signedOut).length, 1, 'signing out retires the deadline even if stale limits remain in the record')
assertEqual(limitReset.announce(signedOut, Date.parse('2026-09-18T12:21:00Z'), true, enabled).notifications.length, 1,
  'a signed-out subscription never announces its stale reset')

const toggledOff = limitReset.announce(first, Date.parse('2026-09-18T12:11:00Z'), false)
assertEqual(toggledOff.notifications.length, 0, 'disabling reset notifications suppresses stale announcements')
assertEqual(Object.keys(toggledOff.pending).length, 0, 'disabling reset notifications clears stale pending state')
assert(/if \(root\.addStage === "" \|\| root\.picking\) root\.moveKey\(dx, dy\)/.test(panelSource), 'arrows move the agents panel cursor on the page and while picking an agent to add')
assert(/target\.kind === "choice"\) chooseAddProvider\(/.test(panelSource), 'Enter on an agent to add chooses it')
assert(!/text: root\.addStage === "running" \? "Cancel" : "Back"/.test(panelSource), 'the hero X is the only way back from adding')
assert(/hasCursor: root\.hasKey\("add"\)/.test(panelSource) && /hasCursor: root\.hasKey\("launch"\)/.test(panelSource), 'the hero buttons take the keyboard cursor')
assert(/hasCursor: root\.hasKey\("starter", index\)/.test(panelSource), 'the starter tiles take the keyboard cursor')
assert(/root\.pointAt\("account", Number\(t\) - 1\)/.test(panelSource), 'number keys move the cursor to an account')
assert(/target\.kind === "launch"\) launchAgent\(\)/.test(panelSource), 'Enter on the launcher starts the default agent')
assert(/row\.push\(\{ kind: "autoswitch", index: entry \}\)/.test(panelSource), 'an inactive account offers Autoswitch and Use as separate stops')
assert(/kind: "signin", index: entry/.test(panelSource) && /kind: "providerSignin", index: p/.test(panelSource), 'Sign-in required links are keyboard stops')
assert(/target\.kind === "signin"\) signInAgain\(/.test(panelSource) && /target\.kind === "providerSignin"\) signInAgain\(/.test(panelSource), 'Enter on Sign-in required signs in again')
assert(/target\.kind === "autoswitch"\) setSwitchMode\(/.test(panelSource), 'Enter on Autoswitch flips the switch mode')
assert(/keyColumn = use >= 0 \? use : /.test(panelSource), 'moving up or down onto an account lands on Use')
assert(/Qt\.callLater\(function\(\) \{ if \(picking\) pointAt\("choice", 0\) \}\)/.test(panelSource), 'picking an agent to add starts with the first one focused')
assert(/opacity: stale \? 0\.5 : 1\.0/.test(panelSource) && /"As of " \+ root\.formatDuration/.test(panelSource), 'limits kept from an earlier check dim and say how old they are on hover')
assert(/onPickingChanged: resetKeys\(\)/.test(panelSource), 'the cursor starts over when the agent list comes or goes')
assert(!/t === "a" \|\| t === "A"/.test(panelSource), 'adding an account has no hotkey; the + is the way in')
assert(/if \(!accounts\[a\]\.active\) \{/.test(panelSource) && /if \(row\.length > 0\) rows\.push\(row\)/.test(panelSource), 'the active account with nothing to fix is not a keyboard stop')
assert(/var from = Math\.min\(0\.8, \(threshold - 15\) \/ 100\)/.test(mainSource), 'faster checks start 15 points below the switch threshold')
JS
