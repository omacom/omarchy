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
