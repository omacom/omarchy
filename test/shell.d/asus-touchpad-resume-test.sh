#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

hook="$ROOT/default/systemd/system-sleep/asus-touchpad-resume"
leaf="$ROOT/install/hardware/asus/fix-asus-um3406-touchpad-resume.sh"
migration="$ROOT/migrations/1790956367.sh"
test_tmp=$(mktemp -d -p /tmp)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls"
sleeps="$test_tmp/sleeps"
driver="$test_tmp/sys/i2c_hid_acpi"
device=i2c-ASUP1206:00
hook_copy="$test_tmp/asus-touchpad-resume"
sleep_dir="$test_tmp/system-sleep"
installed_hook="$sleep_dir/asus-touchpad-resume"
mock_omarchy="$test_tmp/omarchy"
empty_omarchy="$test_tmp/empty-omarchy"
mock_leaf="$mock_omarchy/install/hardware/asus/fix-asus-um3406-touchpad-resume.sh"

mkdir -p "$stub_bin" "$mock_omarchy/default/systemd/system-sleep" "${mock_leaf%/*}" \
  "$empty_omarchy/install/hardware/asus"
cp "$hook" "$mock_omarchy/default/systemd/system-sleep/asus-touchpad-resume"

[[ $(grep -Fxc 'driver=/sys/bus/i2c/drivers/i2c_hid_acpi' "$hook") == 1 ]] ||
  fail "touchpad hook fixes one literal i2c_hid_acpi driver path"
[[ $(grep -Fxc '  asus_touchpad_hook=/usr/lib/systemd/system-sleep/asus-touchpad-resume' "$leaf") == 1 ]] ||
  fail "touchpad setup fixes one literal system-sleep hook path"

sed "s|^driver=/sys/bus/i2c/drivers/i2c_hid_acpi$|driver=$driver|" "$hook" >"$hook_copy"
sed "s|asus_touchpad_hook=/usr/lib/systemd/system-sleep/asus-touchpad-resume|asus_touchpad_hook=$installed_hook|" \
  "$leaf" >"$mock_leaf"
cp "$mock_leaf" "$empty_omarchy/install/hardware/asus/"

# Each sleep is followed by one bind attempt. A bind target that is a directory
# rejects writes for any uid, so removing it after BIND_READY_AT sleeps models a
# probe that recovers on that attempt.
cat >"$stub_bin/sleep" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$SLEEPS"
if [[ -n ${BIND_READY_AT:-} ]] && (( $(wc -l <"$SLEEPS") == BIND_READY_AT )); then
  rmdir -- "$DRIVER/bind"
fi
SH

cat >"$stub_bin/omarchy-hw-match" <<'SH'
#!/bin/bash

[[ $1 == "${HW_MODEL:-}" ]]
SH

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

set -euo pipefail

printf 'sudo' >>"$CALLS"
printf '\t%s' "$@" >>"$CALLS"
printf '\n' >>"$CALLS"

case "$1" in
  mkdir | /usr/bin/mktemp | /usr/bin/mv | /usr/bin/rm)
    exec "$@"
    ;;
  /usr/bin/install)
    shift
    args=()
    while (($#)); do
      case "$1" in
        -o | -g)
          shift 2
          ;;
        *)
          args+=("$1")
          shift
          ;;
      esac
    done
    exec /usr/bin/install "${args[@]}"
    ;;
  *)
    printf 'unexpected sudo command: %s\n' "$*" >&2
    exit 97
    ;;
esac
SH
chmod +x "$stub_bin"/*

reset_sysfs() {
  rm -rf "$driver" "$sleeps"
  mkdir -p "$driver"
  : >"$sleeps"
}

run_hook() {
  SLEEPS="$sleeps" DRIVER="$driver" BIND_READY_AT="${BIND_READY_AT:-}" \
    PATH="$stub_bin:$PATH" bash "$hook_copy" "$@" 2>"$test_tmp/hook-stderr"
}

# Mirror run_logged, which sources install leaves under bash -eE.
run_leaf() {
  : >"$calls"
  CALLS="$calls" HW_MODEL="$1" OMARCHY_PATH="$2" PATH="$stub_bin:$PATH" \
    bash -eE -c 'source "$1"' bash "$2/install/hardware/asus/fix-asus-um3406-touchpad-resume.sh" \
    >/dev/null 2>"$test_tmp/leaf-stderr"
}

run_migration() {
  : >"$calls"
  CALLS="$calls" HW_MODEL="$1" OMARCHY_PATH="$mock_omarchy" PATH="$stub_bin:$PATH" \
    bash -euo pipefail "$migration" >/dev/null
}

stage_files() {
  find "$sleep_dir" -maxdepth 1 -name '.asus-touchpad-resume.omarchy.*' 2>/dev/null
}

reset_sysfs
touch "$driver/$device"
run_hook post suspend || fail "touchpad hook fails a clean rebind"
[[ $(<"$driver/unbind") == "$device" ]] || fail "touchpad hook unbinds only the ASUP1206 touchpad"
[[ $(<"$driver/bind") == "$device" ]] || fail "touchpad hook binds the ASUP1206 touchpad again"
[[ $(wc -l <"$sleeps") == 1 ]] || fail "touchpad hook waits once before a successful first bind"
pass "touchpad hook rebinds a bound touchpad after resume"

reset_sysfs
touch "$driver/$device"
mkdir "$driver/bind"
set +e
run_hook post suspend
status=$?
set -e
(( status == 1 )) || fail "touchpad hook reports success after every bind attempt fails"
[[ $(wc -l <"$sleeps") == 5 ]] ||
  fail "touchpad hook does not bound its bind attempts" "$(wc -l <"$sleeps") attempts"
grep -Fq "Could not rebind $device after 5 attempts" "$test_tmp/hook-stderr" ||
  fail "touchpad hook does not explain why the touchpad stays unbound" "$(<"$test_tmp/hook-stderr")"
pass "touchpad hook gives up after a bounded number of failed binds"

reset_sysfs
touch "$driver/$device"
mkdir "$driver/bind"
BIND_READY_AT=3 run_hook post suspend || fail "touchpad hook gives up before a later bind succeeds"
[[ $(<"$driver/bind") == "$device" ]] || fail "touchpad hook does not retry a failed bind"
[[ $(wc -l <"$sleeps") == 3 ]] || fail "touchpad hook keeps binding after a successful attempt"
pass "touchpad hook recovers when a later bind attempt succeeds"

reset_sysfs
touch "$driver/$device"
mkdir "$driver/unbind"
set +e
run_hook post suspend
status=$?
set -e
(( status == 1 )) || fail "touchpad hook reports success after unbind fails"
[[ ! -e $driver/bind ]] || fail "touchpad hook binds a touchpad it could not unbind"
grep -Fq "Could not unbind $device" "$test_tmp/hook-stderr" ||
  fail "touchpad hook does not explain an unbind failure" "$(<"$test_tmp/hook-stderr")"
pass "touchpad hook reports an unbind failure without touching bind"

reset_sysfs
run_hook post suspend || fail "touchpad hook fails when the touchpad is not bound"
[[ -z $(ls -A "$driver") && ! -s $sleeps ]] || fail "touchpad hook writes to sysfs without a bound touchpad"
touch "$driver/$device"
run_hook pre suspend || fail "touchpad hook fails before suspend"
[[ ! -e $driver/unbind && ! -e $driver/bind && ! -s $sleeps ]] ||
  fail "touchpad hook writes to sysfs before suspend"
pass "touchpad hook does nothing before suspend or without the touchpad"

run_leaf "Other" "$mock_omarchy" || fail "touchpad setup fails on other hardware"
[[ ! -e $sleep_dir && ! -s $calls ]] || fail "touchpad setup touches other hardware" "$(<"$calls")"
pass "touchpad setup skips hardware other than UM3406"

for run in first second; do
  run_leaf "UM3406" "$mock_omarchy" || fail "touchpad setup fails on its $run run" "$(<"$test_tmp/leaf-stderr")"
  cmp -s "$hook" "$installed_hook" || fail "touchpad setup installs different hook content on its $run run"
  [[ $(stat -c '%a' "$installed_hook") == 755 ]] || fail "touchpad setup leaves the hook non-executable on its $run run"
  grep -Eq $'^sudo\t/usr/bin/install\t-m\t0755\t-o\troot\t-g\troot\t-T\t' "$calls" ||
    fail "touchpad setup does not install a root-owned hook on its $run run" "$(<"$calls")"
  [[ -z $(stage_files) ]] || fail "touchpad setup leaves a staged hook behind on its $run run"
done
pass "touchpad setup installs a root-owned executable hook idempotently on UM3406"

rm -rf "$sleep_dir"
set +e
run_leaf "UM3406" "$empty_omarchy"
status=$?
set -e
(( status != 0 )) || fail "touchpad setup reports success without a hook source"
grep -Fq 'Could not install the asus-touchpad-resume system-sleep hook' "$test_tmp/leaf-stderr" ||
  fail "touchpad setup does not explain an install failure" "$(<"$test_tmp/leaf-stderr")"
[[ ! -e $installed_hook ]] || fail "touchpad setup publishes a hook without a source"
[[ -z $(stage_files) ]] || fail "touchpad setup leaves a staged hook behind after a failure"
pass "touchpad setup fails cleanly without a hook source"

rm -rf "$sleep_dir"
run_migration "Other"
[[ ! -e $sleep_dir && ! -s $calls ]] || fail "touchpad migration touches other hardware" "$(<"$calls")"
run_migration "UM3406"
cmp -s "$hook" "$installed_hook" || fail "touchpad migration does not install the hook on UM3406"
[[ $(stat -c '%a' "$installed_hook") == 755 ]] || fail "touchpad migration leaves the hook non-executable"
pass "touchpad migration installs the hook only on UM3406"
