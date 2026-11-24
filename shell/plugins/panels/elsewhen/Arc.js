// A line of text laid along a shallow circular arc. `widths` are character
// advances; `rise` is how far the ends sit from the middle, in pixels; `smile`
// bends the ends up. Returns { width, height, chars: [{ x, y, rotation }] }
// with each box's top-left and its turn in degrees about its center.
function layout(widths, rise, smile) {
  var chars = []
  var total = 0
  var i
  for (i = 0; i < widths.length; i++) total += widths[i]

  if (total <= 0 || rise <= 0) {
    var x = 0
    for (i = 0; i < widths.length; i++) {
      chars.push({ x: x, y: 0, rotation: 0 })
      x += widths[i]
    }
    return { width: total, height: 0, chars: chars }
  }

  // Keeps the trig in range for absurd rises.
  var sag = Math.min(rise, total / 4)

  // Shallow-arc sagitta: R = w^2 / 8s.
  var radius = (total * total) / (8 * sag)
  var halfAngle = total / (2 * radius)
  var maxDrop = radius * (1 - Math.cos(halfAngle))
  var chordWidth = 2 * radius * Math.sin(halfAngle)

  var travelled = 0
  var left = 0, right = chordWidth
  for (i = 0; i < widths.length; i++) {
    var w = widths[i]
    var a = (travelled + w / 2 - total / 2) / radius
    var drop = radius * (1 - Math.cos(a))
    var x = chordWidth / 2 + radius * Math.sin(a) - w / 2
    chars.push({
      x: x,
      y: smile ? maxDrop - drop : drop,
      rotation: (smile ? -a : a) * 180 / Math.PI
    })
    left = Math.min(left, x)
    right = Math.max(right, x + w)
    travelled += w
  }

  // End boxes hang past the chord; shift so x starts at zero and width covers them.
  for (i = 0; i < chars.length; i++) chars[i].x -= left

  return { width: right - left, height: maxDrop, chars: chars }
}

if (typeof module !== "undefined") module.exports = { layout: layout }
