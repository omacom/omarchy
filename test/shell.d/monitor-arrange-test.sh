#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
eval_out="$test_tmp/hyprctl-eval"
monitors_json="$test_tmp/monitors.json"
home_dir="$test_tmp/home"
monitor_lua="$home_dir/.config/hypr/monitors.lua"
scale_arg="$test_tmp/scale-arg"

mkdir -p "$stub_bin" "$home_dir/.config/hypr"

cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash

if [[ $1 == "monitors" && $2 == "-j" ]]; then
  cat "$OMARCHY_TEST_MONITORS_JSON"
elif [[ $1 == "eval" ]]; then
  printf '%s\n' "$2" >>"$OMARCHY_TEST_HYPRCTL_EVAL_OUT"
else
  exit 1
fi
SH
chmod +x "$stub_bin/hyprctl"

cat >"$stub_bin/omarchy-hyprland-monitor-scaling" <<'SH'
#!/bin/bash
printf '%s\n' "$1" >"$OMARCHY_TEST_SCALE_ARG"
printf '%s\n' 'hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 2 })' >>"$OMARCHY_TEST_HYPRCTL_EVAL_OUT"
SH
chmod +x "$stub_bin/omarchy-hyprland-monitor-scaling"

write_stock_config() {
  cat >"$monitor_lua" <<'LUA'
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
local omarchy_monitor_scale = "auto"
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

local omarchy_gdk_scale = 2
hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
LUA
}

write_marked_config() {
  cat >"$monitor_lua" <<'LUA'
local omarchy_monitor_scale = 1.6

hl.monitor({
  output = "desc:LG Display 0x0804",
  mode = "preferred",
  position = "0x0",
  scale = omarchy_monitor_scale,
})

-- arrange:begin
hl.monitor({
  output = "desc:Dell Inc. DELL S2725HS",
  mode = "preferred",
  position = "auto-right",
  scale = omarchy_monitor_scale,
})
-- arrange:end

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
LUA
}

run_arrange() {
  HOME="$home_dir" \
    PATH="$stub_bin:$PATH" \
    OMARCHY_TEST_MONITORS_JSON="$monitors_json" \
    OMARCHY_TEST_HYPRCTL_EVAL_OUT="$eval_out" \
    OMARCHY_TEST_SCALE_ARG="$scale_arg" \
    "$ROOT/bin/omarchy-hyprland-monitor-arrange" "$@"
}

laptop='{"name":"eDP-1","description":"LG Display 0x0804","model":"0x0804","width":2560,"height":1600,"scale":1.6,"x":0,"y":0,"focused":true,"disabled":false}'
dell='{"name":"DP-1","description":"Dell Inc. DELL S2725HS","model":"DELL S2725HS","width":1920,"height":1080,"scale":1.6,"x":1600,"y":0,"focused":false,"disabled":false}'

write_monitors() {
  printf '[%s,%s]\n' "$laptop" "$dell" >"$monitors_json"
}

reset_eval() {
  : >"$eval_out"
}

write_monitors
status=$(run_arrange status)
[[ $status == '{"direction":"right","monitor":"DP-1","model":"DELL S2725HS"}' ]] ||
  fail "arrange status reports the screen on the right" "actual: $status"
pass "arrange status reports the screen on the right"

sentence=$(run_arrange)
[[ $sentence == "DELL S2725HS is to the right of the laptop." ]] ||
  fail "arrange with no arguments describes the side" "actual: $sentence"
pass "arrange with no arguments describes the side"

printf '[%s]\n' "$laptop" >"$monitors_json"
status=$(run_arrange status)
[[ $status == '{"direction":"","monitor":"","model":""}' ]] ||
  fail "arrange status is empty with one screen" "actual: $status"
if run_arrange left >/dev/null 2>"$test_tmp/one-screen.err"; then
  fail "arrange left refuses a single screen"
fi
grep -q 'need two enabled displays' "$test_tmp/one-screen.err" ||
  fail "arrange left explains that two screens are required"
pass "arrange left refuses a single screen"

write_monitors
write_stock_config
reset_eval
run_arrange left >/dev/null
grep -F 'output = "desc:LG Display 0x0804"' "$monitor_lua" >/dev/null ||
  fail "arrange left pins the laptop at the origin"
grep -F 'position = "0x0"' "$monitor_lua" >/dev/null ||
  fail "arrange left keeps the laptop at 0x0"
grep -F 'output = "desc:Dell Inc. DELL S2725HS"' "$monitor_lua" >/dev/null ||
  fail "arrange left records the external screen by description"
grep -F 'position = "auto-left"' "$monitor_lua" >/dev/null ||
  fail "arrange left persists auto-left"
grep -F 'local omarchy_monitor_scale = "auto"' "$monitor_lua" >/dev/null ||
  fail "arrange left keeps the scale setting"
grep -F 'local omarchy_gdk_scale = 2' "$monitor_lua" >/dev/null ||
  fail "arrange left keeps the GDK scale"
grep -F 'hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })' "$monitor_lua" >/dev/null ||
  fail "arrange left keeps the fallback rule"
[[ $(grep -c 'arrange:begin' "$monitor_lua") -eq 1 ]] || fail "arrange left writes one arrange block"
grep -F 'output = "DP-1", mode = "preferred", position = "auto-left", scale = 1.6' "$eval_out" >/dev/null ||
  fail "arrange left applies the side to the running session" "actual: $(cat "$eval_out")"
pass "arrange left persists into a stock monitors.lua and applies it"

# A second move updates the existing block instead of stacking another one.
reset_eval
run_arrange above >/dev/null
[[ $(grep -c 'arrange:begin' "$monitor_lua") -eq 1 ]] || fail "arrange above keeps a single block"
[[ $(grep -c 'desc:LG Display 0x0804' "$monitor_lua") -eq 1 ]] ||
  fail "arrange above does not duplicate the laptop rule"
grep -F 'position = "auto-up"' "$monitor_lua" >/dev/null || fail "arrange above persists auto-up"
if grep -F 'position = "auto-left"' "$monitor_lua" >/dev/null; then
  fail "arrange above leaves the previous side in place"
fi
grep -F 'position = "auto-up", scale = 1.6' "$eval_out" >/dev/null ||
  fail "arrange above applies auto-up"
pass "arrange above updates the saved side"

write_marked_config
reset_eval
run_arrange below >/dev/null
grep -F 'position = "auto-down"' "$monitor_lua" >/dev/null || fail "arrange below updates an existing block"
grep -F 'local omarchy_monitor_scale = 1.6' "$monitor_lua" >/dev/null ||
  fail "arrange below keeps a numeric scale setting"
[[ $(grep -c 'arrange:begin' "$monitor_lua") -eq 1 ]] || fail "arrange below does not add a second block"
[[ $(grep -c 'position = "0x0"' "$monitor_lua") -eq 1 ]] ||
  fail "arrange below leaves the existing laptop rule alone"
pass "arrange below updates monitors.lua that already has an arrange block"

# Scaling parks the focused screen on position auto. Arranging again through
# the scale hook puts the saved side back.
write_marked_config
reset_eval
: >"$scale_arg"
run_arrange scale 1.6 >/dev/null
[[ $(cat "$scale_arg") == "1.6" ]] || fail "arrange scale delegates to monitor scaling" "actual: $(cat "$scale_arg")"
grep -F 'position = "0x0", scale = 1.6' "$eval_out" >/dev/null ||
  fail "arrange scale puts the laptop back at the origin"
grep -F 'position = "auto-right", scale = 1.6' "$eval_out" >/dev/null ||
  fail "arrange scale puts the saved side back"
pass "arrange scale restores the saved side after monitor scaling"

if run_arrange scale 0 >/dev/null 2>"$test_tmp/scale.err"; then
  fail "arrange scale refuses a scale below 1"
fi
grep -q 'refusing scale' "$test_tmp/scale.err" || fail "arrange scale explains a refused scale"
pass "arrange scale refuses a scale below 1"

# A hostile connector name must not reach the hyprctl eval string.
hostile='{"name":"DP-1\"}","description":"","model":"X","width":1920,"height":1080,"scale":1,"x":1920,"y":0,"focused":true,"disabled":false}'
printf '[%s,%s]\n' "$laptop" "$hostile" >"$monitors_json"
write_stock_config
if run_arrange right >/dev/null 2>"$test_tmp/hostile.err"; then
  fail "arrange refuses an unsafe monitor name"
fi
grep -q 'refusing monitor name' "$test_tmp/hostile.err" ||
  fail "arrange explains an unsafe monitor name" "actual: $(cat "$test_tmp/hostile.err")"
pass "arrange refuses an unsafe monitor name"
