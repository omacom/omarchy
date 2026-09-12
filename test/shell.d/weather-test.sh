#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
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

// Execute the editor's actual QML functions and signal handlers. A queued
// response or debounce can arrive between any two user actions.
function qmlBody(marker, closingIndent, offset = 0) {
  const markerStart = panelSource.indexOf(marker, offset)
  if (markerStart < 0) fail('weather editor handler is missing: ' + marker)
  const start = panelSource.indexOf('{', markerStart)
  const end = panelSource.indexOf('\n' + closingIndent + '}', start)
  if (end <= start) fail('weather editor handler does not close: ' + marker)
  return panelSource.slice(start + 1, end)
}

const textChangedLine = panelSource.split('onTextChanged:')[1].split('\n')[0].trim()
const textChangedBody = textChangedLine === '{' ? qmlBody('onTextChanged:', '              ') : textChangedLine
const responseBody = qmlBody('      onStreamFinished:', '      ', panelSource.indexOf('    id: geocodeProc'))

function weatherEditor() {
  const queued = []
  const requests = []
  const editor = {
    Model: weather,
    editingLocation: true,
    savingLocation: false,
    savingLocationQueryStarted: false,
    locationSuggestions: [],
    suggestionIndex: 0,
    geocodePendingQuery: '',
    geocodeActiveQuery: '',
    locationField: { text: '' },
    keyCatcher: null,
    Qt: { callLater: fn => queued.push(fn) },
    geocodeDebounce: {
      running: false,
      restart() { this.running = true },
      stop() { this.running = false }
    },
    persistLocation(name, latitude, longitude) { editor.saved = { name, latitude, longitude } },
    clearLocation() { editor.saved = { name: '', latitude: null, longitude: null } }
  }
  let running = false
  editor.geocodeProc = {
    command: [],
    get running() { return running },
    set running(value) {
      running = value
      if (value) requests.push(this.command.slice())
    }
  }
  editor.root = editor
  vm.createContext(editor)
  for (const name of ['requestGeocode', 'startGeocode', 'commitLocation', 'cancelEditingLocation']) {
    vm.runInContext('function ' + name + '() {' + qmlBody('  function ' + name + '(', '  ') + '\n}', editor)
  }
  editor.type = text => {
    editor.locationField.text = text
    vm.runInContext(textChangedBody, editor)
  }
  editor.respond = results => {
    editor.geocodeProc.running = false
    editor.text = JSON.stringify({ results })
    vm.runInContext(responseBody, editor)
  }
  editor.flush = () => {
    while (queued.length) queued.shift()()
  }
  editor.requests = requests
  return editor
}

const london = { name: 'London', latitude: 51.50853, longitude: -0.12574 }
const paris = { name: 'Paris', latitude: 48.85341, longitude: 2.3488 }
const edited = weatherEditor()
edited.type('London')
edited.requestGeocode()
edited.respond([london])
edited.suggestionIndex = 2
edited.type('Paris')
assertDeepEqual(edited.locationSuggestions, [], 'weather clears old suggestions as soon as the query changes')
assertEqual(edited.suggestionIndex, 0, 'weather resets the selected suggestion when typing')
edited.commitLocation()
assertDeepEqual(edited.saved, { name: 'Paris', latitude: null, longitude: null }, 'weather Enter before debounce saves the typed city instead of the previous suggestion')
edited.requestGeocode()
assertEqual(edited.requests.length, 1, 'weather pending debounce cannot start a request while saving')

const delayed = weatherEditor()
delayed.type('London')
delayed.requestGeocode()
delayed.type('Pa')
delayed.requestGeocode()
assertEqual(delayed.requests.length, 1, 'weather keeps only one geocoding request in flight')
delayed.type('Paris')
delayed.respond([london])
assertDeepEqual(delayed.locationSuggestions, [], 'weather ignores an obsolete response while the next query is pending')
delayed.flush()
assertEqual(delayed.requests.length, 2, 'weather fetches the latest queued query after the old request completes')
assert(delayed.requests[1].at(-1).includes('name=Paris&'), 'weather coalesces intermediate queries into the latest city')
assertEqual(delayed.geocodeDebounce.running, false, 'weather stops the debounce when a queued request starts')
delayed.respond([paris])
delayed.commitLocation()
assertEqual(delayed.saved.name, 'Paris', 'weather accepts the current query suggestion')
assertEqual(delayed.saved.latitude, paris.latitude, 'weather preserves coordinates from the current suggestion')

for (const query of ['', 'P']) {
  const shortened = weatherEditor()
  shortened.type('London')
  shortened.requestGeocode()
  shortened.type(query)
  shortened.respond([london])
  shortened.flush()
  shortened.requestGeocode()
  assertDeepEqual(shortened.locationSuggestions, [], 'weather keeps obsolete results hidden after shortening to ' + JSON.stringify(query))
  assertEqual(shortened.requests.length, 1, 'weather does not fetch a blank or one-character queued query')
}

const cancelled = weatherEditor()
cancelled.type('London')
cancelled.requestGeocode()
cancelled.type('Paris')
cancelled.respond([london])
cancelled.cancelEditingLocation()
cancelled.flush()
assertEqual(cancelled.requests.length, 1, 'weather cancellation prevents a deferred geocoding request from starting')
assertEqual(cancelled.geocodePendingQuery, '', 'weather cancellation clears the queued query')

const reopened = weatherEditor()
reopened.type('London')
reopened.requestGeocode()
reopened.cancelEditingLocation()
reopened.editingLocation = true
reopened.type('Paris')
reopened.respond([london])
assertDeepEqual(reopened.locationSuggestions, [], 'weather reopening cannot publish the cancelled editor query')
reopened.flush()
assertEqual(reopened.requests.length, 2, 'weather reopening fetches the new editor query after an old request finishes')

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
