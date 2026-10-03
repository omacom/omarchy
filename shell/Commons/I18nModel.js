// Source strings are the catalog keys. Never pass command identifiers or user
// input here: those stay untouched even when they look like translated labels.
function normalizeLocale(value) {
  return String(value || "").trim().replace(/[.@].*$/, "").replace(/-/g, "_")
}

function catalogLocale(environment) {
  var env = environment || {}
  var locale = normalizeLocale(env.LC_ALL || env.LC_MESSAGES || env.LANG || "C")
  if (locale === "C" || locale === "POSIX") return ""
  var candidates = env.LANGUAGE ? String(env.LANGUAGE).split(":") : [locale]
  for (var i = 0; i < candidates.length; i++) {
    var candidate = normalizeLocale(candidates[i]).toLowerCase()
    if (/^en(?:_|$)/.test(candidate) || candidate === "c" || candidate === "posix") return ""
    if (candidate === "zh_tw" || candidate === "zh_hant" || candidate === "zh_hant_tw") return "zh_TW"
  }
  return ""
}

function parseCatalog(raw) {
  try {
    var value = JSON.parse(String(raw || ""))
    if (!value || typeof value !== "object" || Array.isArray(value)) return {}
    var catalog = {}
    for (var key in value) {
      if (Object.prototype.hasOwnProperty.call(value, key) && typeof value[key] === "string" && value[key].length > 0)
        Object.defineProperty(catalog, key, { value: value[key], enumerable: true })
    }
    return catalog
  } catch (e) {
    return {}
  }
}

function format(text, args) {
  var values = Array.isArray(args) ? args : []
  return String(text).replace(/%([1-9][0-9]*)/g, function(match, number) {
    var index = Number(number) - 1
    return index < values.length ? String(values[index] === null || values[index] === undefined ? "" : values[index]) : match
  })
}

function translate(catalog, source, args) {
  var text = String(source || "")
  var translated = catalog && Object.prototype.hasOwnProperty.call(catalog, text) && typeof catalog[text] === "string"
    ? catalog[text] : text
  return format(translated, args)
}

function localizeMenu(items, catalog) {
  return (items || []).map(function(item) {
    var copy = {}
    for (var key in item) copy[key] = item[key]
    copy.label = translate(catalog, item.label)
    copy.title = translate(catalog, item.title)
    copy.description = translate(catalog, item.description)
    return copy
  })
}

if (typeof module !== "undefined") {
  module.exports = { normalizeLocale: normalizeLocale, catalogLocale: catalogLocale,
    parseCatalog: parseCatalog, format: format, translate: translate, localizeMenu: localizeMenu }
}
