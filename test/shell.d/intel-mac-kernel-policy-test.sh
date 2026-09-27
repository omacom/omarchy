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
export OMARCHY_KERNEL_DMI_VENDOR="$scratch/sys_vendor"
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
  printf '%s\n' 'Dell Inc.' > "$OMARCHY_KERNEL_DMI_VENDOR"
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

# Local fixture additions. Setup above is retained from #12328's test.
# Remediation retains the Apple exemption and fails closed on unknown DMI.
for vendor in 'Apple Inc.' 'Apple Computer, Inc.' 'Apple' 'Appleish' 'apple Inc.'; do
  reset_fixture
  printf '%s\n' "$vendor" > "$OMARCHY_KERNEL_DMI_VENDOR"
  run_migration
  assert_skipped
  pass "source Apple-prefix policy skips $vendor without changing boot order"
done

for vendor in 'Dell Inc.'; do
  reset_fixture
  printf '%s\n' "$vendor" > "$OMARCHY_KERNEL_DMI_VENDOR"
  run_migration
  grep -Fxq "$kernel" "$INSTALLED_PACKAGES" || fail "source non-Apple policy migrates $vendor"
  assert_preferred "$OMARCHY_KERNEL_LIMINE_CONF"
  pass "source non-Apple policy migrates $vendor"
done

for state in missing unreadable directory empty; do
  reset_fixture
  case "$state" in
    empty) : >"$OMARCHY_KERNEL_DMI_VENDOR" ;;
    missing) rm "$OMARCHY_KERNEL_DMI_VENDOR" ;;
    unreadable) chmod 000 "$OMARCHY_KERNEL_DMI_VENDOR" ;;
    directory) rm "$OMARCHY_KERNEL_DMI_VENDOR"; mkdir "$OMARCHY_KERNEL_DMI_VENDOR" ;;
  esac
  if run_migration; then fail "unavailable DMI leaves migration pending"; fi
  assert_skipped
  pass "unavailable $state DMI preserves the installed kernel"
  [[ $state != unreadable ]] || chmod 600 "$OMARCHY_KERNEL_DMI_VENDOR"
  [[ $state != directory ]] || rmdir "$OMARCHY_KERNEL_DMI_VENDOR"
done

reset_fixture
printf '%s\n' 'Apple Inc.' > "$OMARCHY_KERNEL_DMI_VENDOR"
printf '%s\n' linux-omarchy linux-omarchy-headers > "$INSTALLED_PACKAGES"
printf '%s\n' "$boot_order" >> "$OMARCHY_KERNEL_LIMINE_CONF"
cp "$OMARCHY_KERNEL_LIMINE_CONF" "$scratch/already-migrated-limine"
cp "$INSTALLED_PACKAGES" "$scratch/already-migrated-packages"
mkdir -p "$(dirname "$OMARCHY_KERNEL_REBUILD_MARKER")"
touch "$OMARCHY_KERNEL_REBUILD_MARKER"
run_migration
[[ ! -s $CALL_LOG ]] || fail "already-migrated Apple has no new side effects"
cmp "$INSTALLED_PACKAGES" "$scratch/already-migrated-packages" || fail "the old kernel is not restored"
cmp "$OMARCHY_KERNEL_LIMINE_CONF" "$scratch/already-migrated-limine" || fail "the old boot order is not restored"
[[ -f $OMARCHY_KERNEL_REBUILD_MARKER ]] || fail "old completion marker remains"
pass "Apple exemption does not roll back an already migrated system"

reset_fixture
printf '%s\n' 'Apple Inc.' > "$OMARCHY_KERNEL_DMI_VENDOR"
export OMARCHY_PATH="$scratch/omarchy"
export OMARCHY_MIGRATION_STATE="$scratch/user-markers"
mkdir -p "$OMARCHY_PATH/migrations" "$OMARCHY_MIGRATION_STATE"
cp "$migration" "$OMARCHY_PATH/migrations/"
pending=$("$ROOT/bin/omarchy-migrate" --pending)
[[ $pending == 1789325478.sh ]] || fail "uncompleted user migration stays pending"
pass "source migration is reached for a user with no completion marker"
touch "$OMARCHY_MIGRATION_STATE/1789325478.sh"
pending_status=0
pending=$("$ROOT/bin/omarchy-migrate" --pending) || pending_status=$?
[[ $pending_status == 1 && -z $pending ]] || fail "already-completed user migration is not rerun"
pass "completed user migration is not automatically revisited"
