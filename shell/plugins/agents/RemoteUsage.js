// Build every scope when records change. Selecting a tab only indexes these
// prepared objects; it never reads sources or walks the usage history again.
function copy(value) {
  var result = {}
  for (var key in value) result[key] = value[key]
  return result
}

function remoteProvider(record, account) {
  var result = copy(record || {})
  result.providerId = record.id
  result.providerName = record.name || record.id
  result.costScopeCompatible = true
  result.limits = account ? account.limits : []
  result.balance = account ? account.balance : null
  result.tierLabel = account ? account.tierLabel : ""
  result.usageStatusText = account ? account.usageStatusText : ""
  result.authHelpText = account ? account.authHelpText : ""
  return result
}

function sum(providers, account, nowMs) {
  var result = remoteProvider({ id: account.providerId, name: account.providerName }, account)
  var today = new Date(nowMs)
  function dateKey(date) {
    return date.getFullYear() + "-" + ("0" + (date.getMonth() + 1)).slice(-2) + "-" + ("0" + date.getDate()).slice(-2)
  }
  var todayKey = dateKey(today)
  var days = {}, recent = {}, models = {}, modelToday = {}, issues = [], active = {}
  for (var offset = 29; offset >= 0; offset--) {
    var date = new Date(today.getFullYear(), today.getMonth(), today.getDate() - offset)
    var key = dateKey(date)
    days[key] = { date: key, buckets: [] }
    if (offset < 7) recent[key] = { date: key, messageCount: 0 }
  }
  result.totalPrompts = 0
  result.totalSessions = 0
  result.todayPrompts = 0
  result.todaySessions = 0
  result.todayTotalTokens = 0
  result.hasLocalStats = true
  result.hasPromptStats = false
  var complete = true, unallocated = 0
  for (var i = 0; i < providers.length; i++) {
    var provider = providers[i]
    result.totalPrompts += Number(provider.totalPrompts || 0)
    result.totalSessions += Number(provider.totalSessions || 0)
    result.hasPromptStats = result.hasPromptStats || provider.hasPromptStats !== false
    var daily = provider.dailyUsage
    if (!daily || daily.schemaVersion !== 1) {
      complete = false
      issues.push("A machine has no compatible daily usage record")
      continue
    }
    complete = complete && daily.complete === true
    unallocated += Number(daily.unallocatedTokens || 0)
    var sourceIssues = daily.issues || []
    for (var si = 0; si < sourceIssues.length; si++)
      if (issues.indexOf(sourceIssues[si]) < 0) issues.push(sourceIssues[si])
    var sourceDays = daily.days || []
    for (var d = 0; d < sourceDays.length; d++) {
      var sourceDay = sourceDays[d]
      if (!days[sourceDay.date]) continue
      var buckets = sourceDay.buckets || []
      days[sourceDay.date].buckets = days[sourceDay.date].buckets.concat(buckets)
      for (var b = 0; b < buckets.length; b++) {
        var bucket = buckets[b], tokens = bucket.tokens || {}, total = bucket.totalTokens
        if (total === null || total === undefined) {
          total = 0
          for (var token in tokens) total += Number(tokens[token] || 0)
        }
        if (total > 0) active[sourceDay.date] = true
        if (recent[sourceDay.date]) recent[sourceDay.date].messageCount += total
        var model = bucket.rawModel || "(unknown model)"
        if (!models[model]) models[model] = {}
        for (var field in tokens) models[model][field] = Number(models[model][field] || 0) + Number(tokens[field] || 0)
        if (sourceDay.date === todayKey) {
          result.todayTotalTokens += total
          modelToday[model] = Number(modelToday[model] || 0) + total
        }
      }
    }
    // Legacy prompt counters have only one day's scope; never relabel a
    // cached yesterday counter as today's merely because the clock advanced.
    if (daily.throughDate === todayKey) {
      result.todayPrompts += Number(provider.todayPrompts || 0)
      result.todaySessions += Number(provider.todaySessions || 0)
    }
  }
  var keys = Object.keys(days).sort()
  result.dailyUsage = { schemaVersion: 1, unit: "tokens", fromDate: keys[0], throughDate: todayKey,
    complete: complete, issues: issues, unallocatedTokens: unallocated, days: keys.map(function(key) { return days[key] }) }
  result.recentDays = Object.keys(recent).sort().map(function(key) { return recent[key] })
  result.modelUsage = models
  result.todayTokensByModel = modelToday
  result.activeDays = Object.keys(active).length
  return result
}

function scopes(local, machines, nowMs) {
  var accounts = {}, ids = [], all = {}, result = { local: local }, seen = {}, missing = {}
  for (var i = 0; i < local.length; i++) {
    var p = local[i]
    accounts[p.providerId] = p
    ids.push(p.providerId)
    all[p.providerId] = [p]
  }
  for (var m = 0; m < machines.length; m++) {
    var machine = machines[m]
    if (!machine.identity || seen[machine.identity]) continue
    seen[machine.identity] = true
    var records = machine.providers || {}, view = []
    for (var id in records) {
      if (!accounts[id]) {
        accounts[id] = { providerId: id, providerName: records[id].name || id, limits: [], balance: null }
        ids.push(id)
        all[id] = []
      }
      var remote = remoteProvider(records[id], accounts[id])
      view.push(remote)
      all[id].push(remote)
    }
    result[machine.id] = view
    missing[machine.id] = !machine.lastSuccess
  }
  result.all = ids.map(function(id) {
    if (all[id].length === 1 && ["codex", "claude", "kimi"].indexOf(id) < 0) return all[id][0]
    return sum(all[id], accounts[id], nowMs)
  })
  // Every machine keeps the provider navigation stable, even where a provider
  // has no recorded usage. Its empty view carries the same local account data.
  for (var scope in result) {
    var lookup = {}
    for (var j = 0; j < result[scope].length; j++) lookup[result[scope][j].providerId] = result[scope][j]
    result[scope] = ids.map(function(id) {
      var value = lookup[id] || sum([], accounts[id], nowMs)
      if (missing[scope]) { value = copy(value); value.remoteMissing = true }
      return value
    })
  }
  return result
}

if (typeof module !== "undefined") module.exports = { scopes: scopes, sum: sum }
