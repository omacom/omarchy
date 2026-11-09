// Display numbers go through the shell's I18n.formatNumber when QML passes
// it; Node tests leave it out and get plain English digits.
function formatter(fmt) {
  return typeof fmt === "function" ? fmt : function(v, d) { return d === undefined ? String(v) : Number(v).toFixed(d) }
}

function parseNetworkStatus(raw) {
  var parts = String(raw || "disconnected\t\t\t").replace(/\r?\n+$/, "").split("\t")
  return {
    kind: parts[0] || "disconnected",
    label: parts[1] || "",
    signalStrength: parts[2] ? parseInt(parts[2], 10) : -1,
    frequency: parts[3] || ""
  }
}

// NetworkManager turns dBm into its 0-100 strength with two formulas: scan
// results map -100..-40 dBm linearly onto 0..100, and the connected access
// point's station refresh uses dBm + 120 (floor 30 at -90 dBm). The same link
// reads 83 after a scan and 70 between scans at -50 dBm. The two only meet at
// -70 dBm, so every cut-off leaves a few dB where they disagree; these keep
// those bands to about 4 dB: full from -60 dBm (-64 for scan results), three
// from -70, two from -80 (-76), one down to about -90.
function wifiIconFor(strength) {
  var icons = ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]
  var index = strength >= 60 ? 4 : strength >= 50 ? 3 : strength >= 40 ? 2 : strength >= 15 ? 1 : 0
  return icons[index]
}

// The connected network's own strength comes from the access points
// Quickshell grouped under its SSID. When it has none (an OWE transition-mode
// network between scans files the in-use access point under its hidden
// "_owetm_" twin), fall back to the strength NetworkManager reports for the
// access point in use.
function connectedSignalStrength(networkStrength, activeApSignal) {
  var strength = Math.round((networkStrength || 0) * 100)
  if (strength > 0) return strength
  return activeApSignal > 0 ? activeApSignal : strength
}

// Reads `nmcli -t -f IN-USE,SIGNAL device wifi list` output, where the in-use
// access point is the row marked "*".
function parseActiveApSignal(raw) {
  var lines = String(raw || "").split(/\r?\n/)
  for (var i = 0; i < lines.length; i++) {
    var match = /^\*:(\d+)$/.exec(lines[i].trim())
    if (match) return parseInt(match[1], 10)
  }
  return -1
}

// A known plain-HTTP endpoint lets the network redirect the browser to its
// login page. Never execute or automatically open an untrusted Location header.
var captivePortalUrl = "http://ping.omacom.io/nm-check.txt"

function connectivityState(kind, connectivity, states, checksEnabled) {
  if (kind === "disconnected") return "none"
  // Ignore stale cached results when the operator has disabled probing.
  if (!checksEnabled) return "unknown"
  if (connectivity === states.Portal) return "portal"
  if (connectivity === states.Limited) return "limited"
  if (connectivity === states.Full) return "full"
  if (connectivity === states.None) return "none"
  return "unknown"
}

function connectionIcon(kind, signalStrength, connectivity) {
  var restricted = connectivity === "portal" || connectivity === "limited"
  if (kind === "wifi") return restricted ? "󰤩" : wifiIconFor(signalStrength)
  if (kind === "ethernet") return restricted ? "󰈂" : "󰈀"
  return "󰤮"
}

function formatHeaderSpeed(mbps, fmt) {
  var f = formatter(fmt)
  var v = parseInt(mbps, 10)
  if (!v || v < 0) return ""
  if (v >= 1000) return f(v / 1000, v % 1000 === 0 ? 0 : 1) + "gbit"
  return f(v) + "mbit"
}

function formatHeaderFreq(mhz, fmt) {
  var f = formatter(fmt)
  var v = parseFloat(mhz)
  if (!v) return ""

  if (v >= 2400 && v < 2500) return f(2.4) + "ghz"
  if (v >= 4900 && v < 5925) return f(5) + "ghz"
  if (v >= 5925 && v < 7125) return f(6) + "ghz"
  if (v >= 57000 && v < 71000) return f(60) + "ghz"

  var ghz = v / 1000
  return f(ghz, ghz % 1 === 0 ? 0 : 1) + "ghz"
}

// Wi-Fi band state belongs in the selector section, not beside the hero name.
// Ethernet has no equivalent selector, so keep its negotiated link speed here.
function headerDetail(info, fmt) {
  var value = info || {}
  if (value.type === "ethernet") return formatHeaderSpeed(value.speed || "", fmt)
  return ""
}

function bandLabel(band, tr, fmt) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  if (band === "auto") return t("network.bandAuto", "Auto")
  if (!band) return ""
  // The band stays the script's "2.4" everywhere else; only the label is
  // written in the language's digits.
  var number = Number(band)
  return (isFinite(number) ? formatter(fmt)(number) : band) + "ghz"
}

// Under Automatic the pills are hidden, so the header carries the live band
// instead -- "WI-FI BAND: 2.4GHZ". Once a band is pinned the pills are on
// screen and say it themselves, so the header drops back to a plain label.
function bandSectionTitle(selected, current, tr, fmt) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  if (selected !== "auto") return t("network.wifiBand", "WI-FI BAND")

  var label = bandLabel(current, tr, fmt)
  if (label === "") return t("network.wifiBand", "WI-FI BAND")

  return t("network.wifiBandCurrent", "WI-FI BAND: %1").replace("%1", label.toUpperCase())
}

function bandTooltip(band, tr, fmt) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  if (band === "auto") return t("network.bandAutoTooltip", "Let Wi-Fi pick the band")
  if (!band) return ""
  return t("network.stayOnBand", "Stay on %1").replace("%1", bandLabel(band, tr, fmt))
}

function parseBandStatus(raw) {
  var next = parseKeyValue(raw)
  var tokens = String(next.available || "").split(" ")
  var available = []

  for (var i = 0; i < tokens.length; i++) {
    if (tokens[i] !== "") available.push(tokens[i])
  }

  return {
    band: next.band || "",
    selected: next.selected || "auto",
    available: available
  }
}

function decodeIwSsid(value) {
  var raw = String(value || "")

  try {
    var encoded = ""

    for (var i = 0; i < raw.length; i++) {
      if (raw[i] === "\\" && raw[i + 1] === "x" && /^[0-9a-f]{2}$/i.test(raw.substring(i + 2, i + 4))) {
        var hex = raw.substring(i + 2, i + 4)
        var byte = parseInt(hex, 16)
        encoded += byte < 32 || byte === 127 ? encodeURIComponent(raw.substring(i, i + 4)) : "%" + hex
        i += 3
      } else {
        encoded += encodeURIComponent(raw[i])
      }
    }

    return decodeURIComponent(encoded)
  } catch (error) {
    return raw
  }
}

function parseKeyValue(raw) {
  var next = {}
  var lines = String(raw || "").split("\n")
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i]
    if (!line) continue
    var idx = line.indexOf("\t")
    if (idx === -1) continue
    var key = line.substring(0, idx)
    var value = line.substring(idx + 1)
    next[key] = key === "ssid" ? decodeIwSsid(value) : value.trim()
  }
  return next
}

function throughputState(previous, next, now) {
  var prev = previous || {}
  var sample = next || {}
  var iface = sample.iface || ""
  var rx = parseFloat(sample.rx_bytes || "0")
  var tx = parseFloat(sample.tx_bytes || "0")
  var previousTime = Number(prev.prevSampleTime || 0)

  if (iface !== (prev.prevIface || "") || previousTime === 0) {
    return {
      prevIface: iface,
      prevRxBytes: rx,
      prevTxBytes: tx,
      prevSampleTime: now,
      downloadRate: 0,
      uploadRate: 0
    }
  }

  var downloadRate = Number(prev.downloadRate || 0)
  var uploadRate = Number(prev.uploadRate || 0)
  var dt = now - previousTime
  if (dt > 0) {
    downloadRate = Math.max(0, (rx - Number(prev.prevRxBytes || 0)) / dt)
    uploadRate = Math.max(0, (tx - Number(prev.prevTxBytes || 0)) / dt)
  }

  return {
    prevIface: iface,
    prevRxBytes: rx,
    prevTxBytes: tx,
    prevSampleTime: now,
    downloadRate: downloadRate,
    uploadRate: uploadRate
  }
}

function pingSampleValue(raw) {
  var value = parseFloat(raw)
  if (!isFinite(value) || value < 0) return null
  return value
}

function appendPingSample(samples, raw, limit) {
  var values = Array.isArray(samples) ? samples.slice() : []

  values.push(pingSampleValue(raw))
  while (values.length > limit) values.shift()

  return values
}

function averagePingLatency(samples, limit) {
  var values = Array.isArray(samples) ? samples : []
  var sampleLimit = Math.max(1, parseInt(limit, 10) || values.length || 1)
  var total = 0
  var count = 0

  for (var i = Math.max(0, values.length - sampleLimit); i < values.length; i++) {
    var value = values[i]
    if (typeof value !== "number" || !isFinite(value) || value < 0) continue
    total += value
    count++
  }

  return count > 0 ? total / count : -1
}

function pingPacketLossPercent(samples) {
  var values = Array.isArray(samples) ? samples : []
  if (values.length === 0) return 0

  var lost = 0
  for (var i = 0; i < values.length; i++) {
    if (values[i] === null) lost++
  }

  return Math.round((lost / values.length) * 100)
}

// Ping and loss only mean something once the internet is reachable. Behind a
// portal, on a limited link or offline every probe is lost by design, so the
// rows read "--" instead of a "Timeout" and "100%" that just restate that.
function internetPingReadable(samples, connectivity) {
  var values = Array.isArray(samples) ? samples : []
  if (connectivity === "portal" || connectivity === "limited" || connectivity === "none") return false
  return values.length > 0
}

function formatPacketLoss(percent, hasSamples, fmt) {
  var f = formatter(fmt)
  if (hasSamples === false) return "--"

  var value = parseInt(percent, 10)
  if (!value || value < 0) return f(0) + "%"
  return f(value) + "%"
}

function pingLatencyState(previous, next, limit, averageLimit) {
  var prev = previous || {}
  var sample = next || {}
  var iface = sample.iface || ""
  var window = Math.max(1, parseInt(limit, 10) || 5)
  var averageWindow = Math.max(1, parseInt(averageLimit, 10) || window)
  var reset = iface === "" || iface !== (prev.pingIface || "")
  var routerSamples = reset ? [] : prev.routerPingSamples
  var internetSamples = reset ? [] : prev.internetPingSamples

  routerSamples = sample.router_ping_ms === undefined ? [] : appendPingSample(routerSamples, sample.router_ping_ms, window)
  internetSamples = sample.internet_ping_ms === undefined ? [] : appendPingSample(internetSamples, sample.internet_ping_ms, window)

  return {
    pingIface: iface,
    routerPingSamples: routerSamples,
    internetPingSamples: internetSamples,
    routerPingLatency: averagePingLatency(routerSamples, averageWindow),
    internetPingLatency: averagePingLatency(internetSamples, averageWindow),
    internetPingPacketLoss: pingPacketLossPercent(internetSamples)
  }
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

function formatRate(bytesPerSec, fmt) {
  return formatBytes(bytesPerSec, fmt) + "/s"
}

// `hasSamples` false means no probe has come back yet, which is different from
// a probe that timed out. The rows stay mounted through that gap and read "--"
// so the grid doesn't reflow a second after the panel opens.
function formatPingLatency(ms, hasSamples, tr, fmt) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  var f = formatter(fmt)
  if (hasSamples === false) return "--"

  var value = parseFloat(ms)
  if (!isFinite(value) || value < 0) return t("network.timeout", "Timeout")
  return f(value, value > 0 && value < 10 ? 1 : 0) + " ms"
}

function wifiRow(network) {
  if (!network) return null
  // Primitives only: rows become list-model data, so a WifiNetwork here puts a
  // live QObject wrapper in every delegate's var property. NetworkManager churn
  // (scans, AP removals) can destroy the object while a delegate is still
  // incubating, which segfaults quickshell in wrap_slowPath on the dangling
  // wrapper. Callers that need the object resolve it via networkForSsid().
  return {
    connected: !!network.connected,
    known: !!network.known,
    ssid: network.name || "",
    signal: Math.round((network.signalStrength || 0) * 100),
    security: network.security
  }
}

function sortWifiRows(rows) {
  var nets = Array.isArray(rows) ? rows.slice() : []
  nets.sort(function(a, b) {
    if (a.connected !== b.connected) return a.connected ? -1 : 1
    if (a.known !== b.known) return a.known ? -1 : 1
    return b.signal - a.signal
  })
  return nets
}

function wifiSectionTitle(wifiNetworks, index, tr) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  var networks = Array.isArray(wifiNetworks) ? wifiNetworks : []
  if (index < 0 || index >= networks.length) return ""

  var net = networks[index]
  if (!net) return ""

  if (net.known && index === 0) return t("network.knownNetworks", "KNOWN NETWORKS")
  if (!net.known && (index === 0 || (networks[index - 1] && networks[index - 1].known))) return t("network.otherNetworks", "OTHER NETWORKS")
  return ""
}

// OWE (Enhanced Open) encrypts traffic without authenticating the user, so it
// has no credentials to collect. The panel's lock is a credentials-required
// affordance, so OWE should neither show it nor open its attached prompt.
function requiresCredentials(security, openSecurity, oweSecurity) {
  // Only explicit passwordless types bypass the prompt. Unknown security
  // stays credentialed as the conservative fallback.
  return security !== openSecurity && security !== oweSecurity
}

function canForgetNetwork(network) {
  return !!(network && network.known && !network.connected)
}

// The password arrives on stdin and reaches nmcli through the scriptable
// `connection edit` editor -- argv is world-readable in /proc, so the secret
// must never be an argument (printf is a bash builtin, so no process spawns
// with it either).
var enterpriseConnectScript =
  "u=$(uuidgen); IFS= read -r pw;" +
  " nmcli connection add type wifi con-name \"$1\" ssid \"$1\" connection.uuid \"$u\"" +
  " wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2" +
  " 802-1x.identity \"$2\" 802-1x.auth-timeout 8 >/dev/null" +
  " && printf 'set 802-1x.password\\n%s\\nsave\\nquit\\n' \"$pw\" | nmcli connection edit uuid \"$u\" >/dev/null" +
  " && nmcli connection up uuid \"$u\"" +
  " || { nmcli connection delete uuid \"$u\" >/dev/null 2>&1; false; }"

function networkFailureReason(reason, needsCredentials, reasons, tr) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  var r = reasons || {}
  if (needsCredentials && reason === r.NoSecrets) return t("network.passphraseRequired", "Passphrase required")
  if (needsCredentials && reason === r.WifiAuthTimeout) return t("network.wrongPassword", "Wrong password")
  if (reason === r.WifiNetworkLost) return t("network.networkLost", "Network lost")
  if (reason === r.WifiClientDisconnected) return t("network.disconnected", "Disconnected")
  if (reason === r.WifiClientFailed) return t("network.connectionFailed", "Connection failed")
  return t("network.failedToConnect", "Failed to connect")
}

// Whether a failed connect should reopen the passphrase prompt. NoSecrets
// means credentials are missing only for a network that actually uses them.
// An auth timeout on such a network means the saved passphrase is wrong (the
// same profile a first failed attempt leaves behind as "known"), so the user
// needs a chance to re-enter it -- connectWithPsk overwrites the stored PSK on
// submit.
function shouldRepromptPassphrase(reason, needsCredentials, reasons) {
  var r = reasons || {}
  if (!needsCredentials) return false
  return reason === r.NoSecrets || reason === r.WifiAuthTimeout
}

// `nmcli -t` escapes a literal '\' inside a field as '\\' and a literal ':' as
// '\:'. Decoding '\\' before '\:' matters: a backslash that precedes a colon
// must be read first, or the pair would look like the start of a colon escape.
function decodeNmcliEscapes(value) {
  var raw = String(value || "")
  var out = ""
  for (var i = 0; i < raw.length; i++) {
    if (raw[i] === "\\") {
      var next = raw[i + 1]
      if (next === "\\") { out += "\\"; i++; continue }
      if (next === ":") { out += ":"; i++; continue }
    }
    out += raw[i]
  }
  return out
}

// Splits one `nmcli -t` row on its unescaped ':' separators -- a colon preceded
// by an even number of backslashes -- then decodes every field with
// decodeNmcliEscapes, the same decoder the key/value parser uses.
function splitNmcliFields(line) {
  var fields = [], current = "", backslashes = 0
  for (var i = 0; i < line.length; i++) {
    var ch = line[i]
    if (ch === ":") {
      if (backslashes % 2 === 0) {
        fields.push(decodeNmcliEscapes(current))
        current = ""
      } else {
        current += ch
      }
      backslashes = 0
      continue
    }
    if (ch === "\\") { backslashes++; current += ch; continue }
    backslashes = 0
    current += ch
  }
  fields.push(decodeNmcliEscapes(current))
  return fields
}

// Reads `nmcli -t -f NAME,UUID,ACTIVE,802-11-wireless.ssid connection show`,
// one row per saved profile. Names are user-controlled and can repeat, so the
// UUID is what the callers key on, never the name; the saved SSID is the field
// that actually names the network a profile connects to.
function parseNmcliConnections(output) {
  var lines = String(output || "").split("\n")
  var out = []
  for (var i = 0; i < lines.length; i++) {
    if (lines[i] === "") continue
    var f = splitNmcliFields(lines[i])
    out.push({ name: f[0] || "", uuid: f[1] || "", active: (f[2] || "") === "yes", ssid: f[3] || "" })
  }
  return out
}

// A profile's network is its saved 802-11-wireless.ssid, not the user-editable
// connection name. Match the SSID; a profile with none (legacy or non-Wi-Fi)
// falls back to its name.
function profileMatchesSsid(profile, ssid) {
  if (!profile) return false
  if (profile.ssid) return profile.ssid === ssid
  return profile.name === ssid
}

// Several saved profiles can share one SSID (e.g. a WPA2 and a WPA3 copy), so a
// name match is not enough to pick one. When the SSID is the connected network,
// its active profile is the right one; otherwise a lone match stands and
// duplicates are flagged so the caller can ask the user instead of guessing.
function resolveProfile(profiles, ssid, connected) {
  var matches = []
  for (var i = 0; i < (profiles || []).length; i++) {
    if (profileMatchesSsid(profiles[i], ssid)) matches.push(profiles[i])
  }
  if (matches.length === 0) return { uuid: "", ambiguous: false }
  if (connected) {
    for (var j = 0; j < matches.length; j++) {
      if (matches[j].active) return { uuid: matches[j].uuid, ambiguous: false }
    }
  }
  if (matches.length === 1) return { uuid: matches[0].uuid, ambiguous: false }
  return { uuid: matches[0].uuid, ambiguous: true }
}

// `nmcli -t -f UUID connection show --active` prints one bare UUID per line. The
// save path re-reads it to confirm the profile it is about to cycle is still the
// connection in use.
function parseActiveUuids(output) {
  var lines = String(output || "").split(/\r?\n/)
  var out = []
  for (var i = 0; i < lines.length; i++) {
    var uuid = lines[i].trim()
    if (uuid !== "") out.push(uuid)
  }
  return out
}

// The settings editor reads one saved profile back with
// `nmcli -t -f <settings> connection show uuid <uuid>`. `-t` still puts a ':'
// between the key and its value, and NetworkManager prints a stored secret as
// the literal `<hidden>` rather than echoing it, so the editor never treats
// that as a value it can keep.
function parseNmcliProfile(output) {
  var lines = String(output || "").split("\n")
  var out = {}
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i]
    if (line === "") continue
    var idx = line.indexOf(":")
    if (idx === -1) continue
    var value = decodeNmcliEscapes(line.substring(idx + 1))
    out[line.substring(0, idx)] = value === "<hidden>" ? "" : value
  }
  return out
}

// Which security types carry a pre-shared key. The editor offers a password
// field with a "keep the saved one" affordance only for these; on EAP the same
// `psk` setting is unused, so its `<hidden>` echo means nothing.
function usesPsk(security, securityEnum) {
  var e = securityEnum || {}
  return security === e.Wpa2Psk || security === e.WpaPsk || security === e.Sae
}

// Seeds the editor from a parsed profile. Values a profile leaves unset read
// back as "", and the caller supplies the security enum because only it knows
// the constants, which keeps this pure and testable. `hasPsk` is decided by the
// security type alone: nmcli prints the stored psk as `<hidden>` (parseNmcliProfile
// blanks it), so it can never be read here. Offering the field by type, with a
// blank meaning "keep the current one", is the only way to let a PSK/SAE network
// be edited at all.
function editorDefaults(settings, security, securityEnum) {
  var s = settings || {}
  var priority = parseInt(s["connection.autoconnect-priority"], 10)
  return {
    autoConnect: s["connection.autoconnect"] === "yes",
    priority: isFinite(priority) ? priority : 0,
    metered: s["connection.metered"] || "unknown",
    ipv4Method: s["ipv4.method"] || "auto",
    address: s["ipv4.addresses"] || "",
    gateway: s["ipv4.gateway"] || "",
    identity: s["802-1x.identity"] || "",
    hasPsk: usesPsk(security, securityEnum)
  }
}

// Dotted-quad with every octet in 0-255. A shape-only test lets an impossible
// address like 999.1.1.1 through to nmcli; this rejects each octet over 255.
function isValidIPv4(value) {
  var parts = String(value || "").split(".")
  if (parts.length !== 4) return false
  for (var i = 0; i < 4; i++) {
    if (!/^\d{1,3}$/.test(parts[i])) return false
    var octet = Number(parts[i])
    if (octet < 0 || octet > 255) return false
  }
  return true
}

// CIDR host with a 0-32 prefix. The prefix bounded here is what keeps
// 10.0.0.1/33 and 999.1.1.1/99 from writing a broken profile.
function isValidCidr(value) {
  var parts = String(value || "").split("/")
  if (parts.length !== 2) return false
  if (!/^\d{1,2}$/.test(parts[1])) return false
  var prefix = Number(parts[1])
  return isValidIPv4(parts[0]) && prefix >= 0 && prefix <= 32
}

// Manual IPv4 needs an address with a prefix, and a gateway only when one is
// given. Priority has to be a whole number of 0 or more because nmcli rejects
// anything else. `error` is the message the editor shows under the field;
// `tr` is the shell's I18n.t, so the copy translates like every other string
// while the default keeps the Node tests in English.
function validateEditor(form, tr) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  var f = form || {}
  var priority = f.priority === undefined || f.priority === "" ? 0 : Number(f.priority)
  if (!isFinite(priority) || priority < 0 || Math.floor(priority) !== priority) {
    return { ok: false, error: t("network.priorityInvalid", "Priority must be a whole number of 0 or more.") }
  }
  if (f.ipv4Method === "manual") {
    if (!isValidCidr(f.address)) {
      return { ok: false, error: t("network.addressInvalid", "Enter an address with a prefix, like 10.0.0.5/24.") }
    }
    if (f.gateway && !isValidIPv4(f.gateway)) {
      return { ok: false, error: t("network.gatewayInvalid", "Enter a valid gateway address.") }
    }
  }
  return { ok: true, error: "" }
}

// Builds the stdin `nmcli connection edit` needs to set one property. The
// value is written on its own line under a bare `set <setting>.<property>`,
// which takes nmcli's interactive "Enter '<prop>' value:" path. That path
// reads the raw line and keeps every character. The one-line
// `set <setting>.<property> <value>` form cannot: NetworkManager's
// split_editor_main_cmd_args runs the whole line through g_strstrip and takes
// the remainder verbatim, so leading/trailing spaces are lost, an empty value
// is stripped away (making nmcli prompt and swallow the next command), and
// quotes are never unescaped -- a quoted value stores the quote characters.
// Verified against nmcli 1.58.1. The value stays off argv, and any embedded
// newline is flattened so it cannot inject a second editor command.
function nmcliEditSet(property, value) {
  var text = value === undefined || value === null ? "" : String(value)
  return "set " + property + "\n" + text.replace(/[\r\n]+/g, " ") + "\n"
}

// The editable settings, in the order nmcli receives them. `kind` decides how a
// form value becomes an argument: a boolean is nmcli's yes/no, an int prints as
// a number. One list keeps the argv builder, the reapply check and any future
// field agreed on the setting names.
var MOD_KEYS = [
  ["autoConnect", "connection.autoconnect", "bool"],
  ["priority", "connection.autoconnect-priority", "int"],
  ["metered", "connection.metered", "str"],
  ["ipv4Method", "ipv4.method", "str"],
  ["address", "ipv4.addresses", "str"],
  ["gateway", "ipv4.gateway", "str"]
]

function modArgValue(kind, value) {
  if (kind === "bool") return value ? "yes" : "no"
  if (kind === "int") {
    var n = parseInt(value, 10)
    return String(isFinite(n) ? n : 0)
  }
  return value === undefined || value === null ? "" : String(value)
}

// Builds `nmcli connection modify uuid <uuid> ...` for the settings that
// actually changed. Keying on the uuid (never the SSID, which can repeat) and
// emitting only the edited fields keeps the command from rewriting untouched
// settings; no secret is ever among them, so argv stays safe in /proc. An
// unchanged form yields an empty array, which the caller runs as a no-op.
function changedModArgs(uuid, before, after) {
  var b = before || {}
  var a = after || {}
  var args = []
  for (var i = 0; i < MOD_KEYS.length; i++) {
    var field = MOD_KEYS[i][0]
    var setting = MOD_KEYS[i][1]
    var kind = MOD_KEYS[i][2]
    var from = modArgValue(kind, b[field])
    var to = modArgValue(kind, a[field])
    if (from === to) continue
    args.push(setting, to)
  }
  if (args.length === 0) return []
  return ["nmcli", "connection", "modify", "uuid", String(uuid)].concat(args)
}

// An address, method or gateway change only takes effect on the next
// activation, so the caller must cycle the connection; auto-connect, priority
// and metered apply live and need no reconnect.
function needsReapply(before, after) {
  var b = before || {}
  var a = after || {}
  for (var i = 0; i < MOD_KEYS.length; i++) {
    if (MOD_KEYS[i][1].indexOf("ipv4.") !== 0) continue
    var field = MOD_KEYS[i][0]
    if (modArgValue(MOD_KEYS[i][2], b[field]) !== modArgValue(MOD_KEYS[i][2], a[field])) return true
  }
  return false
}

if (typeof module !== "undefined") {
  module.exports = {
    parseNetworkStatus: parseNetworkStatus,
    wifiIconFor: wifiIconFor,
    connectionIcon: connectionIcon,
    connectedSignalStrength: connectedSignalStrength,
    parseActiveApSignal: parseActiveApSignal,
    connectivityState: connectivityState,
    captivePortalUrl: captivePortalUrl,
    formatHeaderSpeed: formatHeaderSpeed,
    formatHeaderFreq: formatHeaderFreq,
    headerDetail: headerDetail,
    bandLabel: bandLabel,
    bandSectionTitle: bandSectionTitle,
    bandTooltip: bandTooltip,
    parseBandStatus: parseBandStatus,
    decodeIwSsid: decodeIwSsid,
    parseKeyValue: parseKeyValue,
    throughputState: throughputState,
    pingLatencyState: pingLatencyState,
    pingPacketLossPercent: pingPacketLossPercent,
    internetPingReadable: internetPingReadable,
    formatPacketLoss: formatPacketLoss,
    formatBytes: formatBytes,
    formatRate: formatRate,
    formatPingLatency: formatPingLatency,
    wifiRow: wifiRow,
    sortWifiRows: sortWifiRows,
    wifiSectionTitle: wifiSectionTitle,
    requiresCredentials: requiresCredentials,
    canForgetNetwork: canForgetNetwork,
    parseNmcliConnections: parseNmcliConnections,
    profileMatchesSsid: profileMatchesSsid,
    resolveProfile: resolveProfile,
    parseActiveUuids: parseActiveUuids,
    parseNmcliProfile: parseNmcliProfile,
    editorDefaults: editorDefaults,
    validateEditor: validateEditor,
    nmcliEditSet: nmcliEditSet,
    changedModArgs: changedModArgs,
    needsReapply: needsReapply,
    enterpriseConnectScript: enterpriseConnectScript,
    networkFailureReason: networkFailureReason,
    shouldRepromptPassphrase: shouldRepromptPassphrase
  }
}
