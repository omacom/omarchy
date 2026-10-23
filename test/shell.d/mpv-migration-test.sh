#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
migration="$ROOT/migrations/1791649307.sh"
home="$test_tmp/fresh"
mkdir -p "$home/.local/state/omarchy/current/theme"
cp "$ROOT/themes/nord/colors.toml" "$home/.local/state/omarchy/current/theme/"
run_migration() {
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" bash -euo pipefail "$migration"
}
run_migration
[[ -f $home/.config/mpv/scripts/omarchy-controls.lua ]] || fail "fresh user receives mpv controls"
[[ -s $home/.local/state/omarchy/current/theme/mpv-theme.conf ]] || fail "upgrade initializes active palette"
! grep -q '{{' "$home/.local/state/omarchy/current/theme/mpv-theme.conf" || fail "palette tokens resolve"
cp -a "$home" "$test_tmp/first"
run_migration
diff -r "$test_tmp/first" "$home" || fail "mpv migration is idempotent"
pass "fresh upgrade bootstraps palette and idempotent defaults"

# A dark palette with the legacy marker must still initialize in light mode.
# An explicit mode in colors.toml takes precedence over that marker.
for mode in marker explicit; do
  home="$test_tmp/light-$mode"
  theme="$home/.local/state/omarchy/current/theme"
  mkdir -p "$theme"
  sed '/^mode[[:space:]]*=/d; /^theme_type[[:space:]]*=/d' "$ROOT/themes/nord/colors.toml" > "$theme/colors.toml"
  touch "$theme/light.mode"
  expected="light"
  if [[ $mode == "explicit" ]]; then
    printf '\nmode = "dark"\n' >> "$theme/colors.toml"
    expected="dark"
  fi
  run_migration
  grep -qx "mode=$expected" "$theme/mpv-theme.conf" || fail "migration preserves $mode theme mode"
  cp -a "$home" "$test_tmp/light-snapshot"
  run_migration
  diff -r "$test_tmp/light-snapshot" "$home" || fail "migration with $mode mode is idempotent"
  rm -rf "$test_tmp/light-snapshot"
done
pass "migration preserves legacy light mode and explicit mode precedence"

for fixture in regular uosc modernz oscc leaf-link parent-link dangling-link empty-dir; do
  home="$test_tmp/$fixture"
  mkdir -p "$home/.config/mpv"
  case "$fixture" in
    regular) printf '# preferences\nvolume=33\nslang=spa\n' > "$home/.config/mpv/mpv.conf" ;;
    uosc|modernz|oscc) mkdir -p "$home/.config/mpv/scripts"; printf 'user controller\n' > "$home/.config/mpv/scripts/$fixture.lua" ;;
    leaf-link) rmdir "$home/.config/mpv"; ln -s "$test_tmp/fresh/.config/mpv" "$home/.config/mpv" ;;
    dangling-link) rmdir "$home/.config/mpv"; ln -s "$test_tmp/missing" "$home/.config/mpv" ;;
    parent-link) rm -rf "$home/.config"; ln -s "$test_tmp/fresh/.config" "$home/.config" ;;
  esac
  cp -a "$home" "$test_tmp/snapshot"
  run_migration
  diff -r --no-dereference "$test_tmp/snapshot" "$home" || fail "preserves $fixture setup"
  rm -rf "$test_tmp/snapshot"
done
pass "existing configs, alternate controllers and Stow links remain untouched"
home="$test_tmp/no-theme"
mkdir -p "$home"
run_migration
[[ ! -e $home/.config/mpv ]] || fail "does not activate without initial palette"
pass "missing active colors leave opt-in setup available"
