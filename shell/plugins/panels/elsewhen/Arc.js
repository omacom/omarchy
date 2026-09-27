// Laying a line of text along a shallow circular arc.
//
// Kept out of the QML so the geometry can be tested without a window. The
// caller measures each character (advance widths from FontMetrics) and gets
// back where to put it and how far to turn it; nothing here knows about
// fonts, items or colours.
//
// Parameterised by `rise` - how far the ends of the line sit above (or below)
// its middle - rather than by a radius. A radius means nothing at a glance
// and its effect changes with the length of the string: the same 1600px
// circle bends a short line barely at all and a long one visibly. A rise in
// pixels is the thing being judged by eye, and it holds steady as the text
// changes underneath it, which this line does every second.

.pragma library

// widths: advance width of each character, in order.
// rise:   pixels the ends are displaced from the middle. 0 is a flat line.
// smile:  true bends the ends up (a shallow U), false bends them down.
//
// Returns { width, height, chars: [{ x, y, rotation }] }, where x/y are the
// top-left of each character's box in the returned bounding size, and
// rotation is degrees about the character's own centre.
function layout(widths, rise, smile) {
  var chars = []
  var total = 0
  var i
  for (i = 0; i < widths.length; i++) total += widths[i]

  // A flat line is not a special case worth a separate code path in the
  // caller, so it is one here: radius would divide by zero.
  if (total <= 0 || rise <= 0) {
    var x = 0
    for (i = 0; i < widths.length; i++) {
      chars.push({ x: x, y: 0, rotation: 0 })
      x += widths[i]
    }
    return { width: total, height: 0, chars: chars }
  }

  // Past a quarter of the width the arc stops reading as a bent line and
  // starts reading as a circle with a word on it. Nothing sane comes near
  // this; it only keeps the trig in range.
  var sag = Math.min(rise, total / 4)

  // Sagitta of a circular segment: s = R(1 - cos(w/2R)), and for shallow
  // arcs R = w^2/8s. The approximation is what sets the radius; the angles
  // below are then exact for that radius, so the ends land within a fraction
  // of a pixel of the rise that was asked for.
  var radius = (total * total) / (8 * sag)
  var halfAngle = total / (2 * radius)
  var maxDrop = radius * (1 - Math.cos(halfAngle))
  var chordWidth = 2 * radius * Math.sin(halfAngle)

  var travelled = 0
  var left = 0, right = chordWidth
  for (i = 0; i < widths.length; i++) {
    var w = widths[i]
    // Arc length from the middle of the line to the middle of this character.
    var a = (travelled + w / 2 - total / 2) / radius
    var drop = radius * (1 - Math.cos(a))
    var x = chordWidth / 2 + radius * Math.sin(a) - w / 2
    // y grows downward, so a smile puts the middle of the line at the bottom
    // of the box and the ends at the top.
    chars.push({
      x: x,
      y: smile ? maxDrop - drop : drop,
      rotation: (smile ? -a : a) * 180 / Math.PI
    })
    left = Math.min(left, x)
    right = Math.max(right, x + w)
    travelled += w
  }

  // The end characters straddle the ends of the chord, so their boxes hang
  // outside it. Reported width is what actually has to be reserved, and x
  // starts at zero, so a caller can centre the result on its own width
  // without the first character falling off the left of the panel. (Turning
  // each box about its centre widens it a little further, by an amount that
  // depends on the glyph height this file does not know; the caller pads.)
  for (i = 0; i < chars.length; i++) chars[i].x -= left

  return { width: right - left, height: maxDrop, chars: chars }
}
