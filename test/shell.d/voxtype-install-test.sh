#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
lib_path="$test_tmp/lib/voxtype"
calls="$test_tmp/calls.log"
mkdir -p "$stub_bin" "$lib_path"

for command in gum omarchy-pkg-drop omarchy-pkg-add hyprctl omarchy-restart-shell omarchy-notification-send; do
  printf '#!/bin/bash\nexit 0\n' >"$stub_bin/$command"
done
printf '#!/bin/bash\nexit 1\n' >"$stub_bin/omarchy-pkg-present"
cat >"$stub_bin/omarchy-hw-vulkan" <<'SH'
#!/bin/bash
(( ${VULKAN:-1} == 1 ))
SH
cat >"$stub_bin/voxtype" <<'SH'
#!/bin/bash
printf 'voxtype %s\n' "$*" >>"$TEST_LOG"
SH
chmod +x "$stub_bin"/*

run_install() {
  local vulkan=$1 backend=$2

  : >"$calls"
  rm -rf "$test_tmp/home" "$lib_path/voxtype-vulkan"
  mkdir -p "$test_tmp/home"
  case $backend in
  executable)
    printf '#!/bin/bash\n' >"$lib_path/voxtype-vulkan"
    chmod +x "$lib_path/voxtype-vulkan"
    ;;
  unusable)
    : >"$lib_path/voxtype-vulkan"
    ;;
  esac

  HOME="$test_tmp/home" OMARCHY_PATH="$ROOT" OMARCHY_VOXTYPE_LIB_PATH="$lib_path" \
    VULKAN="$vulkan" TEST_LOG="$calls" PATH="$stub_bin:$PATH" \
    bash "$ROOT/bin/omarchy-voxtype-install" >/dev/null ||
    fail "Voxtype install completes (vulkan=$vulkan backend=$backend)"

  grep -Fx 'voxtype setup systemd' "$calls" >/dev/null ||
    fail "Voxtype install sets up the user service (vulkan=$vulkan backend=$backend)"
}

run_install 1 executable
grep -Fx 'voxtype setup gpu --enable' "$calls" >/dev/null ||
  fail "Voxtype enables the GPU backend when Vulkan and the backend binary are present"
pass "Voxtype enables the GPU backend when Vulkan and the backend binary are present"

run_install 1 missing
! grep -q 'setup gpu' "$calls" ||
  fail "Voxtype does not enable a Vulkan backend the package did not ship"
pass "Voxtype does not enable a Vulkan backend the package did not ship"

run_install 1 unusable
! grep -q 'setup gpu' "$calls" ||
  fail "Voxtype does not enable a Vulkan backend that is not executable"
pass "Voxtype does not enable a Vulkan backend that is not executable"

run_install 0 executable
! grep -q 'setup gpu' "$calls" ||
  fail "Voxtype does not enable the GPU backend without a Vulkan runtime"
pass "Voxtype does not enable the GPU backend without a Vulkan runtime"
