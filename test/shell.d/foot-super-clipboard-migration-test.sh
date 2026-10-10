#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

migration="$ROOT/migrations/1791576470.sh"
shipped="$ROOT/config/foot/foot.ini"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

home="$test_dir/home"
foot_config="$home/.config/foot/foot.ini"

reset_home() {
  rm -rf "$home"
  mkdir -p "$home/.config/foot"
}

run_migration() {
  HOME="$home" bash -euo pipefail "$migration" >/dev/null
}

reset_home
printf '%s\n' \
  '[key-bindings]' \
  'clipboard-copy=Control+Insert Control+Shift+c XF86Copy' \
  'primary-paste=none' \
  'clipboard-paste=Shift+Insert Control+Shift+v XF86Paste' \
  >"$foot_config"
chmod 644 "$foot_config"
run_migration
grep -qxF 'clipboard-copy=Control+Insert Control+Shift+c Mod4+Control+Shift+c XF86Copy' "$foot_config"
grep -qxF 'clipboard-paste=Shift+Insert Control+Shift+v Mod4+Control+Shift+v XF86Paste' "$foot_config"
# GNU stat treats -f as a filesystem query, so try -c first.
mode=$(stat -c '%a' "$foot_config" 2>/dev/null || stat -f '%Lp' "$foot_config")
[[ $mode == 644 ]]
[[ ! -e $foot_config.bak ]]
compgen -G "$foot_config.omarchy-1791576470."'*' >/dev/null && exit 1
pass "rewrites the shipped foot clipboard lines and keeps the file mode"

reset_home
printf '%s\n' 'clipboard-copy=Control+Insert Control+Shift+c XF86Copy' >"$foot_config"
printf 'user-backup\n' >"$foot_config.bak"
run_migration
[[ $(cat "$foot_config.bak") == 'user-backup' ]]
pass "leaves an existing foot.ini.bak untouched"

reset_home
cp "$shipped" "$foot_config"
before=$(cat "$foot_config")
run_migration
[[ $(cat "$foot_config") == "$before" ]]
pass "leaves the updated template unchanged"

reset_home
printf '%s\n' 'clipboard-copy=Control+Shift+c' 'clipboard-paste=Control+Shift+v' >"$foot_config"
before=$(cat "$foot_config")
run_migration
[[ $(cat "$foot_config") == "$before" ]]
pass "leaves a customized foot clipboard binding alone"

reset_home
rmdir "$home/.config/foot"
run_migration
[[ ! -e $foot_config ]]
pass "does nothing when foot.ini is absent"

grep -q 'Mod4+Control+Shift+c' "$shipped"
grep -q 'Mod4+Control+Shift+v' "$shipped"
pass "ships the Super-held chords in config/foot/foot.ini"