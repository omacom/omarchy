#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

args_file="$tmpdir/busctl-args"
command="$ROOT/bin/omarchy-tray-context-menu"

printf '%s\n' \
  '#!/bin/bash' \
  'printf "%s\n" "$@" >>"$OMARCHY_TEST_BUSCTL_ARGS"' \
  'case "$*" in' \
  '  *"RegisteredStatusNotifierItems") printf '\''{"type":"as","data":[%s]}\n'\'' "${OMARCHY_TEST_ITEMS:-\":1.10/StatusNotifierItem\"}" ;;' \
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

OMARCHY_TEST_ITEMS='":1.10/StatusNotifierItem",":1.11/StatusNotifierItem"' run_context_menu 5 wine-test 10 20 2>/dev/null
assert_no_context_call
pass "tray context menu refuses to guess between items sharing an id"

run_context_menu 0 wine-test 33 44
actual_call=$(tail -n 11 "$args_file" | paste -sd ' ')
expected_call="--user --timeout=1 -- call :1.10 /StatusNotifierItem org.kde.StatusNotifierItem ContextMenu ii 33 44"
[[ $actual_call == "$expected_call" ]] ||
  fail "tray context menu preserves the native call coordinates" "$actual_call"
pass "tray context menu calls the item's own menu with exact coordinates"
