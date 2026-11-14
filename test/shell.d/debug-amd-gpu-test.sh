#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command timeout

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
export OMARCHY_PCI_DEVICES_PATH="$tmp_dir/PCI devices"

# Load the real collector functions without running unrelated system probes or
# writing the complete debug log. Reuse the implementation without duplicating it.
collector="$tmp_dir/collector.sh"
sed -n '/^amd_gpu_[[:alnum:]_]*() {/,/^}/p' "$ROOT/bin/omarchy-debug" >"$collector"

counter_files=(gpu_busy_percent mem_info_vram_total mem_info_vram_used mem_info_gtt_total mem_info_gtt_used)
counter_labels=("GPU busy" "Driver VRAM total" "Driver VRAM used" "GTT total" "GTT used")

reset_fixture() {
  rm -rf "$OMARCHY_PCI_DEVICES_PATH"
  mkdir -p "$OMARCHY_PCI_DEVICES_PATH" "$tmp_dir/drivers/amdgpu" "$tmp_dir/drivers/radeon"
}

add_device() {
  local device_dir="$OMARCHY_PCI_DEVICES_PATH/$1"
  mkdir -p "$device_dir/power"
  printf '%s\n' "$2" >"$device_dir/vendor"
  printf '%s\n' "$3" >"$device_dir/device"
  printf '%s\n' "$4" >"$device_dir/class"
  if [[ $5 != "-" ]]; then
    ln -s "$tmp_dir/drivers/$5" "$device_dir/driver"
  fi
  if [[ $6 != "-" ]]; then
    printf '%s\n' "$6" >"$device_dir/power/runtime_status"
  fi
  printf '7\n' >"$device_dir/gpu_busy_percent"
  printf '536870912\n' >"$device_dir/mem_info_vram_total"
  printf '134217728\n' >"$device_dir/mem_info_vram_used"
  printf '67140354048\n' >"$device_dir/mem_info_gtt_total"
  printf '1073741824\n' >"$device_dir/mem_info_gtt_used"
}

protect_counters() {
  local field
  for field in "${counter_files[@]}"; do
    rm "$OMARCHY_PCI_DEVICES_PATH/$1/$field"
    # No writer exists. Opening any counter for reading blocks, including
    # Bash's builtin read, and run_collector's timeout catches that attempt.
    mkfifo "$OMARCHY_PCI_DEVICES_PATH/$1/$field"
  done
}

run_collector() {
  local description="$1" status=0
  timeout --kill-after=1s 5s bash -euo pipefail -c '
    source "$1"
    amd_gpu_diagnostics
  ' _ "$collector" >"$tmp_dir/output" 2>"$tmp_dir/errors" || status=$?
  [[ $status == "0" ]] || fail "$description" "collector exited $status (124 means a blocked read): $(cat "$tmp_dir/errors")"
  [[ ! -s $tmp_dir/errors ]] || fail "$description: no unexpected stderr" "$(cat "$tmp_dir/errors")"
}

expect_line() {
  grep -Fxq -- "$1" "$tmp_dir/output" || fail "$2" "$(cat "$tmp_dir/output")"
}

expect_no_counters() {
  ! grep -Eq '^  (GPU busy|Driver VRAM|GTT)' "$tmp_dir/output" ||
    fail "$1: no live values printed" "$(cat "$tmp_dir/output")"
}

reset_fixture
add_device 0000:c3:00.0 0x1002 0x1586 0x038000 amdgpu active
run_collector "active Display-class APU"
for line in \
  'PCI address: 0000:c3:00.0' \
  '  PCI ID: 1002:1586' \
  '  PCI class: 038000' \
  '  Driver: amdgpu' \
  '  Runtime state: active' \
  '  GPU busy: 7%' \
  '  Driver VRAM total: 536870912 bytes' \
  '  Driver VRAM used: 134217728 bytes' \
  '  GTT total: 67140354048 bytes' \
  '  GTT used: 1073741824 bytes' \
  'VRAM/GTT are driver pools, not an additive breakdown of system RAM.'; do
  expect_line "$line" "active APU reports identity and separate memory pools"
done
pass "active 038000 APU reports identity, runtime state, activity, and separate VRAM/GTT pools"

for class in 0x030000 0x030200; do
  reset_fixture
  add_device 0000:01:00.0 0x1002 0x73bf "$class" amdgpu active
  run_collector "AMD display class $class"
  expect_line "  PCI class: ${class#0x}" "AMD display class $class is detected"
  expect_line '  GPU busy: 7%' "AMD display class $class reads counters"
  pass "AMD display class $class is detected"
done

reset_fixture
add_device 0000:c3:00.0 0x1002 0x1586 0x038000 amdgpu unsupported
run_collector "runtime PM unsupported"
expect_line '  Runtime state: unsupported' "unsupported PM state is reported"
expect_line '  GTT used: 1073741824 bytes' "unsupported PM state permits counters"
pass "unsupported runtime PM state permits live counters"

# Calibrate the guard: the real counter reader must block on a protected file.
# This ensures that a broken runtime guard cannot pass on output checks alone.
reset_fixture
add_device 0000:c3:00.0 0x1002 0x1586 0x038000 amdgpu suspended
protect_counters 0000:c3:00.0
status=0
timeout --kill-after=1s 1s bash -euo pipefail -c '
  source "$1"
  : >"$2"
  amd_gpu_counter "GPU busy" "$OMARCHY_PCI_DEVICES_PATH/0000:c3:00.0/gpu_busy_percent" "%"
' _ "$collector" "$tmp_dir/probe-started" >"$tmp_dir/output" 2>"$tmp_dir/errors" || status=$?
[[ -f $tmp_dir/probe-started ]] || fail "counter-read sentinel reaches the real reader"
[[ $status == "124" ]] || fail "counter-read sentinel detects the real reader" "expected timeout 124, got $status"
pass "counter-read sentinel detects the real reader"

for state in suspended suspending resuming unexpected - ""; do
  reset_fixture
  add_device 0000:c3:00.0 0x1002 0x1586 0x038000 amdgpu "$state"
  protect_counters 0000:c3:00.0
  expected_state="$state"
  if [[ $state == "-" || -z $state ]]; then
    expected_state="unavailable"
  fi
  if [[ $state == "-" ]]; then
    description="missing runtime state skips every counter read"
  else
    description="runtime state ${state:-empty} skips every counter read"
  fi
  run_collector "$description"
  expect_line "  Runtime state: $expected_state" "$description"
  expect_line '  Live counters: skipped (device is not known to be active).' "$description"
  expect_no_counters "$description"
  pass "$description"
done

for driver in radeon -; do
  reset_fixture
  add_device 0000:c3:00.0 0x1002 0x1586 0x038000 "$driver" active
  protect_counters 0000:c3:00.0
  expected_driver="$driver"
  if [[ $driver == "-" ]]; then
    expected_driver="unbound or unavailable"
  fi
  description="driver $expected_driver skips every counter read"
  run_collector "$description"
  expect_line "  Driver: $expected_driver" "$description"
  expect_line '  AMDGPU counters: unavailable for this driver.' "$description"
  expect_no_counters "$description"
  pass "$description"
done

reset_fixture
add_device 0000:01:00.0 0x1002 0x73bf 0x030000 amdgpu active
add_device 0000:c3:00.0 0x1002 0x1586 0x038000 amdgpu active
printf '268435456\n' >"$OMARCHY_PCI_DEVICES_PATH/0000:c3:00.0/mem_info_vram_used"
run_collector "multiple active controllers"
(( $(grep -c '^PCI address:' "$tmp_dir/output") == 2 )) || fail "both active controllers are reported"
expect_line '  Driver VRAM used: 134217728 bytes' "first controller's counters are present"
expect_line '  Driver VRAM used: 268435456 bytes' "second controller's counters are present"
pass "multiple active controllers report their counters"

printf 'suspended\n' >"$OMARCHY_PCI_DEVICES_PATH/0000:01:00.0/power/runtime_status"
protect_counters 0000:01:00.0
run_collector "suspended controller before an active controller"
(( $(grep -c '^PCI address:' "$tmp_dir/output") == 2 )) || fail "both mixed-state controllers are reported"
(( $(grep -c '^  GPU busy:' "$tmp_dir/output") == 1 )) || fail "only the active controller reports counters"
expect_line '  Driver VRAM used: 268435456 bytes' "a skipped controller does not hide a later active one"
pass "suspended controller is not read and does not hide a later active controller"

reset_fixture
add_device 0000:01:00.0 0x1002 0x1640 0x040300 amdgpu active
add_device 0000:02:00.0 0x1022 0x1586 0x038000 amdgpu active
add_device 0000:03:00.0 0x8086 0x46a6 0x030000 amdgpu active
add_device 0000:04:00.0 0x10de 0x25ac 0x030200 amdgpu active
for slot in 0000:01:00.0 0000:02:00.0 0000:03:00.0 0000:04:00.0; do
  protect_counters "$slot"
done
run_collector "unrelated PCI functions"
expect_line 'No AMD display controllers detected.' "unrelated PCI functions are ignored"
expect_no_counters "unrelated PCI functions"
pass "AMD audio/CPU functions and other vendors are ignored without counter reads"

reset_fixture
run_collector "empty PCI root"
expect_line 'No AMD display controllers detected.' "empty PCI root is reported"
pass "empty PCI root reports no AMD display controllers"
rm -rf "$OMARCHY_PCI_DEVICES_PATH"
run_collector "missing PCI root"
expect_line 'PCI device information unavailable.' "missing PCI root is reported"
pass "missing PCI root reports unavailable information"

reset_fixture
add_device 0000:01:00.0 0x1002 0x73bf 0x030000 amdgpu active
add_device 0000:02:00.0 0x1002 0x73bf 0x030000 amdgpu active
add_device 0000:c3:00.0 0x1002 0x1586 0x038000 amdgpu active
rm "$OMARCHY_PCI_DEVICES_PATH/0000:01:00.0/vendor" "$OMARCHY_PCI_DEVICES_PATH/0000:02:00.0/class"
protect_counters 0000:01:00.0
protect_counters 0000:02:00.0
run_collector "incomplete PCI entries"
(( $(grep -c '^PCI address:' "$tmp_dir/output") == 1 )) || fail "incomplete PCI entries are skipped"
expect_line 'PCI address: 0000:c3:00.0' "incomplete entries do not hide a later GPU"
pass "incomplete PCI entries are skipped without counter reads or stderr"

reset_fixture
add_device 0000:c3:00.0 0x1002 0x1586 0x038000 amdgpu active
rm "$OMARCHY_PCI_DEVICES_PATH/0000:c3:00.0/device"
run_collector "missing PCI device ID"
expect_line '  PCI ID: 1002:unavailable' "missing device ID is explicit"
expect_line '  GPU busy: 7%' "missing device ID does not suppress readable counters"
pass "missing PCI device ID is explicit and nonfatal"

reset_fixture
add_device 0000:c3:00.0 0x1002 0x1586 0x038000 amdgpu active
for field in "${counter_files[@]}"; do
  rm "$OMARCHY_PCI_DEVICES_PATH/0000:c3:00.0/$field"
done
run_collector "missing counters"
for label in "${counter_labels[@]}"; do
  expect_line "  $label: unavailable" "missing $label is explicit"
done
pass "missing counters are unavailable and nonfatal"

values=(busy -1 1.5 '1024 bytes' '')
for index in "${!counter_files[@]}"; do
  printf '%s\n' "${values[$index]}" >"$OMARCHY_PCI_DEVICES_PATH/0000:c3:00.0/${counter_files[$index]}"
done
run_collector "malformed counters"
for label in "${counter_labels[@]}"; do
  expect_line "  $label: unavailable" "malformed $label is explicit"
done
pass "nonnumeric, negative, fractional, unit-suffixed, and empty counters are unavailable"

for field in "${counter_files[@]}"; do
  printf '0\n' >"$OMARCHY_PCI_DEVICES_PATH/0000:c3:00.0/$field"
done
run_collector "zero counters"
expect_line '  GPU busy: 0%' "zero GPU activity is valid"
for label in "${counter_labels[@]:1}"; do
  expect_line "  $label: 0 bytes" "zero $label is valid"
done
pass "zero counters are valid readings"

rm "$OMARCHY_PCI_DEVICES_PATH/0000:c3:00.0/mem_info_vram_total" "$OMARCHY_PCI_DEVICES_PATH/0000:c3:00.0/mem_info_gtt_total"
mkdir "$OMARCHY_PCI_DEVICES_PATH/0000:c3:00.0/mem_info_vram_total"
ln -s "$tmp_dir/absent-counter" "$OMARCHY_PCI_DEVICES_PATH/0000:c3:00.0/mem_info_gtt_total"
run_collector "unreadable counter paths"
expect_line '  Driver VRAM total: unavailable' "directory in place of counter is unavailable"
expect_line '  GTT total: unavailable' "dangling counter link is unavailable"
expect_line '  GTT used: 0 bytes' "unreadable paths do not suppress other counters"
pass "unreadable counter paths are silent and do not suppress other counters"
