#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

system="$ROOT/default/hypr/apps/system.lua"

grep -Fq 'o.window("omacalc", { float = true })' "$system" ||
  fail "omacalc floats by default"
grep -Fq 'o.window("omacalc", { center = true })' "$system" ||
  fail "omacalc is centered when floating"
grep -Fq 'o.window("omacalc", { size = { 420, 640 } })' "$system" ||
  fail "omacalc has an explicit floating size so fullscreen toggle cannot keep monitor geometry"
pass "omacalc returns to a small centered float after fullscreen toggle"
