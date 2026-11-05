#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
lib_path="$test_tmp/lib/voxtype"
calls="$test_tmp/calls.log"
mkdir -p "$stub_bin" "$lib_path"

for command in gum omarchy-pkg-drop omarchy-pkg-add hyprctl omarchy-restart-shell omarchy-notification-send systemctl; do
  printf '#!/bin/bash\nexit 0\n' >"$stub_bin/$command"
done
printf '#!/bin/bash\nexit 1\n' >"$stub_bin/omarchy-pkg-present"
# Voxtype is already installed, so the install asks nothing and only sets it up.
printf '#!/bin/bash\nexit 1\n' >"$stub_bin/omarchy-cmd-missing"
printf '#!/bin/bash\nexit 0\n' >"$stub_bin/omarchy-dictation-use"
cat >"$stub_bin/omarchy-hw-vulkan" <<'SH'
#!/bin/bash
(( ${VULKAN:-1} == 1 ))
SH
cat >"$stub_bin/voxtype" <<'SH'
#!/bin/bash
printf 'voxtype %s\n' "$*" >>"$TEST_LOG"
if [[ $1 == "setup" && ${2:-} == "gpu" ]]; then
  [[ ${VOXTYPE_AS_ROOT:-0} == "1" ]] || exit 37
  [[ ${GPU_ENABLE_FAIL:-0} != "1" ]] || exit 38
fi
exit 0
SH
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$TEST_LOG"
VOXTYPE_AS_ROOT=1 exec "$@"
SH
chmod +x "$stub_bin"/*

run_install() {
  local vulkan=$1 backend=$2 configuration=${3:-new} gpu_failure=${4:-0}

  : >"$calls"
  rm -rf "$test_tmp/home" "$lib_path/voxtype-vulkan"
  mkdir -p "$test_tmp/home"
  if [[ $configuration == "existing" ]]; then
    mkdir -p "$test_tmp/home/.config/voxtype"
    printf 'custom model configuration\n' >"$test_tmp/home/.config/voxtype/config.toml"
  fi
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
    VULKAN="$vulkan" TEST_LOG="$calls" GPU_ENABLE_FAIL="$gpu_failure" PATH="$stub_bin:$PATH" \
    XDG_CONFIG_HOME="$test_tmp/home/.config" bash "$ROOT/bin/omarchy-install-dictation-voxtype" >"$test_tmp/output" 2>&1 ||
    fail "Voxtype install completes (vulkan=$vulkan backend=$backend)" "$(cat "$test_tmp/output")"

  grep -Fx 'voxtype setup systemd' "$calls" >/dev/null ||
    fail "Voxtype install sets up the user service (vulkan=$vulkan backend=$backend)"
}

run_install 1 executable
grep -Fx 'sudo voxtype setup gpu --enable' "$calls" >/dev/null ||
  fail "Voxtype enables the GPU backend through sudo"
grep -Fx 'voxtype setup gpu --enable' "$calls" >/dev/null ||
  fail "Voxtype enables the GPU backend when Vulkan and the backend binary are present"
! grep -q 'could not enable the Voxtype GPU backend' "$test_tmp/output" ||
  fail "successful GPU setup must not warn"
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

run_install 1 executable existing
grep -Fx 'sudo voxtype setup gpu --enable' "$calls" >/dev/null ||
  fail "Voxtype retries GPU setup when a previous attempt already created config.toml"
[[ $(cat "$test_tmp/home/.config/voxtype/config.toml") == "custom model configuration" ]] ||
  fail "Voxtype GPU retry must preserve custom configuration"
pass "Voxtype retries GPU setup without replacing existing configuration"

for configuration in new existing; do
  run_install 1 executable "$configuration" 1
  grep -Fx 'sudo voxtype setup gpu --enable' "$calls" >/dev/null ||
    fail "failed GPU setup must still run through sudo ($configuration configuration)"
  grep -q 'could not enable the Voxtype GPU backend' "$test_tmp/output" ||
    fail "failed GPU setup must warn ($configuration configuration)"
  pass "failed GPU setup warns while model and service setup complete ($configuration configuration)"
done
