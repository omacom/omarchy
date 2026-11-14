#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# PC and Intel Mac quirks that must leave Apple Silicon alone, run on both sides
# of the detector.

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
modprobe_dir="$test_tmp/modprobe.d"
conf="$modprobe_dir/omarchy-toprow.conf"
mkdir -p "$stub_bin"

cat >"$stub_bin/omarchy-hw-aarch64-apple" <<'SH'
#!/bin/bash
[[ ${APPLE_SILICON:-0} == "1" ]]
SH

cat >"$stub_bin/uname" <<'SH'
#!/bin/bash
if [[ $1 == "-m" ]]; then
  echo "${UNAME_M:-x86_64}"
else
  exec /usr/bin/uname "$@"
fi
SH

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$TEST_LOG"
"$@"
SH

chmod +x "$stub_bin"/*

run_fkeys() {
  mkdir -p "$test_tmp/sys-module"
  APPLE_SILICON="$1" OMARCHY_MODPROBE_DIR="$modprobe_dir" OMARCHY_SYS_MODULE="$test_tmp/sys-module" \
    OMARCHY_TOPROW_REBUILD_PENDING="$test_tmp/rebuild-pending" PATH="$stub_bin:$ROOT/bin:$PATH" TEST_LOG="$calls" \
    bash -eE -o pipefail -c 'source "$1"' _ "$ROOT/install/hardware/fix-fkeys.sh" >/dev/null
}

run_fkeys 0
grep -qx 'options hid_apple fnmode=1' "$conf" && grep -qx 'options hid_asus fnlock_default=0' "$conf" ||
  fail "a PC starts keyboards that leave Fn-lock to Linux on the media keys" "$(cat "$conf")"
pass "a PC starts keyboards that leave Fn-lock to Linux on the media keys"

rm -f "$conf"
printf 'options hid_apple fnmode=2\n' >"$modprobe_dir/hid_apple.conf"
run_fkeys 0
[[ ! -e $conf && $(<"$modprobe_dir/hid_apple.conf") == "options hid_apple fnmode=2" ]] ||
  fail "setup keeps the F-keys an existing install already has"
rm -f "$modprobe_dir/hid_apple.conf"
printf 'options asus_wmi fnlock_default=1\n' >"$modprobe_dir/asus.conf"
run_fkeys 0
[[ ! -e $conf ]] || fail "setup keeps an administrator's own asus_wmi Fn-lock"
pass "setup keeps the F-keys an existing install already has"

rm -rf "$modprobe_dir"
: >"$calls"
run_fkeys 1
[[ ! -e $modprobe_dir && ! -s $calls ]] || fail "Apple Silicon keeps its own keyboard mode" "$(cat "$calls")"
output=$(APPLE_SILICON=1 PATH="$stub_bin:$PATH" bash "$ROOT/bin/omarchy-keyboard-toprow" fnkeys 2>&1) &&
  fail "omarchy keyboard toprow refuses Apple Silicon"
[[ $output == *omarchy-mac* ]] || fail "omarchy keyboard toprow says why it refuses Apple Silicon" "$output"
pass "Apple Silicon keeps its own keyboard mode"

# The Windows guest matches the host CPU, so a CPU with no native Windows build
# refuses it before it touches anything.
output=$(UNAME_M=armv7l APPLE_SILICON=0 PATH="$stub_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-windows-vm" install 2>&1) &&
  fail "Windows VM install fails on armv7l"
[[ $output == *"needs an x86_64 or aarch64 machine"* ]] || fail "Windows VM says why it refuses on armv7l" "$output"
pass "Windows VM refuses CPUs without a native Windows guest"

# The firmware boot entry and hibernation are refused or skipped on Apple
# Silicon before they touch anything.
output=$(APPLE_SILICON=1 PATH="$stub_bin:$PATH" bash "$ROOT/bin/omarchy-setup-direct-boot" 2>&1) &&
  fail "direct boot fails on Apple Silicon"
[[ $output == *"not supported on Apple Silicon"* ]] || fail "direct boot says why it refuses" "$output"
output=$(APPLE_SILICON=1 PATH="$stub_bin:$PATH" bash "$ROOT/bin/omarchy-hibernation-setup" --force 2>&1) ||
  fail "hibernation setup skips Apple Silicon without failing" "$output"
[[ $output == "Skipping hibernation setup (not supported on Apple Silicon)" ]] ||
  fail "hibernation setup stops before its own checks on Apple Silicon" "$output"
pass "direct boot and hibernation step aside on Apple Silicon"

# On x86_64 and aarch64 the Windows VM goes on to its own commands.
for machine in x86_64 aarch64; do
  output=$(UNAME_M=$machine PATH="$stub_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-windows-vm" help 2>&1) || true
  [[ $output != *"aarch64 machine"* && $output == *"install"* ]] || fail "Windows VM runs on $machine" "$output"
done
pass "Windows VM runs on x86_64 and aarch64"
