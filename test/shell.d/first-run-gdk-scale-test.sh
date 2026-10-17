#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
eval_out="$test_tmp/hyprctl-eval"
dbus_out="$test_tmp/dbus-env"
home_dir="$test_tmp/home"
monitor_lua="$home_dir/.config/hypr/monitors.lua"

mkdir -p "$stub_bin" "$home_dir/.config/hypr"

# OMARCHY_TEST_MONITOR_SCALES is a space-separated list, one scale per monitor.
cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash

if [[ $1 == "monitors" && $2 == "-j" ]]; then
  printf '%s\n' $OMARCHY_TEST_MONITOR_SCALES | jq -s -c 'map({scale: .})'
elif [[ $1 == "eval" ]]; then
  printf '%s\n' "$2" >"$OMARCHY_TEST_HYPRCTL_EVAL_OUT"
else
  exit 1
fi
SH
cat >"$stub_bin/dbus-update-activation-environment" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$OMARCHY_TEST_DBUS_OUT"
SH
chmod +x "$stub_bin/hyprctl" "$stub_bin/dbus-update-activation-environment"

write_monitor_config() {
  cp "$ROOT/config/hypr/monitors.lua" "$monitor_lua"
  rm -f "$eval_out" "$dbus_out"
}

run_gdk_scale() {
  HOME="$home_dir" \
    PATH="$stub_bin:$PATH" \
    OMARCHY_TEST_HYPRCTL_EVAL_OUT="$eval_out" \
    OMARCHY_TEST_DBUS_OUT="$dbus_out" \
    OMARCHY_TEST_MONITOR_SCALES="$1" \
    bash "$ROOT/install/user/first-run/gdk-scale.sh"
}

grep -Fx 'local omarchy_gdk_scale = 2' "$ROOT/config/hypr/monitors.lua" >/dev/null ||
  fail "monitors.lua template still ships the line first-run rewrites"
grep -Fx 'local omarchy_monitor_scale = "auto"' "$ROOT/config/hypr/monitors.lua" >/dev/null ||
  fail "monitors.lua template still ships the auto monitor scale first-run checks"
grep -F 'install/user/first-run/gdk-scale.sh' "$ROOT/bin/omarchy-provision-first-run" >/dev/null ||
  fail "first-run runs the GDK scale step"
pass "first-run GDK scale step matches the monitors.lua template"

write_monitor_config
run_gdk_scale "1 1"
grep -Fx 'local omarchy_gdk_scale = 1' "$monitor_lua" >/dev/null || fail "1x displays persist GDK scale 1"
grep -F 'hl.env("GDK_SCALE", "1")' "$eval_out" >/dev/null || fail "1x displays update the running Hyprland env"
grep -Fx -- '--systemd GDK_SCALE=1' "$dbus_out" >/dev/null || fail "1x displays update the activation env"
pass "1x displays lower GDK scale to 1"

write_monitor_config
run_gdk_scale "1.25"
grep -Fx 'local omarchy_gdk_scale = 1' "$monitor_lua" >/dev/null || fail "1.25x display rounds GDK scale down to 1"
pass "1.25x display rounds GDK scale down to 1"

write_monitor_config
run_gdk_scale "1.6"
grep -Fx 'local omarchy_gdk_scale = 2' "$monitor_lua" >/dev/null || fail "1.6x display keeps GDK scale 2"
[[ ! -e $eval_out ]] || fail "unchanged GDK scale leaves the running env alone"
pass "1.6x display keeps GDK scale 2"

write_monitor_config
run_gdk_scale "1 2"
grep -Fx 'local omarchy_gdk_scale = 2' "$monitor_lua" >/dev/null || fail "mixed 1x and 2x displays keep GDK scale 2"
pass "mixed 1x and 2x displays keep GDK scale 2"

write_monitor_config
run_gdk_scale "3"
grep -Fx 'local omarchy_gdk_scale = 3' "$monitor_lua" >/dev/null || fail "3x display raises GDK scale to 3"
pass "3x display raises GDK scale to 3"

write_monitor_config
sed -i 's|^local omarchy_monitor_scale = .*|local omarchy_monitor_scale = 1.25|' "$monitor_lua"
run_gdk_scale "1.25"
grep -Fx 'local omarchy_gdk_scale = 2' "$monitor_lua" >/dev/null || fail "edited monitor scale leaves GDK scale alone"
pass "edited monitors.lua is left alone"

write_monitor_config
run_gdk_scale ""
grep -Fx 'local omarchy_gdk_scale = 2' "$monitor_lua" >/dev/null || fail "no monitors leaves GDK scale alone"
pass "no monitors leaves GDK scale alone"

rm -f "$monitor_lua"
run_gdk_scale "1" || fail "missing monitors.lua is not an error"
[[ ! -e $monitor_lua ]] || fail "missing monitors.lua is not created"
pass "missing monitors.lua is not an error"
