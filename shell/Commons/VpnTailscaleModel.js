// Pure helpers for VpnTailscale.qml, kept out of QML so Node can test them.

var provider = "tailscale"
var id = "tailscale"
var device = "tailscale0"
// The bar widget that owns Tailscale: signing in, the operator grant, exit
// nodes and accounts all happen there, so the network panel's row opens it.
var widget = "omarchy.tailscale"

var states = {
  Running: "activated",
  Starting: "activating",
  NeedsLogin: "login",
  NeedsMachineAuth: "login",
  Stopped: ""
}

// Reads `tailscale status --json` into a VPN entry, with the exit node the
// traffic goes through, if any. null when tailscaled has nothing to offer yet
// (no state, or output that isn't JSON), which keeps the row away.
function parseStatus(raw) {
  var status
  try {
    status = JSON.parse(String(raw || ""))
  } catch (e) {
    return null
  }
  if (!status || !Object.prototype.hasOwnProperty.call(states, status.BackendState)) return null

  var exitNode = ""
  var peers = status.Peer || {}
  for (var key in peers) {
    var peer = peers[key]
    if (peer && peer.ExitNode) {
      exitNode = String(peer.HostName || String(peer.DNSName || "").split(".")[0] || "")
      break
    }
  }

  var state = states[status.BackendState]
  return {
    id: id,
    provider: provider,
    name: "Tailscale",
    type: "tailscale",
    state: state,
    exitNode: state === "activated" ? exitNode : "",
    opens: widget
  }
}

// `tailscale debug watch-ipn` prints each notification as indented JSON with
// every field present. Only a backend state change or a preference change
// (an exit node picked or dropped) can move what the row shows.
function isEvent(line) {
  return /^\s"(State|Prefs)": [^n]/.test(String(line || ""))
}

if (typeof module !== "undefined") {
  module.exports = {
    provider: provider,
    id: id,
    device: device,
    widget: widget,
    parseStatus: parseStatus,
    isEvent: isEvent
  }
}
