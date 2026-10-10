#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'if [[ -r $test_tmp/running ]]; then kill "$(<"$test_tmp/running")" 2>/dev/null || true; fi; rm -rf "$test_tmp"' EXIT
mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/runtime" "$test_tmp/config/hypr"
printf '2\n' >"$test_tmp/hardware"
printf '6000\n' >"$test_tmp/temperature"
printf 'profile {\n  identity = true\n}\n' >"$test_tmp/config/hypr/hyprsunset.conf"

cat >"$mock_bin/omarchy-hyprland-monitor-focused" <<'SH'
#!/bin/bash
printf 'eDP-1\n'
SH

cat >"$mock_bin/omarchy-hyprland-monitor-focused-apple" <<'SH'
#!/bin/bash
exit 1
SH

cat >"$mock_bin/omarchy-hw-display" <<'SH'
#!/bin/bash
printf 'mock_backlight\n'
SH

cat >"$mock_bin/brightnessctl" <<'SH'
#!/bin/bash
if [[ $* == *" -m"* ]]; then
  brightness=$(<"$TEST_ROOT/hardware")
  printf 'mock_backlight,backlight,%s,%s%%\n' "$brightness" "$brightness"
elif [[ $* == *" set "* ]]; then
  value=${@: -1}
  printf '%s\n' "${value%%%}" >"$TEST_ROOT/hardware"
fi
SH

cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
[[ -f $TEST_ROOT/running ]] || exit 1
pid=$(<"$TEST_ROOT/running")
[[ -r /proc/$pid/stat ]] || exit 1
[[ $(awk '{ print $3 }' "/proc/$pid/stat") != "Z" ]] || exit 1
printf '%s\n' "$pid"
SH

cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
sleep 1000 >/dev/null 2>&1 &
printf '%s\n' "$!" >"$TEST_ROOT/running"
printf '100\n' >"$TEST_ROOT/gamma"
printf 'start\n' >>"$TEST_ROOT/events"
SH

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
[[ ${1:-} == "hyprsunset" && -f $TEST_ROOT/running ]] || exit 1
case ${2:-} in
gamma)
  if [[ -n ${3:-} ]]; then
    printf '%s\n' "$3" >"$TEST_ROOT/gamma"
  else
    cat "$TEST_ROOT/gamma"
  fi
  ;;
temperature)
  cat "$TEST_ROOT/temperature"
  ;;
*) exit 1 ;;
esac
SH

cat >"$mock_bin/omarchy-osd" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_ROOT/osd"
SH

chmod +x "$mock_bin"/*

run_brightness() {
  TEST_ROOT="$test_tmp" XDG_RUNTIME_DIR="$test_tmp/runtime" XDG_CONFIG_HOME="$test_tmp/config" \
    PATH="$mock_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-brightness-display" "$@"
}

run_gamma() {
  TEST_ROOT="$test_tmp" XDG_RUNTIME_DIR="$test_tmp/runtime" XDG_CONFIG_HOME="$test_tmp/config" \
    PATH="$mock_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-brightness-display-gamma" "$@"
}

[[ $(run_brightness) == "2" ]] || fail "internal brightness starts with hardware percentage"
run_brightness --no-osd 5%-
[[ $(<"$test_tmp/hardware") == "1" ]] || fail "low brightness uses one-percent hardware steps"
run_brightness --no-osd 5%-
[[ $(<"$test_tmp/hardware") == "0" ]] || fail "brightness reaches hardware zero"
[[ ! -e $test_tmp/running ]] || fail "hyprsunset waits until a gamma adjustment is needed"
[[ $(run_brightness) == "1.0" ]] || fail "hardware zero at neutral gamma reports the handoff level"
pass "hardware reaches zero before gamma changes"

run_brightness --no-osd 5%-
[[ $(<"$test_tmp/gamma") == "93" ]] || fail "first gamma step is 93 percent"
[[ $(run_brightness) == "0.9" ]] || fail "first gamma step reports 0.9 percent"
for _ in {1..9}; do run_brightness --no-osd 5%-; done
[[ $(<"$test_tmp/gamma") == "25" ]] || fail "gamma stops at 25 percent"
[[ $(run_brightness) == "0.0" ]] || fail "minimum brightness reports zero"
run_brightness --no-osd 5%-
[[ $(<"$test_tmp/gamma") == "25" ]] || fail "further down presses keep gamma at 25 percent"
run_brightness --no-osd +1%
[[ $(run_brightness) == "0.1" ]] || fail "precise up key reverses the gamma range"
pass "gamma range has ten steps and a 25-percent floor"

run_brightness 0.5%
[[ $(<"$test_tmp/gamma") == "63" ]] || fail "fractional absolute brightness maps to gamma"
rg -q -- '-i brightness -p 0.5' "$test_tmp/osd" || fail "OSD receives fractional brightness"
run_brightness --no-osd 0%
[[ $(<"$test_tmp/gamma") == "25" ]] || fail "absolute zero uses gamma 25 percent"
run_brightness --no-osd 1%
[[ $(<"$test_tmp/hardware") == "1" ]] || fail "absolute one returns to hardware brightness"
[[ ! -e $test_tmp/runtime/omarchy-brightness-display.hyprsunset ]] || fail "brightness-owned hyprsunset stops above the gamma range"
pass "absolute brightness and OSD support fractional values"

sleep 1000 >/dev/null 2>&1 &
printf '%s\n' "$!" >"$test_tmp/running"
printf '100\n' >"$test_tmp/gamma"
run_brightness --no-osd 0%
run_brightness --no-osd 1%
kill -0 "$(<"$test_tmp/running")" 2>/dev/null || fail "preexisting hyprsunset is preserved"
pass "preexisting hyprsunset is preserved"

kill "$(<"$test_tmp/running")"
rm -f "$test_tmp/running"
run_brightness --no-osd 0%
printf '4000\n' >"$test_tmp/temperature"
run_brightness --no-osd 1%
kill -0 "$(<"$test_tmp/running")" 2>/dev/null || fail "active night light keeps brightness-owned hyprsunset running"
printf '6500\n' >"$test_tmp/temperature"
run_gamma cleanup
[[ ! -e $test_tmp/runtime/omarchy-brightness-display.hyprsunset ]] || fail "hyprsunset stops when night light is disabled"
pass "night light retains the process only while needed"
