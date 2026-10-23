#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

home="$test_dir/home"
source_css="$home/.local/state/omarchy/current/theme/superproductivity.css"
user_data="$home/.config/superProductivity"
target="$user_data/styles.css"
mkdir -p "${source_css%/*}"

sync_theme() {
  HOME="$home" XDG_CONFIG_HOME= bash "$ROOT/bin/omarchy-theme-set-superproductivity" 2>/dev/null
}

backups() {
  compgen -G "$target.bak.*" || true
}

printf 'body { --sp-bg: #000000; }\n' >"$source_css"
sync_theme
[[ ! -e $user_data ]] || fail "a theme switch creates no state dir for an app never opened"
pass "Super Productivity is left alone until it has run once"

mkdir -p "$user_data"
sync_theme
[[ $(tail -n +2 "$target") == "$(<"$source_css")" ]] || fail "the stylesheet lands below its ownership header"
[[ -z $(backups) ]] || fail "a first write with nothing in place keeps no backup"
pass "the theme is written into a fresh install"

printf 'body { --sp-bg: #ffffff; }\n' >"$source_css"
sync_theme
grep -q '#ffffff' "$target" || fail "a theme switch replaces Omarchy's own stylesheet"
[[ -z $(backups) ]] || fail "replacing Omarchy's own unedited stylesheet keeps no backup"
pass "Omarchy's own stylesheet is replaced without a backup"

printf '.my-rule { color: red; }\n' >>"$target"
edited=$(<"$target")
sync_theme
backup=$(backups)
[[ -n $backup && $(<"$backup") == "$edited" ]] || fail "rules added to Omarchy's stylesheet are backed up"
grep -q '#ffffff' "$target" && ! grep -q 'my-rule' "$target" || fail "the edited stylesheet is replaced"
pass "a user's edits to Omarchy's stylesheet are backed up"

rm -f "$target".bak.*
printf '.mine { color: blue; }\n' >"$target"
sync_theme
backup=$(backups)
[[ -n $backup && $(<"$backup") == '.mine { color: blue; }' ]] || fail "a stylesheet the user wrote is backed up"
pass "a stylesheet without Omarchy's header is backed up"

rm -f "$target".bak.*
dotfile="$test_dir/dotfiles/styles.css"
mkdir -p "${dotfile%/*}"
sync_theme
cp "$target" "$dotfile"
ln -sfn "$dotfile" "$target"
sync_theme
backup=$(backups)
[[ -L $backup && $(readlink "$backup") == "$dotfile" ]] || fail "a symlinked stylesheet is kept as the link"
[[ -f $target && ! -L $target ]] || fail "the symlink is replaced by Omarchy's stylesheet"
pass "a symlink into the user's dotfiles is kept aside, never treated as Omarchy's"

rm -f "$target".bak.*
printf 'body { color: {{ foreground }}; }\n' >"$source_css"
before=$(<"$target")
sync_theme
[[ $(<"$target") == "$before" && -z $(backups) ]] || fail "an unresolved template leaves the stylesheet alone"
pass "a theme with unresolved colors changes nothing"
