#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const panelSource = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')

assert(/function launchAgent\(\)/.test(panelSource), 'agents panel launches the default agent')
assert(/root\.bar\.run\("omarchy-agent --pick"\)/.test(panelSource), 'agents panel uses the desktop agent launcher')
assert(/if \(buttonCode === Qt\.RightButton\) root\.launchAgent\(\)/.test(panelSource), 'agents right click launches the agent')
assert(/else if \(buttonCode === Qt\.MiddleButton\) root\.selectProvider\(root\.providerIndex \+ 1\)/.test(panelSource), 'agents middle click still advances the subscription')
assert(/else root\.toggle\(\)/.test(panelSource), 'agents left click still toggles the panel')
assert(!/if \(buttonCode === Qt\.RightButton\) root\.refreshNow\(\)/.test(panelSource), 'agents right click no longer refreshes')
JS

# A percentage that covers the whole subscription and a token count that
# covers one machine look identical once they are stacked in the same panel,
# so every section header carries the population its numbers describe.
run_node_test <<'JS'
const fs = require('fs')
const panelSource = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const start = panelSource.indexOf('function scopeSuffix')
const end = panelSource.indexOf('function heroMeta')
assert(start > 0 && end > start, 'agents panel exposes its scope-label helper')
eval(panelSource.slice(start, end))

assertEqual(scopeSuffix('account', 0), ' \u00b7 ACCOUNT', 'agents panel marks account-wide numbers')
assertEqual(scopeSuffix('device', 0), ' \u00b7 THIS MACHINE', 'agents panel marks machine-local numbers')
assertEqual(scopeSuffix('', 0), ' \u00b7 THIS MACHINE', 'agents panel treats an unstated scope as machine-local')
assertEqual(scopeSuffix('synced', 3), ' \u00b7 3 MACHINES', 'agents panel counts the machines behind a merged total')
assertEqual(scopeSuffix('synced', 1), ' \u00b7 SYNCED', 'agents panel does not boast of one machine')

const headers = [
  ['BALANCE', 'root.scopeSuffix("account", 0)'],
  ['LIMITS', 'root.scopeSuffix("account", 0)'],
  ['TOKENS BY DAY', 'root.scopeSuffix(root.daysScope, root.scopeDeviceCount)'],
  ['TOKENS BY MODEL', 'root.scopeSuffix(root.modelUsageScope, root.scopeDeviceCount)']
]
for (const [title, suffix] of headers) {
  assert(
    panelSource.includes(`text: "${title}" + ${suffix}`),
    `agents panel labels the ${title.toLowerCase()} section with its source`
  )
}

// Limits and balances describe the subscription itself. They are never
// merged across machines, so they must not follow a synced day total into
// claiming several machines.
assert(
  !/text: "(LIMITS|BALANCE)" \+ root\.scopeSuffix\((?!"account")/.test(panelSource),
  'agents panel keeps limits and balances account-labelled'
)
JS

# The record's own scope drives those labels, and a collector may scope its
# model split apart from its day totals.
run_node_test <<'JS'
const fs = require('fs')
const mainSource = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
const start = mainSource.indexOf('function displayProvider')
const end = mainSource.indexOf('function setting')
assert(start > 0 && end > start, 'agents plugin exposes its record mapper')

let syncedStats = null
const aggregateData = { deviceCount: 4, updatedAt: '2026-01-01T00:00:00Z' }
function syncedStatsFor() { return syncedStats }
function numberValue(value) { return Number(value || 0) }
function balanceValue() { return null }
eval(mainSource.slice(start, end))

const local = displayProvider({ id: 'claude', name: 'Claude Code' })
assertEqual(local.daysScope, 'device', 'a record without a scope describes this machine')
assertEqual(local.modelUsageScope, 'device', 'its model split describes this machine too')

const account = displayProvider({ id: 'fireworks', name: 'Fireworks', scope: 'account' })
assertEqual(account.daysScope, 'account', 'an account-scoped record describes the whole account')
assertEqual(account.modelUsageScope, 'account', 'and its model split follows that scope')

const split = displayProvider({ id: 'codex', name: 'Codex', daysScope: 'account' })
assertEqual(split.daysScope, 'account', 'day totals scoped on their own read as account-wide')
assertEqual(split.modelUsageScope, 'device', 'while the model split keeps the record\'s own scope')

const narrower = displayProvider({ id: 'other', name: 'Other', scope: 'account', modelUsageScope: 'device' })
assertEqual(narrower.daysScope, 'account', 'an account-scoped record keeps its day totals account-wide')
assertEqual(narrower.modelUsageScope, 'device', 'unless the model split says it is narrower')

syncedStats = { deviceCount: 4 }
const merged = displayProvider({ id: 'codex', name: 'Codex', daysScope: 'account' })
assertEqual(merged.daysScope, 'synced', 'merged snapshots describe every synced machine')
assertEqual(merged.modelUsageScope, 'synced', 'including the model split they merge')
JS

# Synced aggregation must keep the two populations apart per family: an
# account-wide figure is one truth replicated on every machine, a locally
# scanned one is a share to add up. A record whose day totals are account-wide
# still has a machine-local model split and prompt count, and a machine on an
# older Codex contributes local day totals that the account figure already
# covers, whichever order the snapshots are read in.
run_node_test <<'JS'
const fs = require('fs')
const mainSource = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
const start = mainSource.indexOf('function emptyTokenBucket')
const end = mainSource.indexOf('// Snapshots keep the field names')
assert(start > 0 && end > start, 'agents plugin exposes its snapshot aggregation')

const DAYS = ['2026-01-02']
function recentDateStrings() { return DAYS.slice() }
function safeDeviceId(raw) { return String(raw || 'device') }
function numberValue(value) { return Number(value || 0) }
eval(mainSource.slice(start, end))

const snapshot = (device, provider, stats) => ({ deviceId: device, providers: { [provider]: stats } })
const days = tokens => [{ date: DAYS[0], messageCount: tokens }]
const bucket = (input, output) => ({ inputTokens: input, outputTokens: output, cacheReadInputTokens: 0, cacheCreationInputTokens: 0 })

const accountDays = (input, output) => ({
  daysScope: 'account', todayTotalTokens: 1000, recentDays: days(1000),
  todayPrompts: 1, todaySessions: 1, totalPrompts: 5, totalSessions: 2,
  modelUsage: { 'gpt-test': bucket(input, output) }, todayTokensByModel: { 'gpt-test': input + output }
})
let merged = aggregateSnapshots([snapshot('a', 'codex', accountDays(60, 40)), snapshot('b', 'codex', accountDays(20, 180))]).providers.codex
assertDeepEqual(merged.modelUsage['gpt-test'], bucket(80, 220), 'locally scanned model tokens add up across machines under account day totals')
assertEqual(merged.todayTokensByModel['gpt-test'], 300, 'so does today\'s per-model tally')
assertEqual(merged.todayPrompts + '/' + merged.todaySessions, '2/2', 'and so do today\'s prompt and session counts')
assertEqual(merged.totalPrompts + '/' + merged.totalSessions, '10/4', 'and the all-time ones')
assertEqual(merged.todayTotalTokens, 1000, 'while the account day total is not doubled')
assertEqual(merged.recentDays[0].messageCount, 1000, 'nor its chart row')

const account = { daysScope: 'account', todayTotalTokens: 1000, recentDays: days(1000), modelUsage: {} }
const local = { todayTotalTokens: 200, recentDays: days(200), modelUsage: {} }
const accountFirst = aggregateSnapshots([snapshot('a', 'codex', account), snapshot('b', 'codex', local)]).providers.codex
const localFirst = aggregateSnapshots([snapshot('b', 'codex', local), snapshot('a', 'codex', account)]).providers.codex
assertEqual(accountFirst.todayTotalTokens, 1000, 'an account total covers a local share read after it')
assertEqual(localFirst.todayTotalTokens, 1000, 'and one read before it')
assertEqual(accountFirst.recentDays[0].messageCount + '/' + localFirst.recentDays[0].messageCount, '1000/1000', 'in the chart rows as well')

const lagging = { daysScope: 'account', todayTotalTokens: 0, recentDays: days(0), modelUsage: {} }
assertEqual(aggregateSnapshots([snapshot('a', 'codex', lagging), snapshot('b', 'codex', local)]).providers.codex.todayTotalTokens, 200, 'a lagging account figure still lets the local share through')

const onlyLocal = aggregateSnapshots([snapshot('a', 'codex', { todayTotalTokens: 60, recentDays: days(60), modelUsage: {} }), snapshot('b', 'codex', { todayTotalTokens: 20, recentDays: days(20), modelUsage: {} })]).providers.codex
assertEqual(onlyLocal.todayTotalTokens, 80, 'machines with only local day totals still add up')

const replica = { scope: 'account', todayTotalTokens: 55, recentDays: days(55), modelUsage: { m: bucket(50, 5) }, todayPrompts: 3 }
const replicas = aggregateSnapshots([snapshot('a', 'fireworks', replica), snapshot('b', 'fireworks', replica)]).providers.fireworks
assertDeepEqual(replicas.modelUsage.m, bucket(50, 5), 'a fully account-scoped record still deduplicates its model split')
assertEqual(replicas.todayTotalTokens + '/' + replicas.todayPrompts, '55/3', 'and its totals')
JS

# What a machine publishes for others to merge must carry both family scopes,
# resolved, beside the record-wide one older versions read.
run_node_test <<'JS'
const fs = require('fs')
const mainSource = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
const start = mainSource.indexOf('function providerSnapshot')
const end = mainSource.indexOf('function localSnapshot')
assert(start > 0 && end > start, 'agents plugin exposes its snapshot writer')
function numberValue(value) { return Number(value || 0) }
function cloneValue(value, fallback) { return value === undefined ? fallback : JSON.parse(JSON.stringify(value)) }
eval(mainSource.slice(start, end))

const codex = providerSnapshot({ id: 'codex', daysScope: 'account' })
assertEqual([codex.scope, codex.daysScope, codex.modelUsageScope].join(','), 'device,account,device', 'a snapshot carries account day totals beside a local model split')
const fireworks = providerSnapshot({ id: 'fireworks', scope: 'account' })
assertEqual([fireworks.scope, fireworks.daysScope, fireworks.modelUsageScope].join(','), 'account,account,account', 'a record-wide scope reaches every family in the snapshot')
JS
