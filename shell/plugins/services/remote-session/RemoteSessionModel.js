// Hyprland emits this whenever a screencopy session starts or stops, which
// covers gliff-server (ext-image-copy-capture) as well as screen recorders
// and browser screen shares, so the event is only a cue to re-probe. The
// matching screencastv2 event always accompanies it and is left alone so one
// transition costs one probe.
function isCaptureEvent(name) {
  return String(name || "") === "screencast"
}

// Parses the probe output: one "<pid> [peer]" line per running gliff-server,
// where peer is the ssh client address when the server was spawned over ssh.
function stateFromOutput(text) {
  var lines = String(text || "").split("\n")
  var active = false
  var peers = []
  for (var i = 0; i < lines.length; i++) {
    var parts = lines[i].trim().split(/\s+/)
    if (parts[0] === "") continue
    active = true
    var peer = parts[1] || ""
    if (peer !== "" && peers.indexOf(peer) === -1) peers.push(peer)
  }
  return { active: active, peers: peers }
}

if (typeof module !== "undefined") {
  module.exports = {
    isCaptureEvent: isCaptureEvent,
    stateFromOutput: stateFromOutput
  }
}
