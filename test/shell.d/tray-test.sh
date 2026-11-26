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

const chromeA = { id: 'chrome_status_icon_1', title: '', tooltipTitle: 'LM Studio' }
const chromeB = { id: 'chrome_status_icon_1', title: '', tooltipTitle: 'ChatGPT' }
const chromeBare = { id: 'chrome_status_icon_1' }
const keyA = tray.stateKey(chromeA, true)
const keyB = tray.stateKey(chromeB, true)
const dropbox = (title) => ({ id: 'dropbox', title, tooltipTitle: title })

assertEqual(keyA, 'chrome_status_icon_1\nLM Studio', 'tray keys a colliding electron icon by tooltip')
assert(keyA !== keyB, 'tray gives colliding electron icons different keys')
assertEqual(tray.stateKey(dropbox('Dropbox'), false), 'dropbox', 'tray keys a unique id by the bare id')
assertEqual(tray.stateKey(chromeBare, true), 'chrome_status_icon_1', 'tray keeps the bare id for an unlabelled colliding icon')

// A unique icon keeps its setting when its title changes.
assert(tray.appliesStored(['dropbox'], dropbox('Dropbox: Syncing'), false), 'tray keeps a pin when a unique icon changes its title')
assert(tray.appliesStored(['dropbox'], dropbox('Dropbox: Up to date'), false), 'tray keeps a pin across another title change')

// A shared id never claims every colliding icon.
assert(!tray.appliesStored(['chrome_status_icon_1'], chromeA, true), 'tray does not apply a bare id to a labelled colliding icon')
assert(tray.appliesStored(['chrome_status_icon_1'], chromeBare, true), 'tray applies a bare id to the unlabelled colliding icon')
assert(tray.appliesStored([keyB], chromeB, true), 'tray applies a stored per-icon key while the id is shared')
assert(!tray.appliesStored([keyA], chromeB, true), 'tray does not pin the other colliding icon')

// A sibling's setting survives toggling another icon.
assertDeepEqual(tray.toggleStored(['chrome_status_icon_1'], [], chromeA, true), { keys: ['chrome_status_icon_1', keyA], others: [] }, 'tray pins a labelled icon without deleting the unlabelled sibling')
assertDeepEqual(tray.toggleStored([keyB], [], chromeA, true), { keys: [keyB, keyA], others: [] }, 'tray pins one colliding icon without unpinning the other')
assertDeepEqual(tray.toggleStored([keyA], [], chromeA, true), { keys: [], others: [] }, 'tray unpins a colliding icon by its own key')

// A remaining icon must not inherit or erase its departed sibling's setting.
assert(!tray.appliesStored([keyB], chromeA, false), 'tray does not hide the survivor under the departed sibling key')
assert(tray.appliesStored([keyA], chromeA, false), 'tray preserves the survivor own key after a sibling exits')
assertDeepEqual(tray.toggleStored([], [keyB], chromeA, false), { keys: ['chrome_status_icon_1'], others: [keyB] }, 'tray pins the survivor without clearing the departed sibling hide')

// Pinning clears the icon from the other list, and never matches both.
assertDeepEqual(tray.toggleStored([], ['dropbox'], dropbox('Dropbox'), false), { keys: ['dropbox'], others: [] }, 'tray moves a hidden unique icon to pinned')
assertDeepEqual(tray.toggleStored([], [keyA], chromeA, false), { keys: ['chrome_status_icon_1'], others: [] }, 'tray clears a stale labelled key when the sibling is gone')
assertDeepEqual(tray.toggleStored(['dropbox'], [], dropbox('Dropbox'), false), { keys: [], others: [] }, 'tray unpins a unique icon on the first click')

// Wine needs a double-click's second activate to see a double-click; a native
// app that toggles its window on each activate would close again.
assert(tray.activatesOnDoubleClick({ id: 'wine-0x200d4-0' }), 'a double-click activates a Wine item again')
assert(!tray.activatesOnDoubleClick({ id: 'qbittorrent' }), 'a double-click activates a native item once')
assert(!tray.activatesOnDoubleClick({ id: 'wine-0x200d4-0', onlyMenu: true }), 'a double-click on a menu-only Wine item activates nothing more')

// The bar outlines as much of the tray section as the sliding drawer shows,
// never past the drawer.
assertDeepEqual(tray.shownSpan(0, 100, 20, 30), { start: 20, length: 30 }, 'a section inside the open drawer shows whole')
assertDeepEqual(tray.shownSpan(0, 40, 20, 30), { start: 20, length: 20 }, 'a section past the drawer\'s far edge is cut there')
assertDeepEqual(tray.shownSpan(10, 100, 0, 30), { start: 10, length: 20 }, 'a section sliding in from behind the drawer\'s near edge is cut there')
assertEqual(tray.shownSpan(0, 10, 50, 30), null, 'a section still outside the drawer shows nothing')
assertDeepEqual(tray.shownSpan(0, 50, 50.5, 0), { start: 50, length: 0 }, 'an empty section shows on the drawer\'s edge once within a pixel of it')
assertEqual(tray.shownSpan(0, 50, 52, 0), null, 'an empty section further out shows nothing')
JS
