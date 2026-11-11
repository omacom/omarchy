#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/bin/omarchy-setup-dual-boot"

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
printf '%b\n' "${TEST_LSBLK:-}"
SH
cat >"$scratch/bin/gum" <<'SH'
#!/bin/bash
exit 0
SH
printf '#!/bin/bash\nexit 1\n' >"$scratch/bin/omarchy-hw-aarch64-apple"
chmod +x "$scratch/bin/"*

# The ESP spells the loader path its own way (a FAT tool wrote "efi" in lower
# case), while efibootmgr reports it in capitals.
esp="$scratch/esp"
mkdir -p "$esp/efi/Microsoft/Boot"
: >"$esp/efi/Microsoft/Boot/bootmgfw.efi"
lsblk_esp="/dev/nvme0n1p1 c12a7328-f81f-11d2-ba4b-00a0c93ec93b 1111-aaaa $esp"
windows_path='HD(1,GPT,1111-aaaa,0x800,0x32000)/\\\\EFI\\\\MICROSOFT\\\\BOOT\\\\BOOTMGFW.EFI'
windows_entry_line="Boot0000* Windows Boot Manager\t$windows_path"
limine='Boot0001* Limine\tHD(5,GPT,2222-bbbb,0x800,0x400000)/\\\\EFI\\\\limine\\\\limine_x64.efi'

menu() {
  local conf="$scratch/$1.conf"
  printf 'timeout: 1\nquiet: yes\ndefault_entry: 2\n\n/+Omarchy\ncomment: machine-id=abc\n//linux\n    protocol: efi\n    path: boot():/EFI/Linux/abc_linux.efi\n' >"$conf"
  [[ -z ${2:-} ]] || printf '\n%b\n' "$2" >>"$conf"
  printf '%s\n' "$conf"
}

run_setup() {
  local conf=$1 entries=$2
  OMARCHY_LIMINE_CONF=$conf TEST_EFI_ENTRIES=$entries TEST_LSBLK=$lsblk_esp \
    PATH="$scratch/bin:$ROOT/bin:$PATH" bash "$setup" 2>&1
}

windows_entries() { grep -c '^/Windows$' "$1" || true; }

# One active Windows Boot Manager in BootOrder: Limine hands Windows to the
# firmware, so the TPM never measures Limine for BitLocker.
conf=$(menu firmware)
entries="BootOrder: 0001,0000\nBoot0000* Windows Boot Manager\t$windows_path\n$limine"
output=$(run_setup "$conf" "$entries") || fail "dual-boot setup adds Windows" "$output"
grep -Fxq '    protocol: efi_boot_entry' "$conf" && grep -Fxq '    entry: Windows Boot Manager' "$conf" ||
  fail "a Windows Boot Manager in BootOrder gets an efi_boot_entry" "$(cat "$conf")"
grep -q 'bootmgfw' "$conf" && fail "the firmware entry needs no chainload" "$(cat "$conf")"
grep -Eqi '^quiet:' "$conf" && fail "the boot menu shows once Windows is in it" "$(cat "$conf")"
grep -Fxq 'timeout: 5' "$conf" || fail "the default one-second timeout grows so Windows can be picked" "$(cat "$conf")"
grep -Fxq '/+Omarchy' "$conf" || fail "Omarchy's own entry stays" "$(cat "$conf")"
pass "Windows starts through its firmware entry when BootOrder has exactly one"

output=$(run_setup "$conf" "$entries") || fail "dual-boot setup runs again" "$output"
(( $(windows_entries "$conf") == 1 )) || fail "running again adds no second Windows entry" "$(cat "$conf")"
pass "running dual-boot setup again changes nothing"

# Without a usable firmware entry (missing from BootOrder, or two of them for
# Limine to pick between), Windows is chainloaded from its ESP, spelled as it
# is on disk.
for order in "BootOrder: 0001" "BootOrder: 0001,0000,0002"; do
  conf=$(menu chainload)
  entries="$order\nBoot0000* Windows Boot Manager\t$windows_path\nBoot0002* Windows Boot Manager\t$windows_path\n$limine"
  output=$(run_setup "$conf" "$entries") || fail "dual-boot setup chainloads Windows ($order)" "$output"
  grep -Fxq '    path: guid(1111-aaaa):/efi/Microsoft/Boot/bootmgfw.efi' "$conf" ||
    fail "the chainload uses the loader's on-disk spelling ($order)" "$(cat "$conf")"
done
pass "Windows is chainloaded with the loader path spelled as on disk"

# The entry limine-scan writes copies efibootmgr's capitals, which Limine's
# case-sensitive FAT can't find.
scanned='/Windows Boot Manager\n    protocol: efi\n    path: guid(1111-aaaa):/EFI/MICROSOFT/BOOT/BOOTMGFW.EFI'
conf=$(menu scanned "$scanned")
output=$(run_setup "$conf" "BootOrder: 0001\n$limine") || fail "dual-boot setup fixes a scanned entry" "$output"
grep -Fxq '    path: guid(1111-aaaa):/efi/Microsoft/Boot/bootmgfw.efi' "$conf" ||
  fail "the scanned entry's path is respelled as on disk" "$(cat "$conf")"
(( $(grep -c 'bootmgfw' "$conf") == 1 )) || fail "the scanned entry is fixed, not duplicated" "$(cat "$conf")"
pass "a capitalised limine-scan entry is respelled as on disk"

# Once the firmware entry is usable, the chainload gives way to it.
conf=$(menu replaced "$scanned")
entries="BootOrder: 0000,0001\nBoot0000* Windows Boot Manager\t$windows_path\n$limine"
output=$(run_setup "$conf" "$entries") || fail "dual-boot setup replaces a chainload" "$output"
grep -qi 'bootmgfw' "$conf" && fail "the chainload is removed" "$(cat "$conf")"
grep -Fxq '    protocol: efi_boot_entry' "$conf" || fail "the firmware entry takes its place" "$(cat "$conf")"
grep -Fxq '/+Omarchy' "$conf" || fail "Omarchy's own entry stays when Windows' is replaced" "$(cat "$conf")"
pass "a chainloaded Windows moves to its firmware entry"

# The firmware entry takes the chainload's place in the menu, so a
# default_entry that counts past Windows still starts the same entry.
conf=$(menu inplace)
printf 'timeout: 5\ndefault_entry: 2\n\n%b\n\n/+Omarchy\n//linux\n    protocol: efi\n' "$scanned" >"$conf"
output=$(run_setup "$conf" "BootOrder: 0000,0001\n$windows_entry_line\n$limine") || fail "dual-boot setup replaces Windows in place" "$output"
[[ $(grep -m1 '^/' "$conf") == "/Windows" ]] || fail "Windows stays the first entry when it is replaced" "$(cat "$conf")"
pass "a replaced Windows entry keeps its place in the menu"

# A firmware entry that has left BootOrder (a firmware reset) can't be found by
# Limine, so it gives way to a chainload.
conf=$(menu stale '/Windows\n    protocol: efi_boot_entry\n    entry: Windows Boot Manager')
output=$(run_setup "$conf" "BootOrder: 0001\n$limine") || fail "dual-boot setup replaces a stale firmware entry" "$output"
grep -q 'efi_boot_entry' "$conf" && fail "a firmware entry missing from BootOrder is replaced" "$(cat "$conf")"
grep -Fxq '    path: guid(1111-aaaa):/efi/Microsoft/Boot/bootmgfw.efi' "$conf" || fail "the stale entry becomes a chainload" "$(cat "$conf")"
pass "a firmware entry Limine can't find gives way to a chainload"

# With two Windows ESPs, a spelling fix stays on the one the entry names.
second="$scratch/second-esp"
mkdir -p "$second/EFI/MICROSOFT/BOOT"
: >"$second/EFI/MICROSOFT/BOOT/BOOTMGFW.EFI"
conf=$(menu second '/Windows\n    protocol: efi\n    path: guid(5555-eeee):/EFI/Microsoft/Boot/bootmgfw.efi')
output=$(OMARCHY_LIMINE_CONF=$conf TEST_EFI_ENTRIES="BootOrder: 0001\n$limine" TEST_LSBLK="$lsblk_esp\n/dev/sda1 c12a7328-f81f-11d2-ba4b-00a0c93ec93b 5555-eeee $second" \
  PATH="$scratch/bin:$ROOT/bin:$PATH" bash "$setup" 2>&1) || fail "dual-boot setup fixes a second Windows" "$output"
grep -Fxq '    path: guid(5555-eeee):/EFI/MICROSOFT/BOOT/BOOTMGFW.EFI' "$conf" ||
  fail "the fix keeps the entry on its own ESP" "$(cat "$conf")"
pass "a spelling fix stays on the Windows the entry names"

# A group whose child starts Windows is not a Windows entry: its other
# children stay, and Windows gets an entry of its own.
group='/Other systems\n//Arch\n    protocol: linux\n    path: guid(7777):/vmlinuz-linux\n//Windows\n    protocol: efi\n    path: guid(1111-aaaa):/EFI/MICROSOFT/BOOT/BOOTMGFW.EFI'
conf=$(menu group "$group")
output=$(run_setup "$conf" "BootOrder: 0000,0001\n$windows_entry_line\n$limine") || fail "dual-boot setup leaves groups alone" "$output"
grep -Fxq '    path: guid(7777):/vmlinuz-linux' "$conf" && grep -Fxq '//Arch' "$conf" ||
  fail "a group's other children stay" "$(cat "$conf")"
grep -Fxq '    protocol: efi_boot_entry' "$conf" || fail "Windows gets an entry of its own next to the group" "$(cat "$conf")"
pass "a group with a Windows child is left as it is"
