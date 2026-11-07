#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

drop_in="$ROOT/etc/mkinitcpio.conf.d/zz-omarchy-t2-keyboard.conf"
filter_name=zz-omarchy-kernel-modules.conf
migration="$ROOT/migrations/1794052134.sh"
fix_t2="$ROOT/install/hardware/apple/fix-t2.sh"

[[ -f $drop_in ]] || fail "the T2 keyboard initramfs drop-in is shipped"
grep -Fq 't2bce_dma t2bce_core t2bce_vhci usbhid hid_apple hid_generic xhci_pci xhci_hcd' "$drop_in" ||
  fail "the T2 keyboard drop-in names the internal keyboard modules"
grep -Fq 'modinfo -k "${KERNELVERSION:-$(uname -r)}"' "$drop_in" ||
  fail "the T2 keyboard drop-in asks the kernel being built"
grep -Fq 'MODULES+=(t2bce_vhci usbhid hid_apple hid_generic xhci_pci xhci_hcd)' "$fix_t2" ||
  fail "T2 setup still requests the internal keyboard modules"
mapfile -t sorted < <(printf '%s\n' "$filter_name" zz-omarchy-t2-keyboard.conf | LC_ALL=C.UTF-8 sort -V)
[[ ${sorted[0]} == "$filter_name" && ${sorted[1]} == zz-omarchy-t2-keyboard.conf ]] ||
  fail "the T2 keyboard drop-in sorts after the installer filter" "${sorted[*]}"
pass "the T2 keyboard drop-in is positioned after the installer filter"

# Byte-for-byte the drop-in _drop_initramfs_modules_the_kernel_lacks() writes
# when linux-omarchy has no t2bce_vhci and linux-t2 does.
installer_filter() {
  cat <<'CONF'
# Written by the Omarchy installer. The installed kernel has no such
# modules, and mkinitcpio fails on a module it cannot find.
_omarchy_absent=(t2bce_vhci thunderbolt)
_omarchy_kept=()
for _omarchy_module in "${MODULES[@]}"; do
  [[ " ${_omarchy_absent[*]} " == *" $_omarchy_module "* ]] || _omarchy_kept+=("$_omarchy_module")
done
MODULES=("${_omarchy_kept[@]}")
unset _omarchy_absent _omarchy_kept _omarchy_module
CONF
}

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
mkdir -p "$stub_bin"
: >"$calls"

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
"$@"
SH

cat >"$stub_bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
echo 'limine-mkinitcpio' >>"$TEST_LOG"
exit "${LIMINE_MKINITCPIO_STATUS:-0}"
SH

cat >"$stub_bin/lsinitcpio" <<'SH'
#!/bin/bash
if (( ${T2_UKI_HAS_MODULE:-0} == 1 )); then
  echo 'usr/lib/modules/test/kernel/drivers/staging/t2bce/t2bce_vhci/t2bce_vhci.ko.zst'
fi
SH

cat >"$stub_bin/modinfo" <<'SH'
#!/bin/bash
[[ $1 == -k && $3 == -F && $4 == filename ]] || exit 1
if [[ " ${KERNEL_MODULES-} " == *" $5 "* ]]; then
  printf '/usr/lib/modules/%s/kernel/%s.ko.zst\n' "$2" "$5"
else
  exit 1
fi
SH

chmod +x "$stub_bin"/*

filter="$test_tmp/$filter_name"
marker="$test_tmp/marker"
boot="$test_tmp/boot"
mkdir -p "$boot"

run_migration() {
  PATH="$stub_bin:$ROOT/bin:$PATH" \
    TEST_LOG="$calls" \
    OMARCHY_INITRAMFS_MODULES_CONF="$filter" \
    OMARCHY_T2_KEYBOARD_INITRAMFS_MARKER="$marker" \
    OMARCHY_T2_BOOT_IMAGES="$boot" \
    LIMINE_MKINITCPIO_STATUS="${LIMINE_MKINITCPIO_STATUS:-0}" \
    T2_UKI_HAS_MODULE="${T2_UKI_HAS_MODULE:-0}" \
    bash -euo pipefail "$migration"
}

sourced_modules() {
  local modules=$1
  PATH="$stub_bin:$PATH" KERNEL_MODULES="$modules" KERNELVERSION=6.99.0-test \
    bash -euo pipefail -c '
      MODULES=(t2bce_vhci usbhid hid_apple hid_generic xhci_pci xhci_hcd thunderbolt)
      source "$1"
      printf "%s\n" "${MODULES[*]}"
    ' -- "$filter"
}

installer_filter >"$filter"
: >"$calls"
if LIMINE_MKINITCPIO_STATUS=1 run_migration >/dev/null; then
  fail "a failed boot image rebuild stays pending"
fi
[[ ! -e $marker ]] || fail "a failed boot image rebuild writes no completion marker"
grep -Fq 'modinfo -k "${KERNELVERSION:-$(uname -r)}"' "$filter" ||
  fail "the installer filter is rewritten before the rebuild is attempted"
grep -Fqx 'limine-mkinitcpio' "$calls" || fail "the rebuild was attempted"
pass "a failed boot image rebuild stays pending"

: >"$calls"
: >"$boot/omarchy_linux-t2.efi"
if T2_UKI_HAS_MODULE=0 run_migration >"$test_tmp/out" 2>"$test_tmp/err"; then
  fail "a linux-t2 image without t2bce_vhci stays pending"
fi
[[ ! -e $marker ]] || fail "a linux-t2 image without t2bce_vhci writes no completion marker"
grep -Fq 'still has no t2bce_vhci' "$test_tmp/err" ||
  fail "a linux-t2 image without t2bce_vhci reports that" "$(<"$test_tmp/err")"
pass "a linux-t2 image without t2bce_vhci stays pending"

: >"$calls"
T2_UKI_HAS_MODULE=1 run_migration >"$test_tmp/out"
[[ -f $marker ]] || fail "a repaired linux-t2 image records the machine-wide rebuild"
grep -Fqx 'limine-mkinitcpio' "$calls" || fail "the pending rebuild runs"
# The rewritten filter keeps each absent module only for a kernel that ships it.
[[ $(sourced_modules "t2bce_vhci thunderbolt usbhid hid_apple hid_generic xhci_pci xhci_hcd") == \
  "t2bce_vhci usbhid hid_apple hid_generic xhci_pci xhci_hcd thunderbolt" ]] ||
  fail "the rewritten filter keeps t2bce_vhci on linux-t2"
[[ $(sourced_modules "thunderbolt usbhid hid_apple hid_generic xhci_pci xhci_hcd") == \
  "usbhid hid_apple hid_generic xhci_pci xhci_hcd thunderbolt" ]] ||
  fail "the rewritten filter still omits t2bce_vhci from a kernel that lacks it"
[[ $(sourced_modules "t2bce_vhci usbhid hid_apple hid_generic xhci_pci xhci_hcd") == \
  "t2bce_vhci usbhid hid_apple hid_generic xhci_pci xhci_hcd" ]] ||
  fail "the rewritten filter still omits thunderbolt from a kernel that lacks it"
[[ $(sourced_modules "usbhid hid_apple hid_generic xhci_pci xhci_hcd") == \
  "usbhid hid_apple hid_generic xhci_pci xhci_hcd" ]] ||
  fail "the rewritten filter omits both modules when the kernel has neither"
pass "the rewritten filter keeps t2bce_vhci for the kernel that ships it"

kept=$(<"$filter")
: >"$calls"
run_migration >"$test_tmp/out"
[[ $(<"$filter") == "$kept" ]] || fail "a second run leaves the rewritten filter alone"
[[ ! -s $calls ]] || fail "a second run does not rebuild again" "$(<"$calls")"
pass "the T2 keyboard initramfs repair is machine-idempotent"

rm -f "$marker" "$boot"/*.efi
printf '%s\n' '# edited by hand' '_omarchy_absent=(t2bce_vhci)' >"$filter"
custom=$(<"$filter")
: >"$calls"
run_migration >"$test_tmp/out"
[[ $(<"$filter") == "$custom" ]] || fail "a hand-edited installer filter is left in place"
[[ -f $marker ]] || fail "a hand-edited filter still records the rebuild"
grep -Fqx 'limine-mkinitcpio' "$calls" || fail "a hand-edited filter still rebuilds once"
pass "a hand-edited installer filter is left in place"

rm -f "$marker"
installer_filter | sed 's/t2bce_vhci thunderbolt/thunderbolt/' >"$filter"
: >"$calls"
run_migration >"$test_tmp/out"
[[ ! -e $marker ]] || fail "a filter that does not name t2bce_vhci is not a T2 repair"
[[ ! -s $calls ]] || fail "a filter that does not name t2bce_vhci does not rebuild" "$(<"$calls")"
if grep -Fq 'modinfo' "$filter"; then
  fail "a thunderbolt-only filter is left unconditional"
fi
pass "a filter that does not name t2bce_vhci is left alone"
