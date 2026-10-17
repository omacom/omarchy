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

// tr is an optional translate(key, english) from the QML side (I18n.t);
// without it the English text stands, which is what the Node tests assert.
function brightnessName(percent, tr) {
  var t = typeof tr === "function" ? tr : function(key, english) { return english }
  var p = Math.round(percent)
  if (p >= 95) return t("monitor.level.sunBlast", "Sun blast")
  if (p >= 80) return t("monitor.level.solarFlare", "Solar flare")
  if (p >= 65) return t("monitor.level.goldenHour", "Golden hour")
  if (p >= 45) return t("monitor.level.evenDay", "Even day")
  if (p >= 30) return t("monitor.level.softGlow", "Soft glow")
  if (p >= 20) return t("monitor.level.lampLight", "Lamp light")
  if (p >= 10) return t("monitor.level.candlelit", "Candlelit")
  return t("monitor.level.nightOwl", "Night owl")
}

function formatScaleValue(scale) {
  var n = Number(scale)
  if (!isFinite(n)) return ""
  return String(Math.round(n * 10000) / 10000)
}

function generateScalePresets(width, height, currentScale, maxCount) {
  var modeWidth = Number(width)
  var modeHeight = Number(height)
  var limit = Number(maxCount) || 6
  var fallback = ["1", "1.25", "1.6", "2", "3", "4"]

  if (!isFinite(modeWidth) || !isFinite(modeHeight) || modeWidth <= 0 || modeHeight <= 0) {
    return fallback
  }

  var maxScale = 4.0
  if (modeHeight <= 1080) {
    maxScale = 2.0
  } else if (modeHeight <= 1600) {
    maxScale = 2.5
  }

  var divisor = gcd(Math.round(modeWidth * 120), Math.round(modeHeight * 120))
  var maxK = Math.round(maxScale * 120)
  var candidates = []

  for (var k = 120; k <= maxK; k++) {
    if (divisor % k === 0) {
      candidates.push(k / 120)
    }
  }

  if (candidates.length === 0) return fallback
  if (candidates.length <= limit) {
    return candidates.map(function(s) { return formatScaleValue(s) })
  }

  var n = candidates.length
  var K = limit
  var minVal = candidates[0]
  var maxVal = candidates[n - 1]
  var idealStep = (maxVal - minVal) / (K - 1)

  var reqIdx = -1
  if (currentScale !== undefined && currentScale !== null && currentScale !== "") {
    var cVal = Number(currentScale)
    if (isFinite(cVal)) {
      var bestDistance = Infinity
      for (var i = 0; i < n; i++) {
        var distance = Math.abs(candidates[i] - cVal)
        if (distance < bestDistance) {
          bestDistance = distance
          reqIdx = i
        }
      }
      if (bestDistance > 0.01) {
        reqIdx = -1
      }
    }
  }

  var dp = []
  for (var j = 0; j < K; j++) {
    dp[j] = []
    for (var i = 0; i < n; i++) {
      dp[j][i] = [null, null]
    }
  }

  var initReq = (reqIdx === 0) ? 1 : 0
  dp[0][0][initReq] = { cost: 0, prev: -1, prevReq: 0 }

  for (var j = 1; j < K; j++) {
    for (var i = j; i < n; i++) {
      if (j === K - 1 && i !== n - 1) continue
      var isReq = (i === reqIdx)

      for (var prev = j - 1; prev < i; prev++) {
        var step = candidates[i] - candidates[prev]
        var dev = step - idealStep
        var stepCost = dev * dev

        for (var h = 0; h < 2; h++) {
          if (!dp[j - 1][prev][h]) continue
          var nextH = (h === 1 || isReq) ? 1 : 0
          var totalCost = dp[j - 1][prev][h].cost + stepCost

          if (!dp[j][i][nextH] || totalCost < dp[j][i][nextH].cost) {
            dp[j][i][nextH] = { cost: totalCost, prev: prev, prevReq: h }
          }
        }
      }
    }
  }

  var wantReq = (reqIdx !== -1) ? 1 : 0
  if (!dp[K - 1][n - 1][wantReq]) wantReq = 0

  var resultIndices = []
  var curr = n - 1
  var currReq = wantReq
  for (var j = K - 1; j >= 0; j--) {
    resultIndices.unshift(curr)
    var node = dp[j][curr][currReq]
    curr = node.prev
    currReq = node.prevReq
  }

  return resultIndices.map(function(idx) {
    return formatScaleValue(candidates[idx])
  })
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
    formatScaleValue: formatScaleValue,
    generateScalePresets: generateScalePresets,
    brightnessName: brightnessName,
    parseDisplays: parseDisplays
  }
}
