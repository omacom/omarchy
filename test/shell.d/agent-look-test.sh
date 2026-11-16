#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command magick

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

look_theme() {
  "$ROOT/bin/omarchy-agent-look-theme" "$1" --out "$test_tmp/preview.png"
}

# A stock theme is what a good theme looks like: nothing to report.
cp -r "$ROOT/themes/kanagawa" "$test_tmp/good"
output=$(look_theme "$test_tmp/good") || fail "a stock theme passes the theme check" "$output"
[[ -s $test_tmp/preview.png ]] || fail "the theme check draws a preview" "$output"
pass "a stock theme passes the theme check and is drawn"

# The mistakes small models make: a palette missing keys, text the color of
# the background, and a small, flat background drawn in code.
mkdir -p "$test_tmp/bad/backgrounds"
cat >"$test_tmp/bad/colors.toml" <<'EOF'
mode = "dark"
accent = "#a8c08a"
background = "#1a120c"
foreground = "#2b1e13"
EOF
magick -size 800x450 xc:'#20160f' "$test_tmp/bad/backgrounds/1-drawn.png"
if output=$(look_theme "$test_tmp/bad"); then
  fail "a broken theme fails the theme check" "$output"
fi
for problem in "colors.toml is missing" "foreground #2b1e13 on background" "under 1920x1080" "nearly flat"; do
  [[ $output == *"$problem"* ]] || fail "the theme check reports: $problem" "$output"
done
pass "the theme check names missing keys, unreadable text, and small or flat backgrounds"

# A color the preview can't read is drawn gray, so it has to be named, or the
# check passes a theme while showing a color it never specified.
cp -r "$ROOT/themes/kanagawa" "$test_tmp/typo"
sed -i -E -e 's/^blue = .*/blue = "#GGGGGG"/' -e 's/^red = .*/red = "#ffffff-typo"/' "$test_tmp/typo/colors.toml"
if output=$(look_theme "$test_tmp/typo"); then
  fail "a theme with an unreadable color fails the theme check" "$output"
fi
[[ $output == *"aren't #rrggbb: "*"red #ffffff-typo"*"blue #GGGGGG"* ]] || fail "the theme check names the unreadable colors" "$output"

# Omarchy reads a color between single quotes as well as double, and ignores
# a comment after it.
cp -r "$ROOT/themes/kanagawa" "$test_tmp/single"
sed -i -E -e "s/^(accent = )\"(.*)\"/\\1'\\2'/" -e 's/^(blue = .*)$/\1 # the links/' "$test_tmp/single/colors.toml"
grep -q "^accent = '#" "$test_tmp/single/colors.toml" && grep -q '^blue = "#.*" # the links$' "$test_tmp/single/colors.toml" ||
  fail "the fixture has a single-quoted color and a commented one"
output=$(look_theme "$test_tmp/single") || fail "a single-quoted or commented color is read as Omarchy reads it" "$output"
pass "the theme check names a color that isn't #rrggbb"
