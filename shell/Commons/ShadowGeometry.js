// Logical-pixel geometry shared by the renderer and tightly sized windows.
// Keep limits here so a theme cannot request unbounded render targets.
function number(values, key, fallback, min, max) {
  var raw = values[key]
  if (raw === undefined || raw === null || String(raw).trim() === "") return fallback
  var n = Number(raw)
  return isFinite(n) ? Math.max(min, Math.min(max, n)) : fallback
}

function spec(values, section) {
  var prefix = section + ".shadow-"
  var alpha = number(values, prefix + "alpha", 0, 0, 1)
  var blur = number(values, prefix + "blur", 24, 0, 128)
  var spread = number(values, prefix + "spread", 0, -64, 64)
  var offsetX = number(values, prefix + "offset-x", 0, -128, 128)
  var offsetY = number(values, prefix + "offset-y", 6, -128, 128)
  // RectangularShadow extends by blur + spread. Round outwards, including
  // one antialiasing pixel, so fractional offsets never lose an edge.
  var extent = Math.max(0, blur + spread) + 1
  var enabled = section !== "" && section !== "bar" && alpha > 0
  return {
    enabled: enabled,
    alpha: alpha,
    blur: blur,
    spread: spread,
    offsetX: offsetX,
    offsetY: offsetY,
    left: enabled ? Math.ceil(Math.max(0, extent - offsetX)) : 0,
    right: enabled ? Math.ceil(Math.max(0, extent + offsetX)) : 0,
    top: enabled ? Math.ceil(Math.max(0, extent - offsetY)) : 0,
    bottom: enabled ? Math.ceil(Math.max(0, extent + offsetY)) : 0,
  }
}

if (typeof module !== "undefined") module.exports = { number: number, spec: spec }
