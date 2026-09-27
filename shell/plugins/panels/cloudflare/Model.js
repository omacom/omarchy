var DASHBOARD_URL = "https://dash.cloudflare.com"

// cf colors its JSON whenever FORCE_COLOR leaks into the environment, even
// when stdout is a pipe, so strip escapes before parsing.
function stripAnsi(text) {
  return String(text || "").replace(/\u001b\[[0-9;]*m/g, "")
}

function parseJson(raw) {
  var text = stripAnsi(raw).trim()
  if (text === "") return { ok: true, value: null }
  try {
    return { ok: true, value: JSON.parse(text) }
  } catch (e) {
    return { ok: false, value: null }
  }
}

function signedOut(message) {
  return {
    ok: true,
    authenticated: false,
    tokenValid: false,
    email: "",
    accounts: [],
    message: message || "Signed out"
  }
}

// Parses `cf auth whoami`, which exits 0 whether or not you are signed in and
// reports the difference in its JSON.
function parseWhoami(raw) {
  var parsed = parseJson(raw)
  if (!parsed.ok) {
    var failed = signedOut("Status error")
    failed.ok = false
    failed.error = "Failed to parse cf auth whoami"
    return failed
  }

  var data = parsed.value
  if (!data || data.authenticated !== true) return signedOut(data && data.error ? String(data.error) : "")

  var accounts = []
  var rawAccounts = Array.isArray(data.accounts) ? data.accounts : []
  for (var i = 0; i < rawAccounts.length; i++) {
    var account = rawAccounts[i] || {}
    var id = String(account.id || "")
    if (id !== "") accounts.push({ id: id, name: String(account.name || id) })
  }
  accounts.sort(function(a, b) { return a.name.localeCompare(b.name) })

  return {
    ok: true,
    authenticated: true,
    tokenValid: data.tokenValid !== false,
    email: String(data.email || ""),
    accounts: accounts,
    message: data.tokenValid === false ? "Token rejected" : "Signed in"
  }
}

// `cf zones list` returns every zone the login can see, across accounts, so
// keep only the selected account's.
function parseZones(raw, accountId) {
  var parsed = parseJson(raw)
  if (!parsed.ok || !Array.isArray(parsed.value)) return { ok: parsed.ok && parsed.value === null, zones: [] }

  var zones = []
  for (var i = 0; i < parsed.value.length; i++) {
    var zone = parsed.value[i] || {}
    var owner = String((zone.account && zone.account.id) || "")
    if (accountId && owner !== "" && owner !== accountId) continue
    if (!zone.id || !zone.name) continue
    zones.push({
      id: String(zone.id),
      name: String(zone.name),
      status: String(zone.status || ""),
      paused: zone.paused === true,
      plan: String((zone.plan && zone.plan.name) || "")
    })
  }
  zones.sort(function(a, b) { return a.name.localeCompare(b.name) })
  return { ok: true, zones: zones }
}

function parseWorkers(raw) {
  var parsed = parseJson(raw)
  if (!parsed.ok || !Array.isArray(parsed.value)) return { ok: parsed.ok && parsed.value === null, workers: [] }

  var workers = []
  for (var i = 0; i < parsed.value.length; i++) {
    var worker = parsed.value[i] || {}
    if (!worker.name) continue
    var subdomain = worker.subdomain || {}
    var observability = worker.observability || {}
    workers.push({
      id: String(worker.id || worker.name),
      name: String(worker.name),
      deployedOn: String(worker.deployed_on || worker.updated_on || worker.created_on || ""),
      url: subdomain.enabled === true ? String(subdomain.url || "") : "",
      // Metrics come from Workers Logs, which only exist when this is on.
      logsEnabled: observability.enabled === true && (!observability.logs || observability.logs.enabled !== false)
    })
  }
  // Most recent deploy first: the section answers "did my deploy land?".
  workers.sort(function(a, b) {
    var byDeploy = (Date.parse(b.deployedOn) || 0) - (Date.parse(a.deployedOn) || 0)
    return byDeploy !== 0 ? byDeploy : a.name.localeCompare(b.name)
  })
  return { ok: true, workers: workers }
}

// A healthy zone needs no label, as in the dashboard; only a zone that is not
// serving through Cloudflare calls attention to itself.
function zoneProblem(zone) {
  if (!zone) return ""
  if (zone.paused) return "Paused"
  if (zone.status !== "" && zone.status !== "active") return zone.status.charAt(0).toUpperCase() + zone.status.slice(1)
  return ""
}

function zoneDetail(zone) {
  var problem = zoneProblem(zone)
  if (problem !== "") return problem
  return zone && zone.plan ? zone.plan.replace(/ Website$/, "") : ""
}

function relativeTime(iso, nowMs) {
  var when = Date.parse(String(iso || ""))
  if (!isFinite(when)) return ""
  var seconds = Math.max(0, Math.round(((nowMs === undefined ? Date.now() : nowMs) - when) / 1000))
  if (seconds < 60) return "just now"
  var minutes = Math.round(seconds / 60)
  if (minutes < 60) return minutes + "m ago"
  var hours = Math.round(minutes / 60)
  if (hours < 24) return hours + "h ago"
  var days = Math.round(hours / 24)
  if (days < 30) return days + "d ago"
  var months = Math.round(days / 30)
  if (months < 12) return months + "mo ago"
  return Math.round(days / 365) + "y ago"
}

// Worker metrics come from Workers Logs through `cf observability telemetry
// query`. Leave granularity unset: the API reads it as a bucket size, and a
// small number asks for thousands of buckets and times out.
var BENIGN_OUTCOMES = ["ok", "canceled", "responseStreamDisconnected", "clientDisconnected"]

function metricsQuery(workerName, fromMs, toMs, calculations, extraFilters) {
  var filters = [{ key: "$workers.scriptName", operation: "eq", type: "string", value: String(workerName || "") }]
  return JSON.stringify({
    queryId: "omarchy-cloudflare-panel",
    timeframe: { from: fromMs, to: toMs },
    view: "calculations",
    dry: true,
    chart: true,
    compare: true,
    parameters: {
      datasets: ["cloudflare-workers"],
      filters: filters.concat(extraFilters || []),
      calculations: calculations
    }
  })
}

function usageQuery(workerName, fromMs, toMs) {
  return metricsQuery(workerName, fromMs, toMs, [
    { operator: "count", alias: "invocations" },
    { operator: "median", key: "$workers.cpuTimeMs", keyType: "number", alias: "cpu" }
  ])
}

// Canceled requests and dropped streams are visitors leaving, not failures;
// the dashboard's Errors leaves them out too.
function errorsQuery(workerName, fromMs, toMs) {
  var filters = []
  for (var i = 0; i < BENIGN_OUTCOMES.length; i++) {
    filters.push({ key: "$workers.outcome", operation: "neq", type: "string", value: BENIGN_OUTCOMES[i] })
  }
  return metricsQuery(workerName, fromMs, toMs, [{ operator: "count", alias: "errors" }], filters)
}

function emptyMetric() {
  return { value: null, previous: null, series: [] }
}

// Returns { ok, metrics: { alias: { value, previous, series } } }. Buckets
// with no events come back empty and are drawn as zero.
function parseMetrics(raw) {
  var parsed = parseJson(raw)
  if (!parsed.ok || !parsed.value || !Array.isArray(parsed.value.calculations)) return { ok: false, metrics: {} }

  var metrics = {}
  var calculations = parsed.value.calculations
  for (var i = 0; i < calculations.length; i++) {
    var calculation = calculations[i] || {}
    var alias = String(calculation.alias || calculation.calculation || "")
    if (alias === "") continue
    var metric = emptyMetric()
    var aggregates = Array.isArray(calculation.aggregates) ? calculation.aggregates : []
    metric.value = aggregates.length > 0 ? Number(aggregates[0].value) || 0 : 0
    var series = Array.isArray(calculation.series) ? calculation.series : []
    for (var j = 0; j < series.length; j++) {
      var point = series[j] && Array.isArray(series[j].data) && series[j].data.length > 0 ? Number(series[j].data[0].value) : 0
      metric.series.push(isFinite(point) ? point : 0)
    }
    metrics[alias] = metric
  }

  var compare = Array.isArray(parsed.value.compare) ? parsed.value.compare : []
  for (var k = 0; k < compare.length; k++) {
    var previous = compare[k] || {}
    var key = String(previous.alias || "")
    if (metrics[key] && Array.isArray(previous.aggregates) && previous.aggregates.length > 0) {
      metrics[key].previous = Number(previous.aggregates[0].value) || 0
    }
  }
  return { ok: true, metrics: metrics }
}

function formatCount(value) {
  if (value === null || value === undefined) return "–"
  var n = Number(value) || 0
  if (n < 1000) return String(Math.round(n))
  if (n < 1000000) return trimDecimals(n / 1000) + "k"
  return trimDecimals(n / 1000000) + "M"
}

function trimDecimals(n) {
  return (n < 10 ? n.toFixed(2) : n < 100 ? n.toFixed(1) : n.toFixed(0)).replace(/\.?0+$/, "")
}

function formatMs(value) {
  if (value === null || value === undefined) return "–"
  var n = Number(value) || 0
  return (n < 10 ? trimDecimals(n) : String(Math.round(n))) + " ms"
}

// "↘ 36%" style change against the previous period, or "" when there is no
// earlier value to compare with.
function formatChange(value, previous) {
  if (value === null || previous === null || previous === undefined || !(previous > 0)) return ""
  var percent = Math.round((value - previous) / previous * 100)
  if (percent === 0) return "0%"
  return (percent > 0 ? "↗ " : "↘ ") + Math.abs(percent) + "%"
}

var SOURCE_LABELS = { wrangler: "Wrangler", api: "API", dash: "Dashboard", dashboard: "Dashboard", terraform: "Terraform" }

function sourceLabel(source) {
  var value = String(source || "")
  if (SOURCE_LABELS[value.toLowerCase()]) return SOURCE_LABELS[value.toLowerCase()]
  return value === "" ? "" : value.charAt(0).toUpperCase() + value.slice(1)
}

function parseVersions(raw, limit) {
  var parsed = parseJson(raw)
  if (!parsed.ok || !Array.isArray(parsed.value)) return { ok: parsed.ok && parsed.value === null, versions: [] }

  var versions = []
  for (var i = 0; i < parsed.value.length; i++) {
    var version = parsed.value[i] || {}
    if (!version.id) continue
    var annotations = version.annotations || {}
    var author = String(version.author_email || "")
    versions.push({
      id: String(version.id),
      shortId: String(version.id).substring(0, 8),
      message: String(annotations["workers/message"] || ""),
      tag: String(annotations["workers/tag"] || "").substring(0, 8),
      source: sourceLabel(version.source),
      author: author.indexOf("@") > 0 ? author.substring(0, author.indexOf("@")) : author,
      createdOn: String(version.created_on || "")
    })
  }
  versions.sort(function(a, b) { return (Date.parse(b.createdOn) || 0) - (Date.parse(a.createdOn) || 0) })
  return { ok: true, versions: versions.slice(0, limit || versions.length) }
}

// The newest deployment says which versions are live and with what share of
// traffic; usually one version at 100%.
function parseDeployments(raw) {
  var parsed = parseJson(raw)
  var list = parsed.ok && parsed.value ? (Array.isArray(parsed.value) ? parsed.value : parsed.value.deployments) : null
  if (!Array.isArray(list)) return { ok: parsed.ok && parsed.value === null, live: {}, deployedOn: "", source: "" }

  list = list.slice().sort(function(a, b) { return (Date.parse((b || {}).created_on) || 0) - (Date.parse((a || {}).created_on) || 0) })
  var latest = list[0] || {}
  var live = {}
  var versions = Array.isArray(latest.versions) ? latest.versions : []
  for (var i = 0; i < versions.length; i++) {
    if (versions[i] && versions[i].version_id) live[String(versions[i].version_id)] = Number(versions[i].percentage) || 0
  }
  return { ok: true, live: live, deployedOn: String(latest.created_on || ""), source: sourceLabel(latest.source) }
}

// "SPLIT 90/10" while a gradual rollout is in progress, else "".
function rolloutText(live) {
  var shares = []
  for (var id in live) shares.push(live[id])
  if (shares.length < 2) return ""
  shares.sort(function(a, b) { return b - a })
  return "Split " + shares.map(function(share) { return Math.round(share) }).join("/")
}

function accountDashboardUrl(accountId) {
  var id = String(accountId || "")
  return id === "" ? DASHBOARD_URL : DASHBOARD_URL + "/" + encodeURIComponent(id)
}

function zoneDashboardUrl(accountId, zone) {
  if (!zone || !zone.name) return accountDashboardUrl(accountId)
  return accountDashboardUrl(accountId) + "/" + encodeURIComponent(zone.name)
}

function workerDashboardUrl(accountId, worker) {
  if (!worker || !worker.name) return accountDashboardUrl(accountId)
  return accountDashboardUrl(accountId) + "/workers/services/view/" + encodeURIComponent(worker.name) + "/production"
}

if (typeof module !== "undefined") {
  module.exports = {
    DASHBOARD_URL: DASHBOARD_URL,
    stripAnsi: stripAnsi,
    parseWhoami: parseWhoami,
    parseZones: parseZones,
    parseWorkers: parseWorkers,
    zoneProblem: zoneProblem,
    zoneDetail: zoneDetail,
    relativeTime: relativeTime,
    usageQuery: usageQuery,
    errorsQuery: errorsQuery,
    parseMetrics: parseMetrics,
    formatCount: formatCount,
    formatMs: formatMs,
    formatChange: formatChange,
    sourceLabel: sourceLabel,
    parseVersions: parseVersions,
    parseDeployments: parseDeployments,
    rolloutText: rolloutText,
    accountDashboardUrl: accountDashboardUrl,
    zoneDashboardUrl: zoneDashboardUrl,
    workerDashboardUrl: workerDashboardUrl
  }
}
