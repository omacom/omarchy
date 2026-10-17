#!/bin/bash
source "$(dirname "$0")/base-test.sh"

# omarchy dev font add --codepoint must stay inside the private-use area.
# The "already used" check only sees PUA marks, so without a range guard a
# --codepoint like U+0041 silently remaps an existing (or future) glyph slot.

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

cp "$ROOT/default/fonts/omarchy/omarchy.ttf" "$tmp/test.ttf"
printf '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M4 4h16v16H4z"/></svg>' >"$tmp/mark.svg"

md5_before=$(md5sum "$tmp/test.ttf" | cut -d' ' -f1)

# 1. A non-PUA codepoint is refused before the font is touched.
if python3 "$ROOT/bin/omarchy-dev-font" add testmark "$tmp/mark.svg" \
  --codepoint U+0041 --font "$tmp/test.ttf" 2>"$tmp/err.txt"; then
  fail "--codepoint U+0041 is rejected"
fi
grep -q "outside the private-use range" "$tmp/err.txt" ||
  fail "--codepoint U+0041 names the private-use range" "$(cat "$tmp/err.txt")"
[[ $(md5sum "$tmp/test.ttf" | cut -d' ' -f1) == "$md5_before" ]] ||
  fail "refused --codepoint leaves the font file untouched"
pass "--codepoint outside the PUA is rejected and the font is untouched"

# 2. A malformed codepoint fails cleanly instead of a traceback.
if python3 "$ROOT/bin/omarchy-dev-font" add testmark "$tmp/mark.svg" \
  --codepoint xyz --font "$tmp/test.ttf" 2>"$tmp/err2.txt"; then
  fail "malformed --codepoint is rejected"
fi
grep -q "Traceback" "$tmp/err2.txt" &&
  fail "malformed --codepoint has no traceback" "$(cat "$tmp/err2.txt")"
pass "malformed --codepoint fails with a clean error"

# 3. A free PUA codepoint still works (positive control).
python3 "$ROOT/bin/omarchy-dev-font" add testmark "$tmp/mark.svg" \
  --codepoint U+E9FF --font "$tmp/test.ttf" >/dev/null 2>&1 ||
  fail "--codepoint U+E9FF (free PUA slot) is accepted"
python3 "$ROOT/bin/omarchy-dev-font" list --font "$tmp/test.ttf" |
  grep -q "^U+E9FF" ||
  fail "U+E9FF shows up in the font's mark list"
pass "--codepoint U+E9FF (free PUA slot) is accepted and listed"
