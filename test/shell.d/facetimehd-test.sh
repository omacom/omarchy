#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/fix-facetimehd.sh"
all="$ROOT/install/hardware/all.sh"

 grep -Fq 'apple/fix-facetimehd.sh' "$all" ||
  fail "the FaceTime HD fix runs during hardware setup"
pass "the FaceTime HD fix runs during hardware setup"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
modules="$test_tmp/modules-load.d"
mkdir -p "$stub_bin"
: >"$calls"

cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash
printf '%s\n' "$LSPCI_OUTPUT"
SH
cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'omarchy-pkg-add\t%s\n' "$*" >>"$TEST_LOG"
SH
cat >"$stub_bin/omarchy-pkg-aur-add" <<'SH'
#!/bin/bash
printf 'omarchy-pkg-aur-add\t%s\n' "$*" >>"$TEST_LOG"
SH
cat >"$stub_bin/modprobe" <<'SH'
#!/bin/bash
printf 'modprobe\t%s\n' "$*" >>"$TEST_LOG"
SH
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH
chmod +x "$stub_bin"/*

run_leaf() {
  LSPCI_OUTPUT="$1" \
  TEST_LOG="$calls" \
  OMARCHY_FACETIMEHD_MODULES_DIR="$modules" \
  PATH="$stub_bin:$PATH" \
  bash -euo pipefail "$leaf"
}

run_leaf '03:00.0 Network controller [0280]: Broadcom [14e4:43a0]' >/dev/null
[[ ! -e "$modules/facetimehd.conf" ]] || fail "non-camera Broadcom hardware is left alone"
[[ ! -s "$calls" ]] || fail "non-camera hardware does not install camera support"
pass "non-camera Broadcom hardware is left alone"

run_leaf '02:00.0 Multimedia controller [0480]: Broadcom 720p FaceTime HD Camera [14e4:1570]' >/dev/null
[[ -f "$modules/facetimehd.conf" ]] || fail "the FaceTime HD module is enabled at boot"
grep -Fxq facetimehd "$modules/facetimehd.conf" || fail "the module-load entry names facetimehd"
grep -Fq $'omarchy-pkg-aur-add\tfacetimehd-dkms' "$calls" ||
  fail "the AUR driver package is installed" "$(cat "$calls")"
grep -Fq $'omarchy-pkg-add\tlinux-headers' "$calls" ||
  fail "the kernel headers are installed" "$(cat "$calls")"
grep -Fq $'modprobe\t-r bdc_pci' "$calls" || fail "the conflicting bdc_pci driver is unloaded"
grep -Fq $'modprobe\tfacetimehd' "$calls" || fail "the camera driver is loaded immediately"
pass "Broadcom 1570 installs firmware, DKMS, and module loading"
