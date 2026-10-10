#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

upgrade_script="$ROOT/bin/omarchy-upgrade-to-quattro"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

migration_functions=$(sed -n '/^legacy_hypr_input_value() {/,/^migrate_uwsm_env_customizations() {/p' "$upgrade_script" | sed '$d')

migration_functions=${migration_functions//\/etc\/vconsole.conf/$tmp_dir/vconsole.conf}

run_migration() {
  local home="$1" vconsole="${2-}"
  printf '%s\n' "$vconsole" >"$tmp_dir/vconsole.conf"
  printf '%s\nmigrate_legacy_hypr_input\n' "$migration_functions" | HOME="$home" bash -euo pipefail
}

home="$tmp_dir/custom"
mkdir -p "$home/.config/hypr"
cat >"$home/.config/hypr/input.lua" <<'LUA'
-- Quattro input overrides
LUA
cat >"$home/.config/hypr/input.conf" <<'CONF'
device {
  name = example-keyboard
  kb_options = ignored:device_option
}

input {
  kb_layout = no
  kb_variant =
  kb_model = pc105
  kb_options = compose:caps,grp:alt_shift_toggle # Keep AltGr available.
  kb_rules = evdev

  touchpad {
    natural_scroll = true
  }
}
CONF

run_migration "$home" "XKBVARIANT=nodeadkeys"
run_migration "$home" "XKBVARIANT=nodeadkeys"

input_lua="$home/.config/hypr/input.lua"
grep -F '    kb_layout = "no",' "$input_lua" >/dev/null || fail "Quattro upgrade preserves the legacy keyboard layout"
grep -F '    kb_variant = "",' "$input_lua" >/dev/null || fail "Quattro upgrade preserves an empty legacy keyboard variant"
grep -F '    kb_model = "pc105",' "$input_lua" >/dev/null || fail "Quattro upgrade preserves the legacy keyboard model"
grep -F '    kb_options = "compose:caps,grp:alt_shift_toggle",' "$input_lua" >/dev/null || fail "Quattro upgrade preserves legacy keyboard options"
grep -F '    kb_rules = "evdev",' "$input_lua" >/dev/null || fail "Quattro upgrade preserves legacy keyboard rules"
! grep -Fq 'ignored:device_option' "$input_lua" || fail "Quattro upgrade ignores per-device keyboard options"
[[ $(grep -Fc 'Preserved from legacy ~/.config/hypr/input.conf' "$input_lua") == 1 ]] || fail "legacy keyboard migration is idempotent"
pass "Quattro upgrade preserves legacy keyboard input overrides"

home="$tmp_dir/no-overrides"
mkdir -p "$home/.config/hypr"
printf '%s\n' '-- Quattro input overrides' >"$home/.config/hypr/input.lua"
printf '%s\n' '# No active input block' >"$home/.config/hypr/input.conf"
before=$(sha256sum "$home/.config/hypr/input.lua")
run_migration "$home"
after=$(sha256sum "$home/.config/hypr/input.lua")
[[ $after == "$before" ]] || fail "Quattro upgrade leaves input.lua unchanged without legacy overrides"
pass "Quattro upgrade skips legacy input files without overrides"

home="$tmp_dir/stock"
mkdir -p "$home/.config/hypr"
printf '%s\n' '-- Quattro input overrides' >"$home/.config/hypr/input.lua"
cat >"$home/.config/hypr/input.conf" <<'CONF'
input {
  kb_layout = ru
  kb_options = compose:caps # ,grp:alts_toggle
  repeat_rate = 40
}
CONF
before=$(sha256sum "$home/.config/hypr/input.lua")
run_migration "$home" "XKBLAYOUT=ru"
after=$(sha256sum "$home/.config/hypr/input.lua")
[[ $after == "$before" ]] || fail "Quattro upgrade leaves installer-written keyboard settings to the Quattro defaults"
pass "Quattro upgrade skips stock legacy keyboard settings"

for vconsole in "XKBLAYOUT='ru'" ' XKBLAYOUT = "ru" # default' $'XKBLAYOUT=us\nXKBLAYOUT=ru'; do
  run_migration "$home" "$vconsole"
  [[ $before == $(sha256sum "$home/.config/hypr/input.lua") ]] || fail "quoted stock layouts keep the derived Latin layout"
done
pass "vconsole defaults follow Lua quoting, comments and last-assignment rules"

home="$tmp_dir/later-overrides"
mkdir -p "$home/.config/hypr"
printf '%s\n' '-- Quattro input overrides' >"$home/.config/hypr/input.lua"
cat >"$home/.config/hypr/input.conf" <<'CONF'
input {
  kb_options = compose:caps
  kb_options = compose:caps,grp:alt_shift_toggle
  touchpad {
    kb_options = ignored:nested
  }
}
input {
  kb_layout = fr
}
CONF
run_migration "$home" 'XKBLAYOUT=us'
grep -Fq 'kb_options = "compose:caps,grp:alt_shift_toggle"' "$home/.config/hypr/input.lua" || fail "later options override the stock assignment"
grep -Fq 'kb_layout = "fr"' "$home/.config/hypr/input.lua" || fail "settings in later input blocks are carried across"
! grep -q 'ignored:nested' "$home/.config/hypr/input.lua" || fail "nested settings do not replace top-level settings"
pass "last top-level keyboard assignments survive the upgrade"

copy_line=$(grep -n '^copy_always_config_defaults$' "$upgrade_script" | cut -d: -f1)
migrate_line=$(grep -n '^migrate_legacy_hypr_input$' "$upgrade_script" | cut -d: -f1)
[[ -n $copy_line && -n $migrate_line ]] || fail "Quattro input copy and migration calls exist"
(( copy_line < migrate_line )) || fail "legacy input overrides are applied after the Quattro template is copied"
pass "Quattro upgrade migrates input overrides after installing the template"
