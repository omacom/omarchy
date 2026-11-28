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

// Active ISO 4217 codes and the best-known crypto. Without an amount, "x to y" is
// only a conversion when both sides are in here, because the API's own list is
// full of words: "all in one", "link to one" and "top to one" are all valid pairs
// of its codes. For the same reason the ISO codes that are ordinary words (all,
// bob, cup, gel, mad, mop, pen, sos, top, try) are left out; they still convert
// with an amount, as "5 try to usd".
var KNOWN = {}
"aed afn amd ang aoa ars aud awg azn bam bbd bdt bgn bhd bif bmd bnd brl bsd btn bwp byn bzd cad cdf chf clp cny cop crc cuc cve czk djf dkk dop dzd egp ern etb eur fjd fkp gbp ghs gip gmd gnf gtq gyd hkd hnl htg huf idr ils inr iqd irr isk jmd jod jpy kes kgs khr kmf kpw krw kwd kyd kzt lak lbp lkr lrd lsl lyd mdl mga mkd mmk mnt mru mur mvr mwk mxn myr mzn nad ngn nio nok npr nzd omr pab pgk php pkr pln pyg qar ron rsd rub rwf sar sbd scr sdg sek sgd shp sle srd ssp stn svc syp szl thb tjs tmt tnd ttd twd tzs uah ugx usd uyu uzs ves vnd vuv wst xaf xcd xof xpf yer zar zmw btc eth ltc xrp usdt doge".split(" ").forEach(function(code) { KNOWN[code] = true })

// Longer than any conversion typed by hand. Search text past it stays a search.
var MAX_LENGTH = 64

var CURRENCY = "((?:[a-z]{1,3}\\$)|[$€£₹¥₩₽₺₫₱฿]|[a-z][a-z0-9]{1,7}?\\.?)"
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

function aliasFor(token) {
  var cleaned = String(token || "")
  if (Object.prototype.hasOwnProperty.call(ALIASES, cleaned)) return ALIASES[cleaned]
  cleaned = cleaned.replace(/\.$/, "")
  return Object.prototype.hasOwnProperty.call(ALIASES, cleaned) ? ALIASES[cleaned] : ""
}

function codeFor(token) {
  var alias = aliasFor(token)
  if (alias) return alias
  var cleaned = String(token || "").replace(/\.$/, "")
  return /^[a-z][a-z0-9]{1,7}$/.test(cleaned) ? cleaned : ""
}

// A symbol or currency name, or a code on the list above.
function isKnown(token) {
  return !!aliasFor(token) || Object.prototype.hasOwnProperty.call(KNOWN, codeFor(token))
}

function parseSource(text) {
  var match = AMOUNT_FIRST.exec(text)
  if (match) return { amount: Number(match[1].replace(/,/g, "")), token: match[2] }
  match = CURRENCY_FIRST.exec(text)
  if (match) return { amount: Number(match[2].replace(/,/g, "")), token: match[1] }
  return null
}

// { amount, from, to, known } in lowercase codes, or null when the text is not
// shaped like a conversion. known counts the sides that are certainly currencies:
// CurrencyLookup won't touch the network for text with none. "usd to inr" means
// one unit; a bare "5 usd inr" is allowed because an amount makes the intent clear.
function parse(text) {
  var query = String(text || "").trim().toLowerCase()
  if (query.length > MAX_LENGTH) return null
  query = query.replace(TRAILING_PUNCTUATION, "").replace(LEADING_WORDS, "")
  var source = null
  var target = ""
  var hasAmount = true

  var match = WITH_CONNECTOR.exec(query)
  if (match) {
    target = match[2]
    source = parseSource(match[1])
    if (!source && CURRENCY_ALONE.test(match[1])) {
      source = { amount: 1, token: match[1] }
      hasAmount = false
    }
  } else {
    match = WITHOUT_CONNECTOR.exec(query)
    if (match) {
      target = match[2]
      source = parseSource(match[1])
    }
  }

  if (!source || !isFinite(source.amount)) return null
  // An unfinished "100 inr to" has no target yet.
  if (/^(?:to|in|into|as)$/.test(target)) return null
  var from = codeFor(source.token)
  var to = codeFor(target)
  if (!from || !to) return null

  var known = (isKnown(source.token) ? 1 : 0) + (isKnown(target) ? 1 : 0)
  if (!hasAmount && known < 2) return null
  return { amount: source.amount, from: from, to: to, known: known }
}

// Two decimals is enough for money, but a small result needs its significant
// digits or 1 INR to BTC would read 0.00. Numbers.plain writes the result out.
function round(value) {
  var size = Math.abs(value)
  if (size === 0 || size >= 1) return Number(value.toFixed(2))
  return Number(value.toPrecision(4))
}

if (typeof module !== "undefined") {
  module.exports = {
    parse: parse,
    round: round
  }
}
