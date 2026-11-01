#!/bin/bash

set -euo pipefail

# omarchy-theme-set-zen edits files in profiles the user also edits: it must
# find every profile Zen lists, add its import and prefs once however often a
# theme is set, keep the user's own CSS and prefs, follow the transparency
# mode, and give the files back exactly on --remove.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
theme_dir="$home/.local/state/omarchy/current/theme"
toggles="$home/.local/state/omarchy/toggles/hypr"
legacy="$home/.zen/abc.Default (release)"
fresh="$home/.config/zen/xyz.Default"
linked="$test_tmp/linked profile"
flatpak="$home/.var/app/app.zen_browser.zen/.zen/flat.Default"

mkdir -p "$theme_dir" "$toggles" "$legacy/chrome" "$fresh" "$linked/chrome" "$flatpak/chrome"
printf '[Profile0]\nName=Default\nIsRelative=1\nPath=abc.Default (release)\n\n[General]\nVersion=2\n' >"$home/.zen/profiles.ini"
printf '[Profile0]\nName=Other\nIsRelative=1\nPath=xyz.Default\n\n[Profile1]\nIsRelative=0\nPath=%s\n' "$linked" >"$home/.config/zen/profiles.ini"
printf '[Profile0]\nIsRelative=1\nPath=flat.Default\n' >"${flatpak%/*}/profiles.ini"
printf '#nav-bar { color: red; }' >"$legacy/chrome/userChrome.css"
printf 'user_pref("browser.example", 1);' >"$legacy/user.js"
cp "$legacy/chrome/userChrome.css" "$test_tmp/userChrome.orig"
cp "$legacy/user.js" "$test_tmp/user.js.orig"
cp "$test_tmp/userChrome.orig" "$test_tmp/linked-userChrome.css"
cp "$test_tmp/user.js.orig" "$test_tmp/linked-user.js"
ln -s "$test_tmp/linked-userChrome.css" "$linked/chrome/userChrome.css"
ln -s "$test_tmp/linked-user.js" "$linked/user.js"
: >"$flatpak/chrome/userChrome.css"
: >"$flatpak/user.js"
printf ':root { --omarchy-background-rgb: 26,27,38; }\n' >"$theme_dir/zen.css"

run() {
  HOME="$home" XDG_CONFIG_HOME="$home/.config" XDG_STATE_HOME="$home/.local/state" \
    OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" omarchy-theme-set-zen "$@"
}

run
run

for profile in "$legacy" "$fresh" "$linked" "$flatpak"; do
  [[ -f $profile/chrome/omarchy.css ]] || fail "theme copied into $(basename "$profile")"
  (( $(grep -c 'omarchy-zen begin' "$profile/chrome/userChrome.css") == 1 )) || fail "one import block in $(basename "$profile")"
  (( $(grep -c 'omarchy-zen begin' "$profile/user.js") == 1 )) || fail "one pref block in $(basename "$profile")"
done
[[ $(head -2 "$legacy/chrome/userChrome.css" | tail -1) == '@import url("omarchy.css");' ]] || fail "import comes before the user's rules"
grep -qF '#nav-bar { color: red; }' "$legacy/chrome/userChrome.css" || fail "user's CSS is kept"
grep -qxF 'user_pref("browser.example", 1);' "$legacy/user.js" || fail "user's prefs are kept"
grep -qF -- '--omarchy-zen-glass: 0.985;' "$legacy/chrome/omarchy.css" || fail "transparent mode is the default"
[[ -L $linked/chrome/userChrome.css && -L $linked/user.js ]] || fail "theme updates keep links to the user's dotfiles"
pass "theme lands once in every profile and keeps the user's files and links"

touch "$toggles/window-glassy.lua"
run
grep -qF -- '--omarchy-zen-glass: 0.65;' "$legacy/chrome/omarchy.css" || fail "glassy follows the terminals"
rm "$toggles/window-glassy.lua"
touch "$toggles/window-opaque.lua"
run
grep -qF -- '--omarchy-zen-glass: 1;' "$legacy/chrome/omarchy.css" || fail "opaque is solid"
grep -qF 'user_pref("zen.widget.linux.transparency", false);' "$legacy/user.js" || fail "opaque turns Zen's transparency off"
pass "glass follows the window transparency mode"

printf ':root { --x: {{ background }}; }\n' >"$theme_dir/zen.css"
cp "$legacy/chrome/omarchy.css" "$test_tmp/omarchy.css.before"
run 2>/dev/null
cmp -s "$test_tmp/omarchy.css.before" "$legacy/chrome/omarchy.css" || fail "unresolved colors keep the previous theme"
pass "a theme with unresolved colors is skipped"

run --remove
cmp -s "$test_tmp/userChrome.orig" "$legacy/chrome/userChrome.css" || fail "--remove restores userChrome.css exactly"
cmp -s "$test_tmp/user.js.orig" "$legacy/user.js" || fail "--remove restores user.js exactly"
[[ ! -e $legacy/chrome/omarchy.css ]] || fail "--remove deletes the theme"
[[ ! -e $fresh/chrome && ! -e $fresh/user.js ]] || fail "--remove deletes files it created"
[[ -L $linked/chrome/userChrome.css && -L $linked/user.js ]] || fail "--remove keeps links to the user's dotfiles"
cmp -s "$test_tmp/userChrome.orig" "$test_tmp/linked-userChrome.css" || fail "--remove restores the linked CSS target exactly"
cmp -s "$test_tmp/user.js.orig" "$test_tmp/linked-user.js" || fail "--remove restores the linked pref target exactly"
[[ -f $flatpak/chrome/userChrome.css && ! -s $flatpak/chrome/userChrome.css ]] || fail "--remove keeps an existing empty CSS file"
[[ -f $flatpak/user.js && ! -s $flatpak/user.js ]] || fail "--remove keeps an existing empty prefs file"
pass "--remove gives the profiles back as they were"
