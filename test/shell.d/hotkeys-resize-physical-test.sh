#!/bin/bash

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

manual="$ROOT/manual/07-hotkeys.md"
tiling="$ROOT/default/hypr/bindings/tiling.lua"

grep -q 'Super + Minus' "$manual" || fail "manual still names Super + Minus"
grep -q 'Super + Equal' "$manual" || fail "manual still names Super + Equal"
grep -q 'code:20' "$manual" || fail "manual documents code:20 next to Minus/Equal"
grep -q 'AE11' "$manual" || fail "manual documents AE11 next to Minus/Equal"
grep -q 'code:21' "$manual" || fail "manual documents code:21 next to Equal"
grep -q 'AE12' "$manual" || fail "manual documents AE12 next to Equal"

grep -q 'SUPER + code:20' "$tiling" || fail "tiling.lua still binds SUPER + code:20"
grep -q 'SUPER + code:21' "$tiling" || fail "tiling.lua still binds SUPER + code:21"
if grep -E -q 'SUPER \+ MINUS|SUPER \+ EQUAL' "$tiling"; then
  fail "tiling.lua retargeted resize to MINUS/EQUAL keysyms"
fi

pass "resize chords stay physical AE11/AE12 with documented aliases"
