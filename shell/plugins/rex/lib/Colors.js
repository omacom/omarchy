.pragma library

// Colors for highlighting matches and groups. Themes only promise a
// foreground, background, and accent, so group colors are spread around the
// hue wheel from the accent, at a lightness that reads on the theme's
// background.

// Qt colors and #rrggbb strings both arrive here; QML color values expose
// r/g/b in 0..1.
function rgb(color) {
  if (typeof color === "string") {
    var hex = color.replace("#", "")
    if (hex.length === 8) hex = hex.substr(2)
    return { r: parseInt(hex.substr(0, 2), 16) / 255, g: parseInt(hex.substr(2, 2), 16) / 255, b: parseInt(hex.substr(4, 2), 16) / 255 }
  }
  return { r: color.r, g: color.g, b: color.b }
}

function hsl(c) {
  var max = Math.max(c.r, c.g, c.b), min = Math.min(c.r, c.g, c.b)
  var l = (max + min) / 2
  if (max === min) return { h: 0, s: 0, l: l }
  var d = max - min
  var s = l > 0.5 ? d / (2 - max - min) : d / (max + min)
  var h
  if (max === c.r) h = (c.g - c.b) / d + (c.g < c.b ? 6 : 0)
  else if (max === c.g) h = (c.b - c.r) / d + 2
  else h = (c.r - c.g) / d + 4
  return { h: h / 6, s: s, l: l }
}

function luminance(color) {
  var c = rgb(color)
  return 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
}

// The golden angle keeps neighbouring groups far apart however many there
// are. Returns { h, s, l } for Qt.hsla.
function groupColor(index, accent, background) {
  var base = hsl(rgb(accent))
  var dark = luminance(background) < 0.5
  var h = (base.h + index * 0.381966) % 1
  var s = Math.max(0.55, Math.min(0.85, base.s || 0.7))
  var l = dark ? 0.62 : 0.42
  return { h: h, s: s, l: l }
}

if (typeof module !== "undefined") module.exports = { groupColor: groupColor, luminance: luminance, hsl: hsl, rgb: rgb }
