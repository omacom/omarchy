#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1789325478.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/drop-ins"

export PATH="$scratch/bin:$ROOT/bin:$PATH"
export CALL_LOG="$scratch/calls"
export INSTALLED_PACKAGES="$scratch/packages"
export OMARCHY_KERNEL_LIMINE_CONF="$scratch/limine"
export OMARCHY_KERNEL_LIMINE_DROP_INS="$scratch/drop-ins"
export OMARCHY_KERNEL_REBUILD_MARKER="$scratch/state/1789325478"
kernel="linux-omarchy"
boot_order='BOOT_ORDER="linux-omarchy, linux-omarchy-*, *, *fallback, Snapshots"'

# Exercise the real package helpers, including their post-install queries.
cat > "$scratch/bin/pacman" <<'SH'
#!/bin/bash
case "$1" in
  -Q) grep -Fxq "$2" "$INSTALLED_PACKAGES" ;;
  -S)
    printf 'pacman %s\n' "$*" >> "$CALL_LOG"
    [[ ${INSTALL_FAIL:-0} == "0" ]] || exit 1
    for arg in "$@"; do
      [[ $arg == -* ]] || printf '%s\n' "$arg" >> "$INSTALLED_PACKAGES"
    done
    ;;
  *) exit 99 ;;
esac
SH

cat > "$scratch/bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo %s\n' "$*" >> "$CALL_LOG"
case "$1" in
  pacman | mkdir | touch | sed | tee | install | limine-mkinitcpio | limine-entry-tool) exec "$@" ;;
  *) exit 99 ;;
esac
SH

cat > "$scratch/bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
[[ ${REBUILD_FAIL:-0} == "0" ]]
SH

cat > "$scratch/bin/limine-entry-tool" <<'SH'
#!/bin/bash
[[ $* == "--tree" ]] || exit 99
printf '%s\n' 'Omarchy' '  linux-ptl' '  linux-omarchy-ptl-novrr-mm' '  linux-omarchy-bore' '  linux-omarchy-fallback' '  Snapshots'
if [[ ${MISSING_ENTRY:-0} == "0" ]]; then
  printf '%s\n' '  linux-omarchy'
fi
SH

cat > "$scratch/bin/omarchy-state" <<'SH'
#!/bin/bash
[[ $* == "set reboot-required" ]] || exit 99
printf 'state %s\n' "$*" >> "$CALL_LOG"
SH

cat > "$scratch/bin/uname" <<'SH'
#!/bin/bash
case "$1" in
  -m) printf '%s\n' "${TEST_ARCH:-x86_64}" ;;
  -r) printf '%s\n' "${TEST_KERNEL_RELEASE:-7.2.5-arch1-1}" ;;
  *) exit 99 ;;
esac
SH

cat > "$scratch/bin/omarchy-notification-dismiss" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$scratch/bin/"*

reset_fixture() {
  : > "$CALL_LOG"
  printf '%s\n' linux-ptl linux-ptl-headers > "$INSTALLED_PACKAGES"
  rm -f "$OMARCHY_KERNEL_REBUILD_MARKER" "$OMARCHY_KERNEL_LIMINE_DROP_INS/"*
  cat > "$OMARCHY_KERNEL_LIMINE_CONF" <<'CONF'
KERNEL_CMDLINE[default]="root=UUID=keep-me rw cryptdevice=UUID=keep-me:root"
BOOT_ORDER="*, *fallback, Snapshots"
ENABLE_UKI=yes
CONF
  cp "$OMARCHY_KERNEL_LIMINE_CONF" "$scratch/original-limine"
}

run_migration() {
  bash -euo pipefail "$migration" > "$scratch/output" 2>&1
}

assert_preferred() {
  grep -Fxq "$boot_order" "$1" || fail "Omarchy kernels are preferred in $1"
}

assert_skipped() {
  [[ ! -s $CALL_LOG ]] || fail "excluded systems do not change" "$(<"$CALL_LOG")"
  cmp -s "$OMARCHY_KERNEL_LIMINE_CONF" "$scratch/original-limine" || fail "excluded systems keep their boot settings"
  [[ ! -e $OMARCHY_KERNEL_REBUILD_MARKER ]] || fail "excluded systems do not get a completion marker"
}

for old_kernel in linux linux-lts linux-zen linux-ptl linux-omarchy-ptl-novrr-mm; do
  reset_fixture
  printf '%s\n' "$old_kernel" "$old_kernel-headers" > "$INSTALLED_PACKAGES"
  run_migration
  grep -Fxq "$kernel" "$INSTALLED_PACKAGES" || fail "the generic kernel is installed"
  grep -Fxq "$kernel-headers" "$INSTALLED_PACKAGES" || fail "its headers are installed"
  grep -Fxq "$old_kernel" "$INSTALLED_PACKAGES" || fail "the previous kernel remains available"
  assert_preferred "$OMARCHY_KERNEL_LIMINE_CONF"
  pass "$old_kernel systems receive the generic Omarchy kernel and retain their recovery kernel"
done

for installed in linux-t2 $'linux-t2\nlinux\nlinux-ptl\nlinux-omarchy'; do
  reset_fixture
  printf '%s\n' "$installed" > "$INSTALLED_PACKAGES"
  run_migration
  assert_skipped
done
pass "linux-t2 systems are skipped even with other kernels installed"

reset_fixture
TEST_KERNEL_RELEASE=7.2.5-arch1-T2 run_migration
assert_skipped
pass "a running T2 kernel is excluded even if its package is no longer installed"

reset_fixture
TEST_ARCH=aarch64 run_migration
assert_skipped
pass "ARM systems cannot receive an x86_64 kernel"

reset_fixture
printf '%s\n' linux-omarchy-ptl-novrr-mm > "$INSTALLED_PACKAGES"
mkdir -p "$scratch/state" "$scratch/user-markers" "$scratch/omarchy/migrations"
export OMARCHY_PTL_REBUILD_MARKER="$scratch/state/1789095456"
export OMARCHY_MIGRATION_STATE="$scratch/user-markers"
touch "$OMARCHY_PTL_REBUILD_MARKER" "$OMARCHY_MIGRATION_STATE/1789095456.sh"
cp "$migration" "$scratch/omarchy/migrations/"
[[ ! -e $ROOT/migrations/1789095456.sh ]] || fail "the superseded migration must not install the PTL variant first"
pending=$(OMARCHY_PATH="$scratch/omarchy" "$ROOT/bin/omarchy-migrate" --pending)
[[ $pending == "1789325478.sh" ]] || fail "the renamed migration is pending after completing the old migration"
OMARCHY_PATH="$scratch/omarchy" "$ROOT/bin/omarchy-migrate" > "$scratch/output" 2>&1
grep -Fxq "$kernel" "$INSTALLED_PACKAGES" || fail "the old completion markers cannot skip the generic kernel"
[[ -f $OMARCHY_KERNEL_REBUILD_MARKER && -f $OMARCHY_MIGRATION_STATE/1789325478.sh ]] || fail "new machine and user completion markers are recorded"
assert_preferred "$OMARCHY_KERNEL_LIMINE_CONF"
pass "users who completed the PTL migration run the renamed migration with fresh completion markers"

reset_fixture
for name in dell-xps-panther-lake zz-dell-xps-panther-lake; do
  printf '%s\n' 'BOOT_ORDER="linux-ptl*, *fallback, Snapshots"' > "$OMARCHY_KERNEL_LIMINE_DROP_INS/$name.conf"
done
cp "$OMARCHY_KERNEL_LIMINE_CONF" "$OMARCHY_KERNEL_LIMINE_DROP_INS/omarchy-defaults.conf"
run_migration
grep -Fxq "pacman -S --noconfirm --needed $kernel $kernel-headers" "$CALL_LOG" || fail "both new packages are installed"
grep -Fxq linux-ptl "$INSTALLED_PACKAGES" || fail "the old kernel is kept for recovery"
grep -Fxq linux-ptl-headers "$INSTALLED_PACKAGES" || fail "the old kernel headers are kept"
assert_preferred "$OMARCHY_KERNEL_LIMINE_CONF"
diff -u <(sed '/^BOOT_ORDER=/d; /^$/d' "$scratch/original-limine") \
  <(sed '/^BOOT_ORDER=/d; /^$/d' "$OMARCHY_KERNEL_LIMINE_CONF") || fail "kernel command line and unrelated settings are preserved"
grep -Fxq "sudo limine-mkinitcpio $kernel" "$CALL_LOG" || fail "the new kernel's boot image is rebuilt"
[[ -f $OMARCHY_KERNEL_REBUILD_MARKER ]] || fail "successful completion is recorded"
grep -Fxq 'state set reboot-required' "$CALL_LOG" || fail "the updater must offer a reboot when retaining the old kernel"
pass "new packages install, the central boot order is set, and the old kernel remains available"

: > "$CALL_LOG"
run_migration
[[ ! -s $CALL_LOG ]] || fail "another user's run does not repeat the machine-wide migration"
pass "repeat runs are a no-op after successful completion"

reset_fixture
printf '%s\n' "$kernel" >> "$INSTALLED_PACKAGES"
run_migration
grep -Fxq "$kernel-headers" "$INSTALLED_PACKAGES" || fail "missing headers install when the kernel is already present"
pass "a partially installed kernel gets its missing headers"

reset_fixture
printf '%s\n' "$kernel" "$kernel-headers" >> "$INSTALLED_PACKAGES"
run_migration
! grep -q '^pacman -S' "$CALL_LOG" || fail "already installed packages are not reinstalled"
assert_preferred "$OMARCHY_KERNEL_LIMINE_CONF"
pass "existing new packages still receive the config repair and boot rebuild"

reset_fixture
if INSTALL_FAIL=1 run_migration; then
  fail "package installation failure must fail the migration"
fi
cmp -s "$OMARCHY_KERNEL_LIMINE_CONF" "$scratch/original-limine" || fail "install failure leaves the config untouched"
! grep -q 'limine-mkinitcpio' "$CALL_LOG" || fail "install failure does not rebuild"
[[ ! -e $OMARCHY_KERNEL_REBUILD_MARKER ]] || fail "install failure stays pending"
pass "package failures leave the old boot setup intact and the migration pending"

reset_fixture
if REBUILD_FAIL=1 run_migration; then
  fail "boot rebuild failure must fail the migration"
fi
[[ ! -e $OMARCHY_KERNEL_REBUILD_MARKER ]] || fail "rebuild failure stays pending"
! grep -q '^state ' "$CALL_LOG" || fail "rebuild failure must not request a reboot"
assert_preferred "$OMARCHY_KERNEL_LIMINE_CONF"
: > "$CALL_LOG"
run_migration
grep -Fxq "sudo limine-mkinitcpio $kernel" "$CALL_LOG" || fail "retry must rebuild even after config and packages are repaired"
[[ -f $OMARCHY_KERNEL_REBUILD_MARKER ]] || fail "retry records successful completion"
pass "a failed rebuild is retried even after config and package changes succeeded"

reset_fixture
if MISSING_ENTRY=1 run_migration; then
  fail "a silently skipped kernel build must fail the migration"
fi
[[ ! -e $OMARCHY_KERNEL_REBUILD_MARKER ]] || fail "a missing boot entry stays pending"
! grep -q '^state ' "$CALL_LOG" || fail "a missing boot entry must not request a reboot"
run_migration
[[ -f $OMARCHY_KERNEL_REBUILD_MARKER ]] || fail "a missing boot entry can be repaired on retry"
pass "older Omarchy variants and fallback entries cannot satisfy generic kernel verification"

reset_fixture
cat >> "$OMARCHY_KERNEL_LIMINE_CONF" <<'CONF'
BOOT_ORDER="linux-omarchy-*, *, *fallback, Snapshots"
  BOOT_ORDER = 'linux-lts, *, *fallback, Snapshots'
CONF
run_migration
assert_preferred "$OMARCHY_KERNEL_LIMINE_CONF"
[[ $(grep -c '^BOOT_ORDER=' "$OMARCHY_KERNEL_LIMINE_CONF") == "1" ]] || fail "only one boot order is written"
! grep -Eq '^[[:space:]]+BOOT_ORDER' "$OMARCHY_KERNEL_LIMINE_CONF" || fail "a later custom assignment cannot override first position"
pass "the exact generic kernel takes first position over previous PTL and custom orders"

reset_fixture
for name in omarchy-defaults dell-xps-panther-lake zz-dell-xps-panther-lake; do
  printf '%s\n' 'BOOT_ORDER="linux-ptl*, *fallback, Snapshots"' > "$OMARCHY_KERNEL_LIMINE_DROP_INS/$name.conf"
done
printf '%s\n' 'ENABLE_SORT=yes' >> "$OMARCHY_KERNEL_LIMINE_DROP_INS/omarchy-defaults.conf"
cp "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf" "$OMARCHY_KERNEL_LIMINE_DROP_INS/omarchy-defaults.conf.pacnew"
run_migration
effective_order=$(bash -c 'declare -A KERNEL_CMDLINE; for conf in "$1/"*.conf "$2"; do source "$conf"; done; printf "%s" "$BOOT_ORDER"' -- "$OMARCHY_KERNEL_LIMINE_DROP_INS" "$OMARCHY_KERNEL_LIMINE_CONF")
[[ $effective_order == "linux-omarchy, linux-omarchy-*, *, *fallback, Snapshots" ]] || fail "the central config wins over old and customized drop-ins"
grep -Fxq 'ENABLE_SORT=yes' "$OMARCHY_KERNEL_LIMINE_DROP_INS/omarchy-defaults.conf" || fail "custom packaged settings survive"
cmp -s "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf" \
  "$OMARCHY_KERNEL_LIMINE_DROP_INS/omarchy-defaults.conf.pacnew" || fail "the pacnew is left for the administrator to merge"
pass "the central boot order overrides legacy drop-ins and pacnew files without rewriting them"

reset_fixture
rm "$OMARCHY_KERNEL_LIMINE_CONF"
run_migration
assert_preferred "$OMARCHY_KERNEL_LIMINE_CONF"
pass "a missing central config is created with the exact kernel first"
