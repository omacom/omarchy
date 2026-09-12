function stripJsonc(raw) {
  return String(raw || "")
    .replace(/^\s*\/\/[^\n]*(\n|$)/gm, "")
    .replace(/,(\s*[}\]])/g, "$1")
}

function normalizeAliases(value) {
  if (Array.isArray(value)) return value.filter(function(v) { return v })
  if (typeof value === "string" && value) return [value]
  return []
}

// Prompt-first rows: `input: {prompt, action}` opens input mode and runs the
// template with the answer in place of {}. Anything else (missing, mistyped,
// or action-less) is not an input row.
function normalizeInput(value) {
  if (!value || typeof value !== "object" || Array.isArray(value)) return null
  if (typeof value.action !== "string" || !value.action) return null
  var prompt = typeof value.prompt === "string" && value.prompt ? value.prompt : "Input"
  return { prompt: prompt, action: value.action }
}

function normalizeItem(id, raw) {
  var value = raw || {}
  var aliases = normalizeAliases(value.aliases)
  var parent = value.parent
  if (parent === undefined)
    parent = id.indexOf(".") >= 0 ? id.split(".").slice(0, -1).join(".") : "root"
  if (id === "root") parent = ""

  var kind = value.scope ? "menu" : (value.action ? "action" : (value.target ? "link" : "menu"))

  var itemObj = {
    id: id,
    parent: parent,
    kind: kind,
    icon: value.icon || "",
    iconFont: value.iconFont || "",
    label: value.label || id,
    title: value.title || "",
    target: value.target || "",
    description: value.description || "",
    action: value.action || "",
    provider: value.provider || "",
    aliases: aliases,
    when: value.when || "",
    checked: value.checked || "",
    disabled: value.disabled || ""
  }
  if (value.scope) {
    itemObj.scope = String(value.scope)
    if (value.placeholder) itemObj.placeholder = String(value.placeholder)
  }
  if (value.flat !== undefined) itemObj.flat = !!value.flat
  var input = normalizeInput(value.input)
  if (input) itemObj.input = input
  return itemObj
}

function parseMenuJsonc(raw) {
  var stripped = stripJsonc(raw)
  if (!stripped.trim()) return []

  var parsed
  try {
    parsed = JSON.parse(stripped)
  } catch (e) {
    return []
  }
  if (typeof parsed !== "object" || parsed === null) return []

  var source = (parsed.items && typeof parsed.items === "object" && !Array.isArray(parsed.items))
    ? parsed.items
    : parsed
  var out = []
  for (var id in source) {
    var entry = source[id]
    if (!entry || typeof entry !== "object" || Array.isArray(entry)) continue
    out.push(normalizeItem(id, entry))
  }
  return out
}

function mergeMenuSources(defaultItems, userItems) {
  var nextItems = ({})
  var nextOrder = []
  var sources = [defaultItems || [], userItems || []]

  for (var s = 0; s < sources.length; s++) {
    var src = sources[s]
    for (var i = 0; i < src.length; i++) {
      var entry = src[i]
      if (!entry || !entry.id) continue
      if (!nextItems[entry.id]) nextOrder.push(entry.id)
      var prior = nextItems[entry.id] || {}
      var merged = {}
      for (var k in prior) merged[k] = prior[k]
      for (var k2 in entry) merged[k2] = entry[k2]
      merged.id = entry.id
      nextItems[entry.id] = merged
    }
  }

  if (!nextItems.root) {
    nextItems.root = { id: "root", parent: "", kind: "menu", icon: "", iconFont: "", label: "Go", title: "", target: "", description: "", aliases: [], when: "", checked: "", disabled: "", action: "", provider: "" }
    nextOrder.unshift("root")
  }
  for (var k3 = 0; k3 < nextOrder.length; k3++) nextItems[nextOrder[k3]].order = k3

  return {
    items: nextItems,
    itemOrder: nextOrder
  }
}

// Both merges below return fresh items/itemOrder objects for the caller to
// assign in one go. They must never write into the maps they are handed: those
// live in QML `var` properties, and an in-place write into such an object is
// occasionally dropped by the engine — the key lands with an undefined value.
// A lost write used to leave an id in itemOrder with no item behind it, and
// the next merge then kept that orphan and appended a second row for the same
// app, so the launcher listed it twice (and again on every later rescan).

// Swaps every app row for the current set. Rows keep the order they arrive in;
// ids already claimed (including duplicate desktop ids) are listed once.
function mergeAppRows(items, itemOrder, appRows) {
  var source = items || ({})
  var order = Array.isArray(itemOrder) ? itemOrder : []
  var rows = Array.isArray(appRows) ? appRows : []
  var nextItems = ({})
  var nextOrder = []

  for (var i = 0; i < order.length; i++) {
    var id = order[i]
    var existing = source[id]
    // Orphans (an id with no item) are dropped rather than carried forward,
    // so a single lost write cannot compound into a duplicate row.
    if (!existing || existing.kind === "app") continue
    nextItems[id] = existing
    nextOrder.push(id)
  }

  for (var j = 0; j < rows.length; j++) {
    var row = rows[j]
    if (!row || !row.id || nextItems[row.id]) continue
    row.order = nextOrder.length
    nextItems[row.id] = row
    nextOrder.push(row.id)
  }

  return { items: nextItems, itemOrder: nextOrder }
}

// Swaps the rows one provider contributed, leaving every other item untouched.
// Rows carry the id of the submenu that produced them, so a provider that runs
// again drops its previous batch — a plugin that was just enabled disappears
// from the Enable list — without disturbing static children declared in JSONC.
function swapProviderRows(items, itemOrder, menuId, rows) {
  var source = items || ({})
  var order = Array.isArray(itemOrder) ? itemOrder : []
  var incoming = Array.isArray(rows) ? rows : []
  var nextItems = ({})
  var nextOrder = []

  for (var i = 0; i < order.length; i++) {
    var id = order[i]
    var existing = source[id]
    if (!existing || existing.providerMenu === menuId) continue
    nextItems[id] = existing
    nextOrder.push(id)
  }

  for (var j = 0; j < incoming.length; j++) {
    var row = incoming[j]
    if (!row || !row.id || nextItems[row.id]) continue
    row.providerMenu = menuId
    row.order = nextOrder.length
    nextItems[row.id] = row
    nextOrder.push(row.id)
  }

  return { items: nextItems, itemOrder: nextOrder }
}

function item(items, id) {
  return items && items[id] ? items[id] : null
}

// Routes may name a real id (`system`, `setup.power`) or an alias declared in
// JSONC (`power-menu`, `settings`). An exact id beats any alias, and app rows
// are never routable: their aliases carry .desktop Keywords and GenericName
// for search, so an installed application could otherwise shadow a menu route
// (htop ships `Keywords=system;...`). Unknown strings fall through as the
// literal input so misspellings still attempt to open that id.
function resolveRoute(items, itemOrder, input) {
  var raw = String(input || "").toLowerCase().replace(/_/g, "-")
  if (!raw || raw === "go" || raw === "menu") return "root"
  if (item(items, raw)) return raw
  var order = Array.isArray(itemOrder) ? itemOrder : []
  for (var i = 0; i < order.length; i++) {
    var entry = item(items, order[i])
    if (!entry || entry.kind === "app" || !entry.aliases) continue
    for (var j = 0; j < entry.aliases.length; j++) {
      var alias = String(entry.aliases[j] || "").toLowerCase().replace(/_/g, "-")
      if (alias === raw) return entry.id
    }
  }
  return raw
}

function slugify(value) {
  return String(value || "").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "") || "item"
}

function depthFor(items, id) {
  var depth = 0
  var current = item(items, id)
  var guard = 0

  while (current && current.parent && current.parent !== "root" && guard < 32) {
    depth += 1
    current = item(items, current.parent)
    guard += 1
  }

  return depth
}

function pathFor(items, id) {
  var current = item(items, id)
  if (!current) return ""
  if (current._path !== undefined) return current._path

  var labels = []
  var guard = 0
  var walk = current

  while (walk && walk.id !== "root" && guard < 32) {
    labels.unshift(walk.label || walk.id)
    walk = item(items, walk.parent)
    guard += 1
  }

  current._path = labels.join(" › ")
  return current._path
}

function parentPathFor(items, id) {
  var entry = item(items, id)
  if (!entry || !entry.parent || entry.parent === "root") return ""
  if (entry._parentPath !== undefined) return entry._parentPath
  entry._parentPath = pathFor(items, entry.parent)
  return entry._parentPath
}

function isDescendantOf(items, id, ancestorId) {
  if (ancestorId === "root") return id !== "root"

  var current = item(items, id)
  var guard = 0
  while (current && current.parent && guard < 32) {
    if (current.parent === ancestorId) return true
    current = item(items, current.parent)
    guard += 1
  }

  return false
}

function isSearchableDescendant(items, id, ancestorId) {
  if (!id || id === "root") return false
  if (id === ancestorId) return true

  var current = item(items, id)
  var guard = 0
  while (current && current.parent && guard < 32) {
    if (current.parent === ancestorId) return true
    var pEntry = item(items, current.parent)
    if (pEntry && pEntry.flat === false) return false
    current = pEntry
    guard += 1
  }

  return false
}

function childCount(items, itemOrder, id) {
  var count = 0
  var order = Array.isArray(itemOrder) ? itemOrder : []
  for (var i = 0; i < order.length; i++) {
    var entry = item(items, order[i])
    if (entry && entry.parent === id) count += 1
  }
  return count
}

function isVisible(items, itemOrder, whenResults, entry, depth) {
  if (!entry) return false
  if (entry.when && whenResults && whenResults[entry.id] === false) return false
  if (entry.kind !== "menu" && entry.kind !== "link") return true
  if (entry.provider) return true
  if (entry.scope) return true

  var guard = depth || 0
  if (guard >= 32) return false

  var target = entry.kind === "link" ? entry.target : entry.id
  var order = Array.isArray(itemOrder) ? itemOrder : []
  for (var i = 0; i < order.length; i++) {
    var child = item(items, order[i])
    if (child && child.parent === target && isVisible(items, itemOrder, whenResults, child, guard + 1)) return true
  }

  return false
}

// A `disabled:` row stays listed but goes dim and unselectable. The
// Install submenus use it so software already on the machine reads as
// installed rather than disappearing from the list it was installed from.
function isDisabled(disabledResults, entry) {
  if (!entry || !entry.disabled) return false
  return !!(disabledResults && disabledResults[entry.id])
}

// A disabled row is software you already have, which is the same thing the ✓
// says everywhere else in the menu, so it earns the same marker.
function labelFor(entry, checkedResults, disabledResults) {
  if (!entry) return ""
  var marked = (entry.checked && checkedResults && checkedResults[entry.id]) || isDisabled(disabledResults, entry)
  return marked ? entry.label + " ✓" : entry.label
}

function searchableToken(value) {
  return String(value || "").replace(/[._-]+/g, " ")
}

function leafIdFor(id) {
  var parts = String(id || "").split(".")
  return parts.length > 0 ? parts[parts.length - 1] : id
}

function nameSearchText(entry) {
  if (!entry) return ""
  if (entry._nameSearchText !== undefined) return entry._nameSearchText
  var aliases = []
  var values = Array.isArray(entry.aliases) ? entry.aliases : []
  for (var i = 0; i < values.length; i++) aliases.push(searchableToken(values[i]))
  var text = [entry.label, searchableToken(leafIdFor(entry.id)), aliases.join(" ")].join(" ").toLowerCase()
  entry._nameSearchText = text
  return text
}

function termInSearchWords(term, text) {
  var words = String(text || "").toLowerCase().split(/\s+/)
  for (var i = 0; i < words.length; i++) {
    if (words[i] === term) return true
  }
  return false
}

function descriptionTextMatches(query, text) {
  var terms = String(query || "").toLowerCase().trim().split(/\s+/)
  for (var i = 0; i < terms.length; i++) {
    if (terms[i] && !termInSearchWords(terms[i], text)) return false
  }
  return true
}

// Minimum fuzzy score required to accept a subsequence match. Prevents loose
// single-character matches from producing false positives across unrelated words.
var FUZZY_MIN_SCORE = 35

var levRow0 = new Int32Array(64)
var levRow1 = new Int32Array(64)
var levRow2 = new Int32Array(64)

function damerauLevenshtein(a, b) {
  var al = a.length
  var bl = b.length
  if (al === 0) return bl
  if (bl === 0) return al
  if (bl >= 63) return 99

  for (var j = 0; j <= bl; j++) levRow1[j] = j

  for (var i = 1; i <= al; i++) {
    levRow2[0] = i
    var aCode = a.charCodeAt(i - 1)
    for (var j = 1; j <= bl; j++) {
      var cost = (aCode === b.charCodeAt(j - 1)) ? 0 : 1
      var d = Math.min(levRow1[j] + 1, levRow2[j - 1] + 1)
      var sub = levRow1[j - 1] + cost
      if (sub < d) d = sub
      if (i > 1 && j > 1 && aCode === b.charCodeAt(j - 2) && a.charCodeAt(i - 2) === b.charCodeAt(j - 1)) {
        var trans = levRow0[j - 2] + 1
        if (trans < d) d = trans
      }
      levRow2[j] = d
    }
    for (var k = 0; k <= bl; k++) {
      levRow0[k] = levRow1[k]
      levRow1[k] = levRow2[k]
    }
  }
  return levRow1[bl]
}

function fuzzyMatchWords(pattern, text) {
  var words = String(text || "").toLowerCase().split(/[\s._\-\/]+/)
  var best = { matched: false, score: 0 }
  for (var i = 0; i < words.length; i++) {
    if (!words[i]) continue
    var r = fuzzyMatch(pattern, words[i])
    if (r.matched && r.score > best.score) best = r
  }
  return best
}

function typoMatch(pattern, text) {
  var p = String(pattern || "").toLowerCase().trim()
  if (p.length <= 3) return { matched: false, dist: 99 }

  var words = String(text || "").toLowerCase().split(/[\s._\-\/]+/)
  var maxEdits = p.length <= 5 ? 1 : 2
  var bestDist = 99

  for (var i = 0; i < words.length; i++) {
    var word = words[i]
    if (!word) continue

    var dFull = damerauLevenshtein(p, word)
    if (dFull <= maxEdits && dFull < bestDist) bestDist = dFull

    var minLen = Math.max(3, p.length - 1)
    var maxLen = Math.min(word.length, p.length + 1)
    for (var len = minLen; len <= maxLen; len++) {
      var sub = word.slice(0, len)
      var dSub = damerauLevenshtein(p, sub)
      if (dSub <= maxEdits && dSub < bestDist) bestDist = dSub
    }
  }

  if (bestDist <= maxEdits) {
    return { matched: true, score: 75 - bestDist * 20 }
  }
  return { matched: false, dist: 99 }
}

function fuzzyMatch(pattern, text) {
  if (!pattern) return { matched: true, score: 0 }
  if (!text) return { matched: false, score: 0 }

  var pLower = pattern.toLowerCase()
  var tLower = text.toLowerCase()

  if (tLower === pLower) return { matched: true, score: 100 }
  if (tLower.indexOf(pLower) === 0) return { matched: true, score: 85 }

  var subIdx = tLower.indexOf(pLower)
  if (subIdx > 0) {
    var isWordBoundary = /[\s._\-\/]/.test(text[subIdx - 1])
    return { matched: true, score: isWordBoundary ? 75 : 60 }
  }

  var pLen = pLower.length
  var tLen = tLower.length
  if (pLen > tLen) return { matched: false, score: 0 }

  var pIdx = 0
  var tIdx = 0
  var score = 0
  var prevMatchIdx = -2
  var consecutive = 0

  while (pIdx < pLen && tIdx < tLen) {
    if (pLower[pIdx] === tLower[tIdx]) {
      var boundary = (tIdx === 0) || /[\s._\-\/]/.test(text[tIdx - 1])
      if (boundary) {
        score += 25
      } else if (tIdx === prevMatchIdx + 1) {
        consecutive += 1
        score += 10 + (consecutive * 3)
      } else {
        consecutive = 0
        score += 5
      }
      prevMatchIdx = tIdx
      pIdx++
    }
    tIdx++
  }

  if (pIdx === pLen) {
    score -= (tLen - pLen) * 0.2
    return { matched: true, score: Math.max(1, score) }
  }

  return { matched: false, score: 0 }
}

function matchesQuery(entry, query, visible, allowTypo) {
  if (!entry || entry.id === "root") return false
  if (!visible) return false

  var nameText = nameSearchText(entry)
  var descriptionText = String(entry.description || "").toLowerCase()
  var terms = String(query || "").toLowerCase().trim().split(/\s+/)
  var label = String(entry.label || "")

  for (var i = 0; i < terms.length; i++) {
    var term = terms[i]
    if (!term) continue

    if (nameText.indexOf(term) >= 0) continue
    if (termInSearchWords(term, descriptionText)) continue

    var fLabel = fuzzyMatch(term, label)
    if (fLabel.matched && fLabel.score >= FUZZY_MIN_SCORE) continue

    var fName = fuzzyMatchWords(term, nameText)
    if (fName.matched && fName.score >= FUZZY_MIN_SCORE) continue

    if (allowTypo && term.length >= 4) {
      var tLabel = typoMatch(term, label)
      if (tLabel.matched) continue

      var tName = typoMatch(term, nameText)
      if (tName.matched) continue
    }

    return false
  }

  return true
}

function searchScore(items, entry, query, frecencyMap) {
  if (!entry) return 999999
  var needle = String(query || "").toLowerCase().trim()
  var label = String(entry.label || "").toLowerCase()
  var nameText = nameSearchText(entry)
  var descriptionText = String(entry.description || "").toLowerCase()
  var score = 80

  if (label === needle) {
    score = entry.parent === "root" ? 2 : 0
  } else if (entry.kind === "app" && label.split(/\s+/).indexOf(needle) >= 0) {
    score = 0
  } else if (label.indexOf(needle) === 0) {
    score = 10
  } else if (label.split(/\s+/).some(function(w) { return w.indexOf(needle) === 0 })) {
    score = 15
  } else if (label.indexOf(needle) >= 0) {
    score = 25
  } else if (nameText.indexOf(needle) >= 0) {
    score = 35
  } else {
    var fLabel = fuzzyMatch(needle, entry.label)
    if (fLabel.matched && fLabel.score >= FUZZY_MIN_SCORE) {
      score = Math.max(20, 50 - Math.round(fLabel.score * 0.4))
    } else {
      var fName = fuzzyMatchWords(needle, nameText)
      if (fName.matched && fName.score >= FUZZY_MIN_SCORE) {
        score = Math.max(30, 60 - Math.round(fName.score * 0.3))
      } else {
        var tLabel = typoMatch(needle, entry.label)
        if (tLabel.matched) {
          score = Math.max(35, 65 - Math.round(tLabel.score * 0.2))
        } else {
          var tName = typoMatch(needle, nameText)
          if (tName.matched) {
            score = Math.max(45, 75 - Math.round(tName.score * 0.2))
          } else if (descriptionTextMatches(needle, descriptionText)) {
            score = 75
          }
        }
      }
    }
  }

  if (entry.kind === "menu" || entry.kind === "link") score -= 2
  if (entry.kind === "app") score -= 5

  if (frecencyMap) {
    var key = entry.appId || entry.id
    var record = frecencyMap[key] || frecencyMap[entry.id]
    if (record && typeof record.score === "number") {
      score -= Math.min(15, Math.round(record.score / 20))
    } else if (record && record.count) {
      var hoursAgo = Math.max(0, (Date.now() - (record.lastUsed || 0)) / (1000 * 60 * 60))
      var boost = Math.min(15, (record.count * 2) / (1 + hoursAgo * 0.05))
      score -= Math.round(boost)
    }
  }

  return score * 1000 + depthFor(items, entry.id) * 25 + entry.order
}

var FILE_ICONS = {
  "\uf016": ["*"],
  "\uf1c5": ["png", "jpg", "jpeg", "gif", "webp", "svg", "bmp", "ico", "tif", "tiff", "heic", "avif"],
  "\uf001": ["mp3", "ogg", "opus", "flac", "wav", "m4a", "aac"],
  "\uf008": ["mp4", "mkv", "webm", "mov", "avi", "m4v"],
  "\uf1c1": ["pdf"],
  "\uf1c2": ["doc", "docx", "odt", "rtf"],
  "\uf1c3": ["xls", "xlsx", "csv", "ods"],
  "\uf1c4": ["ppt", "pptx", "odp"],
  "\uf02d": ["epub", "mobi"],
  "\uf48a": ["md", "markdown"],
  "\uf15c": ["txt", "rst", "log"],
  "\ue606": ["py"],
  "\ue714": ["js", "jsx", "mjs", "cjs"],
  "\ue628": ["ts", "tsx"],
  "\ue7a8": ["rs"],
  "\ue626": ["go"],
  "\ue620": ["lua"],
  "\ue615": ["sh", "bash", "zsh", "fish"],
  "\ue60b": ["json", "yaml", "yml", "toml"],
  "\ue736": ["html", "htm"],
  "\ue749": ["css", "scss"],
  "\uf1c0": ["db", "sqlite", "sqlite3"],
  "\uf031": ["ttf", "otf", "woff", "woff2"],
  "\uf410": ["zip", "tar", "gz", "bz2", "xz", "7z", "rar"],
  "\uf120": ["exe", "msi", "appimage", "deb", "rpm", "bin", "run"],
  "\uf084": ["pem", "key", "crt", "gpg", "asc"],
  "\ue7b0": ["dockerfile"],
  "\uf121": ["c", "h", "cpp", "hpp", "java", "kt", "swift", "cs", "php", "pl", "rb", "sql", "vim", "xml", "makefile"]
}

function iconForFile(path) {
  var name = String(path || "").split("/").pop().toLowerCase()
  if (name === "dockerfile" || name.indexOf("docker-compose") === 0) return "\ue7b0"
  var dot = name.lastIndexOf(".")
  var ext = dot > 0 ? name.substring(dot + 1) : name
  for (var icon in FILE_ICONS) {
    var exts = FILE_ICONS[icon]
    for (var i = 0; i < exts.length; i++) {
      if (exts[i] !== "*" && exts[i] === ext) return icon
    }
  }
  return "\uf016"
}

function fileSearchRows(frecencyMap, query, limit) {
  var terms = String(query || "").toLowerCase().trim().split(/\s+/).filter(function(t) { return t })
  if (terms.length === 0 || !frecencyMap) return []
  var scored = []
  var unscored = []
  var keys = Object.keys(frecencyMap)
  for (var i = 0; i < keys.length; i++) {
    var key = keys[i]
    if (key.indexOf("/") !== 0) continue
    var record = frecencyMap[key] || {}
    var kind = record.kind || "file"
    var path = key
    var lower = path.toLowerCase()
    var ok = true
    for (var t = 0; t < terms.length; t++) {
      if (lower.indexOf(terms[t]) < 0) { ok = false; break }
    }
    if (!ok) continue
    var base = path.split("/").pop().toLowerCase()
    var baseHit = false
    for (var b = 0; b < terms.length; b++) {
      if (base.indexOf(terms[b]) >= 0) { baseHit = true; break }
    }
    var isProject = kind === "project"
    var row = {
      itemId: (isProject ? "project." : "file.") + path,
      disabled: false,
      kind: isProject ? "project" : "file",
      icon: isProject ? "" : iconForFile(path),
      iconFont: "",
      appIcon: "",
      appId: "",
      label: (isProject && record.title) ? record.title : path.split("/").pop(),
      target: path,
      detail: path.split("/").slice(0, -1).join("/") || "/",
      path: "",
      childCount: 0,
      action: "",
      provider: "",
      score: 0,
      section: ""
    }
    if (typeof record.score === "number") {
      row.score = record.score + (baseHit ? 100000 : 0)
      scored.push(row)
    } else {
      unscored.push(row)
    }
  }
  scored.sort(function(a, b) { return b.score - a.score })
  return scored.concat(unscored).slice(0, Math.max(0, limit || 5))
}

function scopedSearchRows(frecencyMap, scopeKind, query, limit, actionTemplate, fallbackIcon) {
  if (!frecencyMap || !scopeKind) return []
  var terms = String(query || "").toLowerCase().trim().split(/\s+/).filter(function(t) { return t })
  var scored = []
  var max = typeof limit === "number" ? limit : 20
  var keys = Object.keys(frecencyMap)

  for (var i = 0; i < keys.length; i++) {
    var key = keys[i]
    var record = frecencyMap[key] || {}
    if (record.kind !== scopeKind) continue

    var title = String(record.title || "").toLowerCase()
    var detail = String(record.detail || "").toLowerCase()
    var match = true
    for (var t = 0; t < terms.length; t++) {
      if (title.indexOf(terms[t]) < 0 && key.toLowerCase().indexOf(terms[t]) < 0 && detail.indexOf(terms[t]) < 0) {
        match = false
        break
      }
    }
    if (!match) continue

    var label = record.title || (scopeKind + " " + (key.length > 12 ? key.slice(0, 8) : key))
    var action = record.action || ""
    if (!action && actionTemplate) {
      action = actionTemplate.indexOf("{}") >= 0
        ? actionTemplate.replace("{}", "'" + key.replace(/'/g, "'\\''") + "'")
        : actionTemplate + " '" + key.replace(/'/g, "'\\''") + "'"
    }

    scored.push({
      itemId: scopeKind + "." + key,
      disabled: false,
      kind: scopeKind,
      icon: record.icon || fallbackIcon || "",
      iconFont: record.iconFont || "",
      appIcon: "",
      appId: "",
      label: label,
      target: key,
      detail: record.detail || (key.length > 12 ? key.slice(0, 8) : key),
      path: "",
      childCount: 0,
      action: action,
      provider: "",
      score: typeof record.score === "number" ? record.score : (record.lastUsed || 0),
      section: ""
    })
  }

  scored.sort(function(a, b) {
    if (b.score !== a.score) return b.score - a.score
    return a.label.localeCompare(b.label)
  })
  return scored.slice(0, max)
}

function sessionSearchRows(frecencyMap, query, limit) {
  return scopedSearchRows(frecencyMap, "agent-session", query, limit, "omarchy agent resume {}", "")
}

function displayRow(items, itemOrder, checkedResults, disabledResults, entry, detail, score, section) {
  var target = entry.kind === "link" ? entry.target : entry.id
  return {
    itemId: entry.id,
    disabled: isDisabled(disabledResults, entry),
    kind: entry.kind,
    icon: entry.icon,
    iconFont: entry.iconFont || "",
    appIcon: entry.appIcon || "",
    appId: entry.appId || "",
    label: labelFor(entry, checkedResults, disabledResults),
    target: target,
    detail: detail || "",
    path: pathFor(items, entry.id),
    childCount: (entry.kind === "menu" || entry.kind === "link") ? childCount(items, itemOrder, target) : 0,
    action: entry.action || "",
    provider: entry.provider || "",
    score: score || 0,
    section: section || ""
  }
}

var GUARD_READERS = [
  "omarchy-channel-current",
  "omarchy-default-agent",
  "omarchy-default-browser",
  "omarchy-default-editor",
  "omarchy-default-search",
  "omarchy-default-terminal",
  "omarchy-dns"
]

function guardHelpers() {
  return 'declare -A __omarchy_pkgs=()\n'
    + 'mapfile -t __omarchy_pkg_names < <({ pacman -Qq; LC_ALL=C pacman -Qi'
    + " | awk '/^[A-Za-z]/ { provides = ($0 ~ /^Provides/); sub(/^[^:]*: /, \"\") }"
    + ' provides && $0 != "None" { n = split($0, p, " ");'
    + ' for (i = 1; i <= n; i++) { sub(/[<>=].*/, "", p[i]); print p[i] } }\'; } 2>/dev/null)\n'
    + 'for __omarchy_pkg in "${__omarchy_pkg_names[@]}"; do __omarchy_pkgs[$__omarchy_pkg]=1; done\n'
    + '__omarchy_pkg_has() { [[ -n ${__omarchy_pkgs[$1]-} ]] && return 0; '
    + '[[ $1 == *[\\<\\>=]* ]] && { pacman -Q "$1" &>/dev/null; return; }; return 1; }\n'
    + 'omarchy-pkg-present() { local p; for p in "$@"; do __omarchy_pkg_has "$p" || return 1; done; return 0; }\n'
    + 'omarchy-pkg-missing() { local p; for p in "$@"; do __omarchy_pkg_has "$p" || return 0; done; return 1; }\n'
    + 'omarchy-cmd-present() { local c; for c in "$@"; do command -v "$c" &>/dev/null || return 1; done; return 0; }\n'
    + 'omarchy-cmd-missing() { local c; for c in "$@"; do command -v "$c" &>/dev/null || return 0; done; return 1; }\n'
}

function guardPrelude(guards) {
  var prelude = guardHelpers()

  for (var i = 0; i < GUARD_READERS.length; i++) {
    if (guards.indexOf(guardReaderSlot(i)) < 0) continue
    prelude += "__omarchy_read_" + i + "=$(" + GUARD_READERS[i] + " 2>/dev/null) || :\n"
  }

  return prelude
}

function guardReaderSlot(index) {
  return "${__omarchy_read_" + index + "}"
}

function substituteGuardReaders(expression) {
  var result = String(expression || "")
  for (var i = 0; i < GUARD_READERS.length; i++) {
    var cmd = GUARD_READERS[i]
    result = result.split("$(" + cmd + ")").join(guardReaderSlot(i))
    result = result.split("`" + cmd + "`").join(guardReaderSlot(i))
  }
  return result
}

function guardLine(id, tag, expression) {
  return "if { " + substituteGuardReaders(expression) + "; } >/dev/null 2>&1; then echo "
    + id + ":" + tag + ":1; else echo " + id + ":" + tag + ":0; fi\n"
}

function guardScript(items) {
  var guards = ""
  var ids = Object.keys(items || {})
  for (var i = 0; i < ids.length; i++) {
    var entry = items[ids[i]]
    if (!entry) continue
    if (entry.when) guards += guardLine(ids[i], "w", entry.when)
    if (entry.checked) guards += guardLine(ids[i], "c", entry.checked)
    if (entry.disabled) guards += guardLine(ids[i], "d", entry.disabled)
  }

  return guards ? guardPrelude(guards) + guards : ""
}

function hasParam(action) {
  return String(action || "").indexOf("{}") >= 0
}

function substituteParam(action, quoted) {
  return String(action || "").split("{}").join(String(quoted == null ? "" : quoted))
}

function quicklinkRemainder(query) {
  var q = String(query || "").trim().replace(/\s+/g, " ")
  if (!q) return ""
  var space = q.indexOf(" ")
  if (space < 0) return ""
  return q.substring(space + 1).trim()
}

function quicklinkFirstTerm(query) {
  var q = String(query || "").trim().replace(/\s+/g, " ")
  if (!q) return ""
  var space = q.indexOf(" ")
  return space < 0 ? q : q.substring(0, space)
}

if (typeof module !== "undefined") {
  module.exports = {
    guardReaders: GUARD_READERS,
    guardScript: guardScript,
    stripJsonc: stripJsonc,
    normalizeAliases: normalizeAliases,
    normalizeInput: normalizeInput,
    normalizeItem: normalizeItem,
    parseMenuJsonc: parseMenuJsonc,
    mergeMenuSources: mergeMenuSources,
    slugify: slugify,
    mergeAppRows: mergeAppRows,
    swapProviderRows: swapProviderRows,
    resolveRoute: resolveRoute,
    depthFor: depthFor,
    pathFor: pathFor,
    parentPathFor: parentPathFor,
    isDescendantOf: isDescendantOf,
    isSearchableDescendant: isSearchableDescendant,
    childCount: childCount,
    isVisible: isVisible,
    isDisabled: isDisabled,
    labelFor: labelFor,
    searchableToken: searchableToken,
    leafIdFor: leafIdFor,
    nameSearchText: nameSearchText,
    termInSearchWords: termInSearchWords,
    descriptionTextMatches: descriptionTextMatches,
    matchesQuery: matchesQuery,
    searchScore: searchScore,
    fileSearchRows: fileSearchRows,
    scopedSearchRows: scopedSearchRows,
    sessionSearchRows: sessionSearchRows,
    iconForFile: iconForFile,
    fuzzyMatchWords: fuzzyMatchWords,
    fuzzyMatch: fuzzyMatch,
    typoMatch: typoMatch,
    hasParam: hasParam,
    substituteParam: substituteParam,
    quicklinkRemainder: quicklinkRemainder,
    quicklinkFirstTerm: quicklinkFirstTerm,
    displayRow: displayRow
  }
}
