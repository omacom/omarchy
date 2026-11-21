#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
home_dir="$test_tmp/home"
foot_ini="$home_dir/.config/foot/foot.ini"
shell_toml="$home_dir/.config/omarchy/shell.toml"
sizes_file="$home_dir/.local/state/omarchy/text-sizes"

mkdir -p "$stub_bin" "$home_dir/.config/foot" "$home_dir/.config/omarchy"

# Monitors come from OMARCHY_TEST_MONITORS: name=description pairs separated
# by ";", so a test can plug and unplug displays by env.
cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash

if [[ $1 == "monitors" && $2 == "all" && $3 == "-j" ]]; then
  json="["
  sep=""
  IFS=";" read -ra monitors <<<"$OMARCHY_TEST_MONITORS"
  for monitor in "${monitors[@]}"; do
    json+="$sep{\"name\":\"${monitor%%=*}\",\"description\":\"${monitor#*=}\"}"
    sep=","
  done
  printf '%s]' "$json"
else
  exit 1
fi
SH

cat >"$stub_bin/gsettings" <<'SH'
#!/bin/bash
[[ $1 == "get" ]] && echo "'Liberation Sans 11'"
exit 0
SH

cat >"$stub_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
echo 1
SH

cat >"$stub_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 1
SH

chmod +x "$stub_bin"/*

run_text_size() {
  HOME="$home_dir" \
    XDG_STATE_HOME="$home_dir/.local/state" \
    PATH="$stub_bin:$PATH" \
    OMARCHY_TEST_MONITORS="${OMARCHY_TEST_MONITORS:-}" \
    "$ROOT/bin/omarchy-display-text-size" "$@"
}

shell_base_size() {
  grep -oP '^base-size = \K[0-9]+' "$shell_toml" 2>/dev/null || echo default
}

foot_size() {
  grep -oP ':size=\K[0-9]+' "$foot_ini"
}

reset_configs() {
  printf '[main]\nfont=JetBrainsMono Nerd Font:size=9\n' >"$foot_ini"
  : >"$shell_toml"
  rm -f "$sizes_file"
}

laptop="eDP-1=BOE 0x0A5D"
desk="DP-3=Dell Inc. DELL U2720Q ABC123"

# Fresh state: a sync records the size in use for the displays it finds.
reset_configs
OMARCHY_TEST_MONITORS="$laptop" run_text_size sync
grep -Fx $'internal\tdefault' "$sizes_file" >/dev/null || fail "sync records the default size for the internal panel"
[[ $(shell_base_size) == "default" ]] || fail "sync leaves an unknown display at the current size"
pass "sync records the current size for displays seen for the first time"

# Setting a size while docked remembers it for that monitor, not the panel.
OMARCHY_TEST_MONITORS="$laptop;$desk" run_text_size 14
grep -Fx $'Dell Inc. DELL U2720Q ABC123\t14' "$sizes_file" >/dev/null || fail "setting a size records it for the external monitor"
grep -Fx $'internal\tdefault' "$sizes_file" >/dev/null || fail "setting a size keeps the internal panel entry"
[[ $(shell_base_size) == "14" ]] || fail "setting a size updates the shell base-size"
[[ $(foot_size) == "11" ]] || fail "setting a size updates the terminal size"
pass "setting a size remembers it for the connected external monitor"

# Undocking puts the panel's size back; docking again restores the monitor's.
OMARCHY_TEST_MONITORS="$laptop" run_text_size sync
[[ $(shell_base_size) == "default" ]] || fail "sync restores the default shell size on the internal panel"
[[ $(foot_size) == "9" ]] || fail "sync restores the default terminal size on the internal panel"
pass "sync restores the internal panel size after undocking"

OMARCHY_TEST_MONITORS="$laptop;$desk" run_text_size sync
[[ $(shell_base_size) == "14" ]] || fail "sync restores the shell size for the external monitor"
[[ $(foot_size) == "11" ]] || fail "sync restores the terminal size for the external monitor"
pass "sync restores the external monitor size after docking"

# Clamshell: the panel dropping out does not change the key, so no rewrite.
before=$(stat -c %y "$foot_ini")
OMARCHY_TEST_MONITORS="$desk" run_text_size sync
[[ $(shell_base_size) == "14" ]] || fail "sync keeps the external monitor size with the lid closed"
[[ $(stat -c %y "$foot_ini") == "$before" ]] || fail "sync leaves configs alone when the size already matches"
pass "closing the lid keeps the external monitor size"

# The same monitor on another port keeps its size; a new one adopts the current.
OMARCHY_TEST_MONITORS="$laptop;HDMI-A-1=Dell Inc. DELL U2720Q ABC123" run_text_size sync
[[ $(shell_base_size) == "14" ]] || fail "sync keys the size on the monitor, not the port"
pass "a monitor keeps its size across ports"

OMARCHY_TEST_MONITORS="$laptop;DP-4=LG Electronics LG ULTRAFINE 0" run_text_size sync
[[ $(shell_base_size) == "14" ]] || fail "sync keeps the current size for a monitor seen for the first time"
grep -Fx $'LG Electronics LG ULTRAFINE 0\t14' "$sizes_file" >/dev/null || fail "sync records the current size for a new monitor"
pass "a new monitor adopts the size in use"

# Two monitors form their own key, sorted so plug order does not matter.
OMARCHY_TEST_MONITORS="$laptop;DP-4=LG Electronics LG ULTRAFINE 0;$desk" run_text_size 16
OMARCHY_TEST_MONITORS="$laptop;$desk;DP-4=LG Electronics LG ULTRAFINE 0" run_text_size sync
[[ $(shell_base_size) == "16" ]] || fail "sync matches a pair of monitors regardless of plug order"
pass "a pair of monitors shares one size regardless of plug order"

# Reset remembers the default for the current displays.
OMARCHY_TEST_MONITORS="$laptop;$desk" run_text_size reset
grep -Fx $'Dell Inc. DELL U2720Q ABC123\tdefault' "$sizes_file" >/dev/null || fail "reset records the default for the external monitor"
[[ $(shell_base_size) == "default" ]] || fail "reset drops the shell base-size"
pass "reset remembers the default for the connected displays"

# Without Hyprland, everything keys on the internal panel and still works.
reset_configs
OMARCHY_TEST_MONITORS="" run_text_size 13
grep -Fx $'internal\t13' "$sizes_file" >/dev/null || fail "no monitors keys on the internal panel"
pass "no monitor information falls back to the internal panel"
