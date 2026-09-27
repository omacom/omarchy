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
JS
