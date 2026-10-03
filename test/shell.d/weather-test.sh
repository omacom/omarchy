#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const weather = requireFromRoot('shell/plugins/panels/weather/Model.js')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/weather/Panel.qml', 'utf8')
const widgetSource = fs.readFileSync(root + '/shell/plugins/panels/weather/BarWidget.qml', 'utf8')

assertDeepEqual(weather.parseLocationFile('{"name": "Malibu", "latitude": 34.02577, "longitude": -118.7804}\n'), { name: 'Malibu', latitude: 34.02577, longitude: -118.7804 }, 'weather parses name plus coordinates from weather.json')
assertDeepEqual(weather.parseLocationFile('{"name": "New York"}'), { name: 'New York', latitude: null, longitude: null }, 'weather parses a name-only weather.json')
assertDeepEqual(weather.parseLocationFile('{"name": "Malibu", "latitude": 34.02577}'), { name: 'Malibu', latitude: null, longitude: null }, 'weather requires both coordinates')
assertDeepEqual(weather.parseLocationFile('not json'), { name: '', latitude: null, longitude: null }, 'weather treats an unparseable weather.json as auto-detect')
assertDeepEqual(weather.parseLocationFile(''), { name: '', latitude: null, longitude: null }, 'weather treats a missing weather.json as auto-detect')

assertDeepEqual(weather.locationCommit('  Pasadena  ', [], 0), { name: 'Pasadena', latitude: null, longitude: null }, 'weather commits typed locations before suggestions load')
assertDeepEqual(weather.locationCommit('', [], 0), { name: '', latitude: null, longitude: null }, 'weather commits an empty location as auto-detect')
assertDeepEqual(
  weather.locationCommit('mal', [{ name: 'Malibu', latitude: 34.02577, longitude: -118.7804 }], 0),
  { name: 'Malibu', latitude: 34.02577, longitude: -118.7804 },
  'weather commits the selected geocoding suggestion when available'
)

assertEqual(weather.wttrLocationQuery('Malibu', 34.02577, -118.7804), '34.02577,-118.7804', 'weather prefers coordinates for the wttr query')
assertEqual(weather.wttrLocationQuery('Malibu', '34.02577', '-118.7804'), '34.02577,-118.7804', 'weather accepts string coordinates')
assertEqual(weather.wttrLocationQuery('New York', null, null), 'New%20York', 'weather URL-encodes a name-only location')
assertEqual(weather.wttrLocationQuery('Malibu', 'nope', -118.7804), 'Malibu', 'weather ignores unparseable coordinates')
assertEqual(weather.wttrLocationQuery('', null, null), '', 'weather falls back to IP auto-detect without a location')
assertEqual(weather.wttrLocationQuery('  ', null, null), '', 'weather treats a blank location as unset')

assertDeepEqual(
  weather.parseGeocodingResults(JSON.stringify({
    results: [
      { name: 'Malibu', latitude: 34.02577, longitude: -118.7804, admin1: 'California', country: 'United States' },
      { name: 'Malibu', latitude: -7.18333, longitude: 29.65, admin1: 'Tanganyika', country: 'Democratic Republic of Congo' },
      { name: 'Broken', latitude: 1.0 },
      { name: 'Bare', latitude: 2.0, longitude: 3.0 }
    ]
  })),
  [
    { name: 'Malibu', description: 'California, United States', latitude: 34.02577, longitude: -118.7804 },
    { name: 'Malibu', description: 'Tanganyika, Democratic Republic of Congo', latitude: -7.18333, longitude: 29.65 },
    { name: 'Bare', description: '', latitude: 2.0, longitude: 3.0 }
  ],
  'weather parses geocoding suggestions and drops incomplete rows'
)
assertDeepEqual(weather.parseGeocodingResults('{}'), [], 'weather handles empty geocoding responses')
assertDeepEqual(weather.parseGeocodingResults('{'), [], 'weather handles invalid geocoding JSON')

assertEqual(weather.roundedTemp('21.6'), '22', 'weather rounds temperatures')
assertEqual(weather.roundedTemp('nope'), '', 'weather ignores invalid temperatures')
assertEqual(weather.formatTemp(72, true), '72°F', 'weather formats imperial temperatures')
assertEqual(weather.formatTemp(22, false), '22°C', 'weather formats metric temperatures')
assertEqual(weather.shouldUseImperial('', 'en_US', ''), true, 'weather falls back to US locale for imperial units')
assertEqual(weather.shouldUseImperial('', 'en_US', 'Denmark'), false, 'weather prefers reported metric country over US locale')
assertEqual(weather.shouldUseImperial('', 'da_DK', 'United States of America'), true, 'weather prefers reported imperial country over metric locale')
assertEqual(weather.shouldUseImperial('metric', 'en_US', 'United States of America'), false, 'weather metric override wins')
assertEqual(weather.shouldUseImperial('imperial', 'da_DK', 'Denmark'), true, 'weather imperial override wins')
assertEqual(weather.dayName('2026-05-25'), 'Monday', 'weather derives day names')

const openMeteo = {
  daily: {
    time: ['2026-05-25', '2026-05-26', '2026-05-27', '2026-05-28', '2026-05-29'],
    temperature_2m_max: [20.1, 21.6, 18.2, 17.9, 22.4],
    temperature_2m_min: [12.2, 13.1, 10.8, 9.2, 11.5],
    weather_code: [0, 63, 95, 3, 1]
  }
}

assertDeepEqual(
  weather.openMeteoForecastDays(openMeteo, '2026-05-25').map(day => ({
    date: day.date,
    maxtempC: day.maxtempC,
    mintempF: day.mintempF,
    code: day.openMeteoWeatherCode
  })),
  [
    { date: '2026-05-26', maxtempC: '22', mintempF: '56', code: 63 },
    { date: '2026-05-27', maxtempC: '18', mintempF: '51', code: 95 },
    { date: '2026-05-28', maxtempC: '18', mintempF: '49', code: 3 }
  ],
  'weather builds future Open-Meteo forecast days'
)

assertDeepEqual(
  weather.openMeteoCurrentCondition({ current: { temperature_2m: 21.4, apparent_temperature: 19.8, wind_speed_10m: 14.3, relative_humidity_2m: 63 } }),
  { temp_C: '21', temp_F: '71', FeelsLikeC: '20', FeelsLikeF: '68', windspeedKmph: '14', windspeedMiles: '9', humidity: '63' },
  'weather normalizes open-meteo current conditions to the wttr shape'
)
assertEqual(weather.openMeteoCurrentCondition({}), null, 'weather returns no current conditions without open-meteo data')
assertEqual(weather.openMeteoCurrentCondition({ current: {} }), null, 'weather requires a current temperature')

const wttr = {
  weather: [
    { date: '2026-05-25', maxtempC: '20', mintempC: '12' },
    { date: '2026-05-26', maxtempC: '22', mintempC: '13' }
  ]
}
assertEqual(weather.buildForecastDays(wttr, {}, '2026-05-25')[0].date, '2026-05-26', 'weather falls back to wttr forecast')
assertEqual(weather.bareTempForDay({ maxtempC: '22', mintempC: '13', maxtempF: '72', mintempF: '55' }, 'max', false), '22°', 'weather formats forecast metric highs')
assertEqual(weather.bareTempForDay({ maxtempC: '22', mintempC: '13', maxtempF: '72', mintempF: '55' }, 'min', true), '55°', 'weather formats forecast imperial lows')

assert(weather.dayIcon({ openMeteoWeatherCode: 95 }).length > 0, 'weather maps Open-Meteo weather icons')
assertEqual(weather.currentIcon({ openMeteoWeatherCode: 0, isDay: 1 }, ''), weather.iconForOpenMeteoCode(0), 'weather uses the current Open-Meteo icon with current values')
assertEqual(weather.currentIcon({ openMeteoWeatherCode: 0, isDay: 0 }, ''), weather.iconForCode(113, true), 'weather uses the nighttime Open-Meteo icon after sunset')
assert(weather.iconForOpenMeteoCode(45, true) !== weather.iconForOpenMeteoCode(45, false), 'weather distinguishes nighttime fog from daytime fog')
assertEqual(weather.provisionalCurrentIcon({ weatherCode: 113 }, ''), weather.iconForCode(113, false), 'weather uses wttr to fill an empty initial icon')
assertEqual(weather.provisionalCurrentIcon({ weatherCode: 113 }, 'night'), 'night', 'weather refresh preserves a resolved day-night icon')
// The bar identifies a panel by the widget in its slot, so the nested panel
// has to present the host widget rather than itself — otherwise the
// open-panel dot never lights and Tab cannot leave the panel.
assert(
  panelSource.includes('owner: root.barIdentity'),
  'weather panel gives the bar its host widget as popout identity'
)
assert(
  panelSource.includes('switchPanelFrom(root.barIdentity, direction)'),
  'weather panel switches panels as its host widget'
)
assert(
  widgetSource.includes('target.hostWidget = root'),
  'weather widget injects itself as the panel host'
)
assert(
  widgetSource.includes('readonly property bool popoutSwitchClosing:') && widgetSource.includes('function closeForPopoutSwitch()'),
  'weather widget forwards the popout-switch handshake'
)
assert(
  /Qt\.callLater\(function\(\) \{\s*\n\s*if \(root\.opened\) setCenterHoverRevealSuppressed\(true\)/.test(panelSource),
  'weather claims the shared hover-reveal flag after the popout handoff, so the panel taking over wins'
)

assert(
  panelSource.includes('text: root.label || "—"'),
  'weather hero and bar use the same resolved icon'
)
assert(
  panelSource.includes('onReturnRequested: root.startEditingLocation()'),
  'weather focuses city input when Return is pressed'
)
assert(
  panelSource.split('root.controller.show()\n    locationFile.reload()\n    root.refresh()').length === 3,
  'weather reloads external location changes whenever either open path runs'
)
assert(!weather.weatherResponseCompletesSave(true, 'wttr'), 'weather keeps the spinner through a non-authoritative pinned-location response')
assert(weather.weatherResponseCompletesSave(true, 'open-meteo'), 'weather completes a pinned-location save with Open-Meteo data')
assert(weather.weatherResponseCompletesSave(false, 'wttr'), 'weather completes a name-only location save with wttr data')
assertEqual(
  weather.dayIcon({ hourly: [{ time: '900', weatherCode: 113 }, { time: '1200', weatherCode: 389 }, { time: '1800', weatherCode: 116 }] }),
  weather.iconForCode(389, false),
  'weather picks hourly forecast icon nearest noon'
)

// ---- Sky scenes behind the popup.
assertDeepEqual(
  weather.resolveSkyScene({ openMeteoWeatherCode: 0, isDay: 1, windspeedKmph: '8' }, ''),
  { scene: 'sun', night: false, level: 1, hail: false, windy: false },
  'weather resolves a clear day to the sun scene'
)
assertEqual(weather.resolveSkyScene({ openMeteoWeatherCode: 0, isDay: 0 }, '').night, true, 'weather resolves night from the Open-Meteo day flag')
assertEqual(weather.resolveSkyScene({ openMeteoWeatherCode: 2, isDay: 1 }, '').scene, 'partly', 'weather resolves partly cloudy codes')
assertEqual(weather.resolveSkyScene({ openMeteoWeatherCode: 3, isDay: 1 }, '').scene, 'clouds', 'weather resolves overcast')
assertEqual(weather.resolveSkyScene({ openMeteoWeatherCode: 45, isDay: 1 }, '').scene, 'fog', 'weather resolves fog')
assertDeepEqual(
  [51, 61, 63, 65, 80, 82].map(code => weather.resolveSkyScene({ openMeteoWeatherCode: code, isDay: 1 }, '')).map(r => r.scene + r.level),
  ['rain0', 'rain0', 'rain1', 'rain2', 'rain0', 'rain2'],
  'weather grades drizzle, rain and showers into three rain intensities'
)
assertDeepEqual(
  [71, 73, 75, 77, 85, 86].map(code => weather.resolveSkyScene({ openMeteoWeatherCode: code, isDay: 1 }, '')).map(r => r.scene + r.level),
  ['snow0', 'snow1', 'snow2', 'snow0', 'snow0', 'snow2'],
  'weather grades snow into three intensities'
)
assertDeepEqual(
  [56, 66, 67].map(code => weather.resolveSkyScene({ openMeteoWeatherCode: code, isDay: 1 }, '')).map(r => r.scene + r.level),
  ['sleet0', 'sleet1', 'sleet2'],
  'weather resolves freezing drizzle and rain to sleet'
)
assertDeepEqual(
  weather.resolveSkyScene({ openMeteoWeatherCode: 96, isDay: 0 }, ''),
  { scene: 'storm', night: true, level: 2, hail: true, windy: false },
  'weather resolves a hail thunderstorm'
)
assertEqual(weather.resolveSkyScene({ openMeteoWeatherCode: 95, isDay: 1 }, '').hail, false, 'weather keeps plain thunderstorms hail-free')
assertEqual(weather.resolveSkyScene({ openMeteoWeatherCode: 1, isDay: 1, windspeedKmph: '31' }, '').windy, true, 'weather flags wind from 30 km/h')
assertEqual(weather.resolveSkyScene({ openMeteoWeatherCode: 1, isDay: 1, windspeedKmph: '29' }, '').windy, false, 'weather stays calm below 30 km/h')
assertDeepEqual(
  weather.resolveSkyScene({ weatherCode: 389 }, weather.iconForCode(389, false)),
  { scene: 'storm', night: false, level: 1, hail: false, windy: false },
  'weather falls back to the bar glyph without an Open-Meteo code'
)
assertEqual(weather.resolveSkyScene(null, weather.iconForCode(113, true)).night, true, 'weather infers night from a night glyph without a day flag')
assertEqual(weather.resolveSkyScene(null, '').scene, 'off', 'weather draws nothing without any condition')
assertEqual(weather.skyMode('sun', true), 'moon', 'weather draws the moon for a clear night')
assertEqual(weather.skyMode('partly', true), 'partly-night', 'weather draws the night variant of partly cloudy')
assertEqual(weather.skyMode('rain', true), 'rain', 'weather keeps precipitation scenes under one name at night')
assertDeepEqual(
  Object.keys(weather.WMO).map(name => weather.WMO[name]).sort((x, y) => x - y),
  Object.keys(weather.SKY_BY_WMO).map(Number).sort((x, y) => x - y),
  'weather has a sky entry for exactly the named WMO codes'
)
assert(
  Object.keys(weather.SKY_BY_WMO).every(code => weather.SKY_SCENES.indexOf(weather.SKY_BY_WMO[code].scene) >= 0),
  'weather maps every WMO code to a drawable scene'
)
assertEqual(weather.resolveSkyScene({ openMeteoWeatherCode: 42, isDay: 1 }, '').scene, 'clouds', 'weather treats an unlisted WMO code as clouds')
assertEqual(weather.resolveSkyScene(null, weather.iconForCode(182, false)).scene, 'sleet', 'weather maps the sleet glyph to sleet')

// Evaluate the panel's actual bindings so changing its source selection back
// to wttr cannot pass just because the resolver works in isolation.
const vm = require('vm')
function panelBinding(name, context) {
  const expression = panelSource.match(new RegExp('readonly property \\w+ ' + name + ': (.+)'))[1]
  return vm.runInNewContext(expression, { Model: weather, ...context })
}
const wmoCurrent = weather.openMeteoCurrentCondition({ current: {
  temperature_2m: 12, weather_code: 96, is_day: 0, wind_speed_10m: 35
} })
const wttrCurrent = { weatherCode: 389, windspeedKmph: '8' }
for (const hasConfiguredCoordinates of [false, true]) {
  const context = { hasConfiguredCoordinates, openMeteoCurrent: wmoCurrent,
    report: { current_condition: [wttrCurrent] }, label: weather.iconForCode(389, false) }
  context.current = panelBinding('current', context)
  assertDeepEqual(panelBinding('fxResolved', context),
    { scene: 'storm', night: true, level: 2, hail: true, windy: true },
    'weather panel uses WMO sky data with configured coordinates ' + hasConfiguredCoordinates)
}
assertDeepEqual(panelBinding('fxResolved', {
  openMeteoCurrent: null, current: wttrCurrent, label: weather.iconForCode(389, false)
}), { scene: 'storm', night: false, level: 1, hail: false, windy: false },
'weather panel retains glyph fallback without Open-Meteo')

// Exercise the actual strip painter with a recording context. Geometry must
// survive a new drawing context, while colours remain live and storage bounded.
const sky = vm.createContext({
  cell: 2, layerCache: [], inkSoft: '#aabbcc',
  noiseTable: Array.from({ length: 4096 }, (_, n) => ((n * 7919) % 4096) / 4096),
  ditherThresholds: [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5].map(b => (b + 0.5) / 16)
})
for (const name of ['hashT', 'vnoise', 'fbm', 'layerRuns', 'buildLayerRuns', 'paintLayer']) {
  const rest = panelSource.slice(panelSource.indexOf('        function ' + name + '('))
  const firstLine = rest.split('\n')[0]
  const source = firstLine.endsWith('}') ? firstLine : rest.slice(0, rest.indexOf('\n        }') + 10)
  vm.runInContext(source, sky)
}
let noiseCalls = 0
const fbm = sky.fbm
sky.fbm = (...args) => { noiseCalls++; return fbm(...args) }
function drawStrip(spec, cols = 180, rows = 50) {
  const output = []
  const ctx = { clearRect() {}, fillRect(...rect) { output.push([...rect, this.fillStyle, this.globalAlpha]) } }
  sky.paintLayer(ctx, spec, cols, rows, 2, cols * 2, rows * 2)
  return output
}
const cloud = { kind: 'cloud', nsx: 51, nsy: 30, topOnly: true, dens: 0.09,
  lit: '#eeeeee', body: '#bbbbbb', shade: '#777777', alpha: 0.5, speed: 4.2 }
const coldCloud = drawStrip(cloud)
assert(coldCloud.length > 0 && noiseCalls > 0, 'weather builds drawable cloud geometry on first paint')
noiseCalls = 0
assertDeepEqual(drawStrip(cloud), coldCloud, 'weather replays identical cloud runs into a new context')
assertEqual(noiseCalls, 0, 'weather reopening does not regenerate cloud noise')
const flashCloud = drawStrip({ ...cloud, lit: '#ffffff', body: '#dddddd', alpha: 0.7, speed: 9 })
assertEqual(noiseCalls, 0, 'weather storm flash, opacity and wind reuse cloud geometry')
assert(JSON.stringify(flashCloud) !== JSON.stringify(coldCloud), 'weather cached cloud geometry uses the new palette')
drawStrip({ ...cloud, dens: 0.03 })
assert(noiseCalls > 0, 'weather rebuilds geometry when cloud density changes')
noiseCalls = 0
drawStrip(cloud, 200)
assert(noiseCalls > 0, 'weather rebuilds geometry when strip dimensions change')
const fog = { kind: 'fog', nsx: 66, nsy: 24, seed: 0 }
const fogOther = { kind: 'fog', nsx: 42, nsy: 16.5, seed: 3.7 }
const coldFog = drawStrip(fog)
drawStrip(fogOther)
noiseCalls = 0
assertDeepEqual(drawStrip(fog), coldFog, 'weather replays identical fog runs into a new context')
drawStrip(fogOther)
assertEqual(noiseCalls, 0, 'weather retains both fog geometries across reopens')
sky.inkSoft = '#112233'
const recoloredFog = drawStrip(fog)
assert(recoloredFog.length > 0 && recoloredFog.every(run => run[4] === '#112233'), 'weather fog repaints in the current palette')
assertEqual(noiseCalls, 0, 'weather recoloring fog does not regenerate noise')
assertEqual(sky.layerCache.length, 2, 'weather bounds strip storage after scene and size changes')

const manifest = JSON.parse(fs.readFileSync(root + '/shell/plugins/panels/weather/manifest.json', 'utf8'))
const fxSetting = (manifest.barWidget.schema || []).find(entry => entry.key === 'fx')
assert(fxSetting && fxSetting.type === 'boolean' && fxSetting.defaultValue === true, 'weather manifest declares the fx toggle, on by default')
assert(panelSource.includes('fxEnabled ? Model.skyMode('), 'weather panel draws nothing when the fx toggle is off')
assert(panelSource.includes('visible: root.fxMode !== "off"'), 'weather panel hides the sky layer when the scene is off')
assert(panelSource.includes('running: skyFx.visible && root.opened'), 'weather panel only animates the sky while the popup is open')
assert(!panelSource.includes('onTextKey'), 'weather panel adds no key bindings for the sky')
const skySource = panelSource.slice(panelSource.indexOf('id: skyFx'), panelSource.indexOf('id: weatherScroll'))
assertDeepEqual(
  [...new Set((skySource.match(/#[0-9a-fA-F]{3,8}\b/g) || []).map(hex => hex.toLowerCase()))],
  ['#ffffff'],
  'weather sky layer takes its colours from the theme apart from white'
)
JS

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

weather_location() {
  HOME="$test_tmp" "$ROOT/bin/omarchy-weather-location" "$@"
}

weather_location --set "Malibu" "34.02577,-118.7804"
[[ $(jq -c . "$test_tmp/.local/state/omarchy/settings/weather.json") == '{"name":"Malibu","latitude":34.02577,"longitude":-118.7804}' ]] || fail "weather location stores name and coordinates as JSON"
pass "weather location stores name and coordinates as JSON"

[[ $(weather_location) == "Malibu" ]] || fail "weather location returns the stored name"
pass "weather location returns the stored name"

weather_location --set "New York"
[[ $(jq -c . "$test_tmp/.local/state/omarchy/settings/weather.json") == '{"name":"New York"}' ]] || fail "weather location stores a bare name as JSON"
[[ $(weather_location) == "New York" ]] || fail "weather location returns a bare stored name"
pass "weather location stores and returns a bare name"

if weather_location --set "bad" "not,coords" 2>/dev/null; then
  fail "weather location rejects malformed coordinates"
fi
pass "weather location rejects malformed coordinates"

weather_location --clear
[[ ! -e "$test_tmp/.local/state/omarchy/settings/weather.json" ]] || fail "weather location clear removes the state file"
pass "weather location clear removes the state file"
