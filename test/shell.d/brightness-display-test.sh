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

if command -v bwrap >/dev/null && bwrap --ro-bind / / true 2>/dev/null; then
  mkdir "$test_tmp/lock-sandbox"
  bwrap --ro-bind / / --dev /dev --tmpfs /tmp --ro-bind "$ROOT" "$ROOT" \
    --bind "$test_tmp/lock-sandbox" /tmp/brightness-lock-test --unshare-pid --proc /proc \
    --die-with-parent --setenv TMPDIR /tmp/brightness-lock-test \
    bash "$SHELL_TEST_DIR/fixtures/brightness-display-lock.sh"
else
  skip "Bubblewrap unavailable for isolated backlight lock tests"
fi

mock_bin="$test_tmp/state-bin"
runtime_dir="$test_tmp/state-runtime"
brightness_state="$test_tmp/brightness"
mkdir -p "$mock_bin" "$runtime_dir"
printf '40\n' >"$brightness_state"

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

if [[ $* == *" -m"* ]]; then
  [[ ${BRIGHTNESS_READ_FAIL:-0} == "1" ]] && exit 1
  [[ ${BRIGHTNESS_READ_EMPTY:-0} == "1" ]] && exit 0
  printf 'mock_backlight,backlight,40,%s%%\n' "$(cat "$BRIGHTNESS_STATE")"
  exit 0
fi

if [[ $* == *" set "* ]]; then
  [[ ${BRIGHTNESS_SET_FAIL:-0} == "1" ]] && exit 1
  value=${*: -1}
  printf '%s\n' "${value%%%}" >"$BRIGHTNESS_STATE"
fi
SH

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
if [[ $1 == monitors ]]; then
  printf '[{"name":"eDP-1","disabled":%s,"dpmsStatus":false},{"name":"DP-1","disabled":false}]\n' "${PANEL_DISABLED:-false}"
fi
SH

chmod +x "$mock_bin"/*

run_brightness() {
  BRIGHTNESS_STATE="$brightness_state" XDG_RUNTIME_DIR="$runtime_dir" \
    PATH="$mock_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-brightness-display" "$@"
}

run_brightness off
[[ $(cat "$brightness_state") == 0 ]] || fail "off zeroes the backlight"
[[ $(cat "$runtime_dir/omarchy-brightness-display.saved") == 40 ]] || \
  fail "off saves the current brightness"
run_brightness off
[[ $(cat "$runtime_dir/omarchy-brightness-display.saved") == 40 ]] || \
  fail "repeated off keeps the original saved brightness"
FOCUSED_MONITOR=DP-1 run_brightness on
[[ $(cat "$brightness_state") == 40 ]] || \
  fail "on restores the original brightness after repeated off"
[[ ! -e $runtime_dir/omarchy-brightness-display.saved ]] || \
  fail "successful restore removes the saved brightness"
pass "repeated off/on preserves the original brightness"

printf '55\n' >"$brightness_state"
run_brightness off
BRIGHTNESS_SET_FAIL=1 run_brightness on || true
[[ $(cat "$runtime_dir/omarchy-brightness-display.saved") == 55 ]] || \
  fail "failed restore keeps the saved brightness"
pass "failed restore keeps the saved brightness"

BRIGHTNESS_SET_FAIL=0 run_brightness on
printf '60\n' >"$brightness_state"
BRIGHTNESS_READ_FAIL=1 run_brightness off
[[ $(<"$brightness_state") == 60 ]] || fail "failed read does not zero the backlight"
[[ ! -s $runtime_dir/omarchy-brightness-display.saved ]] || fail "failed read does not save an empty level"
pass "failed read leaves a recoverable backlight level"
FOCUSED_MONITOR=DP-1 run_brightness off
[[ $(<"$brightness_state") == 0 ]] || fail "external focus still blanks the enabled laptop backlight"
run_brightness on
[[ $(<"$brightness_state") == 60 ]] || fail "focus-independent blank restores the laptop level"
pass "blank and wake operate on the laptop regardless of pointer focus"

# Exercise real internal-monitor, mirror and pre-session recovery scripts.
export HOME="$test_tmp/home" OMARCHY_PATH="$ROOT" XDG_RUNTIME_DIR="$runtime_dir"
export PATH="$mock_bin:$ROOT/bin:$PATH" BRIGHTNESS_STATE="$brightness_state"
mkdir -p "$HOME/.local/state/omarchy/toggles/hypr"
cat >"$mock_bin/omarchy-hyprland-monitor-laptop" <<'SCRIPT'
#!/bin/bash
printf 'eDP-1\n'
SCRIPT
cat >"$mock_bin/omarchy-hyprland-monitor-external-active" <<'SCRIPT'
#!/bin/bash
exit "${NO_EXTERNAL:-0}"
SCRIPT
cat >"$mock_bin/omarchy-hw-external-monitors" <<'SCRIPT'
#!/bin/bash
exit "${NO_EXTERNAL:-0}"
SCRIPT
cat >"$mock_bin/omarchy-notification-send" <<'SCRIPT'
#!/bin/bash
exit 0
SCRIPT
chmod +x "$mock_bin"/*
backlight_saved="$HOME/.local/state/omarchy/toggles/hypr/internal-monitor-backlight"
internal_flag="$HOME/.local/state/omarchy/toggles/hypr/internal-monitor-disable.lua"
"$ROOT/bin/omarchy-hyprland-monitor-internal" off
[[ $(<"$brightness_state") == 0 ]] || fail "disabling internal monitor dims backlight"
[[ $(<"$backlight_saved") == 60 ]] || fail "disabling internal monitor saves brightness"
"$ROOT/bin/omarchy-hyprland-monitor-internal-mirror" on
[[ $(<"$brightness_state") == 60 && ! -f $backlight_saved ]] || fail "mirroring restores disabled laptop backlight"
pass "mirroring restores the saved internal backlight"
"$ROOT/bin/omarchy-hyprland-monitor-internal-mirror" off
"$ROOT/bin/omarchy-hyprland-monitor-internal" off
NO_EXTERNAL=1 "$ROOT/bin/omarchy-hw-recover-internal-monitor"
[[ $(<"$brightness_state") == 60 && ! -f $backlight_saved && ! -f $internal_flag ]] || fail "undocked login restores disabled laptop backlight"
pass "pre-session undocked recovery restores the saved internal backlight"

"$ROOT/bin/omarchy-hyprland-monitor-internal" off
BRIGHTNESS_SET_FAIL=1 "$ROOT/bin/omarchy-hyprland-monitor-internal" on
[[ -s $backlight_saved ]] || fail "internal restore failure keeps saved level"
"$ROOT/bin/omarchy-hyprland-monitor-internal" on
[[ $(<"$brightness_state") == 60 && ! -f $backlight_saved ]] || fail "internal on retries after toggle already cleared"
pass "internal restore failure can be retried after clearing the toggle"
BRIGHTNESS_READ_FAIL=1 "$ROOT/bin/omarchy-hyprland-monitor-internal" off
[[ $(<"$brightness_state") == 60 && ! -s $backlight_saved ]] || fail "failed internal read leaves backlight unchanged"
"$ROOT/bin/omarchy-hyprland-monitor-internal" on
pass "failed internal read does not discard the visible level"

run_brightness off
"$ROOT/bin/omarchy-hyprland-monitor-internal" off
[[ $(<"$backlight_saved") == 60 ]] || fail "disabling already blanked panel preserves original brightness"
"$ROOT/bin/omarchy-hyprland-monitor-internal" on
[[ $(<"$brightness_state") == 60 && ! -f $runtime_dir/omarchy-brightness-display.saved ]] || fail "re-enabling blanked panel clears both saved levels"
pass "disable while blanked preserves the original brightness"

# Hold off inside its brightness read and start wake before zeroing happens.
python3 - "$mock_bin/brightnessctl" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1]);s=p.read_text().replace('  printf \'mock_backlight,backlight,40,%s%%\\n\'', '''  if [[ -n ${READ_BARRIER:-} ]]; then
    touch "$READ_BARRIER"
    for _ in {1..250}; do
      [[ -f $READ_RELEASE ]] && break
      sleep 0.02
    done
  fi
  printf 'mock_backlight,backlight,40,%s%%\\n' ''');p.write_text(s)
PY
READ_BARRIER="$test_tmp/read" READ_RELEASE="$test_tmp/release" run_brightness off &
off_pid=$!
for _ in {1..100}; do
  [[ -f $test_tmp/read ]] && break
  sleep 0.02
done
[[ -f $test_tmp/read ]] || fail "off reaches read barrier"
run_brightness on &
on_pid=$!
touch "$test_tmp/release"
wait "$off_pid"
wait "$on_pid"
[[ $(<"$brightness_state") == 60 && ! -f $runtime_dir/omarchy-brightness-display.saved ]] || fail "overlapping wake waits for blank to finish"
pass "overlapping blank and wake restore brightness without losing state"

run_brightness off
PANEL_DISABLED=true FOCUSED_MONITOR=DP-1 run_brightness on
[[ $(<"$brightness_state") == 0 && -s $runtime_dir/omarchy-brightness-display.saved ]] || fail "wake keeps a disabled laptop backlight off"
cat >"$mock_bin/omarchy-hw-clamshell" <<'SCRIPT'
#!/bin/bash
exit 1
SCRIPT
chmod +x "$mock_bin/omarchy-hw-clamshell"
touch "$HOME/.local/state/omarchy/toggles/hypr/internal-monitor-clamshell.lua"
"$ROOT/bin/omarchy-hyprland-monitor-clamshell"
[[ $(<"$brightness_state") == 60 && ! -f $runtime_dir/omarchy-brightness-display.saved ]] || fail "opening lid after external wake restores saved backlight"
pass "wake leaves a closed panel dark and opening the lid restores its level"

printf '65\n' >"$brightness_state"
BRIGHTNESS_READ_EMPTY=1 run_brightness off
[[ $(<"$brightness_state") == 65 && ! -s $runtime_dir/omarchy-brightness-display.saved ]] || fail "empty read does not zero the backlight"
pass "empty successful read leaves the backlight unchanged"

for adjustment in '+5%:45' '5%-:35' '+1%:41' '1%-:39' '+10%:50' '10%+:50' '-10%:30' '70%:70'; do
  step=${adjustment%:*}
  expected=${adjustment#*:}
  printf '40\n' >"$brightness_state"
  run_brightness off
  run_brightness --no-osd "$step"
  [[ $(<"$brightness_state") == "0" ]] || fail "blanked $step keeps the hardware dark"
  [[ $(<"$runtime_dir/omarchy-brightness-display.saved") == "$expected" ]] || fail "blanked $step updates the logical brightness"
  run_brightness on
  [[ $(<"$brightness_state") == "$expected" ]] || fail "wake preserves blanked $step adjustment"
done
pass "brightness keys and absolute adjustments survive wake"

printf '3\n' >"$brightness_state"
run_brightness off
run_brightness --no-osd +5%
run_brightness on
[[ $(<"$brightness_state") == "4" ]] || fail "blanked low brightness keeps adaptive one-percent steps"
pass "adaptive low brightness steps use the saved level"

printf '60\n' >"$brightness_state"
run_brightness off
"$ROOT/bin/omarchy-hyprland-monitor-internal" off
run_brightness --no-osd 70%
[[ $(<"$brightness_state") == "0" && $(<"$backlight_saved") == "70" && $(<"$runtime_dir/omarchy-brightness-display.saved") == "70" ]] || fail "adjustment updates both snapshots without lighting the panel"
"$ROOT/bin/omarchy-hyprland-monitor-internal" on
run_brightness on
[[ $(<"$brightness_state") == "70" ]] || fail "re-enabling an adjusted disabled panel preserves its new level"
pass "explicit adjustment updates disabled and blank restore state while staying dark"

"$ROOT/bin/omarchy-hyprland-monitor-internal" off
run_brightness --no-osd +5%
"$ROOT/bin/omarchy-hyprland-monitor-internal" on
[[ $(<"$brightness_state") == "75" && ! -e $backlight_saved ]] || fail "persistent-only saved level drives relative adjustment"
pass "relative adjustment uses persistent disable state without a blank snapshot"

printf '40\n' >"$brightness_state"
run_brightness off
"$ROOT/bin/omarchy-hyprland-monitor-internal" off
for argument in 500 +500 500- invalid 100000000000000000000%; do
  if run_brightness --no-osd "$argument" 2>/dev/null; then
    fail "unsupported saved-state argument returns failure"
  fi
  [[ $(<"$brightness_state") == "0" && $(<"$backlight_saved") == "40" && $(<"$runtime_dir/omarchy-brightness-display.saved") == "40" ]] || fail "unsupported argument preserves dark hardware and both snapshots"
done
pass "unsupported saved-state arguments leave hardware and snapshots unchanged"

for failing_command in mktemp mv; do
  cat >"$mock_bin/$failing_command" <<'SCRIPT'
#!/bin/bash
if [[ $* == *"internal-monitor-backlight"* ]]; then
  exit 1
fi
exec "/usr/bin/$(basename "$0")" "$@"
SCRIPT
  chmod +x "$mock_bin/$failing_command"
  if run_brightness --no-osd 70%; then
    fail "snapshot replacement failure returns failure"
  fi
  [[ $(<"$brightness_state") == "0" && $(<"$backlight_saved") == "40" && $(<"$runtime_dir/omarchy-brightness-display.saved") == "40" ]] || fail "failed $failing_command leaves both original targets and hardware intact"
  rm "$mock_bin/$failing_command"
done
pass "staging and replacement failures retain both original restore levels"

cat >"$mock_bin/omarchy-osd" <<'SCRIPT'
#!/bin/bash
printf '%s\n' "$*" >"$OSD_LOG"
SCRIPT
chmod +x "$mock_bin/omarchy-osd"
export OSD_LOG="$test_tmp/osd"
BRIGHTNESS_SET_FAIL=1 run_brightness 70%
[[ $(<"$brightness_state") == "0" && $(<"$backlight_saved") == "70" && $(<"$runtime_dir/omarchy-brightness-display.saved") == "70" ]] || fail "saved-state adjustment avoids setting dark hardware"
[[ $(<"$OSD_LOG") == "-i brightness -p 70" ]] || fail "OSD shows logical brightness while dark"
if BRIGHTNESS_READ_FAIL=1 run_brightness --no-osd +5%; then
  fail "unavailable hardware level returns failure before choosing dark or live adjustment"
fi
[[ $(<"$brightness_state") == "0" && $(<"$backlight_saved") == "70" && $(<"$runtime_dir/omarchy-brightness-display.saved") == "70" ]] || fail "failed hardware probe retains restore state and darkness"
PANEL_DISABLED=true run_brightness on
[[ $(<"$brightness_state") == "0" && -s $backlight_saved && -s $runtime_dir/omarchy-brightness-display.saved ]] || fail "disabled wake retains the adjusted dark state"
"$ROOT/bin/omarchy-hyprland-monitor-internal" on
[[ $(<"$brightness_state") == "70" && ! -e $backlight_saved && ! -e $runtime_dir/omarchy-brightness-display.saved ]] || fail "internal wake consumes adjusted snapshots"
pass "saved-state OSD and disabled wake preserve darkness until internal restore"

printf '40\n' >"$brightness_state"
run_brightness off
run_brightness --no-osd +5%
run_brightness --no-osd +5%
run_brightness off
[[ $(<"$brightness_state") == "0" && $(<"$runtime_dir/omarchy-brightness-display.saved") == "50" ]] || fail "repeated keys and blanking preserve the adjusted target"
run_brightness on
[[ $(<"$brightness_state") == "50" ]] || fail "wake restores the latest repeated adjustment"
pass "repeated dark adjustments compose and survive repeated blanking"

printf '40\n' >"$brightness_state"
BRIGHTNESS_SET_FAIL=1 run_brightness off
[[ $(<"$brightness_state") == "40" && $(<"$runtime_dir/omarchy-brightness-display.saved") == "40" ]] || fail "failed blank leaves a lit backlight beside its snapshot"
run_brightness --no-osd +5%
[[ $(<"$brightness_state") == "45" && ! -e $runtime_dir/omarchy-brightness-display.saved ]] || fail "brightness key adjusts still-lit hardware and retires stale blank state"
run_brightness on
[[ $(<"$brightness_state") == "45" ]] || fail "wake cannot overwrite adjustment after failed blank"
pass "brightness keys still adjust a lit backlight after blanking fails"

printf '50\n' >"$brightness_state"
printf 'broken\n' >"$runtime_dir/omarchy-brightness-display.saved"
if run_brightness --no-osd +5% 2>/dev/null; then
  fail "malformed saved brightness returns failure"
fi
[[ $(<"$brightness_state") == "50" && $(<"$runtime_dir/omarchy-brightness-display.saved") == "broken" ]] || fail "malformed state does not adjust hardware or overwrite the snapshot"
rm "$runtime_dir/omarchy-brightness-display.saved"
pass "malformed saved state is rejected without hardware side effects"

cat >"$mock_bin/omarchy-brightness-display-ddc" <<'SCRIPT'
#!/bin/bash
printf '50\n'
SCRIPT
chmod +x "$mock_bin/omarchy-brightness-display-ddc"
printf '40\n' >"$brightness_state"
run_brightness off
FOCUSED_MONITOR=DP-1 run_brightness --no-osd 50%
[[ $(<"$runtime_dir/omarchy-brightness-display.saved") == "40" ]] || fail "external adjustment must retain laptop restore state"
run_brightness on
[[ $(<"$brightness_state") == "40" ]] || fail "external adjustment leaves laptop wake level unchanged"
pass "external brightness adjustment does not consume laptop snapshots"
