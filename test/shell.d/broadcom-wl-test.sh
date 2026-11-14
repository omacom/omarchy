#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/fix-bcm43xx.sh"
all="$ROOT/install/hardware/all.sh"
other_packages="$ROOT/install/omarchy-other.packages"
migration="$ROOT/migrations/1792401200.sh"

grep -q 'run_logged .*hardware/fix-bcm43xx.sh' "$all" ||
  fail "the Broadcom wl setup runs during hardware setup"
grep -qx 'broadcom-wl-dkms' "$other_packages" ||
  fail "the ISO caches the Broadcom wl DKMS package"
pass "the Broadcom wl setup and its package are available during offline installation"

# Matching kernel headers are a base system guarantee, so the leaf must not
# install them itself.
! grep -q 'headers' "$leaf" ||
  fail "the Broadcom wl setup leaves kernel headers to the base install"
pass "the Broadcom wl setup leaves kernel headers to the base install"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
mkdir -p "$stub_bin"

cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash

if [[ -n ${WIFI_ID:-} ]]; then
  echo "03:00.0 Network controller [0280]: Broadcom Inc. Wireless [14e4:$WIFI_ID]"
fi
SH

cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash

printf 'omarchy-pkg-add\t%s\n' "$*" >>"$TEST_LOG"
SH

cat >"$stub_bin/omarchy-pkg-missing" <<'SH'
#!/bin/bash

(( ${PKG_INSTALLED:-0} == 0 ))
SH

cat >"$stub_bin/omarchy-state" <<'SH'
#!/bin/bash

printf 'omarchy-state\t%s\n' "$*" >>"$TEST_LOG"
SH

chmod +x "$stub_bin"/*

run_leaf() {
  local wifi_id="${1:-}"
  : >"$calls"

  WIFI_ID="$wifi_id" TEST_LOG="$calls" PATH="$stub_bin:$PATH" \
    bash -euo pipefail -c 'source "$1"' bash "$leaf" >/dev/null
}

for wifi_id in 43a0 43b1 4331; do
  run_leaf "$wifi_id"
  grep -Fxq $'omarchy-pkg-add\tbroadcom-wl-dkms' "$calls" ||
    fail "a supported Broadcom adapter installs wl" "14e4:$wifi_id"
done
pass "BCM4360, BCM4352, and BCM4331 install wl"

run_leaf 43a3
[[ ! -s $calls ]] || fail "an adapter supported by brcmfmac is left alone" "$(cat "$calls")"
pass "Broadcom adapters supported by another driver are left alone"

run_leaf
[[ ! -s $calls ]] || fail "systems without Broadcom Wi-Fi are left alone" "$(cat "$calls")"
pass "systems without Broadcom Wi-Fi are left alone"

# An install that predates the BCM4352 entry never ran the leaf for it, so the
# migration has to reach one. It runs as the user under omarchy-migrate, the
# context #6608 was about.
run_migration() {
  local wifi_id="${1:-}" installed="${2:-0}"
  : >"$calls"

  WIFI_ID="$wifi_id" PKG_INSTALLED="$installed" TEST_LOG="$calls" PATH="$stub_bin:$PATH" \
    bash -euo pipefail "$migration" >/dev/null
}

run_migration 43b1
grep -Fxq $'omarchy-pkg-add\tbroadcom-wl-dkms' "$calls" ||
  fail "the migration installs wl on a BCM4352 install that never got it" "$(cat "$calls")"
grep -Fxq $'omarchy-state\tset reboot-required' "$calls" ||
  fail "the migration asks for the reboot that loads the module" "$(cat "$calls")"
pass "the migration installs wl on an install that predates the BCM4352 entry"

# The driver is installed at setup time on the machines its leaf covered before,
# so only the installation needs the reboot, and a second user must not be told
# to reboot for a driver that is already there.
run_migration 43b1 1
[[ ! -s $calls ]] || fail "an install that already has the driver is left untouched" "$(cat "$calls")"
pass "the migration leaves an install that has the driver alone"

# A Mac whose wl was removed on purpose must not get it back: this is #7593,
# where the driver hard-freezes a 2011 MacBook Air on BCM4331.
for wifi_id in 4331 43a0; do
  run_migration "$wifi_id"
  [[ ! -s $calls ]] ||
    fail "the migration does not hand the covered Macs a driver they dropped on purpose" "$(cat "$calls")"
done
pass "the migration leaves the Mac adapters its leaf already covered alone"

run_migration
[[ ! -s $calls ]] || fail "the migration does nothing without Broadcom Wi-Fi" "$(cat "$calls")"
pass "the migration does nothing without Broadcom Wi-Fi"
