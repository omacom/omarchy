.pragma library

// Shared state and serialized command queue across every mounted omarchy.logitech
// bar widget (one per monitor), so battery badges, controls, and hotplug state
// stay in sync across displays without duplicating HID++ traffic.

var listeners = []
var leader = null
var pendingCmds = []
var running = false
var statusQueued = false

var state = {
  solaarInstalled: true,
  connected: false,
  refreshing: false,
  applying: false,
  lastError: "",
  name: "",
  serial: "",
  transport: "",
  batteryKnown: false,
  batteryLevel: -1,
  batteryStatus: "unknown",
  batteryCharging: false,
  hosts: [],
  currentHost: "",
  hasDpi: false,
  dpiValue: 1000,
  dpiMin: 200,
  dpiMax: 8000,
  dpiStep: 50,
  hasRatchet: false,
  ratchetValue: "Ratcheted",
  ratchetChoices: [],
  hasSmartShift: false,
  smartShiftValue: 10,
  smartShiftMin: 1,
  smartShiftMax: 50,
  hasTorque: false,
  torqueValue: 75,
  torqueMin: 1,
  torqueMax: 100,
  hasHires: false,
  hiresValue: false,
  hasInvertVertical: false,
  invertVerticalValue: false,
  hasInvertThumb: false,
  invertThumbValue: false,
  hasHaptics: false,
  hapticLevel: 0,
  hapticMin: 0,
  hapticMax: 100,
  canTestHaptics: false,
  buttons: []
}

function cmdKey(args) {
  if (!args || args.length === 0) return ""
  if (args[0] === "status" || args[0] === "reset-buttons") return args[0]
  if (args[0] === "set") {
    var settingIdx = args[1] === "--serial" ? 3 : 1
    var setting = args[settingIdx] || ""
    if (setting === "reprogrammable-keys" && args.length > settingIdx + 1) {
      return setting + ":" + args[settingIdx + 1]
    }
    return setting
  }
  return args[0]
}

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
    var wasRunning = running
    running = false
    leader = listeners.length > 0 ? listeners[0] : null
    if (leader) {
      leader.syncFromStore(state)
      if (wasRunning) {
        requestStatus(leader)
      } else if (pendingCmds.length > 0) {
        drainNext()
      }
    }
  }
}

function broadcast() {
  for (var i = 0; i < listeners.length; i++) {
    listeners[i].syncFromStore(state)
  }
}

function setOptimistic(patch) {
  for (var k in patch) state[k] = patch[k]
  broadcast()
}

function requestStatus(runner) {
  if (!leader) leader = runner
  if (!leader) return
  if (running) {
    statusQueued = true
    return
  }
  running = true
  state.refreshing = true
  broadcast()
  leader.execCli(["status"], "status", false)
}

function enqueueWrite(args, refreshAfter, runner) {
  if (!leader) leader = runner
  if (!leader) return
  var slot = cmdKey(args)
  if (running) {
    pendingCmds = pendingCmds.filter(function(item) { return item.slot !== slot })
    pendingCmds.push({ slot: slot, args: args, refreshAfter: Boolean(refreshAfter) })
    return
  }
  running = true
  state.applying = true
  state.lastError = ""
  broadcast()
  leader.execCli(args, "write", Boolean(refreshAfter))
}

function drainNext() {
  if (!leader || running) return
  if (pendingCmds.length > 0) {
    var next = pendingCmds.shift()
    running = true
    state.applying = true
    state.lastError = ""
    broadcast()
    leader.execCli(next.args, "write", next.refreshAfter)
    return
  }
  state.applying = false
  if (statusQueued) {
    statusQueued = false
    running = true
    state.refreshing = true
    broadcast()
    leader.execCli(["status"], "status", false)
    return
  }
  broadcast()
}

function applyStatusPayload(raw) {
  var trimmed = String(raw || "").trim()
  if (!trimmed) return
  var data
  try {
    data = JSON.parse(trimmed)
  } catch (e) {
    return
  }
  if (!data || typeof data !== "object") return

  state.solaarInstalled = data.solaarInstalled !== false
  if (!data.connected) {
    state.connected = false
    broadcast()
    return
  }

  state.connected = true
  state.lastError = ""
  state.name = String(data.name || "")
  state.serial = String(data.serial || "")
  state.transport = String(data.transport || "")

  var bat = data.battery || {}
  state.batteryKnown = bat.known === true
  state.batteryLevel = typeof bat.level === "number" ? bat.level : -1
  state.batteryStatus = String(bat.status || "unknown")
  state.batteryCharging = bat.charging === true

  var f = data.features || {}

  if (f.hosts && f.hosts.choices && f.hosts.choices.length > 0) {
    state.hosts = f.hosts.choices
    state.currentHost = String(f.hosts.current || "")
  } else {
    state.hosts = []
    state.currentHost = ""
  }

  if (f.dpi) {
    state.hasDpi = true
    state.dpiMin = Number(f.dpi.min) || 200
    state.dpiMax = Number(f.dpi.max) || 8000
    state.dpiStep = Number(f.dpi.step) || 50
    state.dpiValue = Number(f.dpi.value) || 1000
  } else {
    state.hasDpi = false
  }

  var sc = f.scroll || {}
  if (sc.ratchet && sc.ratchet.choices && sc.ratchet.choices.length > 0) {
    state.hasRatchet = true
    state.ratchetValue = String(sc.ratchet.value || "Ratcheted")
    state.ratchetChoices = sc.ratchet.choices
  } else {
    state.hasRatchet = false
    state.ratchetChoices = []
  }

  if (sc.smartShift) {
    state.hasSmartShift = true
    state.smartShiftMin = Number(sc.smartShift.min) || 1
    state.smartShiftMax = Number(sc.smartShift.max) || 50
    state.smartShiftValue = Number(sc.smartShift.value) || 10
  } else {
    state.hasSmartShift = false
  }

  if (sc.torque) {
    state.hasTorque = true
    state.torqueMin = Number(sc.torque.min) || 1
    state.torqueMax = Number(sc.torque.max) || 100
    state.torqueValue = Number(sc.torque.value) || 50
  } else {
    state.hasTorque = false
  }

  state.hasHires = sc.hires !== undefined
  if (state.hasHires) state.hiresValue = sc.hires === true
  state.hasInvertVertical = sc.invertVertical !== undefined
  if (state.hasInvertVertical) state.invertVerticalValue = sc.invertVertical === true
  state.hasInvertThumb = sc.invertThumb !== undefined
  if (state.hasInvertThumb) state.invertThumbValue = sc.invertThumb === true

  if (f.haptics) {
    state.hasHaptics = true
    state.hapticMin = Number(f.haptics.min) || 0
    state.hapticMax = Number(f.haptics.max) || 100
    state.hapticLevel = Number(f.haptics.level) || 0
    state.canTestHaptics = f.haptics.canTest === true
  } else {
    state.hasHaptics = false
  }

  state.buttons = f.buttons && f.buttons.length ? f.buttons : []
  broadcast()
}

function finishExec(kind, raw, exitCode, refreshAfter) {
  running = false
  if (kind === "status") {
    state.refreshing = false
    applyStatusPayload(raw)
  } else {
    var trimmed = String(raw || "").trim()
    if (trimmed) {
      try {
        var res = JSON.parse(trimmed)
        if (res && res.ok === false) {
          state.lastError = String(res.error || "")
          statusQueued = true
        }
      } catch (e) {}
    }
    if (exitCode !== 0 || refreshAfter) statusQueued = true
  }
  drainNext()
}
