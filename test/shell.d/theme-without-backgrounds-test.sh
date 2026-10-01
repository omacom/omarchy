#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home"
runtime_dir="$test_tmp/runtime"
current_state="$test_home/.local/state/omarchy/current"
background_link="$current_state/background"
mkdir -p "$test_home" "$runtime_dir"

set_theme() {
  HOME="$test_home" XDG_RUNTIME_DIR="$runtime_dir" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
    OMARCHY_THEME_HEADLESS=1 "$ROOT/bin/omarchy-theme-set" "$1" >/dev/null
}

bare_theme="$test_home/.config/omarchy/themes/no-backgrounds"
mkdir -p "$bare_theme"
printf 'mode = "dark"\nbackground = "#141414"\nforeground = "#b2b2b2"\n' >"$bare_theme/colors.toml"

set_theme "tokyo-night"
[[ -f $(readlink -f "$background_link") ]] || fail "the outgoing theme sets a background"

set_theme "no-backgrounds"
[[ ! -e $background_link && ! -L $background_link ]] || fail "a theme without backgrounds leaves no background link" \
  "background link: $(readlink "$background_link")"
pass "a theme without backgrounds leaves no background link"

set_theme "no-backgrounds"
[[ ! -e $background_link && ! -L $background_link ]] || fail "reapplying a theme without backgrounds still leaves no link"
pass "reapplying a theme without backgrounds still leaves no link"

user_backgrounds="$test_home/.config/omarchy/backgrounds/no-backgrounds"
mkdir -p "$user_backgrounds"
cp "$ROOT/themes/tokyo-night/backgrounds/$(ls "$ROOT/themes/tokyo-night/backgrounds" | head -n 1)" "$user_backgrounds/mine.webp"
set_theme "no-backgrounds"
[[ $(readlink -f "$background_link") == "$user_backgrounds/mine.webp" ]] ||
  fail "a user background for the theme is still used"
pass "a user background for the theme is still used"
rm -rf "$user_backgrounds"

set_theme "tokyo-night"
[[ $(readlink -f "$background_link") == "$current_state/theme/backgrounds/"* ]] ||
  fail "a theme with backgrounds sets the link again"
pass "a theme with backgrounds sets the link again"
