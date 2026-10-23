#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
pkg_log="$test_tmp/packages"
mkdir -p "$stub_bin"

cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash
printf '%s\n' "$OMARCHY_TEST_LSPCI"
SH

cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_PKG_LOG"
SH

cat >"$stub_bin/cat" <<'STUB'
#!/bin/bash
if [[ $1 == "/sys/class/dmi/id/product_name" ]]; then
  [[ ${OMARCHY_TEST_DMI_MISSING:-0} == 0 ]] || exit 1
  printf '%s\n' "$OMARCHY_TEST_MODEL"
else
  /usr/bin/cat "$@"
fi
STUB

chmod +x "$stub_bin/lspci" "$stub_bin/omarchy-pkg-add" "$stub_bin/cat"

run_bcm() {
  : >"$pkg_log"
  PATH="$stub_bin:$PATH" \
    OMARCHY_TEST_LSPCI="$1" \
    OMARCHY_TEST_MODEL="${2-MacBookPro9,2}" \
    OMARCHY_TEST_PKG_LOG="$pkg_log" \
    bash -eE -c 'source "$1"' _ "$ROOT/install/hardware/fix-bcm43xx.sh"
}

bcm4331='01:00.0 Network controller [0280]: Broadcom Inc. and subsidiaries BCM4331 802.11a/b/g/n [14e4:4331]'
bcm4360='02:00.0 Network controller [0280]: Broadcom Inc. and subsidiaries BCM4360 802.11ac [14e4:43a0]'

run_bcm "$bcm4331"
[[ $(<"$pkg_log") == "broadcom-wl-dkms" ]] || fail "BCM4331 on MacBookPro9,2 keeps wl" "$(cat "$pkg_log")"
pass "BCM4331 on MacBookPro9,2 keeps the working wl driver path"

run_bcm "$bcm4331" "MacBookAir4,1"
[[ ! -s $pkg_log ]] || fail "the reported freezing model must not install wl" "$(cat "$pkg_log")"
pass "MacBookAir4,1 with BCM4331 skips wl"

for model in "MacBookAir4,2" "MacBookAir5,2" "Other system" ""; do
  run_bcm "$bcm4331" "$model"
  [[ $(<"$pkg_log") == "broadcom-wl-dkms" ]] || fail "BCM4331 on other or unknown models keeps wl" "$model"
done
pass "the exception does not spread to unreported or unknown models"

OMARCHY_TEST_DMI_MISSING=1 run_bcm "$bcm4331"
[[ $(<"$pkg_log") == "broadcom-wl-dkms" ]] || fail "unavailable DMI keeps the existing driver path"
pass "missing DMI does not abort hardware setup or suppress wl"

run_bcm "$bcm4360"
[[ $(<"$pkg_log") == "broadcom-wl-dkms" ]] || fail "BCM4360 still installs wl" "$(cat "$pkg_log")"
run_bcm "$bcm4360" "MacBookAir4,1"
[[ $(<"$pkg_log") == "broadcom-wl-dkms" ]] || fail "the exception also requires BCM4331"
pass "BCM4360 alone keeps wl on every model"

both_chips="$bcm4331"$'\n'"$bcm4360"
run_bcm "$both_chips"
[[ $(<"$pkg_log") == "broadcom-wl-dkms" ]] || fail "both chips on other models keep wl"
run_bcm "$both_chips" "MacBookAir4,1"
[[ ! -s $pkg_log ]] || fail "a second chip must not reintroduce wl on the freezing model"
pass "mixed-chip systems respect the model-specific exception"

for model in "MacBookAir4,1" "Other system"; do
  run_bcm '00:1f.6 Ethernet controller [0200]: Intel I219-V [8086:15be]' "$model"
  [[ ! -s $pkg_log ]] || fail "unrelated PCI devices do not install a Broadcom driver"
done
pass "unrelated PCI devices install no Broadcom package"
