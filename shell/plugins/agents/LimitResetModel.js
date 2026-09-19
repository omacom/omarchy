function providerLabelKey(providerId, label) {
  return providerId + "\n" + label
}

function schedule(pending, records, now, notificationsEnabled, providerEnabled) {
  if (!notificationsEnabled) return {}

  var next = Object.assign({}, pending || {})
  var values = Array.isArray(records) ? records : []

  for (var i = 0; i < values.length; i++) {
    var record = values[i] || {}
    var providerId = String(record.id || "")
    if (!providerId || !providerEnabled(providerId)) continue

    // An empty limits array is also emitted while a collector is recovering
    // from a temporary network/auth failure. Keep the prior deadline until a
    // non-empty response can authoritatively replace it.
    var limits = Array.isArray(record.limits) ? record.limits : []
    if (limits.length === 0) continue

    // A non-empty response is authoritative for future state. Keep entries
    // that are already due until announce() gets a chance to deliver them;
    // a refresh can race the 15-second notification timer.
    for (var key in next) {
      if (key.slice(0, providerId.length + 1) === providerId + "\n"
          && next[key] && next[key].deadline > now) delete next[key]
    }

    for (var k = 0; k < limits.length; k++) {
      var current = limits[k] || {}
      var resetAt = String(current.resetsAt || "")
      var resetMs = new Date(resetAt).getTime()
      if (!isFinite(resetMs) || resetMs <= now) continue
      var currentLabel = String(current.title || current.label || "Limit")
      var currentKey = providerLabelKey(providerId, currentLabel) + "\n" + resetAt
      next[currentKey] = {
        deadline: resetMs,
        providerName: String(record.name || providerId),
        label: currentLabel
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
    var providerId = key.split("\n", 1)[0]
    if (providerEnabled && !providerEnabled(providerId)) {
      delete next[key]
      continue
    }
    if (!reset || reset.deadline > now) continue
    notifications.push({
      title: reset.providerName + " limit reset",
      body: reset.label + " is available again."
    })
    delete next[key]
  }
  return { pending: next, notifications: notifications }
}

if (typeof module !== "undefined") module.exports = {
  schedule: schedule,
  announce: announce
}
