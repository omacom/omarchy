#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

detector="$ROOT/bin/omarchy-hw-asus-gu605cx-alc285"
leaf="install/hardware/asus/fix-gu605cx-audio-pop.sh"
migration="migrations/1788118369.sh"

grep -q 'run_logged .*hardware/asus/fix-gu605cx-audio-pop.sh' "$ROOT/install/hardware/all.sh" ||
  fail "hardware setup includes the GU605CX audio workaround"
pass "hardware setup includes the GU605CX audio workaround"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
dmi="$test_tmp/sys/dmi"
hda="$test_tmp/sys/hda"
audio_config="$test_tmp/etc/modprobe.d/omarchy-asus-gu605cx-audio.conf"
call_log="$test_tmp/calls.log"
mkdir -p "$test_tmp/bin" "$test_tmp/$(dirname "$leaf")" "$test_tmp/migrations"

# Rewrite only scratch copies; no test destination override enters production.
for script in "$leaf" "$migration"; do
  sed "s|/etc/modprobe.d|$test_tmp/etc/modprobe.d|g" \
    "$ROOT/$script" >"$test_tmp/$script"
  grep -Eq '(^|[[:space:]"(=])/etc/' "$test_tmp/$script" &&
    fail "test copies contain only the scratch configuration destination"
done

cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$CALL_LOG"
# Only execute the inspected privileged block after its destinations are rewritten.
if (( $# != 2 )) || [[ $1 != "bash" || $2 != "-eu" ]]; then
  printf 'forbidden sudo command\n' >>"$CALL_LOG"
  exit 98
fi
script=$(/usr/bin/cat)
destinations=${script//"$TEST_CONFIG_DIR"/SCRATCH}
if [[ $destinations == *"/etc/"* || $destinations == *"/sys/"* || $destinations == *"/proc/"* || $destinations == *"/dev/"* ]]; then
  printf 'forbidden host path\n' >>"$CALL_LOG"
  exit 98
fi
if (( TEST_SUDO_STATUS != 0 )); then
  exit "$TEST_SUDO_STATUS"
fi
exec /usr/bin/bash -eu <<<"$script"
SH

cat >"$test_tmp/bin/cat" <<'SH'
#!/bin/bash
if (( TEST_WRITE_STATUS != 0 )); then
  # Simulate a write that leaves some output before reporting failure.
  /usr/bin/head -n 1
  exit "$TEST_WRITE_STATUS"
fi
exec /usr/bin/cat "$@"
SH

cat >"$test_tmp/bin/omarchy-state" <<'SH'
#!/bin/bash
printf 'state %s\n' "$*" >>"$CALL_LOG"
[[ $* == "set reboot-required" ]]
SH

cat >"$test_tmp/bin/forbidden" <<'SH'
#!/bin/bash
printf 'forbidden %s %s\n' "${0##*/}" "$*" >>"$CALL_LOG"
exit 98
SH
chmod +x "$test_tmp/bin"/*
for command in systemctl modprobe rmmod tee pkexec reboot shutdown; do
  ln -s forbidden "$test_tmp/bin/$command"
done

reset_hardware() {
  rm -rf "$test_tmp/sys"
  mkdir -p "$dmi" "$hda/hdaudioC0D0" "$hda/hdaudioC1D0"
  printf 'ASUSTeK COMPUTER INC.\n' >"$dmi/board_vendor"
  printf 'GU605CX\n' >"$dmi/board_name"
  printf '0x8086281d\n' >"$hda/hdaudioC0D0/vendor_id"
  printf '0x80860101\n' >"$hda/hdaudioC0D0/subsystem_id"
  printf '0x10ec0285\n' >"$hda/hdaudioC1D0/vendor_id"
  printf '0x10431034\n' >"$hda/hdaudioC1D0/subsystem_id"
}

run_detector() {
  OMARCHY_DMI_PATH="$dmi" OMARCHY_HDA_DEVICES_PATH="$hda" bash "$detector"
}

reset_hardware
run_detector || fail "the detector finds the matching codec after an unrelated controller"
pass "the detector finds the matching codec after an unrelated controller"

for value in "Other vendor" "ASUSTeK COMPUTER INC. extra"; do
  printf '%s\n' "$value" >"$dmi/board_vendor"
  run_detector && fail "the detector requires the exact ASUS board vendor"
done
pass "the detector requires the exact ASUS board vendor"

reset_hardware
for value in GU605CW GU605CX_EXTRA; do
  printf '%s\n' "$value" >"$dmi/board_name"
  run_detector && fail "the detector requires the exact GU605CX board name"
done
pass "the detector requires the exact GU605CX board name"

for attribute in vendor_id subsystem_id; do
  reset_hardware
  expected=$(cat "$hda/hdaudioC1D0/$attribute")
  printf '0x00000000\n' >"$hda/hdaudioC1D0/$attribute"
  run_detector && fail "the detector rejects a different codec $attribute"
  printf '%s0\n' "$expected" >"$hda/hdaudioC1D0/$attribute"
  run_detector && fail "the detector rejects a longer codec $attribute"
  pass "the detector requires an exact codec $attribute"
done

reset_hardware
printf '0x10431034\n' >"$hda/hdaudioC0D0/subsystem_id"
printf '0x00000000\n' >"$hda/hdaudioC1D0/subsystem_id"
run_detector && fail "the codec and subsystem IDs must belong to the same device"
pass "the codec and subsystem IDs must belong to the same device"

for missing in dmi dmi/board_vendor dmi/board_name hda hda/hdaudioC1D0/vendor_id hda/hdaudioC1D0/subsystem_id; do
  reset_hardware
  rm -rf "$test_tmp/sys/$missing"
  run_detector && fail "the detector fails closed with missing $missing"
done
pass "the detector fails closed with missing sysfs directories or attributes"

reset_hardware
rm -rf "$hda"/*
run_detector && fail "the detector fails closed with no HDA devices"
pass "the detector fails closed with no HDA devices"

sysfs_snapshot() {
  sha256sum "$dmi"/* "$hda"/*/*
}

run_script() {
  local script="$1" status before
  : >"$call_log"
  before=$(sysfs_snapshot)
  if PATH="$test_tmp/bin:$ROOT/bin:/usr/bin:/bin" \
    OMARCHY_PATH="$test_tmp" \
    OMARCHY_DMI_PATH="$dmi" \
    OMARCHY_HDA_DEVICES_PATH="$hda" \
    CALL_LOG="$call_log" \
    TEST_CONFIG_DIR="$test_tmp/etc/modprobe.d" \
    TEST_SUDO_STATUS="${2:-0}" \
    TEST_WRITE_STATUS="${3:-0}" \
    bash -euo pipefail -c 'source "$1"' bash "$test_tmp/$script" >"$test_tmp/output" 2>&1; then
    status=0
  else
    status=$?
  fi
  [[ $(sysfs_snapshot) == "$before" ]] || fail "$script leaves hardware fixture attributes unchanged"
  grep -q '^forbidden ' "$call_log" && fail "$script avoids live driver or service changes" "$(cat "$call_log")"
  return "$status"
}

assert_no_calls() {
  [[ ! -s $call_log ]] || fail "$1" "$(cat "$call_log")"
}

assert_config() {
  [[ -f $audio_config ]] || fail "$1 writes the configuration"
  grep -qx 'options snd_hda_intel power_save=0 power_save_controller=N' "$audio_config" ||
    fail "$1 disables both verified HDA power-saving settings"
  [[ $(stat -c %a "$audio_config") == "644" ]] || fail "$1 installs mode 644"
}

for script in "$leaf" "$migration"; do
  reset_hardware
  rm -rf "$test_tmp/etc"
  run_script "$script" || fail "$script succeeds on the affected hardware" "$(cat "$test_tmp/output")"
  assert_config "$script"
  if [[ $script == "$migration" ]]; then
    grep -qx 'state set reboot-required' "$call_log" || fail "the migration requests a reboot after installation"
  else
    grep -q '^state ' "$call_log" && fail "hardware setup does not write user reboot state"
  fi
  pass "$script installs the workaround only for the next boot"

  # A second user running the migration must also leave the existing file alone.
  touch -d '2000-01-01 00:00:00 UTC' "$audio_config"
  before=$(stat -c '%i:%Y' "$audio_config")
  run_script "$script" || fail "$script succeeds when repeated"
  assert_no_calls "$script is idempotent without new privileged calls or reboot markers"
  [[ $(stat -c '%i:%Y' "$audio_config") == "$before" ]] || fail "$script does not rewrite an existing configuration"
  pass "$script is idempotent"

  for mismatch in board codec; do
    rm -f "$audio_config"
    reset_hardware
    if [[ $mismatch == "board" ]]; then
      printf 'GU605CW\n' >"$dmi/board_name"
    else
      printf '0x00000000\n' >"$hda/hdaudioC1D0/subsystem_id"
    fi
    run_script "$script" || fail "$script succeeds on unrelated $mismatch hardware"
    [[ ! -e $audio_config ]] || fail "$script skips unrelated $mismatch hardware"
    assert_no_calls "$script makes no privileged or state calls for unrelated $mismatch hardware"
  done
  pass "$script no-ops on unrelated boards and codecs"

  reset_hardware
  for existing in custom empty symlink; do
    rm -f "$audio_config"
    case "$existing" in
      custom) printf 'options snd_hda_intel power_save=5\n' >"$audio_config" ;;
      empty) : >"$audio_config" ;;
      symlink) ln -s "$test_tmp/missing-custom-config" "$audio_config" ;;
    esac
    before=$(stat -c '%F:%i:%s:%Y' "$audio_config")
    run_script "$script" || fail "$script preserves an existing $existing configuration"
    assert_no_calls "$script preserves $existing configuration without privileged or state calls"
    [[ $(stat -c '%F:%i:%s:%Y' "$audio_config") == "$before" ]] || fail "$script preserves the existing $existing file"
    if [[ $existing == "custom" ]]; then
      grep -qx 'options snd_hda_intel power_save=5' "$audio_config" || fail "$script preserves custom contents"
    elif [[ $existing == "symlink" ]]; then
      [[ $(readlink "$audio_config") == "$test_tmp/missing-custom-config" ]] || fail "$script preserves a dangling symlink"
      [[ ! -e $test_tmp/missing-custom-config ]] || fail "$script does not populate a dangling symlink target"
    fi
  done
  pass "$script preserves custom configuration, empty opt-outs, and dangling symlinks"

  rm -f "$audio_config"
  run_script "$script" 1 && fail "$script propagates privilege failure"
  [[ ! -e $audio_config ]] || fail "$script does not install after privilege failure"
  grep -q '^state ' "$call_log" && fail "$script does not request reboot after privilege failure"
  pass "$script propagates privilege failure without requesting reboot"

  run_script "$script" 0 1 && fail "$script propagates a partial write failure"
  [[ ! -e $audio_config ]] || fail "$script does not publish a partially written configuration"
  [[ -z $(ls -A "$test_tmp/etc/modprobe.d") ]] || fail "$script cleans up its failed temporary write"
  grep -q '^state ' "$call_log" && fail "$script does not request reboot after a partial write"
  run_script "$script" || fail "$script can retry after a partial write failure"
  assert_config "$script"
  pass "$script cleans up a partial write and permits a successful retry"

  # A regular file in place of the parent directory forces a real filesystem error.
  rm -rf "$test_tmp/etc/modprobe.d"
  : >"$test_tmp/etc/modprobe.d"
  run_script "$script" && fail "$script propagates configuration write failure"
  grep -q '^state ' "$call_log" && fail "$script does not request reboot after write failure"
  pass "$script propagates configuration write failure without requesting reboot"
done
