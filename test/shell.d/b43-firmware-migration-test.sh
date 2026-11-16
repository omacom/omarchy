#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
migration="$ROOT/migrations/1789091260.sh"
stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash
printf '%b\n' "$FAKE_LSPCI"
SH

cat >"$stub_bin/pacman" <<'SH'
#!/bin/bash
[[ $1 == "-Q" ]] && grep -qx -- "${@: -1}" "$FAKE_INSTALLED"
SH

# Stands in for the AUR build: FAKE_YAY_STATUS=1 is the AUR down or the build failing.
cat >"$stub_bin/yay" <<'SH'
#!/bin/bash
printf 'yay %s\n' "$*" >>"$CALLS"
(( FAKE_YAY_STATUS == 0 )) && printf '%s\n' "${@: -1}" >>"$FAKE_INSTALLED"
exit "$FAKE_YAY_STATUS"
SH
chmod +x "$stub_bin"/*

bcm4322="03:00.0 Network controller [0280]: Broadcom Inc. and subsidiaries BCM4322 802.11a/b/g/n Wireless LAN Controller [14e4:432b] (rev 01)"
other="00:14.3 Network controller [0280]: Intel Corporation Wi-Fi 6E(802.11ax) AX211 [8086:51f0]"

run_migration() {
  local lspci="$1" installed="$2" yay_status="$3"

  : >"$test_tmp/calls"
  printf '%b' "$installed" >"$test_tmp/installed"
  env -i HOME="$test_tmp" PATH="$stub_bin:$ROOT/bin:/usr/bin" OMARCHY_PATH="$ROOT" \
    FAKE_LSPCI="$lspci" FAKE_INSTALLED="$test_tmp/installed" FAKE_YAY_STATUS="$yay_status" CALLS="$test_tmp/calls" \
    bash -euo pipefail "$migration" >/dev/null 2>&1
}

if run_migration "$bcm4322" "" 1; then
  fail "migration stays pending when b43-firmware cannot be installed"
fi
pass "migration stays pending when b43-firmware cannot be installed"

run_migration "$bcm4322" "" 0 || fail "migration installs b43-firmware on a BCM4322"
grep -q "b43-firmware" "$test_tmp/calls" || fail "migration builds b43-firmware on a BCM4322"
pass "migration installs b43-firmware on a BCM4322"

run_migration "$bcm4322" "b43-firmware\n" 1 || fail "migration completes when b43-firmware is already installed"
[[ ! -s $test_tmp/calls ]] || fail "migration builds nothing when b43-firmware is already installed"
pass "migration leaves an installed b43-firmware alone, even with the AUR down"

run_migration "$other" "" 1 || fail "migration completes on other hardware"
[[ ! -s $test_tmp/calls ]] || fail "migration builds nothing on other hardware"
pass "migration does nothing on other hardware"
