#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
call_log="$test_tmp/calls"
written_value="$test_tmp/written-value"
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
elif [[ ${BACKLIGHT_WRITE_FAIL:-0} == "1" ]]; then
  exit 1
fi
SH

cat >"$mock_bin/omarchy-osd" <<'SH'
#!/bin/bash
printf 'omarchy-osd %s\n' "$*" >>"$CALL_LOG"
SH

cat >"$mock_bin/ddcutil" <<'SH'
#!/bin/bash
printf 'ddcutil %s\n' "$*" >>"$CALL_LOG"

skip_checks=0
verify=0
operation=""
target=""
while (( $# > 0 )); do
  case "$1" in
  --bus)
    shift 2
    ;;
  --skip-ddc-checks)
    skip_checks=1
    shift
    ;;
  --verify)
    verify=1
    shift
    ;;
  --noverify)
    verify=0
    shift
    ;;
  --brief)
    shift
    ;;
  detect)
    operation="$1"
    shift
    ;;
  getvcp)
    [[ $2 == "10" ]] || exit 1
    operation="$1"
    shift 2
    ;;
  setvcp)
    [[ $2 == "10" ]] || exit 1
    operation="$1"
    target="$3"
    shift 3
    ;;
  *)
    printf 'Unrecognized option: %s\n' "$1" >&2
    exit 1
    ;;
  esac
done

case "$operation" in
detect)
  cat <<EOF
Display 1
   I2C bus:             /dev/i2c-${DDC_BUS:-7}
   DRM connector:       card1-${DDC_CONNECTOR:-DP-1}
EOF
  ;;
getvcp)
  [[ ${DDC_READ_FAIL:-0} == "1" ]] && exit 1
  current="${DDC_CURRENT:-40}"
  if [[ -z ${DDC_CURRENT:-} && -r $WRITTEN_VALUE ]]; then
    read -r current <"$WRITTEN_VALUE"
  fi
  printf 'VCP 10 C %s %s\n' "$current" "${DDC_MAXIMUM:-80}"
  ;;
setvcp)
  if [[ ${DDC_WRITE_FAIL:-0} == "1" ]] || { (( skip_checks )) && [[ ${DDC_SWALLOW_FAST_WRITE:-0} == "1" ]]; }; then
    (( verify )) && exit 1
  else
    printf '%s\n' "$target" >"$WRITTEN_VALUE"
  fi
  ;;
esac
exit 0
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
  CALL_LOG="$call_log" WRITTEN_VALUE="$written_value" XDG_RUNTIME_DIR="$runtime_dir" \
    PATH="$mock_bin:$ROOT/bin:$PATH" "$brightness_display" "$@"
}

brightness=$(run_brightness --monitor DP-1)
[[ $brightness == "50" ]] || fail "external brightness is converted to a percentage" "actual: $brightness"
pass "external brightness is converted to a percentage"

(( $(grep -c '^ddcutil --skip-ddc-checks detect --brief$' "$call_log") == 1 )) || fail "DDC bus is detected once"
run_brightness --monitor DP-1 >/dev/null
(( $(grep -c '^ddcutil --skip-ddc-checks detect --brief$' "$call_log") == 1 )) || fail "DDC bus mapping is cached"
pass "DDC bus mapping is cached"

run_brightness --monitor DP-1 25% || fail "external brightness works with ddcutil 2.2.7 options"
[[ $(cat "$written_value") == "20" ]] || fail "external brightness converts the target to the monitor range"
grep -Fx 'omarchy-osd -i brightness -p 25' "$call_log" >/dev/null || \
  fail "successful external writes show the new brightness"
pass "external writes work with ddcutil 2.2.7 options and show the new brightness"

get_count=$(grep -c ' getvcp 10 ' "$call_log")
run_brightness --no-osd --monitor DP-1 30%
(( $(grep -c ' getvcp 10 ' "$call_log") == get_count )) || \
  fail "absolute external brightness reuses the cached VCP range"
[[ $(cat "$written_value") == "24" ]] || fail "cached external range converts the target correctly"
pass "absolute external brightness reuses the cached VCP range"

set_count=$(grep -c ' setvcp 10 ' "$call_log")
DDC_SWALLOW_FAST_WRITE=1 run_brightness --no-osd --monitor DP-1 35% || \
  fail "full DDC checks avoid a swallowed first write"
[[ $(cat "$written_value") == "28" ]] || fail "the monitor receives the brightness target"
(( $(grep -c ' setvcp 10 ' "$call_log") == set_count + 1 )) || \
  fail "external brightness uses one DDC process"
pass "full DDC checks avoid a swallowed first write in one process"

set_count=$(grep -c ' setvcp 10 ' "$call_log")
detect_count=$(grep -c ' detect --brief' "$call_log")
osd_count=$(grep -c '^omarchy-osd ' "$call_log")
if DDC_WRITE_FAIL=1 run_brightness --monitor DP-1 45% >"$test_tmp/failed-output" 2>&1; then
  fail "rejected external brightness write is reported"
fi
[[ ! -s $test_tmp/failed-output ]] || fail "failed writes do not report an unconfirmed brightness"
[[ $(cat "$written_value") == "28" ]] || fail "the rejected write leaves the monitor unchanged"
(( $(grep -c '^omarchy-osd ' "$call_log") == osd_count )) || \
  fail "failed external writes do not show a success OSD"
(( $(grep -c ' setvcp 10 ' "$call_log") == set_count + 1 )) || \
  fail "a rejected write uses one DDC process"
get_count=$(grep -c ' getvcp 10 ' "$call_log")
brightness=$(run_brightness --monitor DP-1) || fail "external brightness stays readable after a rejected write"
[[ $brightness == "35" ]] || fail "external brightness stays readable after a rejected write" "actual: $brightness"
(( $(grep -c ' getvcp 10 ' "$call_log") == get_count + 1 )) || \
  fail "external brightness is re-read after a rejected write"
(( $(grep -c ' detect --brief' "$call_log") == detect_count )) || \
  fail "a rejected write keeps the cached DDC bus"
if DDC_WRITE_FAIL=1 CALL_LOG="$call_log" WRITTEN_VALUE="$written_value" XDG_RUNTIME_DIR="$runtime_dir" PATH="$mock_bin:$PATH" \
  "$ROOT/bin/omarchy-brightness-display-ddc" DP-1 45% >"$test_tmp/failed-output" 2>&1; then
  fail "the DDC helper reports a failed verification"
fi
[[ ! -s $test_tmp/failed-output ]] || fail "the DDC helper does not emit an unconfirmed percentage"
pass "rejected writes report failure without a false brightness or OSD and preserve the cached bus"
rm -f "$runtime_dir/omarchy-brightness-display-ddc/DP-1.bus"

brightness=$(run_brightness --monitor eDP-1)
[[ $brightness == "40" ]] || fail "internal monitor uses the kernel backlight" "actual: $brightness"
grep -F 'brightnessctl -d mock_backlight -m' "$call_log" >/dev/null || \
  fail "internal monitor queries brightnessctl"
pass "internal monitor uses the kernel backlight"

brightness=$(FOCUSED_MONITOR=DP-1 run_brightness)
[[ $brightness == "35" ]] || fail "brightness follows the focused external monitor" "actual: $brightness"
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
[[ $brightness == "35" ]] || fail "transient DDC read failure is retried on the next invocation" "actual: $brightness"
(( $(grep -c ' detect --brief' "$call_log") == detect_count + 2 )) || \
  fail "transient DDC read failure does not create a negative cache entry"
pass "transient DDC read failure is retried on the next invocation"

printf '7 80 0\n' >"$runtime_dir/omarchy-brightness-display-ddc/DP-1.bus"
get_count=$(grep -c ' getvcp 10 ' "$call_log")
DDC_MAXIMUM=100 run_brightness --no-osd --monitor DP-1 50%
(( $(grep -c ' getvcp 10 ' "$call_log") == get_count + 1 )) || \
  fail "expired external brightness range is refreshed"
[[ $(cat "$written_value") == "50" ]] || fail "expired external brightness range uses the refreshed maximum"
pass "expired external brightness range is refreshed"

rm -f "$runtime_dir/omarchy-brightness-display-ddc/DP-1.bus"
DDC_CURRENT=4 DDC_MAXIMUM=100 run_brightness --no-osd --monitor DP-1 +5%
[[ $(cat "$written_value") == "5" ]] || fail "external low brightness writes the one-percent target"
pass "external low brightness uses a one-percent step"

exec {test_lock_fd}>"$runtime_dir/omarchy-brightness-display.lock"
flock -n "$test_lock_fd"
call_count=$(wc -l <"$call_log")
if run_brightness --monitor DP-1 40% >/dev/null 2>&1; then
  fail "a dropped brightness write is not reported as successful"
fi
(( $(wc -l <"$call_log") == call_count )) || fail "a dropped brightness write never reaches the backend or OSD"
brightness=$(run_brightness --monitor DP-1)
[[ -n $brightness ]] || fail "brightness stays readable while a write holds the lock"
flock -u "$test_lock_fd"
exec {test_lock_fd}>&-
pass "a dropped brightness write fails without changing the display or showing an OSD"

osd_count=$(grep -c '^omarchy-osd ' "$call_log")
if BACKLIGHT_WRITE_FAIL=1 run_brightness --no-osd --monitor eDP-1 40%; then
  fail "a failed internal brightness write is reported"
fi
if BACKLIGHT_WRITE_FAIL=1 run_brightness --monitor eDP-1 40%; then
  fail "a failed internal brightness write is reported with the OSD enabled"
fi
(( $(grep -c '^omarchy-osd ' "$call_log") == osd_count )) || fail "a failed internal brightness write shows no success OSD"
pass "a failed internal brightness write fails without showing a success OSD"

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
printf '40\n' >"$written_value"
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
