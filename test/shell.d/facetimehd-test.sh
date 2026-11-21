#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/fix-facetimehd.sh"
hw="$ROOT/bin/omarchy-hw-facetimehd"
all="$ROOT/install/hardware/all.sh"
manual="$ROOT/manual/44-mac-support.md"
other_packages="$ROOT/install/omarchy-other.packages"

grep -q 'apple/fix-facetimehd.sh' "$all" ||
  fail "the FaceTime HD fix runs during hardware setup"
grep -q 'omarchy-hw-facetimehd' "$leaf" ||
  fail "the install leaf keys off the FaceTime HD detector"
grep -q 'facetimehd-dkms' "$leaf" ||
  fail "the install leaf installs facetimehd-dkms"
grep -qx 'facetimehd-dkms' "$other_packages" ||
  fail "the ISO caches facetimehd-dkms"
grep -qx 'facetimehd-firmware-fetcher' "$other_packages" ||
  fail "the ISO caches facetimehd-firmware-fetcher"
! grep -qxE 'facetimehd-(firmware|data)' "$other_packages" ||
  fail "the ISO carries no Apple firmware, which may not be redistributed"
grep -q '14e4:1570' "$hw" ||
  fail "the detector matches the Broadcom 1570 PCI ID"
grep -q 'FaceTime HD' "$manual" ||
  fail "Mac support documents the FaceTime HD camera"
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
printf '%s\n' "$@" >>"$TEST_INSTALLED"
SH

# -T answers for what is installed or named in FACETIMEHD_PROVIDED, as an AUR package providing it would be.
cat >"$stub_bin/pacman" <<'SH'
#!/bin/bash

satisfied() {
  grep -qxF -- "$1" "$TEST_INSTALLED" || [[ " ${FACETIMEHD_PROVIDED:-} " == *" $1 "* ]]
}

case "$1" in
  -T) for dep in "${@:2}"; do satisfied "$dep" || { echo "$dep"; exit 127; }; done ;;
  -Q) grep -qxF -- "$2" "$TEST_INSTALLED" ;;
  *) exit 2 ;;
esac
SH

cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash

printf 'systemctl' >>"$TEST_LOG"
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

installed="$test_tmp/installed"

run_leaf() {
  local hardware="$1" provided="${2:-}"
  : >"$calls"
  : >"$installed"
  FACETIMEHD_HARDWARE="$hardware" FACETIMEHD_PROVIDED="$provided" PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    TEST_INSTALLED="$installed" bash -euo pipefail -c 'source "$1"' _ "$leaf"
}

fetcher_enabled=$'systemctl\tenable\tfacetimehd-firmware-fetcher.service'

run_leaf 1
grep -Fxq $'omarchy-pkg-add\tfacetimehd-dkms\tfacetimehd-firmware-fetcher' "$calls" ||
  fail "leaf installs the DKMS module and the firmware fetcher" "$(cat "$calls")"
grep -Fxq "$fetcher_enabled" "$calls" ||
  fail "leaf enables the fetch for a first boot with a network" "$(cat "$calls")"
pass "leaf installs the DKMS module and the firmware fetcher, and enables the fetch"

run_leaf 1 facetimehd-dkms
grep -Fxq $'omarchy-pkg-add\tfacetimehd-firmware-fetcher' "$calls" ||
  fail "leaf keeps a driver the AUR already provides" "$(cat "$calls")"
pass "leaf keeps a driver the AUR already provides"

run_leaf 1 bcwc-pcie
grep -Fxq $'omarchy-pkg-add\tfacetimehd-firmware-fetcher' "$calls" ||
  fail "leaf keeps the legacy bcwc-pcie driver" "$(cat "$calls")"
pass "leaf keeps the legacy bcwc-pcie driver"

run_leaf 1 "facetimehd-dkms facetimehd-data"
! grep -q -e omarchy-pkg-add -e systemctl "$calls" ||
  fail "leaf installs nothing where the driver and firmware are already provided" "$(cat "$calls")"
pass "leaf installs nothing where the driver and firmware are already provided"

run_leaf 0
[[ ! -s $calls ]] || fail "non-matching hardware is a no-op" "$(cat "$calls")"
pass "leaf is a no-op on machines without a FaceTime HD camera"
