#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1791653969.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

run_migration() {
  HOME="$1" bash -euo pipefail "$migration" >/dev/null
}

setting='app-notifications = no-clipboard-copy,no-config-reload'

# A config from before the change gets the same lines as the new default
home="$test_tmp/stock"
mkdir -p "$home/.config/ghostty"
grep -v -e '^app-notifications' -e '^# No toast on each config reload' "$ROOT/config/ghostty/config" >"$home/.config/ghostty/config"
run_migration "$home"
run_migration "$home"
cmp -s "$ROOT/config/ghostty/config" "$home/.config/ghostty/config" ||
  fail "the migration turns an old default config into the new default"
pass "the migration adds the setting after resize-overlay and can run twice"

# A config with its own app-notifications stays as it is
home="$test_tmp/own"
mkdir -p "$home/.config/ghostty"
printf '%s\n' 'font-size = 12' 'app-notifications = true' >"$home/.config/ghostty/config"
run_migration "$home"
[[ $(cat "$home/.config/ghostty/config") == $'font-size = 12\napp-notifications = true' ]] ||
  fail "the migration keeps an existing app-notifications setting"
pass "the migration keeps an existing app-notifications setting"

# A config without the resize-overlay line (and without a final newline) gets the setting at the end
home="$test_tmp/custom"
mkdir -p "$home/.config/ghostty"
printf '%s' 'font-size = 12' >"$home/.config/ghostty/config"
run_migration "$home"
run_migration "$home"
grep -Fxq 'font-size = 12' "$home/.config/ghostty/config" || fail "the migration keeps the last line intact"
(( $(grep -cFx "$setting" "$home/.config/ghostty/config") == 1 )) ||
  fail "the migration appends the setting once to a custom config"
pass "the migration appends the setting to a custom config"

# A symlinked config stays a symlink
home="$test_tmp/link"
mkdir -p "$home/.config/ghostty" "$test_tmp/dotfiles"
printf '%s\n' 'resize-overlay = never' >"$test_tmp/dotfiles/ghostty-config"
ln -s "$test_tmp/dotfiles/ghostty-config" "$home/.config/ghostty/config"
run_migration "$home"
[[ -L $home/.config/ghostty/config ]] || fail "the migration preserves a symlinked config"
grep -Fxq "$setting" "$test_tmp/dotfiles/ghostty-config" || fail "the migration updates the symlink target"
pass "the migration follows a symlinked config"

# No Ghostty config, no new file
home="$test_tmp/none"
mkdir -p "$home"
run_migration "$home"
[[ ! -e $home/.config/ghostty/config ]] || fail "the migration leaves a missing config absent"
pass "the migration skips a missing config"
