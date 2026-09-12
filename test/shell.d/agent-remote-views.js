const assert = require('node:assert/strict')
const path = require('node:path')
const root = process.argv[2]
const remote = require(path.join(root, 'shell/plugins/agents/RemoteUsage.js'))
const pricing = require(path.join(root, 'shell/plugins/agents/ApiCost.js'))
const now = new Date(2026, 8, 12, 12).getTime()
function record(amount, model = 'gpt-6-astra') {
  return { id: 'codex', name: 'Codex', totalSessions: 1, totalPrompts: 1,
    dailyUsage: { schemaVersion: 1, unit: 'tokens', fromDate: '2026-08-14', throughDate: '2026-09-12',
      complete: true, issues: [], unallocatedTokens: 0, days: [{ date: '2026-09-12', buckets: [{
        rawModel: model, source: 'codex-native', sourceId: 'one', tariff: {}, issues: [], totalTokens: amount,
        tokens: { inputTokens: amount, outputTokens: 0, cacheReadInputTokens: 0, cacheCreationInputTokens: 0 }
      }] }] } }
}
function source(status, lastSuccess) {
  return { status, ...(lastSuccess === undefined ? {} : { lastSuccess }) }
}
function remoteRecord(amount, metadata = {}) {
  return { ...record(amount), ...metadata }
}
const local = { ...record(100), providerId: 'codex', providerName: 'Codex', limits: [{percent: .2}], costScopeCompatible: true }
const machines = Array.from({length: 10}, (_, i) => ({ id: 'm' + i, identity: 'device' + i,
  lastSuccess: now / 1000, providers: { codex: record(10) } }))
const scopes = remote.scopes([local], machines, now)
assert.equal(scopes.all[0].todayTotalTokens, 200)
assert.equal(scopes.m0[0].dailyUsage.days[0].buckets[0].totalTokens, 10)
assert.deepEqual(scopes.m0[0].limits, local.limits)
assert.deepEqual(scopes.all[0].limits, local.limits)
const cost = pricing.buildModelWindowPresentation('codex', scopes.all[0].dailyUsage, now, pricing.parseOverrides(''), true)
assert.equal(cost.summaries[0].tokens, 200)
assert.equal(cost.summaries[0].cost.total, .002)
assert.equal(remote.scopes([local], machines.slice(1), now).all[0].todayTotalTokens, 190)
assert.equal(remote.scopes([local], machines.concat(machines[0]), now).all[0].todayTotalTokens, 200)
const nextDay = remote.scopes([local], machines, new Date(2026, 8, 13, 12).getTime())
assert.equal(nextDay.all[0].todayTotalTokens, 0)
assert.equal(nextDay.all[0].modelUsage['gpt-6-astra'].inputTokens, 200)
const before = scopes.m0[0]
for (let i = 0; i < 10000; i++) assert.equal(scopes.m0[0], before)
console.log('ok - ten machine totals, one account limit, removal, duplicate connections, day rollover and prepared views')

const unavailable = remote.scopes([local], [{ id: 'new', identity: 'new-machine' }], now)
assert.equal(unavailable.new[0].remoteMissing, true)
assert.equal(unavailable.all[0].todayTotalTokens, 100)
const balanceOnly = { providerId: 'fireworks', providerName: 'Fireworks', balance: { remaining: 8 } }
assert.deepEqual(remote.scopes([local, balanceOnly], machines, now).all[1], balanceOnly)
console.log('ok - missing first import stays unavailable and account-only providers survive remote aggregation')

const threeDaysAgo = now / 1000 - 3 * 24 * 60 * 60
const partialMachines = [{
  id: 'partial', identity: 'partial-device', status: 'incomplete', lastSuccess: now / 1000,
  providers: {
    codex: remoteRecord(25, {
      remoteSources: { '.codex/sessions': source('current', threeDaysAgo) },
      remoteCollector: source('current', threeDaysAgo)
    }),
    claude: {
      id: 'claude', name: 'Claude', todayTotalTokens: null,
      dailyUsage: { schemaVersion: 1, unit: 'tokens', complete: false,
        issues: ['.claude/projects: source unavailable'], days: [] },
      remoteSources: { '.claude/projects': source('unavailable') },
      remoteCollector: source('current', now / 1000)
    }
  }
}]
const claudeLocal = { ...record(40, 'claude-sonnet-4-5'), providerId: 'claude', providerName: 'Claude', limits: [] }
const partial = remote.scopes([local, claudeLocal], partialMachines, now)
const individualClaude = partial.partial.find(provider => provider.providerId === 'claude')
const allClaude = partial.all.find(provider => provider.providerId === 'claude')
assert.equal(individualClaude.todayTotalTokens, null)
assert.equal(individualClaude.knownUsage, false)
assert.equal(individualClaude.usageIncomplete, true)
assert.equal(allClaude.todayTotalTokens, 40)
assert.equal(allClaude.knownUsage, true)
assert.equal(allClaude.usageIncomplete, true)
assert.equal(allClaude.recentDays.at(-1).messageCount, 40)
assert.match(remote.machineStatus(partialMachines, 'partial', 'claude', now), /provider source unavailable/)
assert.match(remote.machineStatus(partialMachines, 'partial', 'codex', now), /^Remote usage/)
console.log('ok - unavailable provider data stays unknown while All retains its known local subtotal')

const staleMachines = [{
  id: 'stale', identity: 'stale-device', status: 'incomplete', lastSuccess: now / 1000,
  providers: {
    codex: remoteRecord(25, { remoteSources: { '.codex/sessions': source('current', threeDaysAgo) } }),
    claude: remoteRecord(30, { remoteSources: { '.claude/projects': source('stale', threeDaysAgo) } })
  }
}]
const staleViews = remote.scopes([], staleMachines, now)
const staleClaude = staleViews.all.find(provider => provider.providerId === 'claude')
assert.equal(staleClaude.todayTotalTokens, 30)
assert.equal(staleClaude.knownUsage, true)
assert.equal(staleClaude.usageIncomplete, true)
assert.match(remote.machineStatus(staleMachines, 'stale', 'claude', now), /oldest relevant update 4320 min ago/)
assert.match(remote.machineStatus(staleMachines, 'stale', 'codex', now), /^Remote usage · oldest update 0 min ago$/)
const transportFailure = [{ ...staleMachines[0], status: 'stale', lastSuccess: threeDaysAgo,
  providers: { codex: remoteRecord(25, { remoteSources: { '.codex/sessions': source('current', now / 1000) } }) } }]
assert.match(remote.machineStatus(transportFailure, 'stale', 'codex', now), /oldest relevant update 4320 min ago/)
console.log('ok - stale age follows the relevant provider and ignores old timestamps on current sources')

const cache = pricing.createPresentationCache()
const views = Object.values(scopes)
const prepared = views.map(view => pricing.cachedModelWindowPresentation(cache, view[0], now, '', 0))
for (let round = 0; round < 10; round++) views.forEach((view, index) => {
  assert.equal(pricing.cachedModelWindowPresentation(cache, view[0], now, '', 0), prepared[index])
})
console.log('ok - switching all ten computers reuses prepared cost presentations without recalculation')
