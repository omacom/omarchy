#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const weather = requireFromRoot('shell/plugins/panels/weather/Model.js')

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

const cottage = { ssid: 'Cottage', gateway: '02:00:00:00:00:01' }
assertDeepEqual(weather.parseNetwork('{"ssid":"Cottage","gateway":"02:00:00:00:00:01"}\n'), cottage, 'weather parses the Wi-Fi network omarchy-weather-location identifies')
assertEqual(weather.parseNetwork(''), null, 'weather reads no network off Wi-Fi')
const perNetwork = JSON.stringify({ name: 'Paris', latitude: 48.85341, longitude: 2.3488, networks: [{ ssid: 'Cottage', gateway: '02:00:00:00:00:01', name: 'Besançon', latitude: 47.24878, longitude: 6.01815 }] })
assertDeepEqual(weather.parseLocationFile(perNetwork, cottage), { name: 'Besançon', latitude: 47.24878, longitude: 6.01815 }, 'weather uses the location set for this Wi-Fi network')
assertEqual(weather.parseLocationFile(perNetwork, { ssid: 'Cottage', gateway: '02:00:00:00:00:02' }).name, 'Paris', 'weather tells apart networks of the same name by their gateway')
assertEqual(weather.parseLocationFile(perNetwork, { ssid: 'Cottage-Guest', gateway: '02:00:00:00:00:01' }).name, 'Paris', 'weather needs the SSID to match as well as the gateway')
assertEqual(weather.parseLocationFile(perNetwork, { ssid: 'Cottage', gateway: '' }).name, 'Paris', 'weather matches no network whose gateway is not known yet')
assertEqual(weather.parseLocationFile(perNetwork, null).name, 'Paris', 'weather uses the top-level location off Wi-Fi')
assert(weather.isAutoLocation(weather.parseLocationFile('{"networks":[{"ssid":"Cottage","gateway":"02:00:00:00:00:01","name":"Besançon"}]}', { ssid: 'Hotel', gateway: '02:00:00:00:00:03' })),'weather auto-detects on a network with no location of its own or top-level one')

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

# Off Wi-Fi, or on $WIFI_SSID behind a gateway at $WIFI_GATEWAY, unresolved
# while that is empty, and routed over IPv6 alone with $WIFI_IPV6_ONLY.
mkdir -p "$test_tmp/bin"
cat >"$test_tmp/bin/nmcli" <<'EOF'
#!/bin/bash
[[ -z ${WIFI_SSID:-} ]] || printf 'no:wlan0:Neighbours\nyes:wlan0:%s\n' "$WIFI_SSID"
EOF
cat >"$test_tmp/bin/ip" <<'EOF'
#!/bin/bash
if [[ $* == *"-6 route"* ]]; then
  echo '[{"dst":"default","gateway":"fe80::1","dev":"wlan0"}]'
elif [[ $* == *route* && -z ${WIFI_IPV6_ONLY:-} ]]; then
  echo '[{"dst":"default","gateway":"192.168.1.254","dev":"wlan0"}]'
elif [[ $* == *route* || -z ${WIFI_GATEWAY:-} ]]; then
  echo '[]'
else
  echo "[{\"lladdr\":\"$WIFI_GATEWAY\",\"state\":[\"REACHABLE\"]}]"
fi
EOF
chmod +x "$test_tmp/bin/nmcli" "$test_tmp/bin/ip"

weather_location() {
  HOME="$test_tmp" PATH="$test_tmp/bin:$PATH" "$ROOT/bin/omarchy-weather-location" "$@"
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

cat >"$test_tmp/bin/curl" <<'EOF'
#!/bin/bash
printf '%s\n' "${@: -1}" >>"$HOME/curl-urls"
printf '%s\n' '{"name":"Amsterdam","latitude":52.37403,"longitude":4.88969,"country":"NL","timezone":"Europe/Amsterdam"}'
EOF
chmod +x "$test_tmp/bin/curl"
[[ $(weather_location) == "Amsterdam" ]] || fail "weather location names the place geo.omarchy.org detected"
[[ $(cat "$test_tmp/curl-urls") == "https://geo.omarchy.org/" ]] || fail "weather location asks only geo.omarchy.org" "$(cat "$test_tmp/curl-urls")"
pass "weather location names the place geo.omarchy.org detected when none is stored"

weather_file="$test_tmp/.local/state/omarchy/settings/weather.json"
on_wifi() {
  WIFI_SSID=$1 WIFI_GATEWAY=$2 weather_location "${@:3}"
}

on_wifi Cottage 02:00:00:00:00:01 --set "Besançon" "47.24878,6.01815"
on_wifi Office 02:00:00:00:00:02 --set "Bordeaux"
weather_location --set "Paris" "48.85341,2.3488"
[[ $(jq -c . "$weather_file") == '{"name":"Paris","latitude":48.85341,"longitude":2.3488,"networks":[{"ssid":"Cottage","gateway":"02:00:00:00:00:01","name":"Besançon","latitude":47.24878,"longitude":6.01815},{"ssid":"Office","gateway":"02:00:00:00:00:02","name":"Bordeaux"}]}' ]] || fail "weather location keeps a location per Wi-Fi network" "$(cat "$weather_file")"
pass "weather location keeps a location per Wi-Fi network, and the top-level one off Wi-Fi"

[[ $(on_wifi Cottage 02:00:00:00:00:01) == "Besançon" ]] || fail "weather location names this Wi-Fi network's location"
[[ $(on_wifi Cottage 02:00:00:00:00:03) == "Paris" ]] || fail "weather location names the top-level location on a network of the same name elsewhere"
pass "weather location names this Wi-Fi network's location, else the top-level one"

[[ $(on_wifi Cottage 02:00:00:00:00:01 --network) == '{"ssid":"Cottage","gateway":"02:00:00:00:00:01"}' ]] || fail "weather location identifies this Wi-Fi network"
[[ -z $(weather_location --network) ]] || fail "weather location identifies no network off Wi-Fi"
[[ $(WIFI_IPV6_ONLY=1 on_wifi Lab 02:00:00:00:00:04 --network) == '{"ssid":"Lab","gateway":"02:00:00:00:00:04"}' ]] || fail "weather location identifies an IPv6-only Wi-Fi network by its IPv6 gateway"
pass "weather location identifies this Wi-Fi network by SSID and gateway"

before=$(cat "$weather_file")
if on_wifi Hotel "" --set "Royan" 2>/dev/null || [[ $(cat "$weather_file") != "$before" ]]; then
  fail "weather location stores nothing for a Wi-Fi network whose gateway is unknown"
fi
pass "weather location stores nothing for a Wi-Fi network whose gateway is unknown"

on_wifi Cottage 02:00:00:00:00:01 --clear
[[ $(jq -c . "$weather_file") == '{"networks":[{"ssid":"Office","gateway":"02:00:00:00:00:02","name":"Bordeaux"}]}' ]] || fail "weather location clear forgets this network's and the top-level location" "$(cat "$weather_file")"
[[ $(on_wifi Cottage 02:00:00:00:00:01) == "Amsterdam" ]] || fail "weather location auto-detects on a cleared network"
pass "weather location clear returns this network to auto-detect"

on_wifi Office 02:00:00:00:00:02 --clear
[[ ! -e $weather_file ]] || fail "weather location removes the state file once nothing is left" "$(cat "$weather_file")"
pass "weather location removes the state file once nothing is left"
