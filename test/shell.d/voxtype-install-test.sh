#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_home=$(mktemp -d)
test_bin=$(mktemp -d)
omarchy_path=$(mktemp -d)
log_file=$(mktemp)

cleanup() {
  rm -rf "$test_home" "$test_bin" "$omarchy_path"
  rm -f "$log_file"
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

write_stub gum '[[ $1 == confirm ]] && exit 0
exit 1'
write_stub omarchy-pkg-add 'exit 0'
write_stub hyprctl 'exit 0'
write_stub omarchy-restart-shell 'exit 0'
write_stub omarchy-notification-send 'exit 0'
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
    PATH="$test_bin:$PATH" \
    TEST_LOG="$log_file" \
    "$@" \
    bash "$ROOT/bin/omarchy-voxtype-install"
}

write_stub omarchy-hw-vulkan 'exit 0'
run_install
grep -qx 'sudo:voxtype setup gpu --enable' "$log_file" ||
  fail "Vulkan hardware switches Voxtype to the GPU build with sudo" "$(cat "$log_file")"
pass "Vulkan hardware switches Voxtype to the GPU build with sudo"

write_stub omarchy-hw-vulkan 'exit 1'
run_install
if grep -q 'gpu --enable' "$log_file"; then
  fail "CPU-only install leaves the package CPU binary in place" "$(cat "$log_file")"
fi
pass "CPU-only install leaves the package CPU binary in place"

write_stub omarchy-hw-vulkan 'exit 0'
if VOXTYPE_GPU_ENABLE_FAIL=1 run_install; then
  fail "a failed GPU switch is not reported as a finished install"
fi
pass "a failed GPU switch is not reported as a finished install"
