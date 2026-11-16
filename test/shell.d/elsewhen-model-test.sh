#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const { execFileSync } = require('child_process')
const M = requireFromRoot('shell/plugins/panels/elsewhen/Model.js')

const probe = (ids, withLocal) => {
  const command = M.probeCommand(ids, withLocal)
  return execFileSync(command[0], command.slice(1), { encoding: 'utf8' })
}
const near = (a, b, eps) => Math.abs(a - b) <= (eps === undefined ? 1e-9 : eps)

// ---- the date probe

const zoneCommand = M.probeCommand(['Asia/Tokyo', 'Europe/Paris'])
assertDeepEqual(zoneCommand.slice(0, 2), ['bash', '-c'], 'elsewhen probe runs one bash')
assertDeepEqual(zoneCommand.slice(3), ['bash', 'Asia/Tokyo', 'Europe/Paris'], 'elsewhen probe passes zones as arguments, not script text')
assert(zoneCommand[2].indexOf('Asia/Tokyo') === -1, 'elsewhen probe script never contains a zone id')

const probed = M.parseProbe(probe(['Asia/Tokyo', 'Asia/Kathmandu', 'UTC']))
assertDeepEqual(probed['Asia/Tokyo'], { abbr: 'JST', offsetMinutes: 540 }, 'elsewhen probe reads Tokyo')
assertEqual(probed['Asia/Kathmandu'].offsetMinutes, 345, 'elsewhen probe reads a three-quarter-hour zone')
assertEqual(probed.UTC.offsetMinutes, 0, 'elsewhen probe reads UTC')

const local = probe(['Asia/Tokyo'], true)
const localZone = M.localZoneFromProbe(local)
assert(localZone !== '', 'elsewhen probe names the local zone')
assert(M.parseProbe(local)[localZone] !== undefined, 'elsewhen probe also gives the local zone an offset line')
assert(M.parseProbe(local)['Asia/Tokyo'] !== undefined, 'elsewhen local probe still probes the listed zones')
assertEqual(M.parseProbe(local).LOCAL, undefined, 'elsewhen LOCAL marker is not a zone')

assertEqual(M.parseOffset('-0700'), -420, 'elsewhen parses a negative offset')
assertEqual(M.parseOffset('+0545'), 345, 'elsewhen parses a positive offset')
assertEqual(M.parseOffset('0700'), null, 'elsewhen rejects an unsigned offset')
assertDeepEqual(M.parseProbe('Bad|X\nEurope/Paris|CET|nope\n\n'), {}, 'elsewhen ignores unparseable probe lines')

// ---- clocks

const at = Date.UTC(2026, 5, 21, 13, 5)
assertEqual(M.formatClock(at, 0, true), '13:05', 'elsewhen formats a 24-hour clock')
assertEqual(M.formatClock(at, 0, false), '1:05 PM', 'elsewhen formats a 12-hour clock')
assertEqual(M.formatClock(at, 540, false), '10:05 PM', 'elsewhen applies the zone offset')
assertEqual(M.formatClock(at, -13 * 60 - 5, true), '00:00', 'elsewhen pads midnight on a 24-hour clock')
assertEqual(M.formatClock(at, -13 * 60 - 5, false), '12:00 AM', 'elsewhen shows midnight as 12 AM')
assertEqual(M.formatClock(at, -60 - 5, false), '12:00 PM', 'elsewhen shows noon as 12 PM')
assertEqual(M.formatClock(at, -5 * 60, true), '08:05', 'elsewhen pads a morning hour')
assertEqual(M.formatClock(at, undefined, true), '', 'elsewhen shows nothing before the offset is known')

// ---- scrubbing

assertEqual(Math.round(M.scrubDeltaMinutes(0.5, 600)), 120, 'elsewhen scrubs forward')
assertEqual(Math.round(M.scrubDeltaMinutes(0.5, 840)), -120, 'elsewhen scrubs backward')
assertEqual(Math.round(M.scrubDeltaMinutes(0.0, 1380)), 60, 'elsewhen scrubs the short way round midnight')
assertEqual(Math.round(M.scrubDeltaMinutes(2, 720)), 720, 'elsewhen clamps a scrub past the right edge')
assertEqual(Math.round(M.scrubDeltaMinutes(-1, 720)), 720, 'elsewhen resolves a half-day scrub forward')
assertEqual(Math.round(M.scrubDeltaMinutes(1, 720)), 720, 'elsewhen resolves a half-day scrub forward from the other edge')
assertEqual(Math.round(M.scrubDeltaMinutes(600 / 1440, 600)), 0, 'elsewhen scrub at the current time is zero')
assertDeepEqual([M.formatScrubDelta(0), M.formatScrubDelta(45), M.formatScrubDelta(-90), M.formatScrubDelta(180)], ['', '+45m', '-1h 30m', '+3h'], 'elsewhen formats scrub deltas')
assertDeepEqual([M.formatScrubDelta(1440), M.formatScrubDelta(-2220), M.formatScrubDelta(1500)], ['+1d', '-1d 13h', '+1d 1h'], 'elsewhen formats scrub deltas past a day in days')

assertDeepEqual([M.formatMinuteOfDay(0, false), M.formatMinuteOfDay(13 * 60 + 5, false), M.formatMinuteOfDay(13 * 60, true)], ['12:00 AM', '1:05 PM', '13:00'], 'elsewhen formats minutes of the day')
assertEqual(M.formatMinuteOfDay(419.81, false), '7:00 AM', 'elsewhen rolls the hour when rounding seconds')
assertEqual(M.formatMinuteOfDay(419.81, true), '07:00', 'elsewhen rolls the hour on a 24-hour clock')
assertEqual(M.formatMinuteOfDay(419.5, false), '7:00 AM', 'elsewhen rounds half a minute up')
assertEqual(M.formatMinuteOfDay(419.49, false), '6:59 AM', 'elsewhen rounds under half a minute down')
assertEqual(M.formatMinuteOfDay(719.7, false), '12:00 PM', 'elsewhen rounds into noon')
assertEqual(M.formatMinuteOfDay(1439.7, false), '12:00 AM', 'elsewhen wraps the last minute of the day')
assertEqual(M.formatMinuteOfDay(1439.7, true), '00:00', 'elsewhen wraps the last minute on a 24-hour clock')
assertEqual(M.formatMinuteOfDay(375, false), '6:15 AM', 'elsewhen leaves whole minutes alone')

// ---- offset labels

assertDeepEqual(
  [0, 120, -300, 345, -210, 570, 840, -720, 65].map(M.utcOffsetLabel),
  ['UTC', 'UTC+2', 'UTC-5', 'UTC+5:45', 'UTC-3:30', 'UTC+9:30', 'UTC+14', 'UTC-12', 'UTC+1:05'],
  'elsewhen labels absolute offsets'
)
assertDeepEqual([undefined, null, NaN].map(M.utcOffsetLabel), ['', '', ''], 'elsewhen labels unknown offsets as nothing')

assertEqual(M.relativeOffsetLabel(540, 0), '+9h', 'elsewhen labels a zone ahead')
assertEqual(M.relativeOffsetLabel(-300, -120), '-3h', 'elsewhen labels a zone behind')
assertEqual(M.relativeOffsetLabel(345, 0), '+5.8h', 'elsewhen rounds quarter zones to a tenth')
assertEqual(M.relativeOffsetLabel(330, 0), '+5.5h', 'elsewhen keeps half-hour zones')
assertEqual(M.relativeOffsetLabel(570, 600), '-0.5h', 'elsewhen labels Adelaide from Sydney')
assertEqual(M.relativeOffsetLabel(-480, -480), '', 'elsewhen says nothing on your own offset')

// ---- editing and selection

const zones = M.parseZones('Paris|Europe/Paris, Tokyo|Asia/Tokyo, New York|America/New_York')
const labels = list => list.map(z => z.label).join(',')

assertEqual(M.parseZones('').length, 0, 'elsewhen treats a blank setting as a fresh install')
assertEqual(M.parseZones(undefined).length, 0, 'elsewhen treats an unset setting as a fresh install')
assertDeepEqual(M.parseZones('Europe/Rome'), [{ label: 'Rome', id: 'Europe/Rome' }], 'elsewhen labels a bare zone from its id')
assertEqual(M.labelForZoneId('America/Los_Angeles'), 'Los Angeles', 'elsewhen labels a zone id')

assertDeepEqual([0, 1, 2].map(i => M.indexOfZone(zones, zones[i].label, zones[i].id)), [0, 1, 2], 'elsewhen finds every row by label and zone')
assertEqual(M.indexOfZone(zones, 'Lagos', 'Africa/Lagos'), -1, 'elsewhen finds no row for an untracked globe city')
assertEqual(M.indexOfZone(zones, 'Tokyo', 'Asia/Osaka'), -1, 'elsewhen needs the zone to match')
assertEqual(M.indexOfZone(zones, 'Tokyo City', 'Asia/Tokyo'), -1, 'elsewhen needs the label to match')
assertEqual(M.indexOfZone(undefined, 'Paris', 'Europe/Paris'), -1, 'elsewhen tolerates a missing list')

const tokyoKey = M.factsKey(zones[1])
assertEqual(M.indexOfZoneKey(zones, tokyoKey), 1, 'elsewhen finds a focused city by key')
assertEqual(M.indexOfZoneKey(zones, ''), -1, 'elsewhen treats an empty key as no focus')
assertEqual(M.indexOfZoneKey(null, tokyoKey), -1, 'elsewhen tolerates a missing list for a key')
const moved = M.moveZone(zones, 0, 2)
assertEqual(moved[M.indexOfZoneKey(moved, tokyoKey)].label, 'Tokyo', 'elsewhen focus follows the city through a reorder')
assertEqual(M.indexOfZoneKey(M.removeZoneAt(zones, 0), tokyoKey), 0, 'elsewhen focus follows the city through a removal')
assertEqual(M.indexOfZoneKey(M.removeZoneAt(zones, 1), tokyoKey), -1, 'elsewhen drops focus when the city is removed')

const four = M.parseZones('A|X/a, B|X/b, C|X/c, D|X/d')
assertEqual(labels(M.moveZone(four, 0, 1)), 'B,A,C,D', 'elsewhen moves a row down one')
assertEqual(labels(M.moveZone(four, 0, 3)), 'B,C,D,A', 'elsewhen moves a row to the end')
assertEqual(labels(M.moveZone(four, 3, 0)), 'D,A,B,C', 'elsewhen moves a row to the front')
assert(M.moveZone(four, 2, 2) === four && M.moveZone(four, -1, 2) === four && M.moveZone(four, 0, 9) === four, 'elsewhen ignores no-op and out-of-range moves')
assertEqual(labels(four), 'A,B,C,D', 'elsewhen leaves the original list untouched')
assertEqual(M.removeZoneAt([zones[0]], 0).length, 1, 'elsewhen never removes the last city')
assertEqual(labels(M.removeZone(zones, 'Asia/Tokyo')), 'Paris,New York', 'elsewhen removes a city by zone')

const catalog = M.zoneOptions('America/Los_Angeles\nAsia/Tokyo', [])
const sharing = catalog.filter(o => o.value === 'America/Los_Angeles')
assert(sharing.length > 1 && new Set(sharing.map(o => o.label)).size === sharing.length, 'elsewhen offers several named cities for one zone')
assertEqual(M.addZone([], 'America/Los_Angeles', 'Oakland')[0].label, 'Oakland', 'elsewhen keeps the chosen city name')
assertEqual(M.addZone([], 'America/Los_Angeles', '')[0].label, 'Los Angeles', 'elsewhen falls back to the zone name')
assertEqual(M.addZone(M.addZone([], 'America/Los_Angeles', 'Oakland'), 'America/Los_Angeles', 'Las Vegas').length, 2, 'elsewhen tracks two cities in one zone')

const roundTrip = list => M.parseZones(M.serializeZones(list)).map(z => z.label + '@' + z.id)
assertDeepEqual(roundTrip(M.addZone([], 'Asia/Tokyo', 'Tokyo, Japan')), ['Tokyo Japan@Asia/Tokyo'], 'elsewhen keeps a comma out of the setting')
assertDeepEqual(roundTrip(M.addZone([], 'Asia/Tokyo', 'Tokyo|HQ')), ['Tokyo HQ@Asia/Tokyo'], 'elsewhen keeps a pipe out of the setting')
assertEqual(M.addZone([], 'Asia/Tokyo', ',|,')[0].label, 'Tokyo', 'elsewhen falls back when a label is only delimiters')
assertEqual(M.addZone([], 'evil id, with|pipe', 'x').length, 0, 'elsewhen refuses an id that cannot name a zone')
const unchanged = []
assert(M.addZone(unchanged, 'bad id', 'x') === unchanged, 'elsewhen returns the same list when refusing')
assertEqual(M.addZone([], 'Asia/Tokyo', '<img src=x>')[0].label, '<img src=x>', 'elsewhen keeps markup as plain text')
const remaining = M.zoneOptions('America/Los_Angeles', M.addZone([], 'America/Los_Angeles', 'Oakland'))
assert(!remaining.some(o => o.label === 'Oakland') && remaining.some(o => o.label === 'Las Vegas'), 'elsewhen drops only the tracked city from the picker')

const options = M.zoneOptions('Europe/Paris\nAmerica/Santiago\nAmerica/Argentina/Buenos_Aires', [])
assertEqual(M.searchZones(options, 'par', 6)[0].label, 'Paris', 'elsewhen ranks city-name prefixes first')
assert(M.searchZones(options, 'argentina', 6).some(o => o.label === 'Buenos Aires'), 'elsewhen searches zone ids too')

assertEqual(M.moveSelection(2, 1, 5), 3, 'elsewhen moves the selection down')
assertEqual(M.moveSelection(4, 1, 5), 0, 'elsewhen wraps the selection past the end')
assertEqual(M.moveSelection(0, -1, 5), 4, 'elsewhen wraps the selection past the start')
assertEqual(M.moveSelection(3, 1, 0), 0, 'elsewhen resets the selection in an empty list')


const home = ['Copenhagen', 'Europe/Copenhagen', 55.68, 12.57, 0]
const merged = M.mergeCities(
  home,
  [['copenhagen', 'Europe/Copenhagen', 55, 12, 1], ['Paris', 'Europe/Paris', 48.86, 2.35, 1], ['Nowhere', 'X/y', null, null, 2]],
  [['Paris', 'Europe/Paris', 1, 1, 0], ['Oakland', 'America/Los_Angeles', 37.8, -122.3, 0], ['Pending', 'Asia/Tokyo', null, null, 0]],
  [['Lagos', 'Africa/Lagos', 6.5, 3.4, 0], ['Unplaced', 'Asia/Dubai', undefined, undefined, 0]]
)
assertDeepEqual(merged.map(c => c[0]), ['Copenhagen', 'Paris', 'Nowhere', 'Oakland', 'Lagos'], 'elsewhen merges globe cities with home first and names deduplicated')
assertEqual(merged[1][2], 48.86, 'elsewhen keeps the first city of a name')
assertDeepEqual(M.mergeCities(['Home', 'X/y', undefined, undefined, 0], [['Paris', 'Europe/Paris', 1, 2, 1]], [], []).map(c => c[0]), ['Paris'], 'elsewhen leaves out a home without coordinates')
assertDeepEqual(M.mergeCities([], [], [], []), [], 'elsewhen merges nothing into nothing')

// ---- globe transition and row drag

assertEqual(M.knockAt(0, 0), 0, 'elsewhen rows start in place')
assertEqual(M.knockAt(0, 1), 1, 'elsewhen rows end fully knocked aside')
assertEqual(M.knockAt(2, 0.18), 0, 'elsewhen later rows wait their turn')
assertEqual(M.knockAt(10, 0.75), 0.5, 'elsewhen caps the stagger at half the zoom')
assertDeepEqual([M.knockX(0, 1, 95), M.knockX(1, 1, 95)], [-95, 95], 'elsewhen throws rows to alternating sides')
assertEqual(M.knockY(0, 0.5, 100), 25, 'elsewhen rows accelerate as they fall')
assertDeepEqual([M.knockTilt(0, 1), M.knockTilt(1, 1)], [-14, 14], 'elsewhen tilts rows to alternating sides')
assert(near(M.knockShrink(0, 1), 0.82), 'elsewhen shrinks knocked rows')

assertEqual(M.dragTargetFor(-1, 50, 40, -1, 4), -1, 'elsewhen has no drag target without a drag')
assertEqual(M.dragTargetFor(1, 50, 0, -1, 4), -1, 'elsewhen has no drag target before rows are measured')
assertEqual(M.dragTargetFor(1, 10, 40, -1, 4), 1, 'elsewhen holds the slot for a small drag')
assertEqual(M.dragTargetFor(1, 50, 40, -1, 4), 2, 'elsewhen moves the target past the threshold')
assertEqual(M.dragTargetFor(1, 60, 40, 3, 4), 3, 'elsewhen holds the target near a boundary')
assertEqual(M.dragTargetFor(1, 55, 40, 3, 4), 2, 'elsewhen moves the target back once clearly past')
assertEqual(M.dragTargetFor(0, 400, 40, -1, 4), 3, 'elsewhen clamps the target to the last row')
assertEqual(M.dragTargetFor(2, -400, 40, -1, 4), 0, 'elsewhen clamps the target to the first row')

assertDeepEqual([0, 1, 2, 3].map(i => M.rowShift(i, 1, 3, 70, 40)), [0, 70, -40, -40], 'elsewhen steps rows up under a downward drag')
assertDeepEqual([0, 1, 2, 3].map(i => M.rowShift(i, 3, 1, -70, 40)), [0, 40, 40, -70], 'elsewhen steps rows down under an upward drag')
assertDeepEqual([0, 1].map(i => M.rowShift(i, -1, -1, 0, 40)), [0, 0], 'elsewhen shifts nothing without a drag')

assertDeepEqual(M.mix({ r: 0, g: 0, b: 0 }, { r: 1, g: 0.5, b: 0.2 }, 0.5), { r: 0.5, g: 0.25, b: 0.1, a: 1 }, 'elsewhen mixes two colors opaquely')
assertDeepEqual(M.mix({ r: 0.2, g: 0.4, b: 0.6, a: 0.3 }, { r: 1, g: 1, b: 1 }, 0), { r: 0.2, g: 0.4, b: 0.6, a: 1 }, 'elsewhen mix at zero is the base color, opaque')

// ---- the strip's arrows and chips

const BAR = 567, BOX = 14, TUCK = 3, MARK = 10, SLACK = 4
assertEqual(M.arrowBox(0.26, BAR, BOX, TUCK, true), 136, 'elsewhen puts the sunrise arrow before the band')
assertEqual(M.arrowBox(0.81, BAR, BOX, TUCK, false), 456, 'elsewhen puts the sunset arrow after the band')
assert(M.arrowBox(0.26, BAR, BOX, TUCK, true) + BOX / 2 < 0.26 * BAR, 'elsewhen keeps the sunrise glyph before its crossing')
assert(M.arrowBox(0.81, BAR, BOX, TUCK, false) + BOX / 2 > 0.81 * BAR, 'elsewhen keeps the sunset glyph after its crossing')
assertEqual(M.arrowBox(0, BAR, BOX, TUCK, true), 0, 'elsewhen holds an arrow on the start of the bar')
assertEqual(M.arrowBox(1, BAR, BOX, TUCK, false), BAR - BOX, 'elsewhen holds an arrow on the end of the bar')
assertEqual(M.arrowCovered(136, BOX, 143, MARK, SLACK), true, 'elsewhen hides an arrow under the marker')
assertEqual(M.arrowCovered(136, BOX, 160, MARK, SLACK), false, 'elsewhen shows an arrow the marker has passed')

const SUNRISE = 0, SUNSET = 1
const click = (atPress, slot, tapFirst) => tapFirst
  ? M.chipAfterRelease(M.chipAfterTap(atPress, slot), atPress)
  : (M.chipAfterRelease(atPress, atPress), M.chipAfterTap(atPress, slot))
for (const tapFirst of [true, false]) {
  const order = tapFirst ? 'tap first' : 'release first'
  assertDeepEqual(
    [click(M.NO_CHIP, SUNRISE, tapFirst), click(SUNRISE, SUNRISE, tapFirst), click(SUNRISE, SUNSET, tapFirst), click(SUNSET, SUNRISE, tapFirst)],
    [SUNRISE, M.NO_CHIP, SUNSET, SUNRISE],
    `elsewhen chips open, close and swap (${order})`
  )
}
assertEqual(M.chipAfterRelease(SUNSET, SUNSET), M.NO_CHIP, 'elsewhen closes a chip on a click elsewhere')
assertEqual(M.chipAfterRelease(SUNRISE, M.NO_CHIP), SUNRISE, 'elsewhen keeps a chip opened during the same press')

// ---- weather and units

assertDeepEqual(
  [0, 1, 2, 3, 45, 48, 51, 57, 61, 67, 80, 82, 95, 99, 71, 77, 85, 86, '61'].map(M.weatherKind),
  ['sunny', 'sunny', 'partly', 'cloudy', 'cloudy', 'cloudy', 'rain', 'rain', 'rain', 'rain', 'rain', 'rain', 'rain', 'rain', 'snow', 'snow', 'snow', 'snow', 'rain'],
  'elsewhen collapses WMO codes to five kinds'
)
assertDeepEqual([null, undefined, '', 'rain', 7].map(M.weatherKind), ['', '', '', '', ''], 'elsewhen never turns a missing reading into a sun')
const kinds = ['', 'sunny', 'partly', 'cloudy', 'rain', 'snow']
assert([...Array(100).keys()].every(c => kinds.includes(M.weatherKind(c))), 'elsewhen maps every code 0..99 to a known kind')

assertDeepEqual(
  [M.resolveUnits('C', 'F'), M.resolveUnits('F', 'C'), M.resolveUnits('c', 'F'), M.resolveUnits('  f  ', 'C')],
  ['C', 'F', 'C', 'F'],
  'elsewhen honors an explicit temperature unit'
)
assertDeepEqual(
  [M.resolveUnits('', 'C'), M.resolveUnits('', 'F'), M.resolveUnits(undefined, 'C'), M.resolveUnits(null, 'F'), M.resolveUnits('kelvin', 'C'), M.resolveUnits('', 'wat')],
  ['C', 'F', 'C', 'F', 'C', 'C'],
  'elsewhen follows the system unit otherwise'
)
assertDeepEqual(
  [M.formatTemp(0, 'C'), M.formatTemp(0, 'F'), M.formatTemp(100, 'F'), M.formatTemp(37, 'F'), M.formatTemp(-17.8, 'F'), M.formatTemp(21.5, 'C'), M.formatTemp(null, 'C')],
  ['0°C', '32°F', '212°F', '99°F', '0°F', '22°C', ''],
  'elsewhen formats temperatures'
)
assertEqual(M.tempLabel({ c: 20 }, 'C'), '20°C', 'elsewhen labels a city temperature')
assertEqual(M.tempLabel(undefined, 'C'), '', 'elsewhen labels a missing temperature as nothing')

assertDeepEqual(
  ['h:mm AP', 'h:mm ap', "h'h'mm AP", 'AP h:mm', 'h:mm Ap'].map(M.usesTwentyFourHour),
  [false, false, false, false, false],
  'elsewhen reads a designator as a twelve-hour clock'
)
assertDeepEqual(
  ['HH:mm', 'HH:mm:ss', "H'h'mm", 'H:mm', 'H.mm', ''].map(M.usesTwentyFourHour),
  [true, true, true, true, true, true],
  'elsewhen reads no designator as a twenty-four-hour clock'
)
assertDeepEqual(
  [M.resolveHour24(true, false), M.resolveHour24(false, true), M.resolveHour24('true', false), M.resolveHour24('false', true), M.resolveHour24('24', false), M.resolveHour24('12', true)],
  [true, false, true, false, true, false],
  'elsewhen honors an explicit clock setting'
)
assertDeepEqual(
  [M.resolveHour24('', true), M.resolveHour24('', false), M.resolveHour24(undefined, true), M.resolveHour24(null, true), M.resolveHour24('maybe', true)],
  [true, false, true, true, true],
  'elsewhen follows the system clock otherwise'
)

// ---- first run

const HOMES = [
  'America/Los_Angeles', 'America/New_York', 'Europe/London', 'Europe/Paris',
  'Europe/Copenhagen', 'Asia/Tokyo', 'Asia/Kolkata', 'Australia/Sydney',
  'America/Sao_Paulo', 'Africa/Nairobi', 'Pacific/Honolulu', 'Pacific/Auckland',
  'Atlantic/Reykjavik', 'Asia/Kathmandu', 'UTC'
]
const probedOffsets = M.parseProbe(probe([...new Set(M.seedCandidateZones().concat(HOMES))]))
const offsets = {}
for (const id in probedOffsets) offsets[id] = probedOffsets[id].offsetMinutes
const dial = (a, b) => { const d = Math.abs(a - b) % 1440; return Math.min(d, 1440 - d) }
const known = new Set(M.SEED_CANDIDATES.map(c => c.label))

const seedProblems = []
for (const home of HOMES) {
  const list = M.seedZones({ label: M.labelForZoneId(home), id: home }, offsets, 4)
  const ids = list.map(z => z.id)
  const offs = ids.map(id => offsets[id])
  const east = offs.map(o => ((o - offs[0]) % 1440 + 1440) % 1440)
  let closest = 1e9
  for (let i = 1; i < offs.length; i++)
    for (let j = i + 1; j < offs.length; j++) closest = Math.min(closest, dial(offs[i], offs[j]))
  const round = M.parseZones(M.serializeZones(list))

  const checks = {
    'five cities': list.length === 5,
    'home first': ids[0] === home,
    'no repeated zone': new Set(ids).size === ids.length,
    'no repeated name': new Set(list.map(z => z.label.toLowerCase())).size === list.length,
    'three hours from home': offs.slice(1).every(o => dial(o, offs[0]) >= 180),
    'three hours apart': closest >= 180,
    'sorted eastward': east.slice(1).every((e, i) => i === 0 || e >= east[i]),
    'from the curated list': list.slice(1).every(z => known.has(z.label)),
    'round trips': round.length === 5 && round.every((z, i) => z.id === ids[i])
  }
  for (const name in checks) if (!checks[name]) seedProblems.push(`${home}: ${name}`)
}
assertDeepEqual(seedProblems, [], 'elsewhen seeds four well-spread cities around every home')
assertEqual(M.seedZones({ label: 'Nowhere', id: 'Not/AZone' }, offsets, 4).length, 1, 'elsewhen seeds only home when its offset is unknown')
assertEqual(M.pickSeedZones({ label: 'X', id: 'UTC' }, {}, 4).length, 0, 'elsewhen seeds nothing without offsets')

// ---- claiming home from the globe
const CHI = 'America/Chicago'
assertEqual(M.homeCityAfterTap('Nashville', CHI, '', CHI), 'Nashville', 'elsewhen makes a tapped city on this zone home')
assertEqual(M.homeCityAfterTap('Nashville', CHI, 'Nashville', CHI), null, 'elsewhen leaves home alone on a second tap')
assertEqual(M.homeCityAfterTap('Chicago', CHI, 'Nashville', CHI), '', 'elsewhen clears home when the zone\'s own city is tapped')
assertEqual(M.homeCityAfterTap('Chicago', CHI, '', CHI), null, 'elsewhen stores nothing for the zone\'s own city when none is set')
assertEqual(M.homeCityAfterTap('London', 'Europe/London', '', CHI), null, 'elsewhen never makes a city on another zone home')
assertEqual(M.homeCityAfterTap('Nashville', CHI, '', ''), null, 'elsewhen stores nothing before the machine zone is known')
assertEqual(M.homeCityAfterTap('  Nashville  ', CHI, '', CHI), 'Nashville', 'elsewhen trims a tapped name')

// ---- coordinates and weather
const tab = '#comment\nUS\t+404251-0740023\tAmerica/New_York\nIN\t+2232+08822\tAsia/Kolkata\n'
assertDeepEqual(M.zoneTabCoords(tab, 'America/New_York'), { lat: 40.7142, lon: -74.0064 }, 'elsewhen reads seconds-precision zone1970 coordinates')
assertDeepEqual(M.zoneTabCoords(tab, 'Asia/Kolkata'), { lat: 22.5333, lon: 88.3667 }, 'elsewhen reads minutes-precision zone1970 coordinates')
assertEqual(M.zoneTabCoords(tab, 'Nowhere/Else'), null, 'elsewhen has no fallback for an unknown zone')

const geocoded = JSON.stringify({ results: [
  { latitude: 34.0, longitude: -98.4, timezone: 'America/Chicago' },
  { latitude: 26.4, longitude: -80.1, timezone: 'America/New_York' }
] })
assertDeepEqual(M.pickGeocode(geocoded, 'America/New_York'), { place: { lat: 26.4, lon: -80.1 }, answered: true }, 'elsewhen prefers a geocode in the row\'s own zone')
assertDeepEqual(M.pickGeocode(geocoded, 'Asia/Tokyo'), { place: { lat: 34.0, lon: -98.4 }, answered: true }, 'elsewhen falls back to the top geocode')
assertDeepEqual(M.pickGeocode('{}', 'Asia/Tokyo'), { place: null, answered: true }, 'elsewhen treats no results as an answer')
assertDeepEqual(M.pickGeocode('', 'Asia/Tokyo'), { place: null, answered: false }, 'elsewhen treats a failed request as unanswered')
assert(M.geocodeUrl('São Paulo').endsWith('name=S%C3%A3o%20Paulo'), 'elsewhen URL-encodes the geocoded label')

assertEqual(M.forecastUrl([{ lat: 1, lon: 2 }, { lat: 3, lon: 4 }]).split('&').filter(p => /^l(at|ong)itude=/.test(p)).join('&'), 'latitude=1,3&longitude=2,4', 'elsewhen batches every point into one forecast')
assertDeepEqual(M.parseForecast('{"current":{"temperature_2m":14.33,"weather_code":3}}', ['a'], 5), { a: { c: 14.3, w: 3, at: 5 } }, 'elsewhen reads a single-point forecast')
assertDeepEqual(M.parseForecast('[{"current":{"temperature_2m":1,"weather_code":0}},{"current":{}}]', ['a', 'b'], 5), { a: { c: 1, w: 0, at: 5 } }, 'elsewhen skips points without a reading')
assertDeepEqual(M.parseForecast('', ['a'], 5), {}, 'elsewhen keeps nothing from a failed forecast')
assert(M.weatherStale(undefined, 0) && M.weatherStale({ at: 0 }, 20 * 60 * 1000) && !M.weatherStale({ at: 0 }, 60 * 1000), 'elsewhen refetches weather after twenty minutes')

assertDeepEqual(
  M.mergeFacts(['a', 'b', 'c'], { a: { lat: 1, lon: 2 }, b: null }, { a: { c: 3, w: 0, at: 9 }, b: { c: 4, w: null } }),
  { a: { lat: 1, lon: 2, c: 3, w: 0 }, b: { c: 4 }, c: {} },
  'elsewhen merges coordinates and weather, leaving out unknown fields'
)

// ---- the stored list
const NY = 'America/New_York'
const legacyList = M.parseCities(undefined, 'Paris|Europe/Paris, Asia/Tokyo')
assertDeepEqual(legacyList, [{ label: 'Paris', id: 'Europe/Paris' }, { label: 'Tokyo', id: 'Asia/Tokyo' }], 'elsewhen reads the older zones string until cities is written')
assertEqual(M.parseCities([], '').length, 0, 'elsewhen treats an empty cities list as a fresh install')
const stored = [
  { name: 'Fort Lauderdale', zone: NY, lat: 26.12, lon: -80.14, region: 'Florida, US' },
  { name: 'Cincinnati', zone: NY, people: ['Ann', '@octocat', 'ann'] },
  { name: 'Nowhere', zone: 'not a zone' },
  { name: 'Half', zone: 'Europe/Paris', lat: 48.8 },
  'junk'
]
const cities = M.parseCities(stored, 'Ignored|Asia/Tokyo')
assertDeepEqual(cities.map(c => c.label), ['Fort Lauderdale', 'Cincinnati', 'Half'], 'elsewhen keeps only cities on a real zone, and ignores the older string once cities is set')
assertDeepEqual(cities[0], { label: 'Fort Lauderdale', id: NY, lat: 26.12, lon: -80.14, region: 'Florida, US' }, 'elsewhen reads a city\'s coordinates and region')
assertEqual(cities[2].lat, undefined, 'elsewhen drops half a coordinate pair')
assertDeepEqual(cities[1].people, ['Ann', '@octocat'], 'elsewhen reads a city\'s people without repeats')
assertDeepEqual(M.parseCities(M.serializeCities(cities)), cities, 'elsewhen round-trips the cities list')
assertDeepEqual(M.serializeCities(legacyList), [{ name: 'Paris', zone: 'Europe/Paris' }, { name: 'Tokyo', zone: 'Asia/Tokyo' }], 'elsewhen writes a legacy list as cities')
assertDeepEqual(M.addZone([], NY, 'Fort Lauderdale', { lat: 26.12, lon: -80.14, region: 'Florida, US' }), [cities[0]], 'elsewhen adds a searched place with its coordinates')

// ---- place search
assertEqual(M.placeQuery('Fo'), '', 'elsewhen waits for three letters before asking the geocoder')
assertEqual(M.placeQuery('  Fort   Laud '), 'fort laud', 'elsewhen tidies a place query')
const portland = JSON.stringify({ results: [
  { name: 'Portland', latitude: 45.52, longitude: -122.68, timezone: 'America/Los_Angeles', admin1: 'Oregon', country_code: 'US' },
  { name: 'Portland', latitude: 43.66, longitude: -70.25, timezone: NY, admin1: 'Maine', country_code: 'US' },
  { name: 'Portland', latitude: 43.66, longitude: -70.25, timezone: NY, admin1: 'Maine', country_code: 'US' },
  { name: 'Singapore', latitude: 1.29, longitude: 103.85, timezone: 'Asia/Singapore', admin1: 'Singapore', country_code: 'SG' },
  { name: 'Nowhere', latitude: 1, longitude: 2 },
  { name: 'Floating', timezone: 'Europe/Paris' }
] })
const places = M.placeOptions(portland)
assertDeepEqual(places.map(p => p.label + ' / ' + p.region), ['Portland / Oregon, US', 'Portland / Maine, US', 'Singapore / SG'], 'elsewhen lists geocoded places once, with a region that does not repeat the name')
assertDeepEqual(places[1], { value: NY, label: 'Portland', lat: 43.66, lon: -70.25, region: 'Maine, US' }, 'elsewhen carries a place\'s zone and coordinates')
assertDeepEqual(M.placeOptions('not json'), [], 'elsewhen offers no places from a failed lookup')

const offlinePortland = [{ value: 'America/Los_Angeles', label: 'Portland', description: 'America/Los_Angeles' }]
const mergedPlaces = M.mergePlaces(offlinePortland, places, [], 10)
assertEqual(mergedPlaces.length, 3, 'elsewhen does not list an offline city twice when the geocoder finds it too')
assertEqual(mergedPlaces[0].region, 'Oregon, US', 'elsewhen gives an offline city the geocoder\'s region')
assertEqual(mergedPlaces[0].description, 'America/Los_Angeles', 'elsewhen keeps the offline match first')
assertEqual(M.mergePlaces([], places, [{ label: 'Portland', id: NY }], 10).length, 2, 'elsewhen leaves out places already on the list')
assertEqual(M.mergePlaces(offlinePortland, places, [], 2).length, 2, 'elsewhen caps the merged results')

// ---- here
assertEqual(M.resolveHere(null, '', ''), null, 'elsewhen has no here before the machine zone is known')
assertDeepEqual(M.resolveHere(null, '', NY), { label: 'New York', id: NY, chosen: false }, 'elsewhen guesses here from the zone')
assertDeepEqual(M.resolveHere(null, 'Boca Raton', NY), { label: 'Boca Raton', id: NY, chosen: true }, 'elsewhen still reads the older homeCity')
const fll = { name: 'Fort Lauderdale', zone: NY, lat: 26.12, lon: -80.14 }
assertDeepEqual(M.resolveHere(fll, 'Boca Raton', NY), { label: 'Fort Lauderdale', id: NY, chosen: true, lat: 26.12, lon: -80.14 }, 'elsewhen prefers a chosen place to the older homeCity')
assertDeepEqual(M.resolveHere(fll, '', CHI), { label: 'Chicago', id: CHI, chosen: false }, 'elsewhen sets a chosen place aside while the machine is on another zone')

const seeded = [{ label: 'New York', id: NY }, { label: 'Amsterdam', id: 'Europe/Amsterdam', people: ['Emir'] }]
const guess = M.resolveHere(null, '', NY)
const hereMoved = M.hereAfterPick(seeded, guess, { label: 'Fort Lauderdale', id: NY, lat: 26.12, lon: -80.14, region: 'Florida, US' }, NY)
assertDeepEqual(hereMoved.here, { name: 'Fort Lauderdale', zone: NY, lat: 26.12, lon: -80.14, region: 'Florida, US' }, 'elsewhen stores the picked place as here')
assertDeepEqual(hereMoved.zones[0], { label: 'Fort Lauderdale', id: NY, lat: 26.12, lon: -80.14, region: 'Florida, US' }, 'elsewhen renames the row that stood for here')
assertEqual(hereMoved.zones[1], seeded[1], 'elsewhen leaves the other rows alone')
assertEqual(hereMoved.zoneChange, '', 'elsewhen leaves the clock alone for a place on its own zone')
const away = M.hereAfterPick(seeded, guess, { label: 'Nashville', id: CHI, lat: 36.17, lon: -86.78 }, NY)
assertEqual(away.zoneChange, CHI, 'elsewhen moves the clock for a place on another zone')
assertDeepEqual(away.here, { name: 'Nashville', zone: CHI, lat: 36.17, lon: -86.78 }, 'elsewhen stores a place on another zone as here')
assertEqual(away.zones, seeded, 'elsewhen keeps home on the list while you are away from it')
assertEqual(M.hereAfterPick(seeded, guess, { label: 'Chicago', id: CHI }, NY).here, null, 'elsewhen stores nothing for another zone\'s own city')
assertEqual(M.hereAfterPick(seeded, guess, { label: 'Nowhere', id: '$(rm -rf)' }, NY), null, 'elsewhen never moves the clock to something that is not a zone')
assertEqual(M.hereAfterPick(seeded, null, { label: 'Miami', id: NY }, ''), null, 'elsewhen moves nothing before the machine zone is known')
const tzArgs = M.timezoneCommand(CHI)
assertDeepEqual(tzArgs.slice(3), ['bash', CHI], 'elsewhen passes the new zone as an argument')
assert(tzArgs[2].indexOf(CHI) === -1 && tzArgs[2].indexOf('sudo -n timedatectl set-timezone "$1"') >= 0, 'elsewhen moves the clock through the passwordless timedatectl rule, never prompting')
const withPeople = [{ label: 'New York', id: NY, people: ['Ann'] }]
assertDeepEqual(M.hereAfterPick(withPeople, guess, { label: 'Miami', id: NY }, NY).zones[0].people, ['Ann'], 'elsewhen keeps the people on a renamed here row')
const back = M.hereAfterPick(hereMoved.zones, M.resolveHere(hereMoved.here, '', NY), { label: 'New York', id: NY }, NY)
assertEqual(back.here, null, 'elsewhen goes back to the zone\'s own city rather than storing it')
assertDeepEqual(back.zones[0], { label: 'New York', id: NY }, 'elsewhen drops the old coordinates with the old name')
const both = [{ label: 'New York', id: NY }, { label: 'Miami', id: NY }]
assertEqual(M.hereAfterPick(both, guess, { label: 'Miami', id: NY }, NY).zones, both, 'elsewhen does not rename a row into a city already on the list')
assertEqual(M.hereAfterPick([{ label: 'Tokyo', id: 'Asia/Tokyo' }], guess, { label: 'Miami', id: NY }, NY).zones.length, 1, 'elsewhen adds no row when none stood for here')

// ---- people
assertDeepEqual(M.parsePeople(' Emir , @sarah-dev, emir,, @, @not_a_handle!, Ann  Lee '), ['Emir', '@sarah-dev', 'not_a_handle!', 'Ann Lee'], 'elsewhen reads names and handles from a typed list')
assertEqual(M.parsePeople(Array.from({ length: 20 }, (_, i) => 'P' + i).join(',')).length, 12, 'elsewhen caps the people in one city')
assertEqual(M.peopleText(['Emir', '@octocat']), 'Emir, @octocat', 'elsewhen writes people back as one line')
assertEqual(M.personHandle('@OctoCat'), 'octocat', 'elsewhen reads a handle case-insensitively')
assertEqual(M.personHandle('Emir'), '', 'elsewhen treats a plain name as no handle')
assertEqual(M.personHandle('@../etc'), '', 'elsewhen never takes a path for a handle')
assertEqual(M.personName('@octocat', {}), 'octocat', 'elsewhen shows a handle bare before its profile lands')
assertEqual(M.personName('@octocat', { octocat: { login: 'octocat', name: 'The Octocat' } }), 'The Octocat', 'elsewhen shows a profile\'s name')
assertEqual(M.personName('@octocat', { octocat: { login: 'OctoCat', name: '' } }), 'OctoCat', 'elsewhen falls back to the profile\'s login')
assertEqual(M.initialOf('  émile'), 'É', 'elsewhen takes the first letter for a monogram')
assertEqual(M.initialOf('😀 smile'), '😀', 'elsewhen keeps a surrogate pair whole')
assertDeepEqual(M.handlesIn([{ people: ['@A', 'b'] }, { people: ['@a', '@c'] }, {}]), ['a', 'c'], 'elsewhen fetches each handle once')

const peopleRows = [{ label: 'Cincinnati', id: NY }, { label: 'Paris', id: 'Europe/Paris', people: ['Ann'] }]
assertDeepEqual(M.setPeopleAt(peopleRows, 0, ['Ann', '@octocat'])[0], { label: 'Cincinnati', id: NY, people: ['Ann', '@octocat'] }, 'elsewhen adds people to a city')
assertEqual(M.setPeopleAt(peopleRows, 1, ['Ann']), peopleRows, 'elsewhen skips a write when the people are unchanged')
assertDeepEqual(M.setPeopleAt(peopleRows, 1, [])[1], { label: 'Paris', id: 'Europe/Paris' }, 'elsewhen clears a city\'s people')
assertEqual(M.setPeopleAt(peopleRows, 5, ['Ann']), peopleRows, 'elsewhen ignores a row that is not there')

const profileArgs = M.profilesCommand(['octocat', '../etc', 'a b'])
assertDeepEqual(profileArgs.slice(3), ['bash', 'octocat'], 'elsewhen passes only valid handles, as arguments')
assert(profileArgs[2].indexOf('octocat') === -1, 'elsewhen profile script never contains a handle')
assertDeepEqual(
  M.parseProfiles('{"handle":"octocat","login":"octocat","name":"The Octocat","avatar":"/c/octocat.avatar"}\nnoise\n{"handle":"../x","login":"x"}\n'),
  { octocat: { login: 'octocat', name: 'The Octocat', avatar: '/c/octocat.avatar' } },
  'elsewhen reads cached profiles and drops anything that is not one'
)

// ---- reordering rows of different heights
assertEqual(M.dragTargetFor(0, 70, 40, -1, 4, [40, 60, 40, 40]), 1, 'elsewhen measures a taller row by its own height')
assertEqual(M.dragTargetFor(0, 100, 40, -1, 4, [40, 60, 40, 40]), 2, 'elsewhen passes a taller row and the next')
assertEqual(M.dragTargetFor(3, -50, 40, -1, 4, [40, 60, 40, 40]), 2, 'elsewhen measures an upward drag the same way')
assertEqual(M.dropOffset(0, 2, 40, [40, 60, 40, 40]), 100, 'elsewhen drops a row past the heights it passed')
assertEqual(M.dropOffset(3, 1, 40, [40, 60, 50, 40]), -110, 'elsewhen drops a row upward past the heights it passed')
assertEqual(M.dropOffset(1, 1, 40, [40, 60]), 0, 'elsewhen drops a row in place')
// ---- untrusted answers
assertDeepEqual(M.placeOptions(JSON.stringify({ results: { length: 1e300 } })), [], 'elsewhen ignores geocoder results that are not a list, rather than looping on them')
assertDeepEqual(M.pickGeocode(JSON.stringify({ results: { length: 1e300 } }), NY), { place: null, answered: true }, 'elsewhen reads no geocode from results that are not a list')
assertDeepEqual(M.pickGeocode('{"results":[null, 7]}', NY), { place: null, answered: true }, 'elsewhen skips geocode entries that are not places')
assertEqual(M.placeOptions(JSON.stringify({ results: Array.from({ length: 50 }, (_, i) => ({ name: 'P' + i, latitude: 1, longitude: 2, timezone: 'Europe/Paris' })) })).length, 10, 'elsewhen reads no more geocoder results than it asked for')

const profileScript = M.profilesCommand(['octocat'])[2]
assert(profileScript.indexOf('avatar_url') === -1, 'elsewhen never fetches a URL named by the GitHub API')
assert(profileScript.indexOf('https://avatars.githubusercontent.com/u/$id?s=96') >= 0 && profileScript.indexOf('[[ $id =~ ^[0-9]+$ ]]') >= 0, 'elsewhen fetches the avatar from GitHub\'s own host by numeric id')
assert(profileScript.indexOf('--proto =https --proto-redir =https --globoff') >= 0, 'elsewhen lets curl speak only HTTPS, redirects included')
assert(profileScript.indexOf('mktemp "$dir/') >= 0 && profileScript.indexOf('.tmp') === -1, 'elsewhen downloads into fresh temporary files, never predictable ones')
assert(profileScript.indexOf('chmod 700 "$dir"') >= 0, 'elsewhen keeps the people cache private')
assert(profileScript.indexOf('flock -w 30 9') >= 0, 'elsewhen refreshes each handle under a lock, as every monitor has a panel')
assert(profileScript.indexOf('[[ ! -s $img ]]') >= 0, 'elsewhen retries a missing avatar without waiting for the profile to age')

// ---- towns that share a name and a zone
const springfields = [
  { value: CHI, label: 'Springfield', lat: 39.8, lon: -89.65, region: 'Illinois, US' },
  { value: CHI, label: 'Springfield', lat: 37.21, lon: -93.29, region: 'Missouri, US' }
]
assertDeepEqual(M.mergePlaces([], springfields, [], 10).map(p => p.region), ['Illinois, US', 'Missouri, US'], 'elsewhen lists two towns of one name and zone separately')
const offlineSpringfield = [{ value: CHI, label: 'Springfield', description: CHI }]
assertDeepEqual(M.mergePlaces(offlineSpringfield, springfields, [], 10).map(p => p.region), ['Illinois, US', 'Missouri, US'], 'elsewhen lends an offline city only the first matching place')
let twoSpringfields = M.addZone([], CHI, 'Springfield', springfields[0])
twoSpringfields = M.addZone(twoSpringfields, CHI, 'Springfield', springfields[1])
assertDeepEqual(twoSpringfields.map(r => r.label), ['Springfield', 'Springfield (Missouri)'], 'elsewhen names a second town of one name and zone by its region')
assertEqual(M.addZone(twoSpringfields, CHI, 'Springfield', springfields[1]), twoSpringfields, 'elsewhen does not add the same town twice')
assertEqual(M.regionalName('Springfield', 'Missouri, US'), 'Springfield (Missouri)', 'elsewhen names a second town by the first part of its region')
assertEqual(M.regionalName('Springfield', ''), 'Springfield', 'elsewhen keeps the name when there is no region to add')
assertEqual(M.addZone([{ label: 'Springfield', id: CHI, lat: 39.8, lon: -89.65 }], CHI, 'Springfield', { lat: 37.21, lon: -93.29 }).length, 1, 'elsewhen cannot tell a second town apart without a region, so does not add it under the same name')
assert(M.nearPlace({ lat: 39.8, lon: -89.65 }, { lat: 39.805, lon: -89.655 }) && !M.nearPlace({ lat: 39.8, lon: -89.65 }, { lat: 37.21, lon: -93.29 }), 'elsewhen treats points within about a kilometre as one place')
assertEqual(M.mergePlaces([], springfields, twoSpringfields, 10).length, 0, 'elsewhen knows a tracked town by where it is')
assertEqual(M.mergePlaces([], springfields, [{ label: 'Springfield', id: CHI }], 10).length, 0, 'elsewhen takes a row with no coordinates to be the town of its name')

// ---- weather follows the coordinates
const reading = M.parseForecast('{"current":{"temperature_2m":20,"weather_code":0}}', ['a'], 0, [{ lat: 40.71, lon: -74.01 }]).a
assertDeepEqual(reading, { c: 20, w: 0, at: 0, lat: 40.71, lon: -74.01 }, 'elsewhen remembers where a reading was taken')
assert(!M.weatherStale(reading, 60 * 1000, { lat: 40.71, lon: -74.01 }), 'elsewhen keeps a fresh reading for the same place')
assert(M.weatherStale(reading, 60 * 1000, { lat: 26.12, lon: -80.14 }), 'elsewhen refetches weather when a city\'s coordinates move')
assert(!M.weatherStale({ c: 1, at: 0 }, 60 * 1000, { lat: 26.12, lon: -80.14 }), 'elsewhen keeps an older reading that never said where it was')
JS
