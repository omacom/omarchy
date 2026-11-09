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

// dropboxd reports sync as lines like "Syncing 20,413 files • 51 mins" and
// "Downloading 20,413 files (57,853 KB/sec, 51 mins)", never as a fraction.
// remaining is the first file count it names, or -1 when it names none
// ("Syncing...", "Downloading file list..."); detail is the summary first line.
var SYNC_PATTERN = /^(syncing|downloading|uploading|indexing)\b/i

function parseSync(statusText) {
  var lines = String(statusText || "").split("\n").map(function(line) { return line.trim() }).filter(function(line) { return line !== "" })
  var syncing = lines.some(function(line) { return SYNC_PATTERN.test(line) && !/paused/i.test(line) })
  if (!syncing) return { syncing: false, remaining: -1, detail: "" }
  var remaining = -1
  for (var i = 0; i < lines.length && remaining < 0; i++) {
    var match = lines[i].match(/(\d[\d,.'\s\u00a0\u202f]*)\s+files?\b/i)
    if (match) remaining = parseInt(match[1].replace(/\D/g, ""), 10)
  }
  return { syncing: true, remaining: isFinite(remaining) ? remaining : -1, detail: lines[0] }
}

// The largest backlog seen in this sync run is the denominator. A paused or
// stopped daemon keeps it, so resuming picks up where the bar left off; only
// a running daemon that has finished syncing starts the next run from zero.
function nextSyncPeak(peak, sync, running) {
  if (sync && sync.syncing) return Math.max(Number(peak || 0), Number(sync.remaining || 0))
  return running ? 0 : Number(peak || 0)
}

// 0..1 done, or -1 when there is no file count to measure against.
function syncProgress(remaining, peak) {
  var left = Number(remaining)
  var total = Number(peak)
  if (!isFinite(left) || left < 0 || !isFinite(total) || total <= 0) return -1
  return Math.max(0, Math.min(1, 1 - left / total))
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
    defaultStatus: defaultStatus,
    parseSync: parseSync,
    nextSyncPeak: nextSyncPeak,
    syncProgress: syncProgress,
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
