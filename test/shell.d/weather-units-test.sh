#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const weather = requireFromRoot('shell/plugins/panels/weather/Model.js')

assertEqual(weather.measurementLocale('', 'en_IE.UTF-8', 'en_US'), 'en_IE.UTF-8', 'weather prefers LC_MEASUREMENT over fallback locale')
assertEqual(weather.measurementLocale('en_US.UTF-8', 'en_IE.UTF-8', 'en_GB'), 'en_US.UTF-8', 'weather lets LC_ALL override LC_MEASUREMENT')
assertEqual(weather.measurementLocale('', '', 'en_US'), 'en_US', 'weather falls back to system locale when LC_ALL and LC_MEASUREMENT are unset')
assertEqual(weather.shouldUseImperial('', weather.measurementLocale('', 'en_IE.UTF-8', 'en_US'), ''), false, 'weather uses metric units when LC_MEASUREMENT is metric under en_US LANG')
assertEqual(weather.shouldUseImperial('', weather.measurementLocale('en_US.UTF-8', 'en_IE.UTF-8', 'en_GB'), ''), true, 'weather uses imperial units when LC_ALL is en_US')
JS
