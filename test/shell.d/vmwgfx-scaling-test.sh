#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/user/hardware/fix-vmwgfx-scaling.sh"
shipped="$ROOT/config/hypr/monitors.lua"

grep -Fqx 'run_logged "$OMARCHY_INSTALL/user/hardware/fix-vmwgfx-scaling.sh"' "$ROOT/install/user/all.sh" ||
  fail "user setup registers the vmwgfx scaling leaf"
pass "user setup registers the vmwgfx scaling leaf"

migration="$ROOT/migrations/1791051321.sh"
[[ -n $migration ]] || fail "vmwgfx scaling migration exists"
pass "vmwgfx scaling migration exists"

# The leaf only rewrites the shipped defaults, so the test seeds the fake home
# from the template itself and pins the lines it expects to find there.
grep -Fqx 'local omarchy_monitor_scale = "auto"' "$shipped" ||
  fail "shipped monitors.lua still defaults the monitor scale to auto"
grep -Fqx 'local omarchy_gdk_scale = 2' "$shipped" ||
  fail "shipped monitors.lua still defaults the GDK scale to 2"
pass "shipped monitors.lua carries the defaults the vmwgfx scaling leaf rewrites"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
monitors="$home/.config/hypr/monitors.lua"

# A driver and what it has bound, in sysfs's own shape: "<driver>@<slot>@<card>"
# drives a display, "<driver>@<slot>" does not.
write_pci_drivers() {
  rm -rf "$test_tmp/drivers"
  mkdir -p "$test_tmp/drivers"

  local spec driver slot card rest
  for spec in "$@"; do
    driver=${spec%%@*}
    mkdir -p "$test_tmp/drivers/$driver"

    rest=${spec#"$driver"}
    rest=${rest#@}
    [[ -n $rest ]] || continue

    slot=${rest%%@*}
    mkdir -p "$test_tmp/drivers/$driver/$slot"

    card=${rest#"$slot"}
    card=${card#@}
    [[ -n $card ]] || continue

    mkdir -p "$test_tmp/drivers/$driver/$slot/drm/$card"
  done
}

seed_home() {
  rm -rf "$home"
  mkdir -p "$home/.config/hypr"
  cp "$shipped" "$monitors"
}

run_leaf() {
  HOME="$home" PATH="$ROOT/bin:$PATH" OMARCHY_PCI_DRIVERS_PATH="$test_tmp/drivers" \
    bash -eE -c 'source "$1"' bash "$leaf"
}

run_migration() {
  HOME="$home" PATH="$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" OMARCHY_PCI_DRIVERS_PATH="$test_tmp/drivers" \
    bash -euo pipefail "$migration"
}

# VMware SVGA adapter, the device every VMware guest has.
write_pci_drivers vmwgfx@0000:00:0f.0@card0

seed_home
run_leaf >/dev/null
grep -Fqx 'local omarchy_monitor_scale = 1' "$monitors" ||
  fail "a guest on vmwgfx starts at 1x monitor scale" "$(cat "$monitors")"
grep -Fqx 'local omarchy_gdk_scale = 1' "$monitors" ||
  fail "a guest on vmwgfx starts at 1x GDK scale" "$(cat "$monitors")"
pass "a guest on vmwgfx starts at 1x monitor and GDK scale"

cp "$monitors" "$test_tmp/after-first-run.lua"
run_leaf >/dev/null
cmp -s "$test_tmp/after-first-run.lua" "$monitors" || fail "vmwgfx scaling setup is idempotent"
pass "vmwgfx scaling setup is idempotent"

seed_home
sed -i 's|^local omarchy_monitor_scale = "auto"$|local omarchy_monitor_scale = 1.6|' "$monitors"
cp "$monitors" "$test_tmp/user-chosen.lua"
run_leaf >/dev/null
cmp -s "$test_tmp/user-chosen.lua" "$monitors" ||
  fail "vmwgfx scaling setup leaves a user-chosen scale alone" "$(diff "$test_tmp/user-chosen.lua" "$monitors" || true)"
pass "vmwgfx scaling setup leaves a user-chosen scale alone"

# AMD integrated graphics.
write_pci_drivers amdgpu@0000:00:02.0@card0
seed_home
run_leaf >/dev/null
cmp -s "$shipped" "$monitors" || fail "vmwgfx scaling setup ignores other machines"
pass "vmwgfx scaling setup ignores other machines"

write_pci_drivers vmwgfx@0000:00:0f.0@card0
rm -rf "$home"
mkdir -p "$home"
run_leaf >/dev/null || fail "vmwgfx scaling setup tolerates a missing monitors.lua"
[[ ! -e $monitors ]] || fail "vmwgfx scaling setup does not create monitors.lua"
pass "vmwgfx scaling setup tolerates a missing monitors.lua"

seed_home
run_migration >/dev/null
grep -Fqx 'local omarchy_monitor_scale = 1' "$monitors" ||
  fail "migration starts existing vmwgfx guests at 1x" "$(cat "$monitors")"
grep -Fqx 'local omarchy_gdk_scale = 1' "$monitors" ||
  fail "migration starts existing vmwgfx guests at 1x GDK scale" "$(cat "$monitors")"
pass "migration starts existing vmwgfx guests at 1x"

cp "$monitors" "$test_tmp/after-migration.lua"
run_migration >/dev/null
cmp -s "$test_tmp/after-migration.lua" "$monitors" || fail "migration is idempotent"
pass "migration is idempotent"
