// Display-only summaries. No endpoint calls or token-to-quota estimates.
function finiteNumber(value) {
  return typeof value === "number" && isFinite(value)
}

function duration(ms) {
  if (ms <= 0) return "awaiting refresh"
  var minutes = Math.max(1, Math.ceil(ms / 60000))
  if (minutes >= 1440) return Math.floor(minutes / 1440) + "d " + Math.floor(minutes % 1440 / 60) + "h"
  if (minutes >= 60) return Math.floor(minutes / 60) + "h " + minutes % 60 + "m"
  return minutes + "m"
}

function summary(provider, now, maxAgeMs) {
  var p = provider || {}
  var result = { fraction: 0, known: false, stale: false, alarming: false, text: "—", detail: "Usage unavailable" }
  if (p.usageStatusText) {
    result.detail = String(p.usageStatusText)
    return result
  }
  var updated = Date.parse(p.updatedAt || "")
  result.stale = !isFinite(updated) || now - updated > maxAgeMs || updated > now + 60000
  var limits = Array.isArray(p.limits) ? p.limits : []
  var best = null
  var details = []
  for (var i = 0; i < limits.length; i++) {
    var limit = limits[i] || {}
    if (!finiteNumber(limit.percent) || limit.percent < 0 || limit.percent > 1) continue
    var reset = Date.parse(limit.resetsAt || "")
    if (isFinite(reset) && reset <= now) result.stale = true
    if (!best || limit.percent > best.percent) best = limit
    details.push(String(limit.title || limit.label || "Limit") + ": " + Math.round(limit.percent * 100) + "% used"
      + (isFinite(reset) ? " · " + (reset > now ? "resets in " : "") + duration(reset - now) : ""))
  }
  if (best) {
    result.fraction = best.percent
    result.known = true
    result.text = Math.round(best.percent * 100) + "%"
    result.detail = details.join("\n")
  } else if (p.balance && finiteNumber(p.balance.remaining) && p.balance.remaining >= 0) {
    var b = p.balance
    result.text = String(b.currency || "USD") + " " + b.remaining.toFixed(2)
    result.detail = result.text + " remaining" + (b.estimated ? " (estimated)" : "")
    if (finiteNumber(b.funded) && b.funded > 0) {
      result.known = true
      result.fraction = Math.max(0, Math.min(1, 1 - b.remaining / b.funded))
    }
  }
  result.alarming = result.known && !result.stale && result.fraction >= 0.9
  if (result.stale && (result.known || p.balance)) {
    result.text = "~" + result.text
    result.detail = "Stale reading · " + result.detail
  }
  return result
}

function sessionsFor(sessions, id, now, scannedAt) {
  if (!Array.isArray(sessions) || !finiteNumber(scannedAt) || now - scannedAt > 15000 || scannedAt > now + 1000) return []
  return sessions.filter(function(s) { return s && s.providerId === id })
}

function activity(sessions) {
  if (sessions.some(function(s) { return s.state === "waiting" })) return "waiting"
  if (sessions.some(function(s) { return s.state === "working" })) return "working"
  if (sessions.some(function(s) { return s.state === "idle" })) return "idle"
  return "unknown"
}

if (typeof module !== "undefined") module.exports = { summary, duration, sessionsFor, activity }
