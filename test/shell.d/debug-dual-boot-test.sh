#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

check="$ROOT/bin/omarchy-debug-dual-boot"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"

cat >"$scratch/bin/sudo" <<'SH'
#!/bin/bash
"$@"
SH
cat >"$scratch/bin/efibootmgr" <<'SH'
#!/bin/bash
printf '%b\n' "$TEST_EFI_ENTRIES"
SH
cat >"$scratch/bin/lsblk" <<'SH'
#!/bin/bash
cat "$TEST_LSBLK"
SH
cat >"$scratch/bin/timedatectl" <<'SH'
#!/bin/bash
echo "${TEST_LOCAL_RTC:-no}"
SH
printf '#!/bin/bash\nexit 1\n' >"$scratch/bin/omarchy-hw-aarch64"
chmod +x "$scratch/bin/"*

# A Windows ESP that also holds Omarchy, with Limine as its fallback loader,
# and a Windows system partition.
esp="$scratch/esp"
windows="$scratch/windows"
mkdir -p "$esp/EFI/Microsoft/Boot" "$esp/EFI/BOOT" "$windows/Windows/System32"
: >"$esp/EFI/Microsoft/Boot/bootmgfw.efi"
echo "Limine bootloader" >"$esp/EFI/BOOT/BOOTX64.EFI"
lsblk_json() {
  local extra=""
  [[ ${2:-} == "bitlocker" ]] && extra=',
  {"path": "/dev/nvme0n1p4", "fstype": "BitLocker", "parttype": "ebd0a0a2-b9e5-4433-87c0-68b6b72699c7", "partuuid": "4444-dddd", "mountpoint": null}'
  cat >"$scratch/lsblk.json" <<JSON
{"blockdevices": [{"path": "/dev/nvme0n1", "fstype": null, "parttype": null, "partuuid": null, "mountpoint": null, "children": [
  {"path": "/dev/nvme0n1p1", "fstype": "vfat", "parttype": "c12a7328-f81f-11d2-ba4b-00a0c93ec93b", "partuuid": "1111-aaaa", "mountpoint": "$esp"},
  {"path": "/dev/nvme0n1p3", "fstype": "ntfs", "parttype": "ebd0a0a2-b9e5-4433-87c0-68b6b72699c7", "partuuid": "3333-cccc", "mountpoint": "$1"}$extra
]}]}
JSON
}
lsblk_json "$windows"
windows_entry='Boot0000* Windows Boot Manager\tHD(1,GPT,1111-aaaa)/\\\\EFI\\\\MICROSOFT\\\\BOOT\\\\BOOTMGFW.EFI'
limine_entry='Boot0001* Limine\tHD(1,GPT,1111-aaaa)/\\\\EFI\\\\limine\\\\limine_x64.efi'
menu_head='timeout: 5\n\n/+Omarchy\n//linux\n    protocol: efi\n    path: boot():/EFI/Linux/abc_linux.efi\n\n'
firmware_menu="$menu_head/Windows\n    protocol: efi_boot_entry\n    entry: Windows Boot Manager\n"

run_check() {
  OMARCHY_LIMINE_CONF="$esp/limine.conf" OMARCHY_SECURE_BOOT_VAR="$scratch/no-secure-boot" TEST_LSBLK="$scratch/lsblk.json" \
    PATH="$scratch/bin:$ROOT/bin:$PATH" bash "$check" 2>&1
}

# A setup that starts both systems cleanly reports nothing.
printf "$firmware_menu" >"$esp/limine.conf"
output=$(TEST_LOCAL_RTC=yes TEST_EFI_ENTRIES="BootOrder: 0001,0000\n$windows_entry\n$limine_entry" run_check) ||
  fail "the dual-boot check runs" "$output"
[[ $output == *"Nothing to look at."* && $output != *"✗"* ]] || fail "a clean dual boot has nothing to look at" "$output"
pass "a clean dual boot has nothing to look at"

# An inactive Windows entry first in BootOrder is skipped by firmware, so Limine still starts first.
inactive_windows_entry='Boot0002 Windows Boot Manager\tHD(1,GPT,1111-aaaa)/\\\\EFI\\\\MICROSOFT\\\\BOOT\\\\BOOTMGFW.EFI'
output=$(TEST_LOCAL_RTC=yes TEST_EFI_ENTRIES="BootOrder: 0002,0001\n$inactive_windows_entry\n$limine_entry" run_check) ||
  fail "the dual-boot check runs with an inactive Windows entry first" "$output"
[[ $output == *"The firmware starts Limine first."* && $output != *"The firmware starts Windows first"* && $output == *"Nothing to look at."* && $output != *"✗"* ]] ||
  fail "an inactive Windows entry first in BootOrder is skipped" "$output"
pass "an inactive Windows entry first in BootOrder is skipped"

# A Windows entry grouped under a submenu heading is still recognized.
printf "${menu_head}/+Other systems\n//Windows\n    protocol: efi_boot_entry\n    entry: Windows Boot Manager\n" >"$esp/limine.conf"
output=$(TEST_LOCAL_RTC=yes TEST_EFI_ENTRIES="BootOrder: 0001,0000\n$windows_entry\n$limine_entry" run_check) ||
  fail "the dual-boot check runs on a grouped Windows entry" "$output"
[[ $output == *"Nothing to look at."* && $output != *"✗"* ]] || fail "a grouped //Windows entry is recognized as valid" "$output"
pass "a grouped //Windows entry is recognized as valid"

# Each thing that breaks the other system's start is reported with its fix.
# The loader's capitals differ from the ESP's names only in case, which FAT
# would find but Limine doesn't, so the names are compared, not looked up.
printf 'timeout: 1\nquiet: yes\n\n/+Omarchy\n//linux\n    protocol: efi\n\n/Windows Boot Manager\n    protocol: efi\n    path: guid(1111-aaaa):/EFI/MICROSOFT/BOOT/BOOTMGFW.EFI\n' >"$esp/limine.conf"
printf 'HIBR\0\0\0\0' >"$windows/hiberfil.sys"
echo "Windows Boot Manager" >"$esp/EFI/BOOT/BOOTX64.EFI"
lsblk_json "$windows" bitlocker
output=$(TEST_EFI_ENTRIES="BootOrder: 0000,0001\n$windows_entry\n$limine_entry" run_check) ||
  fail "the dual-boot check runs on a broken setup" "$output"
for expected in \
  "The firmware starts Windows first" \
  "The boot menu is hidden" \
  "isn't spelled that way on disk" \
  "Windows is chainloaded, so BitLocker asks" \
  "fallback loader (EFI/BOOT/BOOTX64.EFI) isn't Limine" \
  "is hibernated (Fast Startup)" \
  "6 to look at."; do
  [[ $output == *"$expected"* ]] || fail "the dual-boot check reports: $expected" "$output"
done
[[ $output != *"Setup > Dual Boot"* && $output != *"command not found"* ]] ||
  fail "without omarchy-setup-dual-boot, standalone repair steps are given instead of Setup > Dual Boot" "$output"
for expected in \
  "Remove quiet: yes (or set quiet: no) and raise timeout: in $esp/limine.conf" \
  "Fix the path: casing in $esp/limine.conf" \
  "Change the Windows entry in $esp/limine.conf"; do
  [[ $output == *"$expected"* ]] || fail "standalone repair step is given: $expected" "$output"
done
[[ $output == *"· Omarchy keeps the hardware clock in UTC"* ]] || fail "the clock is advice, since Windows' setting can't be read" "$output"
printf '#!/bin/bash\nexit 0\n' >"$scratch/bin/omarchy-setup-dual-boot"
chmod +x "$scratch/bin/omarchy-setup-dual-boot"
wizard_output=$(TEST_EFI_ENTRIES="BootOrder: 0000,0001\n$windows_entry\n$limine_entry" run_check) ||
  fail "the dual-boot check runs with omarchy-setup-dual-boot present" "$wizard_output"
rm "$scratch/bin/omarchy-setup-dual-boot"
[[ $wizard_output == *"Run Setup > Dual Boot to show it on every boot."* ]] ||
  fail "with omarchy-setup-dual-boot present, Setup > Dual Boot is suggested" "$wizard_output"
pass "the dual-boot check reports each problem with a step to take"
rm "$windows/hiberfil.sys"
echo "Limine bootloader" >"$esp/EFI/BOOT/BOOTX64.EFI"
lsblk_json "$windows"

# A chainloaded Windows entry without BitLocker reports advice as a note rather than a problem.
printf "${menu_head}/Windows\n    protocol: efi\n    path: guid(1111-aaaa):/EFI/Microsoft/Boot/bootmgfw.efi\n" >"$esp/limine.conf"
output=$(TEST_LOCAL_RTC=yes TEST_EFI_ENTRIES="BootOrder: 0001,0000\n$windows_entry\n$limine_entry" run_check) ||
  fail "the dual-boot check runs on a chainloaded setup without BitLocker" "$output"
[[ $output == *"Nothing to look at."* && $output != *"✗"* && $output == *"  · Windows is chainloaded (no BitLocker detected)"* ]] ||
  fail "a chainloaded setup without BitLocker reports a note rather than a problem" "$output"
pass "a chainloaded setup without BitLocker reports a note rather than a problem"

# Entries that name something no longer there: a firmware entry gone from
# BootOrder, and a partition that holds no Windows loader any more.
printf "$firmware_menu" >"$esp/limine.conf"
output=$(TEST_LOCAL_RTC=yes TEST_EFI_ENTRIES="BootOrder: 0001\n$limine_entry" run_check) || fail "the dual-boot check runs on a stale firmware entry" "$output"
[[ $output == *"BootOrder has 0 of them"* ]] || fail "a firmware entry missing from BootOrder is reported" "$output"
printf "${menu_head}/Windows\n    protocol: efi\n    path: guid(9999-dead):/EFI/Microsoft/Boot/bootmgfw.efi\n" >"$esp/limine.conf"
output=$(TEST_LOCAL_RTC=yes TEST_EFI_ENTRIES="BootOrder: 0001\n$limine_entry" run_check) || fail "the dual-boot check runs on a stale partition" "$output"
[[ $output == *"points at partition 9999-dead, which holds no Windows loader"* ]] || fail "a chainload to a missing partition is reported" "$output"
pass "entries that name a missing firmware entry or partition are reported"

# A chainload through boot() names the ESP Limine started from, and an NTFS
# partition that can't be mounted is said to be unchecked, not left out.
printf "${menu_head}/Windows\n    protocol: efi\n    path: boot():/EFI/Microsoft/Boot/bootmgfw.efi\n" >"$esp/limine.conf"
cat >"$scratch/lsblk.json" <<JSON
{"blockdevices": [
  {"path": "/dev/nvme0n1p1", "fstype": "vfat", "parttype": "c12a7328-f81f-11d2-ba4b-00a0c93ec93b", "partuuid": "1111-aaaa", "mountpoint": "$esp"},
  {"path": "/dev/omarchy-test-missing", "fstype": "ntfs", "parttype": "ebd0a0a2-b9e5-4433-87c0-68b6b72699c7", "partuuid": "3333-cccc", "mountpoint": null}
]}
JSON
output=$(TEST_LOCAL_RTC=yes TEST_EFI_ENTRIES="BootOrder: 0001\n$limine_entry" run_check) || fail "the dual-boot check runs on a boot() entry" "$output"
[[ $output != *"holds no Windows loader"* && $output != *"isn't spelled"* ]] || fail "a boot() chainload is checked on Limine's own ESP" "$output"
[[ $output == *"/dev/omarchy-test-missing is NTFS but couldn't be mounted"* ]] || fail "an unmountable NTFS partition is said to be unchecked" "$output"
pass "boot() chainloads and unmountable NTFS partitions are reported as they are"

# An ESP that can't be mounted is noted as unchecked rather than treated as
# holding no Windows loader when a chainload entry points to its PARTUUID.
printf "${menu_head}/Windows\n    protocol: efi\n    path: guid(2222-bbbb):/EFI/Microsoft/Boot/bootmgfw.efi\n" >"$esp/limine.conf"
cat >"$scratch/lsblk.json" <<JSON
{"blockdevices": [
  {"path": "/dev/nvme0n1p1", "fstype": "vfat", "parttype": "c12a7328-f81f-11d2-ba4b-00a0c93ec93b", "partuuid": "1111-aaaa", "mountpoint": "$esp"},
  {"path": "/dev/omarchy-test-esp", "fstype": "vfat", "parttype": "c12a7328-f81f-11d2-ba4b-00a0c93ec93b", "partuuid": "2222-bbbb", "mountpoint": null},
  {"path": "/dev/nvme0n1p3", "fstype": "ntfs", "parttype": "ebd0a0a2-b9e5-4433-87c0-68b6b72699c7", "partuuid": "3333-cccc", "mountpoint": "$windows"}
]}
JSON
output=$(TEST_LOCAL_RTC=yes TEST_EFI_ENTRIES="BootOrder: 0001\n$limine_entry" run_check) || fail "the dual-boot check runs on an unmountable ESP" "$output"
[[ $output != *"holds no Windows loader"* && $output != *"✗"* ]] || fail "an unmountable ESP is not reported as holding no Windows loader" "$output"
[[ $output == *"/dev/omarchy-test-esp is an EFI System Partition but couldn't be mounted"* ]] || fail "an unmountable ESP is noted as unchecked" "$output"
[[ $output == *"points at partition 2222-bbbb (/dev/omarchy-test-esp), which couldn't be mounted read-only, so its loader wasn't checked."* ]] ||
  fail "a chainload to an unmountable ESP is noted as unchecked" "$output"
pass "unmountable ESPs are noted as unchecked rather than missing a loader"

# An NTFS data drive on a machine with nothing but Omarchy isn't Windows.
mkdir -p "$scratch/data" "$scratch/omarchy-only/EFI/limine"
printf '{"blockdevices": [{"path": "/dev/sda1", "fstype": "vfat", "parttype": "c12a7328-f81f-11d2-ba4b-00a0c93ec93b", "partuuid": "4444", "mountpoint": "%s/omarchy-only"}, {"path": "/dev/sdb1", "fstype": "ntfs", "parttype": "ebd0a0a2-b9e5-4433-87c0-68b6b72699c7", "partuuid": "5555", "mountpoint": "%s/data"}]}\n' "$scratch" "$scratch" >"$scratch/lsblk.json"
output=$(TEST_EFI_ENTRIES="BootOrder: 0001\n$limine_entry" run_check) || fail "the dual-boot check runs without Windows" "$output"
[[ $output == *"No Windows installation found"* && $output != *"✗"* ]] || fail "a machine with an NTFS data drive has nothing to check" "$output"
pass "an NTFS data drive alone isn't taken for Windows"
