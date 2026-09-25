.pragma library

function clamp(value, min, max) {
  var n = Number(value)
  if (!isFinite(n)) return min
  return Math.max(min, Math.min(max, n))
}

function clampAlpha(value) {
  return clamp(value, 0, 1)
}

function padHex(value) {
  var n = clamp(Math.round(Number(value)), 0, 255)
  var h = n.toString(16)
  return h.length < 2 ? "0" + h : h
}

function qmlHexColor(rgb, alphaByte) {
  var rgbPart = String(rgb || "").replace(/^#/, "")
  var a = clamp(Math.round(Number(alphaByte)), 0, 255)

  if (typeof Qt !== "undefined" && Qt.rgba && rgbPart.length >= 6) {
    return Qt.rgba(
      parseInt(rgbPart.substring(0, 2), 16) / 255,
      parseInt(rgbPart.substring(2, 4), 16) / 255,
      parseInt(rgbPart.substring(4, 6), 16) / 255,
      a / 255
    )
  }

  var aHex = padHex(a)
  return aHex.toLowerCase() === "ff" ? "#" + rgbPart : "#" + rgbPart + aHex
}

function canonicalColor(value, alpha) {
  var a = alpha === undefined || alpha === null ? 1 : clampAlpha(alpha)
  var s = String(value || "").replace(/^\s+|\s+$/g, "")
  var m

  m = s.match(/^#([0-9A-Fa-f]{3})$/)
  if (m) {
    var sh = m[1]
    return qmlHexColor(
      sh.charAt(0) + sh.charAt(0)
        + sh.charAt(1) + sh.charAt(1)
        + sh.charAt(2) + sh.charAt(2),
      a * 255
    )
  }

  m = s.match(/^#([0-9A-Fa-f]{6})([0-9A-Fa-f]{2})?$/)
  if (m) {
    var colorAlpha = m[2] ? parseInt(m[2], 16) / 255 : 1
    return qmlHexColor(m[1], colorAlpha * a * 255)
  }

  m = s.match(/^[Rr][Gg][Bb]\(([0-9A-Fa-f]{6})\)$/)
  if (m) return qmlHexColor(m[1], a * 255)

  m = s.match(/^[Rr][Gg][Bb][Aa]\(([0-9A-Fa-f]{6})([0-9A-Fa-f]{2})\)$/)
  if (m) return qmlHexColor(m[1], (parseInt(m[2], 16) / 255) * a * 255)

  m = s.match(/^[Rr][Gg][Bb]\(([0-9]+),([0-9]+),([0-9]+)\)$/)
  if (m) return qmlHexColor(padHex(m[1]) + padHex(m[2]) + padHex(m[3]), a * 255)

  m = s.match(/^[Rr][Gg][Bb][Aa]\(([0-9]+),([0-9]+),([0-9]+),([0-9.]+)\)$/)
  if (m) return qmlHexColor(padHex(m[1]) + padHex(m[2]) + padHex(m[3]), clampAlpha(m[4]) * a * 255)

  m = s.match(/^0x([0-9A-Fa-f]{2})([0-9A-Fa-f]{6})$/)
  if (m) return qmlHexColor(m[2], (parseInt(m[1], 16) / 255) * a * 255)

  return s
}

function parseWidthSpec(value, fallback) {
  var fb = Number(fallback)
  if (!isFinite(fb) || fb < 0) fb = 0

  if (value === undefined || value === null || value === "") {
    return { top: fb, right: fb, bottom: fb, left: fb }
  }

  var parts = String(value).match(/-?\d+(?:\.\d+)?/g) || []
  var nums = []
  for (var i = 0; i < parts.length && i < 4; i++) {
    var n = Number(parts[i])
    nums.push(isFinite(n) && n > 0 ? n : 0)
  }

  if (nums.length === 0) nums = [fb]
  if (nums.length === 1) return { top: nums[0], right: nums[0], bottom: nums[0], left: nums[0] }
  if (nums.length === 2) return { top: nums[0], right: nums[1], bottom: nums[0], left: nums[1] }
  if (nums.length === 3) return { top: nums[0], right: nums[1], bottom: nums[2], left: nums[1] }
  return { top: nums[0], right: nums[1], bottom: nums[2], left: nums[3] }
}

function withSideOverrides(widths, top, right, bottom, left) {
  var out = {
    top: Number(widths && widths.top) || 0,
    right: Number(widths && widths.right) || 0,
    bottom: Number(widths && widths.bottom) || 0,
    left: Number(widths && widths.left) || 0,
  }
  if (top !== undefined && top !== null && top !== "") out.top = Math.max(0, Number(top) || 0)
  if (right !== undefined && right !== null && right !== "") out.right = Math.max(0, Number(right) || 0)
  if (bottom !== undefined && bottom !== null && bottom !== "") out.bottom = Math.max(0, Number(bottom) || 0)
  if (left !== undefined && left !== null && left !== "") out.left = Math.max(0, Number(left) || 0)
  return out
}

function parseGradientSpec(value, fallbackColor, alpha) {
  var s = String(value || "").replace(/^\s+|\s+$/g, "")
  var colors = []
  var angle = 0
  var parts = s.length > 0 ? s.split(/\s+/) : []

  for (var i = 0; i < parts.length; i++) {
    var part = parts[i]
    var angleMatch = part.match(/^(-?\d+(?:\.\d+)?)deg$/)
    if (angleMatch) angle = Number(angleMatch[1])
    else colors.push(canonicalColor(part, alpha))
  }

  if (colors.length === 0 && fallbackColor !== undefined && fallbackColor !== null)
    colors.push(canonicalColor(fallbackColor, alpha))

  return {
    colors: colors,
    angle: isFinite(angle) ? angle : 0,
    enabled: colors.length > 1,
  }
}

function isUniform(widths) {
  if (!widths) return true
  return widths.top === widths.right && widths.top === widths.bottom && widths.top === widths.left
}

function maxWidth(widths) {
  if (!widths) return 0
  return Math.max(widths.top || 0, widths.right || 0, widths.bottom || 0, widths.left || 0)
}

function needsOverlay(spec) {
  if (!spec) return false
  if (maxWidth(spec.widths) <= 0) return false
  return !!(spec.gradient && spec.gradient.enabled) || !isUniform(spec.widths)
}

function canUseNative(spec) {
  return !!spec && maxWidth(spec.widths) > 0 && !needsOverlay(spec)
}

function normalizeRadii(w, h, r) {
  var tl = { rx: Math.max(0, Number(r.tlrx) || 0), ry: Math.max(0, Number(r.tlry) || 0) }
  var tr = { rx: Math.max(0, Number(r.trrx) || 0), ry: Math.max(0, Number(r.trry) || 0) }
  var br = { rx: Math.max(0, Number(r.brrx) || 0), ry: Math.max(0, Number(r.brry) || 0) }
  var bl = { rx: Math.max(0, Number(r.blrx) || 0), ry: Math.max(0, Number(r.blry) || 0) }
  var scale = 1

  if (tl.rx + tr.rx > w && tl.rx + tr.rx > 0) scale = Math.min(scale, w / (tl.rx + tr.rx))
  if (bl.rx + br.rx > w && bl.rx + br.rx > 0) scale = Math.min(scale, w / (bl.rx + br.rx))
  if (tl.ry + bl.ry > h && tl.ry + bl.ry > 0) scale = Math.min(scale, h / (tl.ry + bl.ry))
  if (tr.ry + br.ry > h && tr.ry + br.ry > 0) scale = Math.min(scale, h / (tr.ry + br.ry))

  if (scale < 1) {
    tl.rx *= scale; tr.rx *= scale; br.rx *= scale; bl.rx *= scale
    tl.ry *= scale; tr.ry *= scale; br.ry *= scale; bl.ry *= scale
  }

  return { tl: tl, tr: tr, br: br, bl: bl }
}

// `chamfer` swaps each corner arc for a straight 45° cut, mirroring Hyprland's
// `decoration:rounding_power = 1.0` (a triangular corner).
function appendArc(path, rx, ry, sweep, point, chamfer) {
  if (rx > 0 && ry > 0 && !chamfer) path.push("A", rx, ry, 0, 0, sweep, point.x, point.y)
  else path.push("L", point.x, point.y)
}

function roundedRectPath(x, y, w, h, radii, chamfer) {
  if (w <= 0 || h <= 0) return ""
  var r = normalizeRadii(w, h, radii)
  var right = x + w
  var bottom = y + h
  var p = []

  p.push("M", x + r.tl.rx, y)
  p.push("H", right - r.tr.rx)
  appendArc(p, r.tr.rx, r.tr.ry, 1, { x: right, y: y + r.tr.ry }, chamfer)
  p.push("V", bottom - r.br.ry)
  appendArc(p, r.br.rx, r.br.ry, 1, { x: right - r.br.rx, y: bottom }, chamfer)
  p.push("H", x + r.bl.rx)
  appendArc(p, r.bl.rx, r.bl.ry, 1, { x: x, y: bottom - r.bl.ry }, chamfer)
  p.push("V", y + r.tl.ry)
  appendArc(p, r.tl.rx, r.tl.ry, 1, { x: x + r.tl.rx, y: y }, chamfer)
  p.push("Z")

  return p.join(" ")
}

function borderBoundary(x, y, w, h, radii) {
  var r = radii && radii.tl ? radii : normalizeRadii(w, h, radii)
  var right = x + w
  var bottom = y + h
  return {
    start: [
      { x: x + r.tl.rx, y: y },
      { x: right, y: y + r.tr.ry },
      { x: right - r.br.rx, y: bottom },
      { x: x, y: bottom - r.bl.ry },
    ],
    end: [
      { x: right - r.tr.rx, y: y },
      { x: right, y: bottom - r.br.ry },
      { x: x + r.bl.rx, y: bottom },
      { x: x, y: y + r.tl.ry },
    ],
    corner: [r.tr, r.br, r.bl, r.tl],
  }
}

function appendForwardCorner(path, boundary, side, chamfer) {
  var corner = boundary.corner[side]
  appendArc(path, corner.rx, corner.ry, 1, boundary.start[(side + 1) % 4], chamfer)
}

function appendReverseCorner(path, boundary, side, chamfer) {
  var corner = boundary.corner[side]
  appendArc(path, corner.rx, corner.ry, 0, boundary.end[side], chamfer)
}

function reverseBoundaryPath(boundary, chamfer) {
  var p = ["M", boundary.start[0].x, boundary.start[0].y]
  for (var side = 3; side >= 0; side--) {
    appendReverseCorner(p, boundary, side, chamfer)
    p.push("L", boundary.start[side].x, boundary.start[side].y)
  }
  p.push("Z")
  return p.join(" ")
}

function runPath(outer, inner, start, length, chamfer) {
  var previous = (start + 3) % 4
  var next = (start + length) % 4
  var p = ["M", outer.end[previous].x, outer.end[previous].y]

  appendForwardCorner(p, outer, previous, chamfer)
  for (var offset = 0; offset < length; offset++) {
    var side = (start + offset) % 4
    p.push("L", outer.end[side].x, outer.end[side].y)
    appendForwardCorner(p, outer, side, chamfer)
  }

  p.push("L", inner.start[next].x, inner.start[next].y)
  for (var reverseOffset = length - 1; reverseOffset >= 0; reverseOffset--) {
    var reverseSide = (start + reverseOffset) % 4
    appendReverseCorner(p, inner, reverseSide, chamfer)
    p.push("L", inner.start[reverseSide].x, inner.start[reverseSide].y)
  }
  appendReverseCorner(p, inner, previous, chamfer)
  p.push("Z")
  return p.join(" ")
}

function radiiFit(w, h, r) {
  return r.tlrx + r.trrx <= w
    && r.blrx + r.brrx <= w
    && r.tlry + r.blry <= h
    && r.trry + r.brry <= h
}

// Internal geometry output used by ringPath and focused topology tests.
// Connected enabled-side runs share one closed contour; opposite-only sides
// need two. The all-sides case is one compound winding path with a reversed
// inner loop. Disabled sides never require touching or epsilon-offset inner
// geometry, so a zero/zero rounded corner emits no border pixels.
function borderPaths(w, h, radius, widths, chamfer) {
  w = Math.max(0, Number(w) || 0)
  h = Math.max(0, Number(h) || 0)
  radius = Math.max(0, Number(radius) || 0)
  widths = widths || { top: 0, right: 0, bottom: 0, left: 0 }
  if (w <= 0 || h <= 0) return []

  var top = Math.max(0, Number(widths.top) || 0)
  var right = Math.max(0, Number(widths.right) || 0)
  var bottom = Math.max(0, Number(widths.bottom) || 0)
  var left = Math.max(0, Number(widths.left) || 0)
  var enabled = [top > 0, right > 0, bottom > 0, left > 0]
  if (!enabled[0] && !enabled[1] && !enabled[2] && !enabled[3]) return []

  var outerRadii = normalizeRadii(w, h, {
    tlrx: radius, tlry: radius,
    trrx: radius, trry: radius,
    brrx: radius, brry: radius,
    blrx: radius, blry: radius,
  })
  var outerPath = roundedRectPath(0, 0, w, h, {
    tlrx: outerRadii.tl.rx, tlry: outerRadii.tl.ry,
    trrx: outerRadii.tr.rx, trry: outerRadii.tr.ry,
    brrx: outerRadii.br.rx, brry: outerRadii.br.ry,
    blrx: outerRadii.bl.rx, blry: outerRadii.bl.ry,
  }, chamfer)

  var iw = w - left - right
  var ih = h - top - bottom
  if (iw <= 0 || ih <= 0) return [outerPath]

  // A 45° cut offset inward by w keeps an even stroke when the inner cut
  // shrinks by w * (2 - sqrt 2) rather than the full w an arc would lose.
  // Next to a borderless side, use the rounded inset instead so the inner
  // cut ends on the outer tangent point and the band tapers to nothing.
  var inset = function (r, a, b) {
    if (!chamfer || a <= 0 || b <= 0) return Math.max(0, r - a)
    return Math.max(0, r - (a + b) * (1 - Math.SQRT1_2))
  }
  var desiredInnerRadii = {
    tlrx: inset(outerRadii.tl.rx, left, top),
    tlry: inset(outerRadii.tl.ry, top, left),
    trrx: inset(outerRadii.tr.rx, right, top),
    trry: inset(outerRadii.tr.ry, top, right),
    brrx: inset(outerRadii.br.rx, right, bottom),
    brry: inset(outerRadii.br.ry, bottom, right),
    blrx: inset(outerRadii.bl.rx, left, bottom),
    blry: inset(outerRadii.bl.ry, bottom, left),
  }

  // Normalizing an inner radius that cannot fit can move its tangent beyond
  // the outer rounded boundary. Winding fill may then paint outside the outer
  // contour. Conservatively treat that rounded interior as consumed instead.
  if (!radiiFit(iw, ih, desiredInnerRadii)) return [outerPath]

  var innerRadii = normalizeRadii(iw, ih, desiredInnerRadii)
  var outer = borderBoundary(0, 0, w, h, outerRadii)
  var inner = borderBoundary(left, top, iw, ih, innerRadii)

  if (enabled[0] && enabled[1] && enabled[2] && enabled[3])
    return [outerPath + " " + reverseBoundaryPath(inner, chamfer)]

  var paths = []
  for (var start = 0; start < 4; start++) {
    if (!enabled[start] || enabled[(start + 3) % 4]) continue
    var length = 1
    while (length < 4 && enabled[(start + length) % 4]) length++
    paths.push(runPath(outer, inner, start, length, chamfer))
  }
  return paths
}

function ringPath(w, h, radius, widths, chamfer) {
  return borderPaths(w, h, radius, widths, chamfer).join(" ")
}

// Closed outline of a surface with uniform corners, used as a clip mask.
function surfacePath(w, h, radius, chamfer) {
  radius = Math.max(0, Number(radius) || 0)
  return roundedRectPath(0, 0, Math.max(0, Number(w) || 0), Math.max(0, Number(h) || 0), {
    tlrx: radius, tlry: radius, trrx: radius, trry: radius,
    brrx: radius, brry: radius, blrx: radius, blry: radius,
  }, chamfer)
}

function gradientEndpoints(w, h, angle) {
  w = Math.max(1, Number(w) || 1)
  h = Math.max(1, Number(h) || 1)
  var rad = (Number(angle) || 0) * Math.PI / 180
  var dx = Math.cos(rad)
  var dy = Math.sin(rad)
  var len = (Math.abs(w * dx) + Math.abs(h * dy)) / 2
  var cx = w / 2
  var cy = h / 2
  return {
    x1: cx - dx * len,
    y1: cy - dy * len,
    x2: cx + dx * len,
    y2: cy + dy * len,
  }
}

function stopColor(colors, index) {
  if (!colors || colors.length === 0) return "transparent"
  if (index < colors.length) return colors[index]
  return colors[colors.length - 1]
}

function stopPosition(colors, index) {
  var count = colors ? colors.length : 0
  if (count <= 1) return index === 0 ? 0 : 1
  if (index >= count) return 1
  return index / (count - 1)
}
