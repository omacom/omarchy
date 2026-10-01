#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

system="$ROOT/default/hypr/apps/system.lua"

grep -Fq 'o.window("omacalc", { float = true })' "$system" ||
  fail "omacalc floats by default"
grep -Fq 'o.window("omacalc", { center = true })' "$system" ||
  fail "omacalc default rule declares centering"
grep -Fq 'o.window("omacalc", { size = { 420, 640 } })' "$system" ||
  fail "omacalc default rule declares a 420x640 size"
pass "omacalc default rules declare floating, centering, and a 420x640 size"
