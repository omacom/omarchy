.pragma library

// Sky colour by solar elevation - the whole of the sky-tint feature.
//
// Deleting this file and the two lines in Panel.qml that reference it removes
// the feature completely; nothing else depends on it. The elevation itself
// comes from GlobeModel.js, which the globe needs anyway.
//
// The stops are literal colours rather than theme roles: this is trying to
// look like the sky, and no palette role means "dawn". They are all kept
// fairly light so a city name stays legible on a dark panel.

var STOPS = [
  { e: -90, c: [0x6E, 0x79, 0xA8] },   // deep night, blue-violet
  { e: -12, c: [0x8A, 0x7F, 0xB4] },   // nautical twilight
  { e:  -6, c: [0xC5, 0x8C, 0x86] },   // civil twilight, dusty rose
  { e:  -1, c: [0xE5, 0xA4, 0x68] },   // sun on the horizon
  { e:   4, c: [0xF2, 0xC8, 0x6E] },   // golden hour
  { e:  12, c: [0xBF, 0xD4, 0xD8] },   // morning haze
  { e:  30, c: [0xA9, 0xC9, 0xE2] },   // daylight blue
  { e:  90, c: [0xC8, 0xE1, 0xF0] }    // high sun
]

function hex2(n) {
  var v = Math.max(0, Math.min(255, Math.round(n))).toString(16)
  return v.length < 2 ? "0" + v : v
}

// Linear blend between the two stops the elevation falls between, so the
// colour moves continuously through dawn and dusk rather than stepping.
function tint(elevationDeg) {
  var e = Number(elevationDeg)
  if (!isFinite(e)) return null
  if (e <= STOPS[0].e) return toHex(STOPS[0].c)
  if (e >= STOPS[STOPS.length - 1].e) return toHex(STOPS[STOPS.length - 1].c)
  for (var i = 0; i < STOPS.length - 1; i++) {
    var a = STOPS[i], b = STOPS[i + 1]
    if (e >= a.e && e <= b.e) {
      var t = (b.e === a.e) ? 0 : (e - a.e) / (b.e - a.e)
      return toHex([a.c[0] + (b.c[0] - a.c[0]) * t,
                    a.c[1] + (b.c[1] - a.c[1]) * t,
                    a.c[2] + (b.c[2] - a.c[2]) * t])
    }
  }
  return toHex(STOPS[STOPS.length - 1].c)
}

function toHex(c) {
  return "#" + hex2(c[0]) + hex2(c[1]) + hex2(c[2])
}
