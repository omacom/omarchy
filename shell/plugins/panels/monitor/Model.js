function clampBrightness(value) {
  var n = Number(value)
  if (!isFinite(n)) return 1
  return Math.max(1, Math.min(100, Math.round(n)))
}

function normalizeScale(scale) {
  var n = parseFloat(String(scale || ""))
  if (!isFinite(n)) return ""
  return String(Math.round(n * 100) / 100)
}

function gcd(a, b) {
  while (b) {
    var remainder = a % b
    a = b
    b = remainder
  }
  return a
}

function cleanScale(scale, width, height) {
  var requested = Number(scale)
  var modeWidth = Number(width)
  var modeHeight = Number(height)
  if (!isFinite(requested) || !isFinite(modeWidth) || !isFinite(modeHeight)
      || requested <= 0 || modeWidth <= 0 || modeHeight <= 0) return ""

  var divisor = gcd(Math.round(modeWidth * 120), Math.round(modeHeight * 120))
  var scaleUnits = Math.round(requested * 120)
  if (scaleUnits > divisor) scaleUnits = divisor
  while (divisor % scaleUnits !== 0) scaleUnits++
  return normalizeScale(scaleUnits / 120)
}

function matchingScaleIndex(scales, currentScale, width, height) {
  var current = Number(currentScale)
  if (!Array.isArray(scales) || !isFinite(current)) return -1

  var bestIndex = -1
  var bestDistance = Infinity
  var normalizedCurrent = normalizeScale(current)
  for (var i = 0; i < scales.length; i++) {
    if (cleanScale(scales[i], width, height) !== normalizedCurrent) continue

    var distance = Math.abs(Number(scales[i]) - current)
    if (distance < bestDistance) {
      bestIndex = i
      bestDistance = distance
    }
  }
  return bestIndex
}

function availableScales(scales, width, height) {
  if (!Array.isArray(scales) || Number(width) <= 0 || Number(height) <= 0) return scales || []

  var byEffectiveScale = {}
  for (var i = 0; i < scales.length; i++) {
    var requested = Number(scales[i])
    var effective = Number(cleanScale(requested, width, height))

    if (!isFinite(requested) || !isFinite(effective)) continue

    var key = normalizeScale(effective)
    var existing = byEffectiveScale[key]
    if (!existing || Math.abs(requested - effective) < existing.distance) {
      byEffectiveScale[key] = {
        value: String(scales[i]),
        index: i,
        distance: Math.abs(requested - effective)
      }
    }
  }

  return Object.keys(byEffectiveScale)
    .map(function(key) { return byEffectiveScale[key] })
    .sort(function(a, b) { return a.index - b.index })
    .map(function(candidate) { return candidate.value })
}

function normalizeRefreshRate(rate) {
  var n = parseFloat(String(rate || ""))
  if (!isFinite(n) || n <= 0) return ""
  return String(Math.round(n * 100) / 100)
}

// A display is sold by its whole hertz, so that is what a rate is labelled
// with, even where the mode itself is 143.91Hz.
function refreshRateLabel(rate) {
  var n = parseFloat(String(rate || ""))
  if (!isFinite(n) || n <= 0) return ""
  return String(Math.round(n))
}

// Rates the current mode can reach, fastest first. Modes arrive as Hyprland
// mode strings ("2560x1440@143.91Hz"); anything at another resolution is a
// resolution change rather than a rate, and never reaches here.
function availableRefreshRates(modes, width, height) {
  if (!Array.isArray(modes)) return []

  var modeWidth = Number(width)
  var modeHeight = Number(height)
  var byLabel = {}

  for (var i = 0; i < modes.length; i++) {
    var parts = /^(\d+)x(\d+)@([0-9.]+)Hz$/.exec(String(modes[i] || ""))
    if (!parts) continue
    if (isFinite(modeWidth) && modeWidth > 0 && Number(parts[1]) !== modeWidth) continue
    if (isFinite(modeHeight) && modeHeight > 0 && Number(parts[2]) !== modeHeight) continue

    var rate = normalizeRefreshRate(parts[3])
    if (rate === "") continue

    // 59.94 and 60 are both sold as 60Hz. Keep the faster of the two so every
    // pill lands on a rate the one beside it doesn't.
    var label = refreshRateLabel(rate)
    if (!byLabel[label] || Number(rate) > Number(byLabel[label])) byLabel[label] = rate
  }

  return Object.keys(byLabel)
    .map(function(label) { return byLabel[label] })
    .sort(function(a, b) { return Number(b) - Number(a) })
}

// Hyprland lists the mode as 143.91Hz and reports the live rate as 143.912, so
// the active pill is the nearest rate rather than an equal one. Half a hertz
// out is a mode the display is no longer in, not a rounding gap.
function matchingRefreshRateIndex(rates, currentRate) {
  var current = Number(currentRate)
  if (!Array.isArray(rates) || !isFinite(current) || current <= 0) return -1

  var bestIndex = -1
  var bestDistance = Infinity
  for (var i = 0; i < rates.length; i++) {
    var distance = Math.abs(Number(rates[i]) - current)
    if (distance < bestDistance) {
      bestIndex = i
      bestDistance = distance
    }
  }
  return bestDistance <= 0.5 ? bestIndex : -1
}

function brightnessName(percent) {
  var p = Math.round(percent)
  if (p >= 95) return "Sun blast"
  if (p >= 80) return "Solar flare"
  if (p >= 65) return "Golden hour"
  if (p >= 45) return "Even day"
  if (p >= 30) return "Soft glow"
  if (p >= 20) return "Lamp light"
  if (p >= 10) return "Candlelit"
  return "Night owl"
}

function parseDisplays(raw) {
  var displays = []
  try {
    displays = raw ? JSON.parse(String(raw)) : []
  } catch (e) {
    displays = []
  }
  if (!Array.isArray(displays)) displays = []

  var count = 0
  for (var i = 0; i < displays.length; i++) {
    if (displays[i] && displays[i].enabled) count++
  }

  return {
    displays: displays,
    enabledDisplayCount: count
  }
}

if (typeof module !== "undefined") {
  module.exports = {
    clampBrightness: clampBrightness,
    normalizeScale: normalizeScale,
    cleanScale: cleanScale,
    matchingScaleIndex: matchingScaleIndex,
    availableScales: availableScales,
    normalizeRefreshRate: normalizeRefreshRate,
    refreshRateLabel: refreshRateLabel,
    availableRefreshRates: availableRefreshRates,
    matchingRefreshRateIndex: matchingRefreshRateIndex,
    brightnessName: brightnessName,
    parseDisplays: parseDisplays
  }
}
