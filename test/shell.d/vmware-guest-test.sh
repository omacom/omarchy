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

systemctl() {
  [[ ${TOOLS_HEALTHY:-0} == "1" ]]
}
guest=vmware
result=$(source "$ROOT/migrations/1790241729.sh")
[[ $result == *"sudo systemctl enable --now vmtoolsd.service vmware-vmblock-fuse.service"* ]] || fail "existing VMware guests repair their services"
result=$(TOOLS_HEALTHY=1 source "$ROOT/migrations/1790241729.sh")
[[ $result != *"sudo "* ]] || fail "a later user on a repaired guest needs no privileges"
for guest in none kvm oracle; do
  result=$(source "$ROOT/migrations/1790241729.sh")
  [[ $result != *"package "* && $result != *"sudo "* ]] || fail "$guest migrations do not repair VMware tools"
done
pass "the VMware migration repairs existing guests and skips privileged work on healthy machines"
