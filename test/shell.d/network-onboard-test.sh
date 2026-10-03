#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# A stand-in for /sys/class/net. Physical interfaces are plain directories;
# kernel-synthesized ones resolve through a "virtual" path the way sysfs links
# lo, docker0, and veth pairs back to /sys/devices/virtual/net.
net_root="$tmp/net"
devices="$tmp/devices"
mkdir -p "$net_root" "$devices/virtual/net/docker0" "$devices/pci/net"

mkdir -p "$net_root/wlan0/wireless"
echo "aa:bb:cc:dd:ee:ff" >"$net_root/wlan0/address"

mkdir -p "$net_root/eth0"
echo "11:22:33:44:55:66" >"$net_root/eth0/address"

echo "de:ad:be:ef:00:01" >"$devices/virtual/net/docker0/address"
ln -s "$devices/virtual/net/docker0" "$net_root/docker0"

# No address file at all: sysfs exposes such entries, and reading one would
# print an empty MAC rather than skipping the interface.
mkdir -p "$net_root/bond0"

run_onboard() {
  OMARCHY_NETWORK_SYSFS_ROOT="$net_root" "$ROOT/bin/omarchy-network-onboard" "$@"
}

macs=$(run_onboard --macs-only)

[[ $macs == *$'wlan0\taa:bb:cc:dd:ee:ff'* ]] ||
  fail "onboard lists physical wireless interfaces" "missing wlan0 in:\n$macs"
pass "onboard lists physical wireless interfaces"

[[ $macs == *$'eth0\t11:22:33:44:55:66'* ]] ||
  fail "onboard lists physical wired interfaces" "missing eth0 in:\n$macs"
pass "onboard lists physical wired interfaces"

# The whole point of the command is an address a network administrator will
# accept. A bridge MAC registered against a port grants nothing.
[[ $macs != *docker0* ]] ||
  fail "onboard omits kernel-synthesized interfaces" "docker0 leaked into:\n$macs"
pass "onboard omits kernel-synthesized interfaces"

[[ $macs != *bond0* ]] ||
  fail "onboard omits interfaces with no address" "bond0 leaked into:\n$macs"
pass "onboard omits interfaces with no address"

guide=$(run_onboard)

[[ $guide == *"aa:bb:cc:dd:ee:ff"* ]] ||
  fail "guide prints the address before the join instructions" "address missing from guide"
pass "guide prints the address before the join instructions"

# The enterprise recipe is meant to be pasted, so it has to name a real radio
# rather than a placeholder when one is present.
[[ $guide == *"ifname wlan0"* ]] ||
  fail "guide names the detected Wi-Fi interface" "expected 'ifname wlan0' in the enterprise recipe"
pass "guide names the detected Wi-Fi interface"

[[ $guide == *"Wi-Fi"*"wlan0"* && $guide == *"Ethernet"*"eth0"* ]] ||
  fail "guide labels each interface by kind" "kind labels missing"
pass "guide labels each interface by kind"

# Breaking out of a `while read` on the reading side of a pipeline leaves the
# producer writing into a closed pipe, and pipefail turns that SIGPIPE (141)
# into a failure. The break only reaches the producer once the pipe is full, so
# the listing has to exceed the 64KB buffer: padded names get there in a few
# hundred entries, where realistic ones would need thousands.
many="$tmp/many"
mkdir -p "$many"
pad=$(printf 'x%.0s' {1..200})
for i in $(seq 1 400); do
  mkdir -p "$many/wlan$i$pad/wireless"
  echo "aa:bb:cc:00:00:01" >"$many/wlan$i$pad/address"
done
# The full guide, not --macs-only: the interface the enterprise recipe names is
# resolved after the --macs-only path has already returned.
set +e
timeout 60 setsid env OMARCHY_NETWORK_SYSFS_ROOT="$many" \
  "$ROOT/bin/omarchy-network-onboard" >/dev/null 2>&1
status=$?
set -e
(( status == 0 )) ||
  fail "onboard survives many interfaces without SIGPIPE" "exited $status"
pass "onboard survives many interfaces without SIGPIPE"

# first-run opens this guide with no terminal attached; a prompt that blocks
# there would hang the login sequence.
set +e
timeout 20 setsid env OMARCHY_NETWORK_SYSFS_ROOT="$net_root" \
  "$ROOT/bin/omarchy-network-onboard" >/dev/null 2>&1
status=$?
set -e
(( status == 0 )) ||
  fail "guide completes with no controlling terminal" "exited $status"
pass "guide completes with no controlling terminal"

set +e
run_onboard --nonsense >/dev/null 2>&1
status=$?
set -e
(( status == 2 )) ||
  fail "onboard rejects unknown options" "expected exit 2, got $status"
pass "onboard rejects unknown options"
