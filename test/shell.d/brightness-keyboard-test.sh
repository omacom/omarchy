#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin" "$test_tmp/leds/dell::kbd_backlight" "$test_tmp/runtime"
export BRIGHTNESS_FIXTURE="$test_tmp"
export HOME="$test_tmp/home"
export XDG_STATE_HOME="$test_tmp/home/.local/state"
export OMARCHY_LEDS_PATH="$test_tmp/leds"
export XDG_RUNTIME_DIR="$test_tmp/runtime"
export PATH="$test_tmp/bin:$PATH"
state_file="$XDG_STATE_HOME/omarchy/omarchy-keyboard-backlight-dell::kbd_backlight"

cat >"$test_tmp/bin/brightnessctl" <<'SH'
#!/bin/bash
set -euo pipefail
printf '%s\n' "$*" >>"$BRIGHTNESS_FIXTURE/calls"
case "$1" in
-d) shift 2 ;;
-sd)
  cp "$BRIGHTNESS_FIXTURE/brightness" "$BRIGHTNESS_FIXTURE/legacy-saved"
  shift 2
  ;;
-rd)
  [[ ! -f $BRIGHTNESS_FIXTURE/legacy-saved ]] || cp "$BRIGHTNESS_FIXTURE/legacy-saved" "$BRIGHTNESS_FIXTURE/brightness"
  exit 0
  ;;
*) exit 1 ;;
esac
case "$1" in
get)
  [[ ${FAIL_GET:-0} != "1" ]] || exit 1
  cat "$BRIGHTNESS_FIXTURE/brightness"
  ;;
max) cat "$BRIGHTNESS_FIXTURE/max" ;;
set)
  [[ ${FAIL_SET:-0} != "1" ]] || exit 1
  if [[ ${BLOCK_SET:-0} == "1" ]]; then
    : >"$BRIGHTNESS_FIXTURE/set-entered"
    read -r _ <"$BRIGHTNESS_FIXTURE/release-set"
  fi
  printf '%s\n' "$2" >"$BRIGHTNESS_FIXTURE/brightness"
  ;;
*) exit 1 ;;
esac
SH

cat >"$test_tmp/bin/omarchy-osd" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$BRIGHTNESS_FIXTURE/osd"
SH
chmod +x "$test_tmp/bin/brightnessctl" "$test_tmp/bin/omarchy-osd"

cat >"$test_tmp/bin/flock" <<'SH'
#!/bin/bash
if [[ ${PROBE_LOCK:-0} == "1" ]]; then
  if [[ ! -e $BRIGHTNESS_FIXTURE/first-lock ]]; then
    : >"$BRIGHTNESS_FIXTURE/first-lock"
  elif [[ ! -e $BRIGHTNESS_FIXTURE/lock-probed ]]; then
    if /usr/bin/flock -n "$1"; then
      : >"$BRIGHTNESS_FIXTURE/lock-free"
      /usr/bin/flock -u "$1"
    else
      : >"$BRIGHTNESS_FIXTURE/lock-busy"
    fi
    : >"$BRIGHTNESS_FIXTURE/lock-probed"
  fi
fi
exec /usr/bin/flock "$@"
SH
chmod +x "$test_tmp/bin/flock"

run_keyboard() {
  "$ROOT/bin/omarchy-brightness-keyboard" --no-osd "$@"
}

reset_fixture() {
  rm -f "$state_file" "$state_file.tmp" "$test_tmp/legacy-saved"
  printf '%s\n' "${1:-2}" >"$test_tmp/brightness"
  printf '2\n' >"$test_tmp/max"
  : >"$test_tmp/calls"
  : >"$test_tmp/osd"
}

assert_brightness() {
  [[ $(<"$test_tmp/brightness") == "$1" ]] || fail "$2" "brightness: $(<"$test_tmp/brightness"), expected: $1"
  pass "$2"
}

# A manually selected zero must replace any earlier non-zero restore state.
reset_fixture 2
run_keyboard off
run_keyboard restore
run_keyboard down
run_keyboard down
run_keyboard off
run_keyboard restore
assert_brightness 0 "manual off survives lock and restore after an earlier lit lock"

# Firmware timeout before the first lock must not require an earlier snapshot.
reset_fixture 0
run_keyboard up
printf '0\n' >"$test_tmp/brightness"
: >"$test_tmp/calls"
run_keyboard off
run_keyboard off
if grep -Eq -- 'set 0$' "$test_tmp/calls"; then
  fail "blanking an already timed-out keyboard must not send set 0"
fi
run_keyboard restore
assert_brightness 1 "a manual level survives timeout before the first lock"

# Repeated blanks and wakes must retain the last intentional level.
run_keyboard off
run_keyboard off
run_keyboard restore
run_keyboard restore
assert_brightness 1 "repeated blank and restore retain the selected level"

reset_fixture 2
run_keyboard cycle
run_keyboard off
run_keyboard restore
assert_brightness 0 "cycle to zero stays off after lock and restore"

reset_fixture 0
run_keyboard up
run_keyboard up
printf '0\n' >"$test_tmp/brightness"
run_keyboard off
run_keyboard restore
assert_brightness 2 "the most recent successful manual level is restored"

# Without a recorded selection, only a positive reading can seed the state.
reset_fixture 2
run_keyboard off
run_keyboard off
run_keyboard restore
assert_brightness 2 "a lit first lock seeds the initial restore level"

reset_fixture 0
run_keyboard off
run_keyboard restore
assert_brightness 0 "an unknown initial zero is not guessed to be a timeout"
[[ ! -e $state_file ]] || fail "an unknown zero must not be saved as a user selection"
pass "an unknown zero leaves user state unset"

reset_fixture 0
run_keyboard up
if FAIL_SET=1 run_keyboard up; then
  fail "a failed manual change must report failure"
fi
printf '0\n' >"$test_tmp/brightness"
run_keyboard restore
assert_brightness 1 "a failed manual change preserves the last successful level"

run_keyboard off
if FAIL_SET=1 run_keyboard restore; then
  fail "a failed restore must report failure"
fi
run_keyboard restore
assert_brightness 1 "a failed restore can be retried without losing state"

if FAIL_GET=1 run_keyboard off; then
  fail "a failed brightness read must report failure"
fi
assert_brightness 1 "a failed read does not blank the keyboard"

reset_fixture 2
mkdir "$state_file"
if run_keyboard off >/dev/null 2>&1; then
  fail "a failed initial state save must report failure"
fi
assert_brightness 2 "a failed initial state save does not blank the keyboard"
rmdir "$state_file"

# Preserve ordinary adjustment behavior on devices with many levels.
reset_fixture 0
printf '512\n' >"$test_tmp/max"
"$ROOT/bin/omarchy-brightness-keyboard" up
assert_brightness 51 "many-level keyboards retain their ten-percent step"
grep -Fqx -- '-i keyboard -p 9' "$test_tmp/osd" || fail "manual changes still show the brightness OSD"
pass "manual changes still show the brightness OSD"

reset_fixture 2
run_keyboard cycle
: >"$test_tmp/calls"
run_keyboard restore
! grep -Eq -- 'set 0$' "$test_tmp/calls" || fail "restoring an already dark manual selection avoids redundant zero writes"
pass "manual zero restore does not disable Dell hardware wake triggers"

reset_fixture 0
env -u XDG_RUNTIME_DIR HOME="$test_tmp/home" "$ROOT/bin/omarchy-brightness-keyboard" --no-osd up
assert_brightness 1 "keyboard adjustment works without a runtime directory"
[[ -f $test_tmp/home/.local/state/omarchy/omarchy-keyboard-backlight-dell::kbd_backlight ]] || fail "TTY adjustment records a private user preference"

printf '0\n' >"$test_tmp/brightness"
run_keyboard off
run_keyboard restore
assert_brightness 1 "a TTY choice survives firmware timeout before the compositor's first lock"

reset_fixture 0
run_keyboard up
cat >"$test_tmp/bin/mv" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$test_tmp/bin/mv"
if run_keyboard up >"$test_tmp/out" 2>"$test_tmp/errors"; then fail "state rename failure reaches the caller"; fi
assert_brightness 1 "a failed save rolls hardware back to the previous successful adjustment"
[[ $(<"$state_file") == "1" ]] || fail "a failed save keeps the previous preference"
rm "$test_tmp/bin/mv"
pass "hardware and saved brightness remain consistent after a state save failure"

reset_fixture 0
cat >"$test_tmp/bin/mv" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$test_tmp/bin/mv"
if run_keyboard up >"$test_tmp/out" 2>"$test_tmp/errors"; then fail "state save failure reports failure after a firmware timeout"; fi
! grep -Eq -- 'set 0$' "$test_tmp/calls" || fail "failed-save rollback does not disable hardware wake triggers"
assert_brightness 1 "failed save leaves the adjusted light on instead of disabling wake triggers"
rm "$test_tmp/bin/mv"

reset_fixture 2
printf '1\n' >"$state_file"
run_keyboard off
run_keyboard restore
assert_brightness 2 "a new session restores the lit level it had before locking"

# A broken runtime lock must not stop commands when persistent state is newer.
reset_fixture 0
runtime_state="$XDG_RUNTIME_DIR/omarchy-keyboard-backlight-dell::kbd_backlight"
printf '1\n' >"$state_file"
printf '2\n' >"$runtime_state"
touch -d '2 minutes ago' "$runtime_state"
rm -f "$runtime_state.lock"
mkdir "$runtime_state.lock"
run_keyboard restore
assert_brightness 1 "persistent state still restores when the runtime lock is unavailable"
run_keyboard up
[[ $(<"$state_file") == "2" ]] || fail "a runtime lock failure does not block persistent state saves"

# A newer runtime zero may be an intentional manual off. Do not restore an
# older positive level or save a lock-time level over it without its lock.
reset_fixture 0
printf '1\n' >"$state_file"
touch -d '2 minutes ago' "$state_file"
printf '0\n' >"$runtime_state"
touch -d '1 minute ago' "$runtime_state"
if run_keyboard restore 2>"$test_tmp/errors"; then
  fail "restore must not use older persistent state when runtime state cannot be locked"
fi
assert_brightness 0 "an inaccessible newer manual off stays off on restore"
grep -q 'Could not lock a newer' "$test_tmp/errors" || fail "the skipped restore explains why"
printf '2\n' >"$test_tmp/brightness"
if run_keyboard off 2>"$test_tmp/errors"; then
  fail "lock-time blanking must not replace a newer manual off without its lock"
fi
assert_brightness 2 "lock-time blanking does not replace an inaccessible newer choice"
[[ $(<"$state_file") == "1" ]] || fail "lock-time blanking does not overwrite older persistent state"
run_keyboard cycle
[[ $(<"$state_file") == "0" ]] || fail "a new manual choice can replace the inaccessible runtime state"
run_keyboard restore
assert_brightness 0 "a new persistent manual choice remains usable without the runtime lock"
rmdir "$runtime_state.lock"
rm "$runtime_state"

# An existing lock still works through flock when it is no longer writable.
reset_fixture 0
printf '1\n' >"$state_file"
touch -d '2 minutes ago' "$state_file"
printf '2\n' >"$runtime_state"
touch -d '1 minute ago' "$runtime_state"
: >"$runtime_state.lock"
chmod 400 "$runtime_state.lock"
if (( EUID == 0 )); then
  skip "read-only runtime lock needs an unprivileged user to deny writes"
else
  if (: >"$runtime_state.lock") 2>/dev/null; then
    fail "the read-only runtime lock fixture still allows a write-open"
  fi
  run_keyboard restore
  assert_brightness 2 "a read-only runtime lock still restores the newer choice"
  run_keyboard off
  run_keyboard restore
  assert_brightness 2 "a read-only runtime lock keeps lock and wake working"
fi
chmod 600 "$runtime_state.lock"
rm "$runtime_state" "$runtime_state.lock"

if (( EUID == 0 )); then
  echo "skip - root bypasses directory write permissions"
else
  reset_fixture 0
  chmod 500 "${state_file%/*}"
  run_keyboard up
  run_keyboard off
  run_keyboard restore
  assert_brightness 1 "a writable runtime directory keeps brightness working when persistent state is read-only"
  runtime_state="$XDG_RUNTIME_DIR/omarchy-keyboard-backlight-dell::kbd_backlight"
  [[ -f $runtime_state ]] || fail "runtime fallback records its working restore level"
  chmod 700 "${state_file%/*}"
  rm "$runtime_state"

  reset_fixture 2
  printf '1\n' >"$state_file"
  chmod 500 "${state_file%/*}"
  run_keyboard off
  chmod 700 "${state_file%/*}"
  run_keyboard restore
  assert_brightness 2 "restore keeps the fallback preference when persistent storage becomes writable"

  # A TTY has no runtime directory, so its later manual selection must replace
  # the older compositor fallback once persistent storage recovers.
  printf '0\n' >"$test_tmp/brightness"
  env -u XDG_RUNTIME_DIR "$ROOT/bin/omarchy-brightness-keyboard" --no-osd down
  run_keyboard restore
  assert_brightness 0 "a later TTY selection overrides the older runtime fallback"
  rm "$runtime_state"

  reset_fixture 0
  mkfifo "$test_tmp/release-set"
  chmod 500 "${state_file%/*}"
  BLOCK_SET=1 run_keyboard up >"$test_tmp/first.out" 2>"$test_tmp/first.err" &
  first_pid=$!
  for ((attempt = 0; attempt < 100; attempt++)); do
    [[ ! -e $test_tmp/set-entered ]] || break
    sleep 0.01
  done
  [[ -e $test_tmp/set-entered ]] || fail "the runtime fallback adjustment did not reach hardware"
  chmod 700 "${state_file%/*}"
  PROBE_LOCK=1 run_keyboard down >"$test_tmp/second.out" 2>"$test_tmp/second.err" &
  second_pid=$!
  for ((attempt = 0; attempt < 500; attempt++)); do
    [[ ! -e $test_tmp/lock-probed ]] || break
    sleep 0.01
  done
  [[ -e $test_tmp/lock-probed ]] || fail "the recovered command did not reach its lock"
  [[ -e $test_tmp/lock-busy && ! -e $test_tmp/lock-free ]] ||
    fail "the recovered command did not find the fallback adjustment's lock held"
  printf '\n' >"$test_tmp/release-set"
  wait "$first_pid" || fail "the fallback adjustment failed"
  wait "$second_pid" || fail "the adjustment after recovery failed"
  assert_brightness 0 "recovery serializes a runtime adjustment with the next persistent adjustment"
  rm "$test_tmp/release-set" "$test_tmp/set-entered" "$test_tmp/first-lock" "$test_tmp/lock-probed" \
    "$test_tmp/lock-busy" "$runtime_state"
fi

reset_fixture 2
printf '1\n' >"$state_file"
cat >"$test_tmp/bin/mv" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$test_tmp/bin/mv"
if run_keyboard off 2>"$test_tmp/errors"; then
  fail "a failed lock-time save must report failure when the older level differs"
fi
assert_brightness 2 "a failed lock-time save does not discard the lit level"
grep -q 'leaving the light on' "$test_tmp/errors" || fail "a failed lock-time save explains why the light remains on"
run_keyboard restore
assert_brightness 1 "the earlier saved level remains usable after a failed lock-time save"

printf '2\n' >"$state_file"
printf '2\n' >"$test_tmp/brightness"
run_keyboard off 2>"$test_tmp/errors"
assert_brightness 0 "a failed save can still blank when the earlier level matches"
run_keyboard restore
assert_brightness 2 "a matching earlier level restores after a failed save"

rm "$state_file"
ln -s /dev/null "$state_file"
if run_keyboard off 2>"$test_tmp/errors"; then
  fail "an unreadable previous level must not permit blanking after a failed save"
fi
assert_brightness 2 "a failed save with unreadable state keeps the light on"
rm "$state_file"
rm "$test_tmp/bin/mv"
