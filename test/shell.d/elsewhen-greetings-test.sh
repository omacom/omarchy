#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const { execFileSync } = require('child_process')
const g = requireFromRoot('shell/plugins/panels/elsewhen/Greetings.js')

const at = (zone, hour) => g.greeting(zone, hour).text
const language = (zone, hour) => g.greeting(zone, hour === undefined ? 9 : hour).language

// ---- coverage of every zone the picker offers

const offered = execFileSync('timedatectl', ['list-timezones'], { encoding: 'utf8' }).trim().split('\n')
const placeless = zone => /^(Etc\/|GMT|UCT$|UTC$|Universal$|Zulu$|Greenwich$|Factory$)/.test(zone)
const places = offered.filter(zone => !placeless(zone))
const zoneIds = new Set(g.zoneIds())
const countries = new Set(g.countryCodes())

assert(places.length > 300, 'elsewhen reads the system zone list', places.length)
assertDeepEqual(places.filter(z => !zoneIds.has(z)), [], 'elsewhen has every offered zone in its table')
assertDeepEqual(places.filter(z => g.countryFor(z) === ''), [], 'elsewhen puts every place in a country')
assertDeepEqual(places.filter(z => !countries.has(g.countryFor(z))), [], 'elsewhen greets every place by its country, never by accident')
assert(at('Etc/GMT+5', 9) === 'Good morning' && g.countryFor('Etc/GMT+5') === '', 'elsewhen still greets offset-only zones')

const cities = JSON.parse(fs.readFileSync(path.join(root, 'shell/plugins/panels/elsewhen/cities.json'), 'utf8'))
assertDeepEqual([...new Set(cities.map(c => c[1]))].filter(z => !zoneIds.has(z)), [], 'elsewhen maps every catalogue city')

// ---- languages, overrides and aliases

assertDeepEqual(
  [language('Asia/Jerusalem', 7), g.greeting('Asia/Jerusalem', 7).roman, language('Asia/Singapore', 14), at('Asia/Singapore', 14)],
  ['Hebrew', 'boker tov', 'Malay', 'Selamat tengah hari'],
  'elsewhen greets Tel Aviv and Singapore in their own languages'
)
assertDeepEqual(
  ['Pacific/Honolulu', 'America/Denver', 'America/Montreal', 'America/Toronto'].map(z => language(z)),
  ['Hawaiian', 'English', 'French', 'English'],
  'elsewhen applies city overrides only to their cities'
)
assertDeepEqual(
  ['Asia/Calcutta', 'US/Pacific', 'Europe/Kiev'].map(z => language(z)),
  ['Hindi', 'English', 'Ukrainian'],
  'elsewhen resolves aliases like their targets'
)
assert(g.countryCodes().length > 240, 'elsewhen speaks for every country code')

assertDeepEqual(
  [at('Mars/Olympus_Mons', 9), language('', 9), at(undefined, 9).length > 0],
  ['Good morning', 'English', true],
  'elsewhen falls back to English for unknown zones'
)

const samePlace = [
  ['Iceland', 'Atlantic/Reykjavik'],
  ['NZ', 'Pacific/Auckland'],
  ['Singapore', 'Asia/Singapore'],
  ['Asia/Rangoon', 'Asia/Yangon'],
  ['Africa/Asmera', 'Africa/Asmara'],
  ['Africa/Timbuktu', 'Africa/Bamako'],
  ['America/Virgin', 'America/St_Thomas'],
  ['Pacific/Truk', 'Pacific/Chuuk'],
  ['Pacific/Yap', 'Pacific/Chuuk'],
  ['US/Arizona', 'America/Phoenix'],
  ['MST', 'America/Phoenix'],
  ['Canada/Eastern', 'America/Toronto'],
  ['America/Nipigon', 'America/Toronto'],
  ['America/Thunder_Bay', 'America/Toronto']
]
assertDeepEqual(
  samePlace.filter(([alias, canonical]) => g.countryFor(alias) !== g.countryFor(canonical) || at(alias, 9) !== at(canonical, 9)).map(([alias]) => alias),
  [],
  'elsewhen puts legacy aliases in the country of the place they name'
)
assertDeepEqual([g.countryFor('Antarctica/South_Pole'), g.countryFor('Pacific/Ponape')], ['AQ', 'FM'], 'elsewhen keeps the South Pole and Pohnpei where they are')
assertEqual(language('Europe/Simferopol'), 'Ukrainian', 'elsewhen greets Simferopol in Ukrainian')
assert(g.countryFor('America/Montreal') === g.countryFor('America/Toronto') && language('America/Montreal') === 'French', 'elsewhen greets Montreal in French inside Canada')

// ---- every table

const LATIN = /^[ -~ -ɏɐ-˿̀-ͯḀ-ỿ‘’]+$/
const problems = []
for (const key of g.languageKeys()) {
  const bands = g.bandsOf(key)
  if (bands[0].from !== 0) problems.push(`${key}: does not start at midnight`)
  if (!bands.every((b, i) => i === 0 || b.from > bands[i - 1].from)) problems.push(`${key}: bands do not ascend`)
  if (!bands.every(b => b.from >= 0 && b.from <= 23)) problems.push(`${key}: band outside the day`)
  bands.forEach((b, i) => {
    if (b.text.length === 0 || b.text.trim() !== b.text) problems.push(`${key}: blank or padded greeting`)
    const wrap = i === bands.length - 1 && b.text === bands[0].text
    if (i > 0 && !wrap && b.text === bands[i - 1].text) problems.push(`${key}: band ${i} repeats the one before`)
    if (LATIN.test(b.text) ? b.roman !== '' : b.roman === '') problems.push(`${key}: roman where the script is ${LATIN.test(b.text) ? '' : 'not '}Latin`)
    if (b.roman !== '' && !/^[a-z' -]+$/.test(b.roman)) problems.push(`${key}: unsayable roman ${b.roman}`)
  })
  const zone = g.zoneIds().find(z => g.languageFor(z) === key)
  const texts = new Set(bands.map(b => b.text))
  if (zone) for (let h = 0; h < 24; h++) if (!texts.has(at(zone, h))) problems.push(`${key}: hour ${h} has no greeting`)
}
assertDeepEqual(problems, [], 'elsewhen language tables cover the day with sayable greetings')

assertEqual(at('Asia/Tokyo', 24), at('Asia/Tokyo', 23), 'elsewhen clamps hour 24 into the day')
assertEqual(at('Asia/Tokyo', -3), at('Asia/Tokyo', 0), 'elsewhen clamps a negative hour to midnight')
assertEqual(at('Asia/Tokyo', 11.9), at('Asia/Tokyo', 11), 'elsewhen truncates a fractional hour')

// ---- the boundaries the tables exist for

assert(at('Asia/Tokyo', 7) !== at('Asia/Tokyo', 13) && at('Asia/Tokyo', 13) !== at('Asia/Tokyo', 20), 'elsewhen walks Tokyo through its day')
assertDeepEqual([at('Europe/Madrid', 20), at('America/Lima', 20)], ['Buenas tardes', 'Buenas noches'], 'elsewhen keeps Madrid in the afternoon after Lima')
assert(language('Europe/Madrid', 20).startsWith('Spanish') && language('America/Lima', 20) === 'Spanish', 'elsewhen greets Madrid and Lima in Spanish')
assert(at('Europe/Vienna', 13) !== at('Europe/Berlin', 13) && at('Europe/Zurich', 13) !== at('Europe/Berlin', 13), 'elsewhen tells Vienna and Zurich from Berlin at midday')
assert(at('Asia/Jakarta', 12) !== at('Asia/Jakarta', 16), 'elsewhen gives Jakarta an afternoon and a late afternoon')
assertEqual(new Set([0, 6, 12, 18, 23].map(h => at('Asia/Yangon', h))).size, 1, 'elsewhen greets Yangon the same all day')
assert(at('Asia/Hong_Kong', 8) !== at('Asia/Shanghai', 8), 'elsewhen does not greet Hong Kong in Mandarin')
JS
