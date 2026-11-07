#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test "tray model helpers" <<'JS'
const tray = requireFromRoot('shell/plugins/bar/widgets/TrayModel.js')

assert(tray.itemNamed({ id: 'dropbox-client' }, 'dropbox'), 'tray matches item ids')
assert(tray.itemNamed({ title: 'Dropbox' }, 'dropbox'), 'tray matches item titles')
assert(tray.itemNamed({ tooltipTitle: 'LocalSend' }, 'localsend'), 'tray matches item tooltips')
assert(!tray.itemNamed({ id: 'nextcloud' }, 'dropbox'), 'tray ignores items named for something else')
assert(tray.usesNativeContextMenu({ id: 'wine-0x10106-0', menu: null }), 'tray routes items without a D-Bus menu to their native context menu')
assert(!tray.usesNativeContextMenu({ id: 'wine-0x10106-0', menu: {} }), 'tray keeps items with a D-Bus menu on its own popup')
assert(!tray.usesNativeContextMenu(null), 'tray rejects missing items for native context menus')

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
JS

require_command jq

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

args_file="$tmpdir/busctl-args"
command="$ROOT/bin/omarchy-tray-context-menu"

printf '%s\n' \
  '#!/bin/bash' \
  'printf "%s\n" "$@" >>"$OMARCHY_TEST_BUSCTL_ARGS"' \
  'case "$*" in' \
  '  *"RegisteredStatusNotifierItems") printf '\''{"type":"as","data":[":1.10/StatusNotifierItem"]}\n'\'' ;;' \
  '  *" GetAll s org.kde.StatusNotifierItem") printf '\''{"type":"a{sv}","data":[{"Id":{"type":"s","data":"%s"},"Menu":{"type":"o","data":"%s"}}]}\n'\'' "${OMARCHY_TEST_ITEM_ID:-wine-test}" "${OMARCHY_TEST_MENU_PATH:-/NO_DBUSMENU}" ;;' \
  '  "--user --timeout=1 -- call "*) ;;' \
  '  *) exit 99 ;;' \
  'esac' \
  >"$tmpdir/busctl"
chmod +x "$tmpdir/busctl"

run_context_menu() {
  local expected_status=$1
  shift

  : >"$args_file"
  set +e
  OMARCHY_TEST_BUSCTL_ARGS="$args_file" PATH="$tmpdir:$PATH" "$command" "$@"
  local actual_status=$?
  set -e

  ((actual_status == expected_status)) ||
    fail "tray context menu exits with status $expected_status" "actual: $actual_status"
}

assert_no_context_call() {
  if grep -Fxq -- "ContextMenu" "$args_file"; then
    fail "tray context menu does not call ContextMenu" "$(cat "$args_file")"
  fi
}

run_context_menu 2 "" 10 20
[[ ! -s $args_file ]] || fail "tray context menu rejects a missing item id before DBus" "$(cat "$args_file")"
pass "tray context menu rejects a missing item id before DBus"

run_context_menu 2 wine-test not-a-number 20
[[ ! -s $args_file ]] || fail "tray context menu rejects an invalid x before DBus" "$(cat "$args_file")"
pass "tray context menu rejects an invalid x before DBus"

run_context_menu 2 wine-test 10 not-a-number
[[ ! -s $args_file ]] || fail "tray context menu rejects an invalid y before DBus" "$(cat "$args_file")"
pass "tray context menu rejects an invalid y before DBus"

OMARCHY_TEST_ITEM_ID=wine-other run_context_menu 4 wine-test 10 20
assert_no_context_call
pass "tray context menu ignores unknown item ids"

OMARCHY_TEST_MENU_PATH=/MenuBar run_context_menu 3 wine-test 10 20
assert_no_context_call
pass "tray context menu refuses items with a real DBus menu"

run_context_menu 0 wine-test 33 44
actual_call=$(tail -n 11 "$args_file" | paste -sd ' ')
expected_call="--user --timeout=1 -- call :1.10 /StatusNotifierItem org.kde.StatusNotifierItem ContextMenu ii 33 44"
[[ $actual_call == "$expected_call" ]] ||
  fail "tray context menu preserves the native call coordinates" "$actual_call"
pass "tray context menu calls the item's own menu with exact coordinates"
