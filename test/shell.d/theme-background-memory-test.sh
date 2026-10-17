#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home"
runtime_dir="$test_tmp/runtime"
current_state="$test_home/.local/state/omarchy/current"
background_state="$test_home/.local/state/omarchy/theme-backgrounds"
mkdir -p "$test_home" "$runtime_dir"

set_theme() {
  HOME="$test_home" XDG_RUNTIME_DIR="$runtime_dir" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
    OMARCHY_THEME_HEADLESS=1 "$ROOT/bin/omarchy-theme-set" "$1" >/dev/null
}

current_background_name() {
  basename "$(readlink "$current_state/background")"
}

theme_a="tokyo-night"
theme_b="catppuccin"

set_theme "$theme_a"
mapfile -t theme_a_backgrounds < <(find "$current_state/theme/backgrounds" -maxdepth 1 -type f -print | sort)
(( ${#theme_a_backgrounds[@]} > 1 )) || fail "test theme has multiple backgrounds"
theme_a_first=${theme_a_backgrounds[0]##*/}
theme_a_selected_path=${theme_a_backgrounds[1]}
theme_a_selected=${theme_a_selected_path##*/}
ln -nsf "$theme_a_selected_path" "$current_state/background"

set_theme "$theme_b"
mapfile -t theme_b_backgrounds < <(find "$current_state/theme/backgrounds" -maxdepth 1 -type f -print | sort)
(( ${#theme_b_backgrounds[@]} > 1 )) || fail "second test theme has multiple backgrounds"
theme_b_first=${theme_b_backgrounds[0]##*/}

common_background=$(comm -12 \
  <(find "$ROOT/themes/$theme_a/backgrounds" -maxdepth 1 -type f -printf '%f\n' | sort) \
  <(find "$current_state/theme/backgrounds" -maxdepth 1 -type f -printf '%f\n' | sort) | head -n 1)
[[ -n $common_background ]] || fail "test themes share a background filename"
theme_b_common_path=$(find "$current_state/theme/backgrounds" -maxdepth 1 -type f -name "$common_background" -print -quit)
ln -nsf "$theme_b_common_path" "$current_state/background"

[[ $(<"$background_state/$theme_a") == "$theme_a_selected_path" ]] || fail "theme switch remembers the outgoing background path"
pass "theme switch remembers the outgoing background path"

set_theme "$theme_a"
[[ $(current_background_name) == "$theme_a_selected" ]] || fail "shared filenames do not override the remembered background"
pass "shared filenames do not override the remembered background"

set_theme "$theme_b"
[[ $(current_background_name) == "$common_background" ]] || fail "themes remember backgrounds independently"
pass "themes remember backgrounds independently"

external_background="$test_tmp/external-background.webp"
cp "$(readlink -f "$current_state/background")" "$external_background"
ln -nsf "$external_background" "$current_state/background"
set_theme "$theme_a"
set_theme "$theme_b"
[[ $(readlink -f "$current_state/background") == "$external_background" ]] || fail "theme switch restores an external background path"
pass "theme switch restores an external background path"

set_theme "$theme_b"
[[ $(current_background_name) == "$theme_b_first" ]] || fail "reapplying a theme with an external background falls back to the first image"
pass "reapplying a theme with an external background falls back to the first image"

set_theme "$theme_a"
user_background_dir="$test_home/.config/omarchy/backgrounds/$theme_a"
user_background="$user_background_dir/$theme_a_first"
mkdir -p "$user_background_dir"
cp "${theme_a_backgrounds[0]}" "$user_background"
ln -nsf "$user_background" "$current_state/background"
set_theme "$theme_b"
set_theme "$theme_a"
[[ $(readlink -f "$current_state/background") == "$user_background" ]] || fail "theme switch distinguishes duplicate background filenames"
pass "theme switch distinguishes duplicate background filenames"

set_theme "$theme_b"
rm -f "$user_background"
printf '%s\n' "$test_tmp/missing-background.webp" >"$background_state/$theme_a"
set_theme "$theme_a"
[[ $(current_background_name) == "$theme_a_first" ]] || fail "missing remembered background falls back to the first image"
pass "missing remembered background falls back to the first image"

set_theme "$theme_a"
[[ $(current_background_name) == "$theme_a_selected" ]] || fail "reapplying the active theme still cycles backgrounds"
pass "reapplying the active theme still cycles backgrounds"

printf '%s\n' "../escaped" >"$current_state/theme.name"
set_theme "$theme_b"
[[ ! -e $test_home/.local/state/omarchy/escaped ]] || fail "invalid theme names cannot escape the background state directory"
pass "invalid theme names cannot escape the background state directory"

# Interactive switches choose before swapping the staged theme into place.
source <(awk '
  /^(theme_background_state_file|choose_theme_background|choose_staged_theme_background)\(\) \{/ { copying=1 }
  copying { print }
  copying && /^}$/ { copying=0 }
' "$ROOT/bin/omarchy-theme-set")

HOME="$test_home"
CURRENT_THEME_PATH="$current_state/theme"
NEXT_THEME_PATH="$current_state/next-theme"
CURRENT_BACKGROUND_LINK="$current_state/background"
THEME_BACKGROUND_STATE_PATH="$background_state"
THEME_NAME="staged-test"
PREVIOUS_THEME_NAME="$theme_b"
mkdir -p "$NEXT_THEME_PATH/backgrounds"
printf 'first\n' >"$NEXT_THEME_PATH/backgrounds/first.png"
printf 'selected\n' >"$NEXT_THEME_PATH/backgrounds/selected.mp4"
printf '%s\n' "$CURRENT_THEME_PATH/backgrounds/selected.mp4" >"$background_state/$THEME_NAME"
choose_staged_theme_background
[[ $CHOSEN_THEME_BACKGROUND == "$CURRENT_THEME_PATH/backgrounds/selected.mp4" ]] || fail "staged selection restores a remembered file absent from the outgoing theme"
pass "staged selection restores a remembered file absent from the outgoing theme"

printf 'outgoing only\n' >"$CURRENT_THEME_PATH/backgrounds/outgoing-only.png"
printf '%s\n' "$CURRENT_THEME_PATH/backgrounds/outgoing-only.png" >"$background_state/$THEME_NAME"
choose_staged_theme_background
[[ $CHOSEN_THEME_BACKGROUND == "$CURRENT_THEME_PATH/backgrounds/first.png" ]] || fail "staged selection rejects remembered files absent from the incoming theme"
pass "staged selection rejects remembered files absent from the incoming theme"

PREVIOUS_THEME_NAME="$THEME_NAME"
ln -nsf "$CURRENT_THEME_PATH/backgrounds/first.png" "$CURRENT_BACKGROUND_LINK"
choose_staged_theme_background
[[ $CHOSEN_THEME_BACKGROUND == "$CURRENT_THEME_PATH/backgrounds/selected.mp4" ]] || fail "staged same-theme selection still cycles backgrounds"
pass "staged same-theme selection still cycles backgrounds"

# Shared backgrounds sit directly in the user backgrounds folder and join every
# theme's list after its own.
shared_background="$test_home/.config/omarchy/backgrounds/0-shared.png"
printf 'shared\n' >"$shared_background"

PREVIOUS_THEME_NAME="$theme_b"
rm -f "$background_state/$THEME_NAME"
choose_staged_theme_background
[[ $CHOSEN_THEME_BACKGROUND == "$CURRENT_THEME_PATH/backgrounds/first.png" ]] || fail "shared backgrounds do not become a theme's default"
pass "shared backgrounds do not become a theme's default"

PREVIOUS_THEME_NAME="$THEME_NAME"
ln -nsf "$CURRENT_THEME_PATH/backgrounds/selected.mp4" "$CURRENT_BACKGROUND_LINK"
choose_staged_theme_background
[[ $CHOSEN_THEME_BACKGROUND == "$shared_background" ]] || fail "cycling reaches shared backgrounds after the theme's own"
pass "cycling reaches shared backgrounds after the theme's own"

ln -nsf "$shared_background" "$CURRENT_BACKGROUND_LINK"
choose_staged_theme_background
[[ $CHOSEN_THEME_BACKGROUND == "$CURRENT_THEME_PATH/backgrounds/first.png" ]] || fail "cycling wraps from shared backgrounds to the theme's own"
pass "cycling wraps from shared backgrounds to the theme's own"

PREVIOUS_THEME_NAME="$theme_b"
printf '%s\n' "$shared_background" >"$background_state/$THEME_NAME"
choose_staged_theme_background
[[ $CHOSEN_THEME_BACKGROUND == "$shared_background" ]] || fail "theme switch restores a remembered shared background"
pass "theme switch restores a remembered shared background"

# A theme with no backgrounds of its own opens on the first shared one.
rm -rf "$NEXT_THEME_PATH/backgrounds"
rm -f "$background_state/$THEME_NAME"
printf 'second shared\n' >"$test_home/.config/omarchy/backgrounds/1-shared.png"
[[ ! -e $test_home/.config/omarchy/backgrounds/$THEME_NAME ]] || fail "test theme has no user backgrounds folder"
choose_staged_theme_background
[[ $CHOSEN_THEME_BACKGROUND == "$shared_background" ]] || fail "a theme without backgrounds falls back to the first shared one"
pass "a theme without backgrounds falls back to the first shared one"

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"
printf '#!/bin/bash\n' >"$stub_bin/omarchy-shell"
chmod +x "$stub_bin/omarchy-shell"

set_theme "$theme_a"
mapfile -t theme_a_backgrounds < <(find "$current_state/theme/backgrounds" -maxdepth 1 -type f -print | sort)
ln -nsf "${theme_a_backgrounds[-1]}" "$current_state/background"
HOME="$test_home" PATH="$stub_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-theme-bg-next"
[[ $(readlink "$current_state/background") == "$shared_background" ]] || fail "next background reaches shared backgrounds after the theme's own"
pass "next background reaches shared backgrounds after the theme's own"

# Without a theme name the user folder would be the shared folder itself, and
# listing it as the theme's own would put shared backgrounds first.
rm -f "$current_state/theme.name" "$current_state/background"
HOME="$test_home" PATH="$stub_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-theme-bg-next"
[[ $(readlink "$current_state/background") == "${theme_a_backgrounds[0]}" ]] || fail "next background keeps shared backgrounds last without a theme name"
pass "next background keeps shared backgrounds last without a theme name"
