#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
led_dir="$test_tmp/leds"
state_dir="$test_tmp/state"
mkdir -p "$stub_bin" "$led_dir/asus::kbd_backlight" "$state_dir" "$test_tmp/run"

# Remap the hardcoded sysfs glob so the script can discover a fake LED device.
script_copy="$test_tmp/omarchy-brightness-keyboard"
sed "s|/sys/class/leds/\*kbd_backlight\*|$led_dir/*kbd_backlight*|" \
  "$ROOT/bin/omarchy-brightness-keyboard" >"$script_copy"
chmod +x "$script_copy"

# Stub brightnessctl with save/restore semantics matching -s/-r.
cat >"$stub_bin/brightnessctl" <<'SH'
#!/bin/bash
set -euo pipefail

state_dir=${BRIGHTNESS_STATE_DIR:?}
current_file="$state_dir/current"
saved_file="$state_dir/saved"

device=""
save=0
restore=0
action=""
value=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s)
      save=1
      shift
      ;;
    -r)
      restore=1
      shift
      ;;
    -d)
      device="$2"
      shift 2
      ;;
    -sd)
      save=1
      device="$2"
      shift 2
      ;;
    -rd)
      restore=1
      device="$2"
      shift 2
      ;;
    get|max|set)
      action="$1"
      shift
      if [[ $action == set ]]; then
        value="${1:-}"
        shift || true
      fi
      ;;
    *)
      shift
      ;;
  esac
done

[[ -n $device ]] || exit 1
[[ -f $current_file ]] || printf '0\n' >"$current_file"

if (( restore )); then
  [[ -f $saved_file ]] || exit 1
  cp "$saved_file" "$current_file"
  exit 0
fi

case "$action" in
  get)
    cat "$current_file"
    ;;
  max)
    printf '100\n'
    ;;
  set)
    [[ -n $value ]] || exit 1
    if (( save )); then
      cp "$current_file" "$saved_file"
    fi
    printf '%s\n' "$value" >"$current_file"
    ;;
  *)
    exit 1
    ;;
esac
SH
chmod +x "$stub_bin/brightnessctl"

run_kb() {
  BRIGHTNESS_STATE_DIR="$state_dir" XDG_RUNTIME_DIR="$test_tmp/run" PATH="$stub_bin:$PATH" bash "$script_copy" "$@"
}

# --- off then restore keeps a non-zero saved value ----------------------------
printf '42\n' >"$state_dir/current"
rm -f "$state_dir/saved"

run_kb off
[[ $(cat "$state_dir/current") == 0 ]] || fail "off zeros the keyboard backlight"
[[ $(cat "$state_dir/saved") == 42 ]] || fail "off saves the prior non-zero brightness"

run_kb restore
[[ $(cat "$state_dir/current") == 42 ]] || fail "restore returns the saved non-zero brightness"
pass "off then restore keeps prior non-zero level"

# --- second off must not overwrite the saved restore value with 0 ------------
printf '77\n' >"$state_dir/current"
rm -f "$state_dir/saved"

run_kb off
[[ $(cat "$state_dir/current") == 0 ]] || fail "first off zeros the keyboard backlight"
[[ $(cat "$state_dir/saved") == 77 ]] || fail "first off saves the original non-zero brightness"

run_kb off
[[ $(cat "$state_dir/current") == 0 ]] || fail "second off leaves the backlight at zero"
[[ $(cat "$state_dir/saved") == 77 ]] || fail "second off overwrote the saved restore value with 0"

run_kb restore
[[ $(cat "$state_dir/current") == 77 ]] || fail "restore after double off lost the original non-zero"
pass "off twice then restore still restores the original non-zero level"

# --- a user-chosen 0 after an earlier restore stays off -----------------------
printf '50\n' >"$state_dir/current"
rm -f "$state_dir/saved"

run_kb off
run_kb restore
[[ $(cat "$state_dir/current") == 50 ]] || fail "restore returns the level saved by the first lock"

printf '0\n' >"$state_dir/current"
run_kb off
[[ $(cat "$state_dir/saved") == 0 ]] || fail "off from a user-chosen 0 saves 0"

run_kb restore
[[ $(cat "$state_dir/current") == 0 ]] || fail "restore turned a user-chosen 0 back on"
pass "a backlight turned off by the user stays off across a later lock"

# --- a 0 chosen with the brightness keys while locked survives the next off ---
printf '50\n' >"$state_dir/current"
rm -f "$state_dir/saved"

run_kb off
run_kb --no-osd up
run_kb --no-osd down
[[ $(cat "$state_dir/current") == 0 ]] || fail "up then down while blanked lands on 0"

run_kb off
[[ $(cat "$state_dir/saved") == 0 ]] || fail "off after a keyed 0 saves 0"

run_kb restore
[[ $(cat "$state_dir/current") == 0 ]] || fail "restore turned a keyed 0 back on"
pass "a 0 chosen with the brightness keys while locked stays off"
