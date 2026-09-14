#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1789095456.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/drop-ins"

export PATH="$scratch/bin:$ROOT/bin:$PATH"
export CALL_LOG="$scratch/calls"
export INSTALLED_PACKAGES="$scratch/packages"
export OMARCHY_PTL_LIMINE_CONF="$scratch/limine"
export OMARCHY_PTL_LIMINE_DROP_INS="$scratch/drop-ins"
export OMARCHY_PTL_REBUILD_MARKER="$scratch/state/completed"
kernel="linux-omarchy-ptl-novrr-mm"
boot_order='BOOT_ORDER="linux-omarchy-*, *, *fallback, Snapshots"'

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
  pacman | sed | install | limine-mkinitcpio | limine-entry-tool) exec "$@" ;;
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
printf '%s\n' 'Omarchy' '  linux-ptl' '  Snapshots'
if [[ ${MISSING_ENTRY:-0} == "0" ]]; then
  printf '%s\n' '  linux-omarchy-ptl-novrr-mm'
fi
SH

cat > "$scratch/bin/omarchy-state" <<'SH'
#!/bin/bash
[[ $* == "set reboot-required" ]] || exit 99
printf 'state %s\n' "$*" >> "$CALL_LOG"
SH
chmod +x "$scratch/bin/"*

reset_fixture() {
  : > "$CALL_LOG"
  printf '%s\n' linux-ptl linux-ptl-headers > "$INSTALLED_PACKAGES"
  rm -f "$OMARCHY_PTL_REBUILD_MARKER" "$OMARCHY_PTL_LIMINE_DROP_INS/"*.conf
  cat > "$OMARCHY_PTL_LIMINE_CONF" <<'CONF'
KERNEL_CMDLINE[default]="root=UUID=keep-me rw cryptdevice=UUID=keep-me:root"
BOOT_ORDER="*, *fallback, Snapshots"
ENABLE_UKI=yes
CONF
  cp "$OMARCHY_PTL_LIMINE_CONF" "$scratch/original-limine"
}

run_migration() {
  bash -euo pipefail "$migration" > "$scratch/output" 2>&1
}

assert_preferred() {
  grep -Fxq "$boot_order" "$1" || fail "Omarchy kernels are preferred in $1"
}

reset_fixture
printf '%s\n' linux > "$INSTALLED_PACKAGES"
run_migration
[[ ! -s $CALL_LOG ]] || fail "systems without linux-ptl do not change"
cmp -s "$OMARCHY_PTL_LIMINE_CONF" "$scratch/original-limine" || fail "unaffected Limine settings stay unchanged"
[[ ! -e $OMARCHY_PTL_REBUILD_MARKER ]] || fail "unaffected systems do not get a completion marker"
pass "systems without linux-ptl are skipped"

reset_fixture
for name in dell-xps-panther-lake zz-dell-xps-panther-lake; do
  printf '%s\n' 'BOOT_ORDER="linux-ptl*, *fallback, Snapshots"' > "$OMARCHY_PTL_LIMINE_DROP_INS/$name.conf"
done
cp "$OMARCHY_PTL_LIMINE_CONF" "$OMARCHY_PTL_LIMINE_DROP_INS/omarchy-defaults.conf"
run_migration
grep -Fxq "pacman -S --noconfirm --needed $kernel $kernel-headers" "$CALL_LOG" || fail "both new packages are installed"
grep -Fxq linux-ptl "$INSTALLED_PACKAGES" || fail "the old kernel is kept for recovery"
grep -Fxq linux-ptl-headers "$INSTALLED_PACKAGES" || fail "the old kernel headers are kept"
assert_preferred "$OMARCHY_PTL_LIMINE_CONF"
for conf in "$OMARCHY_PTL_LIMINE_DROP_INS/"*.conf; do
  assert_preferred "$conf"
done
diff -u <(sed '/^BOOT_ORDER=/d' "$scratch/original-limine") \
  <(sed '/^BOOT_ORDER=/d' "$OMARCHY_PTL_LIMINE_CONF") || fail "kernel command line and unrelated settings are preserved"
grep -Fxq "sudo limine-mkinitcpio $kernel" "$CALL_LOG" || fail "the new kernel's boot image is rebuilt"
[[ -f $OMARCHY_PTL_REBUILD_MARKER ]] || fail "successful completion is recorded"
grep -Fxq 'state set reboot-required' "$CALL_LOG" || fail "the updater must offer a reboot when retaining the old kernel"
pass "new packages install, all stock boot orders are repaired, and the old kernel remains available"

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
assert_preferred "$OMARCHY_PTL_LIMINE_CONF"
pass "existing new packages still receive the config repair and boot rebuild"

reset_fixture
if INSTALL_FAIL=1 run_migration; then
  fail "package installation failure must fail the migration"
fi
cmp -s "$OMARCHY_PTL_LIMINE_CONF" "$scratch/original-limine" || fail "install failure leaves the config untouched"
! grep -q 'limine-mkinitcpio' "$CALL_LOG" || fail "install failure does not rebuild"
[[ ! -e $OMARCHY_PTL_REBUILD_MARKER ]] || fail "install failure stays pending"
pass "package failures leave the old boot setup intact and the migration pending"

reset_fixture
if REBUILD_FAIL=1 run_migration; then
  fail "boot rebuild failure must fail the migration"
fi
[[ ! -e $OMARCHY_PTL_REBUILD_MARKER ]] || fail "rebuild failure stays pending"
! grep -q '^state ' "$CALL_LOG" || fail "rebuild failure must not request a reboot"
assert_preferred "$OMARCHY_PTL_LIMINE_CONF"
: > "$CALL_LOG"
run_migration
grep -Fxq "sudo limine-mkinitcpio $kernel" "$CALL_LOG" || fail "retry must rebuild even after config and packages are repaired"
[[ -f $OMARCHY_PTL_REBUILD_MARKER ]] || fail "retry records successful completion"
pass "a failed rebuild is retried even after config and package changes succeeded"

reset_fixture
if MISSING_ENTRY=1 run_migration; then
  fail "a silently skipped kernel build must fail the migration"
fi
[[ ! -e $OMARCHY_PTL_REBUILD_MARKER ]] || fail "a missing boot entry stays pending"
! grep -q '^state ' "$CALL_LOG" || fail "a missing boot entry must not request a reboot"
run_migration
[[ -f $OMARCHY_PTL_REBUILD_MARKER ]] || fail "a missing boot entry can be repaired on retry"
pass "a successful command without a new boot entry cannot complete the migration"

reset_fixture
printf '%s\n' 'BOOT_ORDER="linux-lts, *, *fallback, Snapshots"' > "$OMARCHY_PTL_LIMINE_CONF"
cp "$OMARCHY_PTL_LIMINE_CONF" "$scratch/custom-limine"
run_migration
cmp -s "$OMARCHY_PTL_LIMINE_CONF" "$scratch/custom-limine" || fail "custom boot orders stay unchanged"
pass "administrator-defined boot orders are preserved"

reset_fixture
cp "$OMARCHY_PTL_LIMINE_CONF" "$OMARCHY_PTL_LIMINE_DROP_INS/omarchy-defaults.conf"
printf '%s\n' 'ENABLE_SORT=yes' >> "$OMARCHY_PTL_LIMINE_DROP_INS/omarchy-defaults.conf"
cp "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf" "$OMARCHY_PTL_LIMINE_DROP_INS/omarchy-defaults.conf.pacnew"
run_migration
assert_preferred "$OMARCHY_PTL_LIMINE_DROP_INS/omarchy-defaults.conf"
grep -Fxq 'ENABLE_SORT=yes' "$OMARCHY_PTL_LIMINE_DROP_INS/omarchy-defaults.conf" || fail "custom packaged settings survive the repair"
cmp -s "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf" \
  "$OMARCHY_PTL_LIMINE_DROP_INS/omarchy-defaults.conf.pacnew" || fail "the pending pacnew is left for the administrator to merge"
pass "active packaged defaults are repaired when customized settings leave the update in a pacnew"

reset_fixture
printf '%s\n' '  BOOT_ORDER="*, *fallback, Snapshots" # keep this comment' > "$OMARCHY_PTL_LIMINE_CONF"
run_migration
grep -Fxq "  $boot_order # keep this comment" "$OMARCHY_PTL_LIMINE_CONF" || fail "stock orders with comments are repaired"
pass "indentation and comments survive the repair"

reset_fixture
rm "$OMARCHY_PTL_LIMINE_CONF"
cp "$ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf" "$OMARCHY_PTL_LIMINE_DROP_INS/omarchy-defaults.conf"
run_migration
[[ ! -e $OMARCHY_PTL_LIMINE_CONF ]] || fail "missing central config is not fabricated"
assert_preferred "$OMARCHY_PTL_LIMINE_DROP_INS/omarchy-defaults.conf"
pass "installs without a central config inherit the packaged boot order"
