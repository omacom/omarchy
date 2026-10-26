#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const weather = requireFromRoot('shell/plugins/panels/weather/Model.js')

// Open-Meteo dates its days at the location. At 15:00 UTC it is already the
// 27th in Sydney but still the 26th in Honolulu, so a machine in either one
// looking at the other must count the days from the location's date.
const honolulu = { utc_offset_seconds: -36000, daily: { time: ['2026-10-26', '2026-10-27', '2026-10-28', '2026-10-29'] } }
const sydney = { utc_offset_seconds: 39600, daily: { time: ['2026-10-27', '2026-10-28', '2026-10-29', '2026-10-30'] } }
const afternoonUtc = Date.UTC(2026, 9, 26, 15, 0)
assertDeepEqual(weather.openMeteoForecastDays(honolulu, '2026-10-27', afternoonUtc).map(day => day.date), ['2026-10-27', '2026-10-28', '2026-10-29'], 'weather counts forecast days from a location behind this machine')
assertDeepEqual(weather.openMeteoForecastDays(sydney, '2026-10-26', afternoonUtc).map(day => day.date), ['2026-10-28', '2026-10-29', '2026-10-30'], 'weather leaves out the current day of a location ahead of this machine')
assertDeepEqual(weather.openMeteoForecastDays({ daily: { time: ['2026-10-26', '2026-10-27', '2026-10-28'] } }, '2026-10-26', afternoonUtc).map(day => day.date), ['2026-10-27', '2026-10-28'], 'weather falls back to the machine date when utc_offset_seconds is missing')
JS
