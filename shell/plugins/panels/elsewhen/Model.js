.pragma library

// Pure helpers for the world clock. Kept free of QML types so they can be
// exercised from plain JS in tests/.
//
// Qt's QML engine has no Intl, so there is no way to ask JavaScript for the
// time in an arbitrary IANA zone. What we can do is ask `date` once for each
// zone's current UTC offset, then tick locally against that offset. Offsets
// only move at a DST boundary, and the offsets are refetched whenever the
// panel opens and every few minutes while it is open, so the displayed time
// stays honest without spawning a process per second.

var DEFAULT_ZONES = "Los Angeles|America/Los_Angeles, Paris|Europe/Paris, Tokyo|Asia/Tokyo"

var WEEKDAYS = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
var MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

// "Los Angeles|America/Los_Angeles, Tokyo|Asia/Tokyo" -> [{label, id}, ...]
// A bare "Asia/Tokyo" is accepted too and labelled from its last path segment.
// What a zone id may contain. Ids are handed to `date` as arguments, never
// interpolated into a script, so this is not an injection guard - it keeps
// the list free of entries that could never name a zone.
var ZONE_ID = /^[A-Za-z0-9_+\-\/]+$/

// Labels are stored in a "Label|Zone, Label|Zone" string, so a label may not
// carry either delimiter: "Tokyo, Japan" would otherwise come back from
// shell.json as two rows called "Tokyo" and "Japan".
function cleanLabel(label) {
  return String(label || "").replace(/[,|]/g, " ").replace(/\s+/g, " ").trim()
}

function parseZones(spec) {
  // An empty setting is a fresh install, not a request for the old hardcoded
  // trio: it returns nothing so the panel knows to seed itself. DEFAULT_ZONES
  // survives only as the last resort if even the local zone cannot be read.
  var text = String(spec === undefined || spec === null ? "" : spec)
  var out = []
  var parts = text.split(",")
  for (var i = 0; i < parts.length; i++) {
    var entry = parts[i].trim()
    if (entry === "") continue
    // "Label|Zone" or "Label|Zone|w", where the third field marks a city as
    // one of the working group the overlap band is computed from. Zone ids
    // never contain a pipe, so splitting on it is safe.
    var fields = entry.split("|")
    var label = ""
    var id = ""
    var work = false
    if (fields.length >= 2) {
      label = fields[0].trim()
      id = fields[1].trim()
      work = String(fields[2] || "").trim() === "w"
    } else {
      id = entry
      label = entry.split("/").pop().replace(/_/g, " ")
    }
    if (id === "" || !ZONE_ID.test(id)) continue
    if (label === "") label = id.split("/").pop().replace(/_/g, " ")
    out.push({ label: label, id: id, work: work })
  }
  return out
}

// "-0700" -> -420. Returns null for anything unparseable.
function parseOffset(text) {
  var m = /^([+-])(\d{2})(\d{2})$/.exec(String(text || "").trim())
  if (!m) return null
  var minutes = parseInt(m[2], 10) * 60 + parseInt(m[3], 10)
  return m[1] === "-" ? -minutes : minutes
}

// One "America/Los_Angeles|PDT|-0700" line from the probe.
function parseProbeLine(line) {
  var fields = String(line || "").split("|")
  if (fields.length < 3) return null
  var id = fields[0].trim()
  var offset = parseOffset(fields[2])
  if (id === "" || offset === null) return null
  return { id: id, abbr: fields[1].trim(), offsetMinutes: offset }
}

// The system's own IANA zone. The probe emits it as a "LOCAL|<zone>" line;
// parseProbe ignores that line because it carries no offset, so the two
// parsers can share one process without stepping on each other.
function localZoneFromProbe(text) {
  var lines = String(text || "").split("\n")
  for (var i = 0; i < lines.length; i++) {
    var f = lines[i].split("|")
    if (f.length >= 2 && f[0].trim() === "LOCAL") return f[1].trim()
  }
  return ""
}

// Whole probe stdout -> { "America/Los_Angeles": {abbr, offsetMinutes}, ... }
// "UTC+2", "UTC-3:30", and plain "UTC" at Greenwich.
//
// Whole hours drop the minutes: most zones are whole hours, and ":00" on
// every one of them is noise. The odd ones keep them, because a zone that is
// three quarters of an hour off is exactly the case somebody is reading this
// line to find out about.
//
// Not the same thing as the offset on a row. That one is relative to where
// you are - "+9h" means nine hours from here - and this one is absolute,
// because a city you have not added yet has no relationship to you yet.
function utcOffsetLabel(minutes) {
  if (minutes === undefined || minutes === null) return ""
  var total = Number(minutes)
  if (!isFinite(total)) return ""
  total = Math.round(total)
  if (total === 0) return "UTC"
  var abs = Math.abs(total)
  var hours = Math.floor(abs / 60)
  var mins = abs % 60
  return "UTC" + (total < 0 ? "-" : "+") + hours
       + (mins === 0 ? "" : ":" + (mins < 10 ? "0" : "") + mins)
}

function parseProbe(text) {
  var map = {}
  var lines = String(text || "").split("\n")
  for (var i = 0; i < lines.length; i++) {
    var parsed = parseProbeLine(lines[i])
    if (parsed) map[parsed.id] = { abbr: parsed.abbr, offsetMinutes: parsed.offsetMinutes }
  }
  return map
}

// Shift the instant by the zone offset, then read it back with the UTC
// getters — that yields the wall-clock fields as that zone would show them.
function zoneParts(nowMs, offsetMinutes) {
  var d = new Date(Number(nowMs) + Number(offsetMinutes) * 60000)
  return {
    year: d.getUTCFullYear(),
    month: d.getUTCMonth(),
    day: d.getUTCDate(),
    weekday: d.getUTCDay(),
    hour: d.getUTCHours(),
    minute: d.getUTCMinutes()
  }
}

function localParts(nowMs) {
  var d = new Date(Number(nowMs))
  return {
    year: d.getFullYear(),
    month: d.getMonth(),
    day: d.getDate(),
    weekday: d.getDay(),
    hour: d.getHours(),
    minute: d.getMinutes()
  }
}

// Whole days between two date triples, as seen from `from`. Uses UTC
// arithmetic on the calendar fields alone so DST cannot skew the count.
function dayDelta(parts, reference) {
  var a = Date.UTC(parts.year, parts.month, parts.day)
  var b = Date.UTC(reference.year, reference.month, reference.day)
  return Math.round((a - b) / 86400000)
}

function dayLabel(delta) {
  if (delta === 0) return ""
  if (delta === 1) return "Tomorrow"
  if (delta === -1) return "Yesterday"
  return delta > 0 ? "+" + delta + " days" : delta + " days"
}

function pad2(n) {
  return (n < 10 ? "0" : "") + n
}

function formatTime(parts, hour24) {
  if (hour24) return pad2(parts.hour) + ":" + pad2(parts.minute)
  var h = parts.hour % 12
  if (h === 0) h = 12
  return h + ":" + pad2(parts.minute)
}

function meridiem(parts) {
  return parts.hour < 12 ? "AM" : "PM"
}

function formatDate(parts) {
  return WEEKDAYS[parts.weekday].slice(0, 3) + " " + MONTHS[parts.month] + " " + parts.day
}

// A rough day/night read, used only to pick the row's icon.
function isDaytime(parts) {
  return parts.hour >= 6 && parts.hour < 18
}

// Which part of the day a city is in. This is clock-based, not astronomical:
// without a latitude and a network round trip there is no real sunrise to
// consult, so the panel commits to fixed civil hours and says so rather than
// implying a precision it does not have.
var DAY_START = 6
var DAY_END = 18
var DAWN_END = 8
var DUSK_START = 17

function phaseFor(parts) {
  var h = parts.hour
  if (h < DAY_START || h >= DAY_END + 2) return "night"
  if (h < DAWN_END) return "dawn"
  if (h < DUSK_START) return "day"
  return "dusk"
}

function phaseLabel(phase) {
  if (phase === "dawn") return "sunrise"
  if (phase === "dusk") return "sunset"
  if (phase === "night") return "night"
  return "daytime"
}

// Where the city sits in its own 24 hours, 0..1. Drives the marker on the
// row's daylight strip.
function dayProgress(parts) {
  return (parts.hour * 60 + parts.minute) / 1440
}

// The lit span of the strip, as two 0..1 fractions.
function daylightStart() { return DAY_START / 24 }
function daylightEnd() { return DAY_END / 24 }

// Whether the marker sits inside the lit band. Deliberately geometric rather
// than derived from phaseFor(): the band is 06-18, but "dusk" runs to 20:00,
// so a phase test would colour the dot as daylight while it sat visibly out
// in the dark end of the strip.
function inDaylight(progress) {
  return progress >= daylightStart() && progress < daylightEnd()
}

// Offset relative to the viewer's own clock, e.g. "+9h" or "-3.5h". A zone on
// the viewer's own offset gets no label at all: "same time" is the one case
// where the reader already knows the answer, and printing it only widens the
// line and pushes the zone abbreviation away from the edge.
function relativeOffsetLabel(zoneOffsetMinutes, localOffsetMinutes) {
  var diff = Number(zoneOffsetMinutes) - Number(localOffsetMinutes)
  if (diff === 0) return ""
  var hours = diff / 60
  var text = (Math.round(hours * 10) / 10).toString()
  return (diff > 0 ? "+" : "") + text + "h"
}

// Everything a row needs, or null when the zone has not been probed yet.
function rowFor(zone, probe, nowMs, localOffsetMinutes, hour24) {
  var info = probe ? probe[zone.id] : null
  if (!info) return { label: zone.label, id: zone.id, ready: false }
  var parts = zoneParts(nowMs, info.offsetMinutes)
  var here = localParts(nowMs)
  var delta = dayDelta(parts, here)
  return {
    label: zone.label,
    id: zone.id,
    ready: true,
    abbr: info.abbr,
    offsetMinutes: info.offsetMinutes,
    time: formatTime(parts, hour24),
    // The local hour on its own, for anything that has to say something about
    // the time of day rather than print it - the greeting, so far.
    hour: parts.hour,
    meridiem: hour24 ? "" : meridiem(parts),
    date: formatDate(parts),
    dayLabel: dayLabel(delta),
    daytime: isDaytime(parts),
    phase: phaseFor(parts),
    lit: inDaylight(dayProgress(parts)),
    phaseLabel: phaseLabel(phaseFor(parts)),
    progress: dayProgress(parts),
    relative: relativeOffsetLabel(info.offsetMinutes, localOffsetMinutes)
  }
}

function rows(zones, probe, nowMs, localOffsetMinutes, hour24) {
  var out = []
  for (var i = 0; i < zones.length; i++)
    out.push(rowFor(zones[i], probe, nowMs, localOffsetMinutes, hour24))
  return out
}

// ---------------------------------------------------------------- editing
//
// Cities are added and removed from the panel, so the zone list has to make
// the round trip back into the `zones` setting that parseZones() reads.

// Which row of the list, if any, is the city the globe just selected.
//
// The two views index different things: a row is an index into `zones`, while
// the globe's `selected` indexes its own catalogue of every city it draws.
// The pair that survives the crossing is (label, zone id) - the globe's
// tracked entries are built from exactly those two fields, so matching on
// them needs no shared index space.
//
// Returns -1 for a city the globe can draw but the list does not track, which
// is the common case: the globe knows every zone's main city and the list
// knows only the handful you chose.
function indexOfZone(zones, label, id) {
  var list = zones || []
  for (var i = 0; i < list.length; i++)
    if (list[i].label === label && list[i].id === id) return i
  return -1
}

// The same crossing as indexOfZone, from the key a caller has been holding on
// to rather than from a label and an id. Used for the list's focus, which has
// to survive `zones` being replaced under it by a reorder or a removal: an
// index into a binding is not an identity, and this project has now been bitten
// by that twice - once on the globe's selection, once here.
//
// An unknown key is -1, which is the same answer as "nothing is focused", and
// is what a removed city should give.
function indexOfZoneKey(zones, key) {
  var list = zones || []
  if (!key) return -1
  for (var i = 0; i < list.length; i++)
    if (factsKey(list[i]) === key) return i
  return -1
}

function labelForZoneId(id) {
  return String(id || "").split("/").pop().replace(/_/g, " ")
}

// [{label, id}] -> "Los Angeles|America/Los_Angeles, Paris|Europe/Paris"
function serializeZones(zones) {
  var parts = []
  for (var i = 0; i < zones.length; i++) {
    var z = zones[i]
    if (!z || !z.id) continue
    var base = z.label && z.label !== "" ? z.label + "|" + z.id : z.id
    parts.push(z.work ? base + "|w" : base)
  }
  return parts.join(", ")
}

// Two cities may share a zone, so a listed entry is identified by its label
// and its zone together.
function hasEntry(zones, id, label) {
  for (var i = 0; i < zones.length; i++)
    if (zones[i].id === id && zones[i].label === label) return true
  return false
}

// Appends unless the zone is already listed; returns the same array when
// there is nothing to do so callers can skip a needless write. The picker
// only ever offers catalogue zones, but the IPC `add` takes whatever it is
// given, so the id and label are held to what parseZones will read back.
function addZone(zones, id, label) {
  var zoneId = String(id || "").trim()
  if (zoneId === "" || !ZONE_ID.test(zoneId)) return zones
  var name = cleanLabel(label)
  if (name === "") name = labelForZoneId(zoneId)
  if (hasEntry(zones, zoneId, name)) return zones
  var out = zones.slice()
  out.push({ label: name, id: zoneId, work: false })
  return out
}

// ------------------------------------------------------- the working group
//
// The overlap band is computed only from cities with the briefcase toggled -
// tracking a city and having a colleague in it are different things.

function toggleWorkAt(zones, index) {
  if (index < 0 || index >= zones.length) return zones
  var out = []
  for (var i = 0; i < zones.length; i++) {
    var z = zones[i]
    out.push(i === index ? { label: z.label, id: z.id, work: !z.work }
                         : { label: z.label, id: z.id, work: z.work })
  }
  return out
}

function workZones(zones) {
  var out = []
  for (var i = 0; i < zones.length; i++) if (zones[i].work) out.push(zones[i])
  return out
}

// Removal is by position: with two rows on the same zone, an id is no longer
// enough to say which one the user clicked.
function removeZoneAt(zones, index) {
  if (zones.length <= 1 || index < 0 || index >= zones.length) return zones
  var out = zones.slice()
  out.splice(index, 1)
  return out
}

// Move a city to a new position. Used by drag-to-reorder, which commits once
// on release rather than shuffling the list as the pointer moves - changing
// the model mid-drag would rebuild the delegates and drop the gesture.
function moveZone(zones, from, to) {
  var n = zones.length
  if (from === to || from < 0 || from >= n || to < 0 || to >= n) return zones
  var out = zones.slice()
  out.splice(to, 0, out.splice(from, 1)[0])
  return out
}

// The last city is never removed — an empty panel has nothing to show and no
// obvious way back.
function removeZone(zones, id) {
  if (zones.length <= 1) return zones
  var out = []
  for (var i = 0; i < zones.length; i++) if (zones[i].id !== id) out.push(zones[i])
  return out.length === zones.length ? zones : out
}

// `timedatectl list-timezones` output -> dropdown options. The city is the
// label and the full IANA name the description, so a search for either
// "tokyo" or "asia" finds it.
function zoneOptions(text, existing) {
  var lines = String(text || "").split("\n")
  var seen = {}
  var out = []

  function offer(id, label) {
    var key = label + "\u0000" + id
    if (seen[key]) return
    if (existing && hasEntry(existing, id, label)) return
    seen[key] = true
    out.push({ value: id, label: label, description: id })
  }

  for (var i = 0; i < lines.length; i++) {
    var id = lines[i].trim()
    if (id === "" || id.indexOf("/") === -1) continue
    offer(id, labelForZoneId(id))
  }
  for (var j = 0; j < CITY_ALIASES.length; j++)
    offer(CITY_ALIASES[j].id, CITY_ALIASES[j].label)

  out.sort(function(a, b) { return a.label < b.label ? -1 : (a.label > b.label ? 1 : 0) })
  return out
}

// Filter the zone catalog for the inline picker. Matches the city name and
// the full IANA id, so "tokyo", "asia", and "asia/tok" all land on Tokyo.
// Prefix matches on the city sort first — typing "par" should reach Paris
// before Valparaiso.
function searchZones(options, query, limit) {
  var q = String(query || "").trim().toLowerCase()
  var max = limit === undefined ? 6 : limit
  var starts = []
  var contains = []
  for (var i = 0; i < options.length; i++) {
    var o = options[i]
    var label = String(o.label).toLowerCase()
    var id = String(o.value).toLowerCase()
    if (q === "") { starts.push(o); }
    else if (label.indexOf(q) === 0) starts.push(o)
    else if (label.indexOf(q) !== -1 || id.indexOf(q) !== -1) contains.push(o)
    if (starts.length >= max && q === "") break
  }
  return starts.concat(contains).slice(0, max)
}

// ---------------------------------------------------------------- aliases
//
// The tz database ships one representative city per zone, so most places a
// person actually thinks of are missing from `timedatectl list-timezones` —
// there is no Miami, only America/New_York. These are extra search entries
// pointing at the zone that already governs them. Adding a city here is a
// one-line change; the only rule is that the zone must be the one that place
// actually observes, DST rules included.
var CITY_ALIASES = [
  // US Eastern
  { label: "Miami", id: "America/New_York" },
  { label: "Boca Raton", id: "America/New_York" },
  { label: "Boston", id: "America/New_York" },
  { label: "Philadelphia", id: "America/New_York" },
  { label: "Washington DC", id: "America/New_York" },
  { label: "Atlanta", id: "America/New_York" },
  { label: "Orlando", id: "America/New_York" },
  { label: "Tampa", id: "America/New_York" },
  { label: "Charlotte", id: "America/New_York" },
  { label: "Pittsburgh", id: "America/New_York" },
  { label: "Cleveland", id: "America/New_York" },
  // US Central
  { label: "Chicago", id: "America/Chicago" },
  { label: "Austin", id: "America/Chicago" },
  { label: "Dallas", id: "America/Chicago" },
  { label: "Houston", id: "America/Chicago" },
  { label: "San Antonio", id: "America/Chicago" },
  { label: "Nashville", id: "America/Chicago" },
  { label: "New Orleans", id: "America/Chicago" },
  { label: "Minneapolis", id: "America/Chicago" },
  { label: "Kansas City", id: "America/Chicago" },
  { label: "St. Louis", id: "America/Chicago" },
  { label: "Memphis", id: "America/Chicago" },
  // US Mountain
  { label: "Salt Lake City", id: "America/Denver" },
  { label: "Albuquerque", id: "America/Denver" },
  { label: "Colorado Springs", id: "America/Denver" },
  { label: "Boulder", id: "America/Denver" },
  // Arizona does not observe DST, so it is its own zone.
  { label: "Tucson", id: "America/Phoenix" },
  { label: "Scottsdale", id: "America/Phoenix" },
  // US Pacific
  { label: "San Francisco", id: "America/Los_Angeles" },
  { label: "San Diego", id: "America/Los_Angeles" },
  { label: "San Jose", id: "America/Los_Angeles" },
  { label: "Oakland", id: "America/Los_Angeles" },
  { label: "Sacramento", id: "America/Los_Angeles" },
  { label: "Seattle", id: "America/Los_Angeles" },
  { label: "Portland", id: "America/Los_Angeles" },
  { label: "Las Vegas", id: "America/Los_Angeles" },
  // Canada
  { label: "Montreal", id: "America/Toronto" },
  { label: "Ottawa", id: "America/Toronto" },
  { label: "Calgary", id: "America/Edmonton" },
  { label: "Victoria", id: "America/Vancouver" },
  // Latin America
  { label: "Rio de Janeiro", id: "America/Sao_Paulo" },
  { label: "Brasilia", id: "America/Sao_Paulo" },
  { label: "Guadalajara", id: "America/Mexico_City" },
  // UK and Ireland
  { label: "Manchester", id: "Europe/London" },
  { label: "Edinburgh", id: "Europe/London" },
  { label: "Glasgow", id: "Europe/London" },
  { label: "Birmingham", id: "Europe/London" },
  { label: "Cambridge", id: "Europe/London" },
  { label: "Oxford", id: "Europe/London" },
  // Continental Europe
  { label: "Munich", id: "Europe/Berlin" },
  { label: "Frankfurt", id: "Europe/Berlin" },
  { label: "Hamburg", id: "Europe/Berlin" },
  { label: "Cologne", id: "Europe/Berlin" },
  { label: "Lyon", id: "Europe/Paris" },
  { label: "Marseille", id: "Europe/Paris" },
  { label: "Nice", id: "Europe/Paris" },
  { label: "Barcelona", id: "Europe/Madrid" },
  { label: "Valencia", id: "Europe/Madrid" },
  { label: "Seville", id: "Europe/Madrid" },
  { label: "Milan", id: "Europe/Rome" },
  { label: "Naples", id: "Europe/Rome" },
  { label: "Florence", id: "Europe/Rome" },
  { label: "Venice", id: "Europe/Rome" },
  { label: "Turin", id: "Europe/Rome" },
  { label: "Rotterdam", id: "Europe/Amsterdam" },
  { label: "Geneva", id: "Europe/Zurich" },
  { label: "Basel", id: "Europe/Zurich" },
  { label: "Gothenburg", id: "Europe/Stockholm" },
  { label: "Porto", id: "Europe/Lisbon" },
  { label: "Krakow", id: "Europe/Warsaw" },
  { label: "St Petersburg", id: "Europe/Moscow" },
  // Asia
  { label: "Beijing", id: "Asia/Shanghai" },
  { label: "Shenzhen", id: "Asia/Shanghai" },
  { label: "Guangzhou", id: "Asia/Shanghai" },
  { label: "Osaka", id: "Asia/Tokyo" },
  { label: "Kyoto", id: "Asia/Tokyo" },
  { label: "Yokohama", id: "Asia/Tokyo" },
  { label: "Nagoya", id: "Asia/Tokyo" },
  { label: "Busan", id: "Asia/Seoul" },
  { label: "Mumbai", id: "Asia/Kolkata" },
  { label: "Delhi", id: "Asia/Kolkata" },
  { label: "New Delhi", id: "Asia/Kolkata" },
  { label: "Bangalore", id: "Asia/Kolkata" },
  { label: "Bengaluru", id: "Asia/Kolkata" },
  { label: "Chennai", id: "Asia/Kolkata" },
  { label: "Hyderabad", id: "Asia/Kolkata" },
  { label: "Pune", id: "Asia/Kolkata" },
  { label: "Abu Dhabi", id: "Asia/Dubai" },
  { label: "Tel Aviv", id: "Asia/Jerusalem" },
  // Oceania and Africa
  { label: "Canberra", id: "Australia/Sydney" },
  { label: "Cape Town", id: "Africa/Johannesburg" },
  { label: "Durban", id: "Africa/Johannesburg" },
  { label: "Alexandria", id: "Africa/Cairo" }
]

// ------------------------------------------------- temperature and currency
//
// worldclock-data.py returns a map keyed by "label|zone" holding a Celsius
// temperature (`c`), an ISO 4217 code (`ccy`), and what one unit of that
// currency is worth in US dollars (`usd`). US cities carry no `ccy` at all —
// quoting dollars in dollars says nothing.

function factsKey(zone) {
  return String(zone.label) + "|" + String(zone.id)
}

// Which unit to print in. An explicit setting wins; anything else - unset,
// empty, or a value nobody recognises - falls through to what the system
// measures in, so a fresh install reads in the units of the place it is
// running rather than in the author's.
//
// Kept here rather than inline in the panel because it is the part with rules:
// the panel's job is only to ask Qt what the measurement system is.
function resolveUnits(setting, auto) {
  var explicit = String(setting === undefined || setting === null ? "" : setting)
    .trim().toUpperCase()
  if (explicit === "C" || explicit === "F") return explicit
  return String(auto).toUpperCase() === "F" ? "F" : "C"
}

// Twelve or twenty-four, read off the system's own short time format. Qt's
// pattern is something like "h:mm AP" or "HH:mm"; the AM/PM designator is the
// only 'a' or 'A' the grammar has, once quoted literal text is stripped - some
// locales write their hour separator as "H'h'mm".
//
// The designator rather than the case of the hour letter: 'h' means 1-12 and
// 'H' means 0-23, which is the same answer, but a locale is free to spell a
// 24-hour clock with either while a designator only ever belongs to a
// 12-hour one.
function usesTwentyFourHour(timeFormat) {
  var pattern = String(timeFormat === undefined || timeFormat === null ? "" : timeFormat)
    .replace(/'[^']*'/g, "")
  return !/[Aa]/.test(pattern)
}

// As with the units: an explicit setting wins, anything else follows the
// system. A stored `false` is an explicit twelve-hour clock and must not fall
// through to the automatic answer, so the boolean is checked before the
// emptiness.
function resolveHour24(setting, auto) {
  if (setting === true || setting === false) return setting
  var text = String(setting === undefined || setting === null ? "" : setting)
    .trim().toLowerCase()
  if (text === "true" || text === "24") return true
  if (text === "false" || text === "12") return false
  return auto === true
}

function formatTemp(celsius, units) {
  if (celsius === undefined || celsius === null) return ""
  if (String(units).toUpperCase() === "C") return Math.round(celsius) + "°C"
  return Math.round(celsius * 9 / 5 + 32) + "°F"
}

// Currencies span four orders of magnitude against the dollar, so a fixed
// number of decimals either wastes room on the euro or rounds the yen to
// nothing. Show two decimals where that carries real information and four
// where it does not.
function formatMoney(usd) {
  if (usd === undefined || usd === null || !isFinite(usd) || usd <= 0) return ""
  if (usd >= 0.01) return "$" + usd.toFixed(2)
  return "$" + usd.toFixed(4)
}

function currencyLabel(facts) {
  if (!facts || !facts.ccy) return ""
  var money = formatMoney(facts.usd)
  return money === "" ? facts.ccy : facts.ccy + " " + money
}

function tempLabel(facts, units) {
  return facts ? formatTemp(facts.c, units) : ""
}

// ----------------------------------------------- overlap band and scrubbing
//
// Two features share this arithmetic. The overlap band answers "when can we
// all talk", and the scrubber answers "if I move the clock, what happens to
// everyone". Both live or die on getting circular time right, so both are
// computed in minutes-of-day with explicit wrap handling rather than by
// juggling Date objects.

var DAY_MINUTES = 1440

// Minutes east of UTC -> that zone's local minute-of-day for a given UTC
// minute-of-day.
function localMinuteOfDay(utcMinute, offsetMinutes) {
  return ((utcMinute + offsetMinutes) % DAY_MINUTES + DAY_MINUTES) % DAY_MINUTES
}

// Is a local minute inside [start, end)? Windows may run past midnight
// (start > end), which is what makes a naive comparison wrong.
function withinWindow(minute, start, end) {
  if (start === end) return false
  if (start < end) return minute >= start && minute < end
  return minute >= start || minute < end          // wraps midnight
}

// UTC minute ranges where every zone is inside its working window at once.
//
// Sampled a minute at a time rather than solved analytically: intersecting N
// circular intervals has enough edge cases (wrapping windows, empty results,
// two separate arcs) that 1440 cheap checks are worth more than clever code.
// Runs that touch both ends of the day are merged, so a window spanning
// midnight comes back as one range with end > 1440 rather than two.
function overlapRuns(offsets, winStart, winEnd) {
  if (!offsets || offsets.length === 0) return []
  var inside = []
  var any = false
  for (var m = 0; m < DAY_MINUTES; m++) {
    var all = true
    for (var i = 0; i < offsets.length; i++) {
      if (!withinWindow(localMinuteOfDay(m, offsets[i]), winStart, winEnd)) { all = false; break }
    }
    inside.push(all)
    if (all) any = true
  }
  if (!any) return []

  var runs = []
  var start = -1
  for (var k = 0; k < DAY_MINUTES; k++) {
    if (inside[k] && start < 0) start = k
    if (!inside[k] && start >= 0) { runs.push({ start: start, end: k }); start = -1 }
  }
  if (start >= 0) runs.push({ start: start, end: DAY_MINUTES })

  // A run ending at midnight and one starting at midnight are one run.
  if (runs.length > 1 && runs[0].start === 0 && runs[runs.length - 1].end === DAY_MINUTES) {
    var last = runs.pop()
    runs[0] = { start: last.start, end: DAY_MINUTES + runs[0].end }
  }
  return runs
}

// A UTC run drawn on one city's strip, as 0..1 fractions of its local day.
// A run crossing that city's local midnight becomes two segments.
function localSegments(runs, offsetMinutes) {
  var out = []
  for (var i = 0; i < runs.length; i++) {
    var a = localMinuteOfDay(runs[i].start, offsetMinutes)
    var span = runs[i].end - runs[i].start
    if (span >= DAY_MINUTES) { out.push({ x0: 0, x1: 1 }); continue }
    var b = a + span
    if (b <= DAY_MINUTES) {
      out.push({ x0: a / DAY_MINUTES, x1: b / DAY_MINUTES })
    } else {
      out.push({ x0: a / DAY_MINUTES, x1: 1 })
      out.push({ x0: 0, x1: (b - DAY_MINUTES) / DAY_MINUTES })
    }
  }
  return out
}

// Total minutes covered by the overlap, for "no overlap" vs "18 minutes".
function overlapMinutes(runs) {
  var total = 0
  for (var i = 0; i < runs.length; i++) total += runs[i].end - runs[i].start
  return total
}

// How far to move the clock when the pointer lands at `fraction` across a
// city's strip. Picks the nearest occurrence of that local time - dragging
// slightly left of now should mean an hour ago, never twenty-three hours on.
function scrubDeltaMinutes(fraction, cityLocalMinutes) {
  var target = Math.max(0, Math.min(1, fraction)) * DAY_MINUTES
  var delta = target - cityLocalMinutes
  while (delta > DAY_MINUTES / 2) delta -= DAY_MINUTES
  while (delta <= -DAY_MINUTES / 2) delta += DAY_MINUTES
  return delta
}

// Round to a whole minute *before* splitting it, and wrap after.
//
// Flooring the hour and rounding the minute independently has no carry between
// them, so a value 12 seconds short of the hour printed "6:60 AM" - an hour
// that reads as the one before and a minute that does not exist. The inputs
// were whole minutes when this was written and are not any more: sunrise and
// sunset land wherever they land, and 23:59:42 has to roll the day as well as
// the hour, which is why the wrap comes after the rounding rather than before.
function formatMinuteOfDay(minute, hour24) {
  var m = Math.round(Number(minute))
  m = ((m % DAY_MINUTES) + DAY_MINUTES) % DAY_MINUTES
  var hour = Math.floor(m / 60)
  return formatTime({ hour: hour, minute: m % 60 }, hour24)
    + (hour24 ? "" : (hour < 12 ? " AM" : " PM"))
}

// ----------------------------------------------- the strip's sunrise arrows
//
// Where an arrow's hit box sits along the bar, and whether the now-marker is
// standing on it. One implementation used twice: to place the arrow, and to
// hide it while the marker is over it.
//
// Here rather than inline in the delegate so the placement is testable: the
// glyph has to land outside the band it points at, and that is a claim about
// arithmetic, not about how it looks.

function arrowBox(fraction, barWidth, boxWidth, tuck, rising) {
  var at = barWidth * fraction
  var pos = rising ? at - boxWidth + tuck : at - tuck
  return Math.round(Math.max(0, Math.min(barWidth - boxWidth, pos)))
}

// The marker covers the arrow when their centres are within a marker's radius
// of each other, plus a little air.
function arrowCovered(boxX, boxWidth, markerCentre, markerWidth, slack) {
  return Math.abs(markerCentre - (boxX + boxWidth / 2)) < markerWidth / 2 + slack
}

// ------------------------------------------------- the row's popup chips
//
// A row can show one chip at a time - sunrise or sunset - held as the slot that
// is showing, or NO_CHIP for none. Two rules, because two different things can
// decide it during a single click.
//
// The arrows sit over the strip's scrub area and over the row's reorder grab.
// A press on an arrow does not reach either of them - measured with synthetic
// mouse events in tests/qml/tst_arrows.qml, after a long stretch of assuming it
// must - but a press on the row body does reach the grab, which dismisses, so
// the two decisions can still meet on one click.
//
// Neither rule reads the live value, then. Both are answered from what was
// showing when the press began, which is the same number whichever of them runs
// first; the delivery order is Qt's business and not worth depending on.
// tests/selection_check.js plays both orders through every case.
//
// Written for any number of slots, though only two are drawn. The moon's phase
// was a third for a day - see the note on the scrub area in Panel.qml.
var NO_CHIP = -1

// A tap on the arrow in `slot`: it closes that chip if it was the
// one already open, and opens it otherwise.
function chipAfterTap(shownAtPress, slot) {
  return shownAtPress === slot ? NO_CHIP : slot
}

// A release on the row body or the bar. It clears the chip, unless something
// else has already changed it during this same press - in which case that
// decision stands and this one keeps out of the way.
function chipAfterRelease(shownNow, shownAtPress) {
  return shownNow === shownAtPress ? NO_CHIP : shownNow
}

// "+3h", "-45m", "" for now. Shown while scrubbing so the offset from the
// real present is never ambiguous.
function formatScrubDelta(minutes) {
  var m = Math.round(minutes)
  if (m === 0) return ""
  var sign = m > 0 ? "+" : "-"
  var a = Math.abs(m)
  if (a < 60) return sign + a + "m"
  var h = Math.floor(a / 60), rem = a % 60
  return sign + h + "h" + (rem ? " " + rem + "m" : "")
}

// --------------------------------------------------------------- weather
//
// Open-Meteo reports WMO present-weather codes: nearly a hundred of them,
// separating drizzle from freezing drizzle from rain showers. A row has space
// for one glyph, so they collapse to the five states worth telling apart at a
// glance. Fog joins cloud rather than getting its own icon - at this size the
// distinction is not worth a symbol nobody can read.
function weatherKind(code) {
  // Number(null) is 0, which is a valid code meaning "clear" - so a missing
  // reading would quietly render a sun. Rejected explicitly first.
  if (code === null || code === undefined || code === "") return ""
  var c = Number(code)
  if (!isFinite(c)) return ""
  if (c <= 1) return "sunny"                      // clear, mainly clear
  if (c === 2) return "partly"                    // partly cloudy
  if (c === 3 || c === 45 || c === 48) return "cloudy"   // overcast, fog
  if (c >= 71 && c <= 77) return "snow"           // snow fall, snow grains
  if (c === 85 || c === 86) return "snow"         // snow showers
  if (c >= 51 && c <= 67) return "rain"           // drizzle, rain, freezing
  if (c >= 80 && c <= 82) return "rain"           // rain showers
  if (c >= 95 && c <= 99) return "rain"           // thunderstorms
  return ""
}

// ------------------------------------------------------------ first run
//
// A fresh install should look like a world clock straight away, without
// asking anyone to configure anything. It gets the city you are in plus four
// more, and those four are chosen relative to *you* rather than being a fixed
// list - a constant list would hand someone in Paris two Parises, and would
// give a reader in Tokyo a spread that is really a spread around California.

var SEED_SEPARATION_MIN = 120     // keep seeds at least two hours off home

// Well-known destinations, wide enough apart to cover the dial. Rank 1 is
// used only to break ties when two cities sit equally near a target.
var SEED_CANDIDATES = [
  { label: "Honolulu", id: "Pacific/Honolulu", rank: 3 },
  { label: "Anchorage", id: "America/Anchorage", rank: 3 },
  { label: "Los Angeles", id: "America/Los_Angeles", rank: 2 },
  { label: "Vancouver", id: "America/Vancouver", rank: 3 },
  { label: "Mexico City", id: "America/Mexico_City", rank: 3 },
  { label: "Chicago", id: "America/Chicago", rank: 3 },
  { label: "New York", id: "America/New_York", rank: 1 },
  { label: "Sao Paulo", id: "America/Sao_Paulo", rank: 2 },
  { label: "Buenos Aires", id: "America/Argentina/Buenos_Aires", rank: 3 },
  { label: "Reykjavik", id: "Atlantic/Reykjavik", rank: 3 },
  { label: "London", id: "Europe/London", rank: 1 },
  { label: "Lisbon", id: "Europe/Lisbon", rank: 3 },
  { label: "Paris", id: "Europe/Paris", rank: 1 },
  { label: "Berlin", id: "Europe/Berlin", rank: 3 },
  { label: "Madrid", id: "Europe/Madrid", rank: 3 },
  { label: "Rome", id: "Europe/Rome", rank: 3 },
  { label: "Cairo", id: "Africa/Cairo", rank: 3 },
  { label: "Johannesburg", id: "Africa/Johannesburg", rank: 3 },
  { label: "Istanbul", id: "Europe/Istanbul", rank: 3 },
  { label: "Moscow", id: "Europe/Moscow", rank: 3 },
  { label: "Nairobi", id: "Africa/Nairobi", rank: 3 },
  { label: "Dubai", id: "Asia/Dubai", rank: 2 },
  { label: "Karachi", id: "Asia/Karachi", rank: 3 },
  { label: "Delhi", id: "Asia/Kolkata", rank: 2 },
  { label: "Bangkok", id: "Asia/Bangkok", rank: 3 },
  { label: "Jakarta", id: "Asia/Jakarta", rank: 3 },
  { label: "Singapore", id: "Asia/Singapore", rank: 2 },
  { label: "Hong Kong", id: "Asia/Hong_Kong", rank: 2 },
  { label: "Shanghai", id: "Asia/Shanghai", rank: 2 },
  { label: "Perth", id: "Australia/Perth", rank: 3 },
  { label: "Seoul", id: "Asia/Seoul", rank: 3 },
  { label: "Tokyo", id: "Asia/Tokyo", rank: 1 },
  { label: "Sydney", id: "Australia/Sydney", rank: 2 },
  { label: "Auckland", id: "Pacific/Auckland", rank: 3 }
]

function seedCandidateZones() {
  var out = []
  for (var i = 0; i < SEED_CANDIDATES.length; i++) out.push(SEED_CANDIDATES[i].id)
  return out
}

// Hours east of home, wrapped to a single turn of the clock: a city 20 hours
// ahead and one 4 hours behind are the same place on a dial.
function eastOf(offsetMinutes, homeMinutes) {
  var d = (offsetMinutes - homeMinutes) % DAY_MINUTES
  return d < 0 ? d + DAY_MINUTES : d
}

function dialDistance(a, b) {
  var d = Math.abs(a - b) % DAY_MINUTES
  return Math.min(d, DAY_MINUTES - d)
}

// Recognisable cities first, kept far enough apart to be worth having.
//
// The alternative - spacing four cities evenly round the dial and taking
// whoever is nearest each mark - gives a tidier spread but a stranger list:
// from Los Angeles it produces Sao Paulo, Cairo, Bangkok and Auckland, which
// is even but reads like a lottery. Going by fame and enforcing a gap gives
// New York, London, Dubai and Tokyo, which is both recognisable and spread,
// because the gap does the spreading.
function pickSeedAt(home, offsets, count, gap) {
  var homeOff = offsets[home.id]
  var homeLabel = String(home.label || "").toLowerCase()
  var picked = []
  for (var i = 0; i < SEED_CANDIDATES.length && picked.length < count; i++) {
    // Left un-sorted and swept once per rank, so ties fall out in the order
    // the table is written - which is west to east, and stable.
    for (var r = 1; r <= 3; r++) {
      for (var j = 0; j < SEED_CANDIDATES.length && picked.length < count; j++) {
        var c = SEED_CANDIDATES[j]
        if (c.rank !== r) continue
        var off = offsets[c.id]
        if (off === undefined || off === null) continue
        if (c.id === home.id) continue
        if (String(c.label).toLowerCase() === homeLabel) continue
        var east = eastOf(off, homeOff)
        if (Math.min(east, DAY_MINUTES - east) < gap) continue
        var clash = false
        for (var k = 0; k < picked.length; k++)
          if (dialDistance(picked[k].east, east) < gap) { clash = true; break }
        if (clash) continue
        picked.push({ label: c.label, id: c.id, east: east })
      }
    }
    break
  }
  return picked
}

// `offsets` maps zone id to minutes east of UTC, and must include home's own.
function pickSeedZones(home, offsets, count) {
  var n = count === undefined ? 4 : count
  if (!home || !home.id || !offsets) return []
  if (offsets[home.id] === undefined || offsets[home.id] === null) return []

  // Three hours apart is the goal. Somewhere like Sydney has half the world
  // sitting within a couple of hours of it, so the gap relaxes rather than
  // handing back a short list.
  var picked = []
  var gaps = [180, 120, 60]
  for (var g = 0; g < gaps.length; g++) {
    picked = pickSeedAt(home, offsets, n, gaps[g])
    if (picked.length >= n) break
  }

  // Sorted eastward from home, so the starting list reads as a journey round
  // the world rather than in the order the picker happened to find them.
  picked.sort(function (a, b) { return a.east - b.east })

  var out = []
  for (var m = 0; m < picked.length; m++)
    out.push({ label: picked[m].label, id: picked[m].id, work: false })
  return out
}

// The whole starting list: the city you are in, then the spread.
function seedZones(home, offsets, count) {
  if (!home || !home.id) return []
  var out = [{ label: home.label, id: home.id, work: false }]
  var rest = pickSeedZones(home, offsets, count)
  for (var i = 0; i < rest.length; i++) out.push(rest[i])
  return out
}
