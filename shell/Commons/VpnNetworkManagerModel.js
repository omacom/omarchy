// Pure helpers for VpnNetworkManager.qml, kept out of QML so Node can test
// them: reading NetworkManager's VPN and WireGuard profiles out of nmcli, and
// working out which credentials a profile needs before it can connect.

var vpnTypes = { vpn: true, wireguard: true }
var provider = "networkmanager"

// Splits one line of `nmcli -t` output. Terse mode escapes a ":" inside a
// value as "\:" and a backslash as "\\", so a profile named "Office: VPN"
// must not be cut in two.
function splitTerse(line) {
  var fields = []
  var field = ""
  var value = String(line || "")

  for (var i = 0; i < value.length; i++) {
    var ch = value[i]
    if (ch === "\\" && i + 1 < value.length) {
      field += value[++i]
    } else if (ch === ":") {
      fields.push(field)
      field = ""
    } else {
      field += ch
    }
  }
  fields.push(field)
  return fields
}

// Reads `nmcli -t -f NAME,UUID,TYPE,STATE connection show` and keeps the VPN
// and WireGuard profiles. STATE is empty for a profile that is not active.
function parseVpnConnections(raw) {
  var lines = String(raw || "").split(/\r?\n/)
  var connections = []

  for (var i = 0; i < lines.length; i++) {
    if (!lines[i]) continue
    var fields = splitTerse(lines[i])
    if (fields.length < 4 || !vpnTypes[fields[2]] || !isUuid(fields[1])) continue
    connections.push({ id: fields[1], provider: provider, name: fields[0], type: fields[2], state: fields[3] })
  }
  return connections
}

// Whether the same listing has a device of this name and type, which is how
// another VPN's daemon shows up to NetworkManager (tailscaled's tun device).
function hasDevice(raw, name, type) {
  var lines = String(raw || "").split(/\r?\n/)
  for (var i = 0; i < lines.length; i++) {
    var fields = splitTerse(lines[i])
    if (fields.length >= 3 && fields[0] === name && fields[2] === type) return true
  }
  return false
}

// Reads `nmcli -g vpn.service-type,vpn.data connection show uuid <uuid>`:
// the plugin on the first line, and its settings on the second as
// "key = value, key = value". -g escapes ":" and "\" as nmcli -t does, and a
// "," inside a value was already escaped as "\," underneath that.
function parseVpnDetails(raw) {
  var lines = String(raw || "").split(/\r?\n/)
  var serviceType = String(lines[0] || "").trim()
  var data = {}
  var text = splitTerse(lines[1] || "").join(":")

  var items = []
  var item = ""
  for (var i = 0; i < text.length; i++) {
    var ch = text[i]
    if (ch === "\\" && i + 1 < text.length) {
      item += text[++i]
    } else if (ch === ",") {
      items.push(item)
      item = ""
    } else {
      item += ch
    }
  }
  items.push(item)

  for (var j = 0; j < items.length; j++) {
    var separator = items[j].indexOf(" = ")
    if (separator < 0) continue
    var key = items[j].substring(0, separator).trim()
    if (key !== "") data[key] = items[j].substring(separator + 3)
  }
  return { serviceType: serviceType, data: data }
}

// The user name and password each VPN plugin keeps, by the keys its own
// editor uses: the name lives in the profile's data, the password is the
// named secret. Only the plugins whose sign-in is a name and a password are
// here; anything else (certificates, web sign-ins) asks through a terminal.
function passwordPlugin(userKey, secretKey) {
  return function() { return { userKey: userKey, secretKey: secretKey, flagsKey: secretKey + "-flags" } }
}

var credentialPlugins = {
  "org.freedesktop.NetworkManager.openvpn": function(data) {
    var type = data["connection-type"] || "tls"
    if (type !== "password" && type !== "password-tls") return null
    return { userKey: "username", secretKey: "password", flagsKey: "password-flags" }
  },
  "org.freedesktop.NetworkManager.l2tp": passwordPlugin("user", "password"),
  "org.freedesktop.NetworkManager.pptp": passwordPlugin("user", "password"),
  "org.freedesktop.NetworkManager.sstp": passwordPlugin("user", "password"),
  "org.freedesktop.NetworkManager.fortisslvpn": passwordPlugin("user", "password"),
  "org.freedesktop.NetworkManager.vpnc": passwordPlugin("Xauth username", "Xauth password"),
  "org.freedesktop.NetworkManager.strongswan": function(data) {
    if (data.method !== "eap" && data.method !== "psk") return null
    return { userKey: "user", secretKey: "password", flagsKey: "password-flags" }
  }
}

// NMSettingSecretFlags: the password is kept by an agent, asked every time,
// or not needed at all.
var secretAgentOwned = 1
var secretNotSaved = 2
var secretNotRequired = 4

// How a profile signs in: { userKey, secretKey, username, askFirst }, or null
// when it needs no name and password (WireGuard, certificates) or uses a
// plugin this doesn't know. askFirst is set when connecting cannot work
// without asking: no user name yet, or a password that is never kept.
function credentialPlan(details) {
  var serviceType = details && details.serviceType
  var data = (details && details.data) || {}
  var plugin = credentialPlugins[serviceType]
  var keys = plugin ? plugin(data) : null
  if (!keys) return null

  var flags = parseInt(data[keys.flagsKey] || "0", 10) || 0
  if (flags & secretNotRequired) return null
  var username = String(data[keys.userKey] || "")
  return {
    userKey: keys.userKey,
    secretKey: keys.secretKey,
    username: username,
    askFirst: username === "" || (flags & secretNotSaved) !== 0
  }
}

// One vpn.data item for `nmcli connection modify +vpn.data`, which splits
// items on "," and takes "\" as its escape.
function vpnDataItem(key, value) {
  return key + "=" + String(value || "").replace(/\\/g, "\\\\").replace(/,/g, "\\,")
}

// Connects with the name and password from the panel. The password arrives
// on stdin and reaches nmcli as a passwd-file through process substitution:
// argv is world-readable in /proc, so it is never an argument, and printf is a
// bash builtin, so no process is started with it either. A changed user name
// is saved to the profile first, as the plugin's own editor would.
// Arguments: uuid, secret key, then the vpn.data item to save, or "".
var connectScript =
  "IFS= read -r pw;" +
  " if [ -n \"$3\" ]; then nmcli connection modify uuid \"$1\" +vpn.data \"$3\" || exit; fi;" +
  " nmcli connection up uuid \"$1\" passwd-file <(printf 'vpn.secrets.%s:%s\\n' \"$2\" \"$pw\")"

// The UUID is the only thing interpolated into the terminal command that asks
// for secrets nothing else can, so anything else is refused rather than
// quoted.
function isUuid(value) {
  return /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/.test(String(value || ""))
}

// nmcli fails this way when the profile's secrets were asked for and nothing
// answered with them.
function needsSecrets(stderr) {
  return /Secrets were required|secrets? .*not provided|nmcli cannot ask without '--ask'/i.test(String(stderr || ""))
}

if (typeof module !== "undefined") {
  module.exports = {
    provider: provider,
    splitTerse: splitTerse,
    parseVpnConnections: parseVpnConnections,
    hasDevice: hasDevice,
    parseVpnDetails: parseVpnDetails,
    credentialPlan: credentialPlan,
    vpnDataItem: vpnDataItem,
    connectScript: connectScript,
    isUuid: isUuid,
    needsSecrets: needsSecrets
  }
}
