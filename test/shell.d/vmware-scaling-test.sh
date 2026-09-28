#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/user/hardware/fix-vmware-scaling.sh"
shipped="$ROOT/config/hypr/monitors.lua"

grep -Fqx 'run_logged "$OMARCHY_INSTALL/user/hardware/fix-vmware-scaling.sh"' "$ROOT/install/user/all.sh" ||
  fail "user setup registers the VMware scaling leaf"
pass "user setup registers the VMware scaling leaf"

migration="$ROOT/migrations/1789452621.sh"
[[ -n $migration ]] || fail "VMware scaling migration exists"
pass "VMware scaling migration exists"

# The leaf only rewrites the shipped defaults, so the test seeds the fake home
# from the template itself and pins the lines it expects to find there.
grep -Fqx 'local omarchy_monitor_scale = "auto"' "$shipped" ||
  fail "shipped monitors.lua still defaults the monitor scale to auto"
grep -Fqx 'local omarchy_gdk_scale = 2' "$shipped" ||
  fail "shipped monitors.lua still defaults the GDK scale to 2"
pass "shipped monitors.lua carries the defaults the VMware scaling leaf rewrites"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
monitors="$home/.config/hypr/monitors.lua"

# Each argument is a PCI device as "vendor:class", in sysfs's own format.
write_pci_devices() {
  rm -rf "$test_tmp/devices"
  mkdir -p "$test_tmp/devices"

  local index=0
  local spec
  for spec in "$@"; do
    local slot
    slot=$(printf '0000:%02x:00.0' "$index")
    mkdir -p "$test_tmp/devices/$slot"
    printf '%s\n' "${spec%%:*}" >"$test_tmp/devices/$slot/vendor"
    printf '%s\n' "${spec##*:}" >"$test_tmp/devices/$slot/class"
    index=$((index + 1))
  done
}

seed_home() {
  rm -rf "$home"
  mkdir -p "$home/.config/hypr"
  cp "$shipped" "$monitors"
}

run_leaf() {
  HOME="$home" PATH="$ROOT/bin:$PATH" OMARCHY_PCI_DEVICES_PATH="$test_tmp/devices" \
    bash -eE -c 'source "$1"' bash "$leaf"
}

run_migration() {
  HOME="$home" PATH="$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" OMARCHY_PCI_DEVICES_PATH="$test_tmp/devices" \
    bash -euo pipefail "$migration"
}

# VMware SVGA adapter, the device every VMware guest has.
write_pci_devices 0x15ad:0x030000

seed_home
run_leaf >/dev/null
grep -Fqx 'local omarchy_monitor_scale = 1' "$monitors" ||
  fail "a VMware guest starts at 1x monitor scale" "$(cat "$monitors")"
grep -Fqx 'local omarchy_gdk_scale = 1' "$monitors" ||
  fail "a VMware guest starts at 1x GDK scale" "$(cat "$monitors")"
pass "a VMware guest starts at 1x monitor and GDK scale"

cp "$monitors" "$test_tmp/after-first-run.lua"
run_leaf >/dev/null
cmp -s "$test_tmp/after-first-run.lua" "$monitors" || fail "VMware scaling setup is idempotent"
pass "VMware scaling setup is idempotent"

seed_home
sed -i 's|^local omarchy_monitor_scale = "auto"$|local omarchy_monitor_scale = 1.6|' "$monitors"
cp "$monitors" "$test_tmp/user-chosen.lua"
run_leaf >/dev/null
cmp -s "$test_tmp/user-chosen.lua" "$monitors" ||
  fail "VMware scaling setup leaves a user-chosen scale alone" "$(diff "$test_tmp/user-chosen.lua" "$monitors" || true)"
pass "VMware scaling setup leaves a user-chosen scale alone"

# AMD integrated graphics.
write_pci_devices 0x1002:0x030000
seed_home
run_leaf >/dev/null
cmp -s "$shipped" "$monitors" || fail "VMware scaling setup ignores other machines"
pass "VMware scaling setup ignores other machines"

write_pci_devices 0x15ad:0x030000
rm -rf "$home"
mkdir -p "$home"
run_leaf >/dev/null || fail "VMware scaling setup tolerates a missing monitors.lua"
[[ ! -e $monitors ]] || fail "VMware scaling setup does not create monitors.lua"
pass "VMware scaling setup tolerates a missing monitors.lua"

seed_home
run_migration >/dev/null
grep -Fqx 'local omarchy_monitor_scale = 1' "$monitors" ||
  fail "migration starts existing VMware guests at 1x" "$(cat "$monitors")"
grep -Fqx 'local omarchy_gdk_scale = 1' "$monitors" ||
  fail "migration starts existing VMware guests at 1x GDK scale" "$(cat "$monitors")"
pass "migration starts existing VMware guests at 1x"

cp "$monitors" "$test_tmp/after-migration.lua"
run_migration >/dev/null
cmp -s "$test_tmp/after-migration.lua" "$monitors" || fail "migration is idempotent"
pass "migration is idempotent"
