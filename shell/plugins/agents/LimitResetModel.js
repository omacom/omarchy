function pendingKey(providerId, accountId, identityId, label, resetAt) {
  return JSON.stringify([providerId, accountId, identityId, label, resetAt])
}

function schedule(pending, records, now, notificationsEnabled, providerEnabled) {
  if (!notificationsEnabled) return {}

  var next = Object.assign({}, pending || {})
  var values = Array.isArray(records) ? records : []
  var present = Object.create(null)
  var presentAccounts = Object.create(null)
  for (var r = 0; r < values.length; r++) {
    var record = values[r] || {}
    var id = String(record.id || "")
    if (!id) continue
    present[id] = true
    var registryStatus = String(record.accountRegistryStatus || "")
    if (registryStatus === "unreadable" || registryStatus === "missing") {
      // A fallback active-account record says nothing about which subscriptions
      // remain registered. Preserve their pending deadlines until authoritative.
      continue
    }
    if (Array.isArray(record.accounts)) {
      presentAccounts[id] = Object.create(null)
      for (var a = 0; a < record.accounts.length; a++) {
        var account = record.accounts[a] || {}
        var accountId = String(account.id || account.label || "")
        if (accountId) presentAccounts[id][accountId] = Object.prototype.hasOwnProperty.call(account, "accountId")
          ? String(account.accountId || "") : null
      }
    } else if (Array.isArray(record.limits)) {
      // A complete single-account record supersedes a prior multi-account
      // inventory; an ID-only discovery placeholder does not.
      presentAccounts[id] = Object.create(null)
      presentAccounts[id][""] = null
    }
  }

  for (var pendingKeyValue in next) {
    var queued = next[pendingKeyValue] || {}
    if (!present[queued.providerId]) {
      delete next[pendingKeyValue]
    } else if (presentAccounts[queued.providerId]) {
      var inventory = presentAccounts[queued.providerId]
      var queuedAccountId = String(queued.accountId || "")
      if (!Object.prototype.hasOwnProperty.call(inventory, queuedAccountId)
          || (inventory[queuedAccountId] !== null
            && (!inventory[queuedAccountId] || inventory[queuedAccountId] !== queued.identityId))) {
        delete next[pendingKeyValue]
      }
    }
  }

  for (var i = 0; i < values.length; i++) {
    var currentRecord = values[i] || {}
    var providerId = String(currentRecord.id || "")
    if (!providerId || !providerEnabled(providerId)) continue

    var registryStatus = String(currentRecord.accountRegistryStatus || "")
    if (registryStatus === "unreadable") continue

    var accounts = Array.isArray(currentRecord.accounts) ? currentRecord.accounts : null
    var limitSources = []
    if (registryStatus === "missing") {
      // Legacy single-account installs have no registry. Continue their
      // top-level limits, but do not let a missing inventory displace known
      // per-account deadlines.
      var hasAccountDeadlines = false
      for (var pendingKeyValue in next) {
        var pendingReset = next[pendingKeyValue]
        if (pendingReset && pendingReset.providerId === providerId && pendingReset.accountId) {
          hasAccountDeadlines = true
          break
        }
      }
      if (!hasAccountDeadlines)
        limitSources.push({ accountId: "", identityId: null, accountName: "",
          limits: Array.isArray(currentRecord.limits) ? currentRecord.limits : [] })
    } else if (accounts) {
      for (var j = 0; j < accounts.length; j++) {
        var accountRecord = accounts[j] || {}
        limitSources.push({
          accountId: String(accountRecord.id || accountRecord.label || ""),
          identityId: Object.prototype.hasOwnProperty.call(accountRecord, "accountId")
            ? String(accountRecord.accountId || "") : null,
          accountName: String(accountRecord.label || accountRecord.name || ""),
          limits: Array.isArray(accountRecord.limits) ? accountRecord.limits : []
        })
      }
    } else {
      limitSources.push({
        accountId: "",
        identityId: null,
        accountName: "",
        limits: Array.isArray(currentRecord.limits) ? currentRecord.limits : []
      })
    }

    for (var s = 0; s < limitSources.length; s++) {
      var source = limitSources[s]
      // A cleared identity is a signed-out home, not a temporary limits gap.
      // Unknown identities in legacy collector records retain compatibility.
      if (source.identityId === "") continue
      // An empty response may mean a transient fetch failure. Keep that
      // account's prior deadlines until a non-empty response can replace them.
      if (source.limits.length === 0) continue

      // Replace future state for this account only. Already-due entries stay
      // queued until announce() delivers them, even if refresh races the timer.
      for (var key in next) {
        var queuedForAccount = next[key]
        if (queuedForAccount && queuedForAccount.providerId === providerId
            && queuedForAccount.accountId === source.accountId
            && queuedForAccount.deadline > now) delete next[key]
      }

      for (var k = 0; k < source.limits.length; k++) {
        var limit = source.limits[k] || {}
        var resetAt = String(limit.resetsAt || "")
        var resetMs = new Date(resetAt).getTime()
        if (!isFinite(resetMs) || resetMs <= now) continue
        var label = String(limit.title || limit.label || "Limit")
        var keyValue = pendingKey(providerId, source.accountId, source.identityId, label, resetAt)
        next[keyValue] = {
          providerId: providerId,
          accountId: source.accountId,
          identityId: source.identityId,
          providerName: String(currentRecord.name || providerId),
          accountName: source.accountName,
          label: label,
          deadline: resetMs
        }
      }
    }
  }

  return next
}

function announce(pending, now, notificationsEnabled, providerEnabled) {
  if (!notificationsEnabled) return { pending: {}, notifications: [] }

  var next = Object.assign({}, pending || {})
  var notifications = []
  for (var key in next) {
    var reset = next[key]
    if (providerEnabled && !providerEnabled(reset && reset.providerId)) {
      delete next[key]
      continue
    }
    if (!reset || reset.deadline > now) continue
    notifications.push({
      title: reset.providerName + (reset.accountName ? " (" + reset.accountName + ")" : "") + " limit reset",
      body: reset.label + " rate-limit window has reset."
    })
    delete next[key]
  }
  return { pending: next, notifications: notifications }
}

if (typeof module !== "undefined") module.exports = {
  schedule: schedule,
  announce: announce
}
