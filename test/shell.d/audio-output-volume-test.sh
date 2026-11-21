#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_home=$(mktemp -d)
test_bin=$(mktemp -d)

cleanup() {
  rm -rf "$test_home" "$test_bin"
}
trap cleanup EXIT

export TEST_DATA="$test_home/data"
mkdir -p "$TEST_DATA"

# Mock omarchy-audio-output-sink
cat >"$test_bin/omarchy-audio-output-sink" <<'EOF'
#!/bin/bash
printf '%s\n' "${TEST_SINK:-alsa_output.mock}"
EOF

# Mock pactl
cat >"$test_bin/pactl" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_DATA/pactl.log"

case "$1 $2" in
  "get-sink-volume "*)
    vol=$(cat "$TEST_DATA/volume" 2>/dev/null || echo "50")
    printf 'Volume: front-left: 32768 / %s%% / -18.06 dB,   front-right: 32768 / %s%% / -18.06 dB\n' "$vol" "$vol"
    ;;
  "get-sink-mute "*)
    mute=$(cat "$TEST_DATA/mute" 2>/dev/null || echo "no")
    printf 'Mute: %s\n' "$mute"
    ;;
  "set-sink-volume "*)
    vol_arg="$3"
    vol_num="${vol_arg%\%}"
    printf '%s\n' "$vol_num" >"$TEST_DATA/volume"
    ;;
  "set-sink-mute "*)
    mute_arg="$3"
    if [[ $mute_arg == "toggle" ]]; then
      current=$(cat "$TEST_DATA/mute" 2>/dev/null || echo "no")
      if [[ $current == "yes" ]]; then
        printf 'no\n' >"$TEST_DATA/mute"
      else
        printf 'yes\n' >"$TEST_DATA/mute"
      fi
    elif [[ $mute_arg == "0" ]]; then
      printf 'no\n' >"$TEST_DATA/mute"
    else
      printf 'yes\n' >"$TEST_DATA/mute"
    fi
    ;;
  *)
    exit 0
    ;;
esac
EOF

# Mock omarchy-osd
cat >"$test_bin/omarchy-osd" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_DATA/osd.log"
EOF

chmod +x "$test_bin/omarchy-audio-output-sink" "$test_bin/pactl" "$test_bin/omarchy-osd"
export PATH="$test_bin:$PATH"

run_volume() {
  XDG_RUNTIME_DIR="$test_home/runtime" bash "$ROOT/bin/omarchy-audio-output-volume" "$@"
}

reset_state() {
  rm -f "$TEST_DATA/pactl.log" "$TEST_DATA/osd.log"
  printf '50\n' >"$TEST_DATA/volume"
  printf 'no\n' >"$TEST_DATA/mute"
}

# 1. Absolute percentage with %
reset_state
run_volume 60%
[[ $(tail -n 1 "$TEST_DATA/volume") == "60" ]] || fail "sets absolute percentage with %"
grep -q "set-sink-volume alsa_output.mock 60%" "$TEST_DATA/pactl.log" || fail "pactl called with 60%"
grep -q -- "-p 60" "$TEST_DATA/osd.log" || fail "osd called with 60"
pass "sets absolute percentage with %"

# 2. Absolute percentage without %
reset_state
run_volume 75
[[ $(tail -n 1 "$TEST_DATA/volume") == "75" ]] || fail "sets absolute percentage without %"
grep -q "set-sink-volume alsa_output.mock 75%" "$TEST_DATA/pactl.log" || fail "pactl called with 75%"
grep -q -- "-p 75" "$TEST_DATA/osd.log" || fail "osd called with 75"
pass "sets absolute percentage without %"

# 3. Leading zero absolute values (octal bug regression test)
reset_state
run_volume 08%
[[ $(tail -n 1 "$TEST_DATA/volume") == "8" ]] || fail "leading zero 08% does not evaluate to 100%"
grep -q "set-sink-volume alsa_output.mock 8%" "$TEST_DATA/pactl.log" || fail "pactl called with 8%"
grep -q -- "-p 8" "$TEST_DATA/osd.log" || fail "osd called with 8"
pass "normalizes leading zero 08% to decimal"

reset_state
run_volume 09
[[ $(tail -n 1 "$TEST_DATA/volume") == "9" ]] || fail "leading zero 09 does not evaluate to 100%"
grep -q "set-sink-volume alsa_output.mock 9%" "$TEST_DATA/pactl.log" || fail "pactl called with 9%"
pass "normalizes leading zero 09 to decimal"

reset_state
run_volume 00%
[[ $(tail -n 1 "$TEST_DATA/volume") == "0" ]] || fail "leading zero 00% sets 0"
grep -q "set-sink-volume alsa_output.mock 0%" "$TEST_DATA/pactl.log" || fail "pactl called with 0%"
grep -q -- "-i volume-muted -p 0" "$TEST_DATA/osd.log" || fail "osd shows muted icon for 0%"
pass "normalizes leading zero 00% to decimal 0 and muted icon"

# 4. Upper bound clamp for absolute volume
reset_state
run_volume 150%
[[ $(tail -n 1 "$TEST_DATA/volume") == "100" ]] || fail "clamps volume above 100% to 100%"
grep -q "set-sink-volume alsa_output.mock 100%" "$TEST_DATA/pactl.log" || fail "pactl called with 100%"
pass "clamps absolute volume exceeding 100% to 100%"

# 5. --no-osd flag suppresses OSD
reset_state
run_volume --no-osd 42%
[[ $(tail -n 1 "$TEST_DATA/volume") == "42" ]] || fail "sets volume with --no-osd"
[[ ! -f "$TEST_DATA/osd.log" ]] || fail "--no-osd suppresses omarchy-osd invocation"
pass "--no-osd flag suppresses OSD notification"

# 6. Relative raise and lower
reset_state
run_volume +5
[[ $(tail -n 1 "$TEST_DATA/volume") == "55" ]] || fail "+5 steps volume from 50 to 55"
run_volume -10
[[ $(tail -n 1 "$TEST_DATA/volume") == "45" ]] || fail "-10 steps volume from 55 to 45"
run_volume raise
[[ $(tail -n 1 "$TEST_DATA/volume") == "50" ]] || fail "raise steps volume by +5"
run_volume lower
[[ $(tail -n 1 "$TEST_DATA/volume") == "45" ]] || fail "lower steps volume by -5"
pass "relative raise, lower, +N, and -N adjust volume"

# 7. Relative leading zeros
reset_state
run_volume +08
[[ $(tail -n 1 "$TEST_DATA/volume") == "58" ]] || fail "+08 steps volume by decimal 8"
pass "relative step handles leading zeros"

# 8. Relative limits
reset_state
printf '98\n' >"$TEST_DATA/volume"
run_volume +5
[[ $(tail -n 1 "$TEST_DATA/volume") == "100" ]] || fail "+5 clamps at upper limit 100"

printf '3\n' >"$TEST_DATA/volume"
run_volume -5
[[ $(tail -n 1 "$TEST_DATA/volume") == "0" ]] || fail "-5 clamps at lower limit 0"
pass "relative step clamps at 0 and 100 limits"

# 9. Target specific sink with --sink
reset_state
run_volume --sink custom_headphones_sink 35%
[[ $(tail -n 1 "$TEST_DATA/volume") == "35" ]] || fail "--sink sets volume"
grep -q "set-sink-volume custom_headphones_sink 35%" "$TEST_DATA/pactl.log" || fail "pactl called with custom_headphones_sink"
pass "--sink sets volume on the specified sink instead of default"

reset_state
run_volume --no-osd --sink bluetooth_device 70%
[[ $(tail -n 1 "$TEST_DATA/volume") == "70" ]] || fail "--no-osd --sink sets volume"
grep -q "set-sink-volume bluetooth_device 70%" "$TEST_DATA/pactl.log" || fail "pactl called with bluetooth_device"
[[ ! -f "$TEST_DATA/osd.log" ]] || fail "--no-osd with --sink suppresses OSD"
pass "--no-osd and --sink work together"

# 10. --preserve-mute flag preserves sink mute state
reset_state
printf 'yes\n' >"$TEST_DATA/mute"
run_volume --preserve-mute 40%
[[ $(tail -n 1 "$TEST_DATA/volume") == "40" ]] || fail "--preserve-mute sets volume"
[[ $(cat "$TEST_DATA/mute") == "yes" ]] || fail "--preserve-mute keeps sink muted"
grep -q "set-sink-volume alsa_output.mock 40%" "$TEST_DATA/pactl.log" || fail "pactl called with 40%"
if grep -q "set-sink-mute alsa_output.mock 0" "$TEST_DATA/pactl.log"; then
  fail "--preserve-mute must not unmute sink"
fi
pass "--preserve-mute preserves sink mute state"

# 11. Error cases
if run_volume >/dev/null 2>&1; then
  fail "fails when called without arguments"
fi
if run_volume invalid_action >/dev/null 2>&1; then
  fail "fails when called with invalid action"
fi
if run_volume --sink >/dev/null 2>&1; then
  fail "fails when called with trailing --sink without argument"
fi
if run_volume --sink --no-osd 50% >/dev/null 2>&1; then
  fail "fails when called with flag as --sink value"
fi
pass "rejects missing arguments, invalid actions, and invalid --sink usage"
