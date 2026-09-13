#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/fix-brcmfmac-nvram.sh"
nvram_source="$ROOT/install/hardware/apple/brcmfmac43602-pcie.txt"
all="$ROOT/install/hardware/all.sh"

# Test 1: Script exists and has proper structure
[[ -f $leaf ]] || fail "the NVRAM fix script exists"
pass "the NVRAM fix script exists"

grep -q '14e4:43ba' "$leaf" || fail "script detects BCM43602 by PCI ID"
pass "script detects BCM43602 by PCI ID"

grep -q 'brcmfmac43602-pcie.txt' "$leaf" || fail "script installs the correct NVRAM file"
pass "script installs the correct NVRAM file"

grep -q 'macaddr' "$leaf" || fail "script handles MAC address substitution"
pass "script handles MAC address substitution"

grep -q 'limine-mkinitcpio\|mkinitcpio' "$leaf" || fail "script rebuilds initramfs"
pass "script rebuilds initramfs"

# Test 2: Included in hardware setup
grep -q 'apple/fix-brcmfmac-nvram.sh' "$all" || fail "the NVRAM fix runs during hardware setup"
pass "the NVRAM fix runs during hardware setup"

# Test 3: NVRAM source file exists and has content
[[ -f $nvram_source ]] || fail "the NVRAM config source file exists"
pass "the NVRAM config source file exists"

grep -q 'macaddr=' "$nvram_source" || fail "NVRAM config contains MAC address placeholder"
pass "NVRAM config contains MAC address placeholder"

grep -q 'boardflags=' "$nvram_source" || fail "NVRAM config contains boardflags"
pass "NVRAM config contains boardflags"

grep -q 'pa2ga0=' "$nvram_source" || fail "NVRAM config contains 2GHz PA parameters"
pass "NVRAM config contains 2GHz PA parameters"

grep -q 'pa5ga0=' "$nvram_source" || fail "NVRAM config contains 5GHz PA parameters"
pass "NVRAM config contains 5GHz PA parameters"

# Test 4: Script runs correctly with mocked hardware
test_tmp="$(mktemp -d)"
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin" "$test_tmp/firmware/brcm" "$test_tmp/sys/class/net/wlp3s0" "$test_tmp/tmp"

# Create mock commands
cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash
echo '03:00.0 Network controller [0280]: Broadcom Inc. BCM43602 [14e4:43ba] (rev 02)'
SH

cat >"$stub_bin/iw" <<'SH'
#!/bin/bash
if [[ "$1" == "dev" && -z "${2:-}" ]]; then
  echo "Interface wlp3s0"
fi
SH

cat >"$stub_bin/cat" <<'SH'
#!/bin/bash
if [[ "$1" == "/sys/class/net/wlp3s0/address" ]]; then
  echo "aa:bb:cc:dd:ee:ff"
else
  /usr/bin/cat "$@"
fi
SH

cat >"$stub_bin/install" <<'SH'
#!/bin/bash
/usr/bin/install "$@"
SH

cat >"$stub_bin/mktemp" <<'SH'
#!/bin/bash
if [[ "$1" == "-d" ]]; then
  mkdir -p "$test_tmp/tmp/nvram"
  echo "$test_tmp/tmp/nvram"
else
  /usr/bin/mktemp "$@"
fi
SH

cat >"$stub_bin/command" <<'SH'
#!/bin/bash
if [[ "$1" == "-v" && "$2" == "limine-mkinitcpio" ]]; then
  echo "/usr/bin/limine-mkinitcpio"
  exit 0
elif [[ "$1" == "-v" ]]; then
  /usr/bin/command "$@"
else
  /usr/bin/command "$@"
fi
SH

cat >"$stub_bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
echo "limine-mkinitcpio called"
SH

chmod +x "$stub_bin"/*

export PATH="$stub_bin:$PATH"

mkdir -p "$test_tmp/firmware/brcm"
mkdir -p "$test_tmp/sys/class/net/wlp3s0"
echo "aa:bb:cc:dd:ee:ff" > "$test_tmp/sys/class/net/wlp3s0/address"

# Copy NVRAM source to test tmp (simulating OMARCHY_INSTALL)
test_omarchy_install="$test_tmp/install"
mkdir -p "$test_omarchy_install/hardware/apple"
cp "$nvram_source" "$test_omarchy_install/hardware/apple/brcmfmac43602-pcie.txt"

# Source the script with paths redirected
sed -e "s|/usr/lib/firmware/brcm|$test_tmp/firmware/brcm|g" \
    -e "s|/sys/class/net|$test_tmp/sys/class/net|g" \
    -e "s|\$OMARCHY_INSTALL/hardware|$test_omarchy_install/hardware|g" \
    "$leaf" > "$test_tmp/leaf.sh"

# Run the leaf
bash -eE -o pipefail "$test_tmp/leaf.sh" </dev/null

# Test 5: NVRAM file was installed
nvram_file="$test_tmp/firmware/brcm/brcmfmac43602-pcie.txt"
[[ -f $nvram_file ]] || fail "NVRAM config was installed"
pass "NVRAM config was installed"

# Test 6: MAC address was substituted correctly
grep -q "macaddr=aa:bb:cc:dd:ee:ff" "$nvram_file" || fail "MAC address was substituted into NVRAM config"
pass "MAC address was substituted into NVRAM config"

# Test 7: NVRAM config has correct parameters from the cristianmiranda config
grep -q "boardflags=0x02000001" "$nvram_file" || fail "boardflags parameter present"
pass "boardflags parameter present"

grep -q "pa2ga0=" "$nvram_file" || fail "2GHz PA parameters present"
pass "2GHz PA parameters present"

grep -q "pa5ga0=" "$nvram_file" || fail "5GHz PA parameters present"
pass "5GHz PA parameters present"

# Test 8: NVRAM config has the full set of board flags
grep -q "boardflags2=0xC0000000" "$nvram_file" || fail "boardflags2 parameter present"
pass "boardflags2 parameter present"

grep -q "boardflags3=0x40000108" "$nvram_file" || fail "boardflags3 parameter present"
pass "boardflags3 parameter present"

echo "all tests passed"
