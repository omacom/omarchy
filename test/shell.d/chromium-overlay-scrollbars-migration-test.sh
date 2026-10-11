#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1791376887.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
config_dir="$home/.config"
mkdir -p "$config_dir" "$test_tmp/targets"

printf '%s\n' '--enable-features=TouchpadOverscrollHistoryNavigation' >"$config_dir/chromium-flags.conf"
printf '%s\n' '--enable-features=' >"$config_dir/chrome-flags.conf"
printf '%s' '--ozone-platform=wayland' >"$config_dir/microsoft-edge-stable-flags.conf"
printf '%s\n' '--enable-features=BraveFeature' >"$test_tmp/targets/brave-flags.conf"
ln -s "$test_tmp/targets/brave-flags.conf" "$config_dir/brave-flags.conf"

run_migration() {
  HOME="$home" bash -euo pipefail "$migration" >/dev/null
}

run_migration
run_migration

grep -Fxq -- '--enable-features=TouchpadOverscrollHistoryNavigation,OverlayScrollbar' "$config_dir/chromium-flags.conf" ||
  fail "the migration preserves existing Chromium features"
overlay_count=$(grep -o 'OverlayScrollbar' "$config_dir/chromium-flags.conf" | wc -l)
(( overlay_count == 1 )) || fail "the migration does not duplicate the Chromium feature"
pass "the migration preserves existing features and can run twice"

[[ $(cat "$config_dir/chrome-flags.conf") == '--enable-features=OverlayScrollbar' ]] ||
  fail "the migration fills an empty feature list"
[[ $(cat "$config_dir/microsoft-edge-stable-flags.conf") == $'--ozone-platform=wayland\n--enable-features=OverlayScrollbar' ]] ||
  fail "the migration adds a feature list with a missing trailing newline"
pass "the migration handles empty and missing feature lists"

[[ -L $config_dir/brave-flags.conf ]] || fail "the migration preserves symlinked browser flags"
grep -Fxq -- '--enable-features=BraveFeature,OverlayScrollbar' "$config_dir/brave-flags.conf" ||
  fail "the migration updates the target of symlinked browser flags"
pass "the migration follows symlinked browser flags"

[[ ! -e $config_dir/brave-origin-flags.conf ]] || fail "the migration leaves missing browser flags absent"
pass "the migration skips missing browser flags"
