// Clipboard history model: normalisation, retention, type detection, search and
// the display rows the picker renders. Pure functions so the Node tests can
// exercise them without the shell.

var displayTextLimit = 8192

function nonEmptyLines(text) {
  var lines = String(text || "").split(/\r?\n/)
  var out = []
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].trim().length > 0) out.push(lines[i])
  }
  return out
}

function textEntry(text) {
  var value = String(text || "")
  return value.trim().length > 0 ? { type: "text", text: value } : null
}

function metadata(value, entry) {
  if (value.title !== undefined && value.title !== null && String(value.title).length > 0) entry.title = String(value.title)
  if (value.pinned === true) entry.pinned = true
  if (value.ocr !== undefined && value.ocr !== null && String(value.ocr).length > 0) entry.ocr = String(value.ocr)
  if (value.ocrTried === true) entry.ocrTried = true
  if (value.sourceApp) entry.sourceApp = String(value.sourceApp)
  if (value.sourceTitle) entry.sourceTitle = String(value.sourceTitle)

  var ms = Number(value.capturedAtMs)
  if (!isFinite(ms) || ms <= 0) {
    var parsed = Date.parse(String(value.capturedAt || ""))
    if (isFinite(parsed)) ms = parsed
  }
  if (ms > 0) entry.capturedAtMs = ms
  if (value.capturedAt !== undefined && value.capturedAt !== null) entry.capturedAt = String(value.capturedAt)
  return entry
}

function normalizeEntry(value) {
  if (typeof value === "string") return textEntry(value)
  if (!value || typeof value !== "object") return null

  var type = String(value.type || value.kind || "")
  if (type === "text") {
    var entry = textEntry(value.text)
    return entry ? metadata(value, entry) : null
  }

  if (type === "image") {
    var path = String(value.path || "")
    if (!path) return null
    return metadata(value, {
      type: "image",
      path: path,
      mime: String(value.mime || "image/png")
    })
  }

  return null
}

function entryKey(entry) {
  if (!entry) return ""
  if (entry.type === "image") return "image:" + String(entry.path || "")
  return "text:" + String(entry.text || "")
}

function parseHistory(raw) {
  try {
    var parsed = JSON.parse(String(raw || "[]"))
    var next = []
    if (!Array.isArray(parsed)) return next

    for (var i = 0; i < parsed.length; i++) {
      var entry = normalizeEntry(parsed[i])
      if (entry) next.push(entry)
    }
    return next
  } catch (e) {
    return []
  }
}

function defaultSettings() {
  return {
    retentionDays: 0,
    maxEntries: 500,
    primaryAction: "paste",
    textRecognition: true,
    disabledApps: ["KeePassXC", "org.keepassxc.KeePassXC", "Bitwarden", "1Password"]
  }
}

function parseSettings(raw) {
  var settings = defaultSettings()
  var parsed
  try { parsed = JSON.parse(String(raw || "")) } catch (e) { return settings }
  if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) return settings

  var days = Number(parsed.retentionDays)
  if (isFinite(days) && days >= 0) settings.retentionDays = days

  var max = Number(parsed.maxEntries)
  if (isFinite(max) && max >= 0) settings.maxEntries = max

  if (parsed.primaryAction === "copy" || parsed.primaryAction === "paste") {
    settings.primaryAction = parsed.primaryAction
  }
  if (typeof parsed.textRecognition === "boolean") settings.textRecognition = parsed.textRecognition
  if (Array.isArray(parsed.disabledApps)) {
    var apps = []
    for (var i = 0; i < parsed.disabledApps.length; i++) {
      if (typeof parsed.disabledApps[i] !== "string") continue
      var app = parsed.disabledApps[i].trim()
      if (app && apps.indexOf(app) < 0) apps.push(app)
    }
    settings.disabledApps = apps
  }
  return settings
}

function settingsJson() {
  return JSON.stringify(defaultSettings(), null, 2) + "\n"
}

function isAppDisabled(settings, app) {
  var name = String(app || "").trim().toLowerCase()
  if (!name) return false
  var apps = settings && settings.disabledApps
  if (!Array.isArray(apps)) return false
  for (var i = 0; i < apps.length; i++) {
    if (String(apps[i] || "").trim().toLowerCase() === name) return true
  }
  return false
}

// Newest first, pinned entries exempt from both retention and the entry cap.
function pruneHistory(history, settings, now) {
  var values = Array.isArray(history) ? history : []
  var config = parseSettings(JSON.stringify(settings || {}))
  var cutoff = config.retentionDays > 0 ? Number(now) - config.retentionDays * 86400000 : 0
  var unpinned = 0
  var out = []

  for (var i = 0; i < values.length; i++) {
    var entry = normalizeEntry(values[i])
    if (!entry) continue
    if (entry.pinned) {
      out.push(entry)
      continue
    }
    if (cutoff > 0 && entry.capturedAtMs && entry.capturedAtMs < cutoff) continue
    if (config.maxEntries > 0 && unpinned >= config.maxEntries) continue
    unpinned++
    out.push(entry)
  }
  return out
}

function addEntry(history, value, settings, now) {
  var config
  if (typeof settings === "number") {
    if (settings <= 0) return []
    config = parseSettings(JSON.stringify({ maxEntries: settings }))
  } else {
    config = parseSettings(JSON.stringify(settings || {}))
  }
  var entry = normalizeEntry(value)
  var values = Array.isArray(history) ? history : []
  if (!entry) return pruneHistory(values, config, now)

  var key = entryKey(entry)
  var previous = null
  for (var i = 0; i < values.length; i++) {
    var existing = normalizeEntry(values[i])
    if (existing && entryKey(existing) === key) {
      previous = existing
      break
    }
  }
  // Metadata follows the content: recopying a pinned or renamed entry keeps
  // them, and an image keeps the OCR text already extracted for it.
  if (previous) {
    if (previous.pinned) entry.pinned = true
    if (previous.title && !entry.title) entry.title = previous.title
    if (previous.ocr && !entry.ocr) entry.ocr = previous.ocr
    if (previous.ocrTried) entry.ocrTried = true
    if (!entry.sourceApp && previous.sourceApp) entry.sourceApp = previous.sourceApp
  }

  var next = [entry]
  for (var j = 0; j < values.length; j++) {
    var other = normalizeEntry(values[j])
    if (!other || entryKey(other) === key) continue
    next.push(other)
  }
  return pruneHistory(next, config, now)
}

function removeEntryAt(history, index) {
  var values = Array.isArray(history) ? history : []
  var target = Number(index)
  if (isNaN(target) || target < 0 || target >= values.length) return values.slice()

  var next = values.slice()
  next.splice(target, 1)
  return next
}

function removeSince(history, cutoffMs) {
  var values = Array.isArray(history) ? history : []
  var cutoff = Number(cutoffMs)
  if (!isFinite(cutoff)) return values.slice()

  var next = []
  for (var i = 0; i < values.length; i++) {
    var entry = values[i]
    // Entries captured before timestamps were recorded are left alone.
    if (entry && entry.capturedAtMs && entry.capturedAtMs >= cutoff) continue
    next.push(entry)
  }
  return next
}

function clearHistory() {
  return []
}

function updateEntry(history, index, patch) {
  var values = Array.isArray(history) ? history : []
  var target = Number(index)
  if (isNaN(target) || target < 0 || target >= values.length) return null

  var next = values.slice()
  var copy = {}
  for (var key in values[target]) copy[key] = values[target][key]
  for (var patchKey in patch) copy[patchKey] = patch[patchKey]

  if (copy.type === "text" && String(copy.text || "").trim().length === 0) return null
  next[target] = normalizeEntry(copy)
  if (!next[target]) return null
  return next
}

function setPinned(history, index, pinned) {
  return updateEntry(history, index, { pinned: pinned === true })
}

function moveToTop(history, index) {
  var values = Array.isArray(history) ? history : []
  var target = Number(index)
  if (isNaN(target) || target < 0 || target >= values.length) return values.slice()
  var next = [values[target]]
  for (var i = 0; i < values.length; i++) if (i !== target) next.push(values[i])
  return next
}

function removedImagePaths(before, after) {
  var kept = {}
  var values = Array.isArray(after) ? after : []
  for (var i = 0; i < values.length; i++) {
    if (values[i] && values[i].type === "image" && values[i].path) kept[values[i].path] = true
  }

  var removed = []
  var previous = Array.isArray(before) ? before : []
  for (var j = 0; j < previous.length; j++) {
    var entry = previous[j]
    if (entry && entry.type === "image" && entry.path && !kept[entry.path]) {
      if (removed.indexOf(entry.path) < 0) removed.push(entry.path)
    }
  }
  return removed
}

function parseEntryJson(line) {
  var raw = String(line || "").trim()
  if (!raw) return null
  try { return normalizeEntry(JSON.parse(raw)) } catch (e) { return null }
}

function decodeFileUri(uri) {
  var value = String(uri || "").trim()
  if (value.indexOf("file://") !== 0) return ""

  var path = value.substring(7)
  if (path.indexOf("localhost/") === 0) path = path.substring(9)
  if (path.charAt(0) !== "/") return ""

  try { return decodeURIComponent(path) } catch (e) { return path }
}

function filePaths(entry) {
  if (!entry || entry.type !== "text") return []

  var lines = String(entry.text || "").split(/\r?\n/)
  var paths = []
  for (var i = 0; i < lines.length; i++) {
    var path = decodeFileUri(lines[i])
    if (path) paths.push(path)
  }
  return paths
}

function isFileEntry(entry) {
  if (!entry || entry.type !== "text") return false
  var lines = nonEmptyLines(entry.text)
  if (lines.length === 0) return false
  for (var i = 0; i < lines.length; i++) {
    if (!decodeFileUri(lines[i])) return false
  }
  return true
}

function fileName(path) {
  var parts = String(path || "").split("/")
  return parts.length > 0 ? parts[parts.length - 1] : String(path || "")
}

function isImagePath(path) {
  return /\.(png|jpe?g|webp|gif|bmp|tiff?)$/i.test(String(path || ""))
}

var linkPattern = /^(?:https?:\/\/|ftp:\/\/|www\.)\S+$/i
var bareLinkPattern = /^(?:[a-z0-9-]+\.)+(?:com|org|net|io|dev|ai|co|app|me|info|xyz|edu|gov|uk|de|fr|nl|se|no|es|it|ca|au|jp|in)(?::\d+)?(?:[/?#]\S*)?$/i
var emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/

function isLink(text) {
  var value = String(text || "").trim()
  if (!value || /\s/.test(value)) return false
  return linkPattern.test(value) || bareLinkPattern.test(value)
}

function isEmail(text) {
  var value = String(text || "").trim()
  if (!value || /\s/.test(value)) return false
  return emailPattern.test(value)
}

function clampByte(value) {
  var number = Number(value)
  if (!isFinite(number)) number = 0
  return Math.max(0, Math.min(255, Math.round(number)))
}

function twoHex(value) {
  var text = clampByte(value).toString(16)
  return text.length < 2 ? "0" + text : text
}

function numberOrPercent(value, scale) {
  var text = String(value || "").trim()
  if (text.length === 0) return NaN
  if (text.charAt(text.length - 1) === "%") return Number(text.slice(0, -1)) / 100 * scale
  return Number(text)
}

function hslToRgb(hue, sat, light) {
  var h = ((Number(hue) % 360) + 360) % 360 / 360
  var s = Math.max(0, Math.min(100, Number(sat))) / 100
  var l = Math.max(0, Math.min(100, Number(light))) / 100

  if (s === 0) {
    var gray = Math.round(l * 255)
    return [gray, gray, gray]
  }

  var q = l < 0.5 ? l * (1 + s) : l + s - l * s
  var p = 2 * l - q
  function hueToRgb(t) {
    var value = t
    if (value < 0) value += 1
    if (value > 1) value -= 1
    if (value < 1 / 6) return p + (q - p) * 6 * value
    if (value < 1 / 2) return q
    if (value < 2 / 3) return p + (q - p) * (2 / 3 - value) * 6
    return p
  }
  return [
    Math.round(hueToRgb(h + 1 / 3) * 255),
    Math.round(hueToRgb(h) * 255),
    Math.round(hueToRgb(h - 1 / 3) * 255)
  ]
}

function rgbToHsl(r, g, b) {
  var red = clampByte(r) / 255
  var green = clampByte(g) / 255
  var blue = clampByte(b) / 255
  var max = Math.max(red, green, blue)
  var min = Math.min(red, green, blue)
  var light = (max + min) / 2
  var hue = 0
  var sat = 0

  if (max !== min) {
    var delta = max - min
    sat = light > 0.5 ? delta / (2 - max - min) : delta / (max + min)
    if (max === red) hue = (green - blue) / delta + (green < blue ? 6 : 0)
    else if (max === green) hue = (blue - red) / delta + 2
    else hue = (red - green) / delta + 4
    hue *= 60
  }
  return [Math.round(hue), Math.round(sat * 100), Math.round(light * 100)]
}

// Parses the colour spellings people actually copy: hex, rgb()/rgba() and
// hsl()/hsla(). Returns null for anything else so the entry stays text.
function parseColor(value) {
  var text = String(value || "").trim()
  if (!text || text.length > 64) return null

  var r = 0
  var g = 0
  var b = 0
  var a = 1
  var match = text.match(/^#([0-9a-fA-F]{3,8})$/)

  if (match) {
    var digits = match[1]
    if (digits.length === 3 || digits.length === 4) {
      r = parseInt(digits.charAt(0) + digits.charAt(0), 16)
      g = parseInt(digits.charAt(1) + digits.charAt(1), 16)
      b = parseInt(digits.charAt(2) + digits.charAt(2), 16)
      if (digits.length === 4) a = parseInt(digits.charAt(3) + digits.charAt(3), 16) / 255
    } else if (digits.length === 6 || digits.length === 8) {
      r = parseInt(digits.substring(0, 2), 16)
      g = parseInt(digits.substring(2, 4), 16)
      b = parseInt(digits.substring(4, 6), 16)
      if (digits.length === 8) a = parseInt(digits.substring(6, 8), 16) / 255
    } else {
      return null
    }
  } else if ((match = text.match(/^rgba?\(\s*([^)]+)\)$/i))) {
    var parts = match[1].split(/[,\s/]+/)
    if (parts.length < 3) return null
    r = clampByte(numberOrPercent(parts[0], 255))
    g = clampByte(numberOrPercent(parts[1], 255))
    b = clampByte(numberOrPercent(parts[2], 255))
    if (parts.length > 3) {
      var alpha = String(parts[3] || "").trim()
      a = alpha.charAt(alpha.length - 1) === "%" ? Number(alpha.slice(0, -1)) / 100 : Number(alpha)
    }
  } else if ((match = text.match(/^hsla?\(\s*([^)]+)\)$/i))) {
    var hslParts = match[1].split(/[,\s/]+/)
    if (hslParts.length < 3) return null
    var rgb = hslToRgb(Number(hslParts[0]), Number(String(hslParts[1]).replace("%", "")), Number(String(hslParts[2]).replace("%", "")))
    r = rgb[0]
    g = rgb[1]
    b = rgb[2]
    if (hslParts.length > 3) {
      var hslAlpha = String(hslParts[3] || "").trim()
      a = hslAlpha.charAt(hslAlpha.length - 1) === "%" ? Number(hslAlpha.slice(0, -1)) / 100 : Number(hslAlpha)
    }
  } else {
    return null
  }

  if (!isFinite(a)) a = 1
  a = Math.max(0, Math.min(1, a))
  var hex = "#" + twoHex(r) + twoHex(g) + twoHex(b)
  var hexAlpha = a < 1 ? hex + twoHex(a * 255) : hex
  var hsl = rgbToHsl(r, g, b)
  var rgbText = a < 1
    ? "rgba(" + r + ", " + g + ", " + b + ", " + Math.round(a * 100) / 100 + ")"
    : "rgb(" + r + ", " + g + ", " + b + ")"
  var hslText = a < 1
    ? "hsla(" + hsl[0] + ", " + hsl[1] + "%, " + hsl[2] + "%, " + Math.round(a * 100) / 100 + ")"
    : "hsl(" + hsl[0] + ", " + hsl[1] + "%, " + hsl[2] + "%)"

  return {
    r: r, g: g, b: b, a: a,
    hex: hex,
    hexAlpha: hexAlpha,
    rgb: rgbText,
    hsl: hslText
  }
}

function entryKind(entry) {
  if (!entry) return "text"
  if (entry.type === "image") return "image"
  if (isFileEntry(entry)) return "file"
  if (isLink(entry.text)) return "link"
  if (isEmail(entry.text)) return "email"
  if (parseColor(entry.text)) return "color"
  return "text"
}

var filterKinds = ["all", "text", "image", "file", "link", "email", "color"]

function kindLabel(kind, tr) {
  var t = translator(tr)
  if (kind === "text") return t("clipboard.filterText", "Text")
  if (kind === "image") return t("clipboard.filterImages", "Images")
  if (kind === "file") return t("clipboard.filterFiles", "Files")
  if (kind === "link") return t("clipboard.filterLinks", "Links")
  if (kind === "email") return t("clipboard.filterEmails", "Emails")
  if (kind === "color") return t("clipboard.filterColors", "Colors")
  return t("clipboard.filterAll", "All")
}

function translator(tr) {
  return typeof tr === "function" ? tr : function(key, english) { return english }
}

function fileEntryText(entry, tr, trn, fmt) {
  var tn = typeof trn === "function" ? trn : function(key, count, english) { return count === 1 ? english.one : english.other }
  var number = typeof fmt === "function" ? fmt : function(v) { return String(v) }
  var paths = filePaths(entry)
  if (paths.length === 0) return ""
  if (paths.length === 1) return fileName(paths[0])
  return tn("clipboard.files", paths.length, { one: "%1 file", other: "%1 files" }).replace("%1", number(paths.length))
}

function imagePreviewText(entry, tr) {
  var t = translator(tr)
  var screenshot = String(entry && entry.mime || "") === "image/png"
  if (entry && entry.capturedAtMs) {
    return screenshot
      ? t("clipboard.screenshot", "Screenshot")
      : t("clipboard.image", "Image")
  }
  var timestamp = String(entry && entry.capturedAt || "")
  if (!timestamp) return t("clipboard.image", "Image")
  var pattern = screenshot
    ? t("clipboard.screenshotFrom", "Screenshot from %1")
    : t("clipboard.imageFrom", "Image from %1")
  return pattern.replace("%1", timestamp)
}

function previewText(entry, tr, trn, fmt) {
  if (!entry) return ""
  if (entry.type === "image") return imagePreviewText(entry, tr)
  var fileText = fileEntryText(entry, tr, trn, fmt)
  if (fileText) return fileText
  return String(entry.text || "").replace(/\s+/g, " ").trim()
}

function fullText(entry) {
  if (!entry) return ""
  var paths = filePaths(entry)
  if (paths.length > 0 && isFileEntry(entry)) return paths.join("\n")
  return String(entry.text || "")
}

function cappedEntry(entry) {
  if (!entry || entry.type !== "text" || entry.text.length <= displayTextLimit) return entry

  // Cut on a line break so a file:// URI never truncates into a bogus path.
  var cut = entry.text.lastIndexOf("\n", displayTextLimit)
  var copy = {}
  for (var key in entry) copy[key] = entry[key]
  copy.text = entry.text.slice(0, cut > 0 ? cut : displayTextLimit)
  return copy
}

function relativeTime(ms, now, tr) {
  var stamp = Number(ms)
  if (!isFinite(stamp) || stamp <= 0) return ""
  var t = translator(tr)
  var delta = Math.max(0, Number(now) - stamp)
  var minute = 60000
  var hour = 3600000
  var day = 86400000
  var week = 604800000

  var value
  if (delta < minute) return t("clipboard.justNow", "now")
  if (delta < hour) value = Math.floor(delta / minute) + "m"
  else if (delta < day) value = Math.floor(delta / hour) + "h"
  else if (delta < week) value = Math.floor(delta / day) + "d"
  else if (delta < 5 * week) value = Math.floor(delta / week) + "w"
  else {
    try { return new Date(stamp).toLocaleDateString() } catch (e) { return "" }
  }
  return value
}

function searchableText(entry, tr) {
  if (!entry) return ""
  if (entry.type === "image") {
    return "image screenshot " + String(entry.mime || "") + " " +
      String(entry.ocr || "") + " " + String(entry.title || "") + " " +
      String(entry.sourceApp || "")
  }
  var parts = [
    String(entry.text || ""),
    String(entry.title || ""),
    String(entry.ocr || ""),
    String(entry.sourceApp || ""),
    filePaths(entry).join(" ")
  ]
  var color = parseColor(entry.text)
  if (color) parts.push(color.hex, color.rgb, color.hsl)
  if (isLink(entry.text)) parts.push("link")
  if (isEmail(entry.text)) parts.push("email")
  if (isFileEntry(entry)) parts.push("file")
  return parts.join(" ")
}

function matchesQuery(entry, query, tr) {
  var needle = String(query || "").trim().toLowerCase()
  if (!needle) return true
  var haystack = searchableText(entry, tr).toLowerCase()
  var terms = needle.split(/\s+/)
  for (var i = 0; i < terms.length; i++) {
    if (haystack.indexOf(terms[i]) < 0) return false
  }
  return true
}

function displayRows(history, query, filterOrLimit, limitOrTr, tr, trn, fmt, now) {
  // Old callers pass (history, query, limit, tr, trn, fmt); the picker passes
  // (history, query, filter, limit, tr, trn, fmt, now). Keep both working.
  var args = arguments
  var filter = "all"
  var limit = 200
  var trFn = tr
  var trnFn = trn
  var fmtFn = fmt
  var nowMs = now
  if (typeof filterOrLimit === "number") {
    limit = filterOrLimit
    trFn = args[3]
    trnFn = args[4]
    fmtFn = args[5]
    nowMs = args[6]
  } else {
    filter = filterOrLimit
    limit = args[3]
    trFn = args[4]
    trnFn = args[5]
    fmtFn = args[6]
    nowMs = args[7]
  }

  var values = Array.isArray(history) ? history : []
  var kinds = filterKinds.indexOf(filter) >= 0 ? filter : "all"
  var max = limit === undefined || limit === null ? 200 : Number(limit)
  if (isNaN(max)) max = 200
  max = Math.max(0, max)
  if (max === 0) return []

  var pinned = []
  var rest = []

  for (var i = 0; i < values.length; i++) {
    var entry = cappedEntry(normalizeEntry(values[i]))
    if (!entry) continue

    var kind = entryKind(entry)
    if (kinds !== "all" && kind !== kinds) continue
    if (!matchesQuery(entry, query, trFn)) continue

    var paths = filePaths(entry)
    var isImage = entry.type === "image"
    var isFile = kind === "file"
    var color = kind === "color" ? parseColor(entry.text) : null
    var previewPath = isImage ? String(entry.path || "") : (isFile && paths.length === 1 && isImagePath(paths[0]) ? paths[0] : "")
    var legacyImageTime = isImage && !entry.capturedAtMs && String(entry.capturedAt || "").length > 0
    var timeLabel = legacyImageTime ? "" : relativeTime(entry.capturedAtMs, nowMs, trFn)
    if (!timeLabel && !legacyImageTime && entry.capturedAt) timeLabel = String(entry.capturedAt)
    var source = String(entry.sourceApp || "")
    var meta = []
    if (source) meta.push(source)
    if (timeLabel) meta.push(timeLabel)
    var row = {
      entryType: kind,
      fullText: isImage ? "" : fullText(entry),
      previewText: String(entry.title || previewText(entry, trFn, trnFn, fmtFn)),
      previewImage: previewPath,
      path: isImage ? String(entry.path || "") : (isFile && paths.length === 1 ? paths[0] : ""),
      mime: isImage ? String(entry.mime || "image/png") : "text/plain",
      pinned: entry.pinned === true,
      meta: meta.join(" · "),
      sourceApp: source,
      timeLabel: timeLabel,
      colorR: color ? color.r : 0,
      colorG: color ? color.g : 0,
      colorB: color ? color.b : 0,
      colorA: color ? color.a : 1,
      colorHex: color ? color.hexAlpha : "",
      colorRgb: color ? color.rgb : "",
      colorHsl: color ? color.hsl : "",
      url: kind === "link" ? String(entry.text || "").trim() : "",
      email: kind === "email" ? String(entry.text || "").trim() : "",
      index: i,
      historyIndex: i,
      hasOcr: String(entry.ocr || "").length > 0
    }
    if (entry.pinned) pinned.push(row)
    else rest.push(row)
  }

  var rows = pinned.concat(rest)
  return rows.length > max ? rows.slice(0, max) : rows
}

if (typeof module !== "undefined") {
  module.exports = {
    displayTextLimit: displayTextLimit,
    normalizeEntry: normalizeEntry,
    entryKey: entryKey,
    parseHistory: parseHistory,
    defaultSettings: defaultSettings,
    parseSettings: parseSettings,
    settingsJson: settingsJson,
    isAppDisabled: isAppDisabled,
    pruneHistory: pruneHistory,
    addEntry: addEntry,
    removeEntryAt: removeEntryAt,
    removeSince: removeSince,
    clearHistory: clearHistory,
    updateEntry: updateEntry,
    setPinned: setPinned,
    moveToTop: moveToTop,
    removedImagePaths: removedImagePaths,
    parseEntryJson: parseEntryJson,
    searchableText: searchableText,
    previewText: previewText,
    imagePreviewText: imagePreviewText,
    filePaths: filePaths,
    isFileEntry: isFileEntry,
    fileEntryText: fileEntryText,
    fullText: fullText,
    entryKind: entryKind,
    filterKinds: filterKinds,
    kindLabel: kindLabel,
    parseColor: parseColor,
    isLink: isLink,
    isEmail: isEmail,
    relativeTime: relativeTime,
    displayRows: displayRows
  }
}
