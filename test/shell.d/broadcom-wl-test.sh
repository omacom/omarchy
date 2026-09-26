#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/fix-bcm43xx.sh"
all="$ROOT/install/hardware/all.sh"
other_packages="$ROOT/install/omarchy-other.packages"

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

printf '%s\n' "$*" >>"$TEST_LOG"
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
  grep -Fxq 'broadcom-wl-dkms' "$calls" ||
    fail "a supported Broadcom adapter installs wl" "14e4:$wifi_id"
done
pass "BCM4360, BCM4352, and BCM4331 install wl"

run_leaf 43a3
[[ ! -s $calls ]] || fail "an adapter supported by brcmfmac is left alone" "$(cat "$calls")"
pass "Broadcom adapters supported by another driver are left alone"

run_leaf
[[ ! -s $calls ]] || fail "systems without Broadcom Wi-Fi are left alone" "$(cat "$calls")"
pass "systems without Broadcom Wi-Fi are left alone"
