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
    return { name: m.name, mode: mode || modes[0], modes: modes, x: m.x, y: m.y,
      scale: m.scale, transform: m.transform, mirror: m.mirrorOf && m.mirrorOf !== "none" }
  })
}

function size(display) {
  var mode = String(display.mode || "").split("@")[0].split("x")
  var w = Number(mode[0]) / display.scale
  var h = Number(mode[1]) / display.scale
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

function assignments(text, monitor, workspaces) {
  var ids = text.trim() ? text.trim().split(/[ ,]+/).map(Number) : []
  if (ids.some(function(id) { return !Number.isInteger(id) || id < 1 || id > 99 }))
    throw new Error("Use workspace numbers 1–99, separated by spaces")
  return workspaces.filter(function(w) { return w.monitor !== monitor && ids.indexOf(w.id) < 0 })
    .concat(ids.filter(function(id, i) { return ids.indexOf(id) === i }).map(function(id) { return { id: id, monitor: monitor } }))
}

function request(displays, workspaces) {
  return { displays: displays.map(function(d) {
    return { name: d.name, mode: d.mode, x: d.x, y: d.y, scale: d.scale, transform: d.transform }
  }), workspaces: workspaces }
}

if (typeof module !== "undefined") module.exports = { fromMonitors: fromMonitors, size: size, bounds: bounds, assignments: assignments, request: request }
