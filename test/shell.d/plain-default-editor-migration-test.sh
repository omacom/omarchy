#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
migration="$ROOT/migrations/1794341736.sh"

run_migration() {
  local test_home="$1"
  (
    cd "$test_home"
    env -i HOME="$test_home" PATH="/usr/bin" bash -euo pipefail "$migration" >/dev/null
  )
}

new_home() {
  local test_home="$test_tmp/$1"
  mkdir -p "$test_home/.config"
  echo "$test_home"
}

editor_of() { cat "$1/.local/state/omarchy/defaults/editor"; }
default_for() { awk -F= -v type="$2" '/^\[/ { d = ($0 == "[Default Applications]") } d && $1 == type { print $2 }' "$1/.config/mimeapps.list"; }

# An install with no saved editor and no personal mimeapps.list keeps Neovim.
home=$(new_home untouched)
run_migration "$home"
[[ $(editor_of "$home") == "nvim" ]] || fail "an existing install without a saved editor keeps Neovim"
[[ $(default_for "$home" text/plain) == "nvim.desktop" ]] || fail "text files keep opening in Neovim"
[[ $(default_for "$home" text/xml) == "nvim.desktop" ]] || fail "every packaged text type is kept on Neovim"
pass "an untouched existing install keeps Neovim as editor and for text files"

# An explicit editor choice and personal associations are left alone.
home=$(new_home chosen)
mkdir -p "$home/.local/state/omarchy/defaults"
printf 'code\n' >"$home/.local/state/omarchy/defaults/editor"
cat >"$home/.config/mimeapps.list" <<'LIST'
[Added Associations]
text/xml=org.gnome.TextEditor.desktop;

[Default Applications]
text/plain=org.gnome.TextEditor.desktop
x-scheme-handler/https=omarchy-browser.desktop
LIST
run_migration "$home"
[[ $(editor_of "$home") == "code" ]] || fail "an explicit editor choice is kept"
[[ $(default_for "$home" text/plain) == "org.gnome.TextEditor.desktop" ]] || fail "a personal text/plain default is kept"
[[ $(default_for "$home" text/xml) == "nvim.desktop" ]] || fail "an added association doesn't count as a default"
[[ $(default_for "$home" x-scheme-handler/https) == "omarchy-browser.desktop" ]] || fail "other defaults are kept"
[[ $(grep -c '^text/plain=' "$home/.config/mimeapps.list") == 1 ]] || fail "a set type isn't written twice"
pass "explicit choices are kept and only unset text types are pinned"

# A list without a [Default Applications] section gets one, and a symlinked
# list stays a symlink.
home=$(new_home linked)
mkdir -p "$home/dotfiles"
printf '[Added Associations]\nimage/png=imv.desktop;\n' >"$home/dotfiles/mimeapps.list"
ln -s "$home/dotfiles/mimeapps.list" "$home/.config/mimeapps.list"
run_migration "$home"
[[ -L $home/.config/mimeapps.list ]] || fail "a symlinked mimeapps.list stays a symlink"
[[ $(default_for "$home" text/plain) == "nvim.desktop" ]] || fail "a list without defaults gets the Neovim ones"
grep -qxF "image/png=imv.desktop;" "$home/dotfiles/mimeapps.list" || fail "existing associations are kept"
pass "a symlinked list without defaults is extended in place"

# Running it again changes nothing.
before=$(cat "$home/.config/mimeapps.list")
run_migration "$home"
[[ $(cat "$home/.config/mimeapps.list") == "$before" ]] || fail "the migration is idempotent"
pass "the migration is idempotent"
