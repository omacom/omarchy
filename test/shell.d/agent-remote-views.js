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

const importingMachines = [{
  id: 'continuing', identity: 'continuing-device', status: 'importing', lastSuccess: now / 1000 - 10 * 60,
  providers: {
    codex: remoteRecord(25, { remoteSources: { '.codex/sessions': source('current', now / 1000) } })
  }
}]
assert.equal(remote.machineStatus(importingMachines, 'continuing', 'codex', now),
  'Importing / continuing · oldest relevant update 10 min ago')
console.log('ok - retained provider data still exposes an active import with its truthful age')

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

const rolloverTime = new Date(2026, 8, 13, 12).getTime()
const lastGoodBefore = JSON.stringify(transportFailure)
const staleRollover = remote.scopes([], transportFailure, rolloverTime)
assert.equal(staleRollover.all[0].todayTotalTokens, 0, 'No recorded tokens for the new day')
assert.equal(staleRollover.all[0].dailyUsage.complete, false, 'A stale machine cannot verify a new-day zero')
assert.equal(staleRollover.all[0].usageIncomplete, true)
assert.equal(staleRollover.stale[0].dailyUsage.complete, false)
assert.equal(staleRollover.stale[0].usageIncomplete, true)
assert.equal(staleRollover.all[0].modelUsage['gpt-6-astra'].inputTokens, 25, 'Retain the dated known contribution')
const rolledRows = pricing.buildDailyRows('codex', staleRollover.all[0].dailyUsage,
  staleRollover.all[0].recentDays, rolloverTime, pricing.parseOverrides(''), true)
assert.equal(rolledRows.at(-1).value, '0/—', 'No verified current-day usage means no fabricated zero cost')
assert.equal(rolledRows.at(-1).cost.status, 'unknown')
assert.equal(JSON.stringify(transportFailure), lastGoodBefore, 'Views must not mutate the last good snapshot')
const sameDayStale = remote.scopes([local], transportFailure, now)
assert.equal(sameDayStale.all[0].todayTotalTokens, 125, 'Known local and stale remote tokens still add up')
assert.equal(sameDayStale.all[0].dailyUsage.complete, false)
const recovered = remote.scopes([], [{ ...transportFailure[0], status: 'current', lastSuccess: now / 1000 }], now)
assert.equal(recovered.all[0].dailyUsage.complete, true, 'Successful recovery removes transport coverage uncertainty')
assert.equal(recovered.all[0].usageIncomplete, false)
const absentBeforeFailure = [{ ...transportFailure[0], providers: {} }]
const absentViews = remote.scopes([local], absentBeforeFailure, now)
assert.equal(absentViews.all[0].todayTotalTokens, 100)
assert.equal(absentViews.all[0].usageIncomplete, true, 'A previously absent provider is not a verified zero after transport failure')
assert.equal(absentViews.stale[0].todayTotalTokens, null)
assert.equal(absentViews.stale[0].knownUsage, false)
console.log('ok - stale-machine day rollover keeps unknown coverage and positive last-good subtotals')

const rolloverStatuses = ['current', 'incomplete', 'importing', 'stale', 'unavailable']
const rolloverCosts = []
for (const status of rolloverStatuses) {
  const machine = { id: 'rollover', identity: 'rollover-device', status,
    lastSuccess: new Date(2026, 8, 12, 23, 30).getTime() / 1000, providers: { codex: record(25) } }
  const original = JSON.stringify(machine)
  const views = remote.scopes([], [machine], rolloverTime)
  const values = [views.all[0], views.rollover[0]].map(provider => {
    const rows = pricing.buildDailyRows('codex', provider.dailyUsage, provider.recentDays,
      rolloverTime, pricing.parseOverrides(''), true)
    return [rows.at(-1).value, rows.at(-1).cost.status]
  })
  rolloverCosts.push([status, ...values])
  assert.equal(views.all[0].modelUsage['gpt-6-astra'].inputTokens, 25)
  assert.equal(JSON.stringify(machine), original, 'Rollover must not mutate a last-good provider')
}
assert.deepEqual(rolloverCosts, rolloverStatuses.map(status => [status, ['0/—', 'unknown'], ['0/—', 'unknown']]),
  'Every machine status needs dated current-day coverage in both All and the individual view')
console.log('ok - all statuses preserve new-day pricing uncertainty in All and individual views')

const freshLocal = JSON.parse(JSON.stringify(local))
freshLocal.dailyUsage.throughDate = '2026-09-13'
freshLocal.dailyUsage.days[0].date = '2026-09-13'
for (const status of rolloverStatuses) {
  const machine = { id: 'rollover', identity: 'rollover-device', status,
    lastSuccess: new Date(2026, 8, 12, 23, 30).getTime() / 1000, providers: { codex: record(25) } }
  const mixed = remote.scopes([freshLocal], [machine], rolloverTime)
  const today = pricing.buildDailyRows('codex', mixed.all[0].dailyUsage, mixed.all[0].recentDays,
    rolloverTime, pricing.parseOverrides(''), true).at(-1)
  assert.equal(mixed.all[0].todayTotalTokens, 100)
  assert.equal(mixed.all[0].modelUsage['gpt-6-astra'].inputTokens, 125)
  assert.equal(today.cost.status, 'partial', 'Known local tokens remain a priced subtotal')
  const absent = remote.scopes([freshLocal], [{ ...machine, providers: {} }], rolloverTime)
  assert.equal(absent.all[0].todayTotalTokens, 100)
  assert.equal(absent.all[0].usageIncomplete, true, status + ': yesterday absence cannot verify today zero')
  const single = pricing.buildDailyRows('codex', absent.rollover[0].dailyUsage, absent.rollover[0].recentDays,
    rolloverTime, pricing.parseOverrides(''), true).at(-1)
  assert.equal(single.value, '0/—')
}
const verifiedDay = record(25)
verifiedDay.dailyUsage.throughDate = '2026-09-13'
verifiedDay.dailyUsage.days.push({ date: '2026-09-13', buckets: [] })
const verifiedViews = remote.scopes([], [{ id: 'verified', identity: 'verified-device', status: 'current',
  lastSuccess: rolloverTime / 1000, providers: { codex: verifiedDay } }], rolloverTime)
for (const provider of [verifiedViews.all[0], verifiedViews.verified[0]]) {
  const today = pricing.buildDailyRows('codex', provider.dailyUsage, provider.recentDays,
    rolloverTime, pricing.parseOverrides(''), true).at(-1)
  assert.equal(today.value, '0/$0.00', 'New verified coverage can establish a genuine zero')
  assert.equal(today.cost.status, 'complete')
  assert.equal(provider.usageIncomplete, false)
}
assert.equal(verifiedViews.all[0].modelUsage['gpt-6-astra'].inputTokens, 25)
const rolloverCache = pricing.createPresentationCache()
pricing.preparePresentationCache(rolloverCache, [verifiedViews.all[0], verifiedViews.verified[0]])
const firstPresentation = pricing.cachedModelWindowPresentation(rolloverCache, verifiedViews.verified[0], rolloverTime, '', 0)
assert.equal(pricing.cachedModelWindowPresentation(rolloverCache, verifiedViews.verified[0], rolloverTime, '', 0), firstPresentation)
console.log('ok - rollover retains mixed subtotals, unknown absent providers, verified recovery and cached presentations')

const cache = pricing.createPresentationCache()
const views = Object.values(scopes)
pricing.preparePresentationCache(cache, views.flat())
const prepared = views.map(view => pricing.cachedModelWindowPresentation(cache, view[0], now, '', 0))
for (let round = 0; round < 10; round++) views.forEach((view, index) => {
  assert.equal(pricing.cachedModelWindowPresentation(cache, view[0], now, '', 0), prepared[index])
})
console.log('ok - switching all ten computers reuses prepared cost presentations without recalculation')

function syntheticDaily(providerId, amount, complete = true) {
  const model = providerId === 'claude' ? 'claude-sonnet-4-5' : 'gpt-6-astra'
  const days = []
  for (let offset = 29; offset >= 0; offset--) {
    const date = new Date(2026, 8, 12 - offset)
    const key = date.getFullYear() + '-' + String(date.getMonth() + 1).padStart(2, '0')
      + '-' + String(date.getDate()).padStart(2, '0')
    days.push({ date: key, buckets: [{ rawModel: model, source: providerId + '-native', sourceId: 'fixture',
      tariff: {}, issues: [], totalTokens: amount,
      tokens: { inputTokens: amount, outputTokens: 0, cacheReadInputTokens: 0, cacheCreationInputTokens: 0 } }] })
  }
  return { schemaVersion: 1, unit: 'tokens', fromDate: days[0].date, throughDate: days.at(-1).date,
    complete, issues: complete ? [] : ['synthetic retained partial source'], unallocatedTokens: 0, days }
}

function syntheticProvider(providerId, amount, metadata = {}) {
  return { id: providerId, name: providerId === 'claude' ? 'Claude' : 'Codex',
    totalSessions: 1, totalPrompts: 1, todayTotalTokens: amount,
    dailyUsage: syntheticDaily(providerId, amount, metadata.complete !== false), ...metadata }
}

function measurePreparedSwitches(machineCount) {
  const fixtureLocal = ['codex', 'claude'].map((id, index) => ({
    ...syntheticProvider(id, index + 1), providerId: id, providerName: id === 'claude' ? 'Claude' : 'Codex',
    limits: [{ percent: .2 }], costScopeCompatible: true
  }))
  const fixtureMachines = Array.from({ length: machineCount }, (_, index) => {
    if (index === 4) return { id: 'fixture-' + index, identity: 'fixture-device-' + index }
    const parts = {
      codex: syntheticProvider('codex', index + 2, {
        remoteSources: { sessions: source('current', now / 1000) }
      }),
      claude: syntheticProvider('claude', index + 3, index === 7 ? {
        complete: false,
        remoteSources: { projects: source('unavailable', threeDaysAgo) },
        remoteCollector: source('current', now / 1000)
      } : { remoteSources: { projects: source('current', now / 1000) } })
    }
    return { id: 'fixture-' + index, identity: 'fixture-device-' + index,
      status: index === 7 ? 'incomplete' : 'current', lastSuccess: now / 1000, providers: parts }
  })

  let scopeBuilds = 0
  const scopeStarted = process.hrtime.bigint()
  scopeBuilds++
  const measuredScopes = remote.scopes(fixtureLocal, fixtureMachines, now)
  const scopeMs = Number(process.hrtime.bigint() - scopeStarted) / 1e6
  const preparedViews = []
  for (const [scopeId, providers] of Object.entries(measuredScopes))
    providers.forEach((provider, providerIndex) => preparedViews.push({ scopeId, providers, providerIndex, provider }))

  let historyReads = 0
  const instrumented = new Set()
  for (const view of preparedViews) {
    const daily = view.provider.dailyUsage
    if (!daily || instrumented.has(daily)) continue
    instrumented.add(daily)
    const currentDays = daily.days
    Object.defineProperty(daily, 'days', { configurable: true, enumerable: true,
      get() { historyReads++; return currentDays } })
  }

  const measuredCache = pricing.createPresentationCache()
  pricing.preparePresentationCache(measuredCache, preparedViews.map(view => view.provider))
  const references = new Map()
  const prepareStarted = process.hrtime.bigint()
  for (const view of preparedViews) references.set(view.provider, {
    daily: pricing.cachedDailyRows(measuredCache, view.provider, now, '', 0),
    models: pricing.cachedModelWindowPresentation(measuredCache, view.provider, now, '', 0)
  })
  const prepareMs = Number(process.hrtime.bigint() - prepareStarted) / 1e6
  const prepareHistoryReads = historyReads
  assert.ok(prepareHistoryReads > 0)

  historyReads = 0
  const switchCount = 5000
  const switchStarted = process.hrtime.bigint()
  for (let index = 0; index < switchCount; index++) {
    const view = preparedViews[index % preparedViews.length]
    const expected = references.get(view.provider)
    assert.equal(pricing.cachedDailyRows(measuredCache, view.provider, now, '', 0), expected.daily)
    assert.equal(pricing.cachedModelWindowPresentation(measuredCache, view.provider, now, '', 0), expected.models)
  }
  const switchMs = Number(process.hrtime.bigint() - switchStarted) / 1e6
  assert.equal(scopeBuilds, 1, 'selection must not rebuild/collect source scopes')
  assert.equal(historyReads, 0, 'selection must not re-evaluate prepared history')
  const switchHistoryReads = historyReads

  const target = preparedViews.find(view => view.scopeId === 'all' && view.provider.providerId === 'codex').provider
  const initial = references.get(target)
  historyReads = 0
  const nextDay = now + 24 * 60 * 60 * 1000
  const nextDayDaily = pricing.cachedDailyRows(measuredCache, target, nextDay, '', 0)
  const nextDayModels = pricing.cachedModelWindowPresentation(measuredCache, target, nextDay, '', 0)
  assert.notEqual(nextDayDaily, initial.daily, 'day rollover invalidates daily presentation')
  assert.notEqual(nextDayModels, initial.models, 'day rollover invalidates timeframe presentation')
  assert.ok(historyReads > 0, 'day rollover performs the required history evaluation')

  historyReads = 0
  const revised = pricing.cachedModelWindowPresentation(measuredCache, target, now, '', 1)
  assert.notEqual(revised, initial.models, 'pricing revision invalidates model presentation')
  assert.ok(historyReads > 0, 'pricing revision performs the required history evaluation')

  const replacementDaily = JSON.parse(JSON.stringify(target.dailyUsage))
  const replacementBucket = replacementDaily.days.at(-1).buckets[0]
  replacementBucket.totalTokens += 1000
  replacementBucket.tokens.inputTokens += 1000
  const changedDate = replacementDaily.days.at(-1).date
  const replacementRecent = target.recentDays.map(day => ({ ...day,
    messageCount: day.date === changedDate ? day.messageCount + 1000 : day.messageCount }))
  const replacement = { ...target, dailyUsage: replacementDaily, recentDays: replacementRecent }
  const changedDaily = pricing.cachedDailyRows(measuredCache, replacement, now, '', 0)
  const changedModels = pricing.cachedModelWindowPresentation(measuredCache, replacement, now, '', 0)
  assert.notEqual(changedDaily, initial.daily, 'new daily object invalidates daily presentation')
  assert.notEqual(changedModels, initial.models, 'new daily object invalidates model presentation')
  assert.equal(changedDaily.find(row => row.date === changedDate).tokens,
    initial.daily.find(row => row.date === changedDate).tokens + 1000)
  for (const key of ['today', 'seven', 'thirty']) {
    const beforeTokens = initial.models.summaries.find(summary => summary.key === key).tokens
    const afterTokens = changedModels.summaries.find(summary => summary.key === key).tokens
    assert.equal(afterTokens, beforeTokens + 1000, key + ' sum must reflect replacement data')
  }

  const result = { machineCount, scopes: Object.keys(measuredScopes).length, views: preparedViews.length,
    scopeBuilds, prepareHistoryReads, switchHistoryReads, switchCount,
    scopeMs: Number(scopeMs.toFixed(3)), prepareMs: Number(prepareMs.toFixed(3)),
    switchMs: Number(switchMs.toFixed(3)) }
  console.log('measurement - synthetic local prepared switching ' + JSON.stringify(result))
  return result
}

measurePreparedSwitches(5)
measurePreparedSwitches(10)
console.log('ok - five/ten normal, missing and partial scopes prepare once; switches reuse caches; day, revision and data changes invalidate exact presentations')
