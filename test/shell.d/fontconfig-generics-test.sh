#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# 50-omarchy.conf must leave a request for a missing font with no strongly bound
# family but its own. WebKitGTK takes any strongly bound family in the answer as
# the font it asked for, so a strong Liberation Sans (or Naskh) drew CSS's
# "Della Respira", serif in sans-serif and never reached the serif. fc-pattern
# prints each family's binding after substitution, which is what WebKitGTK reads.

require_command fc-pattern

if [[ ! -f /etc/fonts/fonts.conf || ! -d /etc/fonts/conf.d ]]; then
  skip "fontconfig generics: no system fontconfig at /etc/fonts"
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# The system's configuration with the checkout's 50-omarchy.conf in place of the
# installed one, read through FONTCONFIG_FILE by this test only.
mkdir -p "$tmp/conf.d"
for conf in /etc/fonts/conf.d/*; do
  ln -s "$(readlink -f "$conf")" "$tmp/conf.d/$(basename "$conf")"
done
ln -sfn "$ROOT/default/fontconfig/conf.avail/50-omarchy.conf" "$tmp/conf.d/50-omarchy.conf"
sed "s|<include ignore_missing=\"yes\">conf.d</include>|<include ignore_missing=\"yes\">$tmp/conf.d</include>|" \
  /etc/fonts/fonts.conf >"$tmp/fonts.conf"
grep -Fq "$tmp/conf.d" "$tmp/fonts.conf" || fail "fontconfig generics: fonts.conf includes conf.d" "$(<"$tmp/fonts.conf")"

# The C locale, so no language rule adds a family of its own, and a scratch home,
# so no user configuration (50-user.conf) reaches the patterns.
mkdir -p "$tmp/home"
strong_families() {
  HOME="$tmp/home" LC_ALL=C LANG=C FONTCONFIG_FILE="$tmp/fonts.conf" fc-pattern -c "$1" family | grep -o '"[^"]*"(s)' | tr '\n' ' '
}

for request in "Della Respira" "NoSuchFont"; do
  strong=$(strong_families "$request")
  [[ $strong == "\"$request\"(s) " ]] || fail "fontconfig generics: a missing $request binds no other family strongly" "$strong"
done
pass "fontconfig generics: a missing named font binds no other family strongly"

for pair in "sans\\-serif:Liberation Sans" "serif:Liberation Serif" "monospace:JetBrainsMono Nerd Font"; do
  generic=${pair%%:*} # fc-pattern reads an unescaped "-" as the start of a size
  face=${pair#*:}
  strong=$(strong_families "$generic")
  [[ $strong == "\"$face\"(s) "* ]] || fail "fontconfig generics: $generic is $face first" "$strong"
done
pass "fontconfig generics: each generic family is its Omarchy face first"

strong=$(strong_families ":charset=0627")
[[ $strong == *'"Noto Naskh Arabic"(s)'* ]] ||
  fail "fontconfig generics: an Arabic character's request binds Naskh strongly" "$strong"
pass "fontconfig generics: an Arabic character's request binds Naskh strongly"
