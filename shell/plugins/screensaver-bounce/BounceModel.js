// Block characters by the quarters they fill: a character's index here is its
// mask of top-left 1, top-right 2, bottom-left 4 and bottom-right 8.
var quarters = " ▘▝▀▖▌▞▛▗▚▐▜▄▙▟█"

function isBlank(line) {
  return String(line).trim() === ""
}

// Reads screensaver art. Art drawn only with block characters becomes a grid
// of pixels, two across and two down per character, described as horizontal
// runs so it can be drawn as a handful of rectangles. Anything else is kept as
// text. Blank lines and the common indent are trimmed either way, so the edges
// of the screen are met by the ink itself.
function parseArt(text) {
  var lines = String(text || "").replace(/\t/g, "        ").split("\n").map(function(line) {
    return line.replace(/\s+$/, "")
  })
  while (lines.length && isBlank(lines[lines.length - 1])) lines.pop()
  while (lines.length && isBlank(lines[0])) lines.shift()
  if (!lines.length) return { blocks: false, text: "", columns: 0, rows: 0, runs: [] }

  var indent = Infinity
  lines.forEach(function(line) {
    if (!isBlank(line)) indent = Math.min(indent, line.length - line.replace(/^\s+/, "").length)
  })
  lines = lines.map(function(line) { return Array.from(line.slice(indent)) })

  var blocks = lines.every(function(chars) {
    return chars.every(function(ch) { return quarters.indexOf(ch) >= 0 })
  })
  var width = Math.max.apply(null, lines.map(function(chars) { return chars.length }))
  if (!blocks) {
    return {
      blocks: false,
      text: lines.map(function(chars) { return chars.join("") }).join("\n"),
      columns: width,
      rows: lines.length,
      runs: []
    }
  }

  var pixels = []
  lines.forEach(function(chars) {
    var top = [], bottom = []
    for (var c = 0; c < width; c++) {
      var mask = Math.max(0, quarters.indexOf(chars[c] || " "))
      top.push(mask & 1 ? 1 : 0, mask & 2 ? 1 : 0)
      bottom.push(mask & 4 ? 1 : 0, mask & 8 ? 1 : 0)
    }
    pixels.push(top, bottom)
  })

  var inked = function(row) { return row.indexOf(1) >= 0 }
  while (pixels.length && !inked(pixels[pixels.length - 1])) pixels.pop()
  while (pixels.length && !inked(pixels[0])) pixels.shift()
  var left = Infinity, right = -1
  pixels.forEach(function(row) {
    var first = row.indexOf(1), last = row.lastIndexOf(1)
    if (first >= 0) left = Math.min(left, first)
    if (last > right) right = last
  })

  var runs = []
  pixels.forEach(function(row, y) {
    for (var x = left; x <= right; x++) {
      if (!row[x]) continue
      var start = x
      while (x <= right && row[x]) x++
      runs.push({ x: start - left, y: y, width: x - start })
    }
  })

  return {
    blocks: true,
    text: lines.map(function(chars) { return chars.join("") }).join("\n"),
    columns: right - left + 1,
    rows: pixels.length,
    runs: runs
  }
}

// The legs of the logo's path along one axis, which it can cover between
// 0 and `range` at `speed` a second: a first leg from `position`, heading
// toward the far end when `heading` is positive, to the wall it is facing, then
// out and back between the walls forever. Durations are in milliseconds.
function legs(position, heading, range, speed) {
  var start = Math.max(0, Math.min(range, position))
  var wall = heading > 0 ? range : 0
  var other = range - wall
  var sweep = speed > 0 ? range / speed * 1000 : 0
  return {
    first: { from: start, to: wall, duration: speed > 0 ? Math.abs(wall - start) / speed * 1000 : 0 },
    out: { from: wall, to: other, duration: sweep },
    back: { from: other, to: wall, duration: sweep }
  }
}

// Whether walls met at these times make a corner: both within `slack`, in
// whatever unit the times are in.
function isCorner(hitX, hitY, slack) {
  return Math.abs(hitX - hitY) <= slack
}

// A new color far enough round the wheel from the last one to read as a change.
function nextHue(hue, random) {
  return (hue + 72 + Math.floor(random * 216)) % 360
}

// Bright, saturated color for a hue in degrees, as #rrggbb.
function colorFor(hue) {
  var h = ((hue % 360) + 360) % 360
  var chroma = 216, low = 39
  var ramp = h / 60 % 2
  var mid = Math.round(chroma * (1 - Math.abs(ramp - 1)) + low)
  var high = chroma + low
  var rgb = [
    [high, mid, low], [mid, high, low], [low, high, mid],
    [low, mid, high], [mid, low, high], [high, low, mid]
  ][Math.floor(h / 60)]
  return "#" + rgb.map(function(v) { return ("0" + v.toString(16)).slice(-2) }).join("")
}

if (typeof module !== "undefined") {
  module.exports = {
    parseArt: parseArt,
    legs: legs,
    isCorner: isCorner,
    nextHue: nextHue,
    colorFor: colorFor
  }
}
