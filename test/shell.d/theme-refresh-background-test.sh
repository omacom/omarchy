#!/bin/bash

set -euo pipefail

# omarchy-theme-refresh runs omarchy-theme-set with OMARCHY_THEME_SKIP_BACKGROUND=1
# so template regenerations do not cycle the user's wallpaper. When background
# files are renamed, converted (such as .jpg to .webp), or removed upstream,
# theme refresh must heal dangling symlinks rather than leave a broken path.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
state="$home/.local/state/omarchy/current"
custom_themes="$home/.config/omarchy/themes"
mock_root="$test_tmp/root"
stock_themes="$mock_root/themes"
runtime_dir="$test_tmp/runtime"

mkdir -p "$state" "$custom_themes" "$stock_themes" "$runtime_dir"
mkdir -p "$mock_root/default/themed"
cp -r "$ROOT/default/themed"/* "$mock_root/default/themed/" 2>/dev/null || true

theme_name="test-theme"
theme_dir="$stock_themes/$theme_name"
mkdir -p "$theme_dir/backgrounds"

cat >"$theme_dir/colors.toml" <<'TOML'
mode = "dark"
accent = "#7aa2f7"
selection = "#292e42"
muted = "#414868"
background = "#1a1b26"
foreground = "#a9b1d6"
TOML

printf 'jpg image 0\n' >"$theme_dir/backgrounds/0-intro.jpg"
printf 'jpg image 1\n' >"$theme_dir/backgrounds/1-cosmic.jpg"
printf 'jpg image 2\n' >"$theme_dir/backgrounds/2-meadow.jpg"

run_theme_set() {
  HOME="$home" OMARCHY_PATH="$mock_root" PATH="$ROOT/bin:$PATH" \
    XDG_RUNTIME_DIR="$runtime_dir" \
    env "$@" bash "$ROOT/bin/omarchy-theme-set" "$theme_name" 2>"$test_tmp/stderr" || return $?
}

run_theme_refresh() {
  HOME="$home" OMARCHY_PATH="$mock_root" PATH="$ROOT/bin:$PATH" \
    XDG_RUNTIME_DIR="$runtime_dir" \
    OMARCHY_THEME_SKIP_BACKGROUND=1 \
    env "$@" bash "$ROOT/bin/omarchy-theme-set" "$theme_name" 2>"$test_tmp/stderr" || return $?
}

bg_link="$state/background"

# 1. Initial theme set establishes the background symlink.
run_theme_set OMARCHY_THEME_HEADLESS=1 || fail "initial theme set succeeds"
[[ -L $bg_link ]] || fail "theme set creates the background symlink"
initial_target=$(readlink -f "$bg_link")
[[ -f $initial_target ]] || fail "initial background symlink resolves to an existing file"

# 2. When the background file is still present, theme refresh does not cycle the wallpaper.
run_theme_refresh OMARCHY_THEME_HEADLESS=1 || fail "theme refresh succeeds"
refreshed_target=$(readlink -f "$bg_link")
[[ $refreshed_target == "$initial_target" ]] || \
  fail "theme refresh preserves the active background when still present"

pass "theme refresh preserves the active background when its file exists"

# 3. Simulate upstream converting backgrounds from .jpg to .webp.
# Set active link explicitly to 1-cosmic.jpg.
ln -nsf "$state/theme/backgrounds/1-cosmic.jpg" "$bg_link"
rm -f "$theme_dir/backgrounds/1-cosmic.jpg"
printf 'webp image 1\n' >"$theme_dir/backgrounds/1-cosmic.webp"

run_theme_refresh OMARCHY_THEME_HEADLESS=0 || fail "theme refresh succeeds after image format update"
[[ -e $bg_link ]] || fail "theme refresh does not leave a dangling symlink"
healed_target=$(readlink -f "$bg_link")
[[ $healed_target == "$state/theme/backgrounds/1-cosmic.webp" ]] || \
  fail "theme refresh matches converted background by filename stem" "$healed_target"

pass "theme refresh matches converted background extensions by stem"

# 4. When the active background is deleted with no matching stem, it falls back to an available background.
ln -nsf "$state/theme/backgrounds/deleted-art.png" "$bg_link"
run_theme_refresh OMARCHY_THEME_HEADLESS=0 || fail "theme refresh succeeds after missing background"
[[ -e $bg_link ]] || fail "theme refresh recovers from a missing background"
fallback_target=$(readlink -f "$bg_link")
[[ -f $fallback_target ]] || fail "recovered background link points to an existing file"

pass "theme refresh heals a dangling symlink when the file is removed"

# 5. Headless theme refresh also heals a dangling background symlink.
ln -nsf "$state/theme/backgrounds/vanished.png" "$bg_link"
run_theme_refresh OMARCHY_THEME_HEADLESS=1 || fail "headless theme refresh succeeds"
[[ -e $bg_link ]] || fail "headless theme refresh does not leave a dangling symlink"
headless_target=$(readlink -f "$bg_link")
[[ -f $headless_target ]] || fail "headless healed background points to a valid file"

pass "headless theme refresh repairs a dangling background symlink"
