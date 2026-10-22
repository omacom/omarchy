// CLDR cardinal plural categories for whole counts, per Omarchy language
// code. A plural catalog entry is an object keyed by these categories
// ({ "one": "%1 file", "other": "%1 files" }); every language needs "other",
// plus whichever categories its counts can reach. default/i18n/plural.jq
// holds the same rules for omarchy-i18n, and i18n-test.sh keeps the two
// in agreement.

function within(value, low, high) {
  return value >= low && value <= high
}

function category(code, count) {
  var n = Math.abs(Math.trunc(Number(count) || 0))
  var n10 = n % 10
  var n100 = n % 100
  var millions = n !== 0 && n % 1000000 === 0

  switch (String(code || "")) {
  case "ja": case "ko": case "zh-CN": case "zh-TW": case "th": case "vi": case "id": case "ms":
    return "other"
  case "hi": case "bn": case "fa": case "si":
    return n <= 1 ? "one" : "other"
  case "fr": case "pt-BR":
    return n <= 1 ? "one" : millions ? "many" : "other"
  case "ca": case "es-MX": case "it": case "pt":
    return n === 1 ? "one" : millions ? "many" : "other"
  case "fil":
    return (n10 === 4 || n10 === 6 || n10 === 9) ? "other" : "one"
  case "is":
    return n10 === 1 && n100 !== 11 ? "one" : "other"
  case "cs": case "sk":
    return n === 1 ? "one" : within(n, 2, 4) ? "few" : "other"
  case "pl":
    if (n === 1) return "one"
    return within(n10, 2, 4) && !within(n100, 12, 14) ? "few" : "many"
  case "ru": case "uk":
    if (n10 === 1 && n100 !== 11) return "one"
    return within(n10, 2, 4) && !within(n100, 12, 14) ? "few" : "many"
  case "hr": case "sr":
    if (n10 === 1 && n100 !== 11) return "one"
    return within(n10, 2, 4) && !within(n100, 12, 14) ? "few" : "other"
  case "sl":
    if (n100 === 1) return "one"
    if (n100 === 2) return "two"
    return within(n100, 3, 4) ? "few" : "other"
  case "lt":
    if (within(n100, 11, 19)) return "other"
    return n10 === 1 ? "one" : n10 >= 2 ? "few" : "other"
  case "lv":
    if (n10 === 0 || within(n100, 11, 19)) return "zero"
    return n10 === 1 ? "one" : "other"
  case "ro":
    if (n === 1) return "one"
    return n === 0 || within(n100, 1, 19) ? "few" : "other"
  case "ar":
    if (n <= 2) return ["zero", "one", "two"][n]
    return within(n100, 3, 10) ? "few" : within(n100, 11, 99) ? "many" : "other"
  case "he":
    return n === 1 ? "one" : n === 2 ? "two" : "other"
  case "ga":
    if (n <= 2) return n === 0 ? "other" : n === 1 ? "one" : "two"
    return within(n, 3, 6) ? "few" : within(n, 7, 10) ? "many" : "other"
  default:
    return n === 1 ? "one" : "other"
  }
}

var ORDER = ["zero", "one", "two", "few", "many", "other"]

// The categories a translation of a plural entry must provide.
function categories(code) {
  var seen = { other: true }
  for (var n = 0; n <= 1000; n++) seen[category(code, n)] = true
  seen[category(code, 1000000)] = true
  return ORDER.filter(function(name) { return seen[name] })
}

// The string for a count from a plural entry, or the entry itself when it
// is a plain string. A translation missing a category falls back to its
// "other" form.
function pick(entry, code, count) {
  if (typeof entry === "string") return entry
  if (!entry || typeof entry !== "object") return undefined
  var form = entry[category(code, count)]
  if (typeof form === "string" && form.length > 0) return form
  return typeof entry.other === "string" ? entry.other : undefined
}

if (typeof module !== "undefined") {
  module.exports = { category: category, categories: categories, pick: pick }
}
