function fromMonitors(monitors) {
  return monitors.filter(function(m) { return !m.disabled }).map(function(m) {
    var modes = []
    ;(m.availableModes || []).forEach(function(mode) {
      mode = mode.replace(/Hz$/, "")
      if (modes.indexOf(mode) < 0) modes.push(mode)
    })
    var prefix = m.width + "x" + m.height + "@"
    var mode = modes.filter(function(value) { return value.indexOf(prefix) === 0 }).sort(function(a, b) {
      return Math.abs(Number(a.split("@")[1]) - m.refreshRate) - Math.abs(Number(b.split("@")[1]) - m.refreshRate)
    })[0]
    return { name: m.name, label: m.model ? m.model + " · " + m.name : m.name, mode: mode || modes[0], modes: modes, x: m.x, y: m.y,
      scale: m.scale, transform: m.transform, mirror: m.mirrorOf && m.mirrorOf !== "none" }
  })
}

function size(display) {
  var mode = String(display.mode || "").split("@")[0].split("x")
  var w = Math.round(Number(mode[0]) / display.scale)
  var h = Math.round(Number(mode[1]) / display.scale)
  return display.transform % 2 ? { width: h, height: w } : { width: w, height: h }
}

function bounds(displays) {
  var left = Infinity, top = Infinity, right = -Infinity, bottom = -Infinity
  displays.forEach(function(d) {
    var s = size(d)
    left = Math.min(left, d.x); top = Math.min(top, d.y)
    right = Math.max(right, d.x + s.width); bottom = Math.max(bottom, d.y + s.height)
  })
  return displays.length ? { x: left, y: top, width: right - left, height: bottom - top }
    : { x: 0, y: 0, width: 1, height: 1 }
}

function move(displays, name, x, y) {
  return displays.map(function(d) {
    var copy = Object.assign({}, d)
    if (d.name === name) { copy.x = Math.max(-32768, Math.min(32768, Math.round(x))); copy.y = Math.max(-32768, Math.min(32768, Math.round(y))) }
    return copy
  })
}

function snapPosition(displays, name, x, y, threshold) {
  var d = displays.filter(function(d) { return d.name === name })[0]
  var s = size(d), bestX = threshold, bestY = threshold, proposedX = x, proposedY = y
  displays.forEach(function(other) {
    if (other.name === name) return
    var os = size(other)
    ;[other.x, other.x + os.width, other.x - s.width, other.x + os.width - s.width].forEach(function(edge) {
      var distance = Math.abs(proposedX - edge)
      if (distance < bestX) { bestX = distance; x = edge }
    })
    ;[other.y, other.y + os.height, other.y - s.height, other.y + os.height - s.height].forEach(function(edge) {
      var distance = Math.abs(proposedY - edge)
      if (distance < bestY) { bestY = distance; y = edge }
    })
  })
  return {x: Math.round(x), y: Math.round(y)}
}

function place(displays, name, reference, side) {
  var d = displays.filter(function(d) { return d.name === name })[0]
  var other = displays.filter(function(d) { return d.name === reference })[0]
  if (!d || !other || d === other) return displays
  var s = size(d), os = size(other)
  var x = other.x, y = other.y
  if (side === "left") x -= s.width
  if (side === "right") x += os.width
  if (side === "above") y -= s.height
  if (side === "below") y += os.height
  return move(displays, name, x, y)
}

function resolutions(display) {
  return display.modes.map(function(m) { return m.split("@")[0] }).filter(function(m, i, a) { return a.indexOf(m) === i })
}

function rates(display, resolution) {
  return display.modes.filter(function(m) { return m.split("@")[0] === resolution }).map(function(m) { return m.split("@")[1] })
}

function modeForResolution(display, resolution) {
  var rate = Number(display.mode.split("@")[1])
  var values = rates(display, resolution).sort(function(a, b) { return Math.abs(Number(a) - rate) - Math.abs(Number(b) - rate) })
  return resolution + "@" + values[0]
}

function request(displays) {
  return { displays: displays.map(function(d) {
    return { name: d.name, mode: d.mode, x: d.x, y: d.y, scale: d.scale, transform: d.transform }
  }) }
}

if (typeof module !== "undefined") module.exports = { fromMonitors: fromMonitors, size: size, bounds: bounds, request: request,
  move: move, snapPosition: snapPosition, place: place, resolutions: resolutions, rates: rates, modeForResolution: modeForResolution }
