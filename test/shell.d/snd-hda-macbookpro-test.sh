#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/fix-snd-hda-macbookpro.sh"
all="$ROOT/install/hardware/all.sh"

# Test 1: Script exists and has proper structure
[[ -f $leaf ]] || fail "the audio fix script exists"
pass "the audio fix script exists"

grep -q '106b:3900\|CS8409' "$leaf" || fail "script detects Cirrus Logic CS8409"
pass "script detects Cirrus Logic CS8409"

grep -q 'snd_hda_macbookpro' "$leaf" || fail "script references snd_hda_macbookpro driver"
pass "script references snd_hda_macbookpro driver"

grep -q 'dkms' "$leaf" || fail "script uses DKMS for auto-rebuild on kernel updates"
pass "script uses DKMS for auto-rebuild on kernel updates"

grep -q 'omarchy-pkg-add' "$leaf" || fail "script uses omarchy-pkg-add for dependencies"
pass "script uses omarchy-pkg-add for dependencies"

# Test 2: Included in hardware setup
grep -q 'apple/fix-snd-hda-macbookpro.sh' "$all" || fail "the audio fix runs during hardware setup"
pass "the audio fix runs during hardware setup"

# Test 3: Script uses variable for driver dir
grep -q 'driver_dir=' "$leaf" || fail "script uses variable for driver directory"
pass "script uses variable for driver directory"

# Test 4: Script checks for existing installation before re-running
grep -q 'dkms status\|already installed\|\.git' "$leaf" || fail "script checks if already installed"
pass "script checks if already installed"

# Test 5: Script rebuilds initramfs after install
grep -q 'limine-mkinitcpio\|mkinitcpio' "$leaf" || fail "script rebuilds initramfs"
pass "script rebuilds initramfs"

echo "all tests passed"
