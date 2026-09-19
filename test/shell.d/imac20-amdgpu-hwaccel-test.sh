#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

install_script="$ROOT/install/hardware/apple/install-imac20-amdgpu-hwaccel.sh"
all_hardware="$ROOT/install/hardware/all.sh"
bin_command="$ROOT/bin/omarchy-install-imac20-amdgpu-hwaccel"
manual="$ROOT/manual/44-mac-support.md"

grep -Fq 'run_logged "$OMARCHY_INSTALL/hardware/apple/install-imac20-amdgpu-hwaccel.sh"' \
  "$all_hardware" || fail "hardware setup runs the iMac20 HW-accel opt-in"
test -x "$bin_command" || fail "opt-in command is executable"
pass "iMac20 HW-accel opt-in is wired into the installer"

grep -Fq 'omarchy-hw-imac20-navi14' "$install_script" ||
  fail "HW-accel install gates on the same Navi 14 detector as the safe-fallback"
grep -Fq 'nomodeset' "$install_script" ||
  fail "HW-accel install refuses to run if the safe-fallback cmdline is not active"
grep -Fq 'McoreD/imac20-amdgpu-patch' "$install_script" ||
  fail "HW-accel install points at the companion repo"
grep -Fq 'omarchy-install-imac20-amdgpu-hwaccel' "$manual" ||
  fail "Mac support manual mentions the opt-in command"
pass "install script, bin command, and manual cross-reference correctly"

# Stub git and the companion-repo scripts so we can assert the install script
# exercises the right commands without actually cloning or building anything.
stub_dir=$(mktemp -d)
trap 'rm -rf "$stub_dir"' EXIT

mkdir -p "$stub_dir/opt/imac20-amdgpu-patch/scripts"

cat >"$stub_dir/git" <<'SH'
#!/bin/bash
echo "git $*" >>"$TEST_LOG"
[[ $1 == clone ]] && {
  # Replicate git's argument pattern into a stub repo so subsequent pulls work.
  target="${@: -1}"
  mkdir -p "$target"
  git init -q "$target"
}
exit 0
SH
chmod +x "$stub_dir/git"

for script in build-amdgpu-install.sh install-pacman-hook.sh install-limine-hwaccel-entry.sh; do
  cat >"$stub_dir/opt/imac20-amdgpu-patch/scripts/$script" <<SH
#!/bin/bash
echo "$script $*" >>"\$TEST_LOG"
SH
  chmod +x "$stub_dir/opt/imac20-amdgpu-patch/scripts/$script"
done

cat >"$stub_dir/bc" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$stub_dir/bc"

cat >"$stub_dir/python3" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$stub_dir/python3"

call_log="$stub_dir/calls.log"
: >"$call_log"

OMARCHY_DMI_PRODUCT_NAME="$stub_dir/product_name" \
  OMARCHY_PCI_DEVICES_PATH="$stub_dir/devices" \
  PATH="$stub_dir:$ROOT/bin:$PATH" \
  TEST_LOG="$call_log" \
  bash -euo pipefail "$install_script" </dev/null >/dev/null 2>&1 || true

grep -Fxq "git clone --depth 1 https://github.com/McoreD/imac20-amdgpu-patch.git /opt/imac20-amdgpu-patch" \
  "$call_log" || fail "install clones the companion repo" "$(cat "$call_log")"
grep -Fxq "/opt/imac20-amdgpu-patch/scripts/build-amdgpu-install.sh" \
  "$call_log" || fail "install runs the build script"
grep -Fxq "/opt/imac20-amdgpu-patch/scripts/install-pacman-hook.sh" \
  "$call_log" || fail "install installs the pacman hook"
grep -Fxq "/opt/imac20-amdgpu-patch/scripts/install-limine-hwaccel-entry.sh" \
  "$call_log" || fail "install adds the Limine hwaccel entry"
pass "install script sequence is correct"

# On non-matching hardware the install script must no-op (no git clone, no
# companion-repo scripts) and exit cleanly.
product_file="$stub_dir/product_name"
echo "MacBookPro16,1" >"$product_file"
mkdir -p "$stub_dir/devices"
slots=("0000:00:00.0" "0000:01:00.0")
specs=("0x8086:0x1234:0x060000" "0x1002:0x7340:0x030000")
for i in 0 1; do
  mkdir -p "$stub_dir/devices/${slots[$i]}"
  IFS=: read -r v d c <<<"${specs[$i]}"
  echo "$v" >"$stub_dir/devices/${slots[$i]}/vendor"
  echo "$d" >"$stub_dir/devices/${slots[$i]}/device"
  echo "$c" >"$stub_dir/devices/${slots[$i]}/class"
done

: >"$call_log"
OMARCHY_DMI_PRODUCT_NAME="$product_file" \
  OMARCHY_PCI_DEVICES_PATH="$stub_dir/devices" \
  PATH="$stub_dir:$ROOT/bin:$PATH" \
  TEST_LOG="$call_log" \
  bash -euo pipefail "$install_script" </dev/null >/dev/null 2>&1 || \
  fail "install exits 0 on non-iMac20 hardware"
[[ ! -s $call_log ]] || fail "non-iMac20 hardware makes no companion-repo calls" "$(cat "$call_log")"
pass "non-iMac20 hardware is skipped"

# The hw detector must reject iMac19 and MacBookPro16,1 even with Navi 14.
for dmi in "iMac19,1" "MacBookPro16,1" ""; do
  echo "$dmi" >"$product_file"
  ! OMARCHY_DMI_PRODUCT_NAME="$product_file" \
      OMARCHY_PCI_DEVICES_PATH="$stub_dir/devices" \
      PATH="$stub_dir:$ROOT/bin:$PATH" \
      "$ROOT/bin/omarchy-hw-imac20-navi14" || \
    fail "detector refuses $dmi"
done
pass "detector only matches iMac20,*/iMac20,*"
