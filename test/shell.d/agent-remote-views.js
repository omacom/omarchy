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

const cache = pricing.createPresentationCache()
const views = Object.values(scopes)
const prepared = views.map(view => pricing.cachedModelWindowPresentation(cache, view[0], now, '', 0))
for (let round = 0; round < 10; round++) views.forEach((view, index) => {
  assert.equal(pricing.cachedModelWindowPresentation(cache, view[0], now, '', 0), prepared[index])
})
console.log('ok - switching all ten computers reuses prepared cost presentations without recalculation')
