// QML has no Intl, so each zone's UTC offset comes from a `date` probe and the
// clocks tick locally against it.

var DEFAULT_ZONES = "Los Angeles|America/Los_Angeles, Paris|Europe/Paris, Tokyo|Asia/Tokyo"

var WEEKDAYS = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
var MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

// Display words. QML passes `words` built from the shell's catalog (`t`, and
// `tn` for counted strings), its number writer (`fmt`, so digits and decimal
// separators follow the language) and format locale (`am`, `pm`,
// `date(parts)`); without it, as under the Node tests, everything reads in
// English.
var ENGLISH_WORDS = {
  t: function(key, english) { return english },
  tn: function(key, count, english) { return count === 1 ? english.one : english.other },
  fmt: function(value, decimals) { return decimals === undefined ? String(value) : Number(value).toFixed(decimals) },
  am: "AM",
  pm: "PM",
  date: function(parts) {
    return WEEKDAYS[parts.weekday].slice(0, 3) + " " + MONTHS[parts.month] + " " + parts.day
  }
}

function word(words, name) {
  return words && words[name] !== undefined && words[name] !== null ? words[name] : ENGLISH_WORDS[name]
}

// Fills a catalog string's %1.
function fill(text, value) {
  return String(text).replace("%1", value)
}

// A string's ASCII digits in the language's own ("14:05" is "۱۴:۰۵" in
// Persian), for numbers assembled here rather than by Qt.
function digits(text, words) {
  var fmt = word(words, "fmt")
  return String(text).replace(/[0-9]/g, function(digit) { return fmt(Number(digit)) })
}

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

// ---- the stored list

function isCoordinate(value, limit) {
  if (value === undefined || value === null || value === "") return false
  var n = Number(value)
  return isFinite(n) && Math.abs(n) <= limit
}

// The place facts a city may carry beyond its name and zone, copied onto `into`.
// Coordinates come as a pair or not at all.
function withPlace(into, place) {
  if (place && isCoordinate(place.lat, 90) && isCoordinate(place.lon, 180)) {
    into.lat = Number(place.lat)
    into.lon = Number(place.lon)
  }
  var region = place && place.region ? String(place.region).replace(/\s+/g, " ").trim() : ""
  if (region !== "") into.region = region
  return into
}

// The `cities` setting, [{ name, zone, lat, lon, region, people }], as rows
// of { label, id, ... }. Before the first write it is unset and the older
// "Label|Zone, ..." string in `zones` is read instead.
function parseCities(cities, legacyZones) {
  if (!Array.isArray(cities) || cities.length === 0) return parseZones(legacyZones)
  var out = []
  for (var i = 0; i < cities.length; i++) {
    var c = cities[i]
    if (!c || typeof c !== "object") continue
    var id = String(c.zone || "").trim()
    if (id === "" || !ZONE_ID.test(id)) continue
    var label = cleanLabel(c.name)
    var entry = withPlace({ label: label === "" ? labelForZoneId(id) : label, id: id }, c)
    var people = Array.isArray(c.people) ? cleanPeople(c.people) : []
    if (people.length > 0) entry.people = people
    out.push(entry)
  }
  return out
}

function serializeCities(zones) {
  var out = []
  for (var i = 0; i < zones.length; i++) {
    var z = zones[i]
    if (!z || !z.id) continue
    var entry = withPlace({ name: z.label || labelForZoneId(z.id), zone: z.id }, z)
    if (z.people && z.people.length > 0) entry.people = z.people.slice()
    out.push(entry)
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
function utcOffsetLabel(minutes, words) {
  if (minutes === undefined || minutes === null) return ""
  var total = Number(minutes)
  if (!isFinite(total)) return ""
  total = Math.round(total)
  if (total === 0) return "UTC"
  var abs = Math.abs(total)
  var hours = Math.floor(abs / 60)
  var mins = abs % 60
  return "UTC" + (total < 0 ? "-" : "+") + digits(hours
       + (mins === 0 ? "" : ":" + (mins < 10 ? "0" : "") + mins), words)
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

function dayLabel(delta, words) {
  var t = word(words, "t")
  var tn = word(words, "tn")
  var fmt = word(words, "fmt")
  if (delta === 0) return ""
  if (delta === 1) return t("elsewhen.tomorrow", "Tomorrow")
  if (delta === -1) return t("elsewhen.yesterday", "Yesterday")
  return delta > 0 ? fill(tn("elsewhen.daysAhead", delta, { one: "+%1 day", other: "+%1 days" }), fmt(delta))
                   : fill(tn("elsewhen.daysBehind", -delta, { one: "-%1 day", other: "-%1 days" }), fmt(-delta))
}

function pad2(n) {
  return (n < 10 ? "0" : "") + n
}

function formatTime(parts, hour24, words) {
  if (hour24) return digits(pad2(parts.hour) + ":" + pad2(parts.minute), words)
  var h = parts.hour % 12
  if (h === 0) h = 12
  return digits(h + ":" + pad2(parts.minute), words)
}

function meridiem(parts, words) {
  return parts.hour < 12 ? word(words, "am") : word(words, "pm")
}

// "14:05" or "2:05 PM" at a zone offset; "" before the offset is known.
function formatClock(nowMs, offsetMinutes, hour24, words) {
  if (offsetMinutes === undefined || offsetMinutes === null) return ""
  var parts = zoneParts(nowMs, offsetMinutes)
  return formatTime(parts, hour24, words) + (hour24 ? "" : " " + meridiem(parts, words))
}

function formatDate(parts, words) {
  return word(words, "date")(parts)
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
function relativeOffsetLabel(zoneOffsetMinutes, localOffsetMinutes, words) {
  var diff = Number(zoneOffsetMinutes) - Number(localOffsetMinutes)
  if (diff === 0) return ""
  var hours = diff / 60
  var text = word(words, "fmt")(Math.round(hours * 10) / 10)
  var t = word(words, "t")
  return (diff > 0 ? "+" : "") + fill(t("elsewhen.hoursShort", "%1h"), text)
}

// Everything a row needs; `ready` is false until the zone has been probed.
function rowFor(zone, probe, nowMs, localOffsetMinutes, hour24, words) {
  var info = probe ? probe[zone.id] : null
  var people = zone.people || []
  if (!info) return { label: zone.label, id: zone.id, people: people, ready: false }
  var parts = zoneParts(nowMs, info.offsetMinutes)
  var here = localParts(nowMs)
  var delta = dayDelta(parts, here)
  return {
    label: zone.label,
    id: zone.id,
    people: people,
    ready: true,
    abbr: info.abbr,
    offsetMinutes: info.offsetMinutes,
    time: formatTime(parts, hour24, words),
    hour: parts.hour,
    meridiem: hour24 ? "" : meridiem(parts, words),
    date: formatDate(parts, words),
    dayLabel: dayLabel(delta, words),
    daytime: isDaytime(parts),
    phase: phaseFor(parts),
    lit: inDaylight(dayProgress(parts)),
    phaseLabel: phaseLabel(phaseFor(parts)),
    progress: dayProgress(parts),
    relative: relativeOffsetLabel(info.offsetMinutes, localOffsetMinutes, words)
  }
}

function rows(zones, probe, nowMs, localOffsetMinutes, hour24, words) {
  var out = []
  for (var i = 0; i < zones.length; i++)
    out.push(rowFor(zones[i], probe, nowMs, localOffsetMinutes, hour24, words))
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

// Where "here" is: the stored `here` place while this machine is still on its
// zone, else the older `homeCity` name, else the zone's own city. `chosen` is
// false only for that last guess. Null until the machine's zone is known.
function resolveHere(here, legacyCity, localZone) {
  var zone = String(localZone || "")
  if (zone === "") return null
  if (here && typeof here === "object" && String(here.zone || "") === zone) {
    var name = cleanLabel(here.name)
    if (name !== "") return withPlace({ label: name, id: zone, chosen: true }, here)
  }
  var legacy = cleanLabel(legacyCity)
  if (legacy !== "") return { label: legacy, id: zone, chosen: true }
  return { label: labelForZoneId(zone), id: zone, chosen: false }
}

// Picking `pick` as here: { here, zones, zoneChange }. `here` is the new
// setting, null to go back to the zone's own city.
//
// On this machine's zone, the row that stood for the old here is renamed to the
// new one, keeping its place in the list and its people. A city on another zone
// moves the machine's clock there - `zoneChange` is that zone - and leaves the
// list alone: home stays on it while you are away from it.
function hereAfterPick(zones, current, pick, localZone) {
  var local = String(localZone || "")
  var zone = pick ? String(pick.id || "") : ""
  if (local === "" || zone === "" || !ZONE_ID.test(zone)) return null
  var name = cleanLabel(pick.label)
  if (name === "") return null
  var place = withPlace({}, pick)
  var bare = name === labelForZoneId(zone) && place.lat === undefined
  var here = bare ? null : withPlace({ name: name, zone: zone }, pick)
  if (zone !== local) return { here: here, zones: zones, zoneChange: zone }

  var out = zones
  var at = current ? indexOfZone(zones, current.label, zone) : -1
  if (at >= 0 && (name === current.label || !hasEntry(zones, zone, name))) {
    var row = { label: name, id: zone }
    if (zones[at].people) row.people = zones[at].people
    out = zones.slice()
    out[at] = withPlace(row, pick)
  }
  return { here: here, zones: out, zoneChange: "" }
}

// argv that moves this machine's clock to `zone` through the passwordless
// `timedatectl set-timezone` rule the timezone menu uses (etc/sudoers.d/omarchy-tzupdate),
// then tells the bar clock. `-n`: a missing rule fails rather than waiting on a
// password nobody can type. The zone is an argument, never script text.
function timezoneCommand(zone) {
  return ["bash", "-c", 'sudo -n timedatectl set-timezone "$1" && omarchy-shell -q omarchy.clock refresh', "bash", String(zone)]
}

// ---- people

// GitHub's own rule for a username.
var GITHUB_HANDLE = /^[A-Za-z0-9](?:[A-Za-z0-9-]{0,38})$/
var MAX_PEOPLE = 12

// "Emir, @sarahdev" -> ["Emir", "@sarahdev"]: trimmed, without repeats, and a
// handle GitHub could not have is kept as a plain name.
function parsePeople(text) {
  var parts = String(text === undefined || text === null ? "" : text).split(",")
  var out = []
  var seen = {}
  for (var i = 0; i < parts.length && out.length < MAX_PEOPLE; i++) {
    var name = cleanLabel(parts[i])
    if (name.charAt(0) === "@") {
      var handle = name.slice(1).trim()
      name = GITHUB_HANDLE.test(handle) ? "@" + handle : handle
    }
    if (name === "" || seen[name.toLowerCase()]) continue
    seen[name.toLowerCase()] = true
    out.push(name)
  }
  return out
}

function cleanPeople(list) {
  return parsePeople((list || []).map(function(p) { return String(p).replace(/,/g, " ") }).join(","))
}

function peopleText(list) {
  return (list || []).join(", ")
}

// "@SarahDev" -> "sarahdev"; "" for a plain name.
function personHandle(person) {
  var text = String(person || "")
  if (text.charAt(0) !== "@" || !GITHUB_HANDLE.test(text.slice(1))) return ""
  return text.slice(1).toLowerCase()
}

// A handle reads as the profile's name once it is known, and as the bare handle before.
function personName(person, profiles) {
  var handle = personHandle(person)
  if (handle === "") return String(person || "")
  var profile = profiles ? profiles[handle] : null
  if (profile && profile.name) return profile.name
  return profile && profile.login ? profile.login : String(person).slice(1)
}

// The first letter, whole: a surrogate pair is one letter.
function initialOf(name) {
  var text = String(name || "").trim()
  if (text === "") return ""
  var code = text.charCodeAt(0)
  var first = code >= 0xd800 && code < 0xdc00 ? text.slice(0, 2) : text.charAt(0)
  return first.toUpperCase()
}

// Every handle on the list, once.
function handlesIn(zones) {
  var out = []
  for (var i = 0; i < (zones || []).length; i++) {
    var people = zones[i].people || []
    for (var j = 0; j < people.length; j++) {
      var handle = personHandle(people[j])
      if (handle !== "" && out.indexOf(handle) < 0) out.push(handle)
    }
  }
  return out
}

// The row at `index` with these people, or the same array when nothing changes.
function setPeopleAt(zones, index, people) {
  if (index < 0 || index >= zones.length) return zones
  var next = cleanPeople(people)
  if (peopleText(next) === peopleText(zones[index].people)) return zones
  var row = Object.assign({}, zones[index])
  if (next.length > 0) row.people = next
  else delete row.people
  var out = zones.slice()
  out[index] = row
  return out
}

// argv that refreshes each handle's cached profile when missing or a week old,
// and its avatar along with it or whenever the avatar is missing, then prints
// one JSON line per handle it has a profile for. Handles are arguments, never
// script text, and are checked before they get here.
//
// The API's answer is not trusted to name a URL: the avatar is fetched from
// GitHub's own avatar host by the account's numeric id, and curl may speak
// nothing but HTTPS, redirects included. Downloads land in fresh temporary
// files in a private directory and are renamed into place, so nothing planted
// at a predictable name is written through. Every monitor has its own panel,
// so each handle is refreshed under a lock, and checked again once it is held.
function profilesCommand(handles) {
  var script = [
    'dir="${XDG_CACHE_HOME:-$HOME/.cache}/omarchy/elsewhen/people"',
    'mkdir -p "$dir" && chmod 700 "$dir" || exit 0',
    'fetch() {',
    '  local tmp',
    '  tmp=$(mktemp "$dir/.fetch.XXXXXX") || return 1',
    '  if curl -fsSL --max-time 8 --proto =https --proto-redir =https --globoff -o "$tmp" --url "$1"; then',
    '    mv -f "$tmp" "$2"',
    '  else',
    '    rm -f "$tmp"',
    '    return 1',
    '  fi',
    '}',
    'for h; do',
    '  json="$dir/$h.json" img="$dir/$h.avatar"',
    '  (',
    '    flock -w 30 9 || exit 0',
    '    fresh=1',
    '    if [[ ! -s $json || -n $(find "$json" -mmin +10080) ]]; then',
    '      fetch "https://api.github.com/users/$h" "$json" && fresh=0',
    '    fi',
    '    if [[ -s $json ]] && { (( fresh == 0 )) || [[ ! -s $img ]]; }; then',
    '      id=$(jq -r \'.id // empty | tostring\' "$json")',
    '      [[ $id =~ ^[0-9]+$ ]] && fetch "https://avatars.githubusercontent.com/u/$id?s=96" "$img"',
    '    fi',
    '  ) 9>>"$dir/.$h.lock"',
    '  [[ -s $img ]] || img=""',
    '  [[ -s $json ]] && jq -c --arg h "$h" --arg img "$img" \'{handle: $h, login: (.login // $h | tostring), name: (.name // "" | tostring), avatar: $img}\' "$json"',
    'done',
    'true'
  ].join("\n")
  var valid = (handles || []).filter(function(h) { return GITHUB_HANDLE.test(String(h)) })
  return ["bash", "-c", script, "bash"].concat(valid.map(function(h) { return String(h).toLowerCase() }))
}

// One JSON line per handle -> { handle: { login, name, avatar } }.
function parseProfiles(text) {
  var out = {}
  var lines = String(text || "").split("\n")
  for (var i = 0; i < lines.length; i++) {
    var p
    try { p = JSON.parse(lines[i]) } catch (e) { continue }
    if (!p || !GITHUB_HANDLE.test(String(p.handle || ""))) continue
    out[String(p.handle).toLowerCase()] = {
      login: String(p.login || p.handle),
      name: cleanLabel(p.name),
      avatar: String(p.avatar || "")
    }
  }
  return out
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

// "Springfield" in "Missouri, US" -> "Springfield (Missouri)": a second town
// of a name already in use, named so the two can be told apart. The name
// alone when there is no region to add.
function regionalName(name, region) {
  var first = cleanLabel(String(region || "").split(",")[0])
  return first === "" ? name : name + " (" + first + ")"
}

// Returns the same array when nothing changes, so callers can skip the write.
// `place` may carry the city's coordinates and region from a place search. A
// second town with a name and zone already on the list is a different place
// when the coordinates say so, and is named with its region to tell them apart:
// a row is known by its name and zone.
function addZone(zones, id, label, place) {
  var zoneId = String(id || "").trim()
  if (zoneId === "" || !ZONE_ID.test(zoneId)) return zones
  var name = cleanLabel(label)
  if (name === "") name = labelForZoneId(zoneId)
  var row = withPlace({ label: name, id: zoneId }, place)
  var at = indexOfZone(zones, name, zoneId)
  if (at >= 0) {
    if (row.lat === undefined || zones[at].lat === undefined || nearPlace(zones[at], row)) return zones
    row.label = regionalName(name, row.region)
    if (row.label === name || hasEntry(zones, zoneId, row.label)) return zones
  }
  var out = zones.slice()
  out.push(row)
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

// ---- place search
// The tz database names one city per zone; the geocoder knows the towns in
// between, and tells us which zone each one keeps.

var PLACE_QUERY_MIN = 3

// The query a place search runs for, or "" when it is too short to be worth one.
function placeQuery(text) {
  var q = String(text || "").replace(/\s+/g, " ").trim()
  return q.length >= PLACE_QUERY_MIN ? q.toLowerCase() : ""
}

// "Florida, US": what tells Portland, Oregon from Portland, Maine.
function placeRegion(result) {
  var parts = []
  var admin = cleanLabel(result.admin1)
  if (admin !== "" && admin !== cleanLabel(result.name)) parts.push(admin)
  var country = cleanLabel(result.country_code || result.country)
  if (country !== "") parts.push(country.toUpperCase().length === 2 ? country.toUpperCase() : country)
  return parts.join(", ")
}

// The geocoder's results, or null when the answer is not one. Only a real
// array, and only as many entries as were asked for: the answer comes off the
// network, and a `{"length": 1e300}` would otherwise hold the shell's UI thread
// in a loop.
var GEOCODE_COUNT = 10

function geocodeResults(text) {
  var payload
  try { payload = JSON.parse(text) } catch (e) { return null }
  var results = payload && payload.results
  if (results === undefined || results === null) return []
  return Array.isArray(results) ? results.slice(0, GEOCODE_COUNT) : []
}

// Geocoder answer -> picker options carrying the place, [] when it failed.
function placeOptions(text) {
  var results = geocodeResults(text)
  if (!results) return []
  var out = []
  var seen = {}
  for (var i = 0; i < results.length; i++) {
    var r = results[i] || {}
    var zone = String(r.timezone || "")
    var name = cleanLabel(r.name)
    if (name === "" || !ZONE_ID.test(zone) || zone.indexOf("/") < 0) continue
    var option = withPlace({ value: zone, label: name }, { lat: r.latitude, lon: r.longitude, region: placeRegion(r) })
    if (option.lat === undefined) continue
    var key = name + "\u0000" + (option.region || "") + "\u0000" + zone
    if (seen[key]) continue
    seen[key] = true
    out.push(option)
  }
  return out
}

// Within about a kilometre: the same place, whichever list it came from.
function nearPlace(a, b) {
  return a.lat !== undefined && b.lat !== undefined
    && Math.abs(a.lat - b.lat) < 0.01 && Math.abs(a.lon - b.lon) < 0.01
}

function sameName(option, label, zone) {
  return option.value === zone && String(option.label).toLowerCase() === String(label).toLowerCase()
}

// The offline matches first, so three letters and Return still pick what they
// did; then the geocoder's places. The first place an offline city's name and
// zone match lends it a region and coordinates rather than being listed twice;
// any other town of that name and zone - Springfield, Illinois and Springfield,
// Missouri both keep Central time - is a place of its own and listed as one.
// A place already on the list is left out, known by where it is - or, for a
// row with no coordinates, by its name.
function mergePlaces(offline, places, existing, limit) {
  var out = (offline || []).slice()
  var offlineCount = out.length
  for (var i = 0; i < (places || []).length; i++) {
    var p = places[i]
    var tracked = false
    for (var k = 0; existing && k < existing.length && !tracked; k++) {
      var row = existing[k]
      tracked = row.id === p.value && (nearPlace(row, p)
        || (row.lat === undefined && String(row.label).toLowerCase() === p.label.toLowerCase()))
    }
    if (tracked) continue
    var twin = -1
    for (var j = 0; j < offlineCount && twin < 0; j++) if (sameName(out[j], p.label, p.value)) twin = j
    if (twin >= 0 && out[twin].lat === undefined) out[twin] = withPlace(Object.assign({}, out[twin]), p)
    else if (twin < 0 || !nearPlace(out[twin], p)) out.push(p)
  }
  return limit === undefined ? out : out.slice(0, limit)
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
  return "https://geocoding-api.open-meteo.com/v1/search?count=" + GEOCODE_COUNT + "&language=en&format=json&name="
    + encodeURIComponent(label)
}

// { place, answered }: a place in the row's own zone beats the top result, and
// `answered` is false when the request itself failed.
function pickGeocode(text, zone) {
  var results = geocodeResults(text)
  if (!results) return { place: null, answered: false }
  var best = null
  for (var i = 0; i < results.length && !best; i++) if (results[i] && results[i].timezone === zone) best = results[i]
  if (!best && results.length > 0 && results[0] && typeof results[0] === "object") best = results[0]
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
// `points`, when given, are the coordinates each reading was asked for; a
// reading remembers them, so a city that moves does not keep another's weather.
function parseForecast(text, keys, nowMs, points) {
  var payload
  try { payload = JSON.parse(text) } catch (e) { return {} }
  if (!Array.isArray(payload)) payload = [payload]
  var out = {}
  for (var i = 0; i < keys.length && i < payload.length; i++) {
    var current = (payload[i] && payload[i].current) || {}
    if (current.temperature_2m === undefined || current.temperature_2m === null) continue
    out[keys[i]] = { c: Math.round(current.temperature_2m * 10) / 10, w: current.weather_code, at: nowMs }
    if (points && points[i]) { out[keys[i]].lat = points[i].lat; out[keys[i]].lon = points[i].lon }
  }
  return out
}

// Twenty minutes old, or read for somewhere other than `coords`.
function weatherStale(entry, nowMs, coords) {
  if (!entry || nowMs - entry.at >= WEATHER_TTL_MS) return true
  return !!coords && entry.lat !== undefined && !nearPlace(entry, coords)
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

function formatTemp(celsius, units, words) {
  if (celsius === undefined || celsius === null) return ""
  var fmt = word(words, "fmt")
  if (String(units).toUpperCase() === "C") return fmt(Math.round(celsius)) + "°C"
  return fmt(Math.round(celsius * 9 / 5 + 32)) + "°F"
}

function tempLabel(facts, units, words) {
  return facts ? formatTemp(facts.c, units, words) : ""
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
function formatMinuteOfDay(minute, hour24, words) {
  var m = Math.round(Number(minute))
  m = ((m % DAY_MINUTES) + DAY_MINUTES) % DAY_MINUTES
  var hour = Math.floor(m / 60)
  var parts = { hour: hour, minute: m % 60 }
  return formatTime(parts, hour24, words) + (hour24 ? "" : " " + meridiem(parts, words))
}

// "+3h", "-45m", "" for now.
function formatScrubDelta(minutes, words) {
  var m = Math.round(minutes)
  if (m === 0) return ""
  var sign = m > 0 ? "+" : "-"
  var a = Math.abs(m)
  // The arrow keys can run past a day, where hours alone stop reading well.
  var d = Math.floor(a / DAY_MINUTES), h = Math.floor(a % DAY_MINUTES / 60), rem = a % 60
  var parts = []
  var t = word(words, "t")
  var fmt = word(words, "fmt")
  if (d) parts.push(fill(t("elsewhen.daysShort", "%1d"), fmt(d)))
  if (h) parts.push(fill(t("elsewhen.hoursShort", "%1h"), fmt(h)))
  if (rem) parts.push(fill(t("elsewhen.minutesShort", "%1m"), fmt(rem)))
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

// How many rows a drag of `offset` has passed, fractionally. Rows are not all
// one height - a row with people is a line taller - so each is measured by its
// own pitch in `pitches`; without them every row is `rowPitch`.
function rowsPassed(dragIndex, offset, rowPitch, pitches) {
  if (!pitches) return offset / rowPitch
  var step = offset < 0 ? -1 : 1
  var left = Math.abs(offset)
  var passed = 0
  for (var i = dragIndex + step; i >= 0 && i < pitches.length; i += step) {
    var pitch = pitches[i] > 0 ? pitches[i] : rowPitch
    if (left < pitch) return step * (passed + left / pitch)
    left -= pitch
    passed++
  }
  return step * (passed + left / rowPitch)
}

// Where the dragged row lands when it drops into `target`: the pitches of the rows it passed.
function dropOffset(dragIndex, target, rowPitch, pitches) {
  var step = target < dragIndex ? -1 : 1
  var out = 0
  for (var i = dragIndex + step; step > 0 ? i <= target : i >= target; i += step)
    out += step * (pitches && pitches[i] > 0 ? pitches[i] : rowPitch)
  return out
}

function dragTargetFor(dragIndex, dragOffset, rowPitch, heldTarget, count, pitches) {
  if (dragIndex < 0 || rowPitch <= 0) return -1
  var raw = rowsPassed(dragIndex, dragOffset, rowPitch, pitches)
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
    parseCities: parseCities,
    serializeCities: serializeCities,
    resolveHere: resolveHere,
    hereAfterPick: hereAfterPick,
    timezoneCommand: timezoneCommand,
    parsePeople: parsePeople,
    peopleText: peopleText,
    personHandle: personHandle,
    personName: personName,
    initialOf: initialOf,
    handlesIn: handlesIn,
    setPeopleAt: setPeopleAt,
    profilesCommand: profilesCommand,
    parseProfiles: parseProfiles,
    placeQuery: placeQuery,
    placeOptions: placeOptions,
    mergePlaces: mergePlaces,
    nearPlace: nearPlace,
    regionalName: regionalName,
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
    dropOffset: dropOffset,
    rowShift: rowShift,
    mix: mix,
    seedCandidateZones: seedCandidateZones,
    pickSeedZones: pickSeedZones,
    seedZones: seedZones
  }
}
