#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

font="$test_dir/omarchy.ttf"
cp "$ROOT/default/fonts/omarchy/omarchy.ttf" "$font"
printf '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M4 4h16v16H4z"/></svg>' >"$test_dir/mark.svg"

dev_font() {
  "$ROOT/bin/omarchy-dev-font" "$@" --font "$font"
}

glyph_name() {
  awk -v cp="$1" '$1 == cp { print $3 }' <<<"$2"
}

before=$(dev_font list)
dev_font alias U+E902 U+100001 >/dev/null
after=$(dev_font list)
[[ $(glyph_name U+100001 "$after") == "opencode" ]] || fail "alias maps the new codepoint to the existing mark"
[[ $(grep -v '^U+100001 ' <<<"$after") == "$before" ]] || fail "alias leaves every existing mapping unchanged"
pass "dev font alias adds a codepoint for an existing mark"

aliased=$(sha256sum <"$font")
for args in "U+E902 U+E903" "U+E9FF U+100002" "U+E902 U+FFFF" "U+E902 U+110000" "U+E902 xyz"; do
  read -ra codepoints <<<"$args"
  if dev_font alias "${codepoints[@]}" >/dev/null 2>"$test_dir/err"; then
    fail "alias refuses $args"
  fi
  ! grep -q Traceback "$test_dir/err" || fail "alias refuses $args without a traceback" "$(cat "$test_dir/err")"
done
[[ $(sha256sum <"$font") == "$aliased" ]] || fail "refused aliases leave the font untouched"
pass "dev font alias refuses used, missing, and out-of-range codepoints"

[[ $(dev_font add testmark "$test_dir/mark.svg") == "Added testmark as U+E90F"* ]] ||
  fail "add continues the U+E9xx run past codepoints beyond the BMP"
[[ $(glyph_name U+100000 "$(dev_font list)") == "omarchy" ]] || fail "add keeps the terminal Omarchy mark"
pass "dev font add numbers new marks after the U+E9xx run"
