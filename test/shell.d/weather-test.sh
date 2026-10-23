#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const weather = requireFromRoot('shell/plugins/panels/weather/Model.js')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/weather/Panel.qml', 'utf8')
const widgetSource = fs.readFileSync(root + '/shell/plugins/panels/weather/BarWidget.qml', 'utf8')

const autoCoordinates = weather.locationCoordinates(weather.effectiveLocation({ name: '', latitude: null, longitude: null }, { name: 'Amsterdam', latitude: 52.37, longitude: 4.89 }), null)
assertEqual(autoCoordinates.key, '52.37,4.89', 'radar uses the effective auto-detected location')
assertEqual(weather.locationCoordinates({ latitude: 0, longitude: 0 }, null).key, '0.00,0.00', 'radar accepts zero coordinates')
assertEqual(weather.locationCoordinates({ latitude: 91, longitude: 0 }, null), null, 'radar rejects out-of-range coordinates')
assertEqual(weather.parseRadarStation('', 404), null, 'radar caches unsupported NWS points')
assertEqual(weather.parseRadarStation('', 503), undefined, 'radar can retry a temporary station failure')
assertEqual(weather.parseRadarStation('{"properties":{"radarStation":"KABX"}}', 200), 'KABX', 'radar resolves an NWS station')
assertEqual(weather.parseRadarStation('{"properties":{"radarStation":"../bad"}}', 200), undefined, 'radar retries malformed station responses')
const scans = weather.parseRadarScans('{"scans":[{"ts":"2026-10-23T00:05Z"},{"ts":"2026-10-22T23:59Z"},{"ts":"2026-10-23T00:05:00Z"},{"ts":"bad"}]}')
assertDeepEqual(scans.map(frame => frame.stamp), ['202610222359', '202610230005'], 'radar orders and deduplicates scans across UTC midnight')
const grid = weather.radarTileGrid({ latitude: 0, longitude: 179.99 }, 7.65, 480, 210, 8)
assert(grid.some(tile => tile.x === 255) && grid.some(tile => tile.x === 0), 'radar wraps tile requests across the dateline')
for (const [x, y] of [[0, 0], [479.99, 209.99], [240, 105]]) {
  assert(grid.some(tile => tile.left <= x && tile.left + 256 * Math.pow(2, -0.35) > x && tile.top <= y && tile.top + 256 * Math.pow(2, -0.35) > y), 'radar covers the viewport at fractional zoom')
}

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

const unset = weather.parseLocationFile('')
const detected = weather.parseLocationFile('{"name":"Amsterdam","latitude":52.37403,"longitude":4.88969,"country":"NL","timezone":"Europe/Amsterdam"}')
assertDeepEqual(detected, { name: 'Amsterdam', latitude: 52.37403, longitude: 4.88969 }, 'weather reads a geo.omarchy.org answer with the weather.json parser')
assertDeepEqual(weather.effectiveLocation(unset, detected), detected, 'weather reports for the detected place when none is stored')
assertDeepEqual(weather.effectiveLocation({ name: 'New York', latitude: null, longitude: null }, detected).name, 'New York', 'weather keeps a stored name over the detected place')
assertDeepEqual(weather.effectiveLocation({ name: '', latitude: 34.02577, longitude: -118.7804 }, detected).latitude, 34.02577, 'weather keeps stored coordinates over the detected place')

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

mkdir -p "$test_tmp/bin"
cat >"$test_tmp/bin/curl" <<'EOF'
#!/bin/bash
printf '%s\n' "${@: -1}" >>"$HOME/curl-urls"
printf '%s\n' '{"name":"Amsterdam","latitude":52.37403,"longitude":4.88969,"country":"NL","timezone":"Europe/Amsterdam"}'
EOF
chmod +x "$test_tmp/bin/curl"
[[ $(PATH="$test_tmp/bin:$PATH" weather_location) == "Amsterdam" ]] || fail "weather location names the place geo.omarchy.org detected"
[[ $(cat "$test_tmp/curl-urls") == "https://geo.omarchy.org/" ]] || fail "weather location asks only geo.omarchy.org" "$(cat "$test_tmp/curl-urls")"
pass "weather location names the place geo.omarchy.org detected when none is stored"

require_compositor "weather radar lifecycle runtime test"
require_command quickshell

stage="$test_tmp/radar"
mkdir -p "$stage/weather" "$stage/tiles"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
ln -s "$ROOT/shell/Ui" "$stage/Ui"
cp "$ROOT/shell/plugins/panels/weather/"* "$stage/weather/"
cp "$SHELL_TEST_DIR/fixtures/weather-radar/shell.qml" "$stage/shell.qml"
# Substitute only transport endpoints; the real Radar and Image lifecycle run.
python3 - "$stage" <<'PY'
from pathlib import Path
import sys
stage = Path(sys.argv[1])
p = stage / 'weather/Radar.qml'
s = p.read_text()
a = s.index('source: "https://tile.mierune.co.jp/')
z = s.index('\n', a)
s = s[:a] + 'source: "' + (stage / 'weather/n0b-palette.png').as_uri() + '"' + s[z:]
p.write_text(s)
p = stage / 'weather/Model.js'
s = p.read_text()
a = s.index('  return "https://mesonet.agron.iastate.edu/cache/tile.py/')
z = s.index('\n', a)
s = s[:a] + '  return "' + (stage / 'tiles').as_uri() + '/" + (stamp === "202610230010" && x === 52 && y === 100 ? "missing" : "202610230000") + ".png"' + s[z:]
p.write_text(s)
(stage / 'tiles/202610230000.png').write_bytes((stage / 'weather/n0b-palette.png').read_bytes())
PY
cat >"$test_tmp/bin/curl" <<'EOF_CURL'
#!/bin/bash
printf '%s\n' "${@: -1}" >>"$HOME/radar-urls"
case "${@: -1}" in
  *points/51.50,-0.12) printf '\n404'; exit 22 ;;
  *points/*) printf '{"properties":{"radarStation":"KABX"}}\n200' ;;
  *) printf '{"scans":[{"ts":"2026-10-23T00:00Z"},{"ts":"2026-10-23T00:05Z"}]}\n200' ;;
esac
EOF_CURL
chmod +x "$test_tmp/bin/curl"
HOME="$test_tmp" PATH="$test_tmp/bin:$PATH" OMARCHY_PATH="$ROOT" timeout 20 quickshell -p "$stage" --no-color >"$test_tmp/radar.log" 2>&1 || fail "radar fixture exits cleanly" "$(cat "$test_tmp/radar.log")"
rg -q 'RESULT pass' "$test_tmp/radar.log" || fail "radar lifecycle assertions pass" "$(cat "$test_tmp/radar.log")"
if rg -q 'RESULT fail|ReferenceError|TypeError|Unable to assign|Binding loop' "$test_tmp/radar.log"; then
  fail "radar fixture has no QML errors" "$(cat "$test_tmp/radar.log")"
fi
[[ $(rg -c 'points/51.50,-0.12$' "$test_tmp/radar-urls") == "1" ]] || fail "radar caches an unsupported station across opens"
[[ $(wc -l <"$test_tmp/radar-urls") == "3" ]] || fail "radar reuses fresh scans and stations on reopen"
pass "radar survives failed tiles and refreshes, releases images on close, and caches unsupported stations"

settings_stage="$test_tmp/settings-radar"
mkdir -p "$settings_stage/weather" "$settings_stage/Ui" "$test_tmp/.local/state/omarchy/settings"
ln -s "$ROOT/shell/Commons" "$settings_stage/Commons"
for component in "$ROOT/shell/Ui/"*; do
  if [[ ${component##*/} != "KeyboardPanel.qml" ]]; then
    ln -s "$component" "$settings_stage/Ui/"
  fi
done
cp "$SHELL_TEST_DIR/fixtures/weather-radar/KeyboardPanel.qml" "$settings_stage/Ui/KeyboardPanel.qml"
cp "$ROOT/shell/plugins/panels/weather/"* "$settings_stage/weather/"
cp "$SHELL_TEST_DIR/fixtures/weather-radar/settings.qml" "$settings_stage/shell.qml"
printf '%s\n' '{"name":"San Ysidro","latitude":35.5,"longitude":-106.7}' >"$test_tmp/.local/state/omarchy/settings/weather.json"
python3 "$SHELL_TEST_DIR/fixtures/weather-radar/network.py" "$settings_stage" >"$test_tmp/network.log" 2>&1 &
network_pid=$!
trap 'kill "$network_pid" 2>/dev/null || true; rm -rf "$test_tmp"' EXIT
for ((attempt = 0; attempt < 100; attempt++)); do
  [[ -s $settings_stage/port ]] && break
  sleep 0.02
done
[[ -s $settings_stage/port ]] || fail "radar fixture HTTP server starts" "$(cat "$test_tmp/network.log")"
python3 - "$settings_stage" <<'PY'
from pathlib import Path
import sys
stage = Path(sys.argv[1])
base = 'http://127.0.0.1:' + (stage / 'port').read_text()
p = stage / 'weather/Radar.qml'
s = p.read_text().replace('https://api.weather.gov/points/', base + '/nws/')
s = s.replace('https://tile.mierune.co.jp/mierune_mono/', base + '/mierune/')
p.write_text(s)
p = stage / 'weather/Model.js'
s = p.read_text().replace('https://mesonet.agron.iastate.edu/json/radar.py?operation=list&radar=', base + '/scans/?operation=list&radar=')
s = s.replace('https://mesonet.agron.iastate.edu/cache/tile.py/', base + '/iem/')
p.write_text(s)
PY
cat >"$test_tmp/bin/curl" <<'EOF_CURL'
#!/bin/bash
if [[ ${@: -1} == http://127.0.0.1:* ]]; then
  printf '%s\n' "$$" >>"$HOME/radar-pids"
  exec /usr/bin/curl "$@"
else
  printf '%s\n' '{}'
fi
EOF_CURL
chmod +x "$test_tmp/bin/curl"
HOME="$test_tmp" PATH="$test_tmp/bin:$PATH" OMARCHY_PATH="$ROOT" timeout 20 quickshell -p "$settings_stage" --no-color >"$test_tmp/radar-settings.log" 2>&1 || fail "radar setting fixture exits cleanly" "$(cat "$test_tmp/radar-settings.log")"
rg -q 'RESULT pass' "$test_tmp/radar-settings.log" || fail "radar setting behavior assertions pass" "$(cat "$test_tmp/radar-settings.log")"
if rg -q 'RESULT fail|ReferenceError|TypeError|Unable to assign|Binding loop' "$test_tmp/radar-settings.log"; then
  fail "radar setting fixture has no QML errors" "$(cat "$test_tmp/radar-settings.log")"
fi
pass "weather radar makes no requests with explicit false, loads frames by default, and stops requests when disabled"

kill "$network_pid"
wait "$network_pid" 2>/dev/null || true
behavior_stage="$test_tmp/weather-behavior"
mkdir -p "$behavior_stage/weather"
ln -s "$settings_stage/Ui" "$behavior_stage/Ui"
ln -s "$ROOT/shell/Commons" "$behavior_stage/Commons"
cp "$ROOT/shell/plugins/panels/weather/"* "$behavior_stage/weather/"
cp "$SHELL_TEST_DIR/fixtures/weather-radar/behavior.qml" "$behavior_stage/shell.qml"
python3 "$SHELL_TEST_DIR/fixtures/weather-radar/behavior-network.py" "$behavior_stage" >"$test_tmp/behavior-network.log" 2>&1 &
network_pid=$!
for ((attempt = 0; attempt < 100; attempt++)); do
  [[ -s $behavior_stage/port ]] && break
  sleep 0.02
done
[[ -s $behavior_stage/port ]] || fail "weather behavior HTTP server starts" "$(cat "$test_tmp/behavior-network.log")"
python3 - "$behavior_stage" <<'PY'
from pathlib import Path
import sys
stage = Path(sys.argv[1])
base = 'http://127.0.0.1:' + (stage / 'port').read_text()
for name in ['Panel.qml', 'Radar.qml', 'Model.js']:
  path = stage / 'weather' / name
  source = path.read_text()
  for original, endpoint in [
    ('https://wttr.in/', '/wttr/'),
    ('https://geo.omarchy.org/', '/geo'),
    ('https://api.open-meteo.com/v1/forecast', '/forecast'),
    ('https://api.weather.gov/points/', '/nws/'),
    ('https://tile.mierune.co.jp/mierune_mono/', '/mierune/'),
    ('https://mesonet.agron.iastate.edu/json/radar.py?operation=list&radar=', '/scans/?operation=list&radar='),
    ('https://mesonet.agron.iastate.edu/cache/tile.py/', '/iem/')
  ]:
    source = source.replace(original, base + endpoint)
  path.write_text(source)
PY
for mode in ${WEATHER_TEST_MODE:-named snapshot keyboard}; do
  : >"$test_tmp/behavior-urls"
  if [[ $mode != "keyboard" ]]; then
    printf '%s\n' '{"name":"Denver"}' >"$test_tmp/.local/state/omarchy/settings/weather.json"
  else
    printf '%s\n' '{"name":"Denver","latitude":39.7392,"longitude":-104.9903}' >"$test_tmp/.local/state/omarchy/settings/weather.json"
  fi
  HOME="$test_tmp" PATH="$test_tmp/bin:$PATH" OMARCHY_PATH="$ROOT" WEATHER_TEST_MODE="$mode" timeout 15 quickshell -p "$behavior_stage" --no-color >"$test_tmp/weather-$mode.log" 2>&1 || fail "weather $mode behavior fixture exits cleanly" "$(cat "$test_tmp/weather-$mode.log")"
  rg -q 'RESULT pass' "$test_tmp/weather-$mode.log" || fail "weather $mode behavior assertions pass" "$(cat "$test_tmp/weather-$mode.log")"
  if rg -q 'RESULT fail|ReferenceError|TypeError|Unable to assign|Binding loop' "$test_tmp/weather-$mode.log"; then
    fail "weather $mode behavior fixture has no QML errors" "$(cat "$test_tmp/weather-$mode.log")"
  fi
  case $mode in
    named)
      rg -q '^/wttr/Denver\?format=j1$' "$test_tmp/behavior-urls" || fail "name-only location requests Denver from wttr"
      rg -q '^/wttr/\?format=j1$' "$test_tmp/behavior-urls" || fail "failed auto lookup requests wttr IP fallback"
      (( $(rg -c '^/forecast\?' "$test_tmp/behavior-urls") >= 2 )) || fail "both name-only and auto fallback request Open-Meteo"
      pass "name-only and failed auto-lookup locations load Open-Meteo and radar"
      ;;
    snapshot) pass "wttr response keeps its original query after the location changes" ;;
    keyboard) pass "focused weather panel routes radar keys and preserves editor, Tab, and Escape" ;;
  esac
done
