#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# PC and Intel Mac quirks that must leave Apple Silicon alone, run on both sides
# of the detector.

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
conf="$test_tmp/modprobe.d/hid_apple.conf"
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
  APPLE_SILICON="$1" OMARCHY_HID_APPLE_CONF="$conf" PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    bash -eE -o pipefail -c 'source "$1"' _ "$ROOT/install/hardware/fix-fkeys.sh"
}

run_fkeys 0
[[ $(<"$conf") == "options hid_apple fnmode=2" ]] || fail "a PC keeps F-keys first on Apple-like keyboards" "$(cat "$conf")"
pass "a PC keeps F-keys first on Apple-like keyboards"

printf 'options hid_apple fnmode=0\n' >"$conf"
run_fkeys 0
[[ $(<"$conf") == "options hid_apple fnmode=0" ]] || fail "an existing hid_apple.conf is left alone"
pass "an existing hid_apple.conf is left alone"

rm -rf "$test_tmp/modprobe.d"
: >"$calls"
run_fkeys 1
[[ ! -e $conf && ! -s $calls ]] || fail "Apple Silicon keeps its own keyboard mode" "$(cat "$calls")"
pass "Apple Silicon keeps its own keyboard mode"

# The Windows guest is x86_64, so every other CPU refuses it before it touches
# anything, Apple Silicon or not.
for machine in aarch64 armv7l; do
  output=$(UNAME_M=$machine APPLE_SILICON=0 PATH="$stub_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-windows-vm" install 2>&1) &&
    fail "Windows VM install fails on $machine"
  [[ $output == *"needs an x86_64 machine"* ]] || fail "Windows VM says why it refuses on $machine" "$output"
done
pass "Windows VM refuses every CPU but x86_64"

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

# On x86_64 the Windows VM goes on to its own commands, as before.
output=$(UNAME_M=x86_64 PATH="$stub_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-windows-vm" help 2>&1) || true
[[ $output != *"x86_64 machine"* && $output == *"install"* ]] || fail "Windows VM runs as before on x86_64" "$output"
pass "Windows VM runs as before on x86_64"

run_node_test <<'JS'
const fs = require('fs')
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')
const items = menu.parseMenuJsonc(fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8'))
const when = id => (items.find(entry => entry.id === id) || {}).when
assertEqual(when('install.windows'), 'omarchy-hw-x86', 'install.windows is offered on x86_64 only')
assertEqual(when('setup.direct-boot'), '! omarchy-hw-aarch64-apple', 'setup.direct-boot is hidden on Apple Silicon only')
// No package puts MLX or the Neural Engine on another machine, so the row
// keeps a platform guard alone.
assertEqual(when('install.ai.mlx'), 'omarchy-hw-aarch64-apple', 'install.ai.mlx is offered on Apple Silicon only')
JS
pass "the menu offers Windows on x86_64 only, and hides Direct Boot and offers MLX + Core ML (Apple Silicon) on Apple Silicon only"
