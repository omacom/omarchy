#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const model = requireFromRoot('shell/plugins/panels/elsewhen/Model.js')

// Regional and country link zones resolve to their canonical zone's city name
// instead of literal last segments like "Central" or "Eastern".
assertDeepEqual(
  model.resolveHere(null, '', 'US/Central'),
  { label: 'Chicago', id: 'US/Central', chosen: false },
  'resolveHere uses Chicago as the default city for US/Central'
)
assertDeepEqual(
  model.resolveHere(null, '', 'US/Eastern'),
  { label: 'New York', id: 'US/Eastern', chosen: false },
  'resolveHere uses New York for US/Eastern'
)
assertDeepEqual(
  model.resolveHere(null, '', 'Canada/Central'),
  { label: 'Winnipeg', id: 'Canada/Central', chosen: false },
  'resolveHere uses Winnipeg for Canada/Central'
)
assertDeepEqual(
  model.resolveHere(null, '', 'GB'),
  { label: 'London', id: 'GB', chosen: false },
  'resolveHere uses London for single-token GB'
)
assertDeepEqual(
  model.resolveHere(null, '', 'CST6CDT'),
  { label: 'Chicago', id: 'CST6CDT', chosen: false },
  'resolveHere uses Chicago for CST6CDT'
)
assertDeepEqual(
  model.resolveHere(null, '', 'America/Chicago'),
  { label: 'Chicago', id: 'America/Chicago', chosen: false },
  'resolveHere keeps canonical zone city names'
)
assertDeepEqual(
  model.resolveHere({ name: 'Austin', zone: 'US/Central', lat: 30.267, lon: -97.743 }, '', 'US/Central'),
  { label: 'Austin', id: 'US/Central', chosen: true, lat: 30.267, lon: -97.743 },
  'resolveHere preserves an explicit chosen home under a regional zone'
)

// Tapping or picking the zone's canonical default city clears a custom home.
assertEqual(
  model.homeCityAfterTap('Chicago', 'US/Central', 'Austin', 'US/Central'),
  '',
  'homeCityAfterTap clears override when tapping Chicago under US/Central'
)
assertDeepEqual(
  model.hereAfterPick(
    [{ label: 'Austin', id: 'US/Central' }],
    { label: 'Austin', id: 'US/Central', chosen: true },
    { label: 'Chicago', id: 'US/Central' },
    'US/Central'
  ),
  { here: null, zones: [{ label: 'Chicago', id: 'US/Central' }], zoneChange: '' },
  'hereAfterPick clears here when resetting US/Central back to Chicago'
)
assertDeepEqual(
  model.hereAfterPick(
    [{ label: 'Central', id: 'US/Central', people: ['@alex'] }],
    { label: 'Chicago', id: 'US/Central', chosen: false },
    { label: 'Austin', id: 'US/Central', lat: 30.267, lon: -97.743 },
    'US/Central'
  ),
  {
    here: { name: 'Austin', zone: 'US/Central', lat: 30.267, lon: -97.743 },
    zones: [{ label: 'Austin', id: 'US/Central', people: ['@alex'], lat: 30.267, lon: -97.743 }],
    zoneChange: ''
  },
  'hereAfterPick reconciles legacy saved Central row when default is unchosen'
)
assertDeepEqual(
  model.hereAfterPick(
    [{ label: 'Central', id: 'US/Central' }],
    { label: 'Dallas', id: 'US/Central', chosen: true },
    { label: 'Austin', id: 'US/Central' },
    'US/Central'
  ),
  {
    here: { name: 'Austin', zone: 'US/Central' },
    zones: [{ label: 'Central', id: 'US/Central' }],
    zoneChange: ''
  },
  'hereAfterPick preserves a custom Central row when another home city was chosen'
)

// pickGeocode must never fall back to results[0] from another continent.
const centralHits = JSON.stringify({
  results: [
    { name: 'Central Coast', latitude: -33.42979, longitude: 151.37144, timezone: 'Australia/Sydney' },
    { name: 'Centralniy', latitude: 59.93, longitude: 30.36, timezone: 'Europe/Moscow' }
  ]
})
assertDeepEqual(
  model.pickGeocode(centralHits, 'US/Central'),
  { place: null, answered: true },
  'pickGeocode rejects wrong-continent results for US/Central'
)

const chicagoHits = JSON.stringify({
  results: [
    { name: 'Chicago', latitude: 41.85003, longitude: -87.65005, timezone: 'America/Chicago' }
  ]
})
assertDeepEqual(
  model.pickGeocode(chicagoHits, 'US/Central'),
  { place: { lat: 41.85003, lon: -87.65005 }, answered: true },
  'pickGeocode matches canonical America/Chicago results for US/Central'
)

const calcuttaHits = JSON.stringify({
  results: [
    { name: 'Calcutta', latitude: -24.98, longitude: 31.23, timezone: 'Africa/Johannesburg' },
    { name: 'Calcutta', latitude: 40.67, longitude: -80.58, timezone: 'America/New_York' }
  ]
})
assertDeepEqual(
  model.pickGeocode(calcuttaHits, 'Asia/Calcutta'),
  { place: null, answered: true },
  'pickGeocode rejects wrong-continent results for Asia/Calcutta'
)

// zoneTabCoords resolves pure-rename legacy/regional zones to canonical entries
// in zone1970.tab while leaving cross-place and distinct-city links unplaced.
const sampleZoneTab = [
  '# comment',
  'US\t+415100-0873900\tAmerica/Chicago\tCentral (most areas)',
  'IN\t+223200+0882200\tAsia/Kolkata\t',
  'AU\t-335200+1511300\tAustralia/Sydney\t',
  'GB\t+513030-0000731\tEurope/London\t',
  'IL\t+314650+0351326\tAsia/Jerusalem\t',
  'PG\t-093000+1471000\tPacific/Port_Moresby\t'
].join('\n')

assertDeepEqual(
  model.zoneTabCoords(sampleZoneTab, 'US/Central'),
  { lat: 41.85, lon: -87.65 },
  'zoneTabCoords resolves US/Central via America/Chicago'
)
assertDeepEqual(
  model.zoneTabCoords(sampleZoneTab, 'Asia/Calcutta'),
  { lat: 22.5333, lon: 88.3667 },
  'zoneTabCoords resolves Asia/Calcutta via Asia/Kolkata'
)
assertEqual(
  model.zoneTabCoords(sampleZoneTab, 'Pacific/Truk'),
  null,
  'zoneTabCoords does not map cross-place links onto another country'
)
assertEqual(
  model.zoneTabCoords(sampleZoneTab, 'Australia/Canberra'),
  null,
  'zoneTabCoords does not place Canberra at Sydney coordinates offline'
)
assertEqual(
  model.zoneTabCoords(sampleZoneTab, 'Europe/Belfast'),
  null,
  'zoneTabCoords does not place Belfast at London coordinates offline'
)
assertEqual(
  model.zoneTabCoords(sampleZoneTab, 'Asia/Tel_Aviv'),
  null,
  'zoneTabCoords does not place Tel Aviv at Jerusalem coordinates offline'
)

const canberraHits = JSON.stringify({
  results: [
    { name: 'Canberra', latitude: -35.28346, longitude: 149.12807, timezone: 'Australia/Sydney' }
  ]
})
assertDeepEqual(
  model.pickGeocode(canberraHits, 'Australia/Canberra'),
  { place: { lat: -35.28346, lon: 149.12807 }, answered: true },
  'pickGeocode still accepts geocoded Canberra results carrying Australia/Sydney'
)

assertEqual(model.isPlaceZone('US/Central'), true, 'isPlaceZone allows regional place zones')
assertEqual(model.isPlaceZone('Etc/GMT+6'), false, 'isPlaceZone skips Etc/ offset zones')
assertEqual(model.isPlaceZone('UTC'), false, 'isPlaceZone skips bare UTC')

// First-run seeding from US/Central names home Chicago and avoids duplicating America/Chicago.
const here = model.resolveHere(null, '', 'US/Central')
const offsets = {
  'US/Central': -360,
  'America/Chicago': -360,
  'America/New_York': -300,
  'Europe/London': 0,
  'Asia/Dubai': 240,
  'Asia/Tokyo': 540
}
const seeded = model.seedZones(here, offsets, 4)
assertEqual(seeded[0].label, 'Chicago', 'seedZones uses Chicago as the first city for US/Central')
assertEqual(seeded[0].id, 'US/Central', 'seedZones keeps the system US/Central id')
assert(
  seeded.slice(1).every(z => z.label !== 'Chicago'),
  'seedZones does not add a duplicate Chicago entry'
)
JS
