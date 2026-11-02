#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

unset FONTCONFIG_FILE FONTCONFIG_PATH

# The matrix needs real fonts behind every name it resolves. Read the list
# into a variable first: grep -q closing the pipe early would SIGPIPE
# fc-list and, under pipefail, read as a missing font.
installed_fonts=$(fc-list)
for family in "Adwaita Mono" "Liberation Mono" "JetBrains Mono" "JetBrainsMono Nerd Font" "Noto Sans Mono CJK KR"; do
  if ! grep -Fqi -- "$family" <<<"$installed_fonts"; then
    skip "fontconfig monospace scoping needs $family"
    exit 0
  fi
done

require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fake_home="$test_tmp/fakehome"
mkdir -p "$fake_home/.config"

# The setter's desktop side effects are stubbed; its fontconfig write is
# real and is what the assertions below resolve against.
stub_bin="$test_tmp/stubbin"
mkdir -p "$stub_bin"
for stub in omarchy-restart-shell omarchy-hook omarchy-notification-send omarchy-i18n; do
  printf '#!/bin/bash\nexit 0\n' >"$stub_bin/$stub"
done
# No terminals are running inside the rig, and probing the developer's real
# session would execute the notification path for no reason.
for stub in omarchy-cmd-present pgrep pkill; do
  printf '#!/bin/bash\nexit 1\n' >"$stub_bin/$stub"
done
chmod +x "$stub_bin"/*

set_generated_font() {
  HOME="$fake_home" XDG_CONFIG_HOME="$fake_home/.config" PATH="$stub_bin:$PATH" \
    "$ROOT/bin/omarchy-font-set" "$1" >/dev/null
}

candidate="$ROOT/default/fontconfig/conf.avail/51-omarchy.conf"
{
  echo '<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "fonts.dtd"><fontconfig>'
  echo "<dir>/usr/share/fonts</dir><cachedir>$test_tmp/cache</cachedir>"
  placed=false
  for conf in /etc/fonts/conf.d/*.conf; do
    name=${conf##*/}
    # Skip the installed rule, old name included: the candidate replaces it.
    [[ $name == "50-omarchy.conf" || $name == "51-omarchy.conf" ]] && continue
    if ! $placed && [[ $name > "51-omarchy.conf" ]]; then
      echo "<include>$candidate</include>"
      placed=true
    fi
    echo "<include>$conf</include>"
  done
  $placed || echo "<include>$candidate</include>"
  echo '</fontconfig>'
} >"$test_tmp/fonts.conf"

# env -i keeps a leaked XDG_CONFIG_HOME (or HOME) from loading the
# developer's real user config into the rig and invalidating the result.
rig() {
  env -i HOME="$fake_home" XDG_CONFIG_HOME="$fake_home/.config" FONTCONFIG_FILE="$test_tmp/fonts.conf" PATH="/usr/bin:/bin" LANG=C.UTF-8 "$@"
}

resolve() {
  rig fc-match -f '%{family[0]}\n' "$1"
}

explicit_families=("JetBrains Mono" "Liberation Mono" "Adwaita Mono" "JetBrainsMono Nerd Font")

check_matrix() {
  local chosen=$1
  local actual

  actual=$(resolve monospace)
  [[ $actual == "$chosen" ]] || fail "monospace resolves to the generated font ($chosen)" "$actual"

  local family
  for family in "${explicit_families[@]}"; do
    actual=$(resolve "$family")
    [[ $actual == "$family" ]] || fail "explicit $family resolves to itself with $chosen generated" "$actual"
  done

  # FC_DEBUG=7 prefixes edits a rule actually applied with "Substitute";
  # the bare rule listing repeats every Assign in the config, applied or not.
  # Read the output fully before grepping: grep -q closing the pipe early
  # would SIGPIPE fc-match and hide an applied assignment under pipefail.
  local debug
  for family in "${explicit_families[@]}"; do
    debug=$(rig FC_DEBUG=7 fc-match "$family" 2>&1)
    if grep -q 'Substitute Edit family Assign' <<<"$debug"; then
      fail "no Assign fires for explicit $family" "$debug"
    fi
  done
}

refresh_cache() {
  rig fc-cache >/dev/null
}

# A multi-family request naming an explicit family alongside the parser's
# shortened "sans" spelling must keep its explicit head: the sans
# normalization rewrites only the matched spelling.
actual_head=$(rig fc-pattern -c -f '%{family[0]}\n' "Liberation Sans,sans")
[[ $actual_head == "Liberation Sans" ]] || fail "a multi-family request keeps its explicit head" "$actual_head"
pass "the sans normalization preserves the rest of a multi-family request"

set_generated_font "Adwaita Mono"
refresh_cache
check_matrix "Adwaita Mono"
pass "the generated font wins bare monospace and explicit monospace families resolve to themselves"

set_generated_font "JetBrainsMono Nerd Font"
refresh_cache
check_matrix "JetBrainsMono Nerd Font"
pass "with the default generated font, bare monospace is the Nerd Font and explicit families are unchanged"

# A CJK preference is accepted through 50-user.conf before the generated
# file runs, so the generated rule must still win bare monospace there
# without wiping the preference's fallback.
OMARCHY_PATH="$ROOT" XDG_CONFIG_HOME="$fake_home/.config" \
  python3 "$ROOT/default/input-methods/configure.py" font kr
refresh_cache

set_generated_font "Adwaita Mono"
refresh_cache
actual=$(resolve monospace)
[[ $actual == "Adwaita Mono" ]] || fail "monospace resolves to the generated font with a CJK preference" "$actual"
actual=$(rig fc-pattern -c -f '%{family}\n' monospace)
[[ $actual == *"Noto Sans Mono CJK KR"* ]] || fail "the CJK fallback survives the generated rule" "$actual"
for family in "${explicit_families[@]}"; do
  actual=$(resolve "$family")
  [[ $actual == "$family" ]] || fail "explicit $family resolves to itself with a CJK preference" "$actual"
done
pass "a CJK preference keeps its fallback behind the generated font"
