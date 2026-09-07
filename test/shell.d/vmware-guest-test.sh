#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

systemd-detect-virt() { printf '%s\n' "$guest"; [[ $guest != "none" ]]; }
omarchy-pkg-add() { printf 'package %s\n' "$*"; }
sudo() { printf 'sudo %s\n' "$*"; }

guest=vmware
result=$(source "$ROOT/install/hardware/vmware.sh")
[[ $result == $'package open-vm-tools\nsudo systemctl enable vmtoolsd.service vmware-vmblock-fuse.service' ]] ||
  fail "VMware guests install and enable guest services" "$result"
pass "VMware guests install and enable guest services"

for guest in none kvm oracle; do
  result=$(source "$ROOT/install/hardware/vmware.sh")
  [[ -z $result ]] || fail "$guest machines do not install VMware tools" "$result"
done
pass "other machines do not install VMware tools"
