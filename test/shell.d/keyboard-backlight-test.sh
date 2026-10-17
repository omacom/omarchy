#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

keyboard="$ROOT/bin/omarchy-brightness-keyboard"
wake="$ROOT/bin/omarchy-system-wake"

# The bug: screensaver dismiss runs omarchy-system-wake (keyboard restore)
# without any preceding keyboard off, so restore must not apply a stale
# brightnessctl save. The marker pairs off/restore.
grep -F 'state_marker="${XDG_RUNTIME_DIR:-/tmp}/omarchy-keyboard-backlight-off"' "$keyboard" >/dev/null || \
  fail "keyboard backlight tracks whether off actually blanked the keyboard"
pass "keyboard backlight tracks whether off actually blanked the keyboard"

# A repeated off while already at zero must not re-save (which would clobber
# the saved brightness with 0 and make the later restore a no-op).
grep -F 'if (( current_brightness == 0 )); then' "$keyboard" >/dev/null || \
  fail "keyboard off avoids re-saving when already off"
grep -F 'brightnessctl -d "$device" set 0' "$keyboard" >/dev/null || \
  fail "repeated keyboard off turns off without saving"
grep -F 'brightnessctl -sd "$device" set 0' "$keyboard" >/dev/null || \
  fail "keyboard off saves state when turning off a lit keyboard"
pass "keyboard off only saves when turning off a lit keyboard"

# Restore without a preceding off (screensaver dismiss) stays put.
grep -F 'if [[ ! -f $state_marker ]]; then' "$keyboard" >/dev/null || \
  fail "keyboard restore without a preceding off is a no-op"
pass "keyboard restore without a preceding off is a no-op"

# Restore is one-shot and never clobbers a keyboard that is already lit
# (e.g. user adjusted it while locked).
grep -F 'rm -f "$state_marker"' "$keyboard" >/dev/null || \
  fail "keyboard restore clears its marker"
grep -F 'if (( current_brightness != 0 )); then' "$keyboard" >/dev/null || \
  fail "keyboard restore leaves an already-lit keyboard alone"
grep -F 'brightnessctl -rd "$device"' "$keyboard" >/dev/null || \
  fail "keyboard restore still restores a blanked keyboard"
pass "keyboard restore is one-shot and leaves a lit keyboard alone"

# The wake path itself is unchanged: display on, keyboard restore, clamshell.
grep -F 'omarchy-brightness-keyboard restore' "$wake" >/dev/null || \
  fail "system wake still restores keyboard brightness"
pass "system wake still restores keyboard brightness"
