#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/fix-macbook12-audio.sh"
all="$ROOT/install/hardware/all.sh"

# Test 1: Script exists and has proper structure
[[ -f $leaf ]] || fail "the audio fix script exists"
pass "the audio fix script exists"

grep -q 'MacBook9,1\|MacBook10,1' "$leaf" || fail "script gates on 12-inch MacBook models"
pass "script gates on 12-inch MacBook models"

grep -q 'macbook12-audio-driver' "$leaf" || fail "script references the macbook12-audio driver"
pass "script references the macbook12-audio driver"

grep -q 'dkms' "$leaf" || fail "script uses DKMS for auto-rebuild on kernel updates"
pass "script uses DKMS for auto-rebuild on kernel updates"

grep -q 'install.cirrus.driver.sh' "$leaf" || fail "script installs the driver via its DKMS installer"
pass "script installs the driver via its DKMS installer"

grep -q 'omarchy-pkg-add' "$leaf" || fail "script uses omarchy-pkg-add for build prerequisites"
pass "script uses omarchy-pkg-add for build prerequisites"

# Test 2: Speaker needs software volume
grep -q '51-macbook-cs4208-softvol' "$leaf" || fail "script installs the WirePlumber soft-mixer rule"
pass "script installs the WirePlumber soft-mixer rule"

grep -q 'api.alsa.soft-mixer' "$leaf" || fail "script forces software volume mixing"
pass "script forces software volume mixing"

# Test 3: EFI startup chime is un-muted (firmware powers the amp only on chime)
grep -q 'SystemAudioVolume' "$leaf" || fail "script un-mutes the EFI startup chime"
pass "script un-mutes the EFI startup chime"

grep -q '0x80' "$leaf" || fail "script clears the chime mute bit (0x80)"
pass "script clears the chime mute bit (0x80)"

# Test 4: Codec is kept out of D3cold across suspend
grep -q 'd3cold_allowed' "$leaf" || fail "script pins the audio codec out of D3cold"
pass "script pins the audio codec out of D3cold"

grep -q 'omarchy-macbook12-audio-suspend.service' "$leaf" || fail "script installs a systemd suspend-fix service"
pass "script installs a systemd suspend-fix service"

# Test 5: Included in hardware setup
grep -q 'apple/fix-macbook12-audio.sh' "$all" || fail "the audio fix runs during hardware setup"
pass "the audio fix runs during hardware setup"

echo "all tests passed"
