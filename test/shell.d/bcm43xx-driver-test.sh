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

chmod +x "$stub_bin/lspci" "$stub_bin/omarchy-pkg-add"

run_bcm() {
  : >"$pkg_log"
  PATH="$stub_bin:$PATH" \
    OMARCHY_TEST_LSPCI="$1" \
    OMARCHY_TEST_PKG_LOG="$pkg_log" \
    bash -c 'source "$1"' _ "$ROOT/install/hardware/fix-bcm43xx.sh"
}

bcm4331='01:00.0 Network controller [0280]: Broadcom Inc. and subsidiaries BCM4331 802.11a/b/g/n [14e4:4331]'
bcm4360='02:00.0 Network controller [0280]: Broadcom Inc. and subsidiaries BCM4360 802.11ac [14e4:43a0]'

run_bcm "$bcm4331"
[[ ! -s $pkg_log ]] || fail "BCM4331 must not install broadcom-wl or a firmware package that does not ship b43 ucode" "$(cat "$pkg_log")"
pass "BCM4331 keeps in-kernel b43 and does not install broadcom-wl"

run_bcm "$bcm4360"
[[ $(<"$pkg_log") == "broadcom-wl-dkms" ]] || fail "BCM4360 still installs broadcom-wl" "$(cat "$pkg_log")"
pass "BCM4360 keeps broadcom-wl"

run_bcm $'00:00.0 Host bridge [0600]: Intel [8086:1234]\n'"$bcm4331"$'\n'"$bcm4360"
[[ ! -s $pkg_log ]] || fail "a machine with both chips must not install the wl blacklist" "$(cat "$pkg_log")"
pass "BCM4331 wins when both Broadcom IDs are present, so wl cannot blacklist b43"

run_bcm $'00:1f.6 Ethernet controller [0200]: Intel I219-V [8086:15be]'
[[ ! -s $pkg_log ]] || fail "other PCI devices do not install a Broadcom driver" "$(cat "$pkg_log")"
pass "unrelated PCI devices install neither Broadcom package"
