#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1789487100.sh"
test_root=$(mktemp -d)
trap 'rm -rf "$test_root"' EXIT

new_home() {
  local name=$1
  TEST_HOME="$test_root/$name"
  rm -rf "$TEST_HOME"
  mkdir -p "$TEST_HOME/.config/hypr"
  BACKUP="$TEST_HOME/.local/share/omarchy.omarchy-upgrade-to-quattro.20260915120000.bak"
  mkdir -p "$BACKUP/config/hypr" "$BACKUP/default/hypr"
}

run_live_migration() {
  HOME="$TEST_HOME" OMARCHY_UPGRADE_TO_QUATTRO_LIVE=1 \
    bash -euo pipefail "$migration" 2>&1
}

new_home unchanged
printf 'bind = SUPER, RETURN, exec, foot\n' >"$TEST_HOME/.config/hypr/bindings.conf"
cp "$TEST_HOME/.config/hypr/bindings.conf" "$BACKUP/config/hypr/bindings.conf"
output=$(run_live_migration)
! grep -Fq 'legacy Hyprland config differs' <<<"$output" ||
  fail "unchanged legacy Hyprland config stays quiet"
[[ ! -e $TEST_HOME/.config/omarchy/hooks/post-boot.d/quattro-legacy-hypr-config-warning ]] ||
  fail "unchanged legacy Hyprland config creates no post-boot warning"
pass "unchanged legacy Hyprland config stays quiet"

new_home modified
printf 'bind = SUPER, RETURN, exec, foot\n' >"$BACKUP/config/hypr/bindings.conf"
printf 'bind = SUPER, RETURN, exec, kitty\n' >"$TEST_HOME/.config/hypr/bindings.conf"
output=$(run_live_migration)
grep -Fq 'legacy Hyprland config differs from the pre-upgrade Omarchy defaults' <<<"$output" ||
  fail "modified legacy Hyprland config is reported in the upgrade terminal"
grep -Fxq '  bindings.conf' <<<"$output" ||
  fail "modified bindings.conf is named in the upgrade warning"
hook="$TEST_HOME/.config/omarchy/hooks/post-boot.d/quattro-legacy-hypr-config-warning"
[[ -x $hook ]] || fail "modified legacy config leaves an executable post-boot warning"
grep -Fq 'omarchy-notification-send -u critical' "$hook" ||
  fail "post-boot warning uses a critical notification"
grep -Fq 'Legacy Hyprland settings need review' "$hook" ||
  fail "post-boot warning explains what needs review"
grep -Fq 'rm -f "$0"' "$hook" ||
  fail "post-boot warning removes itself after successful delivery"
pass "modified legacy Hyprland config is reported now and after reboot"

new_home envs-reference
printf 'env = XCURSOR_SIZE,24\n' >"$TEST_HOME/.config/hypr/envs.conf"
printf 'env = THIS_IS_NOT_THE_REFERENCE,1\n' >"$BACKUP/config/hypr/envs.conf"
printf 'env = XCURSOR_SIZE,24\n' >"$BACKUP/default/hypr/envs.conf"
output=$(run_live_migration)
! grep -Fxq '  envs.conf' <<<"$output" ||
  fail "envs.conf is compared against default/hypr/envs.conf"
pass "envs.conf uses the correct pre-upgrade stock reference"

new_home missing-reference
printf 'monitor = eDP-1,preferred,auto,1\n' >"$TEST_HOME/.config/hypr/monitors.conf"
output=$(run_live_migration)
! grep -Fxq '  monitors.conf' <<<"$output" ||
  fail "missing stock references stay conservative"
pass "missing stock references do not create an unprovable customization warning"

new_home normal-update
printf 'bind = SUPER, RETURN, exec, kitty\n' >"$TEST_HOME/.config/hypr/bindings.conf"
printf 'bind = SUPER, RETURN, exec, foot\n' >"$BACKUP/config/hypr/bindings.conf"
output=$(HOME="$TEST_HOME" OMARCHY_UPGRADE_TO_QUATTRO_LIVE=0 bash -euo pipefail "$migration" 2>&1)
! grep -Fq 'legacy Hyprland config differs' <<<"$output" ||
  fail "normal Quattro updates do not emit legacy upgrade warnings"
[[ ! -e $TEST_HOME/.config/omarchy/hooks/post-boot.d/quattro-legacy-hypr-config-warning ]] ||
  fail "normal Quattro updates create no legacy upgrade hook"
pass "legacy comparison is scoped to the live Quattro upgrade"
