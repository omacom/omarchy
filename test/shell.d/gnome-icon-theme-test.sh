#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
data="$test_tmp/data"
mock_bin="$test_tmp/bin"
gsettings_log="$test_tmp/gsettings.log"
stderr_log="$test_tmp/stderr.log"
theme_dir="$home/.local/state/omarchy/current/theme"

mkdir -p "$theme_dir" "$mock_bin" \
  "$data/icons/Yaru-blue" "$data/icons/Adwaita" \
  "$home/.local/share/icons/Custom"
touch "$data/icons/Yaru-blue/index.theme" \
  "$data/icons/Adwaita/index.theme" \
  "$home/.local/share/icons/Custom/index.theme"

cat >"$mock_bin/omarchy-theme-color" <<'SH'
#!/bin/bash
printf 'dark\n'
SH

cat >"$mock_bin/gsettings" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$GSETTINGS_LOG"
SH

chmod +x "$mock_bin"/*

run_gnome_sync() {
  : >"$gsettings_log"
  : >"$stderr_log"
  GSETTINGS_LOG="$gsettings_log" \
    HOME="$home" \
    XDG_DATA_DIRS="$data" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=$test_tmp/bus" \
    PATH="$mock_bin:$PATH" \
    bash "$ROOT/bin/omarchy-theme-set-gnome" 2>"$stderr_log"
}

printf 'Custom\n' >"$theme_dir/icons.theme"
run_gnome_sync
grep -Fqx 'set org.gnome.desktop.interface icon-theme Custom' "$gsettings_log" ||
  fail "an installed configured icon theme is preserved" "$(cat "$gsettings_log")"
pass "installed configured icon themes are preserved"

printf 'Yaru-gray\n' >"$theme_dir/icons.theme"
run_gnome_sync
grep -Fqx 'set org.gnome.desktop.interface icon-theme Adwaita' "$gsettings_log" ||
  fail "a missing configured icon theme preserves the implicit Adwaita fallback" "$(cat "$gsettings_log")"
grep -Fq "Configured icon theme 'Yaru-gray' is not installed" "$stderr_log" ||
  fail "a missing configured icon theme is reported" "$(cat "$stderr_log")"
pass "missing configured icon themes fall back safely"

rm -f "$theme_dir/icons.theme"
run_gnome_sync
grep -Fqx 'set org.gnome.desktop.interface icon-theme Yaru-blue' "$gsettings_log" ||
  fail "themes without icons.theme keep the existing Yaru-blue default" "$(cat "$gsettings_log")"
pass "themes without icon metadata keep the existing default"

rm -f "$data/icons/Adwaita/index.theme"
printf 'Yaru-grey\n' >"$theme_dir/icons.theme"
run_gnome_sync
grep -Fqx 'set org.gnome.desktop.interface icon-theme Yaru-blue' "$gsettings_log" ||
  fail "fallback resolution continues to another installed standard theme" "$(cat "$gsettings_log")"
pass "fallback resolution requires an installed theme"

printf '../../etc\n' >"$theme_dir/icons.theme"
run_gnome_sync
grep -Fqx 'set org.gnome.desktop.interface icon-theme Yaru-blue' "$gsettings_log" ||
  fail "path-like icon theme names are rejected" "$(cat "$gsettings_log")"
pass "icon theme lookup remains inside icon search roots"
