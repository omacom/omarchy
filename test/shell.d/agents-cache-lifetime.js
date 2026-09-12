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
  const days = [[12,amount],[6,amount*2]].map(([day,n]) => ({date:`2026-09-${String(day).padStart(2,'0')}`, buckets:[bucket(n)]}))
  days.push({date:'2026-08-14', buckets:[bucket(amount*3)]})
  const dailyUsage = {schemaVersion:1, unit:'tokens', fromDate:'2026-08-14', throughDate:'2026-09-12', complete:true, issues:[], unallocatedTokens:0}
  Object.defineProperty(dailyUsage, 'days', {get() {sourceReads++; return days}, enumerable:true})
  return {providerId:id, costScopeCompatible:true, dailyUsage, recentDays:[], limits:[]}
}
function bucket(n) {
  return {rawModel:'cache-fixture', source:'codex-native', sourceId:'synthetic', tariff:{}, issues:[], totalTokens:n,
    tokens:{inputTokens:n, outputTokens:0, cacheReadInputTokens:0, cacheCreationInputTokens:0}}
}
const overrides = rates(1)
for (const count of [5,10]) {
  const cache = api.createPresentationCache()
  const machines = Array.from({length:count},(_,i) => provider((i+1)*1000000))
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
// Keep source objects alive so eviction tests cache policy, not GC timing.
// A hot view survives churn; older cold views are recomputed when requested.
for (const method of [api.cachedDailyRows, api.cachedModelWindowPresentation]) {
  const cache = api.createPresentationCache()
  const old = provider(1000000), hot = provider(2000000)
  const oldView = method(cache,old,now,overrides,0), hotView = method(cache,hot,now,overrides,0)
  const snapshots = Array.from({length:256},(_,i)=>provider(i+1))
  for (const p of snapshots) {
    method(cache,p,now,overrides,0)
    assert.equal(method(cache,hot,now,overrides,0),hotView)
  }
  assert.notEqual(method(cache,old,now,overrides,0),oldView,'cold obsolete snapshots must leave the bounded cache even while externally alive')
  const recent = method(cache,snapshots[255],now,overrides,0)
  assert.equal(method(cache,snapshots[255],now,overrides,0),recent)
}
console.log('ok - prepared 5/10 machines, today/7/30, limits-only reuse, revisions, rollover and bounded hot/cold eviction')

// Observe retention through standard WeakRefs, without reading cache internals.
// Separate record lifetimes for both kinds exercise the worst combined bound.
async function checkRetention() {
  assert.equal(typeof global.gc,'function','run this test with node --expose-gc')
  const cache = api.createPresentationCache(), refs = []
  function insert(n) {
    const p = provider(n)
    refs.push(new WeakRef(p.dailyUsage))
    const view = n%2 ? api.cachedDailyRows(cache,p,now,overrides,0) : api.cachedModelWindowPresentation(cache,p,now,overrides,0)
    assert.ok(view)
  }
  for (let n=1;n<=2048;n++) insert(n)
  // A WeakRef keeps its target alive for the current job. Leave that job
  // before requesting collection; do not dereference between collections.
  for (let n=0;n<3;n++) { await new Promise(setImmediate); global.gc() }
  const retained = refs.filter(ref=>ref.deref()!==undefined).length
  assert.ok(retained>0 && retained<=256,`cache retained ${retained} obsolete/current usage snapshots; bound is 256`)
  const latest = provider(3000000)
  assert.equal(api.cachedModelWindowPresentation(cache,latest,now,overrides,0).summaries[0].tokens,3000000)
  console.log('ok - retained usage snapshots after 2048 alternating replacements:',retained,'(combined bound 256)')
}
checkRetention().catch(error=>{ console.error(error); process.exitCode=1 })
