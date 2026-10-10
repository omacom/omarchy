#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

home="$test_dir/home"
link="$home/.config/helix/themes/omarchy.toml"
target="$home/.local/state/omarchy/current/theme/helix.toml"
migration="$ROOT/migrations/1790703856.sh"
mkdir -p "$test_dir/bin" "${target%/*}"

cat >"$test_dir/bin/omarchy-cmd-present" <<'STUB'
#!/bin/bash
[[ $1 == helix && ${HELIX_INSTALLED:-0} == 1 ]]
STUB
chmod +x "$test_dir/bin/omarchy-cmd-present"

run_migration() {
  HOME="$home" PATH="$test_dir/bin:$ROOT/bin:$PATH" HELIX_INSTALLED="${HELIX_INSTALLED:-1}" \
    bash -euo pipefail "$migration" >/dev/null
}

run_theme_set() {
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$ROOT/bin:$PATH" \
    HELIX_INSTALLED="${HELIX_INSTALLED:-1}" OMARCHY_THEME_HEADLESS=1 OMARCHY_THEME_SKIP_BACKGROUND=1 \
    XDG_RUNTIME_DIR="$test_dir" bash "$ROOT/bin/omarchy-theme-set" "Tokyo Night" >/dev/null
}

run_migration
[[ ! -e $link && ! -L $link ]] || fail "migration skips an absent rendered theme"
pass "migration does not create a dangling theme link"

touch "$target"
HELIX_INSTALLED=0 run_migration
[[ ! -e $link && ! -L $link ]] || fail "migration skips users without Helix"
pass "migration skips users without Helix"

run_migration
[[ -L $link && $(readlink "$link") == "$target" ]] || fail "migration provisions missing Helix link"
run_migration
[[ $(readlink "$link") == "$target" ]] || fail "migration is idempotent"
pass "migration provisions a missing Helix link idempotently"

rm "$link"
printf 'user theme\n' >"$link"
run_migration
[[ $(<"$link") == 'user theme' ]] || fail "migration preserves user theme file"
rm "$link"
ln -s /some/custom/theme "$link"
run_migration
[[ $(readlink "$link") == /some/custom/theme ]] || fail "migration preserves custom symlink, even if dangling"
pass "migration preserves user files and symlinks"

rm "$link"
run_theme_set
[[ -L $link && $(readlink "$link") == "$target" && -f $link ]] || fail "theme change provisions and renders the Helix link"
pass "theme change provisions Helix installed outside Omarchy"

rm "$link"
HELIX_INSTALLED=0 run_theme_set
[[ ! -e $link && ! -L $link ]] || fail "theme change skips users without Helix"
pass "theme change skips users without Helix"

printf 'user theme\n' >"$link"
run_theme_set
[[ $(<"$link") == 'user theme' ]] || fail "theme change preserves user theme file"
rm "$link"
ln -s /some/custom/theme "$link"
run_theme_set
[[ $(readlink "$link") == /some/custom/theme ]] || fail "theme change preserves a dangling custom symlink"
pass "theme change preserves existing user themes and links"
