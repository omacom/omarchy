#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test "tray model helpers" <<'JS'
const tray = requireFromRoot('shell/plugins/bar/widgets/TrayModel.js')

assert(tray.itemNamed({ id: 'dropbox-client' }, 'dropbox'), 'tray matches item ids')
assert(tray.itemNamed({ title: 'Dropbox' }, 'dropbox'), 'tray matches item titles')
assert(tray.itemNamed({ tooltipTitle: 'LocalSend' }, 'localsend'), 'tray matches item tooltips')
assert(!tray.itemNamed({ id: 'nextcloud' }, 'dropbox'), 'tray ignores items named for something else')

const layout = {
  left: [{ id: 'omarchy.menu' }],
  center: [],
  right: [{ id: 'omarchy.dropbox' }, { id: 'omarchy.tray' }]
}

assert(tray.layoutHasWidget(layout, 'omarchy.dropbox'), 'tray finds dedicated dropbox widget in layout')
assert(tray.ownedByOmarchy({ id: 'dropbox' }, layout), 'tray suppresses dropbox when dedicated widget is in bar')
assert(!tray.ownedByOmarchy({ id: 'dropbox' }, { left: [], center: [], right: [] }), 'tray keeps dropbox when dedicated widget is absent')
assert(tray.ownedByOmarchy({ id: 'qlBCprNUqU', title: 'localsend' }, { left: [], center: [], right: [] }), 'tray suppresses localsend regardless of layout')
assert(!tray.ownedByOmarchy({ id: 'nextcloud' }, layout), 'tray keeps unrelated tray items')
assert(tray.ownedByOmarchy({ id: 'superwhisper' }, { left: [], center: [], right: [{ id: 'superwhisper.panel' }] }), 'tray suppresses superwhisper when its panel widget is in bar')
assert(!tray.ownedByOmarchy({ id: 'superwhisper' }, { left: [], center: [], right: [] }), 'tray keeps superwhisper when its panel widget is absent')
assert(tray.ownedByOmarchy({ id: 'dropbox' }, { left: [], center: [], right: [{ id: 'omarchy.tray' }], tray: [{ id: 'omarchy.dropbox' }] }), 'tray suppresses dropbox when its widget is in the tray section')

// The bar outlines as much of the tray section as the sliding drawer shows,
// never past the drawer.
assertDeepEqual(tray.shownSpan(0, 100, 20, 30), { start: 20, length: 30 }, 'a section inside the open drawer shows whole')
assertDeepEqual(tray.shownSpan(0, 40, 20, 30), { start: 20, length: 20 }, 'a section past the drawer\'s far edge is cut there')
assertDeepEqual(tray.shownSpan(10, 100, 0, 30), { start: 10, length: 20 }, 'a section sliding in from behind the drawer\'s near edge is cut there')
assertEqual(tray.shownSpan(0, 10, 50, 30), null, 'a section still outside the drawer shows nothing')
assertDeepEqual(tray.shownSpan(0, 50, 50.5, 0), { start: 50, length: 0 }, 'an empty section shows on the drawer\'s edge once within a pixel of it')
assertEqual(tray.shownSpan(0, 50, 52, 0), null, 'an empty section further out shows nothing')

// An icon on neither list goes where the tray's `unlisted` setting says.
assertEqual(tray.placement(false, false, undefined), 'drawer', 'an unlisted icon goes to the drawer by default')
assertEqual(tray.placement(false, false, 'visible'), 'pinned', 'an unlisted icon stays in the bar when unlisted is visible')
assertEqual(tray.placement(false, false, 'bar'), 'drawer', 'an unknown unlisted value means the drawer')
assertEqual(tray.placement(true, true, 'visible'), 'hidden', 'a hidden icon stays hidden whatever the setting')

// The chevron shows while the drawer has something in it, and while it is
// the only way left into the manager.
assert(!tray.showsChevron(0, 0, false, 3, 3), 'no chevron while every icon is in the bar and the drawer is empty')
assert(tray.showsChevron(1, 0, false, 2, 3), 'the chevron shows for icons in the drawer')
assert(tray.showsChevron(0, 1, false, 3, 3), 'the chevron shows for widgets in the tray section')
assert(tray.showsChevron(0, 0, true, 3, 3), 'the chevron shows during a widget drag')
assert(tray.showsChevron(0, 0, false, 0, 2), 'the chevron shows while every icon is hidden, to reach the manager')

// A pin or hide rewrites the whole entry, so it keeps the other settings.
assertDeepEqual(tray.trayEntry({ id: 'omarchy.tray', unlisted: 'visible', pinned: ['a'] }, ['a', 'b'], ['c']), { id: 'omarchy.tray', unlisted: 'visible', pinned: ['a', 'b'], hidden: ['c'] }, 'a pin or hide keeps the tray\'s other settings')
JS
