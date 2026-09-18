#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

migration="$ROOT/migrations/1789574666.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

home="$test_dir/home"
mkdir -p "$home/.config"

run_migration() {
  HOME="$home" bash -euo pipefail "$migration" >/dev/null
}

printf -- '--ozone-platform=wayland\n' >"$home/.config/brave-flags.conf"
printf -- '--ozone-platform=wayland\n--enable-wayland-ime\n' >"$home/.config/chromium-flags.conf"

run_migration
grep -qx -- "--enable-wayland-ime" "$home/.config/brave-flags.conf" || fail "migration enables the Wayland IME for an existing browser"
[[ $(grep -cx -- "--enable-wayland-ime" "$home/.config/chromium-flags.conf") == 1 ]] || fail "migration leaves an already-enabled flags file alone"
[[ ! -e $home/.config/chrome-flags.conf ]] || fail "migration does not create flags for an uninstalled browser"
pass "migration enables the Wayland IME without touching browsers that already have it"

run_migration
[[ $(grep -cx -- "--enable-wayland-ime" "$home/.config/brave-flags.conf") == 1 ]] || fail "migration is idempotent"
grep -qx -- "--ozone-platform=wayland" "$home/.config/brave-flags.conf" || fail "migration preserves existing flags"
pass "migration is idempotent and preserves customized flags"
