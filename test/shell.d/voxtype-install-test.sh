#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
lib_path="$test_tmp/lib/voxtype"
calls="$test_tmp/calls.log"
mkdir -p "$stub_bin" "$lib_path"

for command in gum omarchy-pkg-drop hyprctl omarchy-restart-shell omarchy-notification-send systemctl; do
  printf '#!/bin/bash\nexit 0\n' >"$stub_bin/$command"
done
printf '#!/bin/bash\nexit 1\n' >"$stub_bin/omarchy-pkg-present"
printf '#!/bin/bash\nexit 0\n' >"$stub_bin/omarchy-dictation-use"
cat >"$stub_bin/omarchy-hw-vulkan" <<'SH'
#!/bin/bash
(( ${VULKAN:-1} == 1 ))
SH
cat >"$stub_bin/voxtype" <<'SH'
#!/bin/bash
printf 'voxtype %s\n' "$*" >>"$TEST_LOG"
SH
cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'packages %s\n' "$*" >>"$TEST_LOG"
[[ ${PACKAGE_FAIL:-0} == "0" ]]
SH
# Existing installs are the default; the fresh-install case overrides this.
cat >"$stub_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ ${VOXTYPE_INSTALLED:-1} == "1" ]]
SH
cat >"$stub_bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
[[ ${VOXTYPE_INSTALLED:-1} == "0" ]]
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
    XDG_CONFIG_HOME="$test_tmp/home/.config" bash "$ROOT/bin/omarchy-install-dictation-voxtype" >/dev/null ||
    fail "Voxtype install completes (vulkan=$vulkan backend=$backend)"

  grep -Fx 'packages whisper-cpp' "$calls" >/dev/null ||
    fail "Voxtype setup installs the CLI backend even when Voxtype is already installed"
  [[ $(head -n 1 "$calls") == "packages whisper-cpp" || ${VOXTYPE_INSTALLED:-1} == "0" ]] ||
    fail "Voxtype installs its CLI backend before configuring models"

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

VOXTYPE_INSTALLED=0 run_install 0 missing
grep -Fx 'packages wtype voxtype-bin' "$calls" >/dev/null ||
  fail "a fresh setup still installs Voxtype and its typing helper"
pass "fresh and existing Voxtype setups install the CLI backend"

: >"$calls"
if HOME="$test_tmp/home" OMARCHY_PATH="$ROOT" TEST_LOG="$calls" PACKAGE_FAIL=1 \
  OMARCHY_VOXTYPE_LIB_PATH="$lib_path" PATH="$stub_bin:$PATH" \
  XDG_CONFIG_HOME="$test_tmp/home/.config" bash "$ROOT/bin/omarchy-install-dictation-voxtype" >/dev/null; then
  fail "a failed CLI backend install must stop setup"
fi
! grep -q '^voxtype ' "$calls" || fail "failed dependency installation does not start model or service setup"
pass "dependency failures stop Voxtype setup for a later retry"

migration="$ROOT/migrations/1795203907.sh"
for installed in 0 1; do
  : >"$calls"
  VOXTYPE_INSTALLED="$installed" TEST_LOG="$calls" PATH="$stub_bin:$PATH" \
    bash -euo pipefail "$migration" >/dev/null
  if (( installed )); then
    grep -Fx 'packages whisper-cpp' "$calls" >/dev/null || fail "migration repairs existing Voxtype installs"
  else
    [[ ! -s $calls ]] || fail "migration does not install a backend without Voxtype"
  fi
done
if VOXTYPE_INSTALLED=1 PACKAGE_FAIL=1 TEST_LOG="$calls" PATH="$stub_bin:$PATH" \
  bash -euo pipefail "$migration" >/dev/null; then
  fail "failed backend repairs must leave the migration pending"
fi
pass "the backend migration repairs Voxtype only and propagates package failures"
