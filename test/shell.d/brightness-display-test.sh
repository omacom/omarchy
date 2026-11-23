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
  CALL_LOG="$call_log" XDG_RUNTIME_DIR="$runtime_dir" TEST_TMP="$test_tmp" \
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

# --- Gamma dimming below the backlight floor ------------------------------

# The mocks below keep the backlight and hyprsunset gamma in files, so a step
# can be followed from one command to the next. hyprctl answers monitors and
# the hyprsunset IPC; pgrep and uwsm-app model the daemon's life cycle.
cat >"$mock_bin/brightnessctl" <<'SH'
#!/bin/bash
printf 'brightnessctl %s\n' "$*" >>"$CALL_LOG"
file="$TEST_TMP/backlight"
[[ -r $file ]] || printf '40\n' >"$file"

if [[ $* == *" -m"* ]]; then
  value=$(cat "$file")
  printf 'mock_backlight,backlight,%s,%s%%\n' "$value" "$value"
  exit 0
fi

if [[ $* == *" set "* ]]; then
  arg=${!#}
  current=$(cat "$file")
  if [[ $arg == +* ]]; then
    amount=${arg#+}
    amount=${amount%\%}
    (( value = current + amount ))
  elif [[ $arg == *- ]]; then
    amount=${arg%-}
    amount=${amount%\%}
    (( value = current - amount ))
  else
    value=${arg%\%}
  fi
  (( value < 1 )) && value=1
  (( value > 100 )) && value=100
  printf '%s\n' "$value" >"$file"
fi
SH

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
printf 'hyprctl %s\n' "$*" >>"$CALL_LOG"

if [[ $1 == monitors && $2 == -j ]]; then
  cat "$TEST_TMP/monitors.json"
elif [[ $1 == hyprsunset && $2 == gamma ]]; then
  [[ -r $TEST_TMP/hyprsunset.pid ]] || exit 1
  if [[ -n ${3:-} ]]; then
    printf '%s\n' "$3" >"$TEST_TMP/gamma"
  else
    cat "$TEST_TMP/gamma"
  fi
else
  exit 1
fi
SH

cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
[[ -r $TEST_TMP/hyprsunset.pid ]] || exit 1
cat "$TEST_TMP/hyprsunset.pid"
SH

cat >"$mock_bin/uwsm-app" <<'SH'
#!/bin/bash
printf '4242\n' >"$TEST_TMP/hyprsunset.pid"
[[ -r $TEST_TMP/gamma ]] || printf '100\n' >"$TEST_TMP/gamma"
SH

cat >"$mock_bin/omarchy-osd" <<'SH'
#!/bin/bash
printf 'osd %s\n' "$*" >>"$CALL_LOG"
SH

chmod +x "$mock_bin"/*

write_monitors() {
  if [[ $1 == "external" ]]; then
    printf '%s\n' '[{"name":"eDP-1","disabled":false},{"name":"DP-1","disabled":false}]' >"$test_tmp/monitors.json"
  else
    printf '%s\n' '[{"name":"eDP-1","disabled":false}]' >"$test_tmp/monitors.json"
  fi
}

gamma_state() {
  cat "$runtime_dir/omarchy-brightness-display.gamma" 2>/dev/null
}

write_monitors internal
printf '1\n' >"$test_tmp/backlight"
printf '100\n' >"$test_tmp/gamma"
printf '4242\n' >"$test_tmp/hyprsunset.pid"
rm -f "$runtime_dir/omarchy-brightness-display.gamma"
: >"$call_log"

run_brightness --no-osd --monitor eDP-1 5%-
[[ $(cat "$test_tmp/gamma") == 95 ]] || fail "the first step below the floor lowers gamma" "gamma: $(cat "$test_tmp/gamma")"
[[ $(cat "$test_tmp/backlight") == 1 ]] || fail "gamma dimming keeps the backlight at its floor" "backlight: $(cat "$test_tmp/backlight")"
[[ $(gamma_state) == "4242 100 95" ]] || fail "the script records the gamma it owns" "state: $(gamma_state)"
pass "below the backlight floor, down steps gamma"

run_brightness --no-osd --monitor eDP-1 5%-
[[ $(cat "$test_tmp/gamma") == 90 ]] || fail "another down step keeps lowering gamma" "gamma: $(cat "$test_tmp/gamma")"
pass "gamma keeps stepping down"

run_brightness --no-osd --monitor eDP-1 1%-
[[ $(cat "$test_tmp/gamma") == 89 ]] || fail "precise down uses one gamma point" "gamma: $(cat "$test_tmp/gamma")"
pass "precise down uses one gamma point"

run_brightness --no-osd --monitor eDP-1 +5%
[[ $(cat "$test_tmp/gamma") == 94 ]] || fail "up retraces the gamma range first" "gamma: $(cat "$test_tmp/gamma")"
pass "brightening retraces the gamma range first"

run_brightness --no-osd --monitor eDP-1 +5%
run_brightness --no-osd --monitor eDP-1 +5%
[[ $(cat "$test_tmp/gamma") == 100 ]] || fail "gamma reaches neutral" "gamma: $(cat "$test_tmp/gamma")"
[[ ! -e "$runtime_dir/omarchy-brightness-display.gamma" ]] || fail "the owned state clears at neutral gamma"
run_brightness --no-osd --monitor eDP-1 +5%
[[ $(cat "$test_tmp/backlight") == 2 ]] || fail "the backlight rises after gamma reaches 100" "backlight: $(cat "$test_tmp/backlight")"
pass "the backlight rises after gamma reaches 100"

printf '1\n' >"$test_tmp/backlight"
printf '30\n' >"$test_tmp/gamma"
printf '4242 100 30\n' >"$runtime_dir/omarchy-brightness-display.gamma"
run_brightness --no-osd --monitor eDP-1 5%-
[[ $(cat "$test_tmp/gamma") == 30 ]] || fail "gamma stops at its 30 percent floor" "gamma: $(cat "$test_tmp/gamma")"
pass "gamma stops at its floor"

write_monitors external
printf '80\n' >"$test_tmp/gamma"
rm -f "$runtime_dir/omarchy-brightness-display.gamma"
: >"$call_log"
run_brightness --no-osd --monitor eDP-1 5%-
[[ $(cat "$test_tmp/gamma") == 80 ]] || fail "an external display keeps gamma dimming off" "gamma: $(cat "$test_tmp/gamma")"
[[ $(cat "$test_tmp/backlight") == 1 ]] || fail "an external display leaves the backlight at its floor"
grep -q 'hyprsunset gamma 80' "$call_log" && fail "an external display does not write gamma" "$(<"$call_log")"
pass "an active external display keeps gamma dimming off"

printf '1\n' >"$test_tmp/backlight"
printf '80\n' >"$test_tmp/gamma"
printf '4242 100 80\n' >"$runtime_dir/omarchy-brightness-display.gamma"
run_brightness --no-osd --monitor eDP-1 5%-
[[ $(cat "$test_tmp/gamma") == 100 ]] || fail "an external display lifts the script's own gamma" "gamma: $(cat "$test_tmp/gamma")"
[[ ! -e "$runtime_dir/omarchy-brightness-display.gamma" ]] || fail "lifting the gamma clears the owned state"
pass "an external display lifts the script's own gamma"

write_monitors internal
printf '1\n' >"$test_tmp/backlight"
printf '90\n' >"$test_tmp/gamma"
printf '4242 100 90\n' >"$runtime_dir/omarchy-brightness-display.gamma"
run_brightness --no-osd --monitor eDP-1 50%
[[ $(cat "$test_tmp/backlight") == 50 ]] || fail "an absolute level sets the backlight" "backlight: $(cat "$test_tmp/backlight")"
[[ $(cat "$test_tmp/gamma") == 100 ]] || fail "an absolute level above the floor clears the script's gamma"
[[ ! -e "$runtime_dir/omarchy-brightness-display.gamma" ]] || fail "an absolute level clears the owned state"
pass "an absolute level above the floor clears the script's gamma"

printf '50\n' >"$test_tmp/backlight"
printf '80\n' >"$test_tmp/gamma"
rm -f "$runtime_dir/omarchy-brightness-display.gamma"
run_brightness --no-osd --monitor eDP-1 40%
[[ $(cat "$test_tmp/gamma") == 80 ]] || fail "a user's gamma is not reset" "gamma: $(cat "$test_tmp/gamma")"
pass "a user's gamma survives a brightness change"

write_monitors internal
printf '1\n' >"$test_tmp/backlight"
printf '80\n' >"$test_tmp/gamma"
rm -f "$runtime_dir/omarchy-brightness-display.gamma"
run_brightness --no-osd --monitor eDP-1 5%-
[[ $(cat "$test_tmp/gamma") == 75 ]] || fail "dimming below the floor adopts the user's gamma" "gamma: $(cat "$test_tmp/gamma")"
[[ $(gamma_state) == "4242 80 75" ]] || fail "the state keeps the user's gamma as the baseline" "state: $(gamma_state)"
run_brightness --no-osd --monitor eDP-1 +5%
[[ $(cat "$test_tmp/gamma") == 80 ]] || fail "raising returns to the user's gamma" "gamma: $(cat "$test_tmp/gamma")"
[[ ! -e "$runtime_dir/omarchy-brightness-display.gamma" ]] || fail "returning to the baseline hands the filter back"
run_brightness --no-osd --monitor eDP-1 +5%
[[ $(cat "$test_tmp/gamma") == 80 ]] || fail "the user's gamma survives the backlight rising" "gamma: $(cat "$test_tmp/gamma")"
pass "returning to a user's gamma hands the filter back"

printf '1\n' >"$test_tmp/backlight"
printf '100\n' >"$test_tmp/gamma"
rm -f "$test_tmp/hyprsunset.pid" "$runtime_dir/omarchy-brightness-display.gamma"
run_brightness --no-osd --monitor eDP-1 5%-
[[ -r "$test_tmp/hyprsunset.pid" ]] || fail "hyprsunset starts on demand"
[[ $(cat "$test_tmp/gamma") == 95 ]] || fail "the started hyprsunset takes the first gamma step" "gamma: $(cat "$test_tmp/gamma")"
pass "hyprsunset starts when the gamma range is first needed"

printf '1\n' >"$test_tmp/backlight"
printf '100\n' >"$test_tmp/gamma"
printf '4242\n' >"$test_tmp/hyprsunset.pid"
rm -f "$runtime_dir/omarchy-brightness-display.gamma"
: >"$call_log"
run_brightness --monitor eDP-1 5%-
grep -F 'osd -i brightness -m Dim 95%' "$call_log" >/dev/null || fail "the OSD names the gamma level" "$(<"$call_log")"
pass "the OSD shows the gamma level"

write_monitors external
printf '1\n' >"$test_tmp/backlight"
printf '100\n' >"$test_tmp/gamma"
rm -f "$runtime_dir/omarchy-brightness-display.gamma"
run_brightness --no-osd --monitor eDP-1 1%-
[[ $(cat "$test_tmp/backlight") == 1 ]] || fail "precise down keeps the backlight floor" "backlight: $(cat "$test_tmp/backlight")"
pass "precise down does not blank the panel at the floor"
