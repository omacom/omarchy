function cleaned(value) {
  return String(value || "").replace(/^\s+|\s+$/g, "")
}

function textFor(plugin) {
  return [plugin.name, plugin.id, plugin.description, plugin.author, plugin.category, plugin.kind]
    .concat(Array.isArray(plugin.tags) ? plugin.tags : [])
    .join(" ").toLowerCase()
}

function normalize(catalog, installedIds) {
  var plugins = catalog && Array.isArray(catalog.plugins) ? catalog.plugins : []
  var installed = {}
  var ids = Array.isArray(installedIds) ? installedIds : []
  for (var i = 0; i < ids.length; i++) installed[String(ids[i])] = true

  var rows = []
  for (var j = 0; j < plugins.length; j++) {
    var source = plugins[j] || {}
    if (String(source.sourceType || "community") !== "community" || !cleaned(source.id)) continue
    rows.push({
      id: cleaned(source.id), name: cleaned(source.name) || cleaned(source.id),
      description: cleaned(source.description), author: cleaned(source.author),
      version: cleaned(source.version), category: cleaned(source.category) || "Other",
      kind: cleaned(source.kind) || "Plugin", tags: Array.isArray(source.tags) ? source.tags : [],
      stars: Number(source.stars || 0), addedAt: cleaned(source.addedAt || source.listedAt),
      installAvailable: source.installAvailable === true, installed: source.installed === true || !!installed[String(source.id)],
      verified: String(source.verificationStatus || "") === "verified",
      status: cleaned(source.status), license: cleaned(source.license), installNote: cleaned(source.installNote),
      repo: cleaned(source.repo), previewPath: cleaned(source.previewPath),
      previewImages: Array.isArray(source.previewImages) ? source.previewImages.map(cleaned).filter(function(path) { return path !== "" }) : [],
      previewThumbnail: cleaned(source.previewThumbnail)
    })
  }
  return rows
}

function options(plugins, key) {
  var found = {}
  for (var i = 0; i < plugins.length; i++) found[String(plugins[i][key] || "")] = true
  return Object.keys(found).filter(function(value) { return value !== "" }).sort()
}

function score(plugin, query) {
  var needle = cleaned(query).toLowerCase()
  if (!needle) return 0
  var name = plugin.name.toLowerCase()
  var id = plugin.id.toLowerCase()
  if (name === needle || id === needle) return 100
  if (name.indexOf(needle) !== -1) return 60
  if (id.indexOf(needle) !== -1) return 50
  return textFor(plugin).indexOf(needle) !== -1 ? 10 : -1
}

function filtered(plugins, filters) {
  var state = filters || {}
  var result = []
  for (var i = 0; i < plugins.length; i++) {
    var plugin = plugins[i]
    if (state.category && plugin.category !== state.category) continue
    if (state.kind && plugin.kind !== state.kind) continue
    if (state.installable && !plugin.installAvailable) continue
    if (state.verified && !plugin.verified) continue
    if (state.installed === "installed" && !plugin.installed) continue
    if (state.installed === "available" && plugin.installed) continue
    var relevance = score(plugin, state.query)
    if (relevance < 0) continue
    result.push({ plugin: plugin, relevance: relevance })
  }
  var sort = state.sort || "relevance"
  result.sort(function(a, b) {
    if (sort === "stars") return b.plugin.stars - a.plugin.stars || a.plugin.name.localeCompare(b.plugin.name)
    if (sort === "newest") return String(b.plugin.addedAt).localeCompare(String(a.plugin.addedAt)) || a.plugin.name.localeCompare(b.plugin.name)
    return b.relevance - a.relevance || a.plugin.name.localeCompare(b.plugin.name)
  })
  return result.map(function(row) { return row.plugin })
}

// Catalog keys, not text: the overlay translates them, so these badges and the
// primary action speak the same language as the rest of the card.
function badges(plugin) {
  var values = []
  if (plugin.installed) values.push("marketplace.badgeInstalled")
  else if (plugin.installAvailable) values.push("marketplace.badgeInstallable")
  else values.push("marketplace.badgeManualSetup")
  if (plugin.verified) values.push("marketplace.badgeVerified")
  return values
}

function primaryAction(plugin) {
  var row = plugin || {}
  if (row.installed) return { labelKey: "marketplace.viewDetails", operation: "" }
  if (row.installAvailable && cleaned(row.repo)) return { labelKey: "marketplace.installPlugin", operation: "" }
  return { labelKey: "marketplace.setupInstructions", operation: "" }
}

if (typeof module !== "undefined") module.exports = { normalize: normalize, options: options, filtered: filtered, badges: badges, primaryAction: primaryAction }
