#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
conf="$test_tmp/etc/mkinitcpio.conf.d/surface_device_modules.conf"
mkdir -p "$stub_bin" "$test_tmp/dmi"
printf 'Surface Laptop 3\n' >"$test_tmp/dmi/product_name"

cat >"$stub_bin/omarchy-hw-surface" <<'SH'
#!/bin/bash

[[ $SURFACE_DEVICE == "yes" ]]
SH

cat >"$stub_bin/lsmod" <<'SH'
#!/bin/bash

printf 'Module                  Size  Used by\n'
if [[ $SURFACE_PINCTRL == "yes" ]]; then
  printf 'pinctrl_icelake         32768  0\n'
fi
printf 'surface_aggregator      90112  6 surface_hid,surface_kbd\n'
printf '8250_dw                24576  0\n'
SH
chmod +x "$stub_bin"/*

# Redirect the setup leaf's system paths into the fixture.
sed -e "s|/sys/class/dmi/id/product_name|$test_tmp/dmi/product_name|g" \
    -e "s|/etc/mkinitcpio.conf.d|$test_tmp/etc/mkinitcpio.conf.d|g" \
    "$ROOT/install/hardware/fix-surface-keyboard.sh" >"$test_tmp/leaf.sh"

run_leaf() {
  SURFACE_DEVICE="$1" SURFACE_PINCTRL="$2" PATH="$stub_bin:$PATH" \
    bash -euo pipefail "$test_tmp/leaf.sh" >/dev/null
}

run_leaf no yes
[[ ! -e $conf ]] || fail "non-Surface hardware gets no Surface initramfs config"
pass "non-Surface hardware gets no Surface initramfs config"

run_leaf yes yes
[[ -f $conf ]] || fail "Intel Surface setup writes its initramfs modules"
intel_modules=$(bash -euo pipefail -c 'source "$1"; printf "%s\n" "${MODULES[*]}"' bash "$conf")
[[ $intel_modules == "pinctrl_icelake surface_aggregator surface_aggregator_registry surface_aggregator_hub surface_hid_core surface_hid surface_kbd intel_lpss_pci 8250_dw" ]] ||
  fail "Intel Surface setup keeps the detected pinctrl and LPSS modules" "$intel_modules"
pass "Intel Surface setup keeps the detected pinctrl and LPSS modules"

intel_preserved=$(bash -euo pipefail -c 'MODULES=(existing_module); source "$1"; printf "%s\n" "${MODULES[*]}"' bash "$conf")
[[ $intel_preserved == "existing_module $intel_modules" ]] ||
  fail "the pinctrl branch keeps previously configured initramfs modules" "$intel_preserved"
pass "the pinctrl branch keeps previously configured initramfs modules"

rm -f "$conf"
run_leaf yes no
[[ -f $conf ]] || fail "Surface setup writes initramfs modules without pinctrl"

# Module list from the working AMD Surface workaround in #11128.
expected=(surface_aggregator surface_aggregator_registry surface_aggregator_hub surface_hid_core surface_hid surface_kbd hid_multitouch 8250_dw)
amd_modules=$(bash -euo pipefail -c 'source "$1"; printf "%s\n" "${MODULES[*]}"' bash "$conf")
[[ $amd_modules == "${expected[*]}" ]] ||
  fail "AMD Surface initramfs includes the aggregator, HID and UART modules" "$amd_modules"
pass "AMD Surface initramfs includes the aggregator, HID and UART modules"

preserved=$(bash -euo pipefail -c 'MODULES=(existing_module); source "$1"; printf "%s\n" "${MODULES[*]}"' bash "$conf")
[[ $preserved == "existing_module ${expected[*]}" ]] ||
  fail "the fallback keeps previously configured initramfs modules" "$preserved"
pass "the fallback keeps previously configured initramfs modules"
