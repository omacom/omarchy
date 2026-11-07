#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export HOME="$test_tmp/home" HERDR_APP_HOME="$test_tmp/herdr" PATH="$ROOT/bin:$PATH"
export OMARCHY_PATH="$ROOT"
unset XDG_CONFIG_HOME
default_keys="$ROOT/default/herdr-app/keys.json"
keys="$HERDR_APP_HOME/keys.json"

backups() { find "$HERDR_APP_HOME" -maxdepth 1 -name 'keys.json.bak.*' | wc -l; }

jq -e . "$default_keys" >/dev/null || fail "the shipped Herdr keymap must be valid JSON"
pass "the shipped Herdr keymap is valid JSON"

omarchy-refresh-herdr-app >/dev/null
cmp -s "$default_keys" "$keys" || fail "a first run must seed the Omarchy keymap"
(( $(backups) == 0 )) || fail "a first run has nothing to back up"
pass "a first run seeds the keymap"

omarchy-refresh-herdr-app >/dev/null
(( $(backups) == 0 )) || fail "a matching keymap must not be backed up again"
pass "a matching keymap is left alone"

echo '{"global":{"ctrl-q":"app.quit"}}' >"$keys"
omarchy-refresh-herdr-app >/dev/null
cmp -s "$default_keys" "$keys" || fail "a differing keymap must be replaced"
(( $(backups) == 1 )) || fail "a differing keymap must be backed up"
grep -q 'ctrl-q' "$HERDR_APP_HOME"/keys.json.bak.* || fail "the backup must hold the person's own keys"
pass "a differing keymap is backed up and replaced"

rm -f "$keys" "$HERDR_APP_HOME"/keys.json.bak.*
echo '{"global":{}}' >"$test_tmp/dotfiles-keys.json"
ln -s "$test_tmp/dotfiles-keys.json" "$keys"
omarchy-refresh-herdr-app >/dev/null
[[ -L $keys && $(cat "$test_tmp/dotfiles-keys.json") == '{"global":{}}' ]] || fail "a symlinked keymap must be left alone"
pass "a symlinked keymap is left alone"

rm -rf "$HERDR_APP_HOME"
bash "$ROOT/migrations/1794068501.sh" >/dev/null
[[ ! -e $HERDR_APP_HOME ]] || fail "the migration must skip machines without the app"
pass "the migration skips machines without Herdr Desktop"

mkdir -p "$HERDR_APP_HOME"
bash "$ROOT/migrations/1794068501.sh" >/dev/null
cmp -s "$default_keys" "$keys" || fail "the migration must seed the keymap for app users"
pass "the migration seeds the keymap for Herdr Desktop users"
