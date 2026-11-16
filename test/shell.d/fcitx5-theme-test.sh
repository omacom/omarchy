#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

home="$test_dir/home"
packaged="$test_dir/packaged"
stub_bin="$test_dir/bin"
calls="$test_dir/busctl-calls"
source_conf="$home/.local/state/omarchy/current/theme/fcitx5-theme.conf"
theme_dir="$home/.local/share/fcitx5/themes/omarchy"
classicui="$home/.config/fcitx5/conf/classicui.conf"
mkdir -p "${source_conf%/*}" "$packaged" "$stub_bin"
printf '<svg/>\n' >"$packaged/prev.svg"

cat >"$stub_bin/busctl" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$BUSCTL_CALLS"
STUB
chmod +x "$stub_bin/busctl"

sync_theme() {
  HOME="$home" XDG_CONFIG_HOME= XDG_DATA_HOME= PATH="$stub_bin:$PATH" BUSCTL_CALLS="$calls" \
    OMARCHY_FCITX5_PACKAGED_THEME="$packaged" bash "$ROOT/bin/omarchy-theme-set-fcitx5" "$@"
}

printf 'NormalColor=#a9b1d6\n' >"$source_conf"
sync_theme
[[ ! -e $theme_dir && ! -e $classicui ]] || fail "a theme switch before activation leaves Fcitx alone"
pass "theme switches do not claim Fcitx before activation"

sync_theme --activate
grep -qx 'NormalColor=#a9b1d6' "$theme_dir/theme.conf" || fail "activation installs the generated theme"
[[ $(readlink "$theme_dir/prev.svg") == "$packaged/prev.svg" ]] || fail "the theme links fcitx5's glyphs beside it"
grep -qx 'Theme=omarchy' "$classicui" || fail "activation selects the theme"
grep -qx 'DarkTheme=omarchy' "$classicui" || fail "activation selects the theme for dark mode too"
grep -q -- '--auto-start=no .*ReloadAddonConfig s classicui' "$calls" || fail "a running Fcitx reloads without being started"
pass "activation installs and selects the Omarchy theme"

printf 'NormalColor=#4c4f69\n' >"$source_conf"
sync_theme
grep -qx 'NormalColor=#4c4f69' "$theme_dir/theme.conf" || fail "a theme switch retints the candidate window"
pass "theme switches retint an activated candidate window"

printf 'Font="Noto Sans CJK JP 14"\nTheme=default\nDarkTheme=default-dark\n' >"$classicui"
sync_theme --activate
grep -qx 'Font="Noto Sans CJK JP 14"' "$classicui" || fail "activation keeps the user's other classicui settings"
[[ $(grep -c '^Theme=' "$classicui") == 1 ]] && grep -qx 'Theme=omarchy' "$classicui" || fail "activation replaces fcitx5's stock theme"
grep -qx 'DarkTheme=omarchy' "$classicui" || fail "activation replaces fcitx5's stock dark theme"
pass "activation takes over fcitx5's stock themes and keeps the rest"

printf 'Theme=default\n' >"$classicui"
sync_theme
grep -qx 'Theme=default' "$classicui" || fail "a theme switch never reselects the theme"
pass "choosing fcitx5's own theme after activation sticks"

printf 'Theme=my-theme\nDarkTheme=my-theme\n' >"$classicui"
sync_theme --activate
grep -qx 'Theme=my-theme' "$classicui" && grep -qx 'DarkTheme=my-theme' "$classicui" || fail "activation leaves a user's own theme alone"
pass "activation leaves a theme the user installed alone"

dotfiles="$test_dir/dotfiles/classicui.conf"
mkdir -p "${dotfiles%/*}"
printf 'Theme=default\n' >"$dotfiles"
ln -sfn "$dotfiles" "$classicui"
sync_theme --activate
[[ -L $classicui ]] || fail "activation keeps a dotfiles symlink"
grep -qx 'Theme=omarchy' "$dotfiles" || fail "activation writes through a dotfiles symlink"
pass "activation writes through a symlinked classicui.conf"
