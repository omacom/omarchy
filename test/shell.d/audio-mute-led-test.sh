#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
leds_path="$test_tmp/leds"
call_log="$test_tmp/calls"
runtime_dir="$test_tmp/runtime"
pactl_state="$test_tmp/pactl-state"
mkdir -p "$mock_bin" "$leds_path/platform::mute" "$leds_path/platform::micmute" "$runtime_dir" "$pactl_state"
touch "$leds_path/platform::mute/brightness" "$leds_path/platform::micmute/brightness"
printf 'no\n' >"$pactl_state/mute"
printf '50\n' >"$pactl_state/volume"

cat >"$mock_bin/pactl" <<'SH'
#!/bin/bash
case "$1" in
  get-sink-volume)
    printf 'Volume: front-left: 65536 / %s%% / -0.00 dB\n' "$(<"$PACTL_STATE/volume")"
    ;;
  get-sink-mute)
    printf 'Mute: %s\n' "$(<"$PACTL_STATE/mute")"
    ;;
  set-sink-mute)
    if [[ $3 == "toggle" ]]; then
      [[ $(<"$PACTL_STATE/mute") == "yes" ]] && echo no >"$PACTL_STATE/mute" || echo yes >"$PACTL_STATE/mute"
    else
      printf '%s\n' "$3" >"$PACTL_STATE/mute"
    fi
    ;;
  set-sink-volume)
    printf '%s\n' "${3%%%}" >"$PACTL_STATE/volume"
    ;;
esac
SH

cat >"$mock_bin/brightnessctl" <<'SH'
#!/bin/bash
printf 'brightnessctl %s\n' "$*" >>"$CALL_LOG"
SH

cat >"$mock_bin/omarchy-audio-output-sink" <<'SH'
#!/bin/bash
printf 'mock_sink\n'
SH

cat >"$mock_bin/omarchy-osd" <<'SH'
#!/bin/bash
printf 'omarchy-osd %s\n' "$*" >>"$CALL_LOG"
SH

cat >"$mock_bin/wpctl" <<'SH'
#!/bin/bash
case "$1" in
  set-mute)
    [[ $(<"$PACTL_STATE/source-mute") == "yes" ]] && echo no >"$PACTL_STATE/source-mute" || echo yes >"$PACTL_STATE/source-mute"
    ;;
  get-volume)
    [[ $(<"$PACTL_STATE/source-mute") == "yes" ]] && printf 'MUTED\n' || printf 'Vol: 1.00\n'
    ;;
esac
SH
printf 'no\n' >"$pactl_state/source-mute"

chmod +x "$mock_bin"/*

run() {
  CALL_LOG="$call_log" PACTL_STATE="$pactl_state" XDG_RUNTIME_DIR="$runtime_dir" \
    OMARCHY_LEDS_PATH="$leds_path" PATH="$mock_bin:$ROOT/bin:$PATH" "$@"
}

# The mute key and every volume step settle the indicator on the same helper the
# mic path uses, so the light tracks the software mute state.
reset_toggle() {
  printf '0\n' >"$runtime_dir/omarchy-audio-output-volume-mute-toggle.last"
  : >"$call_log"
}

reset_toggle
run "$ROOT/bin/omarchy-audio-output-volume" mute-toggle
grep -Fx 'brightnessctl --device=platform::mute set 1' "$call_log" >/dev/null || \
  fail "muting the output lights the mute indicator" "$(<"$call_log")"
pass "muting the output lights the mute indicator"

reset_toggle
run "$ROOT/bin/omarchy-audio-output-volume" mute-toggle
grep -Fx 'brightnessctl --device=platform::mute set 0' "$call_log" >/dev/null || \
  fail "unmuting the output clears the mute indicator" "$(<"$call_log")"
pass "unmuting the output clears the mute indicator"

reset_toggle
printf 'yes\n' >"$pactl_state/mute"
run "$ROOT/bin/omarchy-audio-output-volume" raise
grep -Fx 'brightnessctl --device=platform::mute set 0' "$call_log" >/dev/null || \
  fail "raising volume unmutes and clears the mute indicator" "$(<"$call_log")"
pass "raising volume unmutes and clears the mute indicator"

# A laptop without the LED node still has to mute, show the OSD, and exit clean.
printf 'no\n' >"$pactl_state/mute"
reset_toggle
run env OMARCHY_LEDS_PATH="$test_tmp/absent" "$ROOT/bin/omarchy-audio-output-volume" mute-toggle || \
  fail "a missing LED node does not fail the mute key"
[[ $(<"$pactl_state/mute") == "yes" ]] || fail "a missing LED node still mutes the sink"
grep -q 'omarchy-osd -i volume-muted' "$call_log" || fail "a missing LED node still shows the OSD" "$(<"$call_log")"
if grep -q 'brightnessctl' "$call_log"; then
  fail "a missing LED node writes no brightness" "$(<"$call_log")"
fi
pass "a missing LED node leaves the mute key working"

# The mic path keeps defaulting to its own LED, and the helper still accepts an
# explicit device.
: >"$call_log"
run "$ROOT/bin/omarchy-audio-input-mute"
grep -Fx 'brightnessctl --device=platform::micmute set 1' "$call_log" >/dev/null || \
  fail "the mic path still drives the mic-mute LED" "$(<"$call_log")"
pass "the mic path still drives the mic-mute LED"

: >"$call_log"
run "$ROOT/bin/omarchy-audio-input-mute"
grep -Fx 'brightnessctl --device=platform::micmute set 0' "$call_log" >/dev/null || \
  fail "unmuting the mic clears the mic-mute LED" "$(<"$call_log")"
pass "unmuting the mic clears the mic-mute LED"

: >"$call_log"
run "$ROOT/bin/omarchy-brightness-keyboard-mute" on "platform::mute"
grep -Fx 'brightnessctl --device=platform::mute set 1' "$call_log" >/dev/null || \
  fail "the helper drives an explicitly named LED" "$(<"$call_log")"
pass "the helper drives an explicitly named LED"

if run "$ROOT/bin/omarchy-brightness-keyboard-mute" sideways "platform::mute" 2>/dev/null; then
  fail "an unknown state is rejected"
fi
pass "an unknown state is rejected"
