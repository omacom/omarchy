#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

command="$ROOT/bin/omarchy-theme-set-fcitx5"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

home="$test_dir/home"
packaged_theme="$test_dir/packaged-theme"
stub_bin="$test_dir/bin"
mkdir -p "$home/.local/state/omarchy/current/theme" "$packaged_theme" "$stub_bin"

printf 'arrow\n' >"$packaged_theme/arrow.svg"
printf 'radio\n' >"$packaged_theme/radio.png"

cat >"$stub_bin/busctl" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"${BUSCTL_CALLS:?}"
STUB
chmod +x "$stub_bin/busctl"

busctl_calls="$test_dir/busctl-calls"
theme_source="$home/.local/state/omarchy/current/theme/fcitx5-theme.conf"
theme_conf="$home/.local/share/fcitx5/themes/omarchy/theme.conf"
classicui_conf="$home/.config/fcitx5/conf/classicui.conf"

run_command() {
  HOME="$home" PATH="$stub_bin:$PATH" BUSCTL_CALLS="$busctl_calls" \
    OMARCHY_FCITX5_PACKAGED_THEME="$packaged_theme" bash "$command"
}

run_command
[[ ! -e $theme_conf ]] || fail "no theme is installed before one is generated"
[[ ! -e $busctl_calls ]] || fail "fcitx5 is not reloaded when there is nothing to apply"
pass "theme sync no-ops until the theme templates have been generated"

printf 'NormalColor=#c0caf5\nImage=arrow.svg\nImage=radio.svg\n' >"$theme_source"
run_command
grep -qx 'NormalColor=#c0caf5' "$theme_conf" || fail "the generated theme is installed for fcitx5"
[[ -f $home/.local/share/fcitx5/themes/omarchy/arrow.svg ]] || fail "the theme carries the images its Image= entries name"
grep -qx 'Image=arrow.svg' "$theme_conf" || fail "an SVG glyph fcitx5 ships keeps its name"
grep -qx 'Image=radio.png' "$theme_conf" || fail "a glyph fcitx5 only ships as PNG is referenced as PNG"
grep -qx 'Theme=omarchy' "$classicui_conf" || fail "classicui is pointed at the generated theme"
grep -qx 'DarkTheme=omarchy' "$classicui_conf" || fail "classicui uses the generated theme when following the system color scheme"
grep -q 'ReloadAddonConfig s classicui' "$busctl_calls" || fail "a running fcitx5 is told to reload the theme"
pass "theme sync installs the theme, its images, and selects it"

printf 'Font="Noto Sans CJK JP 14"\nTheme=default-dark\n' >"$classicui_conf"
printf 'NormalColor=#4c4f69\n' >"$theme_source"
run_command
grep -qx 'Font="Noto Sans CJK JP 14"' "$classicui_conf" || fail "theme sync preserves settings it does not own"
[[ $(grep -cx 'Theme=omarchy' "$classicui_conf") == 1 ]] || fail "theme sync replaces the theme rather than appending a second entry"
grep -qx 'NormalColor=#4c4f69' "$theme_conf" || fail "theme sync retints for the newly selected theme"
pass "theme sync re-themes without disturbing the user's own classicui settings"

printf 'Theme=my-theme\nDarkTheme=omarchy\n' >"$classicui_conf"
run_command
grep -qx 'Theme=my-theme' "$classicui_conf" || fail "a theme the user picked is not replaced"
grep -qx 'DarkTheme=omarchy' "$classicui_conf" || fail "a key that is Omarchy's keeps following the theme"
pass "theme sync leaves an fcitx5 theme the user chose alone"

rm "$theme_source"
: >"$busctl_calls"
run_command
grep -qx 'Theme=my-theme' "$classicui_conf" || fail "the user's theme survives a theme without a palette"
! grep -q '^DarkTheme=' "$classicui_conf" || fail "classicui stops pointing at the previous theme's colors"
grep -q 'ReloadAddonConfig s classicui' "$busctl_calls" || fail "a running fcitx5 drops the previous colors"
: >"$busctl_calls"
run_command
[[ ! -s $busctl_calls ]] || fail "nothing is reloaded once the selection is released"
pass "theme sync hands the popup back to fcitx5 when the theme generates no palette"
