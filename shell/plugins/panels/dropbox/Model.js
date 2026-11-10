var IMAGE_EXTENSIONS = {
  jpg: true, jpeg: true, png: true, gif: true, webp: true, avif: true, heic: true,
  svg: true, bmp: true, tif: true, tiff: true
}

var VIDEO_EXTENSIONS = {
  mp4: true, mov: true, mkv: true, webm: true, avi: true, m4v: true, mpg: true,
  mpeg: true, wmv: true
}

var DOCUMENT_EXTENSIONS = {
  pdf: true, txt: true, md: true, doc: true, docx: true, xls: true, xlsx: true,
  ppt: true, pptx: true, odt: true, ods: true, odp: true, rtf: true, csv: true,
  pages: true, numbers: true, key: true
}

function translator(tr) {
  return typeof tr === "function" ? tr : function(key, english) { return english }
}

// Display numbers go through the shell's I18n.formatNumber when QML passes
// it; Node tests leave it out and get plain English digits.
function formatter(fmt) {
  return typeof fmt === "function" ? fmt : function(v, d) { return d === undefined ? String(v) : Number(v).toFixed(d) }
}

function parseStatus(raw) {
  var text = String(raw || "").trim()
  if (text === "") return defaultStatus()
  try {
    var parsed = JSON.parse(text)
    if (!parsed || typeof parsed !== "object") return defaultStatus()
    parsed.files = Array.isArray(parsed.files) ? parsed.files : []
    return parsed
  } catch (e) {
    var failed = defaultStatus()
    failed.ok = false
    failed.lastError = "Failed to parse Dropbox status"
    return failed
  }
}

// Dropbox reports transfer details as separate status lines, including speed and ETA.
function isSyncing(status) {
  return /\b(syncing|uploading|downloading)\b/i.test(String(status || ""))
}

function syncDetails(status, fmt, tr) {
  var t = translator(tr)
  var f = formatter(fmt)
  var lines = String(status || "").trim().split(/\n/)
  var transfers = lines.filter(function(line) { return /^(Downloading|Uploading)\b/i.test(line) })
  var transfer = transfers.filter(function(line) { return /B\/(?:sec|s)\b/i.test(line) })[0] || transfers[0] || lines[0] || ""
  var rate = transfer.match(/([\d,.]+)\s*([KMGT]?)B\/(?:sec|s)\b/i)
  var speed = ""
  if (rate) {
    var unit = rate[2] === "" ? 0 : "KMGT".indexOf(rate[2].toUpperCase()) + 1
    speed = formatBytes(Number(rate[1].replace(/,/g, "")) * Math.pow(1000, unit), fmt) + "/s"
  }
  var overall = lines[0].match(/^Syncing\s+([\d,]+)\s+files?\b/i)
  var count = transfer.match(/([\d,]+)\s+files?\b/i)
  var remaining = overall ? Number(overall[1].replace(/,/g, "")) : count ? Number(count[1].replace(/,/g, "")) : 0
  var action = transfers.length > 1 ? "syncing" : /^Downloading/i.test(transfer) ? "downloading" : /^Uploading/i.test(transfer) ? "uploading" : "syncing"
  var label = t("dropbox.syncing", "Syncing…")
  if (count || overall) {
    var labelCount = transfers.length > 1 ? remaining : count ? Number(count[1].replace(/,/g, "")) : remaining
    var one = labelCount === 1
    var pattern = action === "downloading" ? (one ? t("dropbox.downloadingOne", "Downloading %1 file") : t("dropbox.downloadingFiles", "Downloading %1 files"))
      : action === "uploading" ? (one ? t("dropbox.uploadingOne", "Uploading %1 file") : t("dropbox.uploadingFiles", "Uploading %1 files"))
      : one ? t("dropbox.syncingOne", "Syncing %1 file") : t("dropbox.syncingFiles", "Syncing %1 files")
    label = pattern.replace("%1", f(labelCount))
  }
  var etaMatch = (lines[0].split(/[•·]/)[1] || "").trim().match(/^(\d+)(\+?)\s*(sec(?:ond)?s?|min(?:ute)?s?|hours?|days?)$/i)
  var eta = ""
  if (etaMatch) {
    var amount = Number(etaMatch[1])
    var singular = amount === 1 && etaMatch[2] === ""
    var timePattern = /^sec/i.test(etaMatch[3]) ? (singular ? t("dropbox.etaSecondsOne", "%1 sec") : t("dropbox.etaSeconds", "%1 secs"))
      : /^min/i.test(etaMatch[3]) ? (singular ? t("dropbox.etaMinutesOne", "%1 min") : t("dropbox.etaMinutes", "%1 mins"))
      : /^hour/i.test(etaMatch[3]) ? (singular ? t("dropbox.etaHoursOne", "%1 hour") : t("dropbox.etaHours", "%1 hours"))
      : singular ? t("dropbox.etaDaysOne", "%1 day") : t("dropbox.etaDays", "%1 days")
    eta = timePattern.replace("%1", f(amount) + etaMatch[2])
  }
  return { label: label, detail: [speed, eta].filter(function(value) { return value !== "" }).join(" · "), remaining: remaining }
}

function defaultStatus() {
  return {
    ok: true,
    installed: false,
    running: false,
    authenticated: false,
    statusText: "Unavailable",
    accountPath: "",
    plan: "",
    usedBytes: 0,
    quotaBytes: 0,
    usagePercent: 0,
    quotaKnown: false,
    files: []
  }
}

function fileExtension(name) {
  var value = String(name || "").toLowerCase()
  var index = value.lastIndexOf(".")
  return index >= 0 ? value.substring(index + 1) : ""
}

function fileKind(name) {
  var ext = fileExtension(name)
  if (IMAGE_EXTENSIONS[ext]) return "image"
  if (VIDEO_EXTENSIONS[ext]) return "video"
  if (DOCUMENT_EXTENSIONS[ext]) return "document"
  return "misc"
}

function fileGlyph(name) {
  var kind = fileKind(name)
  if (kind === "image") return "󰋩"
  if (kind === "video") return "󰈫"
  if (kind === "document") return "󰈙"
  return "󰈔"
}

function formatBytes(bytes, fmt) {
  var f = formatter(fmt)
  var value = Number(bytes || 0)
  if (!isFinite(value) || value <= 0) return f(0) + " B"
  var units = ["B", "KB", "MB", "GB", "TB"]
  var index = 0
  while (value >= 1000 && index < units.length - 1) {
    value = value / 1000
    index++
  }
  var decimals = value >= 100 || index === 0 ? 0 : (value >= 10 ? 1 : 2)
  // Rounding through Number drops the trailing zeros ("1.50" reads 1.5).
  return f(Number(value.toFixed(decimals))) + " " + units[index]
}

function formatPercent(value, fmt) {
  var f = formatter(fmt)
  var number = Number(value || 0)
  if (!isFinite(number) || number <= 0) return f(0) + "%"
  if (number >= 10) return f(Math.round(number)) + "%"
  return f(Number(number.toFixed(1))) + "%"
}

function usageText(usedBytes, quotaBytes, quotaKnown, tr, fmt) {
  if (quotaKnown && Number(quotaBytes || 0) > 0) {
    return translator(tr)("dropbox.usedOfQuota", "%1 of %2").replace("%1", formatBytes(usedBytes, fmt)).replace("%2", formatBytes(quotaBytes, fmt))
  }
  return formatBytes(usedBytes, fmt)
}

function relativeTime(timestampSec, nowMs, tr, fmt) {
  var t = translator(tr)
  var f = formatter(fmt)
  var ts = Number(timestampSec || 0)
  if (!isFinite(ts) || ts <= 0) return t("dropbox.unknownTime", "Unknown time")
  var now = nowMs === undefined || nowMs === null ? Date.now() : Number(nowMs)
  var diff = Math.max(0, Math.floor((now - ts * 1000) / 1000))
  if (diff < 60) return t("dropbox.justNow", "Just now")
  var minutes = Math.floor(diff / 60)
  if (minutes < 60) return t("dropbox.minutesAgo", "%1m ago").replace("%1", f(minutes))
  var hours = Math.floor(minutes / 60)
  if (hours < 24) return t("dropbox.hoursAgo", "%1h ago").replace("%1", f(hours))
  var days = Math.floor(hours / 24)
  if (days < 30) return t("dropbox.daysAgo", "%1d ago").replace("%1", f(days))
  if (days < 365) return t("dropbox.monthsAgo", "%1mo ago").replace("%1", f(Math.min(11, Math.floor(days / 30))))
  return t("dropbox.yearsAgo", "%1y ago").replace("%1", f(Math.floor(days / 365)))
}

function fileMeta(file, nowMs, tr, fmt) {
  if (!file) return ""
  var parts = [relativeTime(file.modifiedTs, nowMs, tr, fmt)]
  var folder = String(file.folder || "")
  if (folder !== "") parts.push(folder)
  return parts.join(" · ")
}

if (typeof module !== "undefined") {
  module.exports = {
    parseStatus: parseStatus,
    isSyncing: isSyncing,
    syncDetails: syncDetails,
    defaultStatus: defaultStatus,
    fileExtension: fileExtension,
    fileKind: fileKind,
    fileGlyph: fileGlyph,
    formatBytes: formatBytes,
    formatPercent: formatPercent,
    usageText: usageText,
    relativeTime: relativeTime,
    fileMeta: fileMeta
  }
}
