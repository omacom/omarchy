#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/pci/gpu" "$test_tmp/home"
export OMARCHY_PCI_DEVICES_PATH="$test_tmp/pci" TEST_LOG="$test_tmp/calls"
export HOME="$test_tmp/home" OMARCHY_PATH="$ROOT" PATH="$test_tmp/bin:$ROOT/bin:$PATH"
for command in gum omarchy-pkg-add omarchy-restart-shell omarchy-notification-send hyprctl omarchy-hw-vulkan; do
  printf '#!/bin/bash\nexit 0\n' >"$test_tmp/bin/$command"
done
cat >"$test_tmp/bin/voxtype" <<'STUB'
#!/bin/bash
printf 'voxtype %s\n' "$*" >>"$TEST_LOG"
STUB
cat >"$test_tmp/bin/sudo" <<'STUB'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$TEST_LOG"
"$@"
STUB
chmod +x "$test_tmp/bin/"*

printf '0x8086\n' >"$test_tmp/pci/gpu/vendor"
printf '0x030000\n' >"$test_tmp/pci/gpu/class"
for id in 0x0402 0x0416 0x0a26 0x0d26; do
  printf '%s\n' "$id" >"$test_tmp/pci/gpu/device"
  omarchy-hw-intel-haswell-gpu || fail "Haswell GPU $id is detected"
done
bash "$ROOT/bin/omarchy-voxtype-install" >"$test_tmp/output"
grep -qx 'sudo voxtype setup gpu --disable' "$TEST_LOG" || fail "Haswell switches to the CPU backend with privileges"
if grep -q -- '--enable' "$TEST_LOG"; then fail "Haswell must not enable Vulkan"; fi
pass "Haswell and Crystal Well keep CPU dictation even when Vulkan is installed"

printf '0x9a49\n' >"$test_tmp/pci/gpu/device"
: >"$TEST_LOG"
bash "$ROOT/bin/omarchy-voxtype-install" >"$test_tmp/output"
grep -qx 'voxtype setup gpu --enable' "$TEST_LOG" || fail "modern Intel retains GPU setup"
pass "modern Intel GPUs retain the existing acceleration path"

printf '0x0d26\n' >"$test_tmp/pci/gpu/device"
printf '0x1002\n' >"$test_tmp/pci/gpu/vendor"
if omarchy-hw-intel-haswell-gpu; then fail "other vendors do not match Intel IDs"; fi
printf '0x8086\n' >"$test_tmp/pci/gpu/vendor"
printf '0x028000\n' >"$test_tmp/pci/gpu/class"
if omarchy-hw-intel-haswell-gpu; then fail "non-display devices do not match"; fi
pass "the detector requires both Intel ownership and a display-class device"
