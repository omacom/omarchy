// Reads a currency conversion out of the search line: "INR 100 to USD",
// "$5 to INR", "100 rupees in euros", "convert 1,000 jpy into gbp". Codes are
// only shaped here; CurrencyLookup checks them against the API's own list.
var ALIASES = {
  "$": "usd", "us$": "usd", "usd$": "usd", "dollar": "usd", "dollars": "usd", "buck": "usd", "bucks": "usd",
  "€": "eur", "euro": "eur", "euros": "eur",
  "£": "gbp", "pound": "gbp", "pounds": "gbp", "quid": "gbp",
  "₹": "inr", "rs": "inr", "rs.": "inr", "rupee": "inr", "rupees": "inr",
  "¥": "jpy", "yen": "jpy",
  "yuan": "cny", "rmb": "cny",
  "a$": "aud", "c$": "cad", "s$": "sgd", "hk$": "hkd", "nz$": "nzd",
  "₩": "krw", "won": "krw", "₽": "rub", "ruble": "rub", "rubles": "rub",
  "₺": "try", "₫": "vnd", "₱": "php", "฿": "thb"
}

var CURRENCY = "((?:[a-z]{1,2}\\$)|[$€£₹¥₩₽₺₫₱฿]|[a-z][a-z0-9]{1,7}?\\.?)"
// Commas only as thousands groups, Indian ones included. "1,25" is a decimal in
// much of the world, so it stays a search rather than becoming 125.
var AMOUNT = "((?:\\d{1,3}(?:,\\d{2,3})*,\\d{3}|\\d+)(?:\\.\\d+)?|\\.\\d+)"
var AMOUNT_FIRST = new RegExp("^" + AMOUNT + "\\s*" + CURRENCY + "$")
var CURRENCY_FIRST = new RegExp("^" + CURRENCY + "\\s*" + AMOUNT + "$")
var CURRENCY_ALONE = new RegExp("^" + CURRENCY + "$")
var TARGET = "(\\S+)$"
var WITH_CONNECTOR = new RegExp("^(.+?)(?:\\s+(?:to|in|into|as)\\s+|\\s*(?:=>|->|→|=)\\s*)" + TARGET)
var WITHOUT_CONNECTOR = new RegExp("^(.+?)\\s+" + TARGET)
var LEADING_WORDS = /^(?:(?:please\s+)?(?:convert|change|exchange)\s+|how\s+much\s+is\s+|what\s+is\s+|what's\s+|whats\s+)/
var TRAILING_PUNCTUATION = /[?!.]+$/

function codeFor(token) {
  var cleaned = String(token || "")
  if (Object.prototype.hasOwnProperty.call(ALIASES, cleaned)) return ALIASES[cleaned]
  cleaned = cleaned.replace(/\.$/, "")
  if (Object.prototype.hasOwnProperty.call(ALIASES, cleaned)) return ALIASES[cleaned]
  return /^[a-z][a-z0-9]{1,7}$/.test(cleaned) ? cleaned : ""
}

function parseSource(text) {
  var match = AMOUNT_FIRST.exec(text)
  if (match) return { amount: Number(match[1].replace(/,/g, "")), code: codeFor(match[2]) }
  match = CURRENCY_FIRST.exec(text)
  if (match) return { amount: Number(match[2].replace(/,/g, "")), code: codeFor(match[1]) }
  return null
}

// { amount, from, to } in lowercase codes, or null when the text is not shaped
// like a conversion. "usd to inr" means one unit; a bare "5 usd inr" is allowed
// because an amount makes the intent clear.
function parse(text) {
  var query = String(text || "").trim().toLowerCase().replace(TRAILING_PUNCTUATION, "").replace(LEADING_WORDS, "")
  var source = null
  var target = ""

  var match = WITH_CONNECTOR.exec(query)
  if (match) {
    target = match[2]
    source = parseSource(match[1])
    if (!source && CURRENCY_ALONE.test(match[1])) source = { amount: 1, code: codeFor(match[1]) }
  } else {
    match = WITHOUT_CONNECTOR.exec(query)
    if (match) {
      target = match[2]
      source = parseSource(match[1])
    }
  }

  if (!source || !source.code || !isFinite(source.amount)) return null
  // An unfinished "100 inr to" has no target yet.
  if (/^(?:to|in|into|as)$/.test(target)) return null
  var to = codeFor(target)
  return to ? { amount: source.amount, from: source.code, to: to } : null
}

// Two decimals is enough for money, but a small result needs its significant
// digits or 1 INR to BTC would read 0.00. Plain digits, so it can be copied.
function format(value) {
  var size = Math.abs(value)
  if (size === 0 || size >= 1) return String(Number(value.toFixed(2)))
  return String(Number(value.toPrecision(4)))
}

if (typeof module !== "undefined") {
  module.exports = {
    parse: parse,
    format: format
  }
}
