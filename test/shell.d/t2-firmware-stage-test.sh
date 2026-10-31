#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/fix-t2.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"
printf '#!/bin/bash\necho "01:00.0 Bridge [0680]: Apple Inc. T2 Security Chip [106b:1801]"\n' >"$stub_bin/lspci"
printf '#!/bin/bash\n:\n' >"$stub_bin/omarchy-pkg-add"
printf '#!/bin/bash\n:\n' >"$stub_bin/systemctl"
chmod +x "$stub_bin"/*

# Run the leaf against a fake root: every absolute path it writes moves under $test_tmp/root.
run_leaf() {
  local script="$test_tmp/leaf.sh"
  sed -E "s#(^|[ \"=>])/(etc|lib|var)/#\1$test_tmp/root/\2/#g" "$leaf" >"$script"
  PATH="$stub_bin:$PATH" bash -eE -o pipefail -c 'source "$1"' bash "$script" >/dev/null </dev/null
}

stage="$test_tmp/root/var/lib/omarchy/firmware-stage/apple-bcm"
brcm="$test_tmp/root/lib/firmware/brcm"

run_leaf
[[ ! -e $brcm ]] || fail "a T2 install with nothing saved from macOS leaves the firmware directory alone"
pass "a T2 install with nothing saved from macOS leaves the firmware directory alone"

mkdir -p "$stage"
printf 'fw' >"$stage/brcmfmac4364b3-pcie.apple,midway-HRPN-u-7.7.bin"
printf 'bt' >"$stage/brcmbt4364b3-apple,midway-u.bin"
run_leaf
[[ $(cat "$brcm/brcmfmac4364b3-pcie.apple,midway-HRPN-u-7.7.bin") == "fw" && -f "$brcm/brcmbt4364b3-apple,midway-u.bin" ]] ||
  fail "the firmware the ISO saved from macOS is installed" "$(ls -R "$test_tmp/root" 2>&1)"
grep -qx 'brcmbt4364b3-apple,midway-u.bin' "$test_tmp/root/var/lib/apple-bcm-firmware-fetcher/installed-files" ||
  fail "the fetcher's record lists the installed firmware, so removing it cleans up"
pass "the firmware the ISO saved from macOS is installed and recorded for the fetcher"
