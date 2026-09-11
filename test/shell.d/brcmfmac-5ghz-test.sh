#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/fix-brcmfmac-5ghz.sh"
nvram="$ROOT/default/firmware/apple/brcmfmac43602-pcie.txt"
nvram_mbp133="$ROOT/default/firmware/apple/brcmfmac43602-pcie-mbp133.txt"
all="$ROOT/install/hardware/all.sh"
migration="$ROOT/migrations/1787312531.sh"
migration_mbp133="$ROOT/migrations/1788504361.sh"
manual="$ROOT/manual/44-mac-support.md"

grep -q 'apple/fix-brcmfmac-5ghz.sh' "$all" ||
  fail "the BCM43602 5 GHz NVRAM runs during hardware setup"
grep -q 'apple/fix-brcmfmac-supplicant.sh' "$all" ||
  fail "the 5 GHz leaf does not replace the WPA handshake quirk"
pass "the BCM43602 5 GHz NVRAM runs during setup"

[[ -f $nvram ]] || fail "the calibrated NVRAM is in the tree"
grep -qx 'aa5g=7' "$nvram" || fail "NVRAM enables the 5 GHz antenna chain"
grep -qx 'txchain=7' "$nvram" || fail "NVRAM enables the full TX chain"
grep -qx 'rxchain=7' "$nvram" || fail "NVRAM enables the full RX chain"
grep -qx 'ccode=00' "$nvram" || fail "NVRAM defers channel legality to the host"
grep -qx 'regrev=245' "$nvram" || fail "NVRAM uses the host-deferral revision"
grep -q '290569' "$nvram" || fail "NVRAM documents its bugzilla attachment"
grep -qF 'https://bugzilla.kernel.org/attachment.cgi?id=290569' "$nvram" ||
  fail "NVRAM names the exact attachment it was vendored from"
! grep -q '^aa5g=1$' "$nvram" || fail "NVRAM is not the placeholder board file"
pass "the vendored NVRAM has full 5 GHz calibration and provenance"

[[ -f $nvram_mbp133 ]] || fail "the MacBookPro13,3 calibration is in the tree"
grep -qx 'aa5g=3' "$nvram_mbp133" || fail "MacBookPro13,3 NVRAM enables its 5 GHz antenna chain"
grep -q '285753' "$nvram_mbp133" || fail "MacBookPro13,3 NVRAM documents its bugzilla attachment"
grep -qF 'https://bugzilla.kernel.org/attachment.cgi?id=285753' "$nvram_mbp133" ||
  fail "MacBookPro13,3 NVRAM names the exact attachment it was vendored from"
pass "the MacBookPro13,3 NVRAM has separate calibration and provenance"

grep -Fq '5 GHz board calibration on supported 2016–2017 Touch Bar MacBook Pros' "$manual" ||
  fail "Mac support chapter mentions 5 GHz calibration"
pass "Mac support chapter mentions 5 GHz calibration"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
fwdir="$test_tmp/firmware/updates/brcm"
packaged="$test_tmp/firmware/brcm"
pci_devices="$test_tmp/sys-pci"
machine_id_file="$test_tmp/machine-id"
mkdir -p "$stub_bin" "$test_tmp/dmi"
printf 'WIRELESS_REGDOM="US"\n' >"$test_tmp/wireless-regdom"
printf '%s\n' '0123456789abcdef0123456789abcdef' >"$machine_id_file"

cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash

# Real lspci prints the domain in the BDF only when -D is passed, and /sys uses
# the domain form, so a consumer that parses plain lspci -nn finds no MAC.
domain=0
for arg in "$@"; do
  if [[ $arg == -*D* ]]; then
    domain=1
  fi
done

if (( domain == 1 )); then
  wifi_bdf=0000:03:00.0
  filler_bdf=0000:02:00.0
else
  wifi_bdf=03:00.0
  filler_bdf=02:00.0
fi

# Chatty like real lspci: keep writing well past the pipe buffer after the
# match, so a grep -q consumer would kill this stub with SIGPIPE and pipefail
# would read that as "no such hardware" (#6608).
if [[ -n ${WIFI_ID:-} ]]; then
  echo "$wifi_bdf Network controller [0280]: Broadcom Inc. Wireless [14e4:$WIFI_ID]"
fi
for _ in {1..4096}; do
  echo "$filler_bdf Host bridge [0600]: Filler Device [ffff:0000]"
done
SH

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
"$@"
SH

cat >"$stub_bin/omarchy-state" <<'SH'
#!/bin/bash

printf 'omarchy-state' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
SH

chmod +x "$stub_bin"/*

generic() {
  printf '%s\n' "$fwdir/brcmfmac43602-pcie.txt"
}

dmi_file() {
  local vendor=$1 product=$2
  printf '%s\n' "$fwdir/brcmfmac43602-pcie.${vendor}-${product}.txt"
}

provide_mac() {
  mkdir -p "$pci_devices/0000:03:00.0/net/wlp3s0"
  printf 'aa:bb:cc:dd:ee:ff\n' >"$pci_devices/0000:03:00.0/net/wlp3s0/address"
}

# The wiphy's permanent address, as opposed to the netdev's current one.
provide_perm_mac() {
  local mac=$1
  mkdir -p "$pci_devices/0000:03:00.0/ieee80211/phy0"
  printf '%s\n' "$mac" >"$pci_devices/0000:03:00.0/ieee80211/phy0/macaddress"
}

# Same derivation as brcmfmac43602_stable_mac, from this test's machine-id file.
expected_stable_macaddr() {
  local seed
  seed=$(printf '%s' "$(cat "$machine_id_file" 2>/dev/null || true):bcm43602-wifi" | sha256sum | cut -c1-10)
  printf 'macaddr=02:%s:%s:%s:%s:%s\n' \
    "${seed:0:2}" "${seed:2:2}" "${seed:4:2}" "${seed:6:2}" "${seed:8:2}"
}

# Production run_logged uses bash -eE with no pipefail.
invoke_leaf() {
  local wifi_id="${1:-}"
  WIFI_ID="$wifi_id" PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_INSTALL="$ROOT/install" \
    OMARCHY_BRCMFMAC_FWDIR="$fwdir" \
    OMARCHY_BRCMFMAC_PACKAGED_FWDIR="$packaged" \
    OMARCHY_BRCMFMAC_DMI_VENDOR="$test_tmp/dmi/sys_vendor" \
    OMARCHY_BRCMFMAC_DMI_PRODUCT="$test_tmp/dmi/product_name" \
    OMARCHY_BRCMFMAC_PCI_DEVICES="$pci_devices" \
    OMARCHY_BRCMFMAC_REGDOM_FILE="$test_tmp/wireless-regdom" \
    OMARCHY_BRCMFMAC_MACHINE_ID="$machine_id_file" \
    bash -eE -c 'source "$1"' bash "$leaf" </dev/null
}

run_leaf() {
  local vendor=$1 product=$2 wifi_id="${3:-}"
  rm -rf "$fwdir" "$packaged" "$pci_devices"
  mkdir -p "$fwdir" "$packaged"
  printf '%s' "$vendor" >"$test_tmp/dmi/sys_vendor"
  printf '%s' "$product" >"$test_tmp/dmi/product_name"
  invoke_leaf "$wifi_id"
}

run_migration() {
  local vendor=$1 product=$2 wifi_id="${3:-}" migration_path="${4:-$migration}"
  printf '%s' "$vendor" >"$test_tmp/dmi/sys_vendor"
  printf '%s' "$product" >"$test_tmp/dmi/product_name"
  : >"$calls"

  WIFI_ID="$wifi_id" PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_INSTALL="$ROOT/install" \
    OMARCHY_BRCMFMAC_FWDIR="$fwdir" \
    OMARCHY_BRCMFMAC_PACKAGED_FWDIR="$packaged" \
    OMARCHY_BRCMFMAC_DMI_VENDOR="$test_tmp/dmi/sys_vendor" \
    OMARCHY_BRCMFMAC_DMI_PRODUCT="$test_tmp/dmi/product_name" \
    OMARCHY_BRCMFMAC_PCI_DEVICES="$pci_devices" \
    OMARCHY_BRCMFMAC_REGDOM_FILE="$test_tmp/wireless-regdom" \
    OMARCHY_BRCMFMAC_MACHINE_ID="$machine_id_file" \
    bash -euo pipefail "$migration_path" >/dev/null
}

rm -rf "$fwdir" "$packaged" "$pci_devices"
mkdir -p "$fwdir" "$packaged"
provide_mac
printf '%s' "Apple Inc." >"$test_tmp/dmi/sys_vendor"
printf '%s' "MacBookPro14,3" >"$test_tmp/dmi/product_name"
invoke_leaf 43ba >/dev/null
[[ -f "$(generic)" ]] || fail "a MacBookPro14,3 gets the generic NVRAM"
[[ -f "$(dmi_file "Apple Inc." "MacBookPro14,3")" ]] ||
  fail "a MacBookPro14,3 gets the DMI-specific NVRAM"
grep -qx 'aa5g=7' "$(generic)" || fail "installed NVRAM enables 5 GHz"
expected=macaddr=aa:bb:cc:dd:ee:ff
[[ -n $expected ]] || fail "expected macaddr is non-empty"
grep -Fqx "$expected" "$(generic)" ||
  fail "the installed NVRAM carries the NIC's live MAC" "$(grep '^macaddr' "$(generic)")"
grep -Fqx "$expected" "$(dmi_file "Apple Inc." "MacBookPro14,3")" ||
  fail "the DMI-specific NVRAM gets the live MAC"
pass "a MacBookPro14,3 with BCM43602 gets both NVRAM names and the live MAC"

rm -rf "$fwdir" "$packaged" "$pci_devices"
mkdir -p "$fwdir" "$packaged"
provide_mac
printf '%s' "Apple Inc." >"$test_tmp/dmi/sys_vendor"
printf '%s' "MacBookPro14,2" >"$test_tmp/dmi/product_name"
invoke_leaf 43ba >/dev/null
[[ -f "$(dmi_file "Apple Inc." "MacBookPro14,2")" ]] ||
  fail "MacBookPro14,2 gets its DMI-specific NVRAM"
pass "MacBookPro14,2 gets its DMI-specific NVRAM"

rm -rf "$fwdir" "$packaged" "$pci_devices"
mkdir -p "$fwdir" "$packaged"
provide_mac
printf '%s' "Apple Computer, Inc." >"$test_tmp/dmi/sys_vendor"
printf '%s' "MacBookPro14,3" >"$test_tmp/dmi/product_name"
invoke_leaf 43ba >/dev/null
[[ -f "$(dmi_file "Apple Computer, Inc." "MacBookPro14,3")" ]] ||
  fail "the older Apple vendor string is recognized"
pass "the older Apple vendor string is recognized"

# NetworkManager randomises the netdev address while scanning; the wiphy's
# permanent address is the one to persist.
rm -rf "$fwdir" "$packaged" "$pci_devices"
mkdir -p "$fwdir" "$packaged"
provide_perm_mac 11:22:33:44:55:66
mkdir -p "$pci_devices/0000:03:00.0/net/wlp3s0"
printf 'f2:11:22:33:44:55\n' >"$pci_devices/0000:03:00.0/net/wlp3s0/address"
printf '%s' "Apple Inc." >"$test_tmp/dmi/sys_vendor"
printf '%s' "MacBookPro14,3" >"$test_tmp/dmi/product_name"
invoke_leaf 43ba >/dev/null
expected=macaddr=11:22:33:44:55:66
[[ -n $expected ]] || fail "expected macaddr is non-empty"
grep -Fqx "$expected" "$(generic)" ||
  fail "the permanent address wins over a randomised netdev address" "$(grep '^macaddr' "$(generic)")"
pass "the permanent address wins over a randomised netdev address"

# A card whose wiphy only shows Broadcom's 00:90:4c placeholder: keep macaddr=
# but do not persist the dump donor or the wiphy's placeholder.
rm -rf "$fwdir" "$packaged" "$pci_devices"
mkdir -p "$fwdir" "$packaged"
provide_perm_mac 00:90:4c:0d:f4:3e
mkdir -p "$pci_devices/0000:03:00.0/net/wlp3s0"
printf '00:90:4C:0D:F4:3E\n' >"$pci_devices/0000:03:00.0/net/wlp3s0/address"
printf '%s' "Apple Inc." >"$test_tmp/dmi/sys_vendor"
printf '%s' "MacBookPro14,3" >"$test_tmp/dmi/product_name"
invoke_leaf 43ba >/dev/null
[[ -f "$(generic)" ]] || fail "a card on the placeholder address still gets the NVRAM"
expected=$(expected_stable_macaddr)
[[ -n $expected ]] || fail "expected macaddr is non-empty"
grep -q '^macaddr=' "$(generic)" || fail "placeholder wiphy keeps the macaddr= key" "$(cat "$(generic)")"
! grep -Fqx 'macaddr=00:90:4c:0d:f4:3e' "$(generic)" ||
  fail "placeholder wiphy must not persist the dump donor" "$(grep '^macaddr' "$(generic)")"
grep -Fqx "$expected" "$(generic)" ||
  fail "placeholder wiphy gets this machine's stable MAC" "$(grep '^macaddr' "$(generic)")"
grep -Fqx "$expected" "$(dmi_file "Apple Inc." "MacBookPro14,3")" ||
  fail "placeholder wiphy DMI file gets this machine's stable MAC" "$(grep '^macaddr' "$(dmi_file "Apple Inc." "MacBookPro14,3")")"
pass "placeholder wiphy keeps macaddr= as a per-machine address"

# No MAC discoverable: still install, with a per-machine macaddr= rather than the donor.
rm -rf "$fwdir" "$packaged" "$pci_devices"
mkdir -p "$fwdir" "$packaged"
printf '%s' "Apple Inc." >"$test_tmp/dmi/sys_vendor"
printf '%s' "MacBookPro14,3" >"$test_tmp/dmi/product_name"
invoke_leaf 43ba >/dev/null
[[ -f "$(generic)" ]] || fail "a Mac with no discoverable MAC still gets the NVRAM"
expected=$(expected_stable_macaddr)
[[ -n $expected ]] || fail "expected macaddr is non-empty"
grep -q '^macaddr=' "$(generic)" || fail "macaddr= is present when no MAC is discoverable" "$(cat "$(generic)")"
! grep -Fqx 'macaddr=00:90:4c:0d:f4:3e' "$(generic)" ||
  fail "the dump donor is never persisted when no MAC is discoverable" "$(grep '^macaddr' "$(generic)")"
grep -Fqx "$expected" "$(generic)" ||
  fail "no discoverable MAC uses this machine's stable MAC" "$(grep '^macaddr' "$(generic)")"
pass "macaddr= is a per-machine address when no MAC is discoverable"

# A distinct Broadcom placeholder, including the kernel's 00:90:4c:c5:12:38
# default, must not be persisted and must not fall through to the dump donor.
rm -rf "$fwdir" "$packaged" "$pci_devices"
mkdir -p "$fwdir" "$packaged"
provide_perm_mac 00:90:4c:aa:bb:cc
printf '%s' "Apple Inc." >"$test_tmp/dmi/sys_vendor"
printf '%s' "MacBookPro14,3" >"$test_tmp/dmi/product_name"
invoke_leaf 43ba >/dev/null
expected=$(expected_stable_macaddr)
[[ -n $expected ]] || fail "expected macaddr is non-empty"
! grep -Fqx 'macaddr=00:90:4c:aa:bb:cc' "$(generic)" ||
  fail "a distinct Broadcom placeholder is not persisted" "$(grep '^macaddr' "$(generic)")"
! grep -Fqx 'macaddr=00:90:4c:0d:f4:3e' "$(generic)" ||
  fail "rejecting 00:90:4c:* must not persist the dump donor" "$(grep '^macaddr' "$(generic)")"
grep -Fqx "$expected" "$(generic)" ||
  fail "a distinct Broadcom placeholder falls through to the stable MAC" "$(grep '^macaddr' "$(generic)")"
rm -rf "$fwdir" "$packaged" "$pci_devices"
mkdir -p "$fwdir" "$packaged"
provide_perm_mac 00:90:4c:c5:12:38
invoke_leaf 43ba >/dev/null
! grep -Fqx 'macaddr=00:90:4c:c5:12:38' "$(generic)" ||
  fail "the kernel default placeholder is not persisted" "$(grep '^macaddr' "$(generic)")"
! grep -Fqx 'macaddr=00:90:4c:0d:f4:3e' "$(generic)" ||
  fail "the kernel default placeholder must not persist the dump donor" "$(grep '^macaddr' "$(generic)")"
grep -Fqx "$expected" "$(generic)" ||
  fail "the kernel default placeholder falls through to the stable MAC" "$(grep '^macaddr' "$(generic)")"
pass "Broadcom 00:90:4c placeholders fall through to a per-machine MAC"

# Two machines with no interface up must not share a station address.
rm -rf "$fwdir" "$packaged" "$pci_devices"
mkdir -p "$fwdir" "$packaged"
printf '%s' "Apple Inc." >"$test_tmp/dmi/sys_vendor"
printf '%s' "MacBookPro14,3" >"$test_tmp/dmi/product_name"
printf '%s\n' 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' >"$machine_id_file"
invoke_leaf 43ba >/dev/null
mac_one=$(grep '^macaddr=' "$(generic)")
[[ -n $mac_one ]] || fail "first machine-id produced a macaddr="
! grep -Fqx 'macaddr=00:90:4c:0d:f4:3e' "$(generic)" ||
  fail "first machine-id must not persist the dump donor" "$mac_one"
rm -rf "$fwdir" "$packaged" "$pci_devices"
mkdir -p "$fwdir" "$packaged"
printf '%s\n' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' >"$machine_id_file"
invoke_leaf 43ba >/dev/null
mac_two=$(grep '^macaddr=' "$(generic)")
[[ -n $mac_two ]] || fail "second machine-id produced a macaddr="
[[ $mac_one != $mac_two ]] || fail "two machine-ids must not share a macaddr" "$mac_one"
printf '%s\n' '0123456789abcdef0123456789abcdef' >"$machine_id_file"
pass "two machine-ids produce two different macaddr= values"

# Empty or missing machine-id and no live MAC: fail closed, persist nothing.
rm -rf "$fwdir" "$packaged" "$pci_devices"
mkdir -p "$fwdir" "$packaged"
printf '%s' "Apple Inc." >"$test_tmp/dmi/sys_vendor"
printf '%s' "MacBookPro14,3" >"$test_tmp/dmi/product_name"
: >"$machine_id_file"
if invoke_leaf 43ba >/dev/null 2>&1; then
  fail "empty machine-id without a live MAC must not look like success"
fi
[[ -z $(ls -A "$fwdir") ]] || fail "empty machine-id leaves nothing behind" "$(ls -A "$fwdir")"
rm -f "$machine_id_file"
if invoke_leaf 43ba >/dev/null 2>&1; then
  fail "missing machine-id without a live MAC must not look like success"
fi
[[ -z $(ls -A "$fwdir") ]] || fail "missing machine-id leaves nothing behind" "$(ls -A "$fwdir")"
printf '%s\n' '0123456789abcdef0123456789abcdef' >"$machine_id_file"
pass "empty machine-id without a live MAC fails and persists nothing"

# All supported boards must fail closed before staging firmware, not just 14,3.
for model in MacBookPro13,3 MacBookPro14,2 MacBookPro14,3; do
  printf '%s' "$model" >"$test_tmp/dmi/product_name"
  for invalid in '' uninitialized 00000000000000000000000000000000; do
    rm -rf "$fwdir" "$pci_devices"
    mkdir -p "$fwdir"
    printf '%s' "$invalid" >"$machine_id_file"
    if invoke_leaf 43ba >/dev/null 2>&1; then
      fail "$model invalid machine-id without a MAC must fail"
    fi
    [[ -z $(ls -A "$fwdir") ]] || fail "$model invalid identity leaves no firmware or temporary files"
  done
  # A usable discovered MAC does not depend on having a machine-id.
  rm -f "$machine_id_file"
  provide_mac
  invoke_leaf 43ba >/dev/null
  grep -Fqx 'macaddr=aa:bb:cc:dd:ee:ff' "$(generic)" || fail "$model keeps a discovered MAC without machine-id"
  pass "$model rejects invalid fallback input but allows a discovered MAC"
done
printf '%s\n' '0123456789abcdef0123456789abcdef' >"$machine_id_file"

# Missing identity must not mark the model-specific migration as complete.
rm -rf "$fwdir" "$packaged" "$pci_devices"
mkdir -p "$fwdir" "$packaged"
rm -f "$machine_id_file"
if run_migration "Apple Inc." "MacBookPro13,3" 43ba "$migration_mbp133" >/dev/null 2>&1; then
  fail "13,3 migration must fail when identity is unavailable"
fi
[[ -z $(ls -A "$fwdir") ]] || fail "13,3 migration failure leaves no staged firmware"
! grep -q 'omarchy-state' "$calls" || fail "13,3 identity failure must not request a reboot"
printf '%s\n' '0123456789abcdef0123456789abcdef' >"$machine_id_file"
run_migration "Apple Inc." "MacBookPro13,3" 43ba "$migration_mbp133"
grep -Fqx 'macaddr=02:7a:7d:ca:68:5d' "$(generic)" || fail "13,3 migration can retry after identity becomes available"
pass "13,3 migration fails without identity and succeeds on retry"

run_leaf "Apple Inc." "MacBookPro14,3" 43a0 >/dev/null
[[ ! -f "$(generic)" ]] || fail "a Mac whose Wi-Fi brcmfmac does not drive is left alone"
pass "a Mac whose Wi-Fi brcmfmac does not drive is left alone"

run_leaf "Apple Inc." "MacBookPro15,1" 4488 >/dev/null
[[ ! -f "$(generic)" ]] || fail "a T2-era chip is left to apple-bcm-firmware"
pass "a T2-era chip is left to apple-bcm-firmware"

run_leaf "Apple Inc." "MacBookPro14,3" 43bb >/dev/null
[[ ! -f "$(generic)" ]] || fail "the 2 GHz-only BCM43602 variant is left alone"
pass "the 2 GHz-only BCM43602 variant is left alone"

# MacBookPro13,3 uses its own calibration, fills in the host country, and gets a
# stable local address when the card reports Broadcom's placeholder.
rm -rf "$fwdir" "$packaged" "$pci_devices"
mkdir -p "$fwdir" "$packaged"
provide_perm_mac 00:90:4c:0d:f4:3e
printf '%s' "Apple Inc." >"$test_tmp/dmi/sys_vendor"
printf '%s' "MacBookPro13,3" >"$test_tmp/dmi/product_name"
invoke_leaf 43ba >/dev/null
[[ -f "$(dmi_file "Apple Inc." "MacBookPro13,3")" ]] ||
  fail "MacBookPro13,3 gets its DMI-specific NVRAM"
grep -qx 'ccode=US' "$(generic)" || fail "MacBookPro13,3 NVRAM uses the host country"
grep -qx 'regrev=0' "$(generic)" || fail "MacBookPro13,3 NVRAM uses the country revision"
grep -Eq '^macaddr=02:([0-9a-f]{2}:){4}[0-9a-f]{2}$' "$(generic)" ||
  fail "MacBookPro13,3 replaces the Broadcom placeholder with a stable local address"
grep -Fqx 'macaddr=02:7a:7d:ca:68:5d' "$(generic)" || fail "13,3 reconciliation preserves the historical mbp133-wifi salt"
pass "MacBookPro13,3 gets its board calibration, host country, and stable local address"

run_leaf "Apple Inc." "MacBookPro13,2" 43ba >/dev/null
[[ ! -f "$(generic)" ]] || fail "an unvalidated BCM43602 board is outside the model gate"
pass "unvalidated BCM43602 boards remain outside the model gate"

run_leaf "Apple Inc." "MacBookPro11,4" 43ba >/dev/null
[[ ! -f "$(generic)" ]] || fail "a 2015 BCM43602 Mac is outside the model gate"
pass "a 2015 BCM43602 Mac is outside the model gate"

run_leaf "LENOVO" "ThinkPad" 43ba >/dev/null
[[ ! -f "$(generic)" ]] || fail "non-Apple hardware is left alone"
pass "non-Apple hardware is left alone"

run_leaf "Apple Inc." "MacBookPro14,3" >/dev/null
[[ ! -f "$(generic)" ]] || fail "a Mac with no wireless device is left alone"
pass "a Mac with no wireless device is left alone"

# An existing file wins, user-placed or package-shipped. invoke_leaf, not
# run_leaf: run_leaf wipes fwdir first, which made the previous clobber
# assertion vacuous.
rm -rf "$fwdir" "$packaged" "$pci_devices"
mkdir -p "$fwdir" "$packaged"
provide_mac
printf '%s' "Apple Inc." >"$test_tmp/dmi/sys_vendor"
printf '%s' "MacBookPro14,3" >"$test_tmp/dmi/product_name"
printf 'user-owned\n' >"$(generic)"
invoke_leaf 43ba >/dev/null
grep -qx 'user-owned' "$(generic)" ||
  fail "an existing NVRAM is never clobbered" "$(cat "$(generic)")"
pass "an existing NVRAM is never clobbered"

# A packaged linux-firmware board file also outranks this copy.
rm -rf "$fwdir" "$packaged" "$pci_devices"
mkdir -p "$fwdir" "$packaged"
provide_mac
printf '%s' "Apple Inc." >"$test_tmp/dmi/sys_vendor"
printf '%s' "MacBookPro14,3" >"$test_tmp/dmi/product_name"
printf 'package-shipped\n' >"$packaged/brcmfmac43602-pcie.txt"
invoke_leaf 43ba >/dev/null
[[ ! -e "$(generic)" ]] || fail "a packaged NVRAM prevents writing the override"
pass "a packaged NVRAM prevents writing the override"

# Arch ships every firmware file zstd-compressed, so this is the name a real
# linux-firmware board file would arrive under.
rm -rf "$fwdir" "$packaged" "$pci_devices"
mkdir -p "$fwdir" "$packaged"
provide_mac
printf '%s' "Apple Inc." >"$test_tmp/dmi/sys_vendor"
printf '%s' "MacBookPro14,3" >"$test_tmp/dmi/product_name"
printf 'package-shipped\n' >"$packaged/brcmfmac43602-pcie.Apple Inc.-MacBookPro14,3.txt.zst"
invoke_leaf 43ba >/dev/null
[[ ! -e "$(generic)" ]] || fail "a compressed packaged NVRAM prevents writing the override"
pass "a compressed packaged NVRAM prevents writing the override"

# A failed install must not look like success. Stub install(1) to truncate its
# destination and then fail, the shape ENOSPC takes, after the gate has
# matched, so the leaf's set -e surfaces the error and nothing partial is left
# under a name the driver loads or the skip guard honours.
rm -rf "$fwdir" "$packaged" "$pci_devices"
mkdir -p "$fwdir" "$packaged"
provide_mac
printf '%s' "Apple Inc." >"$test_tmp/dmi/sys_vendor"
printf '%s' "MacBookPro14,3" >"$test_tmp/dmi/product_name"
cat >"$stub_bin/install" <<'SH'
#!/bin/bash
: >"${@: -1}"
exit 1
SH
chmod +x "$stub_bin/install"
if invoke_leaf 43ba >/dev/null 2>&1; then
  fail "a failed install does not look like success"
fi
rm -f "$stub_bin/install"
[[ ! -e "$(generic)" ]] || fail "a failed install leaves no dest file"
[[ -z $(ls -A "$fwdir") ]] || fail "a failed install leaves nothing behind" "$(ls -A "$fwdir")"
pass "a failed install does not look like success"

# The generic and DMI-specific names land together or not at all: one file on
# disk would satisfy the skip guard while the migration's reboot prompt is lost.
rm -rf "$fwdir" "$packaged" "$pci_devices"
mkdir -p "$fwdir" "$packaged"
provide_mac
printf '%s' "Apple Inc." >"$test_tmp/dmi/sys_vendor"
printf '%s' "MacBookPro14,3" >"$test_tmp/dmi/product_name"
cat >"$stub_bin/install" <<SH
#!/bin/bash
if [[ -e "$test_tmp/install-once" ]]; then
  exit 1
fi
touch "$test_tmp/install-once"
exec /usr/bin/install "\$@"
SH
chmod +x "$stub_bin/install"
if invoke_leaf 43ba >/dev/null 2>&1; then
  fail "a half-written NVRAM pair does not look like success"
fi
rm -f "$stub_bin/install" "$test_tmp/install-once"
[[ -z $(ls -A "$fwdir") ]] || fail "a half-written NVRAM pair is rolled back" "$(ls -A "$fwdir")"
pass "a half-written NVRAM pair is rolled back"

# A failure after the first final rename must remove both final and temp names.
rm -rf "$fwdir" "$packaged" "$pci_devices"
mkdir -p "$fwdir" "$packaged"
provide_mac
printf '%s' "MacBookPro13,3" >"$test_tmp/dmi/product_name"
cat >"$stub_bin/mv" <<'SH'
#!/bin/bash
if [[ ${@: -1} == *MacBookPro13,3.txt ]]; then
  exit 1
fi
exec /usr/bin/mv "$@"
SH
chmod +x "$stub_bin/mv"
if invoke_leaf 43ba >/dev/null 2>&1; then
  fail "a failed second rename must not look like success"
fi
rm -f "$stub_bin/mv"
[[ -z $(ls -A "$fwdir") ]] || fail "second-rename failure removes final and temporary firmware names" "$(ls -A "$fwdir")"
pass "second-rename failure rolls back the complete NVRAM pair"

# Even a source regression must not install a keyless file and break firmware.
sed '/^macaddr=/d' "$nvram_mbp133" >"$test_tmp/keyless.txt"
if OMARCHY_BRCMFMAC43602_NVRAM="$test_tmp/keyless.txt" invoke_leaf 43ba >/dev/null 2>&1; then
  fail "a calibration missing the required MAC key must fail"
fi
[[ -z $(ls -A "$fwdir") ]] || fail "a keyless calibration leaves no firmware behind"
pass "a calibration missing macaddr is rejected before installation"

rm -rf "$fwdir" "$packaged" "$pci_devices"
mkdir -p "$fwdir" "$packaged"
provide_mac
run_migration "Apple Inc." "MacBookPro14,3" 43ba
[[ -f "$(generic)" ]] || fail "the migration installs NVRAM on an existing Mac"
expected=macaddr=aa:bb:cc:dd:ee:ff
[[ -n $expected ]] || fail "expected macaddr is non-empty"
grep -Fqx "$expected" "$(generic)" ||
  fail "the migration substitutes the live MAC" "$(grep '^macaddr' "$(generic)")"
grep -Fq $'omarchy-state\tset\treboot-required' "$calls" ||
  fail "the migration asks for the reboot that applies it" "$(cat "$calls")"
pass "the migration installs NVRAM and asks for a reboot"

run_migration "Apple Inc." "MacBookPro14,3" 43ba
[[ ! -s $calls ]] || fail "the migration is idempotent" "$(cat "$calls")"
pass "the migration is idempotent"

rm -rf "$fwdir" "$packaged" "$pci_devices"
mkdir -p "$fwdir" "$packaged"
run_migration "Apple Inc." "MacBookPro14,3" 43ba
[[ -f "$(generic)" ]] || fail "the migration installs NVRAM without a discoverable MAC"
expected=$(expected_stable_macaddr)
[[ -n $expected ]] || fail "expected macaddr is non-empty"
grep -q '^macaddr=' "$(generic)" || fail "the migration keeps the macaddr= key" "$(cat "$(generic)")"
! grep -Fqx 'macaddr=00:90:4c:0d:f4:3e' "$(generic)" ||
  fail "the migration must not persist the dump donor" "$(grep '^macaddr' "$(generic)")"
grep -Fqx "$expected" "$(generic)" ||
  fail "the migration uses this machine's stable MAC when none is discoverable" "$(grep '^macaddr' "$(generic)")"
grep -Fq $'omarchy-state\tset\treboot-required' "$calls" ||
  fail "the migration still asks for a reboot without a MAC" "$(cat "$calls")"
pass "the migration uses a per-machine MAC when none is discoverable"

rm -rf "$fwdir" "$packaged"
mkdir -p "$fwdir" "$packaged"
printf 'already-there\n' >"$(generic)"
run_migration "Apple Inc." "MacBookPro14,3" 43ba
grep -qx 'already-there' "$(generic)" ||
  fail "the migration never overwrites an existing NVRAM" "$(cat "$(generic)")"
[[ ! -s $calls ]] || fail "the migration escalates nothing when the file already exists" "$(cat "$calls")"
pass "the migration never overwrites an existing NVRAM"

rm -rf "$fwdir" "$packaged" "$pci_devices"
mkdir -p "$fwdir" "$packaged"
provide_perm_mac 00:90:4c:0d:f4:3e
run_migration "Apple Inc." "MacBookPro13,3" 43ba "$migration_mbp133"
grep -qx 'ccode=US' "$(generic)" || fail "migration gives MacBookPro13,3 the host country"
grep -Eq '^macaddr=02:([0-9a-f]{2}:){4}[0-9a-f]{2}$' "$(generic)" ||
  fail "migration replaces the placeholder MAC on MacBookPro13,3"
grep -Fq $'omarchy-state\tset\treboot-required' "$calls" ||
  fail "MacBookPro13,3 migration asks for a reboot" "$(cat "$calls")"
pass "migration installs the separately calibrated MacBookPro13,3 NVRAM"

rm -rf "$fwdir"
run_migration "LENOVO" "ThinkPad" 43ba
[[ ! -e "$(generic)" ]] || fail "the migration skips non-Apple hardware"
[[ ! -s $calls ]] || fail "the migration escalates nothing on unaffected machines" "$(cat "$calls")"
pass "the migration skips non-Apple hardware"

# A failed migration install must not mark the migration done via reboot-required,
# and the rerun omarchy-migrate then makes must do the work it skipped.
rm -rf "$fwdir" "$packaged" "$pci_devices"
mkdir -p "$fwdir" "$packaged"
provide_mac
cat >"$stub_bin/install" <<'SH'
#!/bin/bash
: >"${@: -1}"
exit 1
SH
chmod +x "$stub_bin/install"
if run_migration "Apple Inc." "MacBookPro14,3" 43ba; then
  fail "a failed migration install does not look like success"
fi
rm -f "$stub_bin/install"
grep -q 'omarchy-state' "$calls" &&
  fail "a failed migration does not ask for a reboot" "$(cat "$calls")"
pass "a failed migration install does not look like success"

run_migration "Apple Inc." "MacBookPro14,3" 43ba
grep -qx 'aa5g=7' "$(generic)" ||
  fail "the rerun after a failed migration installs the NVRAM" "$(ls -A "$fwdir")"
grep -Fq $'omarchy-state\tset\treboot-required' "$calls" ||
  fail "the rerun after a failed migration asks for the reboot" "$(cat "$calls")"
pass "the rerun after a failed migration installs and asks for the reboot"
