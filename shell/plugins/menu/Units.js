// Reads a unit conversion out of the search line: "5 km to mi", "100 c to f",
// "5 ft 11 in to cm", "3/4 cup to tbsp", "how many feet in a mile". Everything is
// worked out here, so unlike a currency nothing reaches the network.
//
// Each unit has a size in its kind's base unit. Temperature and fuel economy are
// the exceptions: a temperature has an offset and a floor at absolute zero, and
// litres per 100 km is the other way up from km per litre, so those units carry a
// pair of functions instead.
//
// Case matters only where two units differ by it alone: "mW" and "MW", "Mb"
// (bits) and "MB", "kN" (kilonewton) and "kn" (knot), "Cal" (a food calorie, a
// kilocalorie) and "cal". All-lowercase data units are bytes, as "5 gb to mb" is
// almost always meant, and the lowercase forms that could be either ("mw", a bare
// "b") are no unit at all.

// Longer than any conversion typed by hand. Search text past it stays a search.
var MAX_LENGTH = 80
// Enough for any measurement, and short of the digits where float noise shows.
var DIGITS = 10

var INCH = 0.0254
var FOOT = INCH * 12
var YARD = FOOT * 3
var MILE = YARD * 1760
var POUND = 0.45359237
var GRAVITY = 9.80665
var US_GALLON = 231 * INCH * INCH * INCH * 1000
var IMPERIAL_GALLON = 4.54609
var BTU = 1055.05585262
var LIGHT_YEAR = 9460730472580800
var ASTRONOMICAL_UNIT = 149597870700

var UNITS = {}
var KINDS = {}
// Aliases with a capital letter only match as typed; the rest match any case.
var EXACT = {}
var ANY_CASE = {}

function own(table, key) {
  return Object.prototype.hasOwnProperty.call(table, key)
}

function plurals(names) {
  var out = []
  names.forEach(function(name) { out.push(name, name + "s") })
  return out
}

function define(kind, symbol, size, aliases, functions) {
  var unit = { kind: kind, symbol: symbol, size: size }
  if (functions) {
    unit.toBase = functions[0]
    unit.fromBase = functions[1]
  }
  UNITS[symbol] = unit
  if (!own(KINDS, kind)) KINDS[kind] = []
  KINDS[kind].push(symbol)
  ;[symbol].concat(aliases || []).forEach(function(alias) {
    var table = alias === alias.toLowerCase() ? ANY_CASE : EXACT
    table[alias] = symbol
  })
}

var LENGTHS = [
  ["m", 1, plurals(["meter", "metre"])],
  ["km", 1000, plurals(["kilometer", "kilometre"]).concat(["kms"])],
  ["cm", 0.01, plurals(["centimeter", "centimetre"])],
  ["mm", 0.001, plurals(["millimeter", "millimetre"])],
  ["µm", 1e-6, ["um", "μm"].concat(plurals(["micrometer", "micrometre", "micron"]))],
  ["nm", 1e-9, plurals(["nanometer", "nanometre"])],
  ["Å", 1e-10, ["å", "angstrom", "angstroms"]],
  ["mi", MILE, plurals(["mile"])],
  ["yd", YARD, ["yds"].concat(plurals(["yard"]))],
  ["ft", FOOT, ["foot", "feet", "'", "′"]],
  ["in", INCH, ["inch", "inches", "\"", "″"]],
  ["nmi", 1852, plurals(["nautical mile"])],
  ["ly", LIGHT_YEAR, plurals(["light year", "lightyear", "light-year"])],
  ["au", ASTRONOMICAL_UNIT, plurals(["astronomical unit"])],
  ["pc", ASTRONOMICAL_UNIT * 648000 / Math.PI, plurals(["parsec"])],
  ["fur", MILE / 8, plurals(["furlong"])],
  ["thou", INCH / 1000, []]
]
LENGTHS.forEach(function(length) { define("length", length[0], length[1], length[2]) })

// Squares and cubes of the lengths people measure areas and volumes in.
var SPELLED = {
  m: ["meter", "meters", "metre", "metres"], km: ["kilometer", "kilometers", "kilometre", "kilometres"],
  cm: ["centimeter", "centimeters", "centimetre", "centimetres"], mm: ["millimeter", "millimeters", "millimetre", "millimetres"],
  ft: ["foot", "feet"], in: ["inch", "inches"], yd: ["yard", "yards"], mi: ["mile", "miles"]
}
Object.keys(SPELLED).forEach(function(symbol) {
  var size = UNITS[symbol].size
  define("area", symbol + "²", size * size, [symbol + "2", symbol + "^2", "sq " + symbol, "sq. " + symbol]
    .concat(SPELLED[symbol].map(function(name) { return "square " + name })))
  if (symbol === "mi") return
  // Litres are the base of volume, and a cubic metre holds a thousand.
  define("volume", symbol + "³", size * size * size * 1000, [symbol + "3", symbol + "^3", "cu " + symbol, "cu. " + symbol]
    .concat(SPELLED[symbol].map(function(name) { return "cubic " + name }))
    .concat(symbol === "cm" ? ["cc"] : []))
})
define("area", "ha", 10000, plurals(["hectare"]))
define("area", "ac", 43560 * FOOT * FOOT, plurals(["acre"]))

define("mass", "kg", 1, ["kgs"].concat(plurals(["kilogram", "kilo"])))
define("mass", "g", 0.001, plurals(["gram", "gramme"]))
define("mass", "mg", 1e-6, plurals(["milligram"]))
define("mass", "µg", 1e-9, ["ug", "μg", "mcg"].concat(plurals(["microgram"])))
define("mass", "t", 1000, plurals(["tonne", "metric ton"]))
define("mass", "ton", 2000 * POUND, plurals(["ton", "short ton", "us ton"]))
define("mass", "long ton", 2240 * POUND, plurals(["long ton", "imperial ton", "uk ton"]))
define("mass", "lb", POUND, ["lbs"].concat(plurals(["pound"])))
define("mass", "oz", POUND / 16, plurals(["ounce"]))
define("mass", "st", 14 * POUND, plurals(["stone"]))
define("mass", "ct", 0.0002, plurals(["carat"]))
define("mass", "gr", POUND / 7000, plurals(["grain"]))

// Celsius is the base, so a whole number of degrees stays whole between C and F.
var ZERO_CELSIUS = 273.15
define("temperature", "°C", 0, ["°c", "c", "celsius", "centigrade", "degc", "deg c", "degree c", "degrees c", "degree celsius", "degrees celsius"],
  [function(c) { return c }, function(c) { return c }])
define("temperature", "°F", 0, ["°f", "f", "fahrenheit", "degf", "deg f", "degree f", "degrees f", "degree fahrenheit", "degrees fahrenheit"],
  [function(f) { return (f - 32) * 5 / 9 }, function(c) { return c * 9 / 5 + 32 }])
define("temperature", "K", 0, ["k", "kelvin", "kelvins", "degrees kelvin"],
  [function(k) { return k - ZERO_CELSIUS }, function(c) { return c + ZERO_CELSIUS }])
define("temperature", "°R", 0, ["°r", "r", "rankine", "degr", "deg r", "degrees rankine"],
  [function(r) { return r * 5 / 9 - ZERO_CELSIUS }, function(c) { return (c + ZERO_CELSIUS) * 9 / 5 }])

// US measures unless they say otherwise.
define("volume", "L", 1, ["l"].concat(plurals(["liter", "litre"])))
define("volume", "mL", 0.001, ["ml"].concat(plurals(["milliliter", "millilitre"])))
define("volume", "cL", 0.01, ["cl"].concat(plurals(["centiliter", "centilitre"])))
define("volume", "dL", 0.1, ["dl"].concat(plurals(["deciliter", "decilitre"])))
define("volume", "gal", US_GALLON, ["us gal"].concat(plurals(["gallon", "us gallon"])))
define("volume", "qt", US_GALLON / 4, ["us qt"].concat(plurals(["quart", "us quart"])))
define("volume", "pt", US_GALLON / 8, ["us pt"].concat(plurals(["pint", "us pint"])))
define("volume", "cup", US_GALLON / 16, ["cups", "us cup", "us cups"])
define("volume", "fl oz", US_GALLON / 128, ["floz", "fl. oz", "fl.oz", "us fl oz"].concat(plurals(["fluid ounce", "us fluid ounce"])))
define("volume", "tbsp", US_GALLON / 256, ["tbs", "tbsps"].concat(plurals(["tablespoon"])))
define("volume", "tsp", US_GALLON / 768, ["tsps"].concat(plurals(["teaspoon"])))
define("volume", "imp gal", IMPERIAL_GALLON, ["uk gal"].concat(plurals(["imperial gallon", "uk gallon"])))
define("volume", "imp qt", IMPERIAL_GALLON / 4, ["uk qt"].concat(plurals(["imperial quart", "uk quart"])))
define("volume", "imp pt", IMPERIAL_GALLON / 8, ["uk pt"].concat(plurals(["imperial pint", "uk pint"])))
define("volume", "imp fl oz", IMPERIAL_GALLON / 160, ["uk fl oz"].concat(plurals(["imperial fluid ounce", "uk fluid ounce"])))

define("speed", "m/s", 1, ["mps", "meter per second", "metre per second", "meters per second", "metres per second"])
define("speed", "km/h", 1 / 3.6, ["kph", "kmh", "kmph", "km/hr", "km per hour", "kilometers per hour", "kilometres per hour", "kilometer per hour", "kilometre per hour"])
define("speed", "mph", MILE / 3600, ["mi/h", "mi/hr", "mile per hour", "miles per hour"])
define("speed", "kn", 1852 / 3600, ["kt", "kts", "knot", "knots"])
define("speed", "ft/s", FOOT, ["fps", "ft/sec", "foot per second", "feet per second"])

define("time", "ns", 1e-9, plurals(["nanosecond"]))
define("time", "µs", 1e-6, ["us", "μs"].concat(plurals(["microsecond"])))
define("time", "ms", 0.001, plurals(["millisecond"]))
define("time", "s", 1, ["sec", "secs"].concat(plurals(["second"])))
define("time", "min", 60, ["mins"].concat(plurals(["minute"])))
define("time", "h", 3600, ["hr", "hrs"].concat(plurals(["hour"])))
define("time", "d", 86400, plurals(["day"]))
define("time", "wk", 7 * 86400, ["wks"].concat(plurals(["week"])))
define("time", "fortnight", 14 * 86400, ["fortnights"])
// Julian years, as astronomy uses: 365.25 days, a month being a twelfth of one.
define("time", "mo", 365.25 * 86400 / 12, ["mos"].concat(plurals(["month"])))
define("time", "yr", 365.25 * 86400, ["yrs"].concat(plurals(["year"])))
define("time", "decade", 3652.5 * 86400, ["decades"])
define("time", "century", 36525 * 86400, ["centuries"])

// SI prefixes count in thousands and IEC ones in 1024s, so a kB is 1000 bytes.
define("data", "bit", 1, ["bits"])
define("data", "B", 8, plurals(["byte"]))
;[["k", "kilo", "kibi"], ["M", "mega", "mebi"], ["G", "giga", "gibi"], ["T", "tera", "tebi"], ["P", "peta", "pebi"]].forEach(function(prefix, index) {
  var symbol = prefix[0]
  var lower = symbol.toLowerCase()
  var upper = symbol.toUpperCase()
  var decimal = Math.pow(1000, index + 1)
  var binary = Math.pow(1024, index + 1)
  define("data", symbol + "B", 8 * decimal, [lower + "b", upper + "B"].concat(plurals([prefix[1] + "byte"])))
  define("data", upper + "iB", 8 * binary, [lower + "ib"].concat(plurals([prefix[2] + "byte"])))
  define("data", symbol + "bit", decimal, [lower + "bit", upper + "b"].concat(plurals([prefix[1] + "bit"])))
  if (index > 2) return
  define("data rate", symbol + "bit/s", decimal, [lower + "bps", lower + "bit/s", upper + "b/s"])
  define("data rate", symbol + "B/s", 8 * decimal, [lower + "b/s", upper + "B/s"])
})
define("data rate", "bit/s", 1, ["bps"])
define("data rate", "B/s", 8, [])

define("pressure", "Pa", 1, ["pa"].concat(plurals(["pascal"])))
define("pressure", "hPa", 100, ["hpa"].concat(plurals(["hectopascal"])))
define("pressure", "kPa", 1000, ["kpa"].concat(plurals(["kilopascal"])))
define("pressure", "MPa", 1e6, ["mpa"].concat(plurals(["megapascal"])))
define("pressure", "bar", 1e5, ["bars"])
define("pressure", "mbar", 100, ["mbars"].concat(plurals(["millibar"])))
define("pressure", "atm", 101325, ["atms"].concat(plurals(["atmosphere"])))
define("pressure", "psi", POUND * GRAVITY / (INCH * INCH), [])
define("pressure", "mmHg", 133.322387415, ["mmhg"])
define("pressure", "Torr", 101325 / 760, ["torr"])
define("pressure", "inHg", 3386.389, ["inhg"])

define("energy", "J", 1, ["j"].concat(plurals(["joule"])))
define("energy", "kJ", 1000, ["kj"].concat(plurals(["kilojoule"])))
define("energy", "MJ", 1e6, ["mj"].concat(plurals(["megajoule"])))
define("energy", "GJ", 1e9, ["gj"].concat(plurals(["gigajoule"])))
define("energy", "cal", 4.184, plurals(["calorie"]))
define("energy", "kcal", 4184, ["Cal"].concat(plurals(["kilocalorie"])))
define("energy", "Wh", 3600, ["wh"].concat(plurals(["watt hour", "watt-hour"])))
define("energy", "kWh", 3.6e6, ["kwh"].concat(plurals(["kilowatt hour", "kilowatt-hour"])))
define("energy", "MWh", 3.6e9, ["mwh"].concat(plurals(["megawatt hour", "megawatt-hour"])))
define("energy", "eV", 1.602176634e-19, ["ev"].concat(plurals(["electronvolt"])))
define("energy", "BTU", BTU, ["btu", "btus"])
define("energy", "therm", 105480400, ["therms"])

define("power", "W", 1, ["w"].concat(plurals(["watt"])))
define("power", "mW", 0.001, plurals(["milliwatt"]))
define("power", "kW", 1000, ["kw"].concat(plurals(["kilowatt"])))
define("power", "MW", 1e6, plurals(["megawatt"]))
define("power", "GW", 1e9, ["gw"].concat(plurals(["gigawatt"])))
define("power", "hp", 550 * FOOT * POUND * GRAVITY, ["horsepower"])
define("power", "PS", 735.49875, ["metric horsepower"])
define("power", "BTU/h", BTU / 3600, ["btu/h", "btu/hr"])

// Degrees are the base, so a whole number of them stays whole.
define("angle", "°", 1, ["deg", "degs"].concat(plurals(["degree"])))
define("angle", "rad", 180 / Math.PI, ["rads"].concat(plurals(["radian"])))
define("angle", "grad", 0.9, ["grads", "gon", "gons"].concat(plurals(["gradian"])))
define("angle", "turn", 360, ["turns", "rev", "revs"].concat(plurals(["revolution"])))
define("angle", "arcmin", 1 / 60, ["arcmins"].concat(plurals(["arcminute"])))
define("angle", "arcsec", 1 / 3600, ["arcsecs"].concat(plurals(["arcsecond"])))

define("frequency", "Hz", 1, ["hz", "hertz"])
define("frequency", "kHz", 1000, ["khz", "kilohertz"])
define("frequency", "MHz", 1e6, ["mhz", "megahertz"])
define("frequency", "GHz", 1e9, ["ghz", "gigahertz"])
define("frequency", "THz", 1e12, ["thz", "terahertz"])
define("frequency", "rpm", 1 / 60, ["revolutions per minute"])

define("force", "N", 1, ["n"].concat(plurals(["newton"])))
define("force", "kN", 1000, plurals(["kilonewton"]))
define("force", "lbf", POUND * GRAVITY, ["pound-force", "pounds-force", "pound force", "pounds force"])
define("force", "kgf", GRAVITY, ["kp", "kilogram-force", "kilograms-force", "kilogram force", "kilograms force"])
define("force", "dyn", 1e-5, ["dyne", "dynes"])

// Kilometres per litre is the base. Litres per 100 km has no answer for nothing,
// and none of them has one for less than nothing.
function perLitre(size) {
  return [function(x) { return x >= 0 ? x * size : NaN }, function(b) { return b / size }]
}
define("fuel economy", "km/L", 0, ["km/l", "kmpl", "kpl", "km per liter", "km per litre"], perLitre(1))
define("fuel economy", "mpg", 0, ["mpg us", "us mpg", "mpg (us)"], perLitre(MILE / 1000 / US_GALLON))
define("fuel economy", "mpg (imp)", 0, ["mpg imp", "imp mpg", "mpg uk", "uk mpg", "mpg (uk)"], perLitre(MILE / 1000 / IMPERIAL_GALLON))
define("fuel economy", "L/100 km", 0, ["l/100km", "l/100 km", "l/100kms", "liters per 100 km", "litres per 100 km"],
  [function(x) { return x > 0 ? 100 / x : NaN }, function(b) { return b > 0 ? 100 / b : NaN }])

// A unit by any of its names, or null.
function unitFor(text) {
  var name = String(text || "").trim().replace(/\s+/g, " ").replace(/°\s+/g, "°")
  if (!name) return null
  if (own(EXACT, name)) return UNITS[EXACT[name]]
  name = name.toLowerCase()
  return own(ANY_CASE, name) ? UNITS[ANY_CASE[name]] : null
}

// Commas only as thousands groups, Indian ones included, as Currency.js reads
// them: "1,25" is a decimal in much of the world, so it stays a search.
var NUMBER = "(?:\\d{1,3}(?:,\\d{2,3})*,\\d{3}|\\d+)(?:\\.\\d+)?|\\.\\d+"
var AMOUNT = new RegExp("^([-−]?)(?:(\\d+) (\\d+)/(\\d+)|(\\d+)/(\\d+)|(" + NUMBER + "))(?![\\d.,/])")
var ARTICLE = /^(?:a|an|one) (?=\S)/i
var STARTS_AMOUNT = /^ ?(?:\d|\.\d)/

// The amount at the start of the text, or null: "1,000", ".5", "3/4", "1 1/2".
function readAmount(text, first) {
  var match = AMOUNT.exec(text)
  if (!match || (match[1] && !first)) return null
  var value
  if (match[2] !== undefined) value = Number(match[2]) + Number(match[3]) / Number(match[4])
  else if (match[5] !== undefined) value = Number(match[5]) / Number(match[6])
  else value = Number(match[7].replace(/,/g, ""))
  if (!isFinite(value)) return null
  return { value: match[1] ? -value : value, length: match[0].length }
}

// The parts of "5 ft 11 in" from position on, each an amount and its unit, or
// null. The longest unit name that leaves a valid rest wins, so "fl oz" is one
// unit and "m 50 cm" is a metre and fifty centimetres.
function readParts(text, first) {
  var amount = readAmount(text, first)
  if (!amount) return null
  var rest = text.slice(amount.length).replace(/^ /, "")
  for (var end = rest.length; end > 0; end--) {
    var unit = unitFor(rest.slice(0, end))
    if (!unit) continue
    var after = rest.slice(end)
    var part = { amount: amount.value, unit: unit }
    if (after.trim() === "") return [part]
    if (!STARTS_AMOUNT.test(after)) continue
    var more = readParts(after.replace(/^ /, ""), false)
    if (more) return [part].concat(more)
  }
  return null
}

// A quantity: one amount and unit, an article and a unit ("a mile"), or several
// lengths, masses or times to add up ("5 ft 11 in", "1 h 30 min").
function readQuantity(text, articleOptional) {
  var article = ARTICLE.exec(text)
  if (article || articleOptional) {
    var unit = unitFor(article ? text.slice(article[0].length) : text)
    if (unit) return { amount: 1, unit: unit, parts: [{ amount: 1, unit: unit }] }
    if (article) return null
  }
  var parts = readParts(text, true)
  if (!parts) return null
  if (parts.length === 1) return { amount: parts[0].amount, unit: parts[0].unit, parts: parts }
  var kind = parts[0].unit.kind
  var base = 0
  for (var i = 0; i < parts.length; i++) {
    var part = parts[i]
    if (part.unit.kind !== kind || part.unit.toBase || part.amount < 0) return null
    base += part.amount * part.unit.size
  }
  return { amount: base / parts[0].unit.size, unit: parts[0].unit, parts: parts }
}

// Ten significant digits hide float noise without rounding away a measurement.
// A temperature also goes through an offset, which leaves noise next to zero, so
// it keeps nine decimals at most. Either way a zero is never negative.
function round(value, kind) {
  if (kind === "temperature") value = Number(value.toFixed(9))
  return Number(value.toPrecision(DIGITS)) + 0
}

function answer(source, to) {
  var from = source.unit
  if (from.kind !== to.kind) return null
  var base = from.toBase ? from.toBase(source.amount) : source.amount * from.size
  // Absolute zero, give or take the noise of the offset that got there.
  if (from.kind === "temperature" && base < -ZERO_CELSIUS - 1e-9) return null
  var value = to.fromBase ? to.fromBase(base) : base / to.size
  if (!isFinite(value)) return null
  return {
    amount: source.amount, from: from.symbol, value: round(value, to.kind), to: to.symbol, kind: from.kind,
    parts: source.parts.map(function(part) { return { amount: part.amount, unit: part.unit.symbol } })
  }
}

var LEADING_WORDS = /^(?:(?:please )?(?:convert|change) |how much is |what is |what's |whats )/i
var TRAILING_PUNCTUATION = /[?!.]+$/
var CONNECTOR = /^(?: (?:to|in|into|as) | ?(?:=>|->|→|=) ?)/i
var HOW_MANY = /^how many (.+?) (?:are )?in (.+)$/i

// "how many feet in a mile": the target comes first, and the amount can be left out.
function howMany(query) {
  var match = HOW_MANY.exec(query)
  if (!match) return null
  var to = unitFor(match[1])
  var source = to && readQuantity(match[2], true)
  return source ? answer(source, to) : null
}

// { amount, from, value, to, kind, parts } with the units' symbols, or null when
// the text is not a conversion. amount is in the from unit, so "5 ft 11 in" reads
// as 5.9166… ft, while parts keeps what was typed.
function convert(text) {
  var query = String(text || "").trim().replace(/\s+/g, " ")
  if (!query || query.length > MAX_LENGTH) return null
  query = query.replace(TRAILING_PUNCTUATION, "").replace(LEADING_WORDS, "")
  if (/^how many /i.test(query)) return howMany(query)

  // Each connector in turn, as "in" can be a unit too: "5 in in cm".
  for (var i = 1; i < query.length; i++) {
    var connector = CONNECTOR.exec(query.slice(i))
    if (!connector) continue
    var result = split(query.slice(0, i), query.slice(i + connector[0].length))
    if (result) return result
  }
  // Then without one, "5 km mi", where an amount makes the intent clear. A
  // trailing "in" is a connector still waiting for its unit, not inches.
  if (/ (?:to|in|into|as)$/i.test(query)) return null
  for (var j = query.indexOf(" "); j > 0; j = query.indexOf(" ", j + 1)) {
    var bare = split(query.slice(0, j), query.slice(j + 1))
    if (bare) return bare
  }
  return null
}

function split(sourceText, targetText) {
  var to = unitFor(targetText)
  var source = to && readQuantity(sourceText, false)
  return source ? answer(source, to) : null
}

// Every kind with the symbols of its units, as answers show them.
function kinds() {
  var out = {}
  Object.keys(KINDS).forEach(function(kind) { out[kind] = KINDS[kind].slice() })
  return out
}

if (typeof module !== "undefined") {
  module.exports = {
    convert: convert,
    kinds: kinds
  }
}
