#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
omarchy_dir="$test_tmp/omarchy"
installed_logo="$test_tmp/installed-logo.png"
plymouthd_conf="$test_tmp/plymouthd.conf"
plymouth_current="$test_tmp/omarchy-plymouth-current"

mkdir -p \
  "$home/.config/omarchy/themes" \
  "$omarchy_dir/default/plymouth" \
  "$omarchy_dir/themes/with-preview"

printf 'default-logo\n' >"$omarchy_dir/default/plymouth/logo.png"
printf 'preview\n' >"$omarchy_dir/themes/with-preview/preview-unlock.png"
printf 'with-preview-logo\n' >"$omarchy_dir/themes/with-preview/unlock.png"

sed \
  -e "s|/usr/share/plymouth/themes/omarchy/logo.png|$installed_logo|" \
  -e "s|/etc/plymouth/plymouthd.conf|$plymouthd_conf|" \
  "$ROOT/bin/omarchy-plymouth-current" >"$plymouth_current"
chmod +x "$plymouth_current"

run_current() {
  HOME="$home" OMARCHY_PATH="$omarchy_dir" PATH="$ROOT/bin:$PATH" "$plymouth_current"
}

cp "$omarchy_dir/default/plymouth/logo.png" "$installed_logo"
output=$(run_current)
[[ $output == "default" ]] || fail "omarchy-plymouth-current prints default for the default logo" "actual: $output"
pass "omarchy-plymouth-current prints default for the default logo"

printf '[Daemon]\nTheme=omarchy\n' >"$plymouthd_conf"
cp "$omarchy_dir/themes/with-preview/unlock.png" "$installed_logo"
output=$(run_current)
[[ $output == "with-preview" ]] || fail "omarchy-plymouth-current prints only the matched theme name" "actual: $output"
pass "omarchy-plymouth-current prints only the matched theme name"

printf 'unmatched-logo\n' >"$installed_logo"
output=$(run_current)
[[ $output == "omarchy" ]] || fail "omarchy-plymouth-current falls back to Theme=omarchy when no logo matches" "actual: $output"
pass "omarchy-plymouth-current falls back to Theme=omarchy when no logo matches"

printf '[Daemon]\nTheme=spinner\n' >"$plymouthd_conf"
output=$(run_current)
[[ $output == "spinner" ]] || fail "omarchy-plymouth-current falls back to the theme configured in plymouthd.conf" "actual: $output"
pass "omarchy-plymouth-current falls back to the theme configured in plymouthd.conf"

rm -f "$plymouthd_conf"
output=$(run_current)
[[ $output == "omarchy" ]] || fail "omarchy-plymouth-current defaults to omarchy when plymouthd.conf is absent" "actual: $output"
pass "omarchy-plymouth-current defaults to omarchy when plymouthd.conf is absent"
