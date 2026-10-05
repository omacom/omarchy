#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
call_log="$test_tmp/calls"
runtime_dir="$test_tmp/runtime"
drm_dir="$test_tmp/drm"
mkdir -p "$mock_bin" "$runtime_dir"

# DP-3 has a connector backlight and DP-1 only a non-backlight child. eDP-1's i915-style backlight must
# not override omarchy-hw-display, and card1's disconnected DP-3 backlight must be ignored.
mkdir -p "$drm_dir/card2-DP-3/apple-DP-3-bl" "$drm_dir/card2-DP-1/power" "$drm_dir/card0-eDP-1/intel_backlight" \
  "$drm_dir/card1-DP-3/other-DP-3-bl"
ln -s ../../../../class/backlight "$drm_dir/card2-DP-3/apple-DP-3-bl/subsystem"
ln -s ../../../../class/backlight "$drm_dir/card0-eDP-1/intel_backlight/subsystem"
ln -s ../../../../bus/platform "$drm_dir/card2-DP-1/power/subsystem"
ln -s ../../../../class/backlight "$drm_dir/card1-DP-3/other-DP-3-bl/subsystem"
for connector in card2-DP-3 card2-DP-1 card0-eDP-1; do
  printf 'connected\n' >"$drm_dir/$connector/status"
done
printf 'disconnected\n' >"$drm_dir/card1-DP-3/status"

cat >"$mock_bin/omarchy-hyprland-monitor-focused-apple" <<'SH'
#!/bin/bash
printf 'omarchy-hyprland-monitor-focused-apple %s\n' "$*" >>"$CALL_LOG"
[[ ${APPLE_DISPLAY:-0} == "1" ]]
SH

cat >"$mock_bin/omarchy-brightness-display-apple" <<'SH'
#!/bin/bash
printf 'omarchy-brightness-display-apple %s\n' "$*" >>"$CALL_LOG"
SH

cat >"$mock_bin/omarchy-osd" <<'SH'
#!/bin/bash
printf 'omarchy-osd %s\n' "$*" >>"$CALL_LOG"
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
  [[ -n ${BRIGHTNESSCTL_READ_FAIL:-} && $* == "-d $BRIGHTNESSCTL_READ_FAIL "* ]] && exit 1
  printf 'mock_backlight,backlight,40,40%%\n'
elif [[ -n ${BRIGHTNESSCTL_WRITE_FAIL:-} && $* == "-d $BRIGHTNESSCTL_WRITE_FAIL set "* ]]; then
  exit 1
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

run_brightness() {
  CALL_LOG="$call_log" XDG_RUNTIME_DIR="$runtime_dir" OMARCHY_DRM_PATH="$drm_dir" PATH="$mock_bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-brightness-display" "$@"
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
if DDC_READ_FAIL=1 run_brightness --monitor DP-1 >/dev/null 2>&1; then
  fail "transient DDC read failure is reported"
fi
(( $(grep -c ' detect --brief' "$call_log") == detect_count + 1 )) || \
  fail "transient DDC read failure is not retried immediately"
brightness=$(run_brightness --monitor DP-1)
[[ $brightness == "50" ]] || fail "transient DDC read failure is retried on the next invocation" "actual: $brightness"
(( $(grep -c ' detect --brief' "$call_log") == detect_count + 2 )) || \
  fail "transient DDC read failure does not create a negative cache entry"
pass "transient DDC read failure is retried on the next invocation"

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

: >"$call_log"
brightness=$(APPLE_DISPLAY=1 run_brightness --monitor DP-3)
[[ $brightness == "40" ]] || fail "connector backlight reports brightness" "actual: $brightness"
grep -F 'brightnessctl -d apple-DP-3-bl -m' "$call_log" >/dev/null || \
  fail "connector backlight is queried through brightnessctl"
pass "connector backlight reports brightness"

: >"$call_log"
APPLE_DISPLAY=1 run_brightness --monitor DP-3 +5%
grep -Fx 'brightnessctl -d apple-DP-3-bl set 45%' "$call_log" >/dev/null || \
  fail "connector backlight steps through brightnessctl" "$(cat "$call_log")"
grep -Fx 'omarchy-osd -i brightness -p 40' "$call_log" >/dev/null || \
  fail "connector backlight shows the OSD" "$(cat "$call_log")"
if grep -E 'omarchy-brightness-display-apple|omarchy-hyprland-monitor-focused-apple|ddcutil' "$call_log"; then
  fail "connector backlight skips the Apple and DDC backends"
fi
pass "connector backlight wins over the Apple and DDC backends"

: >"$call_log"
FOCUSED_MONITOR=DP-3 run_brightness --no-osd 1%-
grep -Fx 'brightnessctl -d apple-DP-3-bl set 1%-' "$call_log" >/dev/null || \
  fail "focused monitor's connector backlight takes precise steps" "$(cat "$call_log")"
pass "focused monitor's connector backlight takes precise steps"

: >"$call_log"
APPLE_DISPLAY=1 run_brightness --no-osd --monitor DP-1 +5%
grep -Fx 'omarchy-brightness-display-apple --no-osd +5%' "$call_log" >/dev/null || \
  fail "Apple display without a connector backlight keeps asdcontrol" "$(cat "$call_log")"
pass "Apple display without a connector backlight keeps asdcontrol"

: >"$call_log"
APPLE_DISPLAY=1 BRIGHTNESSCTL_WRITE_FAIL=apple-DP-3-bl run_brightness --monitor DP-3 +5%
grep -Fx 'omarchy-brightness-display-apple +5%' "$call_log" >/dev/null || \
  fail "unwritable connector backlight falls back to asdcontrol" "$(cat "$call_log")"
if grep -F 'omarchy-osd' "$call_log"; then
  fail "unwritable connector backlight shows no OSD of its own"
fi
pass "unwritable connector backlight falls back to asdcontrol"

: >"$call_log"
rm -f "$runtime_dir/omarchy-brightness-display-ddc/DP-3.bus"
DDC_CONNECTOR=DP-3 DDC_CURRENT=40 DDC_MAXIMUM=100 BRIGHTNESSCTL_WRITE_FAIL=apple-DP-3-bl \
  run_brightness --no-osd --monitor DP-3 30%
grep -F 'ddcutil --bus 7 --skip-ddc-checks --noverify setvcp 10 30' "$call_log" >/dev/null || \
  fail "unwritable connector backlight falls back to DDC with the requested step" "$(cat "$call_log")"
pass "unwritable connector backlight falls back to DDC with the requested step"

: >"$call_log"
APPLE_DISPLAY=1 BRIGHTNESSCTL_READ_FAIL=apple-DP-3-bl run_brightness --monitor DP-3 >/dev/null
grep -Fx 'omarchy-brightness-display-apple ' "$call_log" >/dev/null || \
  fail "unreadable connector backlight falls back to asdcontrol for its level" "$(cat "$call_log")"
pass "unreadable connector backlight falls back to asdcontrol for its level"

stderr=$(APPLE_DISPLAY=1 run_brightness --no-osd --monitor HEADLESS-1 +5% 2>&1 >/dev/null)
[[ -z $stderr ]] || fail "monitor without a DRM connector looks up its backlight quietly" "$stderr"
pass "monitor without a DRM connector looks up its backlight quietly"

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
