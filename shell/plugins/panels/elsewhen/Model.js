// QML has no Intl, so each zone's UTC offset comes from a `date` probe and the
// clocks tick locally against it.

var DEFAULT_ZONES = "Los Angeles|America/Los_Angeles, Paris|Europe/Paris, Tokyo|Asia/Tokyo"

var WEEKDAYS = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
var MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

// Keeps the list free of entries that could never name a zone.
var ZONE_ID = /^[A-Za-z0-9_+\-\/]+$/

// Labels live in a "Label|Zone, Label|Zone" string, so they may not carry either delimiter.
function cleanLabel(label) {
  return String(label || "").replace(/[,|]/g, " ").replace(/\s+/g, " ").trim()
}

// "Los Angeles|America/Los_Angeles, Asia/Tokyo" -> [{label, id}, ...]. Empty means a fresh install.
function parseZones(spec) {
  var text = String(spec === undefined || spec === null ? "" : spec)
  var out = []
  var parts = text.split(",")
  for (var i = 0; i < parts.length; i++) {
    var entry = parts[i].trim()
    if (entry === "") continue
    var fields = entry.split("|")
    var label = ""
    var id = ""
    if (fields.length >= 2) {
      label = fields[0].trim()
      id = fields[1].trim()
    } else {
      id = entry
      label = entry.split("/").pop().replace(/_/g, " ")
    }
    if (id === "" || !ZONE_ID.test(id)) continue
    if (label === "") label = id.split("/").pop().replace(/_/g, " ")
    out.push({ label: label, id: id })
  }
  return out
}

// ---- the date probe

// argv for one `date` per zone, printing "Asia/Tokyo|JST|+0900". Zones are
// arguments, never script text. `withLocal` adds "LOCAL|<zone>" plus that zone's own line.
function probeCommand(ids, withLocal) {
  var script = "for z in \"$@\"; do TZ=\"$z\" date \"+$z|%Z|%z\"; done"
  if (withLocal)
    script = "tz=$(timedatectl show -p Timezone --value); "
      + "printf 'LOCAL|%s\\n' \"$tz\"; TZ=\"$tz\" date \"+$tz|%Z|%z\"; " + script
  return ["bash", "-c", script, "bash"].concat(ids || [])
}

// "-0700" -> -420, or null.
function parseOffset(text) {
  var m = /^([+-])(\d{2})(\d{2})$/.exec(String(text || "").trim())
  if (!m) return null
  var minutes = parseInt(m[2], 10) * 60 + parseInt(m[3], 10)
  return m[1] === "-" ? -minutes : minutes
}

function parseProbeLine(line) {
  var fields = String(line || "").split("|")
  if (fields.length < 3) return null
  var id = fields[0].trim()
  var offset = parseOffset(fields[2])
  if (id === "" || offset === null) return null
  return { id: id, abbr: fields[1].trim(), offsetMinutes: offset }
}

function localZoneFromProbe(text) {
  var lines = String(text || "").split("\n")
  for (var i = 0; i < lines.length; i++) {
    var f = lines[i].split("|")
    if (f.length >= 2 && f[0].trim() === "LOCAL") return f[1].trim()
  }
  return ""
}

// Probe stdout -> { "America/Los_Angeles": {abbr, offsetMinutes}, ... }
function parseProbe(text) {
  var map = {}
  var lines = String(text || "").split("\n")
  for (var i = 0; i < lines.length; i++) {
    var parsed = parseProbeLine(lines[i])
    if (parsed) map[parsed.id] = { abbr: parsed.abbr, offsetMinutes: parsed.offsetMinutes }
  }
  return map
}

// Absolute offset: "UTC+2", "UTC-3:30", "UTC". Minutes only when they are not zero.
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

// ---- clock faces

// Shifting the instant by the offset and reading UTC getters gives the zone's wall clock.
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

// Calendar fields only, so DST cannot skew the count.
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

// "14:05" or "2:05 PM" at a zone offset; "" before the offset is known.
function formatClock(nowMs, offsetMinutes, hour24) {
  if (offsetMinutes === undefined || offsetMinutes === null) return ""
  var parts = zoneParts(nowMs, offsetMinutes)
  return formatTime(parts, hour24) + (hour24 ? "" : " " + meridiem(parts))
}

function formatDate(parts) {
  return WEEKDAYS[parts.weekday].slice(0, 3) + " " + MONTHS[parts.month] + " " + parts.day
}

function isDaytime(parts) {
  return parts.hour >= 6 && parts.hour < 18
}

// Fixed civil hours, used until a city's real sunrise is known.
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

function dayProgress(parts) {
  return (parts.hour * 60 + parts.minute) / 1440
}

function daylightStart() { return DAY_START / 24 }
function daylightEnd() { return DAY_END / 24 }

// Geometric, not phaseFor(): "dusk" runs past the end of the lit band.
function inDaylight(progress) {
  return progress >= daylightStart() && progress < daylightEnd()
}

// "+9h" or "-3.5h" from the viewer's clock; "" on the viewer's own offset.
function relativeOffsetLabel(zoneOffsetMinutes, localOffsetMinutes) {
  var diff = Number(zoneOffsetMinutes) - Number(localOffsetMinutes)
  if (diff === 0) return ""
  var hours = diff / 60
  var text = (Math.round(hours * 10) / 10).toString()
  return (diff > 0 ? "+" : "") + text + "h"
}

// Everything a row needs; `ready` is false until the zone has been probed.
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

// ---- editing

// Rows and globe cities share no index space, so they meet on (label, zone id).
function indexOfZone(zones, label, id) {
  var list = zones || []
  for (var i = 0; i < list.length; i++)
    if (list[i].label === label && list[i].id === id) return i
  return -1
}

// Focus is held as a key so it follows the city when `zones` is replaced.
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

// Tapping a city on this machine's clock makes it "here", and the zone's own
// city clears the choice. The new homeCity setting, or null to leave it.
function homeCityAfterTap(label, zoneId, homeOverride, localZone) {
  var name = String(label || "").trim()
  var local = String(localZone || "")
  if (name === "" || local === "" || String(zoneId || "") !== local) return null
  var override = String(homeOverride || "").trim()
  var zoneCity = labelForZoneId(local)
  if (name === (override === "" ? zoneCity : override)) return null
  return name === zoneCity ? "" : name
}

function serializeZones(zones) {
  var parts = []
  for (var i = 0; i < zones.length; i++) {
    var z = zones[i]
    if (!z || !z.id) continue
    parts.push(z.label && z.label !== "" ? z.label + "|" + z.id : z.id)
  }
  return parts.join(", ")
}

// Two cities may share a zone, so an entry is its label and zone together.
function hasEntry(zones, id, label) {
  for (var i = 0; i < zones.length; i++)
    if (zones[i].id === id && zones[i].label === label) return true
  return false
}

// Returns the same array when nothing changes, so callers can skip the write.
function addZone(zones, id, label) {
  var zoneId = String(id || "").trim()
  if (zoneId === "" || !ZONE_ID.test(zoneId)) return zones
  var name = cleanLabel(label)
  if (name === "") name = labelForZoneId(zoneId)
  if (hasEntry(zones, zoneId, name)) return zones
  var out = zones.slice()
  out.push({ label: name, id: zoneId })
  return out
}

// By position: with two rows on one zone, an id cannot say which was clicked.
function removeZoneAt(zones, index) {
  if (zones.length <= 1 || index < 0 || index >= zones.length) return zones
  var out = zones.slice()
  out.splice(index, 1)
  return out
}

function moveZone(zones, from, to) {
  var n = zones.length
  if (from === to || from < 0 || from >= n || to < 0 || to >= n) return zones
  var out = zones.slice()
  out.splice(to, 0, out.splice(from, 1)[0])
  return out
}

// The last city is never removed.
function removeZone(zones, id) {
  if (zones.length <= 1) return zones
  var out = []
  for (var i = 0; i < zones.length; i++) if (zones[i].id !== id) out.push(zones[i])
  return out.length === zones.length ? zones : out
}

// `timedatectl list-timezones` plus CITY_ALIASES -> picker options, minus `existing`.
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

// Matches city name or IANA id; city-name prefixes sort first.
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

// Keyboard selection in a result list, wrapping at both ends.
function moveSelection(index, delta, count) {
  if (count === 0) return 0
  return ((index + delta) % count + count) % count
}

// Globe cities as [name, zone, lat, lon, rank]: home first, then the rest,
// first name wins. Tracked and session cities need coordinates.
function mergeCities(home, builtIn, tracked, session) {
  var out = []
  var seen = {}
  function add(city, needsCoords) {
    if (needsCoords && (city[2] === null || city[2] === undefined)) return
    var key = String(city[0]).toLowerCase()
    if (seen[key]) return
    seen[key] = true
    out.push(city)
  }
  if (home && home.length > 0 && home[2] !== undefined) add(home, false)
  var i
  for (i = 0; i < (builtIn || []).length; i++) add(builtIn[i], false)
  for (i = 0; i < (tracked || []).length; i++) add(tracked[i], true)
  for (i = 0; i < (session || []).length; i++) add(session[i], true)
  return out
}

// Places people think of that the tz database files under another city's zone.
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

// ---- weather

// Coordinates and weather are keyed by "label|zone".
function factsKey(zone) {
  return String(zone.label) + "|" + String(zone.id)
}

var WEATHER_TTL_MS = 20 * 60 * 1000

function geocodeUrl(label) {
  return "https://geocoding-api.open-meteo.com/v1/search?count=10&language=en&format=json&name="
    + encodeURIComponent(label)
}

// { place, answered }: a place in the row's own zone beats the top result, and
// `answered` is false when the request itself failed.
function pickGeocode(text, zone) {
  var results
  try { results = JSON.parse(text).results || [] } catch (e) { return { place: null, answered: false } }
  var best = null
  for (var i = 0; i < results.length && !best; i++) if (results[i].timezone === zone) best = results[i]
  if (!best && results.length > 0) best = results[0]
  return { place: best ? { lat: best.latitude, lon: best.longitude } : null, answered: true }
}

// The zone's representative city from zone1970.tab (ISO 6709), the offline fallback.
function zoneTabCoords(tabText, zone) {
  var lines = String(tabText || "").split("\n")
  for (var i = 0; i < lines.length; i++) {
    var parts = lines[i].split("\t")
    if (lines[i].charAt(0) === "#" || parts.length < 3 || parts[2] !== zone) continue
    var m = /^([+-])(\d{2})(\d{2})(\d{2})?([+-])(\d{3})(\d{2})(\d{2})?$/.exec(parts[1])
    if (!m) return null
    function dec(sign, d, mm, ss) { return (sign === "-" ? -1 : 1) * (Number(d) + Number(mm) / 60 + Number(ss || 0) / 3600) }
    return { lat: Math.round(dec(m[1], m[2], m[3], m[4]) * 1e4) / 1e4, lon: Math.round(dec(m[5], m[6], m[7], m[8]) * 1e4) / 1e4 }
  }
  return null
}

function forecastUrl(points) {
  return "https://api.open-meteo.com/v1/forecast?current=temperature_2m,weather_code&temperature_unit=celsius"
    + "&latitude=" + points.map(function(p) { return p.lat }).join(",")
    + "&longitude=" + points.map(function(p) { return p.lon }).join(",")
}

// Open-Meteo answers one point as an object and several as an array, in request order.
function parseForecast(text, keys, nowMs) {
  var payload
  try { payload = JSON.parse(text) } catch (e) { return {} }
  if (!Array.isArray(payload)) payload = [payload]
  var out = {}
  for (var i = 0; i < keys.length && i < payload.length; i++) {
    var current = (payload[i] && payload[i].current) || {}
    if (current.temperature_2m === undefined || current.temperature_2m === null) continue
    out[keys[i]] = { c: Math.round(current.temperature_2m * 10) / 10, w: current.weather_code, at: nowMs }
  }
  return out
}

function weatherStale(entry, nowMs) {
  return !entry || nowMs - entry.at >= WEATHER_TTL_MS
}

// { "label|zone": { lat, lon, c, w } }, each field only when known.
function mergeFacts(keys, coords, weather) {
  var out = {}
  keys.forEach(function(key) {
    var entry = {}
    if (coords[key]) { entry.lat = coords[key].lat; entry.lon = coords[key].lon }
    if (weather[key]) {
      entry.c = weather[key].c
      if (weather[key].w !== undefined && weather[key].w !== null) entry.w = weather[key].w
    }
    out[key] = entry
  })
  return out
}

// An explicit "C" or "F" wins; anything else follows the system.
function resolveUnits(setting, auto) {
  var explicit = String(setting === undefined || setting === null ? "" : setting)
    .trim().toUpperCase()
  if (explicit === "C" || explicit === "F") return explicit
  return String(auto).toUpperCase() === "F" ? "F" : "C"
}

// Only a 12-hour pattern has an AM/PM designator once quoted literals are stripped.
function usesTwentyFourHour(timeFormat) {
  var pattern = String(timeFormat === undefined || timeFormat === null ? "" : timeFormat)
    .replace(/'[^']*'/g, "")
  return !/[Aa]/.test(pattern)
}

// An explicit setting wins, and a stored `false` is explicit.
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

function tempLabel(facts, units) {
  return facts ? formatTemp(facts.c, units) : ""
}

// WMO present-weather codes collapsed to the five glyphs a row can show.
function weatherKind(code) {
  // Number(null) is 0, which means "clear".
  if (code === null || code === undefined || code === "") return ""
  var c = Number(code)
  if (!isFinite(c)) return ""
  if (c <= 1) return "sunny"
  if (c === 2) return "partly"
  if (c === 3 || c === 45 || c === 48) return "cloudy"
  if (c >= 71 && c <= 77) return "snow"
  if (c === 85 || c === 86) return "snow"
  if (c >= 51 && c <= 67) return "rain"
  if (c >= 80 && c <= 82) return "rain"
  if (c >= 95 && c <= 99) return "rain"
  return ""
}

// ---- scrubbing

var DAY_MINUTES = 1440

// The nearest occurrence of the local time under the pointer, in (-720, 720].
function scrubDeltaMinutes(fraction, cityLocalMinutes) {
  var target = Math.max(0, Math.min(1, fraction)) * DAY_MINUTES
  var delta = target - cityLocalMinutes
  while (delta > DAY_MINUTES / 2) delta -= DAY_MINUTES
  while (delta <= -DAY_MINUTES / 2) delta += DAY_MINUTES
  return delta
}

// Round before splitting into hour and minute, and wrap after, so 419.8 is "7:00".
function formatMinuteOfDay(minute, hour24) {
  var m = Math.round(Number(minute))
  m = ((m % DAY_MINUTES) + DAY_MINUTES) % DAY_MINUTES
  var hour = Math.floor(m / 60)
  return formatTime({ hour: hour, minute: m % 60 }, hour24)
    + (hour24 ? "" : (hour < 12 ? " AM" : " PM"))
}

// "+3h", "-45m", "" for now.
function formatScrubDelta(minutes) {
  var m = Math.round(minutes)
  if (m === 0) return ""
  var sign = m > 0 ? "+" : "-"
  var a = Math.abs(m)
  // The arrow keys can run past a day, where hours alone stop reading well.
  var d = Math.floor(a / DAY_MINUTES), h = Math.floor(a % DAY_MINUTES / 60), rem = a % 60
  var parts = []
  if (d) parts.push(d + "d")
  if (h) parts.push(h + "h")
  if (rem) parts.push(rem + "m")
  return sign + parts.join(" ")
}

// ---- the strip's sunrise arrows

function arrowBox(fraction, barWidth, boxWidth, tuck, rising) {
  var at = barWidth * fraction
  var pos = rising ? at - boxWidth + tuck : at - tuck
  return Math.round(Math.max(0, Math.min(barWidth - boxWidth, pos)))
}

function arrowCovered(boxX, boxWidth, markerCenter, markerWidth, slack) {
  return Math.abs(markerCenter - (boxX + boxWidth / 2)) < markerWidth / 2 + slack
}

// One chip shows at a time. Both rules read what showed at press time, so a
// click comes out the same whichever handler Qt runs first.
var NO_CHIP = -1

function chipAfterTap(shownAtPress, slot) {
  return shownAtPress === slot ? NO_CHIP : slot
}

// Clears the chip unless something else changed it during this press.
function chipAfterRelease(shownNow, shownAtPress) {
  return shownNow === shownAtPress ? NO_CHIP : shownNow
}

// ---- globe transition and row drag

// Rows are knocked aside one after another as `zoom` runs 0..1, alternating sides.
var KNOCK_STAGGER = 0.09
var KNOCK_MAX_LEAD = 0.5
var KNOCK_TILT = 14
var KNOCK_SHRINK = 0.18

function knockAt(index, zoom) {
  var lead = Math.min(KNOCK_MAX_LEAD, index * KNOCK_STAGGER)
  return Math.max(0, Math.min(1, (zoom - lead) / (1 - lead)))
}

function knockSide(index) { return index % 2 === 0 ? -1 : 1 }

function knockX(index, zoom, throwX) { return knockAt(index, zoom) * knockSide(index) * throwX }

// Squared, so rows accelerate as they fall.
function knockY(index, zoom, fall) {
  var p = knockAt(index, zoom)
  return p * p * fall
}

function knockTilt(index, zoom) { return knockAt(index, zoom) * knockSide(index) * KNOCK_TILT }
function knockShrink(index, zoom) { return 1 - KNOCK_SHRINK * knockAt(index, zoom) }

// Rows the pointer must travel past the held slot before the target moves.
var DRAG_HYSTERESIS = 0.6

function dragTargetFor(dragIndex, dragOffset, rowPitch, heldTarget, count) {
  if (dragIndex < 0 || rowPitch <= 0) return -1
  var raw = dragOffset / rowPitch
  var held = heldTarget < 0 ? 0 : heldTarget - dragIndex
  var next = Math.abs(raw - held) >= DRAG_HYSTERESIS ? Math.round(raw) : held
  return Math.max(0, Math.min(count - 1, dragIndex + next))
}

// The dragged row follows the pointer; rows it has passed step aside by one pitch.
function rowShift(index, dragIndex, dragTarget, dragOffset, rowPitch) {
  if (dragIndex < 0) return 0
  if (index === dragIndex) return dragOffset
  if (dragIndex < dragTarget && index > dragIndex && index <= dragTarget) return -rowPitch
  if (dragIndex > dragTarget && index >= dragTarget && index < dragIndex) return rowPitch
  return 0
}

// Opaque blend of two colors: a Qt color inside QML, {r, g, b, a} under node.
function mix(from, to, t) {
  var r = from.r + (to.r - from.r) * t
  var g = from.g + (to.g - from.g) * t
  var b = from.b + (to.b - from.b) * t
  return typeof Qt !== "undefined" ? Qt.rgba(r, g, b, 1) : { r: r, g: g, b: b, a: 1 }
}

// ---- first run

// Home plus four well-known cities spread round the clock from it. Rank breaks ties.
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

// Minutes east of home, wrapped to one turn of the dial.
function eastOf(offsetMinutes, homeMinutes) {
  var d = (offsetMinutes - homeMinutes) % DAY_MINUTES
  return d < 0 ? d + DAY_MINUTES : d
}

function dialDistance(a, b) {
  var d = Math.abs(a - b) % DAY_MINUTES
  return Math.min(d, DAY_MINUTES - d)
}

// Best-ranked candidates first, each at least `gap` minutes from home and from every pick.
function pickSeedAt(home, offsets, count, gap) {
  var homeOff = offsets[home.id]
  var homeLabel = String(home.label || "").toLowerCase()
  var picked = []
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
  return picked
}

// `offsets` maps zone id to minutes east of UTC and must include home's.
function pickSeedZones(home, offsets, count) {
  var n = count === undefined ? 4 : count
  if (!home || !home.id || !offsets) return []
  if (offsets[home.id] === undefined || offsets[home.id] === null) return []

  // Relax the gap where half the world sits within a couple of hours of home.
  var picked = []
  var gaps = [180, 120, 60]
  for (var g = 0; g < gaps.length; g++) {
    picked = pickSeedAt(home, offsets, n, gaps[g])
    if (picked.length >= n) break
  }

  picked.sort(function (a, b) { return a.east - b.east })

  var out = []
  for (var m = 0; m < picked.length; m++)
    out.push({ label: picked[m].label, id: picked[m].id })
  return out
}

function seedZones(home, offsets, count) {
  if (!home || !home.id) return []
  var out = [{ label: home.label, id: home.id }]
  var rest = pickSeedZones(home, offsets, count)
  for (var i = 0; i < rest.length; i++) out.push(rest[i])
  return out
}

if (typeof module !== "undefined") {
  module.exports = {
    DEFAULT_ZONES: DEFAULT_ZONES,
    NO_CHIP: NO_CHIP,
    SEED_CANDIDATES: SEED_CANDIDATES,
    parseZones: parseZones,
    probeCommand: probeCommand,
    parseOffset: parseOffset,
    parseProbe: parseProbe,
    localZoneFromProbe: localZoneFromProbe,
    utcOffsetLabel: utcOffsetLabel,
    relativeOffsetLabel: relativeOffsetLabel,
    zoneParts: zoneParts,
    localParts: localParts,
    formatTime: formatTime,
    meridiem: meridiem,
    formatClock: formatClock,
    daylightStart: daylightStart,
    daylightEnd: daylightEnd,
    rows: rows,
    indexOfZone: indexOfZone,
    indexOfZoneKey: indexOfZoneKey,
    labelForZoneId: labelForZoneId,
    homeCityAfterTap: homeCityAfterTap,
    serializeZones: serializeZones,
    addZone: addZone,
    removeZoneAt: removeZoneAt,
    moveZone: moveZone,
    removeZone: removeZone,
    zoneOptions: zoneOptions,
    searchZones: searchZones,
    moveSelection: moveSelection,
    mergeCities: mergeCities,
    factsKey: factsKey,
    geocodeUrl: geocodeUrl,
    pickGeocode: pickGeocode,
    zoneTabCoords: zoneTabCoords,
    forecastUrl: forecastUrl,
    parseForecast: parseForecast,
    weatherStale: weatherStale,
    mergeFacts: mergeFacts,
    resolveUnits: resolveUnits,
    usesTwentyFourHour: usesTwentyFourHour,
    resolveHour24: resolveHour24,
    formatTemp: formatTemp,
    tempLabel: tempLabel,
    weatherKind: weatherKind,
    scrubDeltaMinutes: scrubDeltaMinutes,
    formatMinuteOfDay: formatMinuteOfDay,
    formatScrubDelta: formatScrubDelta,
    arrowBox: arrowBox,
    arrowCovered: arrowCovered,
    chipAfterTap: chipAfterTap,
    chipAfterRelease: chipAfterRelease,
    knockAt: knockAt,
    knockX: knockX,
    knockY: knockY,
    knockTilt: knockTilt,
    knockShrink: knockShrink,
    dragTargetFor: dragTargetFor,
    rowShift: rowShift,
    mix: mix,
    seedCandidateZones: seedCandidateZones,
    pickSeedZones: pickSeedZones,
    seedZones: seedZones
  }
}
