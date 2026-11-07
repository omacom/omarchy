#!/bin/bash
#
# Migration 1789840720 pins root= in /etc/default/limine when the omarchy-defaults
# += drop-in hides the /proc/cmdline fallback. It runs as the user, so the
# root-only ESP and /etc/default are modelled with real permissions that only
# the sudo stub opens, and every failure that leaves the boot cmdline unrepaired
# must exit non-zero so the migration stays pending.

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

migration=${MIGRATION_UNDER_TEST:-$ROOT/migrations/1789840720.sh}

if (($(id -u) == 0)); then
  echo "ok - limine root= pin migration # SKIP root ignores the permissions this test models"
  exit 0
fi

test_dir=$(mktemp -d)
trap '[[ -n ${KEEP:-} ]] || { chmod -R u+rwX "$test_dir" 2>/dev/null; rm -rf "$test_dir"; }' EXIT
stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

# sudo opens the root-only directories for the one command it runs.
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
echo "sudo $*" >>"$TEST_LOG"
[[ ${SUDO_DENY:-} == 1 ]] && exit 1
# Overlapping elevations (find feeding a loop of objcopy calls) must not close
# the directories under each other.
exec 9>"$TEST_LOG.lock"; flock 9
chmod 700 "$TEST_ESP" "$TEST_UKI_DIR"; chmod 755 "$TEST_ETC"; [[ -e $TEST_ETC/limine ]] && chmod 644 "$TEST_ETC/limine"
"$@"; rc=$?
chmod 000 "$TEST_UKI_DIR" "$TEST_ESP"; [[ -e $TEST_ETC/limine ]] && chmod 444 "$TEST_ETC/limine"; chmod 555 "$TEST_ETC"
exit $rc
SH
# The effective default cmdline: the drop-in's options plus anything pinned.
cat >"$stub_bin/limine-entry-tool" <<'SH'
#!/bin/bash
[[ ${ENTRY_TOOL_FAIL:-} == 1 ]] && exit 1
[[ $1 == --get-cmdline && $2 == default ]] || exit 2
pin=$(sed -n 's/^KERNEL_CMDLINE\[default\]+=" \(.*\)"$/\1/p' "$TEST_ETC/limine" 2>/dev/null | tr '\n' ' ')
echo "quiet splash ${pin}"
SH
cat >"$stub_bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
echo "limine-mkinitcpio" >>"$TEST_LOG"
[[ ${MKINITCPIO_FAIL:-} == 1 ]] && exit 1
[[ ${MKINITCPIO_SKIP:-} == 1 ]] && exit 0   # upstream maps a failed kernel build to success
cmdline=$(limine-entry-tool --get-cmdline default)
printf '/+Omarchy\n  cmdline: %s\n' "$cmdline" >"$TEST_ESP/limine.conf"
if [[ ${NO_CMDLINE:-} == 1 ]]; then
  : >"$TEST_UKI_DIR/omarchy_linux.efi"   # Secure Boot with Snapper: no .cmdline section
else
  printf '%s\0' "$cmdline" >"$TEST_UKI_DIR/omarchy_linux.efi"
fi
SH
cat >"$stub_bin/objcopy" <<'SH'
#!/bin/bash
for arg; do [[ $arg == *.efi ]] && cat "$arg"; done
exit 0
SH
cat >"$stub_bin/objdump" <<'SH'
#!/bin/bash
echo "  0 .linux        00000010  0000000000000000  0000000000000000  00000000  2**2"
for arg; do [[ $arg == *.efi && -s $arg ]] && echo "  1 .cmdline      00000010  0000000000000000  0000000000000000  00000000  2**2"; done
exit 0
SH
cat >"$stub_bin/findmnt" <<'SH'
#!/bin/bash
case "$*" in
  *SOURCE*) echo /dev/nvme0n1p2 ;;
  *UUID*) echo "${ROOT_UUID-1111-2222}" ;;
  *FSTYPE*) echo btrfs ;;
  *FSROOT*) echo /@ ;;
esac
SH
cat >"$stub_bin/lsblk" <<'SH'
#!/bin/bash
[[ ${LSBLK_FAIL:-} == 1 ]] && exit 1
printf '%s\n' ${ROOT_STACK:-part disk}
SH
chmod +x "$stub_bin"/*

export TEST_LOG="$test_dir/log" TEST_ESP="$test_dir/esp" TEST_ETC="$test_dir/etc" TEST_UKI_DIR="$test_dir/esp-uki"

# Fresh unpinned machine: limine.conf and a UKI built without root=.
reset_machine() {
  chmod -R u+rwX "$test_dir" 2>/dev/null || true
  rm -rf "$TEST_ESP" "$TEST_ETC" "$TEST_UKI_DIR" "$TEST_LOG"
  mkdir -p "$TEST_ESP" "$TEST_ETC" "$TEST_UKI_DIR"
  printf '/+Omarchy\n  cmdline: quiet splash\n' >"$TEST_ESP/limine.conf"
  printf 'quiet splash\0' >"$TEST_UKI_DIR/omarchy_linux.efi"
  printf 'TARGET_OS_NAME="Omarchy"\n' >"$TEST_ETC/limine"
  echo "${1:-BOOT_IMAGE=/vmlinuz quiet splash}" >"$test_dir/cmdline"
  : >"$TEST_LOG"
  chmod 444 "$TEST_ETC/limine"; chmod 555 "$TEST_ETC"; chmod 000 "$TEST_ESP" "$TEST_UKI_DIR"
}

run_migration() {
  PATH="$stub_bin:$PATH" \
    OMARCHY_LIMINE_CONF="$TEST_ESP/limine.conf" \
    OMARCHY_LIMINE_DEFAULT_CONF="$TEST_ETC/limine" \
    OMARCHY_LIMINE_UKI_DIR="$TEST_UKI_DIR" \
    OMARCHY_PROC_CMDLINE="$test_dir/cmdline" \
    bash -euo pipefail "$migration" >"$test_dir/out" 2>"$test_dir/err"
}

default_conf() { chmod 755 "$TEST_ETC"; chmod 644 "$TEST_ETC/limine"; cat "$TEST_ETC/limine"; chmod 444 "$TEST_ETC/limine"; chmod 555 "$TEST_ETC"; }
pins() { default_conf | grep -c '^KERNEL_CMDLINE\[default\]+=' || true; }
uki_cmdline() { chmod 700 "$TEST_UKI_DIR"; tr -d '\0' <"$TEST_UKI_DIR/omarchy_linux.efi"; chmod 000 "$TEST_UKI_DIR"; }
rebuilds() { grep -c '^limine-mkinitcpio$' "$TEST_LOG" || true; }

reset_machine
run_migration || fail "an unpinned machine behind a root-only ESP is repaired" "$(cat "$test_dir/err")"
default_conf | grep -Fx 'KERNEL_CMDLINE[default]+=" root=UUID=1111-2222 rw rootflags=subvol=@"' >/dev/null ||
  fail "an unpinned machine gets root= pinned in /etc/default/limine" "$(default_conf)"
uki_cmdline | grep -q 'root=UUID=1111-2222' || fail "an unpinned machine's UKI is rebuilt with root=" "$(uki_cmdline)"
: >"$TEST_LOG"
run_migration || fail "a second run on a repaired machine succeeds" "$(cat "$test_dir/err")"
[[ $(pins) == 1 && $(rebuilds) == 0 ]] || fail "a second run neither pins again nor rebuilds" "pins=$(pins) rebuilds=$(rebuilds)"
pass "an unpinned machine behind a root-only ESP is pinned and rebuilt, once"

reset_machine "BOOT_IMAGE=/vmlinuz root=PARTUUID=abcd rw rootflags=subvol=@ quiet"
run_migration || fail "a booted root= is copied" "$(cat "$test_dir/err")"
default_conf | grep -Fx 'KERNEL_CMDLINE[default]+=" root=PARTUUID=abcd rw rootflags=subvol=@"' >/dev/null ||
  fail "a booted root= is copied verbatim" "$(default_conf)"
pass "a booted root= (PARTUUID) is copied verbatim"

reset_machine
if SUDO_DENY=1 run_migration; then
  fail "a denied sudo prompt leaves the migration pending"
fi
[[ $(pins) == 0 ]] || fail "a denied sudo prompt leaves /etc/default/limine untouched"
pass "a denied sudo prompt leaves the migration pending and nothing written"

reset_machine
if ENTRY_TOOL_FAIL=1 run_migration; then
  fail "a failed limine-entry-tool leaves the migration pending"
fi
[[ $(pins) == 0 ]] || fail "a failed limine-entry-tool is not read as an unpinned cmdline"
pass "a failed limine-entry-tool stops without pinning"

reset_machine
if MKINITCPIO_FAIL=1 run_migration; then
  fail "a failed rebuild leaves the migration pending"
fi
grep -F "limine-mkinitcpio failed" "$test_dir/err" >/dev/null || fail "a failed rebuild says so" "$(cat "$test_dir/err")"
run_migration || fail "the next run retries a failed rebuild" "$(cat "$test_dir/err")"
[[ $(pins) == 1 ]] || fail "retrying a failed rebuild does not pin twice" "pins=$(pins)"
uki_cmdline | grep -q 'root=' || fail "retrying a failed rebuild produces a UKI with root=" "$(uki_cmdline)"
pass "a failed rebuild stays pending and the next run retries it without pinning twice"

reset_machine
if MKINITCPIO_SKIP=1 run_migration; then
  fail "a rebuild that leaves the UKI without root= keeps the migration pending"
fi
grep -F "root= is still missing" "$test_dir/err" >/dev/null || fail "an unrepaired UKI is reported" "$(cat "$test_dir/err")"
pass "a rebuild that exits 0 but leaves root= out of the boot entries stays pending"

reset_machine
if ROOT_STACK="crypt part disk" run_migration; then
  fail "dm-crypt root without unlock params keeps the migration pending"
fi
[[ $(pins) == 0 ]] || fail "dm-crypt root without unlock params is not pinned"
pass "a dm-crypt root without unlock params stays pending, unpinned"

reset_machine
if LSBLK_FAIL=1 run_migration; then
  fail "an lsblk failure keeps the migration pending"
fi
[[ $(pins) == 0 ]] || fail "an lsblk failure is not read as no crypt layer"
pass "an lsblk failure is not read as no crypt layer"

reset_machine
if ROOT_UUID="" run_migration; then
  fail "an unknown root UUID keeps the migration pending"
fi
pass "an unknown root UUID stays pending"

reset_machine
NO_CMDLINE=1 run_migration || fail "a UKI without an embedded cmdline boots limine.conf's root=" "$(cat "$test_dir/err")"
: >"$TEST_LOG"
NO_CMDLINE=1 run_migration || fail "a pinned machine whose UKIs carry no cmdline is healthy" "$(cat "$test_dir/err")"
[[ $(pins) == 1 && $(rebuilds) == 0 ]] || fail "a UKI without an embedded cmdline is not rebuilt again" "pins=$(pins) rebuilds=$(rebuilds)"
pass "UKIs built without an embedded cmdline (Secure Boot with Snapper) are checked through limine.conf"

reset_machine
chmod 700 "$TEST_ESP"; rm -f "$TEST_ESP/limine.conf"; chmod 000 "$TEST_ESP"
run_migration || fail "a machine without limine.conf is left alone" "$(cat "$test_dir/err")"
[[ $(pins) == 0 && $(rebuilds) == 0 ]] || fail "a machine without limine.conf is not touched"
pass "a machine without Limine is left alone"
