#!/bin/bash

# An older monitors.lua carried Omarchy's monitor defaults and the display
# panel's scale as connector rules. The upgrade leaves the new template plus
# whatever else the file held, and moves those rules into the saved settings
# of the monitors behind them.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
home_dir="$test_tmp/home"
monitor_lua="$home_dir/.config/hypr/monitors.lua"
settings_file="$home_dir/.local/state/omarchy/monitors/settings"
template="$ROOT/config/hypr/monitors.lua"
apple="Apple Computer Inc ProDisplayXDR 0x0A110A08"
laptop="LG Display 0x0804"

mkdir -p "$stub_bin" "$home_dir/.config/hypr"

# The laptop and the Pro Display are plugged in; nothing is on HDMI-A-1.
cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash
if [[ $1 == "monitors" ]]; then
  printf '[{"name":"eDP-1","description":"LG Display 0x0804"},{"name":"DP-1","description":"Apple Computer Inc ProDisplayXDR 0x0A110A08"}]'
fi
SH
chmod +x "$stub_bin/hyprctl"

fresh() {
  rm -rf "$home_dir/.local/state" "$home_dir/.config/hypr"
  mkdir -p "$home_dir/.config/hypr"
  cat >"$monitor_lua"
}

upgrade() {
  HOME="$home_dir" PATH="$stub_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-hyprland-monitor-config-upgrade"
}

setting() {
  awk -F'\t' -v identity="$1" '$4 == identity { print $1 "|" $2 "|" $3 }' "$settings_file" 2>/dev/null
}

kept() {
  sed -n '/^-- Kept from your earlier monitors.lua/,$p' "$monitor_lua" | tail -n +2
}

backups() {
  find "$home_dir/.config/hypr" -name 'monitors.lua.bak.*' | wc -l
}

# A file like most older installs have: the old defaults, the panel's rules for
# both plugged-in monitors, and things the panel doesn't cover.
fresh <<'LUA'
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
local omarchy_monitor_scale = 2
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
hl.monitor({ output = "DP-1", mode = "5120x2880@60", position = "0x0", scale = 2 })
hl.monitor({ output = "eDP-1", mode = "preferred", position = "640x1440", scale = 2 })
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })
hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = 1 })
local omarchy_gdk_scale = 2
hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.config({ misc = { vrr = 0 } })
LUA
cp "$monitor_lua" "$test_tmp/original.lua"
upgrade
head -n "$(wc -l <"$template")" "$monitor_lua" | cmp -s - "$template" || fail "monitors upgrade starts from the new template" "$(<"$monitor_lua")"
[[ $(setting "$apple") == "5120x2880@60|0x0|2" ]] || fail "monitors upgrade saves the Pro Display's rule by its identity" "actual: $(setting "$apple")"
[[ $(setting "$laptop") == "|640x1440|2" ]] || fail "monitors upgrade saves only what the laptop's rule chose" "actual: $(setting "$laptop")"
expected_kept='hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 2 })
hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = 1 })
hl.config({ misc = { vrr = 0 } })'
[[ $(kept) == "$expected_kept" ]] || fail "monitors upgrade keeps everything else and the changed default scale" "actual:"$'\n'"$(kept)"
! grep -q 'omarchy_monitor_scale\|omarchy_gdk_scale' "$monitor_lua" || fail "monitors upgrade drops the old defaults' locals"
(( $(backups) == 1 )) || fail "monitors upgrade keeps the old file"
cmp -s "$(find "$home_dir/.config/hypr" -name 'monitors.lua.bak.*')" "$test_tmp/original.lua" || fail "monitors upgrade's backup is the old file"
pass "monitors upgrade moves an older monitors.lua over to the saved settings"

# A monitor with settings already saved keeps them; its old rule just goes.
fresh <<'LUA'
local omarchy_monitor_scale = "auto"
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
hl.monitor({ output = "DP-1", mode = "5120x2880@60", position = "0x0", scale = 2 })
local omarchy_gdk_scale = 1
hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
LUA
mkdir -p "${settings_file%/*}"
printf '%s\t%s\t%s\t%s\n' "6016x3384@60" "0x0" "2" "$apple" >"$settings_file"
upgrade
[[ $(setting "$apple") == "6016x3384@60|0x0|2" ]] || fail "monitors upgrade leaves saved settings alone" "actual: $(setting "$apple")"
[[ $(kept) == 'hl.env("GDK_SCALE", "1")' ]] || fail "monitors upgrade keeps a changed GDK scale as a plain line, and an auto scale not at all" "actual:"$'\n'"$(kept)"
pass "monitors upgrade keeps saved settings and changed defaults"

# A kept line still naming an old local keeps the local it needs.
fresh <<'LUA'
local omarchy_monitor_scale = "auto"
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
hl.monitor({ output = "DP-3", mode = "preferred", position = "auto", scale = omarchy_monitor_scale, transform = 1 })
LUA
upgrade
grep -Fxq 'local omarchy_monitor_scale = "auto"' "$monitor_lua" || fail "monitors upgrade keeps a local a kept line uses" "$(<"$monitor_lua")"
pass "monitors upgrade keeps a local a kept line still uses"

# A file already in the new shape is left alone.
fresh <"$template"
upgrade
cmp -s "$monitor_lua" "$template" || fail "monitors upgrade leaves a new monitors.lua alone"
(( $(backups) == 0 )) || fail "monitors upgrade makes no backup of a new monitors.lua"
pass "monitors upgrade leaves a new monitors.lua alone"
