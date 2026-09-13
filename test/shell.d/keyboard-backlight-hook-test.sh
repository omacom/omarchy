#!/bin/bash

# The hibernate hook clears the keyboard backlight so the ASUS S4 transition
# cannot hang on an active LED. Clearing is one-way in hardware, so the level has
# to be recorded and put back after the resume, or the keyboard stays dark until
# a brightness key is pressed. These assertions run the real hook against a
# sandboxed LED by rewriting the two absolute paths it uses.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

hook_source="$ROOT/default/systemd/system-sleep/keyboard-backlight"
sandbox=$(mktemp -d -p /tmp)
trap 'rm -rf "$sandbox"' EXIT

leds="$sandbox/leds"
record="$sandbox/recorded-level"
led="$leds/asus::kbd_backlight/brightness"
hook="$sandbox/hook.sh"

mkdir -p "${led%/*}"
sed \
  -e "s|/sys/class/leds|$leds|g" \
  -e "s|/run/omarchy-keyboard-backlight-level|$record|g" \
  "$hook_source" >"$hook"

echo 3 >"$led"
SYSTEMD_SLEEP_ACTION=hibernate bash "$hook" pre hibernate
[[ $(<"$led") == 0 ]] || fail "pre hibernate clears a lit keyboard backlight" "LED reads $(<"$led")"
[[ $(<"$record") == 3 ]] || fail "pre hibernate records the level it cleared" "record reads $(<"$record")"
pass "pre hibernate clears the backlight and records its level"

SYSTEMD_SLEEP_ACTION=hibernate bash "$hook" post hibernate
[[ $(<"$led") == 3 ]] || fail "post hibernate restores the recorded level" "LED reads $(<"$led")"
[[ ! -e $record ]] || fail "post hibernate consumes the record it restored"
pass "post hibernate restores the level"

# The idle-restore plugin or a lock's own restore can light the keyboard first;
# a lit LED must win over the recorded level.
echo 2 >"$led"
SYSTEMD_SLEEP_ACTION=hibernate bash "$hook" pre hibernate
echo 1 >"$led"
SYSTEMD_SLEEP_ACTION=hibernate bash "$hook" post hibernate
[[ $(<"$led") == 1 ]] || fail "post hibernate leaves a LED something else lit alone" "LED reads $(<"$led")"
pass "post hibernate leaves an already lit LED alone"

# A keyboard that was already dark stays dark, and no stale level survives.
echo 0 >"$led"
SYSTEMD_SLEEP_ACTION=hibernate bash "$hook" pre hibernate
SYSTEMD_SLEEP_ACTION=hibernate bash "$hook" post hibernate
[[ $(<"$led") == 0 ]] || fail "a keyboard that was dark before hibernate stays dark" "LED reads $(<"$led")"
pass "a keyboard that was dark before hibernate stays dark"

# Only hibernate is touched. Suspend keeps the LED powered, so its level is
# never lost and the hook has nothing to do.
echo 3 >"$led"
SYSTEMD_SLEEP_ACTION=suspend bash "$hook" pre suspend
[[ $(<"$led") == 3 ]] || fail "suspend does not clear the keyboard backlight" "LED reads $(<"$led")"
[[ ! -e $record ]] || fail "suspend does not record a level"
pass "other sleep actions are left alone"
