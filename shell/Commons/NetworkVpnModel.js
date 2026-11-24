// Pure helpers for NetworkVpn.qml, kept out of QML so Node can test them.
//
// Every VPN the machine has comes from a provider (see NetworkVpn.qml), and
// every provider describes its VPNs the same way:
//   { id, provider, name, type, state, exitNode?, opens? }
// state is "" when off, "activating" | "activated" | "deactivating", or
// "login" when the VPN needs signing in before it can connect. opens names
// the bar widget that handles the VPN, for one that is not toggled here.

// All providers' VPNs as one list, in name order so a row never jumps when
// its state changes.
function mergeConnections(lists) {
  var merged = []
  var all = Array.isArray(lists) ? lists : []
  for (var i = 0; i < all.length; i++) {
    if (Array.isArray(all[i])) merged = merged.concat(all[i])
  }
  merged.sort(function(a, b) {
    var byName = String(a.name).localeCompare(String(b.name))
    return byName !== 0 ? byName : String(a.id).localeCompare(String(b.id))
  })
  return merged
}

// The VPNs carrying this machine's traffic, which is what the bar's lock
// means. A VPN counts once it is activated. Tailscale on its own only reaches
// the tailnet, so it counts only while an exit node carries the rest.
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

if (typeof module !== "undefined") {
  module.exports = {
    mergeConnections: mergeConnections,
    activeVpnNames: activeVpnNames
  }
}
