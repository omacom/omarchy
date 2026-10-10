#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/fix-suspend-nvme.sh"
migration="$ROOT/migrations/1789274148.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
unit="$test_tmp/etc/systemd/system/omarchy-nvme-suspend-fix.service"
mkdir -p "$stub_bin" "$test_tmp/dmi" "$test_tmp/pci"

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
if [[ $1 != "systemctl" ]]; then
  "$@"
fi
SH

chmod +x "$stub_bin"/*

# The leaf reads the model and the PCI vendor from absolute paths and writes the
# unit to /etc, so run a copy with all three redirected into the sandbox.
run_leaf() {
  local model="$1" vendor="$2"
  rm -rf "${test_tmp:?}/etc"
  : >"$calls"
  printf '%s\n' "$model" >"$test_tmp/dmi/product_name"
  printf '%s\n' "$vendor" >"$test_tmp/pci/vendor"

  local script="$test_tmp/leaf.sh"
  sed -e "s|/sys/class/dmi/id/product_name|$test_tmp/dmi/product_name|g" \
      -e "s|\"/sys/bus/pci/devices/0000:01:00.0\"|\"$test_tmp/pci\"|g" \
      -e "s|/etc/systemd/system|$test_tmp/etc/systemd/system|g" \
      "$leaf" >"$script"

  PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    bash -eE -o pipefail -c 'source "$1"' bash "$script" </dev/null
}

# The models Dunedan/mbp-2016-linux lists with Apple's NVMe controller at 01:00.0.
for model in MacBook8,1 MacBook9,1 MacBook10,1 MacBookPro13,1 MacBookPro13,2 MacBookPro14,1 MacBookPro14,2; do
  run_leaf "$model" 0x106b >/dev/null
  grep -q 'd3cold_allowed' "$unit" 2>/dev/null || fail "a Mac with Apple's NVMe controller gets the fix" "$model"
  grep -Fq $'sudo\tsystemctl\tenable\tomarchy-nvme-suspend-fix.service' "$calls" ||
    fail "the fix is enabled" "$model: $(cat "$calls")"
done
pass "every Mac with Apple's NVMe controller gets the fix"

# The unit used to escape the colons, which systemd warns about on every boot.
! grep -q '\\:' "$unit" || fail "the unit has no escape sequences systemd ignores" "$(cat "$unit")"
pass "the unit has no escape sequences systemd ignores"

# 15-inch models: 01:00.0 exists, but it is the AMD GPU.
for model in MacBookPro13,3 MacBookPro14,3; do
  run_leaf "$model" 0x1002 >/dev/null
  [[ ! -e $unit ]] || fail "a 15-inch MacBook Pro is left alone" "$model"
  [[ ! -s $calls ]] || fail "a 15-inch MacBook Pro escalates nothing" "$model: $(cat "$calls")"
done
pass "15-inch MacBook Pros, whose 01:00.0 is the GPU, are left alone"

# A 13-inch board whose 01:00.0 is not Apple's controller does not get the fix blind.
run_leaf MacBookPro14,2 0x144d >/dev/null
[[ ! -e $unit ]] || fail "a replaced or unexpected controller is left alone"
pass "a device at 01:00.0 that is not Apple's controller is left alone"

run_migration() {
  local vendor="$1"
  : >"$calls"
  printf '%s\n' "$vendor" >"$test_tmp/pci/vendor"

  PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    OMARCHY_NVME_SUSPEND_UNIT="$unit" \
    OMARCHY_NVME_SUSPEND_PCI_VENDOR="$test_tmp/pci/vendor" \
    bash -euo pipefail "$migration" >/dev/null
}

write_old_unit() {
  mkdir -p "$(dirname "$unit")"
  printf '%s\n' '[Service]' "ExecStart=/bin/bash -c 'echo 0 > /sys/bus/pci/devices/0000\:01\:00.0/d3cold_allowed'" >"$unit"
}

# A 15-inch install from before the fix carries the service aimed at its GPU.
write_old_unit
run_migration 0x1002
[[ ! -e $unit ]] || fail "the migration removes the service from a 15-inch MacBook Pro"
grep -Fq $'sudo\tsystemctl\tdisable\tomarchy-nvme-suspend-fix.service' "$calls" ||
  fail "the migration disables the service" "$(cat "$calls")"
pass "the migration removes the service where 01:00.0 is not Apple's controller"

run_migration 0x1002
[[ ! -s $calls ]] || fail "the migration is idempotent" "$(cat "$calls")"
pass "the migration is idempotent"

# The machines the fix was written for keep it.
write_old_unit
run_migration 0x106b
[[ -f $unit ]] || fail "the migration keeps the service on a Mac with Apple's NVMe controller"
[[ ! -s $calls ]] || fail "the migration escalates nothing on those Macs" "$(cat "$calls")"
pass "the migration keeps the service on Macs with Apple's NVMe controller"

rm -rf "${test_tmp:?}/etc"
run_migration 0x8086
[[ ! -s $calls ]] || fail "the migration skips machines that never had the service" "$(cat "$calls")"
pass "the migration skips machines that never had the service"
