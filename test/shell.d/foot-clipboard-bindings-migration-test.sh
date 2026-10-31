#!/bin/bash

set -euo pipefail

# The migration extends Foot's legacy Insert-only clipboard bindings with the
# Ctrl+Shift chords SUPER+C/V send to terminals, without touching anything a
# user changed and without mapping a chord Foot already has bound.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1790476654.sh"
[[ -f $migration ]] || fail "Foot clipboard bindings migration exists"
[[ $(stat -c %a "$migration") == "644" ]] || fail "migration is a plain 0644 file"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

foot_config="$test_tmp/home/.config/foot/foot.ini"
packaged_bindings=$(sed -n '/^\[key-bindings\]/,/^$/p' "$ROOT/config/foot/foot.ini")

run_migration() {
  HOME="$test_tmp/home" OMARCHY_PATH="$ROOT" bash -euo pipefail "$migration" >/dev/null
}

write_config() {
  rm -rf "$test_tmp/home"
  mkdir -p "${foot_config%/*}"
  printf '%s\n' "$@" >"$foot_config"
}

run_migration || fail "migration exits clean without a Foot config"
[[ ! -e $foot_config ]] || fail "migration does not create a Foot config"
pass "migration leaves a machine without a Foot config alone"

write_config "[main]" "font=Iosevka:size=11" "" "[key-bindings]" "clipboard-copy=Control+Insert" "primary-paste=none" "clipboard-paste=Shift+Insert" ""
run_migration || fail "migration exits clean on a legacy config"
[[ $(sed -n '/^\[key-bindings\]/,/^$/p' "$foot_config") == "$packaged_bindings" ]] ||
  fail "legacy bindings match the packaged defaults" "$(cat "$foot_config")"
grep -qx "font=Iosevka:size=11" "$foot_config" || fail "the rest of the config is kept" "$(cat "$foot_config")"
pass "migration extends legacy Insert-only bindings"

before=$(cat "$foot_config")
run_migration || fail "migration exits clean on a second run"
[[ $(cat "$foot_config") == "$before" ]] || fail "second run changes nothing" "$(cat "$foot_config")"
pass "migration is idempotent"

write_config "[key-bindings]" "clipboard-copy=Control+Insert" "clipboard-paste=Shift+Insert" "search-start=Control+Shift+c"
run_migration || fail "migration exits clean when a chord is taken"
grep -qx "clipboard-copy=Control+Insert" "$foot_config" || fail "a copy chord bound elsewhere is not mapped twice" "$(cat "$foot_config")"
grep -qx "clipboard-paste=Shift+Insert Control+Shift+v XF86Paste" "$foot_config" ||
  fail "the free paste chord is still added" "$(cat "$foot_config")"
pass "migration does not map a chord the user already bound"

write_config "[key-bindings]" "clipboard-copy=Control+Insert Mod4+c" "clipboard-paste=Shift+Insert"
run_migration || fail "migration exits clean on customized bindings"
grep -qx "clipboard-copy=Control+Insert Mod4+c" "$foot_config" || fail "customized copy binding is kept" "$(cat "$foot_config")"
pass "migration leaves customized bindings alone"
