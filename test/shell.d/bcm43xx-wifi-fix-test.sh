#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

fix_script="$ROOT/install/hardware/fix-bcm43xx.sh"

# === Static analysis ===

grep -q '14e4:43a0' "$fix_script" || \
  fail "fix-bcm43xx.sh still detects BCM4360 (14e4:43a0)"
pass "fix-bcm43xx.sh still detects BCM4360 (14e4:43a0)"

grep -q '14e4:4331' "$fix_script" || \
  fail "fix-bcm43xx.sh still detects BCM4331 (14e4:4331)"
pass "fix-bcm43xx.sh still detects BCM4331 (14e4:4331)"

grep -q '14e4:4353' "$fix_script" || \
  fail "fix-bcm43xx.sh detects BCM43224 (14e4:4353) in MacBook Air 5,2"
pass "fix-bcm43xx.sh detects BCM43224 (14e4:4353) in MacBook Air 5,2"

# === Test 1: BCM43224 detection ===

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
mkdir -p "$stub_bin"
: >"$calls"

cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash

echo '02:00.0 Network controller [0280]: Broadcom Inc. and subsidiaries BCM43224 802.11a/b/g/n [14e4:4353] (rev 01)'
SH

cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash

printf 'omarchy-pkg-add\t%s\n' "$*" >>"$TEST_LOG"
SH

chmod +x "$stub_bin"/*

# Redirect /etc/modprobe.d to sandbox so the test runs without root
script="$test_tmp/fix-bcm43xx.sh"
sed -e "s|/etc/modprobe.d|$test_tmp/etc/modprobe.d|g" \
    "$fix_script" >"$script"

PATH="$stub_bin:$PATH" \
  TEST_LOG="$calls" \
  OMARCHY_INSTALL="$ROOT/install" \
  bash -euo pipefail "$script" >/dev/null

# Verify package install was called (tab-separated)
grep -qx $'omarchy-pkg-add\tbroadcom-wl-dkms' "$calls" || \
  fail "BCM43224 triggers broadcom-wl-dkms installation, relying on the base install's kernel headers"
pass "BCM43224 triggers broadcom-wl-dkms installation, relying on the base install's kernel headers"

# broadcom-wl-dkms ships its own blacklist, which goes away with the package
[[ ! -d "$test_tmp/etc/modprobe.d" ]] || fail "BCM43224 leaves blacklisting to broadcom-wl-dkms"
pass "BCM43224 leaves blacklisting to broadcom-wl-dkms"

# === Test 2: Non-Broadcom hardware is skipped ===

test_tmp2=$(mktemp -d)
trap 'rm -rf "$test_tmp" "$test_tmp2"' EXIT

stub_bin2="$test_tmp2/bin"
calls2="$test_tmp2/calls.log"
mkdir -p "$stub_bin2"
: >"$calls2"

cat >"$stub_bin2/lspci" <<'SH'
#!/bin/bash

echo '02:00.0 Network controller [0280]: Intel Corporation Wi-Fi 6 AX201 [8086:06f0] (rev 01)'
SH

cat >"$stub_bin2/omarchy-pkg-add" <<'SH'
#!/bin/bash

printf 'omarchy-pkg-add\t%s\n' "$*" >>"$TEST_LOG"
SH

chmod +x "$stub_bin2"/*

script2="$test_tmp2/fix-bcm43xx.sh"
sed -e "s|/etc/modprobe.d|$test_tmp2/etc/modprobe.d|g" \
    "$fix_script" >"$script2"

PATH="$stub_bin2:$PATH" \
  TEST_LOG="$calls2" \
  OMARCHY_INSTALL="$ROOT/install" \
  bash -euo pipefail "$script2" >/dev/null

[[ ! -s $calls2 ]] || fail "non-Broadcom hardware skips driver installation"
pass "non-Broadcom hardware skips driver installation"

[[ ! -d "$test_tmp2/etc/modprobe.d" ]] || fail "non-Broadcom hardware skips blacklist creation"
pass "non-Broadcom hardware skips blacklist creation"
