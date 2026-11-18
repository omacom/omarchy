#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

dmi="$test_tmp/dmi"
stub_bin="$test_tmp/bin"
mkdir -p "$dmi" "$stub_bin"
sed "s|/sys/class/dmi/id|$dmi|g" "$ROOT/bin/omarchy-hw-match" >"$stub_bin/omarchy-hw-match"

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo\t%s\n' "$*" >>"$TEST_LOG"
if [[ $1 == limine-mkinitcpio ]]; then
  limine-mkinitcpio
  exit
fi
"$@"
SH

cat >"$stub_bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
if [[ -n ${FAIL_KERNEL:-} ]]; then
  echo "mkinitcpio failed for kernel $FAIL_KERNEL"
fi
exit "${REBUILD_STATUS:-0}"
SH

cat >"$stub_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$stub_bin/omarchy-state" <<'SH'
#!/bin/bash
printf 'state %s\n' "$*" >>"$TEST_LOG"
SH

chmod +x "$stub_bin"/*

model() {
  printf '%s\n' "$1" >"$dmi/product_name"
  printf '%s\n' "${2:-}" >"$dmi/product_family"
}

# Copies keep the real helpers and rewrite only the absolute paths the scripts
# would otherwise write on this machine.
migration_copy() {
  local work=$1
  local script=$work/migration.sh
  sed \
    -e "s|/proc/cmdline|$work/cmdline|g" \
    -e "s|/etc/udev/rules.d|$work/udev|g" \
    -e "s|/etc/limine-entry-tool.d|$work/limine|g" \
    -e "s|/var/lib/omarchy/migrations/1791387391|$work/marker|g" \
    "$ROOT/migrations/1791387391.sh" >"$script"
  grep -qE '/etc/|/proc/cmdline|/var/lib/omarchy|/sys/class/dmi' "$script" &&
    fail "the migration copy stays off this machine" "$(grep -nE '/etc/|/proc/|/var/lib/|/sys/' "$script")"
  printf '%s\n' "$script"
}

leaf_copy() {
  local work=$1
  local script=$work/leaf.sh
  sed \
    -e "s|/etc/udev/rules.d|$work/udev|g" \
    -e "s|/etc/limine-entry-tool.d|$work/limine|g" \
    -e "s|/etc/systemd/system|$work/systemd|g" \
    -e "s|\"/sys/bus/pci/devices/0000:01:00.0\"|\"$work/pci\"|g" \
    "$ROOT/install/hardware/apple/fix-suspend-nvme.sh" >"$script"
  if grep -q '/etc/' "$script" || grep -q '"/sys/bus/pci/devices/0000:01:00.0"' "$script"; then
    fail "the leaf copy stays off this machine" "$(grep -n '/etc/\|/sys/bus/pci' "$script")"
  fi
  printf '%s\n' "$script"
}

run_migration() {
  local name=$1 model_name=$2 cmdline=${3:-quiet}
  local work=$test_tmp/$name
  rm -rf "$work"
  mkdir -p "$work"
  printf '%s\n' "$cmdline" >"$work/cmdline"
  model "$model_name"
  : >"$test_tmp/calls"
  local status=0
  PATH="$stub_bin:$PATH" TEST_LOG="$test_tmp/calls" \
    bash -euo pipefail "$(migration_copy "$work")" >"$work/out" 2>"$work/err" || status=$?
  printf '%s\n' "$status"
}

run_leaf() {
  local name=$1 model_name=$2 vendor=$3
  local work=$test_tmp/leaf-$name
  rm -rf "$work"
  mkdir -p "$work/pci"
  printf '%s\n' "$vendor" >"$work/pci/vendor"
  model "$model_name"
  : >"$test_tmp/calls"
  PATH="$stub_bin:$PATH" TEST_LOG="$test_tmp/calls" \
    bash -eE -o pipefail "$(leaf_copy "$work")" >/dev/null
}

# A reported kernel failure exits 0 from limine-mkinitcpio. The marker must stay
# absent so the next run tries again.
model MacBookPro14,1
status=$(FAIL_KERNEL=linux-omarchy run_migration failed MacBookPro14,1)
[[ $status == 1 ]] || fail "a reported kernel failure leaves the migration pending" "status $status"
[[ ! -e $test_tmp/failed/marker ]] || fail "a reported kernel failure writes no rebuild marker"
grep -q 'boot image was not rebuilt' "$test_tmp/failed/err" || fail "a reported kernel failure says to run the migration again" "$(<"$test_tmp/failed/err")"
! grep -q 'reboot-required' "$test_tmp/calls" || fail "a reported kernel failure does not ask for a reboot"
pass "a boot image limine-mkinitcpio reported as failed stays pending"

status=$(REBUILD_STATUS=1 run_migration hard-fail MacBookPro14,1)
[[ $status != 0 ]] || fail "a rebuild that exits nonzero leaves the migration pending"
[[ ! -e $test_tmp/hard-fail/marker ]] || fail "a rebuild that exits nonzero writes no rebuild marker"
pass "a rebuild that exits nonzero stays pending"

status=$(run_migration ok MacBookPro14,1)
[[ $status == 0 ]] || fail "a MacBookPro14,1 migration succeeds" "status $status $(<"$test_tmp/ok/err")"
[[ -e $test_tmp/ok/marker ]] || fail "a successful rebuild records its marker"
grep -q 'mem_sleep_default=s2idle' "$test_tmp/ok/limine/apple-s3x-suspend.conf" || fail "a MacBookPro14,1 gets the boot parameters"
grep -q 'reboot-required' "$test_tmp/calls" || fail "a MacBookPro14,1 is asked to reboot"
pass "a MacBookPro14,1 gets the boot parameters and a reboot notice"

status=$(run_migration already MacBookPro14,1 "mem_sleep_default=s2idle nvme_core.default_ps_max_latency_us=0 intel_idle.max_cstate=1")
[[ $status == 0 ]] || fail "a MacBookPro14,1 that already has the parameters succeeds"
[[ ! -e $test_tmp/already/marker ]] || fail "an up-to-date boot is not rebuilt"
! grep -q 'reboot-required' "$test_tmp/calls" || fail "an up-to-date boot is not asked to reboot"
pass "a MacBookPro14,1 that already booted the parameters is left alone"

status=$(run_migration fourteen-two MacBookPro14,2)
[[ $status == 0 ]] || fail "a MacBookPro14,2 migration succeeds"
[[ -e $test_tmp/fourteen-two/udev/99-omarchy-apple-nvme-d3cold.rules ]] || fail "a MacBookPro14,2 gets the udev rule"
[[ ! -e $test_tmp/fourteen-two/limine/apple-s3x-suspend.conf ]] || fail "a MacBookPro14,2 keeps deep sleep"
pass "a MacBookPro14,2 gets the udev rule and keeps its sleep mode"

for skipped in MacBookPro14,3 MacBookPro14,10 MacBook8,1; do
  status=$(run_migration "skip-$skipped" "$skipped")
  [[ $status == 0 ]] || fail "$skipped migration succeeds" "status $status"
  [[ ! -e $test_tmp/skip-$skipped/udev ]] || fail "$skipped is left alone"
done
pass "models outside the Apple NVMe list are left alone"

run_leaf fourteen-one MacBookPro14,1 0x106b
[[ -e $test_tmp/leaf-fourteen-one/limine/apple-s3x-suspend.conf ]] || fail "the leaf installs the MacBookPro14,1 boot parameters"
unit=$(<"$test_tmp/leaf-fourteen-one/systemd/omarchy-nvme-suspend-fix.service")
[[ $unit == *'0000:01:00.0/d3cold_allowed'* && $unit != *'\\:'* ]] || fail "the leaf unit names the controller without escaped colons" "$unit"
pass "the leaf installs the MacBookPro14,1 fix when 01:00.0 is Apple's controller"

run_leaf fourteen-two MacBookPro14,2 0x106b
[[ ! -e $test_tmp/leaf-fourteen-two/limine ]] || fail "the leaf does not change sleep mode on a MacBookPro14,2"
[[ -e $test_tmp/leaf-fourteen-two/systemd/omarchy-nvme-suspend-fix.service ]] || fail "the leaf still keeps Apple's controller out of D3cold on a MacBookPro14,2"
pass "the leaf leaves a MacBookPro14,2 on deep sleep"

run_leaf other-controller MacBookPro14,1 0x144d
[[ -e $test_tmp/leaf-other-controller/limine/apple-s3x-suspend.conf ]] || fail "the boot parameters do not depend on the controller vendor"
[[ ! -e $test_tmp/leaf-other-controller/systemd ]] || fail "a controller that is not Apple's is left alone"
pass "a device at 01:00.0 that is not Apple's controller gets no D3cold service"

for skipped in MacBookPro14,3 MacBookPro14,10 MacBook8,1; do
  run_leaf "skip-$skipped" "$skipped" 0x106b
  [[ ! -e $test_tmp/leaf-skip-$skipped/udev ]] || fail "the leaf leaves $skipped alone"
done
pass "the leaf leaves models outside the Apple NVMe list alone"
