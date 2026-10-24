#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
runtime_dir="$test_tmp/run"
mkdir -p "$mock_bin" "$runtime_dir" "$test_tmp/leds/mock::kbd_backlight" "$test_tmp/state"

# A brightnessctl stub with just enough of its save/restore state to exercise
# the off/restore path: -s saves the current level, -r restores it.
cat >"$mock_bin/brightnessctl" <<'SH'
#!/bin/bash
cur_file="$STATE_DIR/cur"
saved_file="$STATE_DIR/saved"
save=0 restore=0 action="" value=""
for arg in "$@"; do
  case "$arg" in
    -s | -sd | -ds) save=1 ;;
    -r | -rd | -dr) restore=1 ;;
    get | max | set) action="$arg" ;;
    [0-9]*) value="$arg" ;;
  esac
done
cur="$(cat "$cur_file" 2>/dev/null || echo 0)"
case "$action" in
  max) echo "${MAXV:-255}" ;;
  get) echo "$cur" ;;
  set)
    (( save )) && printf '%s' "$cur" >"$saved_file"
    printf '%s' "$value" >"$cur_file"
    ;;
esac
if (( restore )); then
  [[ -n ${FAIL:-} ]] && exit 1
  cp "$saved_file" "$cur_file"
fi
exit 0
SH

cat >"$mock_bin/omarchy-osd" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$mock_bin"/*

# A copy of the command that finds the backlight under a fixture, not /sys.
kbd="$test_tmp/omarchy-brightness-keyboard"
sed "s|/sys/class/leds|$test_tmp/leds|g" "$ROOT/bin/omarchy-brightness-keyboard" >"$kbd"
chmod +x "$kbd"
grep -qF "$test_tmp/leds" "$kbd" || fail "omarchy-brightness-keyboard reads the LED class from the fixture"

off_marker="$runtime_dir/omarchy-keyboard-backlight-off"

run_kbd() {
  STATE_DIR="$test_tmp/state" MAXV=255 XDG_RUNTIME_DIR="$runtime_dir" \
    PATH="$mock_bin:$ROOT/bin:$PATH" "$kbd" --no-osd "$@"
}

# The light is on at 200 and nothing has turned it off yet.
printf '200' >"$test_tmp/state/cur"
rm -f "$off_marker"

run_kbd off
[[ $(cat "$test_tmp/state/cur") == 0 ]] || fail "off turns the keyboard backlight off"
[[ $(cat "$test_tmp/state/saved") == 200 ]] || fail "off saves the level it turned down from"
[[ -e $off_marker ]] || fail "off marks that it is in effect"
pass "off saves the current level and turns the backlight off"

run_kbd off
[[ $(cat "$test_tmp/state/saved") == 200 ]] ||
  fail "a second off keeps the saved level, not 0" "saved: $(cat "$test_tmp/state/saved")"
pass "a second off before a restore does not overwrite the saved level"

run_kbd restore
[[ $(cat "$test_tmp/state/cur") == 200 ]] ||
  fail "restore returns the pre-off level" "cur: $(cat "$test_tmp/state/cur")"
[[ ! -e $off_marker ]] || fail "restore clears the off marker"
pass "restore returns the backlight to the level before it was turned off"

# A manual change while off is in effect clears the marker, so the next off
# records the level the user left it at (even 0) instead of skipping the save.
printf '200' >"$test_tmp/state/cur"
rm -f "$off_marker"
run_kbd off
[[ -e $off_marker ]] || fail "off marks that it is in effect"

run_kbd up
[[ ! -e $off_marker ]] || fail "a manual brightness change clears the off marker"

# The user then dims to zero by hand; a stale saved level must not survive it.
printf '0' >"$test_tmp/state/cur"
printf '99' >"$test_tmp/state/saved"
run_kbd off
[[ $(cat "$test_tmp/state/saved") == 0 ]] ||
  fail "off after a manual change saves the level the user left, not a stale value" \
    "saved: $(cat "$test_tmp/state/saved")"
run_kbd restore
[[ $(cat "$test_tmp/state/cur") == 0 ]] ||
  fail "restore honours a user-chosen zero instead of forcing the light on" "cur: $(cat "$test_tmp/state/cur")"
pass "a manual change clears the marker so a user-chosen zero is saved and restored"

# A restore that fails must keep the off marker, so the next off does not treat
# the still-dark keyboard as a fresh level and save 0 over the real one.
printf '123' >"$test_tmp/state/cur"
rm -f "$off_marker"
run_kbd off
FAIL=1 STATE_DIR="$test_tmp/state" MAXV=255 XDG_RUNTIME_DIR="$runtime_dir" \
  PATH="$mock_bin:$ROOT/bin:$PATH" "$kbd" --no-osd restore && fail "a failed restore exits non-zero"
[[ -e $off_marker ]] || fail "a failed restore keeps the off marker"
run_kbd off
[[ $(cat "$test_tmp/state/saved") == 123 ]] ||
  fail "off after a failed restore keeps the saved level" "saved: $(cat "$test_tmp/state/saved")"
run_kbd restore
[[ $(cat "$test_tmp/state/cur") == 123 ]] ||
  fail "a later restore still returns the real level" "cur: $(cat "$test_tmp/state/cur")"
pass "a failed restore does not drop the saved level"
