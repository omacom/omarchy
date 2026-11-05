#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command magick

export PATH="$ROOT/bin:$PATH"

test_tmp=$(mktemp -d)
trap 'rm -rf -- "$test_tmp"' EXIT

# The themes' unlock logos are the stock screensaver wordmark drawn as pixels,
# so the stock art has to come back as the logo they ship. Theirs was scaled to
# 800 pixels wide, a 9.88-pixel column where this draws 10, so it is compared
# at their size, where only the one-pixel seams of that scaling may differ.
omarchy-transcode-logo "$ROOT/logo.txt" "$test_tmp/wordmark.png" --color '#82fb9c' >/dev/null
size=$(magick identify -format '%wx%h' "$test_tmp/wordmark.png")
[[ $size == "810x190" ]] || fail "the stock art draws ten pixels to a column" "got $size"

differing=$(magick \( "$test_tmp/wordmark.png" -sample '800x188!' -alpha extract \) \
  \( "$ROOT/themes/hackerman/unlock.png" -alpha extract \) -metric AE -compare -format '%[distortion]' info:)
awk -v differing="$differing" 'BEGIN { exit !(differing < 0.02) }' ||
  fail "the stock art draws the unlock logo the themes ship" "$differing of the pixels differ"
pass "the stock art draws the unlock logo the themes ship"

# ⡇ is the left column of dots only, so the pair is three dots wide. Reading
# braille as a solid block, or its dot bits in the wrong order, widens it.
printf '⣿⡇\n' >"$test_tmp/braille.txt"
omarchy-transcode-logo "$test_tmp/braille.txt" "$test_tmp/braille.png" >/dev/null
size=$(magick identify -format '%wx%h' "$test_tmp/braille.png")
[[ $size == "15x20" ]] || fail "braille dots land in their own places" "got $size"
pass "braille dots land in their own places"

# Typed letters have no pixels, so they are named instead of drawn as nothing.
printf 'Hi\n' >"$test_tmp/typed.txt"
if output=$(omarchy-transcode-logo "$test_tmp/typed.txt" "$test_tmp/typed.png" 2>&1); then
  fail "typed letters are refused" "$output"
fi
[[ $output == *"H i"* ]] || fail "the refusal names the letters it can't draw" "$output"
[[ ! -e $test_tmp/typed.png ]] || fail "a refused drawing writes no logo"
pass "typed letters are refused by name"
