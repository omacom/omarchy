#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
runtime_dir="$test_tmp/runtime"
brightness_state="$test_tmp/brightness"
mkdir -p "$mock_bin" "$runtime_dir"
printf '40\n' >"$brightness_state"

cat >"$mock_bin/omarchy-hyprland-monitor-focused-apple" <<'SH'
#!/bin/bash
exit 1
SH

cat >"$mock_bin/omarchy-hyprland-monitor-focused" <<'SH'
#!/bin/bash
printf 'eDP-1\n'
SH

cat >"$mock_bin/omarchy-hw-display" <<'SH'
#!/bin/bash
printf 'mock_backlight\n'
SH

cat >"$mock_bin/brightnessctl" <<'SH'
#!/bin/bash

if [[ $* == *" -m"* ]]; then
  [[ ${BRIGHTNESS_READ_FAIL:-0} == 1 ]] && exit 1
  printf 'mock_backlight,backlight,40,%s%%\n' "$(cat "$BRIGHTNESS_STATE")"
  exit 0
fi

if [[ $* == *" set "* ]]; then
  [[ ${BRIGHTNESS_SET_FAIL:-0} == 1 ]] && exit 1
  value=${*: -1}
  printf '%s\n' "${value%%%}" >"$BRIGHTNESS_STATE"
fi
SH

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
if [[ $1 == monitors ]]; then
  printf '[]\n'
fi
SH

chmod +x "$mock_bin"/*

run_brightness() {
  BRIGHTNESS_STATE="$brightness_state" XDG_RUNTIME_DIR="$runtime_dir" \
    PATH="$mock_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-brightness-display" "$@"
}

run_brightness off
[[ $(cat "$runtime_dir/omarchy-brightness-display.saved") == 40 ]] || \
  fail "off saves the current brightness"
run_brightness off
[[ $(cat "$runtime_dir/omarchy-brightness-display.saved") == 40 ]] || \
  fail "repeated off keeps the original saved brightness"
run_brightness on
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
