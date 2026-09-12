// weather.json holds {"name": ..., "latitude": ..., "longitude": ...} (see
// omarchy-weather-location, which owns the format). Missing, blank, or
// unparseable means the location is auto-detected from the IP address.
function parseLocationFile(raw) {
  var unset = { name: "", latitude: null, longitude: null }
  try {
    var data = JSON.parse(String(raw || ""))
    if (!data || typeof data !== "object") return unset

    var latitude = parseFloat(data.latitude)
    var longitude = parseFloat(data.longitude)
    var hasCoordinates = !isNaN(latitude) && !isNaN(longitude)
    return {
      name: typeof data.name === "string" ? data.name.replace(/^\s+|\s+$/g, "") : "",
      latitude: hasCoordinates ? latitude : null,
      longitude: hasCoordinates ? longitude : null
    }
  } catch (e) {
    return unset
  }
}

// wttr.in path segment for a configured location: exact coordinates when
// both are present, the URL-encoded name as a fallback (hand-edited
// weather.loc files may only carry a name), empty for IP auto-detect.
function wttrLocationQuery(location, latitude, longitude) {
  var lat = parseFloat(String(latitude))
  var lon = parseFloat(String(longitude))
  if (!isNaN(lat) && !isNaN(lon)) return lat + "," + lon

  var name = String(location || "").replace(/^\s+|\s+$/g, "")
  return name === "" ? "" : encodeURIComponent(name)
}

// Open-Meteo geocoding response → suggestion rows for the location picker.
function parseGeocodingResults(raw) {
  try {
    var data = JSON.parse(String(raw || "{}"))
    var results = data.results
    if (!results || !results.length) return []

    var out = []
    for (var i = 0; i < results.length; i++) {
      var r = results[i]
      if (!r || !r.name || r.latitude === undefined || r.longitude === undefined) continue
      var region = [r.admin1, r.country].filter(function(part) { return !!part }).join(", ")
      out.push({
        name: String(r.name),
        description: region,
        latitude: r.latitude,
        longitude: r.longitude
      })
    }
    return out
  } catch (e) {
    return []
  }
}

function locationCommit(text, suggestions, selectedIndex) {
  var name = String(text || "").replace(/^\s+|\s+$/g, "")
  if (name === "") return { name: "", latitude: null, longitude: null }

  var choices = suggestions || []
  var index = Math.max(0, Math.min(parseInt(selectedIndex, 10) || 0, choices.length - 1))
  var suggestion = choices[index]
  if (suggestion) return suggestion

  return { name: name, latitude: null, longitude: null }
}

function isFutureForecastDate(dateString, todayString) {
  if (!dateString) return false
  return String(dateString).slice(0, 10) > String(todayString || "")
}

function roundedTemp(value) {
  if (value === undefined || value === null || value === "") return ""
  var n = parseFloat(String(value))
  return isNaN(n) ? "" : String(Math.round(n))
}

function celsiusToFahrenheit(value) {
  if (value === undefined || value === null || value === "") return ""
  var n = parseFloat(String(value))
  return isNaN(n) ? "" : (n * 9 / 5) + 32
}

function formatTemp(value, useImperial) {
  if (value === undefined || value === null || value === "") return ""
  return value + "°" + (useImperial ? "F" : "C")
}

function normalizedUnit(value) {
  return String(value || "").replace(/^\s+|\s+$/g, "").toLowerCase()
}

function localeUsesImperial(localeName) {
  var name = String(localeName || "").replace(".", "_")
  return /^en[_-]US($|[_.-])/.test(name) || /^en[_-]LR($|[_.-])/.test(name) || /^my($|[_.-])/.test(name)
}

function countryUsesImperial(countryName) {
  var country = String(countryName || "")
    .replace(/^\s+|\s+$/g, "")
    .replace(/[._-]+/g, " ")
    .toLowerCase()
  if (!country) return null
  if (country === "us" || country === "usa" || country === "united states" || country === "united states of america") return true
  if (country === "liberia" || country === "myanmar" || country === "burma") return true
  return false
}

function shouldUseImperial(unitOverride, localeName, countryName) {
  var unit = normalizedUnit(unitOverride)
  if (unit === "imperial") return true
  if (unit === "metric") return false

  var countryPreference = countryUsesImperial(countryName)
  if (countryPreference !== null) return countryPreference

  return localeUsesImperial(localeName)
}

function dayName(dateString, formatter) {
  if (!dateString) return ""
  var d = new Date(dateString + "T12:00:00")
  if (isNaN(d.getTime())) return ""
  if (formatter) return formatter(d)
  return ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"][d.getDay()]
}

function openMeteoForecastDays(dailyForecastReport, todayString) {
  var daily = dailyForecastReport && dailyForecastReport.daily ? dailyForecastReport.daily : null
  if (!daily || !daily.time) return []

  var result = []
  for (var i = 0; i < daily.time.length && result.length < 3; ++i) {
    var date = daily.time[i]
    if (!isFutureForecastDate(date, todayString)) continue

    var maxC = daily.temperature_2m_max ? daily.temperature_2m_max[i] : ""
    var minC = daily.temperature_2m_min ? daily.temperature_2m_min[i] : ""
    result.push({
      date: date,
      maxtempC: roundedTemp(maxC),
      mintempC: roundedTemp(minC),
      maxtempF: roundedTemp(celsiusToFahrenheit(maxC)),
      mintempF: roundedTemp(celsiusToFahrenheit(minC)),
      openMeteoWeatherCode: daily.weather_code ? daily.weather_code[i] : null
    })
  }
  return result
}

// Open-Meteo bundles current conditions with the daily forecast request and
// answers far faster than wttr.in. Normalize them to wttr's
// current_condition shape so the panel can use either source
// interchangeably. Open-Meteo reports metric (°C, km/h).
function openMeteoCurrentCondition(dailyForecastReport) {
  var current = dailyForecastReport && dailyForecastReport.current ? dailyForecastReport.current : null
  if (!current || current.temperature_2m === undefined || current.temperature_2m === null) return null
  return {
    temp_C: roundedTemp(current.temperature_2m),
    temp_F: roundedTemp(celsiusToFahrenheit(current.temperature_2m)),
    FeelsLikeC: roundedTemp(current.apparent_temperature),
    FeelsLikeF: roundedTemp(celsiusToFahrenheit(current.apparent_temperature)),
    windspeedKmph: roundedTemp(current.wind_speed_10m),
    windspeedMiles: roundedTemp(current.wind_speed_10m * 0.621371),
    humidity: roundedTemp(current.relative_humidity_2m),
    openMeteoWeatherCode: current.weather_code,
    isDay: current.is_day
  }
}

function currentIcon(current, fallback) {
  if (!current) return fallback || ""
  if (current.openMeteoWeatherCode !== undefined && current.openMeteoWeatherCode !== null)
    return iconForOpenMeteoCode(current.openMeteoWeatherCode, Number(current.isDay) === 0)
  if (current.weatherCode !== undefined && current.weatherCode !== null)
    return iconForCode(current.weatherCode, false)
  return fallback || ""
}

// wttr.in has no day/night flag. Use its icon only to fill an empty initial
// state, never to replace a day/night-aware icon resolved by Open-Meteo.
function provisionalCurrentIcon(current, resolvedIcon) {
  return resolvedIcon || currentIcon(current, "")
}

function weatherResponseCompletesSave(hasConfiguredCoordinates, source) {
  return hasConfiguredCoordinates ? source === "open-meteo" : source === "wttr"
}

function wttrNextForecastDays(report, todayString) {
  var days = report && report.weather ? report.weather : []
  var result = []
  for (var i = 0; i < days.length && result.length < 3; ++i) {
    if (isFutureForecastDate(days[i].date, todayString)) result.push(days[i])
  }
  return result
}

function buildForecastDays(report, dailyForecastReport, todayString) {
  var days = openMeteoForecastDays(dailyForecastReport, todayString)
  return days.length > 0 ? days : wttrNextForecastDays(report, todayString)
}

function bareTempForDay(day, kind, useImperial) {
  if (!day) return ""
  var v = useImperial
    ? (kind === "max" ? day.maxtempF : day.mintempF)
    : (kind === "max" ? day.maxtempC : day.mintempC)
  if (v === undefined || v === null || v === "") return ""
  return v + "°"
}

function dayIcon(day) {
  if (!day) return ""
  if (day.openMeteoWeatherCode !== undefined && day.openMeteoWeatherCode !== null)
    return iconForOpenMeteoCode(day.openMeteoWeatherCode)
  if (!day.hourly || day.hourly.length === 0) return ""

  var best = day.hourly[0]
  var bestDist = 9999
  for (var i = 0; i < day.hourly.length; ++i) {
    var t = parseInt(String(day.hourly[i].time || "0"), 10)
    var dist = Math.abs(t - 1200)
    if (dist < bestDist) {
      bestDist = dist
      best = day.hourly[i]
    }
  }
  return iconForCode(best.weatherCode, false)
}

function iconForOpenMeteoCode(code, night) {
  var c = parseInt(String(code || "0"), 10)
  if (c === 0) return iconForCode(113, night)
  if (c === 1 || c === 2) return iconForCode(116, night)
  if (c === 3) return iconForCode(119, night)
  if (c === 45 || c === 48) return iconForCode(143, night)
  if (c === 51 || c === 53 || c === 55 || c === 56 || c === 57 || c === 61) return iconForCode(266, night)
  if (c === 63 || c === 65 || c === 66 || c === 67 || c === 80 || c === 81 || c === 82) return iconForCode(308, night)
  if (c === 71 || c === 73 || c === 75 || c === 77 || c === 85 || c === 86) return iconForCode(338, night)
  if (c === 95 || c === 96 || c === 99) return iconForCode(389, night)
  return iconForCode(119, night)
}

function iconForCode(code, night) {
  var c = parseInt(String(code || "0"), 10)
  switch (c) {
    case 113: return night ? "" : ""
    case 116: return night ? "" : ""
    case 119: case 122: return ""
    case 143: case 248: case 260: return night ? "\ue346" : "\ue313"
    case 176: case 263: case 353: return night ? "" : ""
    case 179: case 227: case 230: case 323: case 326: case 368: return night ? "" : ""
    case 182: case 185: case 281: case 284: case 311: case 314:
    case 317: case 320: case 350: case 362: case 365: case 374: case 377: return ""
    case 200: case 386: case 389: case 392: case 395: return ""
    case 266: case 293: case 296: case 299: case 302: case 305: case 308: case 356: case 359: return ""
    case 329: case 332: case 335: case 338: case 371: return ""
    default: return ""
  }
}

// ---- Rain tables: MET Norway amounts + Open-Meteo probabilities ----
//
// Slots are pure data for the expandable day tables. MET Norway carries
// rain amounts, temperatures, and symbol codes but no probability of
// precipitation outside the Nordics; Open-Meteo hourly
// precipitation_probability fills that column. MET instants are UTC;
// slot boundaries are local wall time, derived from the system time zone,
// so midnight and DST transitions fall out of the local Date getters.
// Any value without data stays null and formats as a dash.
var MET_USER_AGENT = "omarchy-weather/1.0 https://github.com/omacom/omarchy"
var MET_FETCH_MIN_INTERVAL_MS = 30 * 60 * 1000
var MET_CACHE_SUBDIR = "weather"
var MET_API_URL = "https://api.met.no/weatherapi/locationforecast/2.0/complete"
var TWO_HOUR_SLOT_COUNT = 12
var MISSING_VALUE = "–"

function pad2(value) {
  var n = parseInt(value, 10)
  if (isNaN(n)) return "00"
  return (n < 10 ? "0" : "") + n
}

function round1(value) {
  if (value === null || value === undefined) return null
  var n = parseFloat(String(value))
  return isNaN(n) ? null : Math.round(n * 10) / 10
}

// Coordinates for MET Norway: at most 4 decimals. Null when unparseable.
function roundCoord(value) {
  var n = parseFloat(String(value))
  if (isNaN(n)) return null
  return Math.round(n * 10000) / 10000
}

function metUrl(lat, lon) {
  var la = roundCoord(lat)
  var lo = roundCoord(lon)
  if (la === null || lo === null) return ""
  return MET_API_URL + "?lat=" + la + "&lon=" + lo
}

// Coordinates shared by the Open-Meteo and MET Norway fetches: saved
// coordinates when present, else the area wttr.in reported for auto-detect.
// Pure so Panel.qml delegates to it (and tests drive the real rule).
function forecastCoords(configuredLocationState, sourceReport, fallbackArea) {
  var lat = parseFloat(String(configuredLocationState ? configuredLocationState.latitude : null))
  var lon = parseFloat(String(configuredLocationState ? configuredLocationState.longitude : null))
  if (isNaN(lat) || isNaN(lon)) {
    var area = sourceReport && sourceReport.nearest_area && sourceReport.nearest_area[0] ? sourceReport.nearest_area[0] : fallbackArea
    if (!area) return null
    lat = parseFloat(String(area.latitude || ""))
    lon = parseFloat(String(area.longitude || ""))
  }
  if (isNaN(lat) || isNaN(lon)) return null
  return [lat, lon]
}

function floorUtcHour(ms) {
  return Math.floor(ms / 3600000) * 3600000
}

function localDateOf(ms) {
  var d = new Date(ms)
  return d.getFullYear() + "-" + pad2(d.getMonth() + 1) + "-" + pad2(d.getDate())
}

function localHourOf(ms) {
  return new Date(ms).getHours()
}

function localHourKey(ms) {
  return localDateOf(ms) + "T" + pad2(localHourOf(ms))
}

function localDayLabel(ms) {
  return pad2(new Date(ms).getHours())
}

// UTC instant of a local wall hour on a local date. Parsing without a zone
// keeps it in the system time zone, so DST transitions resolve correctly.
function localWallMs(dateString, hour) {
  var day = String(dateString || "").slice(0, 10)
  var h = parseInt(hour, 10)
  if (!/^\d{4}-\d{2}-\d{2}$/.test(day) || isNaN(h) || h < 0 || h > 24) return NaN
  if (h === 24) {
    var next = shiftDateString(day, 1)
    return next === "" ? NaN : localWallMs(next, 0)
  }
  return new Date(day + "T" + pad2(h) + ":00:00").getTime()
}

function shiftDateString(day, deltaDays) {
  var base = new Date(day + "T12:00:00").getTime()
  if (isNaN(base)) return ""
  return localDateOf(base + deltaDays * 86400000)
}

// MET Locationforecast timeseries → UTC-hour lookups. next_1_hours carries
// only precipitation_amount; instant carries air_temperature on every entry
// (kept separately so quarter-start temperatures outlive hourly coverage).
function indexMetTimeseries(timeseries) {
  var hourly = {}
  var sixHour = {}
  var instant = {}
  var list = timeseries && timeseries.length ? timeseries : []
  for (var i = 0; i < list.length; i++) {
    var entry = list[i] || {}
    var ms = Date.parse(entry.time)
    if (isNaN(ms)) continue
    var data = entry.data || {}
    var details = data.instant && data.instant.details ? data.instant.details : null
    var temp = details ? details.air_temperature : null
    if (temp === undefined) temp = null
    if (temp !== null && !isNaN(parseFloat(String(temp)))) instant[ms] = parseFloat(String(temp))
    if (data.next_1_hours) {
      var one = data.next_1_hours.details || {}
      var onePrecip = one.precipitation_amount === undefined ? null : one.precipitation_amount
      hourly[ms] = {
        tempC: instant[ms] !== undefined ? instant[ms] : null,
        precipMm: onePrecip,
        symbol: data.next_1_hours.summary ? data.next_1_hours.summary.symbol_code || null : null
      }
    }
    if (data.next_6_hours) {
      var six = data.next_6_hours.details || {}
      sixHour[ms] = {
        precipMm: six.precipitation_amount === undefined ? null : six.precipitation_amount,
        symbol: data.next_6_hours.summary ? data.next_6_hours.summary.symbol_code || null : null,
        tminC: six.air_temperature_min === undefined ? null : six.air_temperature_min,
        tmaxC: six.air_temperature_max === undefined ? null : six.air_temperature_max
      }
    }
  }
  return { hourly: hourly, sixHour: sixHour, instant: instant }
}

// Open-Meteo hourly precipitation_probability → local "YYYY-MM-DDTHH" map.
// Hourly times already arrive in local wall time (timezone=auto).
function indexPrecipitationProbability(hourly) {
  var index = {}
  if (!hourly || !hourly.time || !hourly.precipitation_probability) return index
  for (var i = 0; i < hourly.time.length; i++) {
    var key = String(hourly.time[i] || "").slice(0, 13)
    if (!/^\d{4}-\d{2}-\d{2}T\d{2}$/.test(key)) continue
    var p = hourly.precipitation_probability[i]
    if (p === null || p === undefined || p === "") index[key] = null
    else index[key] = isNaN(parseFloat(String(p))) ? null : parseFloat(String(p))
  }
  return index
}

function chanceForHours(probIndex, hoursMs) {
  var best = null
  for (var i = 0; i < hoursMs.length; i++) {
    var p = probIndex[localHourKey(hoursMs[i])]
    if (p === null || p === undefined) continue
    if (best === null || p > best) best = p
  }
  return best
}

// Wetter hour wins; the first hour wins ties and beats missing data.
function pickWetterSymbol(candidates) {
  var best = null
  var bestPrecip = -1
  for (var i = 0; i < candidates.length; i++) {
    var c = candidates[i] || {}
    if (!c.symbol) continue
    var p = (c.precipMm === null || c.precipMm === undefined) ? -1 : parseFloat(String(c.precipMm))
    if (isNaN(p)) p = -1
    if (best === null || p > bestPrecip) {
      best = c
      bestPrecip = p
    }
  }
  return best ? best.symbol : null
}

// MET symbol_code (e.g. partlycloudy_night) onto the widget's glyphs via the
// existing wttr.in code mapping. Unknown codes fall back to the cloudy glyph,
// matching iconForCode's default.
var MET_SYMBOL_CODES = {
  clearsky: 113, fair: 116, partlycloudy: 116, cloudy: 119, fog: 143,
  lightrainshowers: 263, rainshowers: 308, heavyrainshowers: 359,
  lightrainshowersandthunder: 200, rainshowersandthunder: 389, heavyrainshowersandthunder: 389,
  lightrain: 266, rain: 308, heavyrain: 359,
  lightrainandthunder: 200, rainandthunder: 389, heavyrainandthunder: 389,
  lightsleet: 311, sleet: 320, heavysleet: 377,
  lightsleetshowers: 362, sleetshowers: 365, heavysleetshowers: 374,
  lightsnow: 323, snow: 326, heavysnow: 338,
  lightsnowshowers: 326, snowshowers: 368, heavysnowshowers: 338,
  lightsnowandthunder: 392, snowandthunder: 395, heavysnowandthunder: 395,
  lightfog: 143
}

function iconForMetSymbol(symbolCode) {
  var raw = String(symbolCode || "")
  if (raw === "") return ""
  var night = /_night$/.test(raw)
  var base = raw.replace(/_(day|night|polartwilight)$/, "")
  var code = MET_SYMBOL_CODES[base]
  if (code === undefined) code = 119
  return iconForCode(code, night)
}

function tempForHour(met, ms) {
  if (met && met.instant && met.instant[ms] !== undefined) return met.instant[ms]
  if (met && met.hourly && met.hourly[ms]) return met.hourly[ms].tempC
  return null
}

// Next 24 elapsed hours as 2-hour slots from the current hour. Labels are
// local HH-HH; aggregation is over exact UTC hours so midnight and DST need
// no special cases.
function buildTwoHourSlots(metIndex, probIndex, nowMs, count) {
  var met = metIndex || { hourly: {}, sixHour: {}, instant: {} }
  met.hourly = met.hourly || {}
  met.sixHour = met.sixHour || {}
  met.instant = met.instant || {}
  var probs = probIndex || {}
  var n = (count === undefined || count === null) ? TWO_HOUR_SLOT_COUNT : Math.max(0, parseInt(count, 10) || 0)
  var start = floorUtcHour(nowMs)
  if (isNaN(start)) return []
  var slots = []
  for (var i = 0; i < n; i++) {
    var h0 = start + i * 2 * 3600000
    var h1 = h0 + 3600000
    var e0 = met.hourly[h0] || null
    var e1 = met.hourly[h1] || null
    var rain = null
    if (e0 && e0.precipMm !== null && e0.precipMm !== undefined) rain = parseFloat(String(e0.precipMm))
    if (e1 && e1.precipMm !== null && e1.precipMm !== undefined) {
      var second = parseFloat(String(e1.precipMm))
      rain = (rain === null || isNaN(rain) ? 0 : rain) + second
    }
    if (rain !== null && isNaN(rain)) rain = null
    var symbol = pickWetterSymbol([
      e0 ? { precipMm: e0.precipMm, symbol: e0.symbol } : null,
      e1 ? { precipMm: e1.precipMm, symbol: e1.symbol } : null
    ])
    slots.push({
      startMs: h0,
      endMs: h0 + 2 * 3600000,
      label: localDayLabel(h0) + "-" + localDayLabel(h0 + 2 * 3600000),
      tempC: tempForHour(met, h0),
      rainMm: round1(rain),
      chance: chanceForHours(probs, [h0, h1]),
      symbol: symbol,
      icon: symbol ? iconForMetSymbol(symbol) : ""
    })
  }
  return slots
}

// A local calendar day as 00-06/06-12/12-18/18-24 slots. Rain sums hourly
// values where they fully cover the quarter, else falls back to the
// next_6_hours amount at the quarter start. DST-short/long quarters simply
// contain fewer/more UTC hours.
function buildSixHourSlots(metIndex, probIndex, dateString) {
  var day = String(dateString || "").slice(0, 10)
  if (!/^\d{4}-\d{2}-\d{2}$/.test(day)) return []
  var met = metIndex || { hourly: {}, sixHour: {}, instant: {} }
  met.hourly = met.hourly || {}
  met.sixHour = met.sixHour || {}
  met.instant = met.instant || {}
  var probs = probIndex || {}
  var slots = []
  for (var q = 0; q < 4; q++) {
    var qStart = localWallMs(day, q * 6)
    var qEnd = localWallMs(day, q * 6 + 6)
    if (isNaN(qStart) || isNaN(qEnd)) continue
    var hours = []
    for (var h = qStart; h < qEnd; h += 3600000) hours.push(h)
    var rain = null
    var fullCover = hours.length > 0
    var sum = 0
    for (var k = 0; k < hours.length; k++) {
      var e = met.hourly[hours[k]]
      if (!e || e.precipMm === null || e.precipMm === undefined || isNaN(parseFloat(String(e.precipMm)))) {
        fullCover = false
        break
      }
      sum += parseFloat(String(e.precipMm))
    }
    var fallbackSix = null
    if (fullCover) {
      rain = sum
    } else {
      fallbackSix = met.sixHour[qStart] || null
      if (!fallbackSix) {
        for (var m = 0; m < hours.length; m++) {
          if (met.sixHour[hours[m]]) {
            fallbackSix = met.sixHour[hours[m]]
            break
          }
        }
      }
      rain = fallbackSix ? fallbackSix.precipMm : null
      if (rain !== null && rain !== undefined && isNaN(parseFloat(String(rain)))) rain = null
    }
    var cands = []
    for (var c = 0; c < hours.length; c++) {
      var he = met.hourly[hours[c]]
      if (he) cands.push({ precipMm: he.precipMm, symbol: he.symbol })
    }
    var symbol = pickWetterSymbol(cands)
    if (!symbol && fallbackSix) symbol = fallbackSix.symbol
    slots.push({
      startMs: qStart,
      endMs: qEnd,
      label: pad2(q * 6) + "-" + pad2(q * 6 + 6),
      tempC: tempForHour(met, qStart),
      rainMm: round1(rain),
      chance: chanceForHours(probs, hours),
      symbol: symbol,
      icon: symbol ? iconForMetSymbol(symbol) : ""
    })
  }
  return slots
}

// Total rain over displayed slots; null when every slot is missing.
function dayRainTotal(slots) {
  var total = null
  var list = slots || []
  for (var i = 0; i < list.length; i++) {
    var r = list[i] ? list[i].rainMm : null
    if (r === null || r === undefined || isNaN(parseFloat(String(r)))) continue
    total = (total === null ? 0 : total) + parseFloat(String(r))
  }
  return round1(total)
}

function formatSlotTemp(celsius, useImperial) {
  if (celsius === null || celsius === undefined || celsius === "") return MISSING_VALUE
  var n = parseFloat(String(celsius))
  if (isNaN(n)) return MISSING_VALUE
  var v = useImperial ? (n * 9 / 5 + 32) : n
  return String(Math.round(v)) + "°"
}

function formatRain(mm) {
  var r = round1(mm)
  return r === null ? MISSING_VALUE : r.toFixed(1)
}

function formatChance(p) {
  if (p === null || p === undefined || p === "") return MISSING_VALUE
  var n = parseFloat(String(p))
  return isNaN(n) ? MISSING_VALUE : String(Math.round(n)) + "%"
}

function formatDayRain(mm) {
  var r = round1(mm)
  return r === null ? MISSING_VALUE : r.toFixed(1) + " mm"
}

// Day rows: today plus up to three following days, so the next-24-hours
// 2-hour table has a home and later days expand to 6-hour quarters.
function openMeteoDayRows(dailyForecastReport, todayString) {
  var daily = dailyForecastReport && dailyForecastReport.daily ? dailyForecastReport.daily : null
  if (!daily || !daily.time) return []
  var today = String(todayString || "").slice(0, 10)
  var rows = []
  for (var i = 0; i < daily.time.length && rows.length < 4; ++i) {
    var date = String(daily.time[i] || "").slice(0, 10)
    if (date < today) continue
    var maxC = daily.temperature_2m_max ? daily.temperature_2m_max[i] : ""
    var minC = daily.temperature_2m_min ? daily.temperature_2m_min[i] : ""
    rows.push({
      date: date,
      isToday: date === today,
      maxtempC: roundedTemp(maxC),
      mintempC: roundedTemp(minC),
      maxtempF: roundedTemp(celsiusToFahrenheit(maxC)),
      mintempF: roundedTemp(celsiusToFahrenheit(minC)),
      openMeteoWeatherCode: daily.weather_code ? daily.weather_code[i] : null
    })
  }
  return rows
}

if (typeof module !== "undefined") {
  module.exports = {
    parseLocationFile: parseLocationFile,
    wttrLocationQuery: wttrLocationQuery,
    parseGeocodingResults: parseGeocodingResults,
    locationCommit: locationCommit,
    isFutureForecastDate: isFutureForecastDate,
    roundedTemp: roundedTemp,
    celsiusToFahrenheit: celsiusToFahrenheit,
    formatTemp: formatTemp,
    normalizedUnit: normalizedUnit,
    localeUsesImperial: localeUsesImperial,
    countryUsesImperial: countryUsesImperial,
    shouldUseImperial: shouldUseImperial,
    dayName: dayName,
    openMeteoForecastDays: openMeteoForecastDays,
    openMeteoCurrentCondition: openMeteoCurrentCondition,
    currentIcon: currentIcon,
    provisionalCurrentIcon: provisionalCurrentIcon,
    weatherResponseCompletesSave: weatherResponseCompletesSave,
    wttrNextForecastDays: wttrNextForecastDays,
    buildForecastDays: buildForecastDays,
    bareTempForDay: bareTempForDay,
    dayIcon: dayIcon,
    iconForOpenMeteoCode: iconForOpenMeteoCode,
    iconForCode: iconForCode,
    MET_USER_AGENT: MET_USER_AGENT,
    MET_FETCH_MIN_INTERVAL_MS: MET_FETCH_MIN_INTERVAL_MS,
    MET_CACHE_SUBDIR: MET_CACHE_SUBDIR,
    MET_API_URL: MET_API_URL,
    TWO_HOUR_SLOT_COUNT: TWO_HOUR_SLOT_COUNT,
    MISSING_VALUE: MISSING_VALUE,
    pad2: pad2,
    roundCoord: roundCoord,
    metUrl: metUrl,
    forecastCoords: forecastCoords,
    floorUtcHour: floorUtcHour,
    localDateOf: localDateOf,
    localHourOf: localHourOf,
    localHourKey: localHourKey,
    localWallMs: localWallMs,
    shiftDateString: shiftDateString,
    indexMetTimeseries: indexMetTimeseries,
    indexPrecipitationProbability: indexPrecipitationProbability,
    chanceForHours: chanceForHours,
    pickWetterSymbol: pickWetterSymbol,
    iconForMetSymbol: iconForMetSymbol,
    buildTwoHourSlots: buildTwoHourSlots,
    buildSixHourSlots: buildSixHourSlots,
    dayRainTotal: dayRainTotal,
    formatSlotTemp: formatSlotTemp,
    formatRain: formatRain,
    formatChance: formatChance,
    formatDayRain: formatDayRain,
    openMeteoDayRows: openMeteoDayRows
  }
}
