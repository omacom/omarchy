#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
call_log="$test_tmp/calls"
runtime_dir="$test_tmp/runtime"
mkdir -p "$mock_bin" "$runtime_dir"

cat >"$mock_bin/omarchy-hyprland-monitor-focused-apple" <<'SH'
#!/bin/bash
exit 1
SH

cat >"$mock_bin/omarchy-hyprland-monitor-focused" <<'SH'
#!/bin/bash
printf '%s\n' "${FOCUSED_MONITOR:-eDP-1}"
SH

cat >"$mock_bin/omarchy-hw-display" <<'SH'
#!/bin/bash
printf 'mock_backlight\n'
SH

cat >"$mock_bin/brightnessctl" <<'SH'
#!/bin/bash
printf 'brightnessctl %s\n' "$*" >>"$CALL_LOG"
if [[ $* == *" -m"* ]]; then
  printf 'mock_backlight,backlight,40,40%%\n'
fi
SH

cat >"$mock_bin/ddcutil" <<'SH'
#!/bin/bash
printf 'ddcutil %s\n' "$*" >>"$CALL_LOG"

if [[ $* == *" detect --brief"* ]]; then
  cat <<EOF
Display 1
   I2C bus:             /dev/i2c-${DDC_BUS:-7}
   DRM connector:       card1-${DDC_CONNECTOR:-DP-1}
EOF
elif [[ $* == *" getvcp 10 "* ]]; then
  [[ ${DDC_READ_FAIL:-0} == "1" ]] && exit 1
  printf 'VCP 10 C %s %s\n' "${DDC_CURRENT:-40}" "${DDC_MAXIMUM:-80}"
fi
SH

chmod +x "$mock_bin"/*

# A copy of the command reads its platform file from a fixture root (none
# unless a case writes one, whatever the machine running the suite has
# installed) and its DRM connectors from a fixture directory.
platform_root="$test_tmp/platform"
mkdir -p "$platform_root" "$test_tmp/copy"
brightness_display="$test_tmp/copy/omarchy-brightness-display"
platform_root_copy "$ROOT/bin/omarchy-brightness-display" "$brightness_display" "$platform_root"
sed -i "s|/sys/class/drm|$test_tmp/drm|g" "$brightness_display"
grep -qF "$test_tmp/drm/card" "$brightness_display" || fail "omarchy-brightness-display reads DRM connectors from the fixture"

run_brightness() {
  CALL_LOG="$call_log" XDG_RUNTIME_DIR="$runtime_dir" \
    PATH="$mock_bin:$ROOT/bin:$PATH" "$brightness_display" "$@"
}

brightness=$(run_brightness --monitor DP-1)
[[ $brightness == "50" ]] || fail "external brightness is converted to a percentage" "actual: $brightness"
pass "external brightness is converted to a percentage"

(( $(grep -c '^ddcutil --skip-ddc-checks detect --brief$' "$call_log") == 1 )) || fail "DDC bus is detected once"
run_brightness --monitor DP-1 >/dev/null
(( $(grep -c '^ddcutil --skip-ddc-checks detect --brief$' "$call_log") == 1 )) || fail "DDC bus mapping is cached"
pass "DDC bus mapping is cached"

run_brightness --no-osd --monitor DP-1 25%
grep -F 'ddcutil --bus 7 --skip-ddc-checks --noverify setvcp 10 20' "$call_log" >/dev/null || \
  fail "external percentage is converted to the monitor VCP range"
pass "external percentage is converted to the monitor VCP range"

get_count=$(grep -c ' getvcp 10 ' "$call_log")
run_brightness --no-osd --monitor DP-1 30%
(( $(grep -c ' getvcp 10 ' "$call_log") == get_count )) || \
  fail "absolute external brightness reuses the cached VCP range"
grep -F 'ddcutil --bus 7 --skip-ddc-checks --noverify setvcp 10 24' "$call_log" >/dev/null || \
  fail "absolute external brightness skips write verification"
pass "absolute external brightness reuses the cached VCP range"

brightness=$(run_brightness --monitor eDP-1)
[[ $brightness == "40" ]] || fail "internal monitor uses the kernel backlight" "actual: $brightness"
grep -F 'brightnessctl -d mock_backlight -m' "$call_log" >/dev/null || \
  fail "internal monitor queries brightnessctl"
pass "internal monitor uses the kernel backlight"

brightness=$(FOCUSED_MONITOR=DP-1 run_brightness)
[[ $brightness == "50" ]] || fail "brightness follows the focused external monitor" "actual: $brightness"
pass "brightness follows the focused external monitor"

detect_count=$(grep -c ' detect --brief' "$call_log")
if DDC_CONNECTOR=DP-1 run_brightness --monitor DP-2 >/dev/null 2>&1; then
  fail "unsupported external monitor has no brightness backend"
fi
if DDC_CONNECTOR=DP-1 run_brightness --monitor DP-2 >/dev/null 2>&1; then
  fail "cached unsupported external monitor has no brightness backend"
fi
(( $(grep -c ' detect --brief' "$call_log") == detect_count + 1 )) || \
  fail "unsupported external monitor detection is temporarily cached"
pass "unsupported external monitor has no brightness backend"

rm -f "$runtime_dir/omarchy-brightness-display-ddc/DP-1.bus"
detect_count=$(grep -c ' detect --brief' "$call_log")
get_count=$(grep -c ' getvcp 10 ' "$call_log")
if DDC_READ_FAIL=1 run_brightness --monitor DP-1 >/dev/null 2>&1; then
  fail "unreadable DDC brightness is reported"
fi
if DDC_READ_FAIL=1 run_brightness --monitor DP-1 >/dev/null 2>&1; then
  fail "cached unreadable DDC brightness is reported"
fi
(( $(grep -c ' detect --brief' "$call_log") == detect_count + 1 )) || \
  fail "unreadable DDC brightness is temporarily cached"
(( $(grep -c ' getvcp 10 ' "$call_log") == get_count + 1 )) || \
  fail "cached unreadable DDC brightness is not read again"
pass "unreadable DDC brightness is temporarily cached"

printf 'unavailable 0\n' >"$runtime_dir/omarchy-brightness-display-ddc/DP-1.bus"
brightness=$(run_brightness --monitor DP-1)
[[ $brightness == "50" ]] || fail "expired unreadable DDC brightness is retried" "actual: $brightness"
pass "expired unreadable DDC brightness is retried"

detect_count=$(grep -c ' detect --brief' "$call_log")
if DDC_READ_FAIL=1 run_brightness --monitor DP-1 >/dev/null 2>&1; then
  fail "transient DDC read failure is reported"
fi
brightness=$(run_brightness --monitor DP-1)
[[ $brightness == "50" ]] || fail "transient DDC read failure on a known bus is retried on the next invocation" "actual: $brightness"
(( $(grep -c ' detect --brief' "$call_log") == detect_count + 1 )) || \
  fail "transient DDC read failure on a known bus detects the bus again"
pass "transient DDC read failure on a known bus is retried on the next invocation"

printf '7\n' >"$runtime_dir/omarchy-brightness-display-ddc/DP-1.bus"
if DDC_READ_FAIL=1 run_brightness --monitor DP-1 >/dev/null 2>&1; then
  fail "unread DDC bus failure is reported"
fi
read -r cached_entry _ <"$runtime_dir/omarchy-brightness-display-ddc/DP-1.bus"
[[ $cached_entry == "unavailable" ]] || fail "a bus never read successfully is temporarily cached" "actual: $cached_entry"
pass "a bus never read successfully is temporarily cached"
rm -f "$runtime_dir/omarchy-brightness-display-ddc/DP-1.bus"

printf '7 80 0\n' >"$runtime_dir/omarchy-brightness-display-ddc/DP-1.bus"
get_count=$(grep -c ' getvcp 10 ' "$call_log")
DDC_MAXIMUM=100 run_brightness --no-osd --monitor DP-1 50%
(( $(grep -c ' getvcp 10 ' "$call_log") == get_count + 1 )) || \
  fail "expired external brightness range is refreshed"
grep -F 'ddcutil --bus 7 --skip-ddc-checks --noverify setvcp 10 50' "$call_log" >/dev/null || \
  fail "expired external brightness range uses the refreshed maximum"
pass "expired external brightness range is refreshed"

rm -f "$runtime_dir/omarchy-brightness-display-ddc/DP-1.bus"
DDC_CURRENT=4 DDC_MAXIMUM=100 run_brightness --no-osd --monitor DP-1 +5%
grep -F 'ddcutil --bus 7 --skip-ddc-checks --noverify setvcp 10 5' "$call_log" >/dev/null || \
  fail "external low brightness writes the one-percent target"
pass "external low brightness uses a one-percent step"

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' '[
  {"name":"DP-1","focused":true,"make":"HPN","model":"OMEN X 25f"},
  {"name":"DP-2","focused":false,"make":"Apple Computer Inc","model":"StudioDisplay"}
]'
SH
chmod +x "$mock_bin/hyprctl"

PATH="$mock_bin:$PATH" "$ROOT/bin/omarchy-hyprland-monitor-focused-apple" DP-2 || \
  fail "named Apple display is detected independently of focus"
if PATH="$mock_bin:$PATH" "$ROOT/bin/omarchy-hyprland-monitor-focused-apple"; then
  fail "focused non-Apple display is not detected as Apple"
fi
pass "named Apple display is detected independently of focus"

# A platform whose display driver has no DDC channel says so: an external
# monitor whose connector has no ddc node is not probed and never dims the
# built-in panel in its place.
mkdir -p "$test_tmp/drm/card2-USB-1" "$test_tmp/drm/card2-eDP-1"
# The last line needs no newline.
printf '%s\n%s' '# no DDC channel on the display driver' 'ddc-require-connector-ddc' >"$platform_root/displays.conf"
: >"$call_log"
if run_brightness --monitor USB-1 >/dev/null 2>&1; then
  fail "an external monitor without a ddc node has no brightness backend"
fi
if run_brightness --no-osd --monitor USB-1 +5% >/dev/null 2>&1; then
  fail "setting an external monitor without a ddc node fails"
fi
printf 'ddc-require-connector-ddc\r\n' >"$platform_root/displays.conf"
if run_brightness --monitor USB-1 >/dev/null 2>&1; then
  fail "a displays.conf saved with CRLF line ends reads the same"
fi
printf '%s\n%s' '# no DDC channel on the display driver' 'ddc-require-connector-ddc' >"$platform_root/displays.conf"
[[ ! -s $call_log ]] || fail "an external monitor without a ddc node probes nothing" "$(<"$call_log")"
brightness=$(run_brightness --monitor eDP-1)
(( brightness == 40 )) || fail "the built-in panel still uses the kernel backlight" "actual: $brightness"
pass "a platform without DDC channels skips DDC for a connector without one"

rm -f "$runtime_dir/omarchy-brightness-display-ddc/"*
: >"$test_tmp/drm/card2-USB-1/ddc"
brightness=$(DDC_CONNECTOR=USB-1 run_brightness --monitor USB-1)
(( brightness == 50 )) || fail "an external monitor with a ddc node uses DDC" "actual: $brightness"
pass "a platform without DDC channels still uses DDC where a connector has one"

# Without the directive, every external monitor is probed, ddc node or not.
rm -f "$runtime_dir/omarchy-brightness-display-ddc/"* "$test_tmp/drm/card2-USB-1/ddc"
for conf in "" "ddc-require-connector-ddc extra" "ddc-future"; do
  printf '%s\n' "$conf" >"$platform_root/displays.conf"
  rm -f "$runtime_dir/omarchy-brightness-display-ddc/"*
  brightness=$(DDC_CONNECTOR=USB-1 run_brightness --monitor USB-1)
  (( brightness == 50 )) || fail "an external monitor is probed without the directive" "conf: $conf, actual: $brightness"
done
rm -f "$platform_root/displays.conf"
pass "every external monitor is probed without the directive"

# Brightness memory serializes source changes and writes for the internal panel.
memory_bin="$test_tmp/memory-bin"
mkdir -p "$memory_bin" "$test_tmp/state" "$test_tmp/memory-runtime"
cat >"$memory_bin/omarchy-hw-display" <<'SH'
#!/bin/bash
[[ ${NO_DISPLAY:-0} == 1 ]] && exit 1
printf 'panel\n'
SH
cat >"$memory_bin/busctl" <<'SH'
#!/bin/bash
[[ ${BUSCTL_FAIL:-0} == 1 ]] && exit 1
printf 'b %s\n' "$(<"$POWER_SOURCE")"
SH
cat >"$memory_bin/brightnessctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$MEMORY_CALLS"
if [[ $* == *" -m"* ]]; then printf 'panel,backlight,%s,%s%%\n' "${MEMORY_CURRENT:-40}" "${MEMORY_CURRENT:-40}"; fi
SH
chmod +x "$memory_bin"/*
source_file="$test_tmp/power-source"
printf false >"$source_file"
memory="$ROOT/bin/omarchy-brightness-memory"
run_memory() {
  POWER_SOURCE="$source_file" MEMORY_CALLS="$test_tmp/memory-calls" XDG_STATE_HOME="$test_tmp/state" XDG_RUNTIME_DIR="$test_tmp/memory-runtime" PATH="$memory_bin:$ROOT/bin:$PATH" "$memory" "$@"
}
state="$test_tmp/state/omarchy/brightness"
mkdir -p "$state"
printf '40\n' >"$state/ac"
printf '63\n' >"$state/ac"
printf 'ac\n' >"$state/active"
: >"$test_tmp/memory-calls"
run_memory sync
[[ ! -s $test_tmp/memory-calls ]] || fail "sync after restart does not overwrite the current level"
printf true >"$source_file"
printf '30\n' >"$state/battery"
run_memory sync
[[ $(<"$test_tmp/memory-calls") == "-q -d panel set 30%" && $(<"$state/active") == battery ]] || fail "sync applies the level for the newly selected source"
pass "brightness memory restart and source switch"

: >"$test_tmp/memory-calls"
rm -f "$state/active" "$state/ac"
run_memory sync
[[ ! -s $test_tmp/memory-calls && $(<"$state/active") == battery ]] || fail "missing active records source without writing brightness"
printf 'battery\n' >"$state/active"
printf false >"$source_file"
run_memory sync
[[ ! -s $test_tmp/memory-calls && $(<"$state/active") == ac ]] || fail "missing saved level updates active without writing"
run_memory set 70%
[[ $(<"$state/ac") == 70 ]] || fail "set saves its target instead of reading back brightness"
pass "brightness memory initializes missing state and saves target"

printf true >"$source_file"
printf 'ac\n' >"$state/active"
printf '45\n' >"$state/ac"
: >"$test_tmp/memory-calls"
run_memory set 70%
printf false >"$source_file"
run_memory sync
[[ $(<"$state/battery") == 70 && $(<"$state/active") == ac && $(<"$test_tmp/memory-calls") == $'-q -d panel set 70%\n-q -d panel set 45%' ]] || fail "set-before-switch-sync preserves both source levels"
printf true >"$source_file"
run_memory sync
run_memory set 70%
: >"$test_tmp/memory-calls"
run_memory sync
[[ $(<"$state/battery") == 70 && $(<"$state/active") == battery && ! -s $test_tmp/memory-calls ]] || fail "switch-sync-before-set does not replay stale brightness"
pass "brightness memory serializes either set and sync order"

lock="$test_tmp/memory-runtime/omarchy-brightness-memory.lock"
flock "$lock" sleep 2 & lock_pid=$!
sleep 0.1
if timeout 1 env POWER_SOURCE="$source_file" MEMORY_CALLS="$test_tmp/memory-calls" XDG_STATE_HOME="$test_tmp/state" XDG_RUNTIME_DIR="$test_tmp/memory-runtime" PATH="$memory_bin:$ROOT/bin:$PATH" "$memory" set 50%; then fail "memory lock blocks competing writes"; else status=$?; (( status == 124 )) || fail "memory lock timeout status" "actual: $status"; fi
wait "$lock_pid"
before_ac=$(<"$state/ac")
before_battery=$(<"$state/battery")
before_active=$(<"$state/active")
: >"$test_tmp/memory-calls"
BUSCTL_FAIL=1 run_memory set 50%
[[ $(<"$test_tmp/memory-calls") == "-q -d panel set 50%" ]] || fail "UPower failure still changes brightness"
[[ $(<"$state/ac") == "$before_ac" && $(<"$state/battery") == "$before_battery" && $(<"$state/active") == "$before_active" ]] || fail "UPower failure does not persist a guessed source"
: >"$test_tmp/memory-calls"
BUSCTL_FAIL=1 run_memory sync
[[ ! -s $test_tmp/memory-calls && $(<"$state/active") == "$before_active" ]] || fail "sync without UPower leaves brightness state untouched"
MEMORY_CURRENT=1 run_memory set '5%-'
grep -F -- '-q -d panel set 1%' "$test_tmp/memory-calls" >/dev/null || fail "decrement at zero clamps to one percent"
[[ $(<"$state/battery") == 1 ]] || fail "clamped decrement target is persisted"
NO_DISPLAY=1 run_memory set 51%
pass "brightness memory blocks on lock and handles desktop or no display"

# Exercise the public CLI, not only its helper: relative arguments must finish
# while the helper owns the shared lock and retain their brightnessctl meaning.
for argument in +5% 10%- +10% 10%- +1; do
  timeout 3 env POWER_SOURCE="$source_file" MEMORY_CALLS="$test_tmp/memory-calls" XDG_STATE_HOME="$test_tmp/state" XDG_RUNTIME_DIR="$test_tmp/memory-runtime" PATH="$memory_bin:$ROOT/bin:$PATH" "$brightness_display" --no-osd --monitor eDP-1 "$argument" || fail "CLI relative brightness argument completes: $argument"
done
pass "brightness CLI relative arguments complete under timeout"
