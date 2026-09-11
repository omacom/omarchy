// I18nModel.js — pure-JS core of qs.Commons.I18n
//
// Pure JavaScript: runs under node for unit testing and loads into QML with
// `import "I18nModel.js" as Model`.

var CONTEXT_SEPARATOR = "\u0004"

// ---------------------------------------------------------------------------
// Locale normalization and candidate resolution

function normalizeLocale(value) {
  var locale = String(value || "").trim()
  if (!locale) return ""
  locale = locale.split(".")[0].split("@")[0].replace(/-/g, "_")
  if (locale === "C" || locale === "POSIX") return ""
  var parts = locale.split("_").filter(Boolean)
  if (parts.length === 0) return ""
  var language = parts[0].toLowerCase()
  if (!language) return ""
  var result = [language]
  for (var i = 1; i < parts.length; i++) {
    var p = parts[i]
    if (p.length === 4) {
      // Script: Title Case (e.g. Hans, Hant, Latn)
      result.push(p.charAt(0).toUpperCase() + p.slice(1).toLowerCase())
    } else if (p.length === 2 || p.length === 3) {
      // Region: Uppercase (e.g. CN, TW, SG, HK, MO, US)
      result.push(p.toUpperCase())
    } else {
      result.push(p)
    }
  }
  return result.join("_")
}

function localeCandidates(environment) {
  var env = environment || {}
  // Priority: OMARCHY_UI_LANGUAGE > LANGUAGE > LC_ALL > LC_MESSAGES > LANG
  var raw = env.OMARCHY_UI_LANGUAGE || env.LANGUAGE || env.LC_ALL || env.LC_MESSAGES || env.LANG || ""
  var requested = (env.OMARCHY_UI_LANGUAGE ? [env.OMARCHY_UI_LANGUAGE] : (env.LANGUAGE ? String(raw).split(":") : [raw]))
  var candidates = []
  for (var i = 0; i < requested.length; i++) {
    var normalized = normalizeLocale(requested[i])
    if (!normalized) continue
    var parts = normalized.split("_")
    var language = parts[0]
    if (candidates.indexOf(normalized) === -1) candidates.push(normalized)
    if (parts.length > 2) {
      // An explicit script constrains fallback; a region must not override it.
      var langScript = language + "_" + parts[1]
      if (candidates.indexOf(langScript) === -1) candidates.push(langScript)
    }
    if (candidates.indexOf(language) === -1) candidates.push(language)
    if (language === "en") break
  }
  return candidates
}

// ---------------------------------------------------------------------------
// Interpolation: %1, %2 ... preserves unknown indices, avoids re-expansion

function interpolate(value, args) {
  var output = String(value === undefined || value === null ? "" : value)
  var values = Array.isArray(args) ? args : []
  return output.replace(/%([1-9][0-9]*)/g, function(match, rawIndex) {
    var index = Number(rawIndex) - 1
    return index < values.length ? String(values[index]) : match
  })
}

function contextKey(context, source) {
  var ctx = String(context === undefined || context === null ? "" : context)
  var key = String(source === undefined || source === null ? "" : source)
  return ctx ? ctx + CONTEXT_SEPARATOR + key : key
}

// ---------------------------------------------------------------------------
// Catalog Registry & Translation lookup

function createRegistry() {
  var catalogs = {} // locale -> catalog map
  var currentLocale = "en"

  function registerCatalog(locale, catalog, aliases) {
    var norm = normalizeLocale(locale)
    if (!norm || !catalog) return
    catalogs[norm] = catalog
    if (Array.isArray(aliases)) {
      for (var i = 0; i < aliases.length; i++) {
        var aliasNorm = normalizeLocale(aliases[i])
        if (aliasNorm) catalogs[aliasNorm] = catalog
      }
    }
  }

  function setLocale(locale) {
    currentLocale = normalizeLocale(locale) || "en"
  }

  function getCatalog(candidates) {
    var cand = Array.isArray(candidates) ? candidates : [currentLocale]
    for (var i = 0; i < cand.length; i++) {
      var c = catalogs[cand[i]]
      if (c) return c
    }
    return null
  }

  function resolveLocale(candidates) {
    var cand = Array.isArray(candidates) ? candidates : [currentLocale]
    for (var i = 0; i < cand.length; i++) {
      if (catalogs[cand[i]]) return cand[i]
    }
    return "en"
  }

  function translate(source, options) {
    var key = String(source === undefined || source === null ? "" : source)
    if (!key) return ""
    var opts = options || {}
    var fullKey = opts.context ? contextKey(opts.context, key) : key
    var candidates = opts.candidates || [currentLocale]

    var catalog = getCatalog(candidates)
    var translated = (catalog && catalog[fullKey] !== undefined) ? catalog[fullKey] : null

    // Fallback if context lookup missed: try bare key
    if (translated === null && opts.context && catalog && catalog[key] !== undefined) {
      translated = catalog[key]
    }

    // Default fallback to source English string
    if (translated === null || translated === undefined) {
      translated = key
    }

    if (opts.args && opts.args.length > 0) {
      return interpolate(translated, opts.args)
    }
    return translated
  }

  return {
    registerCatalog: registerCatalog,
    setLocale: setLocale,
    getCatalog: getCatalog,
    resolveLocale: resolveLocale,
    translate: translate,
    catalogs: catalogs
  }
}

if (typeof module !== "undefined") {
  module.exports = {
    normalizeLocale: normalizeLocale,
    localeCandidates: localeCandidates,
    interpolate: interpolate,
    contextKey: contextKey,
    createRegistry: createRegistry
  }
}
