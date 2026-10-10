#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf=install/hardware/lenovo/fix-thinkpad-bluetooth-hotkey.sh
migration=migrations/1790544300.sh
helper=default/systemd/thinkpad-bluetooth-hotkey.sh
unit=default/systemd/system/omarchy-thinkpad-bluetooth-hotkey.service
[[ ! -e $ROOT/default/modprobe.d/omarchy-thinkpad-bluetooth-hotkey.conf ]] ||
  fail "no model-specific boot mask is shipped"
rg -Fq 'lenovo/fix-thinkpad-bluetooth-hotkey.sh' "$ROOT/install/hardware/all.sh" ||
  fail "hardware setup runs the ThinkPad leaf"
for line in 'After=systemd-modules-load.service' 'ConditionPathExists=/sys/devices/platform/thinkpad_acpi/hotkey_mask' 'Type=oneshot' 'ExecStart=/bin/bash /usr/local/lib/omarchy/thinkpad-bluetooth-hotkey.sh' 'WantedBy=multi-user.target'; do
  rg -Fxq "$line" "$ROOT/$unit" || fail "boot unit contains $line"
done

test_tmp=$(mktemp -d)
trap 'chmod -R u+rwX "$test_tmp"; rm -rf "$test_tmp"' EXIT
export OMARCHY_PATH="$test_tmp/repo" TEST_LOG="$test_tmp/calls" TEST_MASK="$test_tmp/mask"
export TEST_SYS="$test_tmp/sys" TEST_READ_FAIL=0 TEST_WRITE_FAIL=0 TEST_THINKPAD=1
mkdir -p "$test_tmp/bin" "$TEST_SYS/module/thinkpad_acpi" "$TEST_SYS/devices/platform/thinkpad_acpi"
# Redirect filesystem boundaries; execute the actual scripts and copied helper.
for script in "$leaf" "$migration" "$helper" "$unit"; do
  mkdir -p "$OMARCHY_PATH/$(dirname "$script")"
  sed -e "s|/sys/|$TEST_SYS/|g" -e "s|/etc/|$test_tmp/etc/|g" \
    -e "s|/usr/local/|$test_tmp/usr/local/|g" "$ROOT/$script" >"$OMARCHY_PATH/$script"
done
mkdir -p "$test_tmp/etc/modprobe.d"
printf 'administrator configuration\n' >"$test_tmp/etc/modprobe.d/omarchy-thinkpad-hotkey.conf"

cat >"$test_tmp/bin/sudo" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_LOG"
case $1 in
  install|/bin/bash) "$@" ;;
  systemctl) ;;
  *) exit 99 ;;
esac
STUB
cat >"$test_tmp/bin/cat" <<'STUB'
#!/bin/bash
# Simulate root access to sysfs, including a read failure, even in root-run CI.
(( TEST_READ_FAIL == 0 )) || exit 1
/bin/cat "$TEST_MASK"
STUB
cat >"$test_tmp/bin/tee" <<'STUB'
#!/bin/bash
(( TEST_WRITE_FAIL == 0 )) || exit 1
/usr/bin/tee "$TEST_MASK"
STUB
cat >"$test_tmp/bin/omarchy-hw-match" <<'STUB'
#!/bin/bash
[[ $1 == "ThinkPad" ]] && (( TEST_THINKPAD == 1 ))
STUB
chmod +x "$test_tmp/bin/"*
export PATH="$test_tmp/bin:$PATH"
mask_path="$TEST_SYS/devices/platform/thinkpad_acpi/hotkey_mask"
installed_helper="$test_tmp/usr/local/lib/omarchy/thinkpad-bluetooth-hotkey.sh"
installed_unit="$test_tmp/etc/systemd/system/omarchy-thinkpad-bluetooth-hotkey.service"

run_script() {
  bash -euo pipefail -c 'source "$1"; echo survived' bash "$OMARCHY_PATH/$1" >"$test_tmp/output"
  rg -q '^survived$' "$test_tmp/output" || fail "script completes under strict mode"
  cmp "$OMARCHY_PATH/$helper" "$installed_helper" || fail "shared helper is installed"
  cmp "$OMARCHY_PATH/$unit" "$installed_unit" || fail "boot unit is installed"
  rg -Fxq 'systemctl daemon-reload' "$TEST_LOG" || fail "system units are reloaded"
  rg -Fxq 'systemctl enable omarchy-thinkpad-bluetooth-hotkey.service' "$TEST_LOG" || fail "boot unit is enabled"
  rg -Fxq "/bin/bash $installed_helper" "$TEST_LOG" || fail "live mask is applied with root privileges"
  if rg -q 'modprobe|mkinitcpio' "$TEST_LOG"; then fail "no modprobe mask or initramfs rebuild is requested"; fi
}

for script in "$leaf" "$migration"; do
  for mask in 0xff8c7ffb 0x00000005 0x00100005; do
    printf '%s\n' "$mask" >"$TEST_MASK"
    if [[ -e $mask_path ]]; then chmod 644 "$mask_path"; fi
    cp "$TEST_MASK" "$mask_path"
    chmod 444 "$mask_path"
    : >"$TEST_LOG"
    run_script "$script"
    expected=$(printf '%#x' "$((mask | 0x00100000))")
    [[ $(<"$TEST_MASK") == "$expected" ]] || fail "only bit 20 changes for $mask"
    run_script "$script"
    [[ $(<"$TEST_MASK") == "$expected" ]] || fail "repeated execution preserves mask"

    # Simulate a reboot resetting the mask, then run the unit's actual ExecStart.
    printf '%s\n' "$mask" >"$TEST_MASK"
    boot_command=$(sed -n 's/^ExecStart=//p' "$installed_unit")
    bash -euo pipefail -c "$boot_command"
    [[ $(<"$TEST_MASK") == "$expected" ]] || fail "boot restores only bit 20 for $mask"
  done

  for failure in read write; do
    export TEST_READ_FAIL=0 TEST_WRITE_FAIL=0
    if [[ $failure == "read" ]]; then export TEST_READ_FAIL=1; else export TEST_WRITE_FAIL=1; fi
    printf '0x5\n' >"$TEST_MASK"
    : >"$TEST_LOG"
    run_script "$script"
    bash -euo pipefail "$installed_helper"
    [[ $(<"$TEST_MASK") == "0x5" ]] || fail "failed $failure preserves mask"
  done
  export TEST_READ_FAIL=0 TEST_WRITE_FAIL=0

  rm -f "$mask_path"
  : >"$TEST_LOG"
  run_script "$script"
  bash -euo pipefail "$installed_helper"
  [[ $(<"$TEST_MASK") == "0x5" ]] || fail "missing sysfs preserves mask"

  rmdir "$TEST_SYS/module/thinkpad_acpi"
  export TEST_THINKPAD=0
  : >"$TEST_LOG"
  bash -euo pipefail -c 'source "$1"' bash "$OMARCHY_PATH/$script" >"$test_tmp/output"
  [[ ! -s $TEST_LOG ]] || fail "unrelated hardware is untouched"
  export TEST_THINKPAD=1
  mkdir -p "$TEST_SYS/module/thinkpad_acpi"

  [[ $(<"$test_tmp/etc/modprobe.d/omarchy-thinkpad-hotkey.conf") == "administrator configuration" ]] ||
    fail "unrelated configuration is preserved"
  [[ ! -e $test_tmp/etc/modprobe.d/omarchy-thinkpad-bluetooth-hotkey.conf ]] ||
    fail "no modprobe configuration is installed"
  pass "$script installs persistence and safely applies the ThinkPad mask under strict mode"
done
