#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
omarchy_dir="$test_tmp/omarchy"
installed_logo="$test_tmp/installed-logo.png"
plymouth_current="$test_tmp/omarchy-plymouth-current"

mkdir -p \
  "$home/.config/omarchy/themes/user-theme" \
  "$omarchy_dir/default/plymouth" \
  "$omarchy_dir/themes/with-preview" \
  "$omarchy_dir/themes/without-preview"

printf 'default-logo\n' >"$omarchy_dir/default/plymouth/logo.png"
printf 'preview\n' >"$omarchy_dir/themes/with-preview/preview-unlock.png"
printf 'with-preview-logo\n' >"$omarchy_dir/themes/with-preview/unlock.png"
printf 'without-preview-logo\n' >"$omarchy_dir/themes/without-preview/unlock.png"
printf 'user-theme-logo\n' >"$home/.config/omarchy/themes/user-theme/unlock.png"

sed "s|/usr/share/plymouth/themes/omarchy/logo.png|$installed_logo|" \
  "$ROOT/bin/omarchy-plymouth-current" >"$plymouth_current"
chmod +x "$plymouth_current"

run_current() {
  HOME="$home" OMARCHY_PATH="$omarchy_dir" PATH="$ROOT/bin:$PATH" "$plymouth_current"
}

cp "$omarchy_dir/default/plymouth/logo.png" "$installed_logo"
output=$(run_current)
[[ $output == "default" ]] || fail "omarchy-plymouth-current prints default for the default logo" "actual: $output"
pass "omarchy-plymouth-current prints default for the default logo"

cp "$omarchy_dir/themes/with-preview/unlock.png" "$installed_logo"
output=$(run_current)
[[ $output == "with-preview" ]] || fail "omarchy-plymouth-current prints only the matched theme name" "actual: $output"
pass "omarchy-plymouth-current prints only the matched theme name"

cp "$omarchy_dir/themes/without-preview/unlock.png" "$installed_logo"
output=$(run_current)
[[ $output == "without-preview" ]] || fail "omarchy-plymouth-current matches a theme without preview-unlock.png" "actual: $output"
pass "omarchy-plymouth-current matches a theme without preview-unlock.png"

cp "$home/.config/omarchy/themes/user-theme/unlock.png" "$installed_logo"
output=$(run_current)
[[ $output == "user-theme" ]] || fail "omarchy-plymouth-current matches a user theme without preview-unlock.png" "actual: $output"
pass "omarchy-plymouth-current matches a user theme without preview-unlock.png"

printf 'unmatched-logo\n' >"$installed_logo"
output=$(run_current)
[[ $output == "custom" ]] || fail "omarchy-plymouth-current prints custom for an unmatched logo" "actual: $output"
pass "omarchy-plymouth-current prints custom for an unmatched logo"
