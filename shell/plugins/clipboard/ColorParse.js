// Recognize a clipboard entry that is a CSS color so the preview can show a
// swatch next to it. Returns { r, g, b, a } in 0..1 or null. Deliberately
// narrow: hex (with or without the #), rgb()/rgba(), hsl()/hsla(),
// oklab()/oklch(). Named colors are skipped, a copied "orange" is usually a
// word, not a color.

function parse(text) {
  var s = String(text || "").trim()
  if (!s || s.length > 64 || s.indexOf("\n") >= 0) return null

  var hex = parseHex(s)
  if (hex) return hex

  var m = /^([a-z]+)\((.*)\)$/i.exec(s)
  if (!m) return null
  var fn = m[1].toLowerCase()
  var args = splitArgs(m[2])
  if (!args || args.values.length !== 3) return null

  var v = args.values
  var alpha = args.alpha
  if (fn === "rgb" || fn === "rgba") return rgb(v, alpha)
  if (fn === "hsl" || fn === "hsla") return hsl(v, alpha)
  if (fn === "oklab") return oklab(v, alpha)
  if (fn === "oklch") return oklch(v, alpha)
  return null
}

// Bare 3-digit hex is skipped on purpose: "add", "bed", "cab" are words.
function parseHex(s) {
  var m = /^(#?)([0-9a-f]{3,8})$/i.exec(s)
  if (!m) return null
  var h = m[2]
  var hasHash = m[1] === "#"
  if (h.length === 3 || h.length === 4) {
    if (!hasHash) return null
    h = h.split("").map(function(c) { return c + c }).join("")
  } else if (h.length !== 6 && h.length !== 8) {
    return null
  }
  var n = parseInt(h, 16)
  if (h.length === 8) return { r: (n >>> 24) / 255, g: ((n >>> 16) & 255) / 255, b: ((n >>> 8) & 255) / 255, a: (n & 255) / 255 }
  return { r: (n >> 16) / 255, g: ((n >> 8) & 255) / 255, b: (n & 255) / 255, a: 1 }
}

// Accepts both the comma form "a, b, c[, alpha]" and the space form
// "a b c[ / alpha]". Returns { values: [3 strings], alpha: string|null }.
function splitArgs(inner) {
  var alpha = null
  var body = inner
  var slash = inner.indexOf("/")
  if (slash >= 0) {
    alpha = inner.slice(slash + 1).trim()
    body = inner.slice(0, slash)
  }
  var parts = body.split(/[\s,]+/).filter(function(p) { return p.length > 0 })
  if (parts.length === 4 && alpha === null) alpha = parts.pop()
  if (parts.length !== 3) return null
  return { values: parts, alpha: alpha }
}

// Number with optional unit. Returns NaN on anything unexpected.
function num(token, opts) {
  var t = String(token).trim().toLowerCase()
  if (t === "none") return 0
  var m = /^([+-]?(?:\d+\.?\d*|\.\d+)(?:e[+-]?\d+)?)(%|deg|rad|grad|turn)?$/.exec(t)
  if (!m) return NaN
  var n = parseFloat(m[1])
  var unit = m[2] || ""
  if (unit === "%") return opts.percent !== undefined ? n / 100 * opts.percent : NaN
  if (opts.angle) {
    if (unit === "rad") return n * 180 / Math.PI
    if (unit === "grad") return n * 0.9
    if (unit === "turn") return n * 360
    return n
  }
  if (unit) return NaN
  return opts.scale !== undefined ? n / opts.scale : n
}

function alphaOf(token) {
  if (token === null || token === undefined) return 1
  var a = num(token, { percent: 1 })
  return isFinite(a) ? clamp(a) : NaN
}

function clamp(x) {
  return Math.max(0, Math.min(1, x))
}

function finish(r, g, b, a) {
  if (![r, g, b, a].every(isFinite)) return null
  return { r: clamp(r), g: clamp(g), b: clamp(b), a: a }
}

function rgb(v, alpha) {
  return finish(
    num(v[0], { percent: 1, scale: 255 }),
    num(v[1], { percent: 1, scale: 255 }),
    num(v[2], { percent: 1, scale: 255 }),
    alphaOf(alpha))
}

function hsl(v, alpha) {
  var h = num(v[0], { angle: true })
  var s = num(v[1], { percent: 1, scale: 100 })
  var l = num(v[2], { percent: 1, scale: 100 })
  if (![h, s, l].every(isFinite)) return null
  s = clamp(s)
  l = clamp(l)
  h = ((h % 360) + 360) % 360
  var c = (1 - Math.abs(2 * l - 1)) * s
  var x = c * (1 - Math.abs((h / 60) % 2 - 1))
  var m = l - c / 2
  var rgb1 = h < 60 ? [c, x, 0] : h < 120 ? [x, c, 0] : h < 180 ? [0, c, x]
           : h < 240 ? [0, x, c] : h < 300 ? [x, 0, c] : [c, 0, x]
  return finish(rgb1[0] + m, rgb1[1] + m, rgb1[2] + m, alphaOf(alpha))
}

function oklab(v, alpha) {
  var L = num(v[0], { percent: 1 })
  var a = num(v[1], { percent: 0.4 })
  var b = num(v[2], { percent: 0.4 })
  return oklabToRgb(L, a, b, alphaOf(alpha))
}

function oklch(v, alpha) {
  var L = num(v[0], { percent: 1 })
  var C = num(v[1], { percent: 0.4 })
  var H = num(v[2], { angle: true })
  if (!isFinite(H)) return null
  var rad = H * Math.PI / 180
  return oklabToRgb(L, C * Math.cos(rad), C * Math.sin(rad), alphaOf(alpha))
}

// Björn Ottosson's reference Oklab → linear sRGB matrices, then the sRGB
// transfer curve. Out-of-gamut channels are clamped, not gamut-mapped.
function oklabToRgb(L, a, b, alpha) {
  if (![L, a, b].every(isFinite)) return null
  var l_ = L + 0.3963377774 * a + 0.2158037573 * b
  var m_ = L - 0.1055613458 * a - 0.0638541728 * b
  var s_ = L - 0.0894841775 * a - 1.2914855480 * b
  var l = l_ * l_ * l_
  var m = m_ * m_ * m_
  var s = s_ * s_ * s_
  return finish(
    gamma(+4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s),
    gamma(-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s),
    gamma(-0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s),
    alpha)
}

function gamma(x) {
  x = clamp(x)
  return x <= 0.0031308 ? 12.92 * x : 1.055 * Math.pow(x, 1 / 2.4) - 0.055
}

if (typeof module !== "undefined") {
  module.exports = { parse: parse }
}
