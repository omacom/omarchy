#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

hook="$ROOT/default/systemd/system-sleep/keyboard-backlight"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

leds="$tmpdir/leds"
mkdir -p "$leds/tpacpi::kbd_backlight"
mock_bin="$tmpdir/bin"
state_dir="$tmpdir/state"
mkdir -p "$mock_bin" "$state_dir"
calls="$tmpdir/calls"
: >"$calls"

cat >"$mock_bin/brightnessctl" <<'SH'
#!/bin/bash
printf 'brightnessctl' >>"$CALLS"
printf '\t%s' "$@" >>"$CALLS"
printf '\n' >>"$CALLS"
if [[ $* == *-d* && $* == *get* ]]; then
  echo "${BRIGHTNESS_VALUE:-2}"
fi
SH
chmod +x "$mock_bin/brightnessctl"

run_hook() {
  CALLS="$calls" PATH="$mock_bin:$PATH"     OMARCHY_KBD_BACKLIGHT_DIR="$leds"     OMARCHY_KBD_SLEEP_STATE_DIR="$state_dir"     "$hook" "$@"
}

: >"$calls"
BRIGHTNESS_VALUE=2 run_hook pre suspend
[[ $(<"$state_dir/keyboard-backlight-sleep.state") == $'tpacpi::kbd_backlight\t2' ]] ||
  fail "suspend pre writes an independent brightness receipt"
! grep -q $'\t-sd\|\t-rd' "$calls" ||
  fail "system-sleep hook must not use brightnessctl shared save/restore state" "$(cat "$calls")"
! grep -Eq $'brightnessctl\t-d\ttpacpi::kbd_backlight\tset\t0$' "$calls" ||
  fail "ordinary suspend must not force keyboard LEDs off" "$(cat "$calls")"
pass "suspend records brightness without consuming lock/idle save state"

: >"$calls"
SYSTEMD_SLEEP_ACTION=hibernate BRIGHTNESS_VALUE=3 run_hook pre
grep -F $'brightnessctl\t-d\ttpacpi::kbd_backlight\tset\t0' "$calls" >/dev/null ||
  fail "hibernate pre zeros keyboard LEDs" "$(cat "$calls")"
[[ $(<"$state_dir/keyboard-backlight-sleep.state") == $'tpacpi::kbd_backlight\t3' ]] ||
  fail "hibernate preserves the pre-zero brightness receipt"
pass "hibernate saves brightness then zeros LEDs"

: >"$calls"
run_hook post suspend
grep -F $'brightnessctl\t-d\ttpacpi::kbd_backlight\tset\t3' "$calls" >/dev/null ||
  fail "post restores the exact sleep-owned brightness" "$(cat "$calls")"
[[ ! -e $state_dir/keyboard-backlight-sleep.state ]] ||
  fail "post consumes the sleep-owned brightness receipt"
pass "post restores and consumes only the sleep-owned receipt"

: >"$calls"
run_hook post suspend
[[ ! -s $calls ]] || fail "post without a sleep receipt is a no-op" "$(cat "$calls")"
pass "post without a receipt is a no-op"

# A failed next pre must not leave a prior-cycle receipt for post to consume.
printf 'tpacpi::kbd_backlight\t9\n' >"$state_dir/keyboard-backlight-sleep.state"
mkdir -p "$tmpdir/no-leds"
: >"$calls"
CALLS="$calls" PATH="$mock_bin:$PATH" OMARCHY_KBD_BACKLIGHT_DIR="$tmpdir/no-leds" \
  OMARCHY_KBD_SLEEP_STATE_DIR="$state_dir" "$hook" pre suspend
[[ ! -e $state_dir/keyboard-backlight-sleep.state ]] ||
  fail "failed new pre leaves a stale keyboard brightness receipt"
pass "failed new pre cannot resurrect prior-cycle brightness"

mkdir -p "$tmpdir/empty-leds"
: >"$calls"
CALLS="$calls" PATH="$mock_bin:$PATH" OMARCHY_KBD_BACKLIGHT_DIR="$tmpdir/empty-leds"   OMARCHY_KBD_SLEEP_STATE_DIR="$state_dir" "$hook" pre suspend
[[ ! -s $calls ]] || fail "missing kbd device is a no-op" "$(cat "$calls")"
pass "missing kbd device is a no-op"
