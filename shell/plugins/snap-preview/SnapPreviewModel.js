// What Hyprland's window snapping (default/hypr/window-snapping.lua) announces
// as a dragged window's drop target, read from its custom event:
//   snap-preview <monitor> <x> <y> <w> <h>   (layout coordinates)
//   snap-preview none
// Any client on Hyprland's socket can send a custom event, so anything but an
// exact, bounded message counts as none, and nothing received is shown as text.

var LIMIT = 100000

// The box to outline, or null for none. undefined: not a snap-preview event.
function parse(name, data) {
  if (String(name) !== "custom") return undefined
  var parts = String(data).trim().split(/\s+/)
  if (parts[0] !== "snap-preview") return undefined
  if (parts.length !== 6 || !/^[A-Za-z0-9._-]{1,64}$/.test(parts[1])) return null
  var numbers = []
  for (var i = 2; i < 6; i++) {
    if (!/^-?\d{1,6}$/.test(parts[i])) return null
    numbers.push(parseInt(parts[i], 10))
  }
  var x = numbers[0], y = numbers[1], w = numbers[2], h = numbers[3]
  if (Math.abs(x) > LIMIT || Math.abs(y) > LIMIT || w < 1 || h < 1 || w > LIMIT || h > LIMIT) return null
  return { monitor: parts[1], x: x, y: y, w: w, h: h }
}

if (typeof module !== "undefined") {
  module.exports = {
    parse: parse
  }
}
