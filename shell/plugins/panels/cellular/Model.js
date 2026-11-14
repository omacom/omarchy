// Pure parsing and presentation for the cellular widget. Everything here
// takes text the service read from mmcli, gdbus or /proc, so the Node tests
// feed it real captures and nothing in it needs a modem.

// Signal quality (0-100) needed to light each of the four bars, and how far
// past a threshold the value has to move before the count changes. ModemManager
// reports SignalQuality several times a second under load; without the band a
// link hovering on a threshold would flicker between two counts.
var LEVEL_THRESHOLDS = [10, 30, 50, 70]
var LEVEL_HYSTERESIS = 5
var LEVEL_COUNT = LEVEL_THRESHOLDS.length

var MONITOR_PREFIX = "org.freedesktop.ModemManager1"

function translator(tr) {
  return typeof tr === "function" ? tr : function(key, english) { return english }
}

function formatter(fmt) {
  if (typeof fmt === "function") return fmt
  return function(value, decimals) {
    var scale = Math.pow(10, decimals || 0)
    return String(Math.round(Number(value) * scale) / scale)
  }
}

// mmcli --output-keyvalue: `key : value`, keys padded to a column, `--` for
// an empty value. Repeated keys (a second bearer) keep the last value; use
// parseBearers for those.
function parseKeyValue(raw) {
  var result = {}
  var lines = String(raw || "").split(/\r?\n/)
  for (var i = 0; i < lines.length; i++) {
    var match = lines[i].match(/^([a-z0-9][a-z0-9.\-_\[\]]*)\s*:\s?(.*)$/i)
    if (!match) continue
    var value = match[2].trim()
    result[match[1]] = value === "--" ? "" : value
  }
  return result
}

function parseBearers(raw) {
  var bearers = []
  var current = null
  var lines = String(raw || "").split(/\r?\n/)
  for (var i = 0; i < lines.length; i++) {
    var match = lines[i].match(/^(bearer\.[a-z0-9.\-_\[\]]*)\s*:\s?(.*)$/i)
    if (!match) continue
    var value = match[2].trim()
    if (value === "--") value = ""
    if (match[1] === "bearer.dbus-path" || !current) {
      current = {}
      bearers.push(current)
    }
    current[match[1]] = value
  }
  return bearers.map(function(b) {
    var startDate = parseInt(b["bearer.stats.start-date"] || "", 10)
    return {
      path: b["bearer.dbus-path"] || "",
      connected: b["bearer.status.connected"] === "yes",
      iface: b["bearer.status.interface"] || "",
      apn: b["bearer.properties.apn"] || "",
      ipType: b["bearer.properties.ip-type"] || "",
      ipv4: b["bearer.ipv4-config.address"] || "",
      prefix: b["bearer.ipv4-config.prefix"] || "",
      gateway: b["bearer.ipv4-config.gateway"] || "",
      startDate: isFinite(startDate) && startDate > 0 ? startDate : 0
    }
  })
}

function listValues(kv, key) {
  var values = []
  var count = parseInt(kv[key + ".length"] || "0", 10)
  for (var i = 1; i <= count; i++) {
    var value = kv[key + ".value[" + i + "]"]
    if (value) values.push(value)
  }
  return values
}

// One refresh: `mmcli -m any -K` (or its error), each bearer's `mmcli -b -K`,
// and /proc/net/route. `installed` false means mmcli itself is missing.
function parseStatus(raw, installed) {
  var text = String(raw || "")
  var status = {
    installed: installed !== false,
    daemon: true,
    present: false,
    state: "",
    failedReason: "",
    unlockRequired: "",
    powerState: "",
    signal: -1,
    tech: "",
    operatorName: "",
    operatorCode: "",
    registration: "",
    apn: "",
    primaryPort: "",
    model: "",
    bearer: null
  }
  if (!status.installed) {
    status.daemon = false
    return status
  }
  if (/couldn't find the ModemManager process|ModemManager1 was not provided|org\.freedesktop\.DBus\.Error\.ServiceUnknown/.test(text)) {
    status.daemon = false
    return status
  }

  var kv = parseKeyValue(text)
  if (!kv["modem.dbus-path"]) return status

  status.present = true
  status.state = kv["modem.generic.state"] || "unknown"
  status.failedReason = kv["modem.generic.state-failed-reason"] || ""
  status.unlockRequired = kv["modem.generic.unlock-required"] || ""
  status.powerState = kv["modem.generic.power-state"] || ""
  var signal = parseInt(kv["modem.generic.signal-quality.value"] || "", 10)
  status.signal = isFinite(signal) ? Math.max(0, Math.min(100, signal)) : -1
  var techs = listValues(kv, "modem.generic.access-technologies")
  status.tech = techs.length > 0 ? techs[0] : ""
  status.operatorName = kv["modem.3gpp.operator-name"] || ""
  status.operatorCode = kv["modem.3gpp.operator-code"] || ""
  status.registration = kv["modem.3gpp.registration-state"] || ""
  status.primaryPort = kv["modem.generic.primary-port"] || ""
  status.model = kv["modem.generic.model"] || ""

  var bearers = parseBearers(text)
  for (var i = 0; i < bearers.length && !status.bearer; i++) {
    if (bearers[i].connected) status.bearer = bearers[i]
  }
  if (!status.bearer && bearers.length > 0) status.bearer = bearers[0]
  // The data bearer carries the APN actually in use; the initial EPS bearer
  // is what the network attached with, the best answer before data is up.
  status.apn = status.bearer && status.bearer.connected && status.bearer.apn
    ? status.bearer.apn : (kv["modem.3gpp.eps.initial-bearer.settings.apn"] || "")
  return status
}

// The interface holding the IPv4 default route with the lowest metric, from
// /proc/net/route. Cellular reads as secondary when something else owns it.
function primaryRouteInterface(raw) {
  var best = ""
  var bestMetric = Infinity
  var lines = String(raw || "").split(/\r?\n/)
  for (var i = 0; i < lines.length; i++) {
    var fields = lines[i].trim().split(/\s+/)
    if (fields.length < 8) continue
    if (fields[1] !== "00000000" || fields[7] !== "00000000") continue
    if (!/^[0-9A-Fa-f]{4}$/.test(fields[3]) || !(parseInt(fields[3], 16) & 1)) continue
    var metric = parseInt(fields[6], 10)
    if (!isFinite(metric)) continue
    if (metric < bestMetric) {
      best = fields[0]
      bestMetric = metric
    }
  }
  return best
}

function rawLevel(quality) {
  var q = Number(quality)
  if (!isFinite(q) || q < 0) return 0
  var level = 0
  while (level < LEVEL_COUNT && q >= LEVEL_THRESHOLDS[level]) level++
  return level
}

// Bars lit for a quality, given the bars lit now. A negative previous level
// means there is none yet, so the raw level stands.
function signalLevel(quality, previous) {
  var q = Number(quality)
  if (!isFinite(q) || q < 0) return 0
  var prev = Number(previous)
  if (!isFinite(prev) || prev < 0 || prev > LEVEL_COUNT) return rawLevel(q)
  var level = prev
  while (level < LEVEL_COUNT && q >= LEVEL_THRESHOLDS[level] + LEVEL_HYSTERESIS) level++
  while (level > 0 && q < LEVEL_THRESHOLDS[level - 1] - LEVEL_HYSTERESIS) level--
  return level
}

// A gdbus monitor line, sorted into what the service does with it. The
// stream carries SignalQuality several times a second and bearer Stats on a
// timer; those two are answered in place or dropped, so only real changes
// (state, registration, bearers, a modem coming or going) cost an mmcli read.
function classifyMonitorLine(line) {
  var text = String(line || "")
  var owner = text.match(/^The name (\S+) (is owned by|does not have an owner)/)
  if (owner) return owner[1] === MONITOR_PREFIX ? { kind: "owner", present: owner[2] === "is owned by" } : { kind: "ignore" }
  if (/^Monitoring signals /.test(text) || text.trim() === "") return { kind: "ignore" }

  var changed = text.match(/: org\.freedesktop\.DBus\.Properties\.PropertiesChanged \('([^']+)', \{(.*)\}, @as \[\]\)\s*$/)
  if (changed) {
    var iface = changed[1]
    var props = changed[2]
    var quality = props.match(/^'SignalQuality': <\(uint32 (\d+), (true|false)\)>$/)
    if (iface === MONITOR_PREFIX + ".Modem" && quality) return { kind: "signal", quality: parseInt(quality[1], 10) }
    if (iface === MONITOR_PREFIX + ".Bearer" && /^'Stats': <\{[^{}]*\}>$/.test(props)) return { kind: "ignore" }
    // Extended signal metrics (RSRP/SNR) poll on their own clock; nothing
    // here shows them.
    if (iface === MONITOR_PREFIX + ".Modem.Signal") return { kind: "ignore" }
  }
  return { kind: "refresh" }
}

function techLabel(tech) {
  var t = String(tech || "").toLowerCase()
  var labels = {
    "5gnr": "5G",
    "lte": "LTE",
    "lte-cat-m": "LTE-M",
    "lte-nb-iot": "NB-IoT",
    "hspa-plus": "HSPA+",
    "hspa": "HSPA",
    "hsupa": "HSUPA",
    "hsdpa": "HSDPA",
    "umts": "3G",
    "edge": "EDGE",
    "gprs": "GPRS",
    "gsm": "GSM",
    "gsm-compact": "GSM",
    "evdo0": "EV-DO",
    "evdoa": "EV-DO",
    "evdob": "EV-DO",
    "1xrtt": "1xRTT"
  }
  if (labels[t]) return labels[t]
  return t === "" || t === "unknown" ? "" : t.toUpperCase()
}

function isRoaming(status) {
  return !!status && status.registration.indexOf("roaming") === 0
}

// What the widget shows for a status: `kind` names the state, `visual` is
// how the bar draws it (hidden, normal, dimmed, or alarm in the urgent
// color), and `level` the bars lit. `primaryIface` comes from
// primaryRouteInterface; an empty one never dims a working link.
function presentation(status, level, primaryIface, tr, fmt) {
  var t = translator(tr)
  var f = formatter(fmt)
  var s = status || parseStatus("", false)
  var result = {
    kind: "unavailable",
    visual: "hidden",
    level: 0,
    crossed: false,
    badge: "",
    roaming: false,
    connected: false,
    canToggle: false,
    transition: "",
    title: t("cellular.title", "Cellular"),
    tech: "",
    statusText: "",
    tooltip: ""
  }
  if (!s.installed || !s.daemon) return result

  var lines = []
  if (!s.present) {
    result.kind = "no-modem"
    result.visual = "dimmed"
    result.crossed = true
    result.statusText = t("cellular.noModem", "No modem")
    result.tooltip = result.statusText
    return result
  }

  var state = s.state
  var reason = s.failedReason
  var lit = Math.max(0, Math.min(LEVEL_COUNT, Number(level) || 0))
  result.tech = techLabel(s.tech)
  if (s.operatorName) result.title = s.operatorName

  if (state === "failed") {
    result.visual = "alarm"
    result.crossed = true
    if (reason === "sim-missing") {
      result.kind = "sim-missing"
      result.statusText = t("cellular.simMissing", "No SIM card")
    } else {
      result.kind = "failed"
      result.statusText = reason && reason !== "unknown"
        ? t("cellular.modemFailedReason", "Modem failed: %1").replace("%1", reason)
        : t("cellular.modemFailed", "Modem failed")
    }
  } else if (state === "locked") {
    result.kind = "pin-locked"
    result.visual = "alarm"
    result.badge = "!"
    if (s.unlockRequired === "sim-puk") result.statusText = t("cellular.simPukRequired", "SIM PUK required")
    else if (s.unlockRequired === "sim-pin") result.statusText = t("cellular.simPinRequired", "SIM PIN required")
    else result.statusText = t("cellular.simLocked", "SIM locked")
  } else if (state === "disabled" || state === "disabling") {
    result.kind = "disabled"
    result.visual = "dimmed"
    result.crossed = true
    result.statusText = t("cellular.modemOff", "Modem off")
  } else if (state === "registered" || state === "connecting" || state === "disconnecting" || state === "connected") {
    result.roaming = isRoaming(s)
    result.level = lit
    result.canToggle = state === "registered" || state === "connected"
    result.transition = state === "connecting" || state === "disconnecting" ? state : ""
    if (state === "connected") {
      result.kind = "connected"
      result.connected = true
      var iface = s.bearer ? s.bearer.iface : ""
      var secondary = primaryIface !== "" && primaryIface !== undefined && iface !== "" && primaryIface !== iface
      result.visual = secondary ? "dimmed" : "normal"
      result.statusText = t("cellular.connected", "Connected")
      if (secondary) lines.push(t("cellular.notPrimary", "Not the primary connection"))
    } else {
      result.kind = "registered"
      result.visual = "dimmed"
      result.statusText = state === "connecting" ? t("cellular.connecting", "Connecting…")
        : (state === "disconnecting" ? t("cellular.disconnecting", "Disconnecting…") : t("cellular.registeredNoData", "Registered, no data"))
    }
    if (result.roaming) result.badge = t("cellular.roamingBadge", "R")
  } else {
    result.kind = "searching"
    result.visual = "dimmed"
    if (s.registration === "denied") result.statusText = t("cellular.registrationDenied", "Registration denied")
    else if (state === "searching" || s.registration === "searching") result.statusText = t("cellular.searching", "Searching for network")
    else result.statusText = t("cellular.noService", "No service")
  }

  var head = result.tech !== "" && (result.kind === "connected" || result.kind === "registered")
    ? result.title + " · " + result.tech : result.title
  var detail = result.statusText
  if (result.kind === "connected" || result.kind === "registered") {
    if (s.signal >= 0) detail += " · " + t("cellular.signalPercent", "%1% signal").replace("%1", f(s.signal))
    if (result.roaming) detail += " · " + t("cellular.roaming", "Roaming")
  }
  result.tooltip = [head, detail].concat(lines).join("\n")
  return result
}

function registrationLabel(registration, tr) {
  var t = translator(tr)
  var r = String(registration || "")
  if (r === "home" || r === "home-sms-only" || r === "home-csfb-not-preferred") return t("cellular.registrationHome", "Home network")
  if (r.indexOf("roaming") === 0) return t("cellular.roaming", "Roaming")
  if (r === "searching") return t("cellular.registrationSearching", "Searching")
  if (r === "denied") return t("cellular.registrationDenied", "Registration denied")
  if (r === "idle") return t("cellular.registrationIdle", "Not registered")
  if (r === "emergency-only") return t("cellular.registrationEmergency", "Emergency calls only")
  return "--"
}

function formatAddress(bearer) {
  if (!bearer || !bearer.ipv4) return ""
  return bearer.prefix ? bearer.ipv4 + "/" + bearer.prefix : bearer.ipv4
}

function formatBytes(bytes, fmt) {
  var f = formatter(fmt)
  var n = Number(bytes)
  if (!isFinite(n) || n < 0) n = 0
  if (n < 1024) return f(Math.round(n)) + " B"
  if (n < 1024 * 1024) return f(n / 1024, 1) + " KB"
  if (n < 1024 * 1024 * 1024) return f(n / (1024 * 1024), 1) + " MB"
  return f(n / (1024 * 1024 * 1024), 2) + " GB"
}

// How long the bearer has been up, from its start date (epoch seconds).
function formatUptime(startDate, nowSeconds, tr, fmt) {
  var t = translator(tr)
  var f = formatter(fmt)
  var start = Number(startDate)
  var now = Number(nowSeconds)
  if (!isFinite(start) || start <= 0 || !isFinite(now)) return ""
  var minutes = Math.max(0, Math.floor((now - start) / 60))
  if (minutes < 60) return t("cellular.durationMinutes", "%1m").replace("%1", f(minutes))
  return t("cellular.durationHours", "%1h %2m").replace("%1", f(Math.floor(minutes / 60))).replace("%2", f(minutes % 60))
}

// Session counters from /sys/class/net/<iface>/statistics/{rx,tx}_bytes.
function parseCounter(raw) {
  var n = parseInt(String(raw || "").trim(), 10)
  return isFinite(n) && n >= 0 ? n : -1
}

if (typeof module !== "undefined") {
  module.exports = {
    LEVEL_COUNT: LEVEL_COUNT,
    parseKeyValue: parseKeyValue,
    parseBearers: parseBearers,
    parseStatus: parseStatus,
    primaryRouteInterface: primaryRouteInterface,
    signalLevel: signalLevel,
    classifyMonitorLine: classifyMonitorLine,
    techLabel: techLabel,
    isRoaming: isRoaming,
    presentation: presentation,
    registrationLabel: registrationLabel,
    formatAddress: formatAddress,
    formatBytes: formatBytes,
    formatUptime: formatUptime,
    parseCounter: parseCounter
  }
}
