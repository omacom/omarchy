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
[[ ${APPLE_MONITOR:-0} == "1" ]]
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

cat >"$mock_bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH

cat >"$mock_bin/asdcontrol" <<'SH'
#!/bin/bash
printf 'asdcontrol %s\n' "$*" >>"$CALL_LOG"

if [[ ${1:-} == "--detect" ]]; then
  shift
  for device in "$@"; do
    case "$device" in
    *hiddev5 | *hiddev10) printf '%s: USB Monitor - SUPPORTED.\n' "$device" ;;
    *hiddev7) printf '%s: USB Monitor - UNSUPPORTED.\n' "$device" ;;
    esac
  done
elif (( $# == 1 )); then
  case "$1" in
  *hiddev5) printf 'BRIGHTNESS=24000\n' ;;
  *hiddev10) printf 'BRIGHTNESS=36000\n' ;;
  *) exit 1 ;;
  esac
elif (( $# == 3 )) && [[ $2 == "--" ]]; then
  [[ ${ASD_WRITE_FAIL_DEVICE:-} != "$1" ]]
else
  exit 2
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
    OMARCHY_BRIGHTNESS_APPLE_DEV_ROOT="$test_tmp/dev" PATH="$mock_bin:$ROOT/bin:$PATH" "$brightness_display" "$@"
}

mkdir -p "$test_tmp/dev/usb"
touch "$test_tmp/dev/usb/hiddev5" "$test_tmp/dev/usb/hiddev7" "$test_tmp/dev/usb/hiddev10"

if ! brightness=$(APPLE_MONITOR=1 run_brightness --monitor DP-1); then
  fail "Apple displays report their group brightness"
fi
[[ $brightness == "50" ]] || fail "Apple displays report their group brightness" "actual: $brightness"
APPLE_MONITOR=1 run_brightness --no-osd --monitor DP-1 +5%
grep -F "asdcontrol $test_tmp/dev/usb/hiddev5 -- 55%" "$call_log" >/dev/null ||
  fail "Apple brightness is written to the first display"
grep -F "asdcontrol $test_tmp/dev/usb/hiddev10 -- 55%" "$call_log" >/dev/null ||
  fail "Apple brightness is written to the second display"
if grep -F "asdcontrol $test_tmp/dev/usb/hiddev7 -- 55%" "$call_log" >/dev/null; then
  fail "unsupported HID devices are excluded from the Apple brightness group"
fi
pass "Apple displays share one brightness"

(( $(grep -c '^asdcontrol --detect ' "$call_log") == 1 )) || fail "Apple display detection is cached"
pass "Apple display detection is cached"

apple_cache="$runtime_dir/omarchy-brightness-display-apple.devices"
printf '%s\n' "$test_tmp/dev/usb/hiddev10 $test_tmp/dev/usb/hiddev5 $test_tmp/dev/usb/hiddev7" \
  "$test_tmp/dev/usb/hiddev7" >"$apple_cache"
brightness=$(APPLE_MONITOR=1 run_brightness --monitor DP-1) || fail "a stale Apple display cache is detected again"
[[ $brightness == "50" ]] || fail "a stale Apple display cache is detected again" "actual: $brightness"
grep -Fx "$test_tmp/dev/usb/hiddev7" "$apple_cache" >/dev/null && fail "a stale Apple display cache is replaced"
pass "a stale Apple display cache is detected again"

printf '%s\n' "$test_tmp/dev/usb/hiddev10 $test_tmp/dev/usb/hiddev5 $test_tmp/dev/usb/hiddev7" \
  "$test_tmp/dev/sda" >"$apple_cache"
: >"$call_log"
APPLE_MONITOR=1 run_brightness --monitor DP-1 >/dev/null
grep -F "asdcontrol $test_tmp/dev/sda" "$call_log" >/dev/null && fail "a cached path outside the HID nodes is not trusted"
pass "a cached path outside the HID nodes is not trusted"

if APPLE_MONITOR=1 ASD_WRITE_FAIL_DEVICE="$test_tmp/dev/usb/hiddev10" \
  run_brightness --no-osd --monitor DP-1 55%; then
  fail "Apple group brightness reports a partial write failure"
fi
pass "Apple group brightness reports a partial write failure"

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

lock_file="$runtime_dir/omarchy-brightness-display.lock"
lock_ready="$test_tmp/lock-ready"
lock_release="$test_tmp/lock-release"
mkfifo "$lock_release"
(
  exec {held_lock_fd}>"$lock_file"
  flock "$held_lock_fd"
  touch "$lock_ready"
  read -r <"$lock_release"
) &
lock_holder_pid=$!
while [[ ! -e $lock_ready ]]; do sleep 0.01; done

if run_brightness --nonblocking --no-osd --monitor DP-1 35%; then
  fail "nonblocking automatic writes report lock contention"
else
  [[ $? == 75 ]] || fail "nonblocking automatic writes use the busy exit status"
fi

if timeout 0.1 env CALL_LOG="$call_log" XDG_RUNTIME_DIR="$runtime_dir" PATH="$mock_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-brightness-display" --no-osd --monitor DP-1 35% --nonblocking; then
  fail "trailing nonblocking writes report lock contention"
else
  [[ $? == 75 ]] || fail "trailing nonblocking writes use the busy exit status"
fi

write_count=$(grep -c ' setvcp 10 ' "$call_log")
if timeout 0.1 env CALL_LOG="$call_log" XDG_RUNTIME_DIR="$runtime_dir" PATH="$mock_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-brightness-display" --no-osd --monitor DP-1 35%; then
  fail "manual absolute writes wait for the brightness lock"
else
  [[ $? == 124 ]] || fail "manual absolute writes block during lock contention"
fi
printf '\n' >"$lock_release"
wait "$lock_holder_pid"
run_brightness --no-osd --monitor DP-1 35%
(( $(grep -c ' setvcp 10 ' "$call_log") == write_count + 1 )) ||
  fail "manual absolute writes wait for the brightness lock"
pass "automatic writes yield the brightness lock to manual absolute writes"

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
