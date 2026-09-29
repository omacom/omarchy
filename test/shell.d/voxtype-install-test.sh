#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_home=$(mktemp -d)
test_bin=$(mktemp -d)
omarchy_path=$(mktemp -d)
voxtype_lib=$(mktemp -d)
pci_root=$(mktemp -d)
log_file=$(mktemp)
stdout_file=$(mktemp)
voxtype_link="$test_home/voxtype"
voxtype_vulkan="$voxtype_lib/voxtype-vulkan"

cleanup() {
  rm -rf "$test_home" "$test_bin" "$omarchy_path" "$voxtype_lib" "$pci_root"
  rm -f "$log_file" "$stdout_file"
}
trap cleanup EXIT

mkdir -p "$omarchy_path/default/voxtype"
printf 'engine = "whisper"\n' >"$omarchy_path/default/voxtype/config.toml"

write_stub() {
  local name="$1"
  local body="$2"
  printf '%s\n' '#!/bin/bash' "$body" >"$test_bin/$name"
  chmod +x "$test_bin/$name"
}

use_backend() {
  local name="$1"
  local target="$voxtype_lib/$name"
  [[ -e $target ]] || : >"$target"
  ln -sfn "$target" "$voxtype_link"
}

use_vulkan_binary() {
  printf '%s\n' '#!/bin/bash' 'exit 0' >"$voxtype_vulkan"
  chmod +x "$voxtype_vulkan"
}

write_stub gum '[[ $1 == confirm ]] && exit 0
exit 1'
write_stub omarchy-pkg-add 'exit 0'
write_stub hyprctl 'exit 0'
write_stub omarchy-restart-shell 'exit 0'
write_stub omarchy-notification-send 'exit 0'
write_stub omarchy-hw-intel-haswell-gpu 'exit 1'
write_stub omarchy-hw-vulkan 'exit 0'
write_stub sudo 'echo "sudo:$*" >>"$TEST_LOG"
"$@"'
write_stub voxtype 'echo "voxtype:$*" >>"$TEST_LOG"
if [[ ${VOXTYPE_GPU_ENABLE_FAIL:-} == 1 && $* == *"gpu --enable"* ]]; then
  exit 1
fi
exit 0'

run_install() {
  : >"$log_file"
  HOME="$test_home" \
    OMARCHY_PATH="$omarchy_path" \
    OMARCHY_VOXTYPE_BIN="$voxtype_link" \
    OMARCHY_VOXTYPE_VULKAN="$voxtype_vulkan" \
    PATH="$test_bin:$PATH" \
    TEST_LOG="$log_file" \
    "$@" \
    bash "$ROOT/bin/omarchy-voxtype-install"
}

assert_no_gpu_switch() {
  if grep -q 'gpu --enable' "$log_file"; then
    fail "$1" "$(cat "$log_file")"
  fi
  if grep -q 'gpu --disable' "$log_file"; then
    fail "$1" "$(cat "$log_file")"
  fi
}

use_vulkan_binary
use_backend voxtype-avx512

run_install >"$stdout_file"
grep -qx 'sudo:voxtype setup gpu --enable' "$log_file" ||
  fail "Vulkan hardware switches Voxtype to the GPU build with sudo" "$(cat "$log_file")"
grep -qx 'voxtype:setup systemd' "$log_file" ||
  fail "Vulkan hardware switches Voxtype to the GPU build with sudo" "$(cat "$log_file")"
pass "Vulkan hardware switches Voxtype to the GPU build with sudo"

use_backend voxtype-avx2
run_install >"$stdout_file"
grep -qx 'sudo:voxtype setup gpu --enable' "$log_file" ||
  fail "an avx2 CPU link switches to the Vulkan build" "$(cat "$log_file")"
grep -qx 'voxtype:setup systemd' "$log_file" ||
  fail "an avx2 CPU link switches to the Vulkan build" "$(cat "$log_file")"
pass "an avx2 CPU link switches to the Vulkan build"

use_backend voxtype-avx512
write_stub omarchy-hw-vulkan 'exit 1'
run_install >"$stdout_file"
assert_no_gpu_switch "CPU-only install leaves the package CPU binary in place"
grep -qx 'voxtype:setup systemd' "$log_file" ||
  fail "CPU-only install leaves the package CPU binary in place" "$(cat "$log_file")"
pass "CPU-only install leaves the package CPU binary in place"

write_stub omarchy-hw-vulkan 'exit 0'
if VOXTYPE_GPU_ENABLE_FAIL=1 run_install >"$stdout_file"; then
  fail "a failed GPU switch is not reported as a finished install" "$(cat "$log_file")"
fi
grep -qx 'sudo:voxtype setup gpu --enable' "$log_file" ||
  fail "a failed GPU switch is not reported as a finished install" "$(cat "$log_file")"
if grep -qx 'voxtype:setup systemd' "$log_file"; then
  fail "a failed GPU switch is not reported as a finished install" "$(cat "$log_file")"
fi
pass "a failed GPU switch is not reported as a finished install"

rm -f "$voxtype_vulkan"
run_install >"$stdout_file"
assert_no_gpu_switch "a missing voxtype-vulkan binary skips the GPU switch"
grep -qx 'voxtype:setup systemd' "$log_file" ||
  fail "a missing voxtype-vulkan binary skips the GPU switch" "$(cat "$log_file")"
pass "a missing voxtype-vulkan binary skips the GPU switch"

use_vulkan_binary
use_backend voxtype-vulkan
run_install >"$stdout_file"
assert_no_gpu_switch "an existing Vulkan link is left alone"
grep -qx 'voxtype:setup systemd' "$log_file" ||
  fail "an existing Vulkan link is left alone" "$(cat "$log_file")"
pass "an existing Vulkan link is left alone"

use_backend voxtype-onnx-avx512
run_install >"$stdout_file"
assert_no_gpu_switch "an ONNX link is left alone"
grep -qx 'voxtype:setup systemd' "$log_file" ||
  fail "an ONNX link is left alone" "$(cat "$log_file")"
pass "an ONNX link is left alone"

use_backend voxtype-baseline
run_install >"$stdout_file"
assert_no_gpu_switch "a baseline CPU link is left alone"
grep -qx 'voxtype:setup systemd' "$log_file" ||
  fail "a baseline CPU link is left alone" "$(cat "$log_file")"
pass "a baseline CPU link is left alone"

use_backend voxtype-avx512
write_stub omarchy-hw-intel-haswell-gpu 'exit 0'
run_install >"$stdout_file"
grep -qx 'Using CPU dictation: Intel Haswell Vulkan lacks the required 16-bit storage.' "$stdout_file" ||
  fail "Haswell stays on the CPU build" "$(cat "$stdout_file")"
grep -qx 'sudo:voxtype setup gpu --disable' "$log_file" ||
  fail "Haswell stays on the CPU build" "$(cat "$log_file")"
if grep -q 'gpu --enable' "$log_file"; then
  fail "Haswell stays on the CPU build" "$(cat "$log_file")"
fi
grep -qx 'voxtype:setup systemd' "$log_file" ||
  fail "Haswell stays on the CPU build" "$(cat "$log_file")"
pass "Haswell stays on the CPU build"

reset_pci() {
  rm -rf "$pci_root"
  mkdir -p "$pci_root"
}

add_pci() {
  local slot="$1"
  local vendor="$2"
  local device="$3"
  local class="$4"
  local dir="$pci_root/$slot"

  mkdir -p "$dir"
  printf '%s\n' "$vendor" >"$dir/vendor"
  printf '%s\n' "$device" >"$dir/device"
  printf '%s\n' "$class" >"$dir/class"
}

expect_haswell() {
  local description="$1"
  local want_match="$2"
  local vendor="$3"
  local device="$4"
  local class="$5"
  local status=0

  reset_pci
  add_pci 0000:00:02.0 "$vendor" "$device" "$class"
  OMARCHY_PCI_DEVICES_PATH="$pci_root" "$ROOT/bin/omarchy-hw-intel-haswell-gpu" || status=$?

  if [[ $want_match == "yes" ]]; then
    (( status == 0 )) || fail "$description" "expected exit 0, got $status"
  elif (( status == 0 )); then
    fail "$description" "expected a non-match, got exit $status"
  fi
  pass "$description"
}

expect_haswell "Haswell GT1 0x0402 is detected" yes 0x8086 0x0402 0x030000
expect_haswell "Haswell GT2 0x0416 is detected" yes 0x8086 0x0416 0x030000
expect_haswell "Haswell ULT 0x0a26 is detected" yes 0x8086 0x0a26 0x030000
expect_haswell "Crystal Well 0x0d26 is detected" yes 0x8086 0x0d26 0x030000
expect_haswell "a newer Intel GPU is not Haswell" no 0x8086 0x9a49 0x030000
expect_haswell "a non-Intel vendor is not Haswell" no 0x1002 0x0402 0x030000
expect_haswell "a non-display class is not Haswell" no 0x8086 0x0402 0x028000
