// Byte bounds for clipboard text. Without them one large copy was carried whole
// through the watcher line, every save and every startup load, at several times
// its size each time. Text is measured in UTF-16 units; a UTF-8 byte count is
// never smaller, so an entry capture.sh accepts by bytes is always accepted here.
var entryTextLimit = 2 * 1024 * 1024
// The longest line the watcher can legitimately send: an entry at the limit
// whose every character JSON-escapes to six.
var captureLineLimit = entryTextLimit * 6 + 64
// Serialized size of everything kept, newest first. Past it the oldest entries
// are dropped, the same way the entry-count limit already drops them.
var historyBudget = 8 * 1024 * 1024
// Largest file load-history.sh accepts. It must cover the heaviest history the
// budget allows, every kept unit a three-byte character, or the loader would
// reject a file the overlay wrote itself.
var historyFileLimit = 32 * 1024 * 1024

// A text copy over entryTextLimit is kept as a file instead, like an image, with
// only a short preview in history. These bound that per copy, for all copies
// together (the oldest go first), and for the preview kept for display.
var largeTextLimit = 256 * 1024 * 1024
var largeTextBudget = 1024 * 1024 * 1024
var largePreviewLimit = 8192

// Large copies live only as <sha256>.txt in an omarchy/clipboard-text folder.
// Anything else is refused, so a crafted history cannot point a paste at an
// arbitrary file.
function isLargeTextPath(path) {
  var value = String(path || "")
  return /^\/(?:[^\/]+\/)*omarchy\/clipboard-text\/[0-9a-f]{64}\.txt$/.test(value)
    && value.split("/").indexOf("..") < 0
}

function sizeLabel(bytes) {
  return (Number(bytes) / 1048576).toFixed(1) + " MB"
}

function entrySize(entry) {
  return JSON.stringify(entry).length
}

function normalizeEntry(value) {
  if (typeof value === "string") {
    if (value.length > entryTextLimit) return null
    return value.trim().length > 0 ? { type: "text", text: value } : null
  }

  if (!value || typeof value !== "object") return null

  var type = String(value.type || value.kind || "")
  if (type === "text") {
    var text = String(value.text || "")
    if (text.length > entryTextLimit) return null
    return text.trim().length > 0 ? { type: "text", text: text } : null
  }

  if (type === "image") {
    var path = String(value.path || "")
    if (!path) return null
    var entry = {
      type: "image",
      path: path,
      mime: String(value.mime || "image/png")
    }
    if (value.capturedAt !== undefined && value.capturedAt !== null)
      entry.capturedAt = String(value.capturedAt)
    return entry
  }

  if (type === "largetext") {
    var largePath = String(value.path || "")
    var bytes = Number(value.bytes)
    if (!isLargeTextPath(largePath)) return null
    if (!(bytes > 0) || bytes > largeTextLimit || Math.floor(bytes) !== bytes) return null
    return {
      type: "largetext",
      path: largePath,
      bytes: bytes,
      preview: String(value.preview || "").slice(0, largePreviewLimit)
    }
  }

  return null
}

function entryKey(entry) {
  if (!entry) return ""
  if (entry.type === "image") return "image:" + String(entry.path || "")
  if (entry.type === "largetext") return "largetext:" + String(entry.path || "")
  return "text:" + String(entry.text || "")
}

// Returns null, never [], for a history it cannot read: an empty result would be
// saved over the file at the next copy and destroy it.
function parseHistory(raw, limit) {
  var parsed
  try { parsed = JSON.parse(String(raw || "[]")) } catch (e) { return null }
  if (!Array.isArray(parsed)) return null

  var max = limit === undefined || limit === null ? Infinity : Math.max(0, Number(limit) || 0)
  var next = []
  var used = 0
  var largeUsed = 0
  for (var i = 0; i < parsed.length && next.length < max; i++) {
    var entry = normalizeEntry(parsed[i])
    if (!entry) continue
    if (entry.type === "largetext" && largeUsed + entry.bytes > largeTextBudget) continue
    var size = entrySize(entry)
    if (next.length > 0 && used + size > historyBudget) break
    if (entry.type === "largetext") largeUsed += entry.bytes
    used += size
    next.push(entry)
  }
  return next
}

function addEntry(history, entry, limit) {
  var normalized = normalizeEntry(entry)
  var max = limit === undefined || limit === null ? 100 : Number(limit)
  if (isNaN(max)) max = 100
  max = Math.max(0, max)
  if (!normalized) return Array.isArray(history) ? history.slice(0, max) : []
  if (max === 0) return []

  var key = entryKey(normalized)
  var next = [normalized]
  var used = entrySize(normalized)
  var largeUsed = normalized.type === "largetext" ? normalized.bytes : 0
  var values = Array.isArray(history) ? history : []

  // The newest entry is always kept; older ones only while they fit the budget.
  // Past the disk budget the oldest large copies go first and small entries stay.
  for (var i = 0; i < values.length && next.length < max; i++) {
    var existing = normalizeEntry(values[i])
    if (!existing || entryKey(existing) === key) continue
    if (existing.type === "largetext" && largeUsed + existing.bytes > largeTextBudget) continue
    var size = entrySize(existing)
    if (used + size > historyBudget) break
    if (existing.type === "largetext") largeUsed += existing.bytes
    used += size
    next.push(existing)
  }

  return next
}

function removeEntryAt(history, index) {
  var values = Array.isArray(history) ? history : []
  var target = Number(index)
  if (isNaN(target) || target < 0 || target >= values.length) return values.slice()

  var next = values.slice()
  next.splice(target, 1)
  return next
}

function clearHistory() {
  return []
}

// Classifies one line from the clipboard watcher. An oversized copy is reported
// as skipped so the overlay can say so, whether capture.sh caught it or not. The
// length check runs before parsing so a runaway line is never parsed at all.
function captureResult(line) {
  var raw = String(line || "")
  if (raw.length > captureLineLimit) return { kind: "skipped" }

  var value
  try { value = JSON.parse(raw.trim()) } catch (e) { return { kind: "ignore" } }
  if (value && value.type === "skipped") return { kind: "skipped" }
  if (value && value.type === "text" && String(value.text || "").length > entryTextLimit) return { kind: "skipped" }

  var entry = normalizeEntry(value)
  return entry ? { kind: "entry", entry: entry } : { kind: "ignore" }
}

function searchableText(entry) {
  if (!entry) return ""
  if (entry.type === "image") return "image screenshot " + String(entry.mime || "") + " " + String(entry.capturedAt || "")
  if (entry.type === "largetext") return String(entry.preview || "")
  return String(entry.text || "") + " " + fileEntryText(entry)
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

function fileName(path) {
  var parts = String(path || "").split("/")
  return parts.length > 0 ? parts[parts.length - 1] : String(path || "")
}

function isImagePath(path) {
  return /\.(png|jpe?g|webp|gif|bmp|tiff?)$/i.test(String(path || ""))
}

function fileEntryText(entry) {
  var paths = filePaths(entry)
  if (paths.length === 0) return ""
  if (paths.length === 1) return fileName(paths[0])
  return paths.length + " files"
}

function imagePreviewText(entry) {
  var timestamp = String(entry && entry.capturedAt || "")
  if (!timestamp) return "Image"

  var label = String(entry && entry.mime || "") === "image/png" ? "Screenshot" : "Image"
  return label + " from " + timestamp
}

function previewText(entry) {
  if (!entry) return ""
  if (entry.type === "image") return imagePreviewText(entry)
  if (entry.type === "largetext") return sizeLabel(entry.bytes) + " · " + String(entry.preview || "").replace(/\s+/g, " ")
  var fileText = fileEntryText(entry)
  if (fileText) return fileText
  return String(entry.text || "").replace(/\s+/g, " ")
}

function fullText(entry) {
  if (!entry) return ""
  if (entry.type === "largetext") return String(entry.preview || "") + "\n\n… " + sizeLabel(entry.bytes) + " in all"
  var paths = filePaths(entry)
  if (paths.length > 0) return paths.join("\n")
  return String(entry.text || "")
}

// The picker only ever searches and renders a prefix of an entry, so scan and
// render just that much. A single huge paste otherwise costs hundreds of
// megabytes of string work on every keystroke and stalls the whole shell.
// Pasting reads the full entry back from history by index, so nothing is lost.
var displayTextLimit = 8192

function cappedEntry(entry) {
  if (!entry || entry.type !== "text" || entry.text.length <= displayTextLimit) return entry

  // Cut on a line break so a file:// URI never truncates into a bogus path.
  var cut = entry.text.lastIndexOf("\n", displayTextLimit)
  return { type: "text", text: entry.text.slice(0, cut > 0 ? cut : displayTextLimit) }
}

function displayRows(history, query, limit) {
  var values = Array.isArray(history) ? history : []
  var needle = String(query || "").trim().toLowerCase()
  var max = limit === undefined || limit === null ? 50 : Number(limit)
  if (isNaN(max)) max = 50
  max = Math.max(0, max)
  if (max === 0) return []

  var rows = []

  for (var i = 0; i < values.length; i++) {
    var entry = cappedEntry(normalizeEntry(values[i]))
    if (!entry) continue
    if (needle && searchableText(entry).toLowerCase().indexOf(needle) < 0) continue

    var paths = filePaths(entry)
    var isFile = paths.length > 0
    var isImage = entry.type === "image"
    var previewPath = isImage ? String(entry.path || "") : (isFile && paths.length === 1 && isImagePath(paths[0]) ? paths[0] : "")
    rows.push({
      entryType: isFile ? "file" : entry.type,
      fullText: isImage ? "" : fullText(entry),
      previewText: previewText(entry),
      previewImage: previewPath,
      path: isImage || entry.type === "largetext" ? String(entry.path || "") : (isFile && paths.length === 1 ? paths[0] : ""),
      mime: isImage ? String(entry.mime || "image/png") : (entry.type === "largetext" ? "text/plain;charset=utf-8" : "text/plain"),
      index: i
    })
    if (rows.length >= max) break
  }

  return rows
}

// File names of the large copies history still uses, for prune-text.sh.
function largeTextNames(history) {
  var values = Array.isArray(history) ? history : []
  var names = []
  for (var i = 0; i < values.length; i++) {
    var entry = normalizeEntry(values[i])
    if (entry && entry.type === "largetext") names.push(entry.path.slice(entry.path.lastIndexOf("/") + 1))
  }
  return names
}

if (typeof module !== "undefined") {
  module.exports = {
    normalizeEntry: normalizeEntry,
    entryKey: entryKey,
    parseHistory: parseHistory,
    addEntry: addEntry,
    removeEntryAt: removeEntryAt,
    clearHistory: clearHistory,
    captureResult: captureResult,
    entryTextLimit: entryTextLimit,
    captureLineLimit: captureLineLimit,
    historyBudget: historyBudget,
    historyFileLimit: historyFileLimit,
    largeTextLimit: largeTextLimit,
    largeTextBudget: largeTextBudget,
    largePreviewLimit: largePreviewLimit,
    searchableText: searchableText,
    previewText: previewText,
    imagePreviewText: imagePreviewText,
    filePaths: filePaths,
    fileEntryText: fileEntryText,
    fullText: fullText,
    displayRows: displayRows,
    largeTextNames: largeTextNames
  }
}
