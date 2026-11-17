// Pure helpers for NetworkVpn.qml, kept out of QML so Node can test them.
//
// A VPN is either a NetworkManager profile (VPN plugin or WireGuard), driven
// with nmcli, or Tailscale, which runs its own daemon and is driven with the
// tailscale CLI. Both become the same entries: { name, uuid, type, state }.

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

// tailscaled brings up its tun device as soon as it runs, whether or not
// Tailscale is connected, and NetworkManager lists it as an external
// connection. That is the cue to start asking tailscale itself.
function hasTailscaleDevice(raw) {
  var lines = String(raw || "").split(/\r?\n/)
  for (var i = 0; i < lines.length; i++) {
    var fields = splitTerse(lines[i])
    if (fields.length >= 3 && fields[0] === "tailscale0" && fields[2] === "tun") return true
  }
  return false
}

var tailscaleId = "tailscale"
var tailscaleStates = {
  Running: "activated",
  Starting: "activating",
  NeedsLogin: "login",
  NeedsMachineAuth: "login",
  Stopped: ""
}

// Reads `tailscale status --json` into the same shape as a NetworkManager
// profile, with the exit node the traffic goes through, if any. null when
// tailscaled has nothing to offer yet (no state, or output that isn't JSON).
function parseTailscaleStatus(raw) {
  var status
  try {
    status = JSON.parse(String(raw || ""))
  } catch (e) {
    return null
  }
  if (!status || !Object.prototype.hasOwnProperty.call(tailscaleStates, status.BackendState)) return null

  var exitNode = ""
  var peers = status.Peer || {}
  for (var key in peers) {
    var peer = peers[key]
    if (peer && peer.ExitNode) {
      exitNode = String(peer.HostName || String(peer.DNSName || "").split(".")[0] || "")
      break
    }
  }

  var state = tailscaleStates[status.BackendState]
  return { name: "Tailscale", uuid: tailscaleId, type: "tailscale", state: state, exitNode: state === "activated" ? exitNode : "" }
}

// `tailscale debug watch-ipn` prints each notification as indented JSON with
// every field present. Only a backend state change or a preference change
// (an exit node picked or dropped) can move what the panel shows.
function isTailscaleEvent(line) {
  return /^\s"(State|Prefs)": [^n]/.test(String(line || ""))
}

function withTailscale(connections, tailscale) {
  var list = Array.isArray(connections) ? connections.slice() : []
  if (tailscale) list.push(tailscale)
  list.sort(function(a, b) {
    var byName = a.name.localeCompare(b.name)
    return byName !== 0 ? byName : a.uuid.localeCompare(b.uuid)
  })
  return list
}

// The VPNs carrying this machine's traffic, which is what the bar's lock
// means. A profile counts once it is activated. Tailscale on its own only
// reaches the tailnet, so it counts only while an exit node carries the rest.
function activeVpnNames(connections) {
  var names = []
  var list = Array.isArray(connections) ? connections : []
  for (var i = 0; i < list.length; i++) {
    var connection = list[i]
    if (!connection || connection.state !== "activated") continue
    if (connection.type === "tailscale" && !connection.exitNode) continue
    names.push(connection.name)
  }
  return names
}

// A UUID is the only thing interpolated into the terminal command that asks
// for VPN secrets, so anything else is refused rather than quoted.
function isUuid(value) {
  return /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/.test(String(value || ""))
}

function isTailscale(id) {
  return id === tailscaleId
}

// tailscale refuses up/down from a user it doesn't know as its operator;
// granting that once (as Omarchy's Tailscale panel does) lets it run.
function needsOperator(stderr) {
  return /access denied|must be root|--operator/i.test(String(stderr || ""))
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
    hasTailscaleDevice: hasTailscaleDevice,
    parseTailscaleStatus: parseTailscaleStatus,
    isTailscaleEvent: isTailscaleEvent,
    withTailscale: withTailscale,
    activeVpnNames: activeVpnNames,
    isUuid: isUuid,
    isTailscale: isTailscale,
    needsOperator: needsOperator,
    needsSecrets: needsSecrets
  }
}
