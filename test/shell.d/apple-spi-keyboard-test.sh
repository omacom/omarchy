#!/bin/bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"
fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT

run_case() (
  local model=$1 vendor=$2
  rm -f "$fixture/packages" "$fixture/modules"
  cat() {
    case "$1" in
      /sys/class/dmi/id/product_name) printf '%s\n' "$model" ;;
      /sys/class/dmi/id/sys_vendor) printf '%s\n' "$vendor" ;;
      *) return 1 ;;
    esac
  }
  omarchy-pkg-add() { printf '%s\n' "$@" >>"$fixture/packages"; }
  sudo() {
    case "$*" in
      'mkdir -p /etc/mkinitcpio.conf.d') : ;;
      'tee /etc/mkinitcpio.conf.d/macbook_spi_modules.conf') /usr/bin/tee "$fixture/modules" ;;
      *) return 1 ;;
    esac
  }
  source "$ROOT/install/hardware/apple/fix-spi-keyboard.sh"
)

for model in MacBookPro13,2 MacBookPro13,3 MacBookPro14,2 MacBookPro14,3; do
  run_case "$model" 'Apple Inc.'
  [[ ! -e $fixture/packages ]] || fail "$model avoids the obsolete SPI DKMS package"
  grep -qxF 'MODULES=(applespi intel_lpss_pci spi_pxa2xx_platform)' "$fixture/modules" ||
    fail "$model retains early keyboard modules"
done
pass "all four T1 models use stock SPI modules without legacy DKMS"

run_case MacBook8,1 'Apple Inc.'
grep -qxF macbook12-spi-driver-dkms "$fixture/packages" || fail "older MacBooks retain their driver setup"
grep -qxF 'MODULES=(applespi spi_pxa2xx_platform spi_pxa2xx_pci)' "$fixture/modules" || fail "older MacBook module selection"
run_case MacBookPro13,3 'Other vendor'
grep -qxF macbook12-spi-driver-dkms "$fixture/packages" || fail "stock T1 selection requires Apple vendor"
run_case MacBookPro18,3 'Apple Inc.'
[[ ! -e $fixture/packages && ! -e $fixture/modules ]] || fail "unrelated model is untouched"
pass "legacy, vendor, and unrelated-model behavior is retained"
