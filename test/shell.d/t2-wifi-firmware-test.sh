#!/bin/bash

# DMI and lspci are mocked. Nothing here boots a T2 Mac or downloads firmware.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

wifi="$ROOT/bin/omarchy-hw-t2-wifi"
leaf="$ROOT/install/hardware/apple/fix-t2-wifi.sh"
all="$ROOT/install/hardware/all.sh"

grep -q 'run_logged "$OMARCHY_INSTALL/hardware/apple/fix-t2-wifi.sh"' "$all" ||
  fail "hardware setup installs T2 Wi-Fi firmware"
awk '
  /fix-t2\.sh/ { t2 = NR }
  /fix-t2-wifi\.sh/ { wifi = NR }
  END { exit !(t2 && wifi && t2 < wifi) }
' "$all" || fail "T2 Wi-Fi firmware runs after the fetcher package is installed"
grep -q 'OMARCHY_T2_WIFI_BEST_EFFORT=1 omarchy-hw-t2-wifi' "$leaf" ||
  fail "hardware setup does not fail when the recovery image cannot be fetched"
pass "T2 Wi-Fi firmware is part of hardware setup"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
firmware_dir="$test_tmp/firmware"
dmi_product="$test_tmp/product_name"
dmi_vendor="$test_tmp/sys_vendor"
log="$test_tmp/calls.log"
stdout="$test_tmp/stdout"
stderr="$test_tmp/stderr"
tree="$test_tmp/firmware-tree"
mkdir -p "$stub_bin" "$firmware_dir"

cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash

if (( ${T2_HARDWARE:-0} == 1 )); then
  echo '01:00.0 Bridge [0680]: Apple Inc. T2 Security Chip [106b:1801]'
fi
for _ in {1..4096}; do
  echo '02:00.0 Host bridge [0600]: Filler Device [ffff:0000]'
done
SH

cat >"$stub_bin/modprobe" <<'SH'
#!/bin/bash

printf 'modprobe' >>"$T2_WIFI_LOG"
printf '\t%s' "$@" >>"$T2_WIFI_LOG"
printf '\n' >>"$T2_WIFI_LOG"
SH

cat >"$stub_bin/recovery" <<'SH'
#!/bin/bash

printf 'recovery' >>"$T2_WIFI_LOG"
printf '\t%s' "$@" >>"$T2_WIFI_LOG"
printf '\n' >>"$T2_WIFI_LOG"
exit 1
SH

cat >"$stub_bin/ip" <<'SH'
#!/bin/bash

if [[ $1 == route && $2 == show && $3 == default ]]; then
  if (( ${T2_ROUTE:-1} == 1 )); then
    echo 'default via 10.0.0.1 dev eth0'
  fi
  exit 0
fi
echo "unexpected ip: $*" >&2
exit 1
SH

cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash

printf 'omarchy-pkg-add' >>"$T2_WIFI_LOG"
printf '\t%s' "$@" >>"$T2_WIFI_LOG"
printf '\n' >>"$T2_WIFI_LOG"
exit 1
SH

cat >"$stub_bin/losetup" <<'SH'
#!/bin/bash

echo "losetup $*" >>"$T2_WIFI_LOG"
exit 1
SH

cat >"$stub_bin/dmg2img" <<'SH'
#!/bin/bash

echo "dmg2img $*" >>"$T2_WIFI_LOG"
exit 1
SH

cat >"$stub_bin/mount" <<'SH'
#!/bin/bash

echo "mount $*" >>"$T2_WIFI_LOG"
exit 1
SH

chmod +x "$stub_bin"/*

set_machine() {
  printf '%s\n' "$1" >"$dmi_vendor"
  printf '%s\n' "$2" >"$dmi_product"
}

reset_state() {
  rm -rf "$firmware_dir"
  mkdir -p "$firmware_dir"
  : >"$log"
}

run_wifi() {
  local expected=$1
  shift
  local -a env_vars=()
  local -a args=()

  while (($#)); do
    if [[ $1 == *=* ]]; then
      env_vars+=("$1")
    else
      args+=("$1")
    fi
    shift
  done

  set +e
  env \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_DMI_PRODUCT_NAME="$dmi_product" \
    OMARCHY_DMI_SYS_VENDOR="$dmi_vendor" \
    OMARCHY_T2_WIFI_FIRMWARE_DIR="$firmware_dir" \
    OMARCHY_T2_WIFI_RECOVERY_CMD="$stub_bin/recovery" \
    T2_WIFI_LOG="$log" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    "${env_vars[@]}" \
    "$wifi" "${args[@]}" >"$stdout" 2>"$stderr"
  status=$?
  set -e
  if (( status != expected )); then
    fail "exit status $status, expected $expected" "$(printf 'stdout:\n%s\nstderr:\n%s\n' "$(cat "$stdout")" "$(cat "$stderr")")"
  fi
}

write_maui_tree() {
  local wifi_dir="$tree/wifi/C-4364__s-B2"
  rm -rf "$tree"
  mkdir -p "$wifi_dir"
  printf 'FIRMWARE' >"$wifi_dir/maui.trx"
  printf 'CLM' >"$wifi_dir/maui-X3.clmb"
  printf 'boardtype=maui\n' >"$wifi_dir/P-maui-X3_M-HRPN_V-m__m-7.7.txt"
}

write_bali_tree() {
  local wifi_dir="$tree/wifi/C-4364__s-B3"
  rm -rf "$tree"
  mkdir -p "$wifi_dir"
  printf 'FIRMWARE' >"$wifi_dir/bali.trx"
  printf 'boardtype=bali\n' >"$wifi_dir/P-bali-X2_M-HRPN_V-u__m-6.5.txt"
}

# A1989 is MacBookPro15,2: BCM4364 B2, island maui.
set_machine "Apple Inc." "MacBookPro15,2"
reset_state
write_maui_tree
run_wifi 0 T2_HARDWARE=1 OMARCHY_T2_WIFI_FIRMWARE_TREE="$tree"
[[ -f $firmware_dir/brcmfmac4364b2-pcie.apple,maui.bin ]] ||
  fail "MacBookPro15,2 gets BCM4364 B2 maui firmware" "$(ls -1 "$firmware_dir")"
[[ -f $firmware_dir/brcmfmac4364b2-pcie.apple,maui.txt ]] ||
  fail "MacBookPro15,2 gets BCM4364 B2 maui NVRAM" "$(ls -1 "$firmware_dir")"
[[ -f $firmware_dir/brcmfmac4364b2-pcie.apple,maui.clm_blob ]] ||
  fail "MacBookPro15,2 gets the maui regulatory blob"
grep -qx 'boardtype=maui' "$firmware_dir/brcmfmac4364b2-pcie.apple,maui.txt" ||
  fail "NVRAM contents are preserved"
grep -qx $'modprobe\t-r\tbrcmfmac_wcc' "$log" || fail "brcmfmac_wcc is unloaded before brcmfmac"
grep -qx $'modprobe\t-r\tbrcmfmac' "$log" || fail "brcmfmac is reloaded so it reads the new firmware"
grep -qx $'modprobe\tbrcmfmac' "$log" || fail "brcmfmac is loaded"
! grep -q '^recovery' "$log" || fail "an on-disk firmware tree does not download a recovery image" "$(cat "$log")"
! grep -q '^omarchy-pkg-add' "$log" || fail "an on-disk firmware tree does not install dmg2img"
pass "MacBookPro15,2 (A1989) gets BCM4364 maui firmware, NVRAM, and a brcmfmac reload"

: >"$log"
run_wifi 0 T2_HARDWARE=1
! grep -q '^modprobe' "$log" || fail "firmware already installed is left loaded" "$(cat "$log")"
! grep -q '^recovery' "$log" || fail "firmware already installed does not download again"
run_wifi 1 T2_HARDWARE=1 --check
pass "installed MacBookPro15,2 firmware is left alone"

reset_state
cat >"$stub_bin/apple-bcm-firmware-fetcher" <<'SH'
#!/bin/bash

echo fetcher >>"$T2_WIFI_LOG"
mkdir -p "$OMARCHY_T2_WIFI_FIRMWARE_DIR"
printf 'from-macos\n' >"$OMARCHY_T2_WIFI_FIRMWARE_DIR/brcmfmac4364b2-pcie.apple,maui.bin"
printf 'boardtype=maui\n' >"$OMARCHY_T2_WIFI_FIRMWARE_DIR/brcmfmac4364b2-pcie.apple,maui.txt"
SH
chmod +x "$stub_bin/apple-bcm-firmware-fetcher"
run_wifi 0 T2_HARDWARE=1
grep -qx fetcher "$log" || fail "a macOS volume is tried before a recovery image" "$(cat "$log")"
grep -qx 'from-macos' "$firmware_dir/brcmfmac4364b2-pcie.apple,maui.bin" ||
  fail "firmware from the macOS volume is kept"
! grep -q '^recovery' "$log" || fail "a macOS volume satisfies the firmware without a download"
grep -qx $'modprobe\tbrcmfmac' "$log" || fail "brcmfmac loads firmware copied from macOS"
rm -f "$stub_bin/apple-bcm-firmware-fetcher"
pass "a leftover macOS volume supplies firmware and skips the recovery image"

reset_state
run_wifi 1 T2_HARDWARE=1
grep -q $'^recovery\tdownload\t-b\tMac-827FAC58A8FDFA22\t-m\t00000000000000000\t-n\tBaseSystem\t-o\t' "$log" ||
  fail "a wiped MacBookPro15,2 downloads the Sonoma recovery image" "$(cat "$log")"
! grep -q '^modprobe' "$log" || fail "a failed download does not reload brcmfmac" "$(cat "$log")"
! grep -q '^losetup' "$log" || fail "a failed download does not mount an image"
pass "a wiped MacBookPro15,2 asks for an Apple recovery image and reports failure"

reset_state
run_wifi 0 T2_HARDWARE=1 OMARCHY_T2_WIFI_BEST_EFFORT=1
grep -q '^recovery' "$log" || fail "best-effort setup still tries the recovery image when a route exists"
pass "hardware setup keeps going when the recovery download fails"

reset_state
run_wifi 1 T2_HARDWARE=1 T2_ROUTE=0
! grep -q '^recovery' "$log" || fail "no network route does not start a download" "$(cat "$log")"
pass "no network route skips the recovery download"

reset_state
run_wifi 0 T2_HARDWARE=1 OMARCHY_T2_WIFI_BEST_EFFORT=1 OMARCHY_IMAGE_DEFERRED_HARDWARE=1
! grep -q '^recovery' "$log" || fail "first boot does not download a recovery image" "$(cat "$log")"
grep -Fq "omarchy hw t2 wifi" "$stderr" || fail "first boot tells the owner how to fetch firmware" "$(cat "$stderr")"
pass "image first boot does not block on the recovery download"

set_machine "Apple Inc." "iMacPro1,1"
reset_state
run_wifi 0 T2_HARDWARE=1
! grep -q '^recovery' "$log" || fail "an iMac Pro does not use the recovery image" "$(cat "$log")"
grep -Fq "installed macOS" "$stderr" || fail "an iMac Pro is told the recovery image is not enough" "$(cat "$stderr")"
pass "an iMac Pro is not given the recovery-image path"

set_machine "Apple Inc." "MacBookPro16,1"
reset_state
write_bali_tree
run_wifi 0 T2_HARDWARE=1 OMARCHY_T2_WIFI_FIRMWARE_TREE="$tree"
[[ -f $firmware_dir/brcmfmac4364b3-pcie.apple,bali.bin ]] ||
  fail "MacBookPro16,1 gets BCM4364 B3 bali firmware" "$(ls -1 "$firmware_dir")"
[[ -f $firmware_dir/brcmfmac4364b3-pcie.apple,bali.txt ]] ||
  fail "MacBookPro16,1 gets BCM4364 B3 bali NVRAM"
! [[ -f $firmware_dir/brcmfmac4364b2-pcie.apple,maui.bin ]] ||
  fail "a B3 Mac does not take the B2 maui firmware"
pass "MacBookPro16,1 gets BCM4364 B3 firmware and NVRAM"

set_machine "Apple Inc." "MacBookPro14,2"
reset_state
run_wifi 0 T2_HARDWARE=1
run_wifi 1 T2_HARDWARE=1 --check
! grep -q '^recovery' "$log" || fail "a BCM43602 Mac is not given T2 firmware" "$(cat "$log")"
[[ -z $(ls -A "$firmware_dir") ]] || fail "a BCM43602 Mac gets no firmware files" "$(ls -1 "$firmware_dir")"
pass "a 2017 Touch Bar Mac (BCM43602) is left to its own NVRAM path"

set_machine "LENOVO" "MacBookPro15,2"
reset_state
run_wifi 0 T2_HARDWARE=1
run_wifi 1 T2_HARDWARE=1 --check
! grep -q '^recovery' "$log" || fail "a non-Apple product name does not fetch T2 firmware"
pass "a non-Apple machine is left alone"

set_machine "Apple Inc." "MacBookPro15,2"
reset_state
run_wifi 0 T2_HARDWARE=0
run_wifi 1 T2_HARDWARE=0 --check
! grep -q '^recovery' "$log" || fail "a Mac without a T2 chip does not fetch T2 firmware"
pass "a Mac without a T2 chip is left alone"

set_machine "Apple Inc." "MacBookPro15,2"
reset_state
run_wifi 1 T2_HARDWARE=1 --not-an-option
pass "an unknown option is rejected"

# Missing DMI must not abort under set -u.
rm -f "$dmi_product" "$dmi_vendor"
run_wifi 0 T2_HARDWARE=1
run_wifi 1 T2_HARDWARE=1 --check
pass "missing DMI is not a T2 Wi-Fi install"
