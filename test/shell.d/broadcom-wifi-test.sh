#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

fix_bcm="$ROOT/install/hardware/fix-bcm43xx.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

# Real lspci keeps printing well past any match, so a grep -q consumer can be
# killed by SIGPIPE; keep the stub chatty for the same reason as the T2 test.
cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash
[[ -n ${STUB_WIFI_ID:-} ]] &&
  echo "04:00.0 Network controller [0280]: Broadcom Inc. and subsidiaries Wireless [$STUB_WIFI_ID] (rev 03)"
for _ in {1..4096}; do
  echo '02:00.0 Host bridge [0600]: Filler Device [ffff:0000]'
done
SH
chmod +x "$stub_bin/lspci"

installs_driver_for() {
  local wifi_id=${1:-}
  local calls="$test_tmp/calls-$RANDOM"

  PATH="$stub_bin:$PATH" \
  STUB_WIFI_ID="$wifi_id" \
  OMARCHY_TEST_CALLS="$calls" \
    "$BASH" -c '
      omarchy-pkg-add() { printf "%s\n" "$@" >>"$OMARCHY_TEST_CALLS"; }
      source "$1"
    ' _ "$fix_bcm" >/dev/null 2>&1

  [[ -f $calls ]] && grep -qx 'broadcom-wl-dkms' "$calls"
}

# BCM4321 is the 2007-2008 iMac/MacBook card. b43 can drive it, but Omarchy
# standardized on the wl driver, which covers it too.
for id in 14e4:4328 14e4:4329 14e4:432a; do
  installs_driver_for "$id" ||
    fail "BCM4321 ($id) gets broadcom-wl-dkms"
done
pass "BCM4321 device ids pull in broadcom-wl-dkms"

# Regression guard: the ids that already worked must keep working.
installs_driver_for 14e4:43a0 || fail "BCM4360 still gets broadcom-wl-dkms"
installs_driver_for 14e4:4331 || fail "BCM4331 still gets broadcom-wl-dkms"
pass "BCM4360 and BCM4331 keep their driver"

# A Broadcom wireless card the wl driver does not claim must not drag it in.
! installs_driver_for 14e4:4353 ||
  fail "an unsupported Broadcom id does not install broadcom-wl-dkms"
! installs_driver_for ||
  fail "a machine with no Broadcom wireless installs nothing"
pass "non-matching hardware installs no Broadcom driver"
