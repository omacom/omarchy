// Pure helpers for NetworkVpn.qml, kept out of QML so Node can test them.

var vpnTypes = { vpn: true, wireguard: true }

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
// and WireGuard profiles, in name order so a row never jumps when its state
// changes. STATE is empty for a profile that is not active.
function parseVpnConnections(raw) {
  var lines = String(raw || "").split(/\r?\n/)
  var connections = []

  for (var i = 0; i < lines.length; i++) {
    if (!lines[i]) continue
    var fields = splitTerse(lines[i])
    if (fields.length < 4 || !vpnTypes[fields[2]]) continue
    connections.push({ name: fields[0], uuid: fields[1], type: fields[2], state: fields[3] })
  }

  connections.sort(function(a, b) {
    var byName = a.name.localeCompare(b.name)
    return byName !== 0 ? byName : a.uuid.localeCompare(b.uuid)
  })
  return connections
}

function activeVpnNames(connections) {
  var names = []
  var list = Array.isArray(connections) ? connections : []
  for (var i = 0; i < list.length; i++) {
    if (list[i] && list[i].state === "activated") names.push(list[i].name)
  }
  return names
}

// A UUID is the only thing interpolated into the terminal command that asks
// for VPN secrets, so anything else is refused rather than quoted.
function isUuid(value) {
  return /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/.test(String(value || ""))
}

// nmcli fails this way when the profile keeps its password with a secret
// agent and none answered: there is no prompt to show from the shell, so the
// connect moves to a terminal where `nmcli --ask` can ask for it.
function needsSecrets(stderr) {
  return /Secrets were required|secrets? .*not provided|nmcli cannot ask without '--ask'/i.test(String(stderr || ""))
}

if (typeof module !== "undefined") {
  module.exports = {
    splitTerse: splitTerse,
    parseVpnConnections: parseVpnConnections,
    activeVpnNames: activeVpnNames,
    isUuid: isUuid,
    needsSecrets: needsSecrets
  }
}
