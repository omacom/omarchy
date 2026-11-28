#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
modprobe_dir="$test_tmp/modprobe.d"
sys_module="$test_tmp/sys-module"
conf="$modprobe_dir/omarchy-toprow.conf"
mkdir -p "$stub_bin" "$modprobe_dir" "$sys_module/hid_asus" "$sys_module/hid_apple/parameters"
printf '3\n' >"$sys_module/hid_apple/parameters/fnmode"

cat >"$stub_bin/omarchy-hw-aarch64-apple" <<'SH'
#!/bin/bash
exit 1
SH

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
"$@"
SH

# The real omarchy-boot-rebuild on a Limine machine, so a kernel
# limine-mkinitcpio skips while exiting 0 still counts as a failed rebuild.
cat >"$stub_bin/omarchy-boot-backend" <<'SH'
#!/bin/bash
echo limine
SH

cat >"$stub_bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
echo rebuild >>"$TEST_LOG"
[[ -z ${REBUILD_FAILS:-} ]] || echo "mkinitcpio failed for kernel linux"
SH

chmod +x "$stub_bin"/*

toprow() {
  OMARCHY_MODPROBE_DIR="$modprobe_dir" OMARCHY_SYS_MODULE="$sys_module" \
    OMARCHY_TOPROW_REBUILD_PENDING="$test_tmp/rebuild-pending" PATH="$stub_bin:$ROOT/bin:$PATH" TEST_LOG="$calls" \
    bash "$ROOT/bin/omarchy-device-keyboard-toprow" "$@"
}

# Before anything is chosen, the top row reports what the loaded driver booted
# with, and unsupported when no driver leaves Fn-lock to Linux.
bare="$test_tmp/bare-sys-module"
mkdir -p "$bare"
[[ $(sys_module="$bare" toprow) == "unsupported" ]] || fail "toprow is unsupported without a host-kept Fn-lock"
mkdir -p "$bare/hid_asus/parameters"
printf 'Y\n' >"$bare/hid_asus/parameters/fnlock_default"
[[ $(sys_module="$bare" toprow) == "fnkeys" ]] || fail "toprow reports the booted hid_asus Fn-lock"
printf 'N\n' >"$bare/hid_asus/parameters/fnlock_default"
[[ $(sys_module="$bare" toprow) == "mediakeys" ]] || fail "toprow reports hid_asus mediakeys"
apple_only="$test_tmp/apple-sys-module"
mkdir -p "$apple_only/hid_apple/parameters"
printf '2\n' >"$apple_only/hid_apple/parameters/fnmode"
[[ $(sys_module="$apple_only" toprow) == "fnkeys" ]] || fail "toprow reports an Apple-style keyboard without the ASUS drivers"
pass "toprow reports the booted mode before anything is chosen"

# Omarchy's own earlier file goes; an administrator's own stays and is overridden.
printf 'options hid_apple fnmode=2\n' >"$modprobe_dir/hid_apple.conf"
printf 'options hid_asus fnlock_default=1\n' >"$modprobe_dir/hid_asus.conf"
toprow mediakeys >/dev/null
[[ ! -e $modprobe_dir/hid_apple.conf && -e $modprobe_dir/hid_asus.conf ]] || fail "toprow replaces only Omarchy's earlier files"
grep -qx 'options asus_wmi fnlock_default=0' "$conf" || fail "toprow mediakeys sets every host-kept Fn-lock" "$(cat "$conf")"
[[ $(<"$sys_module/hid_apple/parameters/fnmode") == "1" ]] || fail "toprow switches hid_apple right away"
[[ $(<"$calls") == "rebuild" && $(toprow) == "mediakeys" ]] || fail "toprow mediakeys rebuilds the boot image for a loaded keyboard driver" "$(cat "$calls")"
pass "toprow mediakeys sets every host-kept Fn-lock and rebuilds the boot image"

: >"$calls"
toprow mediakeys >/dev/null
[[ ! -s $calls ]] || fail "toprow rebuilds nothing when nothing changed"
printf '2\n' >"$sys_module/hid_apple/parameters/fnmode"
toprow mediakeys >/dev/null
[[ ! -s $calls && $(<"$sys_module/hid_apple/parameters/fnmode") == "1" ]] || fail "toprow restores a drifted hid_apple mode without a rebuild"
sed -i '1s/.*/# Written by an earlier version/' "$conf"
toprow mediakeys >/dev/null
[[ ! -s $calls ]] || fail "toprow rebuilds nothing when only the file's comment differs"
pass "toprow rebuilds nothing when nothing changed"

REBUILD_FAILS=1 toprow fnkeys >/dev/null 2>&1 && fail "toprow fails when the boot image is not rebuilt"
: >"$calls"
toprow fnkeys >/dev/null
[[ $(<"$calls") == "rebuild" && $(toprow) == "fnkeys" ]] || fail "toprow retries a failed rebuild" "$(cat "$calls")"

# The keyboard that needed the rebuild may be unplugged before the retry.
REBUILD_FAILS=1 toprow mediakeys >/dev/null 2>&1 && fail "toprow fails when the boot image is not rebuilt"
: >"$calls"
sys_module="$test_tmp/unplugged-sys-module" toprow mediakeys >/dev/null
[[ $(<"$calls") == "rebuild" && ! -e $test_tmp/rebuild-pending ]] || fail "toprow retries an owed rebuild after the keyboard is unplugged" "$(cat "$calls")"
pass "toprow retries a failed rebuild"

# A writable mount does not make every parameter writable. Keep such errors
# visible rather than treating them as the install chroot's deferred change.
: >"$calls"
chmod a-w "$apple_only/hid_apple/parameters/fnmode"
if [[ ! -w $apple_only/hid_apple/parameters/fnmode ]]; then
  if LC_ALL=C sys_module="$apple_only" toprow mediakeys --no-rebuild >"$test_tmp/write-error" 2>&1; then
    fail "toprow rejects a live parameter write failure on a writable mount"
  fi
  grep -q 'Permission denied' "$test_tmp/write-error" || fail "toprow reports the live parameter write failure"
  [[ $(<"$apple_only/hid_apple/parameters/fnmode") == "2" && ! -s $calls ]] || fail "toprow leaves the mode and boot image alone after a write failure"
  pass "toprow preserves live write errors on writable mounts"
else
  skip "live write permission regression needs a user without DAC override"
fi
chmod u+w "$apple_only/hid_apple/parameters/fnmode"

# The install chroot has a read-only /sys. Use a real read-only mount so tee
# fails as it does there, without touching the host's keyboard or mounts.
if unshare --user --map-root-user --mount true 2>/dev/null; then
  printf '2\n' >"$apple_only/hid_apple/parameters/fnmode"
  rm -f "$conf" "$modprobe_dir/hid_asus.conf"
  : >"$calls"
  OMARCHY_MODPROBE_DIR="$modprobe_dir" OMARCHY_SYS_MODULE="$apple_only" \
    OMARCHY_TOPROW_REBUILD_PENDING="$test_tmp/rebuild-pending" PATH="$stub_bin:$ROOT/bin:$PATH" TEST_LOG="$calls" \
    unshare --user --map-root-user --mount bash -euc '
      mount --bind "$1" "$1"
      mount -o remount,bind,ro "$1"
      bash "$3"
      grep -qx "options hid_apple fnmode=1" "$OMARCHY_MODPROBE_DIR/omarchy-toprow.conf"
      bash "$2" mediakeys --no-rebuild
    ' -- "$apple_only" "$ROOT/bin/omarchy-device-keyboard-toprow" "$ROOT/install/hardware/fix-fkeys.sh" >"$test_tmp/readonly-output" ||
    fail "toprow saves the boot mode when sysfs is read-only"
  grep -qx 'options hid_apple fnmode=1' "$conf" || fail "toprow persists the Apple boot mode with read-only sysfs"
  [[ $(<"$apple_only/hid_apple/parameters/fnmode") == "2" && ! -s $calls ]] ||
    fail "toprow leaves the live mode and boot image alone during install"
  [[ $(grep -c 'from the next boot' "$test_tmp/readonly-output") == "2" ]] || fail "toprow reports the deferred live change on both calls"
  if grep -q 'already sends' "$test_tmp/readonly-output"; then
    fail "toprow still reports the deferred change when the boot configuration already matches"
  fi
  pass "toprow saves the boot mode when sysfs is read-only"
  sys_module="$apple_only" toprow mediakeys --no-rebuild >"$test_tmp/writable-output"
  [[ $(<"$apple_only/hid_apple/parameters/fnmode") == "1" && ! -s $calls ]] || fail "toprow applies the deferred mode once sysfs is writable"
  grep -q 'already sends' "$test_tmp/writable-output" || fail "toprow no longer reports a deferred live change on writable sysfs"
  pass "toprow applies the saved mode once sysfs is writable"
else
  skip "read-only sysfs regression needs unprivileged mount namespaces"
fi
