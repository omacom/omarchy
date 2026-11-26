.pragma library

function dpiPresets(minDpi, maxDpi) {
  var candidates = [800, 1000, 1600, 2400, 4000]
  var out = []
  for (var i = 0; i < candidates.length; i++) {
    var v = candidates[i]
    if (v >= minDpi && v <= maxDpi) out.push(v)
  }
  return out
}

function snapValue(val, minVal, maxVal, step) {
  var s = step > 0 ? step : 1
  var snapped = Math.round((val - minVal) / s) * s + minVal
  return Math.max(minVal, Math.min(maxVal, Math.round(snapped)))
}

function batteryStatusKind(battery) {
  if (!battery || !battery.known) return "connected"
  var st = String(battery.status || "").toLowerCase()
  if (battery.charging || st === "recharging" || st === "charging") return "charging"
  if (st === "full") return "full"
  if (battery.level <= 15) return "low"
  return "discharging"
}

function remappedCount(buttons) {
  if (!buttons || !buttons.length) return 0
  var n = 0
  for (var i = 0; i < buttons.length; i++) {
    if (buttons[i] && buttons[i].isDefault === false) n++
  }
  return n
}

function isFreespinMode(raw) {
  return String(raw || "").toLowerCase().indexOf("free") !== -1
}

// Neutralize HTML/QML rich-text metacharacters before passing dynamic text to
// any external tooltip or notification sink whose textFormat we do not own.
function plainSafe(raw) {
  var s = String(raw === undefined || raw === null ? "" : raw)
  return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
}
