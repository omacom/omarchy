// Resolves the focused application name and label for the active window bar widget.

function cleanAppId(appId) {
  var id = String(appId || "").trim()
  if (id.slice(-8) === ".desktop") id = id.slice(0, -8)
  return id
}

function formatFallbackName(appId) {
  var id = cleanAppId(appId)
  if (!id) return ""

  // Terminal launcher convention (e.g., "org.omarchy.nvim" -> "nvim")
  if (id.indexOf("org.omarchy.") === 0) {
    id = id.slice("org.omarchy.".length)
  }

  // Strip reverse-DNS / domain segments (e.g., "org.gnome.Nautilus" -> "Nautilus", "com.anthropic.Claude" -> "Claude")
  var parts = id.split(".")
  var last = parts[parts.length - 1] || id

  // Handle kebab-case and snake_case (e.g. "google-chrome" -> "Google Chrome")
  var words = last.replace(/[-_]+/g, " ").trim().split(/\s+/)
  var capitalized = []
  for (var i = 0; i < words.length; i++) {
    var w = words[i]
    if (!w) continue
    capitalized.push(w.charAt(0).toUpperCase() + w.slice(1))
  }
  return capitalized.join(" ")
}

function appNameFromEntry(entry) {
  if (!entry) return ""
  var name = String(entry.name || "").trim()
  return name
}

function claimingTerminalEntryId(appId, entries) {
  var id = String(appId || "")
  if (!id) return ""
  var list = entries || []
  var flag = "--app-id=" + id
  for (var i = 0; i < list.length; i++) {
    var words = String(list[i].execString || "").split(/\s+/)
    if (words.indexOf(flag) >= 0) return list[i].id
  }
  if (id.indexOf("org.omarchy.") !== 0) return ""
  var command = id.slice("org.omarchy.".length)
  for (var j = 0; j < list.length; j++) {
    var program = String((list[j].command || [])[0] || "")
    if (list[j].runInTerminal && program.slice(program.lastIndexOf("/") + 1) === command) return list[j].id
  }
  return ""
}

function resolveAppName(appId, desktopEntries, terminalEntries) {
  var id = cleanAppId(appId)
  if (!id) return ""

  // 1. Quickshell DesktopEntries heuristic lookup
  if (desktopEntries && typeof desktopEntries.heuristicLookup === "function") {
    var entry = desktopEntries.heuristicLookup(id)
    var name = appNameFromEntry(entry)
    if (name) return name
  }

  // 2. Direct byId lookup
  if (desktopEntries && typeof desktopEntries.byId === "function") {
    var entryById = desktopEntries.byId(id)
    var nameById = appNameFromEntry(entryById)
    if (nameById) return nameById
  }

  // 3. Claiming entry for terminal apps or --app-id
  if (terminalEntries && terminalEntries.length && desktopEntries && typeof desktopEntries.byId === "function") {
    var claimingId = claimingTerminalEntryId(id, terminalEntries)
    if (claimingId) {
      var claimedEntry = desktopEntries.byId(claimingId)
      var claimedName = appNameFromEntry(claimedEntry)
      if (claimedName) return claimedName
    }
  }

  // 4. Try last segment of reverse-DNS domain
  var dotParts = id.split(".")
  if (dotParts.length > 1) {
    var lastSegment = dotParts[dotParts.length - 1]
    if (desktopEntries && typeof desktopEntries.heuristicLookup === "function") {
      var segEntry = desktopEntries.heuristicLookup(lastSegment)
      var segName = appNameFromEntry(segEntry)
      if (segName) return segName
    }
    if (desktopEntries && typeof desktopEntries.byId === "function") {
      var segById = desktopEntries.byId(lastSegment)
      var segByIdName = appNameFromEntry(segById)
      if (segByIdName) return segByIdName
    }
  }

  // 5. Friendly formatted name from the app ID
  return formatFallbackName(id)
}

function labelText(mode, appName, windowTitle) {
  var app = String(appName || "").trim()
  var title = String(windowTitle || "").trim()
  if (mode === "title") return title || app
  if (mode === "both") {
    if (app && title && app.toLowerCase() !== title.toLowerCase()) return app + "  ·  " + title
    return app || title
  }
  // Default mode: "appName" (macOS style)
  return app || title
}

if (typeof module !== "undefined") {
  module.exports = {
    cleanAppId: cleanAppId,
    formatFallbackName: formatFallbackName,
    appNameFromEntry: appNameFromEntry,
    claimingTerminalEntryId: claimingTerminalEntryId,
    resolveAppName: resolveAppName,
    labelText: labelText
  }
}
