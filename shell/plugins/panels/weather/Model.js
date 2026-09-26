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

// ---- Sky scenes for the panel's animated background.
//      A scene name plus night/intensity/hail/wind modifiers, resolved from the
//      Open-Meteo WMO weather code and day flag when present, else from the
//      resolved bar glyph.
var SKY_SCENES = ["sun", "partly", "clouds", "fog", "rain", "storm", "snow", "sleet"]

var SKY_LEVEL = { LIGHT: 0, MODERATE: 1, HEAVY: 2 }
var WINDY_KMPH = 30

// WMO weather interpretation codes, as Open-Meteo reports them.
var WMO = {
  CLEAR: 0, MAINLY_CLEAR: 1, PARTLY_CLOUDY: 2, OVERCAST: 3,
  FOG: 45, RIME_FOG: 48,
  DRIZZLE_LIGHT: 51, DRIZZLE_MODERATE: 53, DRIZZLE_DENSE: 55,
  FREEZING_DRIZZLE_LIGHT: 56, FREEZING_DRIZZLE_DENSE: 57,
  RAIN_SLIGHT: 61, RAIN_MODERATE: 63, RAIN_HEAVY: 65,
  FREEZING_RAIN_LIGHT: 66, FREEZING_RAIN_HEAVY: 67,
  SNOW_SLIGHT: 71, SNOW_MODERATE: 73, SNOW_HEAVY: 75, SNOW_GRAINS: 77,
  RAIN_SHOWERS_SLIGHT: 80, RAIN_SHOWERS_MODERATE: 81, RAIN_SHOWERS_VIOLENT: 82,
  SNOW_SHOWERS_SLIGHT: 85, SNOW_SHOWERS_HEAVY: 86,
  THUNDERSTORM: 95, THUNDERSTORM_HAIL_SLIGHT: 96, THUNDERSTORM_HAIL_HEAVY: 99
}

function skyEntry(scene, level, hail) { return { scene: scene, level: level, hail: hail === true } }

var SKY_BY_WMO = {}
SKY_BY_WMO[WMO.CLEAR]                    = skyEntry("sun",    SKY_LEVEL.MODERATE)
SKY_BY_WMO[WMO.MAINLY_CLEAR]             = skyEntry("partly", SKY_LEVEL.MODERATE)
SKY_BY_WMO[WMO.PARTLY_CLOUDY]            = skyEntry("partly", SKY_LEVEL.MODERATE)
SKY_BY_WMO[WMO.OVERCAST]                 = skyEntry("clouds", SKY_LEVEL.MODERATE)
SKY_BY_WMO[WMO.FOG]                      = skyEntry("fog",    SKY_LEVEL.MODERATE)
SKY_BY_WMO[WMO.RIME_FOG]                 = skyEntry("fog",    SKY_LEVEL.MODERATE)
SKY_BY_WMO[WMO.DRIZZLE_LIGHT]            = skyEntry("rain",   SKY_LEVEL.LIGHT)
SKY_BY_WMO[WMO.DRIZZLE_MODERATE]         = skyEntry("rain",   SKY_LEVEL.LIGHT)
SKY_BY_WMO[WMO.DRIZZLE_DENSE]            = skyEntry("rain",   SKY_LEVEL.LIGHT)
SKY_BY_WMO[WMO.FREEZING_DRIZZLE_LIGHT]   = skyEntry("sleet",  SKY_LEVEL.LIGHT)
SKY_BY_WMO[WMO.FREEZING_DRIZZLE_DENSE]   = skyEntry("sleet",  SKY_LEVEL.LIGHT)
SKY_BY_WMO[WMO.RAIN_SLIGHT]              = skyEntry("rain",   SKY_LEVEL.LIGHT)
SKY_BY_WMO[WMO.RAIN_MODERATE]            = skyEntry("rain",   SKY_LEVEL.MODERATE)
SKY_BY_WMO[WMO.RAIN_HEAVY]               = skyEntry("rain",   SKY_LEVEL.HEAVY)
SKY_BY_WMO[WMO.FREEZING_RAIN_LIGHT]      = skyEntry("sleet",  SKY_LEVEL.MODERATE)
SKY_BY_WMO[WMO.FREEZING_RAIN_HEAVY]      = skyEntry("sleet",  SKY_LEVEL.HEAVY)
SKY_BY_WMO[WMO.SNOW_SLIGHT]              = skyEntry("snow",   SKY_LEVEL.LIGHT)
SKY_BY_WMO[WMO.SNOW_MODERATE]            = skyEntry("snow",   SKY_LEVEL.MODERATE)
SKY_BY_WMO[WMO.SNOW_HEAVY]               = skyEntry("snow",   SKY_LEVEL.HEAVY)
SKY_BY_WMO[WMO.SNOW_GRAINS]              = skyEntry("snow",   SKY_LEVEL.LIGHT)
SKY_BY_WMO[WMO.RAIN_SHOWERS_SLIGHT]      = skyEntry("rain",   SKY_LEVEL.LIGHT)
SKY_BY_WMO[WMO.RAIN_SHOWERS_MODERATE]    = skyEntry("rain",   SKY_LEVEL.MODERATE)
SKY_BY_WMO[WMO.RAIN_SHOWERS_VIOLENT]     = skyEntry("rain",   SKY_LEVEL.HEAVY)
SKY_BY_WMO[WMO.SNOW_SHOWERS_SLIGHT]      = skyEntry("snow",   SKY_LEVEL.LIGHT)
SKY_BY_WMO[WMO.SNOW_SHOWERS_HEAVY]       = skyEntry("snow",   SKY_LEVEL.HEAVY)
SKY_BY_WMO[WMO.THUNDERSTORM]             = skyEntry("storm",  SKY_LEVEL.MODERATE)
SKY_BY_WMO[WMO.THUNDERSTORM_HAIL_SLIGHT] = skyEntry("storm",  SKY_LEVEL.HEAVY, true)
SKY_BY_WMO[WMO.THUNDERSTORM_HAIL_HEAVY]  = skyEntry("storm",  SKY_LEVEL.HEAVY, true)

// wttr.in condition codes, one per bar glyph, for the glyph-only fallback.
var WTTR = {
  SUNNY: 113, PARTLY_CLOUDY: 116, CLOUDY: 119, MIST: 143,
  PATCHY_RAIN: 176, PATCHY_SNOW: 179, PATCHY_SLEET: 182,
  LIGHT_DRIZZLE: 266, HEAVY_SNOW: 338, THUNDERY_RAIN: 389
}
var SKY_BY_WTTR = [
  [WTTR.SUNNY, "sun"], [WTTR.PARTLY_CLOUDY, "partly"], [WTTR.CLOUDY, "clouds"],
  [WTTR.MIST, "fog"], [WTTR.PATCHY_RAIN, "rain"], [WTTR.LIGHT_DRIZZLE, "rain"],
  [WTTR.THUNDERY_RAIN, "storm"], [WTTR.PATCHY_SNOW, "snow"], [WTTR.HEAVY_SNOW, "snow"],
  [WTTR.PATCHY_SLEET, "sleet"]
]

// Scene and night flag for a bar glyph, by matching it against the glyphs
// iconForCode draws for each wttr.in code.
function skySceneForGlyph(glyph) {
  for (var n = 0; n < SKY_BY_WTTR.length; n++) {
    var day = iconForCode(SKY_BY_WTTR[n][0], false), night = iconForCode(SKY_BY_WTTR[n][0], true)
    if (glyph === day || glyph === night) return { scene: SKY_BY_WTTR[n][1], night: glyph === night && glyph !== day }
  }
  return { scene: "off", night: false }
}

function resolveSkyScene(current, glyph) {
  var windK = current ? parseFloat(current.windspeedKmph) : NaN
  var fromGlyph = skySceneForGlyph(glyph)
  var r = { scene: fromGlyph.scene, night: fromGlyph.night, level: SKY_LEVEL.MODERATE, hail: false,
            windy: isFinite(windK) && windK >= WINDY_KMPH }
  if (current && current.isDay !== undefined && current.isDay !== null) r.night = Number(current.isDay) === 0
  var code = current && current.openMeteoWeatherCode !== undefined && current.openMeteoWeatherCode !== null
           ? parseInt(String(current.openMeteoWeatherCode), 10) : NaN
  if (isNaN(code)) return r
  var entry = SKY_BY_WMO[code] || skyEntry("clouds", SKY_LEVEL.MODERATE)
  r.scene = entry.scene; r.level = entry.level; r.hail = entry.hail
  return r
}

// The scene actually drawn: the base scene with night applied.
function skyMode(base, night) {
  if (base === "sun" && night) return "moon"
  if (base === "partly" && night) return "partly-night"
  return base
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
    SKY_SCENES: SKY_SCENES,
    SKY_LEVEL: SKY_LEVEL,
    WMO: WMO,
    SKY_BY_WMO: SKY_BY_WMO,
    skySceneForGlyph: skySceneForGlyph,
    resolveSkyScene: resolveSkyScene,
    skyMode: skyMode
  }
}
