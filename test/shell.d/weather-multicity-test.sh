#!/bin/bash

# Multi-city pages for the weather panel: the first page is the current
# location exactly as stock Omarchy resolves it, followed by added cities.
# Guards the faults that motivated the feature: cities lost on reopen when
# the settings directory did not exist yet, pages sharing one MET cache,
# and sideways swipes flipping more than one page per gesture.
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

// Public example points only: Ljubljana city centre, Oslo, Tokyo.
const LJU = { name: 'Ljubljana', latitude: 46.05, longitude: 14.51 }
const OSLO = { name: 'Oslo', latitude: 59.91, longitude: 10.75 }
const TOKYO = { name: 'Tokyo', latitude: 35.68, longitude: 139.69 }
const CURRENT = { name: 'CurrentPlace', latitude: 46.05, longitude: 14.51 }

// ---- Page model: ordering, add, duplicate no-op, remove, current first. ----
assertDeepEqual(
  weather.buildPages(CURRENT, []).map((p) => [p.isCurrent, p.name]),
  [[true, 'CurrentPlace']],
  'weather keeps a single page holding the current location first'
)
assertDeepEqual(
  weather.buildPages(CURRENT, [OSLO, TOKYO]).map((p) => [p.isCurrent, p.name]),
  [[true, 'CurrentPlace'], [false, 'Oslo'], [false, 'Tokyo']],
  'weather lists added cities after the current location in insertion order'
)
assertDeepEqual(
  weather.addCity([OSLO], TOKYO).map((c) => c.name),
  ['Oslo', 'Tokyo'],
  'weather appends a new city'
)
assertDeepEqual(
  weather.addCity([{ name: 'Oslo', latitude: 59.91, longitude: 10.75 }], { name: 'Oslo, Norway', latitude: 59.91004, longitude: 10.75003 }),
  [{ name: 'Oslo', latitude: 59.91, longitude: 10.75 }],
  'weather treats adding a duplicate city as a no-op preserving the original entry'
)
assertDeepEqual(
  weather.addCity([OSLO], { name: 'Nowhere', latitude: null, longitude: null }),
  [OSLO],
  'weather ignores added cities without coordinates'
)
assertDeepEqual(
  (() => { const before = [OSLO]; weather.addCity(before, TOKYO); return before })(),
  [OSLO],
  'weather never mutates the city list on add'
)
assertDeepEqual(
  weather.removeCity([OSLO, TOKYO], weather.cityKey(59.91, 10.75)).map((c) => c.name),
  ['Tokyo'],
  'weather removes a city by coordinates'
)
assertDeepEqual(
  weather.removeCity([OSLO], weather.cityKey(35.68, 139.69)),
  [OSLO],
  'weather treats removing an unknown city as a no-op'
)
assertEqual(weather.cityKey(46.05, 14.51), weather.cityKey(46.05004, 14.51003), 'weather keys cities stable under 4-decimal rounding')
assert(weather.cityKey(46.05, 14.51) !== weather.cityKey(59.91, 10.75), 'weather keys Ljubljana apart from Oslo')
assert(weather.cityKey(59.91, 10.75) !== weather.cityKey(35.68, 139.69), 'weather keys Oslo apart from Tokyo')
assertEqual(weather.isDuplicateCity(CURRENT, [], LJU), true, 'weather counts a city matching the current location as a duplicate')
assertEqual(weather.isDuplicateCity(CURRENT, [], TOKYO), false, 'weather accepts a city far from the current location')
assertEqual(weather.isDuplicateCity(CURRENT, [OSLO], OSLO), true, 'weather counts an already added city as a duplicate')

// ---- City-list persistence: a widget-owned file beside weather.json. ----
assertDeepEqual(weather.parseCityList(weather.serializeCityList([OSLO, TOKYO])), [OSLO, TOKYO], 'weather round-trips the city list')
assertDeepEqual(weather.parseCityList(weather.serializeCityList([])), [], 'weather round-trips an empty city list')
assertDeepEqual(weather.parseCityList(''), [], 'weather parses a missing city list as empty')
assertDeepEqual(weather.parseCityList('not json{'), [], 'weather parses a corrupt city list as empty')
assertDeepEqual(weather.parseCityList('{"name":"Oslo"}'), [], 'weather parses a non-list city file as empty')
assertDeepEqual(
  weather.parseCityList(JSON.stringify([OSLO, { name: '', latitude: 1, longitude: 2 }, { name: 'X' }, TOKYO])),
  [OSLO, TOKYO],
  'weather drops invalid city entries while valid ones survive'
)
assertEqual(weather.CITIES_FILENAME, 'weather-cities.json', 'weather persists added cities beside the stock weather.json contract')
assert(weather.CITIES_FILENAME.endsWith('.json'), 'weather city file stays JSON')
assert(weather.CITIES_FILENAME !== 'weather.json', 'weather city file never collides with the stock location file')

// ---- Per-city MET cache isolation over the model helpers. ----
for (const sub of [weather.metCacheSubdir(LJU.latitude, LJU.longitude), weather.metCacheSubdir(OSLO.latitude, OSLO.longitude), weather.metCacheSubdir(TOKYO.latitude, TOKYO.longitude)]) {
  assert(sub.startsWith(weather.MET_CACHE_SUBDIR + '/'), 'weather scopes every added city under the shared MET parent')
}
assert(weather.metCacheSubdir(OSLO.latitude, OSLO.longitude) !== weather.metCacheSubdir(TOKYO.latitude, TOKYO.longitude), 'weather isolates Oslo from Tokyo in the MET cache')
assert(weather.metCacheSubdir(LJU.latitude, LJU.longitude) !== weather.metCacheSubdir(OSLO.latitude, OSLO.longitude), 'weather isolates Ljubljana from Oslo in the MET cache')
assertEqual(weather.metCacheSubdir(46.05, 14.51), weather.metCacheSubdir(46.05004, 14.51003), 'weather keeps the MET subdir stable under 4-decimal rounding')
assert(weather.MET_USER_AGENT.includes('omacom/omarchy'), 'weather MET user agent identifies the upstream project')

// ---- Horizontal swipe: one page per gesture, vertical wheels pass through. ----
let swipeAcc = 0
let swipeSteps = 0
for (const dx of [20, 20, 20, 20, 20]) {
  const folded = weather.accumulateSwipe(swipeAcc, dx, weather.SWIPE_THRESHOLD)
  swipeAcc = folded.acc
  swipeSteps += Math.abs(folded.step)
}
assertEqual(swipeSteps, 1, 'weather accumulates small horizontal deltas into a single page step')
assertEqual(swipeAcc, 0, 'weather resets the swipe accumulator on a page step')
assertEqual(weather.swipeStepsForGesture([{ x: -60, y: 0 }, { x: -60, y: 0 }, { x: -60, y: 0 }, { x: -60, y: 0 }]), 1, 'weather yields exactly one page change for a long gesture')
assertEqual(weather.swipeStepsForGesture([{ x: -200, y: 0 }]), 1, 'weather steps left to the next page')
assertEqual(weather.swipeStepsForGesture([{ x: 200, y: 0 }]), -1, 'weather steps right to the previous page')
assertEqual(weather.swipeStepsForGesture([{ x: 0, y: -120 }, { x: 0, y: -120 }]), 0, 'weather changes no page for a vertical wheel')
assertEqual(weather.swipeStepsForGesture([{ x: -30, y: -120 }]), 0, 'weather treats any vertical component as a scroll, not a swipe')
assertEqual(weather.swipeStepsForGesture([{ x: 10, y: 0 }, { x: -10, y: 0 }]), 0, 'weather changes no page for sub-threshold jitter')
assertEqual(weather.isHorizontalWheel(-40, 0), true, 'weather accepts a purely horizontal wheel as a swipe')
assertEqual(weather.isHorizontalWheel(0, -40), false, 'weather rejects a vertical wheel as a swipe')
assertEqual(weather.isHorizontalWheel(-40, -40), false, 'weather rejects a diagonal wheel as a swipe')
assertEqual(weather.isHorizontalWheel(0, 0), false, 'weather rejects an empty wheel event')
assertDeepEqual(weather.pageWindow(1, 3), [0, 1, 2], 'weather prefetches the visible page and its neighbours')
assertDeepEqual(weather.pageWindow(0, 3), [0, 1], 'weather prefetches forward from the first page')
assertDeepEqual(weather.pageWindow(2, 3), [1, 2], 'weather prefetches backward from the last page')
assertDeepEqual(weather.pageWindow(0, 1), [0], 'weather fetches the only page there is')

// ---- Structural reader for Panel.qml, shared with the rain tables test:
// the panel cannot run under plain node, so render-structure regressions are
// pinned by parsing the real QML: block spans, nesting, and effective
// `visible:` bindings. ----
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

function spanText(block) {
  return lines.slice(block.startLine - 1, block.endLine).join('\n')
}

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

function handlerBlock(id) {
  const idLine = findLine(new RegExp(`id:\\s*${id}\\b`))
  assert(idLine > 0, `weather handler exists: ${id}`)
  const block = innermostContaining(blocks, idLine)
  assert(block, `weather handler sits inside a QML block: ${id}`)
  return block
}

const containerLine = findLine(/id:\s*pageContainer\b/)
assert(containerLine > 0, 'weather wraps pages in a page container')
const container = innermostContaining(blocks, containerLine)
assert(container, 'weather page container sits inside a QML block')

assert(panelSource.includes('CITIES_FILENAME'), 'weather reads the widget-owned cities file through the model constant')
assert(panelSource.includes('settings/weather.json'), 'weather keeps the stock weather.json contract untouched')
assert(panelSource.includes('omarchy-weather-location'), 'weather still saves locations through omarchy-weather-location')

const metBodyLine = findLine(/property FileView metBodyFile/)
assert(metBodyLine > 0, 'weather keeps a cached Locationforecast body')
assert(/metCityKey|activeMetCacheDir|metCacheSubdir/.test(spanText(innermostContaining(blocks, metBodyLine))), 'weather scopes the cached body to the visible page')
assert(panelSource.includes('activeIsCurrent ? metCacheDir :'), 'weather keeps the historic MET cache dir for the first page')

const rows = [{ date: '2026-09-12' }]
for (const pattern of [/id:\s*tempBig\b/, /model:\s*root\.dayRows/, /Data: MET Norway, Open-Meteo/, /id:\s*cityDots\b/, /id:\s*addCityButton\b/]) {
  const marker = findLine(pattern)
  assert(marker > 0, `weather page keeps ${pattern}`)
  assert(container.startLine < marker && marker < container.endLine, `weather keeps ${pattern} inside the page container`)
  assert(effectiveVisible(innermostContaining(blocks, marker), rows) === true, `weather keeps ${pattern} visible`)
}

const wheelLine = findLine(/WheelHandler/)
assert(wheelLine > 0, 'weather handles touchpad swipes')
const wheelBody = spanText(innermostContaining(blocks, wheelLine))
assert(/angleDelta\.y/.test(wheelBody), 'weather distinguishes horizontal swipes from vertical wheels')
assert(/stepPage|goToPage/.test(wheelBody), 'weather steps exactly one page per horizontal swipe')

const moveLine = findLine(/onMoveRequested/)
assert(moveLine > 0, 'weather handles key-catcher moves')
assert(/stepPage/.test(lines.slice(moveLine - 1, moveLine + 3).join('\n')), 'weather steps pages with the Left and Right arrow keys')

assert(!/#[0-9a-fA-F]{3,8}\b/.test(panelSource), 'weather adds no hard-coded colours')

// The Open-Meteo handler caches every arriving response for its page and
// only paints the visible one; a neighbour response refires the visible
// fetch instead of painting over it.
const dailyBody = spanText(handlerBlock('dailyForecastProc'))
const dailyLines = dailyBody.split('\n')
const tryLine = dailyLines.findIndex((l) => /\btry\s*\{/.test(l))
const cacheLine = dailyLines.findIndex((l) => /root\.cityDailyCache\[.*\]\s*=\s*parsed/.test(l))
assert(tryLine >= 0 && cacheLine > tryLine, 'weather caches the arriving Open-Meteo response for its page')
assert(!/\bif\b/.test(dailyLines.slice(tryLine, cacheLine).join('\n')), 'weather caches the Open-Meteo response unconditionally')
assert(dailyBody.includes('root.dailyRequestKey !== root.activeKey'), 'weather skips the paint for a neighbour response')
assert(dailyBody.includes('root.dailyForecastReport = parsed'), 'weather still paints the visible page')
assert(dailyBody.includes('refreshDailyForecastFor(root.activePage'), 'weather refires the visible fetch after a neighbour response')

// City saves go through the tested builder and never touch weather.json.
const persistLine = findLine(/function persistCities/)
assert(persistLine > 0, 'weather saves the city list through persistCities')
assert(lines.slice(persistLine - 1, persistLine + 6).join('\n').includes('citiesSaveScript'), 'weather builds city saves with the tested command string')
const saveBody = spanText(handlerBlock('citiesSaveProc'))
assert(saveBody.includes('console.warn'), 'weather logs a failed city save instead of failing silently')
assert(saveBody.includes('omarchy.weather'), 'weather tags the city save warning with the plugin id')
assert(saveBody.includes('citiesFile.reload()'), 'weather reverts to disk truth after a city save')

// The save builder creates the settings directory first, writes a temp file
// in the same directory, and moves it over the target.
const saveCmd = weather.citiesSaveCommand('[]', '/tmp/example/' + weather.CITIES_FILENAME)
assertEqual(saveCmd[0], 'sh', 'weather runs the city save through sh')
assert(saveCmd[2].includes('mkdir -p'), 'weather creates the settings directory before saving cities')
assert(saveCmd[2].includes('.tmp'), 'weather writes cities through a temp file')
assert(/&& mv /.test(saveCmd[2]), 'weather moves the temp file over the city list')
for (const value of ['Oslo', 'a b', '', '46.05,14.51', '[]']) {
  assertEqual(weather.shellQuote(value), "'" + value.split("'").join("'\\''") + "'", `weather shell-quotes ${JSON.stringify(value)}`)
}
JS

multicity_tmp=$(mktemp -d)
trap 'rm -rf "$multicity_tmp"' EXIT

cities_filename() {
  node -e 'process.stdout.write(require(process.env.ROOT + "/shell/plugins/panels/weather/Model.js").CITIES_FILENAME)'
}

city_subdir() {
  node -e 'const weather = require(process.env.ROOT + "/shell/plugins/panels/weather/Model.js"); process.stdout.write(weather.metCacheSubdir(process.argv[1], process.argv[2]))' "$1" "$2"
}

cities_save_script() {
  CITIES_JSON="$1" CITIES_PATH="$2" node -e 'const weather = require(process.env.ROOT + "/shell/plugins/panels/weather/Model.js"); process.stdout.write(weather.citiesSaveScript(process.env.CITIES_JSON, process.env.CITIES_PATH))'
}

check_cities() {
  CITIES_FILE="$1" EXPECTED="$2" node -e '
const fs = require("fs")
const weather = require(process.env.ROOT + "/shell/plugins/panels/weather/Model.js")
const actual = JSON.stringify(weather.parseCityList(fs.readFileSync(process.env.CITIES_FILE, "utf8")))
if (actual !== process.env.EXPECTED) {
  console.error("expected: " + process.env.EXPECTED + "\nactual:   " + actual)
  process.exit(1)
}
'
}

oslo_json='[{"name":"Oslo","latitude":59.91,"longitude":10.75}]'
oslo_tokyo_json='[{"name":"Oslo","latitude":59.91,"longitude":10.75},{"name":"Tokyo","latitude":35.68,"longitude":139.69}]'
tokyo_json='[{"name":"Tokyo","latitude":35.68,"longitude":139.69}]'

# ---- The real save script inside a temporary HOME whose settings directory
# does not exist yet: the shape that once lost cities on reopen. ----
cities_file="$multicity_tmp/.local/state/omarchy/settings/$(cities_filename)"
[[ ! -e "$(dirname "$cities_file")" ]] || fail "weather city save starts with no settings directory"
pass "weather city save starts with no settings directory"

output=$(cities_save_script "$oslo_json" "$cities_file" | sh 2>&1) || fail "weather city save creates a missing settings directory" "$output"
pass "weather city save creates a missing settings directory"
[[ -f $cities_file ]] || fail "weather city save writes the city list"
check_cities "$cities_file" "$oslo_json" || fail "weather city save round-trips through a reopen"
pass "weather city save survives a missing settings directory and reopens"

# A bare redirect into a missing directory fails: the old shape that lost cities.
bare_file="$multicity_tmp/bare/settings/$(cities_filename)"
if sh -c "printf '%s' '[]' > '$bare_file'" 2>/dev/null; then
  fail "weather bare redirect fails without the settings directory"
fi
[[ ! -e $bare_file ]] || fail "weather bare redirect writes nothing without the settings directory"
pass "weather bare redirect fails without the settings directory"

output=$(cities_save_script "$oslo_tokyo_json" "$cities_file" | sh 2>&1) || fail "weather city save overwrites the city list" "$output"
check_cities "$cities_file" "$oslo_tokyo_json" || fail "weather city save persists a second city"
output=$(cities_save_script "$tokyo_json" "$cities_file" | sh 2>&1) || fail "weather city save persists a removal" "$output"
check_cities "$cities_file" "$tokyo_json" || fail "weather city save persists a removal"
pass "weather city save persists overwrites and removals"

# A blocked settings path fails the save instead of pretending it worked.
touch "$multicity_tmp/blocker"
blocked_file="$multicity_tmp/blocker/settings/$(cities_filename)"
if cities_save_script "$oslo_json" "$blocked_file" | sh >/dev/null 2>&1; then
  fail "weather city save fails when the settings path is blocked"
fi
pass "weather city save fails when the settings path is blocked"

# ---- met-fetch.sh keeps two cities' caches separate (Oslo vs Tokyo). ----
oslo_sub=$(city_subdir 59.91 10.75)
tokyo_sub=$(city_subdir 35.68 139.69)
[[ $oslo_sub != "$tokyo_sub" ]] || fail "weather maps Oslo and Tokyo to separate cache subdirs"
pass "weather maps Oslo and Tokyo to separate cache subdirs"

oslo_dir="$multicity_tmp/$oslo_sub"
tokyo_dir="$multicity_tmp/$tokyo_sub"
seed_met_cache() {
  mkdir -p "$1"
  printf 'meta_lat="%s"\nmeta_lon="%s"\nlast_fetch="%s"\nexpires=""\nlast_modified=""\n' "$2" "$3" "$(date +%s)" >"$1/meta"
  printf '{"city":"%s"}' "$4" >"$1/body.json"
  printf 'HTTP/1.1 200 OK\n' >"$1/headers.txt"
}
seed_met_cache "$oslo_dir" "59.9100" "10.7500" "oslo"
seed_met_cache "$tokyo_dir" "35.6800" "139.6900" "tokyo"

output=$("$WEATHER_DIR/met-fetch.sh" "59.91" "10.75" "$oslo_dir" 2>/dev/null) || fail "weather MET fetcher serves the Oslo cache without fetching" "$output"
[[ $output == *'"status":"throttled"'* ]] || fail "weather MET fetcher reports the throttled Oslo cache" "$output"
[[ $(cat "$tokyo_dir/body.json") == '{"city":"tokyo"}' ]] || fail "weather MET fetcher leaves the Tokyo cache alone"
[[ $(cat "$oslo_dir/body.json") == '{"city":"oslo"}' ]] || fail "weather MET fetcher keeps the Oslo marker"
output=$("$WEATHER_DIR/met-fetch.sh" "35.68" "139.69" "$tokyo_dir" 2>/dev/null) || fail "weather MET fetcher serves the Tokyo cache without fetching" "$output"
[[ $(cat "$oslo_dir/body.json") == '{"city":"oslo"}' ]] || fail "weather MET fetcher keeps city caches separate"
pass "weather MET fetcher keeps city caches separate"
