#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

hooks_dir="$ROOT/default/systemd/system-sleep"

# systemd-sleep only runs executable files from system-sleep directories, so a
# hook shipped without the bit is dead on arrival wherever it is copied with -p.
for hook in keyboard-backlight force-igpu unmount-fuse; do
  [[ -x $hooks_dir/$hook ]] || fail "$hook is executable in the repo"
  bash -n "$hooks_dir/$hook" || fail "$hook parses"
  pass "$hook is an executable, parseable sleep hook"
done

# The installers must set the mode themselves rather than trust the source file.
for script in omarchy-hibernation-setup omarchy-toggle-hybrid-gpu; do
  if grep -q 'cp -p .*system-sleep' "$ROOT/bin/$script"; then
    fail "$script installs sleep hooks with an explicit mode, not cp -p"
  fi
  pass "$script installs sleep hooks with an explicit mode"
done

# keyboard-backlight zeroes only ASUS keyboard LEDs before hibernate, and puts
# them back on resume (#12657). It runs from a copy pointed at fake sysfs and
# /run trees, so the installed hook keeps its fixed paths.
leds="$tmp_dir/leds"
state="$tmp_dir/kbd-state"
mkdir -p "$leds/asus::kbd_backlight" "$leds/tpacpi::kbd_backlight"
echo 3 >"$leds/asus::kbd_backlight/brightness"
echo 2 >"$leds/tpacpi::kbd_backlight/brightness"
keyboard_hook_copy() {
  sed -e "s|^leds_dir=/sys/class/leds$|leds_dir=$leds|" -e "s|^state_dir=/run/omarchy-kbd-backlight$|state_dir=$2|" \
    "$hooks_dir/keyboard-backlight" >"$1"
  chmod +x "$1"
  grep -q "^leds_dir=$leds$" "$1" && grep -q "^state_dir=$2$" "$1" || fail "keyboard-backlight test copy points at the fake trees"
}
keyboard_hook_copy "$tmp_dir/keyboard-backlight" "$state"
run_keyboard_hook() {
  "$tmp_dir/keyboard-backlight" "$@"
}

run_keyboard_hook pre suspend
[[ $(<"$leds/asus::kbd_backlight/brightness") == 3 ]] || fail "keyboard-backlight leaves the LEDs alone on suspend"
pass "keyboard-backlight ignores suspend"

run_keyboard_hook pre hibernate
[[ $(<"$leds/asus::kbd_backlight/brightness") == 0 ]] || fail "keyboard-backlight turns the ASUS keyboard off before hibernate"
[[ $(<"$leds/tpacpi::kbd_backlight/brightness") == 2 ]] || fail "keyboard-backlight leaves non-ASUS keyboards alone"
pass "keyboard-backlight turns off only the ASUS keyboard before hibernate"

run_keyboard_hook post hibernate
[[ $(<"$leds/asus::kbd_backlight/brightness") == 3 ]] || fail "keyboard-backlight restores the ASUS keyboard on resume"
[[ ! -e $state ]] || fail "keyboard-backlight clears its saved state on resume"
pass "keyboard-backlight restores the ASUS keyboard on resume"

# suspend-then-hibernate passes the phase in SYSTEMD_SLEEP_ACTION.
SYSTEMD_SLEEP_ACTION=hibernate run_keyboard_hook pre suspend-then-hibernate
[[ $(<"$leds/asus::kbd_backlight/brightness") == 0 ]] || fail "keyboard-backlight handles the hibernate phase of suspend-then-hibernate"
SYSTEMD_SLEEP_ACTION=hibernate run_keyboard_hook post suspend-then-hibernate
[[ $(<"$leds/asus::kbd_backlight/brightness") == 3 ]] || fail "keyboard-backlight restores after suspend-then-hibernate"
pass "keyboard-backlight handles suspend-then-hibernate"

# Other ASUS LED names (asus-wmi's RGB keyboards on older kernels) are covered too.
mkdir -p "$leds/asus:rgb:kbd_backlight"
echo 1 >"$leds/asus:rgb:kbd_backlight/brightness"
run_keyboard_hook pre hibernate
[[ $(<"$leds/asus:rgb:kbd_backlight/brightness") == 0 ]] || fail "keyboard-backlight turns off asus:rgb:kbd_backlight"
run_keyboard_hook post hibernate
[[ $(<"$leds/asus:rgb:kbd_backlight/brightness") == 1 ]] || fail "keyboard-backlight restores asus:rgb:kbd_backlight"
rm -rf "$leds/asus:rgb:kbd_backlight"
pass "keyboard-backlight handles other ASUS keyboard LED names"

# If the level can't be saved the keyboard still goes dark (an ASUS controller
# can hang S4 otherwise), the failure is logged, and resume restores nothing.
touch "$tmp_dir/not-a-dir"
keyboard_hook_copy "$tmp_dir/keyboard-backlight-unsaved" "$tmp_dir/not-a-dir/state"
save_error=$("$tmp_dir/keyboard-backlight-unsaved" pre hibernate 2>&1 >/dev/null)
[[ $(<"$leds/asus::kbd_backlight/brightness") == 0 ]] || fail "keyboard-backlight turns the keyboard off even when it cannot save it"
[[ $save_error == *"could not save asus::kbd_backlight"* ]] || fail "keyboard-backlight logs a failed save" "$save_error"
echo 3 >"$leds/asus::kbd_backlight/brightness"
pass "keyboard-backlight still turns off and logs when it cannot save the level"

mkdir -p "$state"
: >"$state/asus::kbd_backlight"
run_keyboard_hook post hibernate || fail "keyboard-backlight resume with an empty saved level succeeds"
[[ $(<"$leds/asus::kbd_backlight/brightness") == 3 ]] || fail "keyboard-backlight never restores an empty saved level"
[[ ! -e $state ]] || fail "keyboard-backlight clears an empty saved level"
pass "keyboard-backlight ignores an empty saved level"

run_keyboard_hook post hibernate || fail "keyboard-backlight resume without saved state succeeds"
[[ $(<"$leds/asus::kbd_backlight/brightness") == 3 ]] || fail "keyboard-backlight resume without saved state changes nothing"
pass "keyboard-backlight resume without saved state is a no-op"

# The migration replaces hooks earlier releases installed. Installed hooks are
# root-owned, so it works through sudo; a stub records each privileged call and
# runs it as this user.
sleep_dir="$tmp_dir/system-sleep"
# The migration runs from a copy pointed at a fake system-sleep directory, so
# the installed one keeps its fixed path.
migration="$tmp_dir/migration.sh"
sed "s|^hook_dir=/usr/lib/systemd/system-sleep$|hook_dir=$sleep_dir|" "$ROOT/migrations/1790960338.sh" >"$migration"
grep -q "^hook_dir=$sleep_dir$" "$migration" || fail "migration test copy points at the fake system-sleep directory"
stub_bin="$tmp_dir/bin"
sudo_calls="$tmp_dir/sudo-calls"
mkdir -p "$stub_bin" "$sleep_dir"
# STUB_SUDO_FAIL makes the stub fail the matching privileged command.
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$SUDO_CALLS"
[[ -z ${STUB_SUDO_FAIL:-} || $1 != "$STUB_SUDO_FAIL" ]] || exit 1
"$@"
SH
chmod +x "$stub_bin/sudo"
migration_err="$tmp_dir/migration-stderr"
run_migration() {
  PATH="$stub_bin:$PATH" SUDO_CALLS="$sudo_calls" OMARCHY_PATH="${1:-$ROOT}" bash -euo pipefail "$migration" >/dev/null 2>"$migration_err"
}
no_stages() {
  [[ -z $(find "$sleep_dir" -name '.*.omarchy.*') ]]
}

# The hooks as earlier releases shipped them: keyboard-backlight zeroes any
# keyboard LED and never restores it, force-igpu has no timeouts and misses the
# hibernate phase of suspend-then-hibernate.
legacy_keyboard_backlight="$tmp_dir/legacy-keyboard-backlight"
cat >"$legacy_keyboard_backlight" <<'SH'
#!/bin/bash

# Turn off keyboard backlight before hibernate to prevent hang on power-off.
# The ASUS keyboard controller can block S4 shutdown if LEDs are active.

sleep_action=${SYSTEMD_SLEEP_ACTION:-$2}

if [[ $1 == "pre" && $sleep_action == "hibernate" ]]; then
  device=""
  for candidate in /sys/class/leds/*kbd_backlight*; do
    if [[ -e "$candidate" ]]; then
      device="$(basename "$candidate")"
      break
    fi
  done

  if [[ -n "$device" ]]; then
    brightnessctl -d "$device" set 0 >/dev/null 2>&1
  fi
fi
SH
[[ $(sha256sum "$legacy_keyboard_backlight" | cut -d' ' -f1) == 79215eed4da8036e25cd70ad09276823aad92d386a68c69d589d587c93b79c60 ]] ||
  fail "keyboard-backlight legacy fixture no longer matches the migration fingerprint"
legacy_force_igpu="$tmp_dir/legacy-force-igpu"
cat >"$legacy_force_igpu" <<'SH'
#!/bin/bash

# Use the Vfio to Integrated trick to turn off NVIDIA dgpu when in integrated mode
# without needing to restart the computer. This is needed because computers like the Asus G14
# will wake after suspend in Hybrid mode, even if the system was in Integrated mode before
# suspending.

case "$1" in
  pre)
    # Before hibernating, switch to Vfio so the nvidia driver is detached from the dGPU.
    # Without this, hibernate resume fails because the nvidia driver can't freeze a
    # powered-off dGPU (returns -EIO), which aborts the entire resume.
    if [[ $2 == "hibernate" ]]; then
      /usr/bin/supergfxctl -m Vfio
      sleep 1
    fi
    ;;
  post)
    # small delay so the device is fully re-enumerated
    sleep 4

    # force-bind dGPU to vfio (fully detached from nvidia)
    /usr/bin/supergfxctl -m Vfio
    sleep 1

    # then go back to Integrated, which powers it off again
    /usr/bin/supergfxctl -m Integrated
    ;;
esac
SH
[[ $(sha256sum "$legacy_force_igpu" | cut -d' ' -f1) == d604e7c4903829563e45fc52188fc5602c3f1bc66e247f0a2cc0a974ed6e57db ]] ||
  fail "force-igpu legacy fixture no longer matches the migration fingerprint"
install -m644 "$legacy_keyboard_backlight" "$sleep_dir/keyboard-backlight"
install -m644 "$legacy_force_igpu" "$sleep_dir/force-igpu"
install -m644 /dev/null "$sleep_dir/unrelated"

# A replacement that fails at the rename leaves the shipped hook in place and
# removes its stage, so a retry still recognizes and replaces it instead of
# treating a partial copy as custom.
if STUB_SUDO_FAIL=/usr/bin/mv run_migration; then
  fail "migration reports a failed hook replacement"
fi
[[ $(<"$migration_err") == *"Could not replace $sleep_dir/keyboard-backlight; rerun omarchy-migrate to retry"* ]] ||
  fail "migration explains a failed hook replacement" "$(<"$migration_err")"
grep -Eq -- "^/usr/bin/rm -f -- $sleep_dir/\.keyboard-backlight\.omarchy\.[[:alnum:]]{6}$" "$sudo_calls" ||
  fail "a failed replacement removes its stage through sudo"
cmp -s "$legacy_keyboard_backlight" "$sleep_dir/keyboard-backlight" || fail "a failed replacement leaves the shipped hook untouched"
no_stages || fail "a failed replacement leaves no staged copy behind"
pass "a failed hook replacement leaves the shipped hook for the retry"

# If the stage can't even be created (here a read-only hooks directory), the
# migration says so and fails instead of dying silently under set -e. Root
# ignores the directory mode, so this needs an ordinary user.
if (( EUID != 0 )); then
  chmod 555 "$sleep_dir"
  stage_status=0
  stage_error=$(PATH="$stub_bin:$PATH" SUDO_CALLS="$sudo_calls" OMARCHY_PATH="$ROOT" bash -euo pipefail "$migration" 2>&1 >/dev/null) ||
    stage_status=$?
  chmod 755 "$sleep_dir"
  (( stage_status != 0 )) || fail "migration reports a stage it could not create"
  [[ $stage_error == *"Could not stage a replacement for $sleep_dir/keyboard-backlight; rerun omarchy-migrate"* ]] ||
    fail "migration explains a stage it could not create" "$stage_error"
  cmp -s "$legacy_keyboard_backlight" "$sleep_dir/keyboard-backlight" || fail "a failed stage leaves the shipped hook untouched"
  pass "migration explains a replacement it could not stage"
fi

rm -f "$sudo_calls"
run_migration || fail "migration completes on shipped 644 hooks" "$(<"$migration_err")"
for hook in keyboard-backlight force-igpu; do
  cmp -s "$hooks_dir/$hook" "$sleep_dir/$hook" || fail "migration replaces a shipped $hook with the current one"
  [[ -x $sleep_dir/$hook ]] || fail "migration installs $hook executable"
  grep -Eq -- "^/usr/bin/install -m 0755 -T -- $hooks_dir/$hook $sleep_dir/\.$hook\.omarchy\.[[:alnum:]]{6}$" "$sudo_calls" ||
    fail "migration stages the $hook replacement through sudo"
  grep -Eq -- "^/usr/bin/mv -Tf -- $sleep_dir/\.$hook\.omarchy\.[[:alnum:]]{6} $sleep_dir/$hook$" "$sudo_calls" ||
    fail "migration renames the $hook replacement into place through sudo"
done
no_stages || fail "migration leaves no staged copy behind"
[[ ! -x $sleep_dir/unrelated ]] || fail "migration leaves other files alone"
pass "migration replaces shipped 644 keyboard-backlight and force-igpu hooks with the current, executable ones"

rm -f "$sudo_calls"
run_migration || fail "migration is idempotent" "$(<"$migration_err")"
[[ ! -e $sudo_calls ]] || fail "migration runs nothing privileged once the hooks are current"
pass "migration is a no-op the second time"

# The current hook installed without the bit was disabled by an administrator
# (installers have only ever installed it 0755), so its mode stays.
chmod 644 "$sleep_dir/force-igpu"
rm -f "$sudo_calls"
run_migration || fail "migration completes on a non-executable current hook" "$(<"$migration_err")"
[[ ! -x $sleep_dir/force-igpu ]] || fail "migration leaves a disabled current hook disabled"
[[ ! -e $sudo_calls ]] || fail "migration runs nothing privileged for a current hook"
pass "migration leaves a current hook's mode alone"

# A customized hook is the administrator's: its content and mode stay, even
# when they left it non-executable on purpose.
printf '#!/bin/bash\n# custom\n' >"$sleep_dir/keyboard-backlight"
chmod 644 "$sleep_dir/keyboard-backlight"
rm -f "$sudo_calls"
run_migration || fail "migration completes on a customized hook" "$(<"$migration_err")"
grep -q custom "$sleep_dir/keyboard-backlight" || fail "migration keeps a customized keyboard-backlight hook"
[[ ! -x $sleep_dir/keyboard-backlight ]] || fail "migration leaves a disabled customized hook disabled"
[[ ! -e $sudo_calls ]] || fail "migration runs nothing privileged for a customized hook"
pass "migration leaves a customized keyboard-backlight hook alone"

# The legacy fixtures above are among the shipped versions it recognizes.
grep -q "$(sha256sum "$legacy_keyboard_backlight" | cut -d' ' -f1)" "$migration" || fail "migration lists the legacy keyboard-backlight fixture"
grep -q "$(sha256sum "$legacy_force_igpu" | cut -d' ' -f1)" "$migration" || fail "migration lists the legacy force-igpu fixture"
pass "migration recognizes the legacy keyboard-backlight and force-igpu"

rm -rf "$sleep_dir"
run_migration || fail "migration completes with no hooks installed" "$(<"$migration_err")"
pass "migration completes with no hooks installed"
