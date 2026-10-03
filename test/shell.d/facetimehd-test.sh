#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/fix-facetimehd.sh"
hw="$ROOT/bin/omarchy-hw-facetimehd"
all="$ROOT/install/hardware/all.sh"
manual="$ROOT/manual/44-mac-support.md"
other_packages="$ROOT/install/omarchy-other.packages"
migration="$ROOT/migrations/1789542390.sh"

grep -q 'apple/fix-facetimehd.sh' "$all" ||
  fail "the FaceTime HD fix runs during hardware setup"
grep -q 'omarchy-hw-facetimehd' "$leaf" ||
  fail "the install leaf keys off the FaceTime HD detector"
grep -q 'facetimehd-dkms' "$leaf" ||
  fail "the install leaf installs facetimehd-dkms"
grep -qx 'facetimehd-dkms' "$other_packages" ||
  fail "the ISO caches facetimehd-dkms"
grep -qx 'facetimehd-firmware' "$other_packages" ||
  fail "the ISO caches facetimehd-firmware"
grep -qx 'facetimehd-data' "$other_packages" ||
  fail "the ISO caches facetimehd-data"
grep -q '14e4:1570' "$hw" ||
  fail "the detector matches the Broadcom 1570 PCI ID"
grep -q 'FaceTime HD' "$manual" ||
  fail "Mac support documents the FaceTime HD camera"
grep -q 'fix-facetimehd.sh' "$migration" ||
  fail "a migration applies the FaceTime HD fix on existing installs"
pass "the FaceTime HD fix is wired into hardware setup"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
mkdir -p "$stub_bin"
: >"$calls"

cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash

# Chatty like real lspci: keep writing well past the pipe buffer after the
# match, so a grep -q consumer would kill this stub with SIGPIPE and pipefail
# would read that as "no such hardware" (#6608).
if (( ${FACETIMEHD_HARDWARE:-0} == 1 )); then
  echo '02:00.0 Multimedia controller [0480]: Broadcom Inc. 720p FaceTime HD Camera [14e4:1570]'
fi
for _ in {1..4096}; do
  echo '00:00.0 Host bridge [0600]: Filler Device [ffff:0000]'
done
SH

cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash

printf 'omarchy-pkg-add' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
SH

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
"$@"
SH

install -m0755 "$hw" "$stub_bin/omarchy-hw-facetimehd"
chmod +x "$stub_bin"/*

# Detector: present
FACETIMEHD_HARDWARE=1 PATH="$stub_bin:$PATH" "$stub_bin/omarchy-hw-facetimehd"
pass "detector matches PCI 14e4:1570"

# Detector: absent
if FACETIMEHD_HARDWARE=0 PATH="$stub_bin:$PATH" "$stub_bin/omarchy-hw-facetimehd"; then
  fail "detector ignores machines without a FaceTime HD camera"
fi
pass "detector skips machines without a FaceTime HD camera"

run_leaf() {
  local hardware="$1"
  : >"$calls"
  FACETIMEHD_HARDWARE="$hardware" PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    bash -euo pipefail -c 'source "$1"' _ "$leaf"
}

run_leaf 1
grep -Fxq $'omarchy-pkg-add\tfacetimehd-firmware\tfacetimehd-data\tfacetimehd-dkms' "$calls" ||
  fail "leaf installs firmware, calibration data, and the DKMS module" "$(cat "$calls")"
pass "leaf installs firmware, calibration data, and the DKMS module"

run_leaf 0
[[ ! -s $calls ]] || fail "non-matching hardware is a no-op" "$(cat "$calls")"
pass "leaf is a no-op on machines without a FaceTime HD camera"

run_migration() {
  local hardware="$1"
  : >"$calls"
  FACETIMEHD_HARDWARE="$hardware" PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    OMARCHY_PATH="$ROOT" \
    bash -euo pipefail "$migration" >/dev/null
}

run_migration 1
grep -Fxq $'omarchy-pkg-add\tfacetimehd-firmware\tfacetimehd-data\tfacetimehd-dkms' "$calls" ||
  fail "the migration installs the FaceTime HD packages" "$(cat "$calls")"
pass "the migration installs the FaceTime HD packages"

run_migration 0
[[ ! -s $calls ]] || fail "the migration is a no-op without a FaceTime HD camera" "$(cat "$calls")"
pass "the migration is a no-op without a FaceTime HD camera"
