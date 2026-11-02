// Optional metadata every entry may carry: the pinboard it is pinned to, the
// app it was copied from, and when it was copied (epoch milliseconds). Values
// come from the history file, so they are bounded before they are kept.
var pinboardNameLimit = 64
var appIdLimit = 128

function boundedString(value, limit) {
  if (typeof value !== "string") return ""
  var text = value.replace(/[\u0000-\u001f\u007f]/g, " ").trim()
  return text.length > limit ? text.slice(0, limit) : text
}

function pinboardName(value) {
  return boundedString(value, pinboardNameLimit)
}

function withMetadata(entry, value) {
  var pinboard = pinboardName(value.pinboard)
  if (pinboard) entry.pinboard = pinboard
  var app = boundedString(value.app, appIdLimit)
  if (app) entry.app = app
  var copiedAt = Number(value.copiedAt)
  if (value.copiedAt !== undefined && value.copiedAt !== null && isFinite(copiedAt) && copiedAt > 0) entry.copiedAt = Math.floor(copiedAt)
  return entry
}

function normalizeEntry(value) {
  if (typeof value === "string")
    return value.trim().length > 0 ? { type: "text", text: value } : null

  if (!value || typeof value !== "object") return null

  var type = String(value.type || value.kind || "")
  if (type === "text") {
    var text = String(value.text || "")
    return text.trim().length > 0 ? withMetadata({ type: "text", text: text }, value) : null
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
    return withMetadata(entry, value)
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

// The new copy goes to the front. Copying something already in history moves
// it there instead of adding a second row, keeping its pinboard and the app it
// first came from. The limit only trims unpinned entries: a pinned entry stays
// until it is unpinned or deleted.
function addEntry(history, entry, limit) {
  var normalized = normalizeEntry(entry)
  var max = limit === undefined || limit === null ? 100 : Number(limit)
  if (isNaN(max)) max = 100
  max = Math.max(0, max)
  var values = Array.isArray(history) ? history : []
  if (!normalized) return trimmed(values, max)

  var key = entryKey(normalized)
  var rest = []
  for (var i = 0; i < values.length; i++) {
    var existing = normalizeEntry(values[i])
    if (!existing) continue
    if (entryKey(existing) === key) {
      if (existing.pinboard) normalized.pinboard = existing.pinboard
      if (existing.app) normalized.app = existing.app
      continue
    }
    rest.push(existing)
  }

  return trimmed([normalized].concat(rest), max)
}

function trimmed(values, max) {
  var next = []
  var unpinned = 0
  for (var i = 0; i < values.length; i++) {
    var entry = normalizeEntry(values[i])
    if (!entry) continue
    if (!entry.pinboard) {
      if (unpinned >= max) continue
      unpinned++
    }
    next.push(entry)
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

// Clearing history keeps pinned entries: they were saved on purpose.
function clearHistory(history) {
  var values = Array.isArray(history) ? history : []
  return values.filter(function(entry) { return !!(entry && entry.pinboard) })
}

function pinEntryAt(history, index, pinboard) {
  var values = Array.isArray(history) ? history.slice() : []
  var target = Number(index)
  var name = pinboardName(pinboard)
  if (!name || isNaN(target) || target < 0 || target >= values.length) return values

  var entry = normalizeEntry(values[target])
  if (!entry) return values
  entry.pinboard = name
  values[target] = entry
  return values
}

function unpinEntryAt(history, index) {
  var values = Array.isArray(history) ? history.slice() : []
  var target = Number(index)
  if (isNaN(target) || target < 0 || target >= values.length) return values

  var entry = normalizeEntry(values[target])
  if (!entry) return values
  delete entry.pinboard
  values[target] = entry
  return values
}

// Pinboards are named tabs. A board can exist before anything is pinned to it,
// so the saved list keeps the user's order and empty boards, and any board an
// entry names but the list lacks (a hand-edited file) is appended.
function parsePinboards(raw) {
  try {
    return pinboardList(JSON.parse(String(raw || "[]")), [])
  } catch (e) {
    return []
  }
}

function pinboardList(saved, history) {
  var names = []
  function add(value) {
    var name = pinboardName(value)
    if (name && names.indexOf(name) < 0) names.push(name)
  }

  if (Array.isArray(saved)) saved.forEach(add)
  if (Array.isArray(history)) history.forEach(function(entry) { if (entry) add(entry.pinboard) })
  return names
}

function renamePinboard(history, from, to) {
  var source = pinboardName(from)
  var target = pinboardName(to)
  var values = Array.isArray(history) ? history : []
  return values.map(function(value) {
    var entry = normalizeEntry(value)
    if (entry && source && target && entry.pinboard === source) entry.pinboard = target
    return entry
  }).filter(function(entry) { return !!entry })
}

// Deleting a board unpins its entries rather than deleting them, so they fall
// back into history and age out with everything else.
function removePinboard(history, name) {
  var board = pinboardName(name)
  var values = Array.isArray(history) ? history : []
  return values.map(function(value) {
    var entry = normalizeEntry(value)
    if (entry && board && entry.pinboard === board) delete entry.pinboard
    return entry
  }).filter(function(entry) { return !!entry })
}

function parseEntryJson(line) {
  var raw = String(line || "").trim()
  if (!raw) return null
  try { return normalizeEntry(JSON.parse(raw)) } catch (e) { return null }
}

function searchableText(entry) {
  if (!entry) return ""
  var app = entry.app ? " " + entry.app : ""
  if (entry.type === "image") return "image screenshot " + String(entry.mime || "") + " " + String(entry.capturedAt || "") + app
  return String(entry.text || "") + " " + fileEntryText(entry) + app
}

function isLink(entry) {
  if (!entry || entry.type !== "text") return false
  return /^(https?|ftp):\/\/\S+$/i.test(String(entry.text || "").trim())
}

// What the type filter matches on: image, file, link or text.
function entryKind(entry) {
  if (!entry) return ""
  if (entry.type === "image") return "image"
  if (filePaths(entry).length > 0) return "file"
  if (isLink(entry)) return "link"
  return "text"
}

var kinds = ["all", "text", "link", "image", "file"]

function kindOptions(tr) {
  var t = translator(tr)
  var labels = {
    all: t("clipboard.kindAll", "All"),
    text: t("clipboard.kindText", "Text"),
    link: t("clipboard.kindLinks", "Links"),
    image: t("clipboard.kindImages", "Images"),
    file: t("clipboard.kindFiles", "Files")
  }
  return kinds.map(function(kind) { return { value: kind, label: labels[kind] } })
}

function nextKind(kind, delta) {
  var index = kinds.indexOf(String(kind || "all"))
  if (index < 0) index = 0
  return kinds[(index + delta + kinds.length) % kinds.length]
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

// tr is an optional translate(key, english) from the QML side (I18n.t),
// trn its plural form (I18n.tn) and fmt a number formatter
// (I18n.formatNumber); without them the English text and plain digits
// stand, which is what the Node tests assert.
function translator(tr) {
  return typeof tr === "function" ? tr : function(key, english) { return english }
}

function characterCount(count, trn, fmt) {
  var tn = typeof trn === "function" ? trn : function(key, n, english) { return n === 1 ? english.one : english.other }
  var number = typeof fmt === "function" ? fmt : function(v) { return String(v) }
  var english = { one: "%1 character", other: "%1 characters" }
  var pattern = tn("clipboard.characters", count, english)
  // A catalog without the key hands the fallback object back unpicked.
  if (typeof pattern !== "string") pattern = count === 1 ? english.one : english.other
  return pattern.replace("%1", number(count))
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
  var timestamp = String(entry && entry.capturedAt || "")
  if (!timestamp) return t("clipboard.image", "Image")

  var screenshot = String(entry && entry.mime || "") === "image/png"
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
  return String(entry.text || "").replace(/\s+/g, " ")
}

function fullText(entry) {
  if (!entry) return ""
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
  // Keep the metadata: a long pinned snippet still belongs to its board.
  var cut = entry.text.lastIndexOf("\n", displayTextLimit)
  return withMetadata({ type: "text", text: entry.text.slice(0, cut > 0 ? cut : displayTextLimit) }, entry)
}

// filter narrows the rows to one pinboard ({ pinboard: name }; empty means
// all of history) and one kind ({ kind: "link" }; empty or "all" means any).
function displayRows(history, query, limit, tr, trn, fmt, filter) {
  var values = Array.isArray(history) ? history : []
  var needle = String(query || "").trim().toLowerCase()
  var max = limit === undefined || limit === null ? 50 : Number(limit)
  if (isNaN(max)) max = 50
  max = Math.max(0, max)
  if (max === 0) return []

  var board = pinboardName(filter && filter.pinboard)
  var kind = String(filter && filter.kind || "all")
  var rows = []

  for (var i = 0; i < values.length; i++) {
    var full = normalizeEntry(values[i])
    var entry = cappedEntry(full)
    if (!entry) continue
    if (board && entry.pinboard !== board) continue
    var entryKindValue = entryKind(entry)
    if (kind !== "all" && entryKindValue !== kind) continue
    if (needle && searchableText(entry).toLowerCase().indexOf(needle) < 0) continue

    var paths = filePaths(entry)
    var isFile = paths.length > 0
    var isImage = entry.type === "image"
    var previewPath = isImage ? String(entry.path || "") : (isFile && paths.length === 1 && isImagePath(paths[0]) ? paths[0] : "")
    rows.push({
      entryType: isFile ? "file" : entry.type,
      kind: entryKindValue,
      fullText: isImage ? "" : fullText(entry),
      previewText: previewText(entry, tr, trn, fmt),
      previewImage: previewPath,
      path: isImage ? String(entry.path || "") : (isFile && paths.length === 1 ? paths[0] : ""),
      mime: isImage ? String(entry.mime || "image/png") : "text/plain",
      pinboard: entry.pinboard || "",
      app: entry.app || "",
      copiedAt: entry.copiedAt || 0,
      textLength: isImage || isFile ? 0 : full.text.length,
      index: i
    })
    if (rows.length >= max) break
  }

  return rows
}

if (typeof module !== "undefined") {
  module.exports = {
    normalizeEntry: normalizeEntry,
    entryKey: entryKey,
    pinboardName: pinboardName,
    parseHistory: parseHistory,
    addEntry: addEntry,
    removeEntryAt: removeEntryAt,
    clearHistory: clearHistory,
    pinEntryAt: pinEntryAt,
    unpinEntryAt: unpinEntryAt,
    parsePinboards: parsePinboards,
    pinboardList: pinboardList,
    renamePinboard: renamePinboard,
    removePinboard: removePinboard,
    entryKind: entryKind,
    kindOptions: kindOptions,
    characterCount: characterCount,
    nextKind: nextKind,
    parseEntryJson: parseEntryJson,
    searchableText: searchableText,
    previewText: previewText,
    imagePreviewText: imagePreviewText,
    filePaths: filePaths,
    fileEntryText: fileEntryText,
    fullText: fullText,
    displayRows: displayRows
  }
}
