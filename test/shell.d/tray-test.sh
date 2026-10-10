#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test "tray model helpers" <<'JS'
const tray = requireFromRoot('shell/plugins/bar/widgets/TrayModel.js')

assert(tray.iconNeedsTint('image://icon/zero-trust-connected'), 'Cloudflare connected icon follows the bar foreground')
assert(tray.iconNeedsTint('image://icon/zero-trust-connected?path=/icons'), 'Cloudflare connected icon matches with an icon search path')
assert(tray.iconNeedsTint('image://icon/network-wireless-symbolic'), 'symbolic icons still follow the bar foreground')
assert(!tray.iconNeedsTint('image://icon/zero-trust-connected-exclamation'), 'Cloudflare warning icon keeps its status color')
assert(!tray.iconNeedsTint('image://icon/zero-trust-disconnected'), 'Cloudflare disconnected icon keeps its status color')
assert(!tray.iconNeedsTint('image://icon/zero-trust-error'), 'Cloudflare error icon keeps its status color')
assert(!tray.iconNeedsTint('image://icon/zero-trust-orange'), 'Cloudflare orange icon keeps its status color')
assert(!tray.iconNeedsTint('image://icon/other-connected'), 'unrelated icons keep their original colors')

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
JS
