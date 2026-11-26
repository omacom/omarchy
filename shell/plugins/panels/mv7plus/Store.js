.pragma library

// Shared state and command queue across every mounted omarchy.mv7plus bar
// widget (one per monitor), so mute icons, panel controls, and hotplug state
// never diverge between displays and rapid writes never duplicate HID traffic.

var listeners = []
var leader = null
var pendingCmds = []
var running = false

var state = {
  deviceConnected: false,
  deviceError: "",
  autoLevel: true,
  gainDb: 28.0,
  micMuted: false,
  hpfMode: 0,
  limiterOn: false,
  compressorMode: 0,
  denoiserOn: false,
  popperStopperOn: false,
  tonePct: 0,
  reverbOutputOn: false,
  reverbType: 0,
  reverbIntensity: 0,
  reverbMonitorOn: false,
  micLevel: 100,
  playbackLevel: 100
}

var FIELD_MAP = [
  ["auto_level", "autoLevel", "bool"],
  ["gain_db", "gainDb", "num"],
  ["mute", "micMuted", "bool"],
  ["hpf", "hpfMode", "num"],
  ["limiter", "limiterOn", "bool"],
  ["compressor", "compressorMode", "num"],
  ["denoiser", "denoiserOn", "bool"],
  ["popper_stopper", "popperStopperOn", "bool"],
  ["tone_pct", "tonePct", "num"],
  ["reverb_output", "reverbOutputOn", "bool"],
  ["reverb_type", "reverbType", "num"],
  ["reverb_intensity", "reverbIntensity", "num"],
  ["reverb_monitor", "reverbMonitorOn", "bool"],
  ["mic_level", "micLevel", "num"],
  ["playback_level", "playbackLevel", "num"]
]

function isLeader(panel) {
  return leader === panel
}

function register(panel) {
  if (listeners.indexOf(panel) < 0) listeners.push(panel)
  if (!leader) leader = panel
  panel.syncFromStore(state)
}

function unregister(panel) {
  listeners = listeners.filter(function(p) { return p !== panel })
  if (leader === panel) {
    running = false
    leader = listeners.length > 0 ? listeners[0] : null
    if (leader && pendingCmds.length > 0) drainNext()
  }
}

function broadcast() {
  for (var i = 0; i < listeners.length; i++) {
    listeners[i].syncFromStore(state)
  }
}

function setOptimistic(prop, value) {
  state[prop] = value
  broadcast()
}

function hasPendingWrite(key) {
  for (var i = 0; i < pendingCmds.length; i++) {
    var cmd = pendingCmds[i]
    if (cmd[0] === "preset") return true
    if (cmd[0] === "set" && cmd[1] === key) return true
  }
  return false
}

function enqueue(args, runner) {
  if (!leader) leader = runner
  if (running) {
    var slot = args.slice(0, 2).join(" ")
    pendingCmds = pendingCmds.filter(function(c) { return c.slice(0, 2).join(" ") !== slot })
    pendingCmds.push(args)
    return
  }
  running = true
  leader.execHelper(args)
}

function drainNext() {
  if (!leader || running || pendingCmds.length === 0) return
  var next = pendingCmds.shift()
  running = true
  leader.execHelper(next)
}

function applySnapshot(raw) {
  var trimmed = String(raw || "").trim()
  if (!trimmed) return
  var data
  try {
    data = JSON.parse(trimmed)
  } catch (e) {
    return
  }
  state.deviceConnected = Boolean(data.connected)
  state.deviceError = data.error ? String(data.error) : ""
  if (!state.deviceConnected) {
    broadcast()
    return
  }
  var st = data.state
  if (st && typeof st === "object") {
    // Merge every field that has no newer write waiting in the queue so full
    // preset snapshots are never discarded when a follow-up set is queued.
    for (var i = 0; i < FIELD_MAP.length; i++) {
      var key = FIELD_MAP[i][0]
      var prop = FIELD_MAP[i][1]
      var kind = FIELD_MAP[i][2]
      if (st[key] === null || st[key] === undefined) continue
      if (hasPendingWrite(key)) continue
      state[prop] = kind === "bool" ? Number(st[key]) !== 0 : Number(st[key])
    }
  }
  broadcast()
}

function finishExec(raw) {
  running = false
  applySnapshot(raw)
  drainNext()
}

function markDisconnected() {
  state.deviceConnected = false
  state.deviceError = ""
  pendingCmds = []
  broadcast()
}
