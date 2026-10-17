// Pure helpers behind PluginExtensions.qml. They live here so the shortcut
// grammar and the host lookup can be tested from node without a compositor.

var MODIFIER_NAMES = {
  "ctrl": "ctrl",
  "control": "ctrl",
  "shift": "shift",
  "alt": "alt",
  "meta": "meta",
  "super": "meta"
}

// "Ctrl+E", "ctrl+shift+Return": modifiers first, exactly one key last. An
// unreadable spec returns null, so a bad manifest costs that extension its
// shortcut and nothing else.
function parseShortcut(spec) {
  var parts = String(spec === undefined || spec === null ? "" : spec).split("+")
  var key = String(parts.pop() || "").trim().toUpperCase()
  if (!key) return null

  var shortcut = { key: key, ctrl: false, shift: false, alt: false, meta: false }
  for (var i = 0; i < parts.length; i++) {
    var modifier = MODIFIER_NAMES[String(parts[i]).trim().toLowerCase()]
    if (!modifier) return null
    shortcut[modifier] = true
  }
  return shortcut
}

// Enabled plugins that declare themselves an extension of hostId, sorted by id
// so two extensions claiming one shortcut resolve the same way every boot.
function hostedExtensions(installedPlugins, hostId, isEnabled) {
  var hosted = []
  if (!installedPlugins || !hostId) return hosted

  for (var id in installedPlugins) {
    var manifest = installedPlugins[id]
    if (!manifest || !Array.isArray(manifest.kinds)) continue
    if (manifest.kinds.indexOf("extension") === -1) continue
    if (!manifest.extension || String(manifest.extension.host || "") !== String(hostId)) continue
    if (isEnabled && !isEnabled(id)) continue
    hosted.push(manifest)
  }

  hosted.sort(function(a, b) { return String(a.id) < String(b.id) ? -1 : 1 })
  return hosted
}

if (typeof module !== "undefined") {
  module.exports = {
    parseShortcut: parseShortcut,
    hostedExtensions: hostedExtensions
  }
}
