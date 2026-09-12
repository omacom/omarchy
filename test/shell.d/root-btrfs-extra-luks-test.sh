#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

helper="$ROOT/bin/omarchy-root-btrfs-extra-luks"
analyze_logs="$ROOT/bin/omarchy-update-analyze-logs"
hooks="$ROOT/etc/mkinitcpio.conf.d/omarchy_hooks.conf"

[[ -x $helper ]] || fail "extra-LUKS helper exists" "missing $helper"
pass "extra-LUKS helper exists"

grep -q 'omarchy-root-btrfs-extra-luks' "$analyze_logs" ||
  fail "update-analyze-logs calls the extra-LUKS helper"
pass "update-analyze-logs calls the extra-LUKS helper"

grep -q 'omarchy-root-btrfs-extra-luks || true' "$analyze_logs" ||
  fail "update-analyze-logs does not block reboot on extra LUKS"
pass "update-analyze-logs does not block reboot on extra LUKS"

grep -q 'encrypt' "$hooks" || fail "HOOKS still uses classic encrypt"
grep -q 'sd-encrypt' "$hooks" && fail "HOOKS must not switch to sd-encrypt"
pass "HOOKS line still uses classic encrypt"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

write_stub() {
  local name="$1"
  local body="$2"

  cat >"$stub_bin/$name" <<SH
#!/bin/bash
$body
SH
  chmod +x "$stub_bin/$name"
}

run_helper() {
  PATH="$stub_bin:$ROOT/bin:$PATH" \
    "$helper" >"$test_tmp/out" 2>"$test_tmp/err"
}

write_stub findmnt '
case " $* " in
  *" FSTYPE "*) printf "%s\n" "${TEST_FSTYPE:-btrfs}" ;;
  *" SOURCE "*) printf "%s\n" "${TEST_SOURCE:-/dev/mapper/root}" ;;
  *) exit 1 ;;
esac
'

write_stub btrfs '
if [[ ${1:-} == "filesystem" && ${2:-} == "show" ]]; then
  printf "%s\n" "$TEST_BTRFS_SHOW"
  exit 0
fi
exit 1
'

write_stub lsblk '
device=${*: -1}
case $device in
  /dev/mapper/root|/dev/dm-0)
    printf "/dev/mapper/root btrfs\n"
    printf "/dev/nvme0n1p2 crypto_LUKS\n"
    ;;
  /dev/mapper/extra)
    printf "/dev/mapper/extra btrfs\n"
    printf "/dev/loop1 crypto_LUKS\n"
    ;;
  /dev/sdb)
    printf "/dev/sdb btrfs\n"
    ;;
  *)
    exit 1
    ;;
esac
'

two_device_show=$'Label: none  uuid: 00000000-0000-0000-0000-000000000000\n        Total devices 2 FS bytes used 1.00GiB\n        devid    1 size 10.00GiB used 2.00GiB path /dev/mapper/root\n        devid    2 size 10.00GiB used 0.00GiB path /dev/mapper/extra'

single_device_show=$'Label: none  uuid: 00000000-0000-0000-0000-000000000000\n        Total devices 1 FS bytes used 1.00GiB\n        devid    1 size 10.00GiB used 2.00GiB path /dev/mapper/root'

plain_extra_show=$'Label: none  uuid: 00000000-0000-0000-0000-000000000000\n        Total devices 2 FS bytes used 1.00GiB\n        devid    1 size 10.00GiB used 2.00GiB path /dev/mapper/root\n        devid    2 size 10.00GiB used 0.00GiB path /dev/sdb'

set +e
TEST_BTRFS_SHOW="$two_device_show" run_helper
status=$?
set -e
(( status == 1 )) || fail "two-device extra LUKS exits 1" "status=$status"
[[ -z $(<"$test_tmp/out") ]] || fail "two-device extra LUKS is silent on stdout"
grep -q "root Btrfs spans extra LUKS devices" "$test_tmp/err" ||
  fail "two-device extra LUKS prints a warning" "$(<"$test_tmp/err")"
pass "two-device extra LUKS warns and exits 1"

set +e
TEST_BTRFS_SHOW="$single_device_show" run_helper
status=$?
set -e
(( status == 0 )) || fail "single-device root is silent" "status=$status"
[[ -z $(<"$test_tmp/out") && -z $(<"$test_tmp/err") ]] ||
  fail "single-device root emits nothing" "out=$(<"$test_tmp/out") err=$(<"$test_tmp/err")"
pass "single-device root is silent"

set +e
TEST_BTRFS_SHOW="$plain_extra_show" run_helper
status=$?
set -e
(( status == 0 )) || fail "plain extra member is silent" "status=$status"
[[ -z $(<"$test_tmp/out") && -z $(<"$test_tmp/err") ]] ||
  fail "plain extra member emits nothing"
pass "plain extra member is silent"

missing_bin="$test_tmp/missing"
mkdir -p "$missing_bin"
set +e
PATH="$missing_bin:$ROOT/bin" "$helper" >"$test_tmp/out" 2>"$test_tmp/err"
status=$?
set -e
(( status == 0 )) || fail "missing btrfs is fail-open" "status=$status"
[[ -z $(<"$test_tmp/out") && -z $(<"$test_tmp/err") ]] ||
  fail "missing btrfs stays silent"
pass "missing btrfs is fail-open and silent"

set +e
TEST_FSTYPE=ext4 TEST_BTRFS_SHOW="$two_device_show" run_helper
status=$?
set -e
(( status == 0 )) || fail "non-btrfs root is silent" "status=$status"
pass "non-btrfs root is silent"

# findmnt SOURCE can be /dev/dm-N while `btrfs filesystem show` prints the
# mapper name; both still sit on the same crypto_LUKS ancestor.
same_luks_aliased_show=$'Label: none  uuid: 00000000-0000-0000-0000-000000000000\n        Total devices 2 FS bytes used 1.00GiB\n        devid    1 size 10.00GiB used 2.00GiB path /dev/mapper/root\n        devid    2 size 10.00GiB used 0.00GiB path /dev/sdb'
set +e
TEST_SOURCE=/dev/dm-0 TEST_BTRFS_SHOW="$same_luks_aliased_show" run_helper
status=$?
set -e
(( status == 0 )) || fail "same-LUKS mapper alias is silent" "status=$status"
[[ -z $(<"$test_tmp/out") && -z $(<"$test_tmp/err") ]] ||
  fail "same-LUKS mapper alias emits nothing"
pass "same-LUKS mapper alias is silent"

set +e
TEST_SOURCE=/dev/dm-0 TEST_BTRFS_SHOW="$two_device_show" run_helper
status=$?
set -e
(( status == 1 )) || fail "aliased root still warns on extra LUKS" "status=$status"
grep -q "root Btrfs spans extra LUKS devices" "$test_tmp/err" ||
  fail "aliased root still prints the extra-LUKS warning"
pass "aliased root still warns on extra LUKS"
