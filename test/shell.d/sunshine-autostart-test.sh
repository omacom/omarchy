#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if grep -Fq 'launch_on_start("sunshine")' "$ROOT/bin/omarchy-install-service-sunshine"; then
  fail "Sunshine installer does not add a Hyprland autostart copy"
fi
pass "Sunshine installer does not add a Hyprland autostart copy"

grep -Fq 'o.launch_on_start("sunshine")' "$ROOT/bin/omarchy-remove-service-sunshine" ||
  fail "Sunshine removal still strips a leftover Hyprland autostart line"
pass "Sunshine removal still strips a leftover Hyprland autostart line"

grep -Fq 'systemctl --user enable --now sunshine' "$ROOT/bin/omarchy-install-service-sunshine" ||
  fail "Sunshine still autostarts through the user unit"
pass "Sunshine still autostarts through the user unit"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
home="$test_tmp/home"
mkdir -p "$home/.config/hypr"
autostart="$home/.config/hypr/autostart.lua"

cat >"$autostart" <<'LUA'
-- Extra autostart processes.
o.launch_on_start("my-service")
o.launch_on_start("sunshine")
LUA

HOME="$home" bash -euo pipefail "$ROOT/migrations/1789703649.sh" >/dev/null
grep -Fq 'o.launch_on_start("my-service")' "$autostart" ||
  fail "Sunshine migration leaves other autostart entries"
if grep -Fq 'o.launch_on_start("sunshine")' "$autostart"; then
  fail "Sunshine migration removes the duplicate autostart line"
fi
pass "Sunshine migration removes the duplicate autostart line"

HOME="$home" bash -euo pipefail "$ROOT/migrations/1789703649.sh" >/dev/null
grep -Fq 'o.launch_on_start("my-service")' "$autostart" ||
  fail "Sunshine migration is idempotent"
pass "Sunshine migration is idempotent"
