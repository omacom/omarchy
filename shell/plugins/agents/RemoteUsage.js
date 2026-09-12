// Build every scope when records change. Selecting a tab only indexes these
// prepared objects; it never reads sources or walks the usage history again.
function copy(value) {
  var result = {}
  for (var key in value) result[key] = value[key]
  return result
}

function providerCoverage(record) {
  record = record || {}
  var metadata = false, incomplete = false, oldest = 0, unavailableWithoutSuccess = false
  function inspect(part) {
    if (!part || typeof part !== "object" || !part.status) return
    metadata = true
    if (part.status !== "stale" && part.status !== "unavailable") return
    incomplete = true
    var success = Number(part.lastSuccess || 0)
    if (success > 0) oldest = oldest > 0 ? Math.min(oldest, success) : success
    else unavailableWithoutSuccess = true
  }
  var sources = record.remoteSources || {}
  for (var source in sources) inspect(sources[source])
  inspect(record.remoteCollector)

  var daily = record.dailyUsage
  var known = record.todayTotalTokens !== null && record.todayTotalTokens !== undefined
  if (!known && daily && daily.schemaVersion === 1 && daily.days && daily.days.length > 0) known = true
  if (metadata && (!daily || daily.complete !== true || record.todayTotalTokens === null)) incomplete = true
  return { known: known, incomplete: incomplete, oldest: oldest,
    unavailableWithoutSuccess: unavailableWithoutSuccess }
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
  var coverage = providerCoverage(record)
  result.knownUsage = coverage.known
  result.usageIncomplete = coverage.incomplete
  result.oldestStaleSuccess = coverage.oldest
  result.unavailableWithoutSuccess = coverage.unavailableWithoutSuccess
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
  var complete = true, unallocated = 0, knownContributions = 0, usageIncomplete = false
  var oldestStaleSuccess = 0, unavailableWithoutSuccess = false
  for (var i = 0; i < providers.length; i++) {
    var provider = providers[i]
    var coverage = provider.knownUsage === false
      ? { known: false, incomplete: provider.usageIncomplete === true,
          oldest: Number(provider.oldestStaleSuccess || 0),
          unavailableWithoutSuccess: provider.unavailableWithoutSuccess === true }
      : providerCoverage(provider)
    if (provider.usageIncomplete === true) coverage.incomplete = true
    if (Number(provider.oldestStaleSuccess || 0) > 0) coverage.oldest = Number(provider.oldestStaleSuccess)
    if (provider.unavailableWithoutSuccess === true) coverage.unavailableWithoutSuccess = true
    usageIncomplete = usageIncomplete || coverage.incomplete
    unavailableWithoutSuccess = unavailableWithoutSuccess || coverage.unavailableWithoutSuccess
    if (coverage.oldest > 0)
      oldestStaleSuccess = oldestStaleSuccess > 0 ? Math.min(oldestStaleSuccess, coverage.oldest) : coverage.oldest
    if (coverage.known) {
      knownContributions++
      result.totalPrompts += Number(provider.totalPrompts || 0)
      result.totalSessions += Number(provider.totalSessions || 0)
      result.hasPromptStats = result.hasPromptStats || provider.hasPromptStats !== false
    }
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
  var knownUsage = providers.length === 0 || knownContributions > 0
  result.dailyUsage = { schemaVersion: 1, unit: "tokens", fromDate: keys[0], throughDate: todayKey,
    complete: complete && !usageIncomplete, issues: issues, unallocatedTokens: unallocated,
    days: knownUsage ? keys.map(function(key) { return days[key] }) : [] }
  result.recentDays = knownUsage
    ? Object.keys(recent).sort().map(function(key) { return recent[key] }) : []
  result.modelUsage = models
  result.todayTokensByModel = modelToday
  result.activeDays = Object.keys(active).length
  result.todayTotalTokens = knownUsage ? result.todayTotalTokens : null
  result.knownUsage = knownUsage
  result.usageIncomplete = usageIncomplete
  result.oldestStaleSuccess = oldestStaleSuccess
  result.unavailableWithoutSuccess = unavailableWithoutSuccess
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
  // A computer with no completed import contributes an unknown value to every
  // supported provider in All; it must not silently disappear as zero.
  for (var missingScope in missing) {
    if (!missing[missingScope]) continue
    for (var missingIdIndex = 0; missingIdIndex < ids.length; missingIdIndex++) {
      var missingId = ids[missingIdIndex]
      if (["codex", "claude", "kimi"].indexOf(missingId) < 0) continue
      all[missingId].push({ id: missingId, name: accounts[missingId].providerName,
        knownUsage: false, usageIncomplete: true, unavailableWithoutSuccess: true })
    }
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
      if (missing[scope]) {
        value = copy(value)
        value.remoteMissing = true
        value.knownUsage = false
        value.usageIncomplete = true
        value.unavailableWithoutSuccess = true
        value.todayTotalTokens = null
        value.recentDays = []
        value.dailyUsage = copy(value.dailyUsage)
        value.dailyUsage.complete = false
        value.dailyUsage.days = []
      }
      return value
    })
  }
  return result
}

function machineStatus(machines, selectedId, providerId, nowMs) {
  var selected = machines.filter(function(machine) { return selectedId === "all" || machine.id === selectedId })
  if (!selected.length) return ""
  var now = nowMs / 1000, missing = 0, displayOldest = now
  var importing = false, importingOldest = 0
  var issues = false, issueOldest = 0, unavailableWithoutSuccess = false
  function rememberIssue(coverage) {
    if (!coverage.incomplete) return
    issues = true
    if (coverage.oldest > 0)
      issueOldest = issueOldest > 0 ? Math.min(issueOldest, coverage.oldest) : coverage.oldest
    else if (coverage.unavailableWithoutSuccess) unavailableWithoutSuccess = true
  }
  for (var i = 0; i < selected.length; i++) {
    var machine = selected[i]
    var machineSuccess = Number(machine.lastSuccess || 0)
    if (!machineSuccess) missing++
    else displayOldest = Math.min(displayOldest, machineSuccess)
    if (machine.status === "importing") {
      importing = true
      if (machineSuccess > 0)
        importingOldest = importingOldest > 0 ? Math.min(importingOldest, machineSuccess) : machineSuccess
    }

    // Stale/unavailable machine status represents a transport-wide failure.
    // An incomplete machine can have a current sibling provider, so its
    // provider metadata below decides whether this page is affected.
    if (machine.status === "stale" || machine.status === "unavailable") {
      issues = true
      if (machineSuccess > 0)
        issueOldest = issueOldest > 0 ? Math.min(issueOldest, machineSuccess) : machineSuccess
      else unavailableWithoutSuccess = true
    } else if (machineSuccess > 0 && now - machineSuccess > 7200) {
      issues = true
      issueOldest = issueOldest > 0 ? Math.min(issueOldest, machineSuccess) : machineSuccess
    }

    var records = machine.providers || {}
    if (providerId) {
      if (records[providerId]) rememberIssue(providerCoverage(records[providerId]))
    } else {
      for (var id in records) rememberIssue(providerCoverage(records[id]))
      if (machine.status !== "current" && machine.status !== "incomplete") issues = true
    }
  }
  if (missing) return "Incomplete: " + missing + " computer(s) have no successful import yet"
  if (importing) {
    var oldestImport = importingOldest
    if (issueOldest > 0) oldestImport = oldestImport > 0 ? Math.min(oldestImport, issueOldest) : issueOldest
    if (oldestImport > 0)
      return "Importing / continuing · oldest relevant update " + Math.max(0, Math.floor((now - oldestImport) / 60)) + " min ago"
    return "Importing / continuing"
  }
  if (issues) {
    if (issueOldest > 0)
      return "Last known / incomplete · oldest relevant update " + Math.max(0, Math.floor((now - issueOldest) / 60)) + " min ago"
    if (unavailableWithoutSuccess) return "Last known / incomplete · provider source unavailable"
    return "Last known / incomplete"
  }
  return "Remote usage · oldest update " + Math.max(0, Math.floor((now - displayOldest) / 60)) + " min ago"
}

if (typeof module !== "undefined") module.exports = {
  scopes: scopes, sum: sum, providerCoverage: providerCoverage, machineStatus: machineStatus
}
