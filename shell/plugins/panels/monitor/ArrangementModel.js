function pair(monitors, moving, reference) {
  var names = monitors.map(function(monitor) { return monitor.name })
  if (names.indexOf(reference) < 0) {
    reference = names.filter(function(name) { return /^(eDP|LVDS|DSI)/.test(name) })[0] || names[0] || ""
  }
  if (names.indexOf(moving) < 0 || moving === reference)
    moving = names.filter(function(name) { return name !== reference }).pop() || ""
  return { moving: moving, reference: reference }
}

function bounds(monitors) {
  if (!monitors.length) return { x: 0, y: 0, width: 1, height: 1 }
  var left = Math.min.apply(null, monitors.map(function(m) { return m.x }))
  var top = Math.min.apply(null, monitors.map(function(m) { return m.y }))
  var right = Math.max.apply(null, monitors.map(function(m) { return m.x + m.logicalWidth }))
  var bottom = Math.max.apply(null, monitors.map(function(m) { return m.y + m.logicalHeight }))
  return { x: left, y: top, width: Math.max(1, right - left), height: Math.max(1, bottom - top) }
}

function positions(monitors) {
  var result = {}
  monitors.forEach(function(m) { result[m.name] = [m.x, m.y] })
  return result
}

function place(monitors, name, x, y) {
  return monitors.map(function(m) {
    return Object.assign({}, m, m.name === name ? {x: Math.round(x), y: Math.round(y)} : {})
  })
}

function overlaps(monitors) {
  for (var i = 0; i < monitors.length; i++) {
    for (var j = i + 1; j < monitors.length; j++) {
      var a = monitors[i], b = monitors[j]
      if (a.x < b.x + b.logicalWidth && b.x < a.x + a.logicalWidth
          && a.y < b.y + b.logicalHeight && b.y < a.y + a.logicalHeight) return true
    }
  }
  return false
}

function connected(monitors) {
  if (!monitors.length) return true
  var visited = [monitors[0]], remaining = monitors.slice(1)
  for (var i = 0; i < visited.length; i++) {
    var a = visited[i]
    remaining = remaining.filter(function(b) {
      var touches = ((a.x + a.logicalWidth === b.x || b.x + b.logicalWidth === a.x)
        && Math.max(a.y, b.y) < Math.min(a.y + a.logicalHeight, b.y + b.logicalHeight))
        || ((a.y + a.logicalHeight === b.y || b.y + b.logicalHeight === a.y)
        && Math.max(a.x, b.x) < Math.min(a.x + a.logicalWidth, b.x + b.logicalWidth))
      if (touches) visited.push(b)
      return !touches
    })
  }
  return remaining.length === 0
}

function preset(monitors, name, reference, side, alignment) {
  var m = monitors.filter(function(s) { return s.name === name })[0]
  var a = monitors.filter(function(s) { return s.name === reference })[0]
  if (!m || !a || name === reference) return monitors
  var horizontal = side === "left" || side === "right"
  var difference = horizontal ? a.logicalHeight - m.logicalHeight : a.logicalWidth - m.logicalWidth
  var offset = alignment === "center" ? Math.floor(difference / 2) : alignment === "bottom" || alignment === "right" ? difference : 0
  return place(monitors, name,
    a.x + (side === "left" ? -m.logicalWidth : side === "right" ? a.logicalWidth : offset),
    a.y + (side === "above" ? -m.logicalHeight : side === "below" ? a.logicalHeight : offset))
}

// Snap the nearest contacting edge, retaining arbitrary offsets along it.
// Discard colliding candidates so a third display cannot hide underneath one.
function snap(monitors, name, x, y, distance) {
  var m = monitors.filter(function(s) { return s.name === name })[0]
  if (!m) return null
  var candidates = []
  monitors.filter(function(s) { return s.name !== name }).forEach(function(a) {
    var vertical = [a.y, a.y + a.logicalHeight - m.logicalHeight, a.y + Math.floor((a.logicalHeight - m.logicalHeight) / 2)]
    var horizontal = [a.x, a.x + a.logicalWidth - m.logicalWidth, a.x + Math.floor((a.logicalWidth - m.logicalWidth) / 2)]
    function align(value, targets) {
      return targets.reduce(function(best, target) {
        return Math.abs(value - target) <= Math.min(distance, 16) && Math.abs(value - target) < Math.abs(value - best) ? target : best
      }, value + distance + 1)
    }
    var sy = align(y, vertical), sx = align(x, horizontal)
    if (Math.abs(sy - y) > distance) sy = y
    if (Math.abs(sx - x) > distance) sx = x
    var points = [[a.x - m.logicalWidth, sy], [a.x + a.logicalWidth, sy],
                  [sx, a.y - m.logicalHeight], [sx, a.y + a.logicalHeight]]
    points.forEach(function(p, index) {
      var contact = index < 2 ? p[1] < a.y + a.logicalHeight && p[1] + m.logicalHeight > a.y
                              : p[0] < a.x + a.logicalWidth && p[0] + m.logicalWidth > a.x
      var delta = Math.hypot(p[0] - x, p[1] - y)
      var layout = place(monitors, name, p[0], p[1])
      if (contact && delta <= distance && !overlaps(layout))
        candidates.push({layout: layout, x: Math.round(p[0]), y: Math.round(p[1]), distance: delta,
                         guide: index < 2 ? {x: index === 0 ? a.x : a.x + a.logicalWidth} : {y: index === 2 ? a.y : a.y + a.logicalHeight}})
    })
  })
  candidates.sort(function(a, b) { return a.distance - b.distance })
  return candidates[0] || null
}

function changed(original, draft) {
  var before = positions(original), after = positions(draft)
  return Object.keys(before).some(function(name) { return !after[name] || before[name][0] !== after[name][0] || before[name][1] !== after[name][1] })
}

if (typeof module !== "undefined") module.exports = { pair: pair, bounds: bounds, positions: positions, place: place, overlaps: overlaps, connected: connected, preset: preset, snap: snap, changed: changed }
