#!/bin/bash

# Rain tables for the weather panel: MET Norway amounts plus Open-Meteo
# chance-of-rain in expandable day rows. Guards the two faults that once
# slipped through: a manifest without schemaVersion, and day rows nested
# inside the self-hiding fetching indicator.
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

WEATHER_DIR="$ROOT/shell/plugins/panels/weather"

run_node_test <<'JS'
process.env.TZ = 'Europe/Ljubljana'

const fs = require('fs')
const weather = requireFromRoot('shell/plugins/panels/weather/Model.js')
const panelPath = root + '/shell/plugins/panels/weather/Panel.qml'
const panelSource = fs.readFileSync(panelPath, 'utf8')
const lines = panelSource.split('\n')

// ---- Manifest: the registry rejects manifests without schemaVersion. ----
const manifest = JSON.parse(fs.readFileSync(root + '/shell/plugins/panels/weather/manifest.json', 'utf8'))
assertEqual(manifest.schemaVersion, 1, 'weather manifest carries schemaVersion')
assertEqual(manifest.id, 'omarchy.weather', 'weather manifest keeps the stock id')
assertDeepEqual(
  Object.keys(manifest),
  ['schemaVersion', 'id', 'name', 'version', 'author', 'description', 'kinds', 'entryPoints', 'barWidget'],
  'weather manifest keeps the stock key shape'
)
assertDeepEqual(Object.keys(manifest.entryPoints), ['barWidget'], 'weather manifest keeps the stock entry points')
assertDeepEqual(
  Object.keys(manifest.barWidget),
  ['displayName', 'description', 'category', 'allowMultiple', 'settingsForm'],
  'weather manifest keeps the stock bar widget shape'
)
assertEqual(manifest.entryPoints.barWidget, 'BarWidget.qml', 'weather manifest keeps the stock bar widget entry point')

// ---- Neutral fetcher identity: MET Norway requires an identifying
// User-Agent; it must name the upstream project and agree between the model
// and the fetch script. ----
assertEqual(weather.MET_CACHE_SUBDIR, 'weather', 'weather caches MET data under a neutral Omarchy directory')
assert(weather.MET_USER_AGENT.includes('omacom/omarchy'), 'weather MET user agent identifies the upstream project')
const fetchSource = fs.readFileSync(root + '/shell/plugins/panels/weather/met-fetch.sh', 'utf8')
assert(fetchSource.includes(weather.MET_USER_AGENT), 'weather fetch script sends the same user agent as the model')

// ---- Structural reader for Panel.qml: the panel cannot run under plain
// node, so render-structure regressions are pinned by parsing the real QML:
// block spans, nesting, and effective `visible:` bindings. ----
function parseBlocks(textLines) {
  const text = textLines.join('\n')
  const blocks = []
  const stack = []
  let inString = false
  let line = 1
  for (let i = 0; i < text.length; i++) {
    const c = text[i]
    if (c === '\n') { line++; continue }
    if (inString) {
      if (c === '"') inString = false
      continue
    }
    if (c === '"') { inString = true; continue }
    if (c === '/' && text[i + 1] === '/') {
      while (i < text.length && text[i] !== '\n') i++
      line++
      continue
    }
    if (c === '{') {
      const m = textLines[line - 1].match(/([A-Za-z][A-Za-z0-9_.]*)\s*\{[^}]*$/)
      stack.push({ name: m ? m[1] : '{', startLine: line })
    } else if (c === '}') {
      const open = stack.pop()
      if (open) blocks.push({ name: open.name, startLine: open.startLine, endLine: line })
    }
  }
  return blocks
}

function innermostContaining(blocks, markerLine) {
  let best = null
  for (const b of blocks) {
    if (b.startLine <= markerLine && markerLine <= b.endLine) {
      if (!best || b.startLine >= best.startLine) best = b
    }
  }
  return best
}

function findLine(pattern) {
  const idx = lines.findIndex((l) => pattern.test(l))
  return idx === -1 ? -1 : idx + 1
}

// The block's OWN `visible:` binding: first such line at the block's own
// depth, so nested children's bindings never leak into the ancestor.
function ownVisible(block) {
  let depth = 0
  let inString = false
  for (let n = block.startLine; n <= block.endLine; n++) {
    let line = lines[n - 1]
    if (n === block.startLine) {
      const open = line.indexOf('{')
      line = open === -1 ? '' : line.slice(open + 1)
    } else {
      const m = line.match(/^\s*visible:\s*(.+?)\s*$/)
      if (m && depth === 0) return m[1]
    }
    for (let i = 0; i < line.length; i++) {
      const c = line[i]
      if (inString) {
        if (c === '"') inString = false
        continue
      }
      if (c === '"') { inString = true; continue }
      if (c === '/' && line[i + 1] === '/') break
      if (c === '{') depth++
      else if (c === '}') depth--
    }
  }
  return null
}

// Effective `visible:` along the ancestor chain, evaluated for a panel that
// HAS current conditions and day rows. Unknown bindings default to visible;
// the bindings that matter evaluate exactly.
function effectiveVisible(block, rows) {
  const chain = blocks
    .filter((b) => b.startLine <= block.startLine && block.endLine <= b.endLine)
    .sort((a, b) => a.startLine - b.startLine)
  for (const ancestor of chain) {
    const expr = ownVisible(ancestor)
    if (!expr) continue
    if (expr === '!root.current') return false
    if (/dayRows\.length/.test(expr) && rows.length === 0) return false
  }
  return true
}

const blocks = parseBlocks(lines)
const dayRepeaterLine = findLine(/model:\s*root\.dayRows/)
assert(dayRepeaterLine > 0, 'weather panel repeats over the day rows')
const daySection = innermostContaining(blocks, dayRepeaterLine)
assert(daySection, 'weather day section sits inside a QML block')
const fetchingLine = findLine(/Fetching forecast/)
assert(fetchingLine > 0, 'weather fetching indicator exists')
const fetching = innermostContaining(blocks, fetchingLine)
assert(fetching, 'weather fetching indicator sits inside a QML block')
assert(
  dayRepeaterLine > fetching.endLine,
  'weather day rows never nest inside the self-hiding fetching indicator'
)
assert(
  effectiveVisible(daySection, [{ date: '2026-09-12' }]) === true,
  'weather day section stays visible once current conditions arrive'
)
const creditLine = findLine(/Data: MET Norway, Open-Meteo/)
assert(creditLine > 0, 'weather panel credits its data sources')
assert(creditLine > fetching.endLine, 'weather credit line never nests inside the fetching indicator')
assert(
  effectiveVisible(innermostContaining(blocks, creditLine), [{ date: '2026-09-12' }]) === true,
  'weather credit line stays visible with the day rows'
)

// The QML fetch handlers cannot run under node, so their contract is pinned
// against the real source: the Open-Meteo store is unconditional, and the
// wttr handler re-issues both follow-up fetches once the area is known.
function handlerBlock(id) {
  const idLine = findLine(new RegExp(`id:\\s*${id}\\b`))
  assert(idLine > 0, `weather handler exists: ${id}`)
  return innermostContaining(blocks, idLine)
}
const dailyBody = lines.slice(handlerBlock('dailyForecastProc').startLine - 1, handlerBlock('dailyForecastProc').endLine).join('\n')
const tryIdx = dailyBody.search(/\btry\s*\{/)
const storeIdx = dailyBody.search(/root\.dailyForecastReport\s*=\s*parsed/)
assert(tryIdx >= 0 && storeIdx > tryIdx, 'weather stores the arriving Open-Meteo response')
assert(!/\bif\b/.test(dailyBody.slice(tryIdx, storeIdx)), 'weather stores the Open-Meteo response unconditionally')
const forecastBody = lines.slice(handlerBlock('forecastProc').startLine - 1, handlerBlock('forecastProc').endLine).join('\n')
assert(forecastBody.includes('root.refreshDailyForecast(parsed)'), 'weather re-issues the Open-Meteo fetch once the area is known')
assert(forecastBody.includes('root.refreshMet()'), 'weather re-issues the MET fetch once the area is known')

// ---- Model units: coordinates, symbols, slots, and formatting. ----
assertEqual(weather.metUrl('46.05111', '14.51111'), weather.MET_API_URL + '?lat=46.0511&lon=14.5111', 'weather rounds MET coordinates to 4 decimals')
assertEqual(weather.metUrl('nope', '14.5'), '', 'weather refuses unparseable MET coordinates')
assertEqual(
  weather.pickWetterSymbol([{ precipMm: 0.2, symbol: 'cloudy' }, { precipMm: 1.5, symbol: 'rain' }]),
  'rain',
  'weather shows the wetter hour symbol'
)
assertEqual(
  weather.pickWetterSymbol([{ precipMm: 1.5, symbol: 'rain' }, { precipMm: 1.5, symbol: 'heavyrain' }]),
  'rain',
  'weather keeps the first symbol on a precipitation tie'
)
assertEqual(weather.iconForMetSymbol('clearsky'), weather.iconForCode(113, false), 'weather maps MET symbols onto widget glyphs')
assertEqual(weather.iconForMetSymbol('partlycloudy_night'), weather.iconForCode(116, true), 'weather keeps MET day/night suffixes')
assertEqual(weather.iconForMetSymbol('volcano'), weather.iconForCode(119, false), 'weather falls back to cloudy for unknown MET symbols')
assertEqual(weather.formatSlotTemp(21.4, false), '21°', 'weather formats slot temperatures')
assertEqual(weather.formatSlotTemp(null, false), weather.MISSING_VALUE, 'weather dashes missing slot temperatures')
assertEqual(weather.formatRain(2), '2.0', 'weather formats rain amounts')
assertEqual(weather.formatRain(null), weather.MISSING_VALUE, 'weather dashes missing rain')
assertEqual(weather.formatChance(80), '80%', 'weather formats chance of rain')
assertEqual(weather.formatChance(null), weather.MISSING_VALUE, 'weather dashes missing chance')
assertEqual(weather.formatDayRain(2), '2.0 mm', 'weather formats day rain totals')
assertEqual(weather.dayRainTotal([{ rainMm: 1 }, { rainMm: null }, { rainMm: 2 }]), 3, 'weather totals day rain over populated slots')
assertEqual(weather.dayRainTotal([{ rainMm: null }]), null, 'weather totals missing day rain as missing')

const wttrArea = { nearest_area: [{ latitude: '46.05', longitude: '14.51', areaName: [{ value: 'Ljubljana' }] }] }
assertDeepEqual(
  weather.forecastCoords(weather.parseLocationFile(''), wttrArea, null),
  [46.05, 14.51],
  'weather resolves fetch coordinates from the detected area without a saved location'
)
assertDeepEqual(
  weather.forecastCoords(weather.parseLocationFile('{"name":"X","latitude":1.5,"longitude":2.5}'), wttrArea, null),
  [1.5, 2.5],
  'weather prefers saved coordinates over the detected area'
)
assertEqual(weather.forecastCoords(weather.parseLocationFile(''), null, null), null, 'weather issues no fetch without coordinates anywhere')

// A Locationforecast-shaped series with only 6-hour data at a quarter start
// must still populate that quarter through the next_6_hours fallback.
const quarterStart = Date.parse('2026-09-13T04:00:00Z')
const fallbackIndex = weather.indexMetTimeseries([{
  time: new Date(quarterStart).toISOString().slice(0, 13) + ':00:00Z',
  data: {
    instant: { details: { air_temperature: 14.0 } },
    next_6_hours: { summary: { symbol_code: 'rain' }, details: { precipitation_amount: 2.5 } }
  }
}])
const fallbackSlots = weather.buildSixHourSlots(fallbackIndex, {}, '2026-09-13')
assertEqual(fallbackSlots.length, 4, 'weather builds four 6-hour quarters for a later day')
assertDeepEqual(fallbackSlots.map((s) => s.label), ['00-06', '06-12', '12-18', '18-24'], 'weather labels quarters in local wall time')

// ---- End to end: the no-saved-location sequence through populated tables.
// MET instants are UTC; slot boundaries are local wall time
// (Europe/Ljubljana, UTC+2 in September).
const H = 3600000
const TODAY = '2026-09-12'
const NOW_MS = Date.parse('2026-09-11T22:35:00Z')
const seriesBase = Date.parse('2026-09-11T20:00:00Z')
const series = []
for (let h = 0; h < 100; h++) {
  const ms = seriesBase + h * H
  const entry = {
    time: new Date(ms).toISOString().slice(0, 13) + ':00:00Z',
    data: {
      instant: { details: { air_temperature: 12 + (h % 9) } },
      next_1_hours: {
        summary: { symbol_code: h % 2 ? 'lightrain' : 'cloudy' },
        details: { precipitation_amount: (h % 3) * 0.4 }
      }
    }
  }
  if (h % 6 === 0) {
    entry.data.next_6_hours = {
      summary: { symbol_code: 'rain' },
      details: { precipitation_amount: 1.2 }
    }
  }
  series.push(entry)
}
const hourlyTime = []
const hourlyProb = []
for (let h = 0; h < 96; h++) {
  const ms = Date.parse(TODAY + 'T00:00:00') + h * H
  const d = new Date(ms)
  const pad = (n) => String(n).padStart(2, '0')
  hourlyTime.push(`${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:00`)
  hourlyProb.push((h * 7) % 100)
}
const openMeteo = {
  daily: {
    time: ['2026-09-12', '2026-09-13', '2026-09-14', '2026-09-15'],
    temperature_2m_max: [20.1, 21.6, 18.2, 17.9],
    temperature_2m_min: [12.2, 13.1, 10.8, 9.2],
    weather_code: [3, 63, 95, 1]
  },
  hourly: { time: hourlyTime, precipitation_probability: hourlyProb }
}

const metIndex = weather.indexMetTimeseries(series)
const probIndex = weather.indexPrecipitationProbability(openMeteo.hourly)
const rows = weather.openMeteoDayRows(openMeteo, TODAY)
assertEqual(rows.length, 4, 'weather yields four day rows starting today')
assertDeepEqual(rows.map((r) => r.date), ['2026-09-12', '2026-09-13', '2026-09-14', '2026-09-15'], 'weather rows start at today')
assertEqual(rows[0].isToday, true, 'weather marks the first row as today')
const todaySlots = weather.buildTwoHourSlots(metIndex, probIndex, NOW_MS, weather.TWO_HOUR_SLOT_COUNT)
assertEqual(todaySlots.length, 12, 'weather builds 12 two-hour slots for today')
for (const s of todaySlots) {
  assert(s.rainMm !== null, `weather populates MET rain for slot ${s.label}`)
  assert(s.chance !== null, `weather populates Open-Meteo chance for slot ${s.label}`)
  assert(s.tempC !== null && s.icon, `weather populates temp and icon for slot ${s.label}`)
}
const laterSlots = weather.buildSixHourSlots(metIndex, probIndex, '2026-09-13')
assertEqual(laterSlots.length, 4, 'weather builds four quarters for a later day')
for (const s of laterSlots) {
  assert(s.rainMm !== null, `weather populates MET rain for quarter ${s.label}`)
  assert(s.chance !== null, `weather populates Open-Meteo chance for quarter ${s.label}`)
}
JS

# ---- met-fetch.sh: the caching helper behind the MET fetch. ----
[[ -x "$WEATHER_DIR/met-fetch.sh" ]] || fail "weather MET fetcher is executable"
pass "weather MET fetcher is executable"

bash -n "$WEATHER_DIR/met-fetch.sh" || fail "weather MET fetcher parses as bash"
pass "weather MET fetcher parses as bash"

fetch_tmp=$(mktemp -d)
trap 'rm -rf "$fetch_tmp"' EXIT

output=$("$WEATHER_DIR/met-fetch.sh" 2>/dev/null) && fail "weather MET fetcher rejects missing arguments" "$output"
[[ $output == *'"status":"error"'* ]] || fail "weather MET fetcher reports usage errors as JSON" "$output"
pass "weather MET fetcher rejects missing arguments as JSON"

output=$("$WEATHER_DIR/met-fetch.sh" "46.05" "not-a-number" "$fetch_tmp" 2>/dev/null) && fail "weather MET fetcher rejects bad coordinates" "$output"
pass "weather MET fetcher rejects bad coordinates"

# A primed cache with a fresh check stays local: no network involved.
mkdir -p "$fetch_tmp/met"
printf '{}' >"$fetch_tmp/met/body.json"
now=$(date +%s)
printf 'meta_lat="46.0500"\nmeta_lon="14.5100"\nlast_fetch="%s"\nexpires=""\nlast_modified=""\n' "$now" >"$fetch_tmp/met/meta"
output=$("$WEATHER_DIR/met-fetch.sh" "46.05" "14.51" "$fetch_tmp/met" 2>/dev/null) || fail "weather MET fetcher serves a fresh cache without fetching" "$output"
[[ $output == *'"status":"throttled"'* ]] || fail "weather MET fetcher reports the throttled cache" "$output"
pass "weather MET fetcher serves a fresh cache without fetching"

