// Public presentation API: prepared views, invalidation and bounded eviction.
const assert = require('node:assert/strict')
const path = require('node:path')
const api = require(path.join(process.argv[2], 'shell/plugins/agents/ApiCost.js'))
const now = new Date(2026, 8, 12, 12).getTime()
const rates = rate => api.parseOverrides(JSON.stringify({models: {
  'cache-fixture': {input:rate, output:rate, cacheRead:rate, cacheWrite:rate}
}}))
let sourceReads = 0
function provider(amount, id = 'codex') {
  const days = [[12,amount],[6,amount*2]].map(([day,n]) => ({date:`2026-09-${String(day).padStart(2,'0')}`, buckets:[bucket(n,id)]}))
  days.push({date:'2026-08-14', buckets:[bucket(amount*3,id)]})
  const dailyUsage = {schemaVersion:1, unit:'tokens', fromDate:'2026-08-14', throughDate:'2026-09-12', complete:true, issues:[], unallocatedTokens:0}
  Object.defineProperty(dailyUsage, 'days', {get() {sourceReads++; return days}, enumerable:true})
  return {providerId:id, costScopeCompatible:true, dailyUsage, recentDays:[], limits:[]}
}
function bucket(n,id) {
  return {rawModel:'cache-fixture', source:id+'-native', sourceId:'synthetic', tariff:{}, issues:[], totalTokens:n,
    tokens:{inputTokens:n, outputTokens:0, cacheReadInputTokens:0, cacheCreationInputTokens:0}}
}
const overrides = rates(1)
for (const count of [5,10,248]) {
  const cache = api.createPresentationCache()
  const machines = Array.from({length:count},(_,i) => provider((i+1)*1000000))
  api.preparePresentationCache(cache,machines)
  const prepared = machines.map(p => ({daily:api.cachedDailyRows(cache,p,now,overrides,0), models:api.cachedModelWindowPresentation(cache,p,now,overrides,0)}))
  const reads = sourceReads
  for (let turn=0;turn<10;turn++) for (let i=0;i<count;i++) {
    const p = {...machines[i], limits:[{percent:turn/10}]}
    assert.equal(api.cachedDailyRows(cache,p,now,overrides,0),prepared[i].daily)
    assert.equal(api.cachedModelWindowPresentation(cache,p,now,overrides,0),prepared[i].models)
    assert.deepEqual(prepared[i].models.summaries.map(s=>s.tokens),[(i+1)*1000000,(i+1)*3000000,(i+1)*6000000])
    assert.deepEqual(prepared[i].models.summaries.map(s=>s.cost.total),[i+1,3*(i+1),6*(i+1)])
  }
  assert.equal(sourceReads,reads,'unchanged prepared switching must not traverse usage or reprice')
  const revised = api.cachedModelWindowPresentation(cache,machines[0],now,rates(2),1)
  assert.notEqual(revised,prepared[0].models)
  assert.deepEqual(revised.summaries.map(s=>s.cost.total),[2,6,12])
  const changed = api.cachedModelWindowPresentation(cache,provider(2000000),now,overrides,0)
  assert.deepEqual(changed.summaries.map(s=>s.tokens),[2000000,6000000,12000000])
  const tomorrow = api.cachedModelWindowPresentation(cache,machines[0],new Date(2026,8,13,12).getTime(),overrides,0)
  assert.deepEqual(tomorrow.summaries.map(s=>s.tokens),[0,1000000,3000000])
}
// Four provider identities across All/local/60 computers exceed the old global
// capacity. Prices for the three native providers, and unavailable pricing for
// the fourth, must all reuse their prepared results on the 30-second ticks.
{
  const cache = api.createPresentationCache()
  const providers = Array.from({length:62},()=>['codex','claude','kimi','fireworks'].map(id=>provider(1000000,id))).flat()
  api.preparePresentationCache(cache,providers)
  const daily = providers.map(p=>api.cachedDailyRows(cache,p,now,overrides,0))
  const models = providers.map(p=>api.cachedModelWindowPresentation(cache,p,now,overrides,0))
  for (let i=0;i<providers.length;i++) if (providers[i].providerId!=='fireworks') {
    assert.deepEqual(models[i].summaries.map(s=>s.tokens),[1000000,3000000,6000000])
    assert.deepEqual(models[i].summaries.map(s=>s.cost.total),[1,3,6])
  }
  const reads = sourceReads
  for (let turn=1;turn<=10;turn++) for (let i=0;i<providers.length;i++) {
    assert.equal(api.cachedDailyRows(cache,providers[i],now+turn*30000,overrides,0),daily[i])
    assert.equal(api.cachedModelWindowPresentation(cache,providers[i],now+turn*30000,overrides,0),models[i])
  }
  assert.equal(sourceReads,reads)
}
// Externally retained obsolete records must be dropped on a snapshot switch,
// while surviving current records remain hot even under transient-view churn.
for (const method of [api.cachedDailyRows, api.cachedModelWindowPresentation]) {
  const cache = api.createPresentationCache()
  const snapshots = Array.from({length:248},(_,i)=>provider(i+1))
  api.preparePresentationCache(cache,snapshots)
  const views = snapshots.map(p=>method(cache,p,now,overrides,0))
  api.preparePresentationCache(cache,snapshots.slice(0,5))
  for (let i=0;i<5;i++) assert.equal(method(cache,snapshots[i],now,overrides,0),views[i])
  assert.notEqual(method(cache,snapshots[247],now,overrides,0),views[247],'discarded key must be evicted immediately')
  const transient = Array.from({length:256},(_,i)=>provider(i+1000))
  const cold = method(cache,transient[0],now,overrides,0)
  for (const p of transient) method(cache,p,now,overrides,0)
  assert.notEqual(method(cache,transient[0],now,overrides,0),cold,'transient snapshots cannot accumulate')
  for (let i=0;i<5;i++) assert.equal(method(cache,snapshots[i],now,overrides,0),views[i],'transient churn cannot evict current views')
  api.preparePresentationCache(cache,[])
  assert.notEqual(method(cache,snapshots[0],now,overrides,0),views[0],'empty prepared snapshot releases prior views')
}
console.log('ok - prepared 5/10 and 62 x 4 views, today/7/30, limits-only reuse, revision, rollover, shrink and transient eviction')

// WeakRefs observe source ownership through the public API, not cache internals.
// Natural-GC Qt checks are separate; this deterministic Node memory check lets
// the source objects die between jobs, then explicitly requests collection.
async function checkRetention() {
  assert.equal(typeof global.gc,'function','run this test with node --expose-gc')
  const cache = api.createPresentationCache(), refs = []
  function replace(count) {
    const current = Array.from({length:count},(_,i)=>provider(i+1))
    for (const p of current) refs.push(new WeakRef(p.dailyUsage))
    api.preparePresentationCache(cache,current)
    for (const p of current) {
      api.cachedDailyRows(cache,p,now,overrides,0)
      api.cachedModelWindowPresentation(cache,p,now,overrides,0)
    }
  }
  function transient(n) {
    const p = provider(n)
    refs.push(new WeakRef(p.dailyUsage))
    const view = n%2 ? api.cachedDailyRows(cache,p,now,overrides,0) : api.cachedModelWindowPresentation(cache,p,now,overrides,0)
    assert.ok(view)
  }
  async function retained() {
    for (let n=0;n<3;n++) { await new Promise(setImmediate); global.gc() }
    return refs.filter(ref=>ref.deref()!==undefined).length
  }
  for (let n=0;n<10;n++) replace(248)
  assert.equal(await retained(),248,'only the current prepared source keys survive replacement')
  for (let n=1;n<=2048;n++) transient(n)
  const withSpare = await retained()
  assert.ok(withSpare>=248 && withSpare<=280,`current keys plus at most 32 transient keys, got ${withSpare}`)
  replace(5)
  assert.equal(await retained(),5,'shrinking releases all discarded keys and transient entries')
  replace(0)
  assert.equal(await retained(),0,'empty snapshot releases cache ownership')
  console.log('ok - ten 248-view replacements retain 248 keys; after transient churn:',withSpare,'(bound 280); shrink: 5; empty: 0')
}
checkRetention().catch(error=>{ console.error(error); process.exitCode=1 })
