#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/fix-facetimehd.sh"
all="$ROOT/install/hardware/all.sh"
migration="$ROOT/migrations/1789095456.sh"

grep -Fq 'apple/fix-facetimehd.sh' "$all" ||
  fail "the FaceTime HD quirk runs during hardware setup"
pass "the FaceTime HD quirk runs during hardware setup"

grep -Fq 'fix-facetimehd.sh' "$migration" ||
  fail "the migration applies the FaceTime HD quirk" "$migration"
pass "the migration applies the FaceTime HD quirk"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
mkdir -p "$stub_bin" "$test_tmp/dmi"

cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash

if (( ${FACETIMEHD_HARDWARE:-0} == 1 )); then
  echo '05:00.0 Multimedia controller [0480]: Broadcom Inc. and subsidiaries 720p FaceTime HD Camera [14e4:1570]'
else
  echo '00:02.0 VGA compatible controller [0300]: Intel Corporation HD Graphics [8086:0d26]'
fi
SH

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
"$@"
SH

cat >"$stub_bin/omarchy-pkg-aur-add" <<'SH'
#!/bin/bash

printf 'pkg-aur-add %s\n' "$*" >>"$TEST_LOG"
(( ${PKG_FAIL:-0} == 0 ))
SH

cat >"$stub_bin/modprobe" <<'SH'
#!/bin/bash

printf 'modprobe' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
(( ${MODPROBE_FAIL:-0} == 0 ))
SH

chmod +x "$stub_bin"/*

run_leaf() {
  local vendor="$1" camera="${2:-0}" pkg_fail="${3:-0}"
  printf '%s' "$vendor" >"$test_tmp/dmi/sys_vendor"
  : >"$calls"

  OMARCHY_DMI_VENDOR="$test_tmp/dmi/sys_vendor" \
    FACETIMEHD_HARDWARE="$camera" PKG_FAIL="$pkg_fail" \
    PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    bash -eE -o pipefail -c 'source "$1"' bash "$leaf" </dev/null
}

run_leaf "Apple Inc." 1 >/dev/null
grep -Fq 'pkg-aur-add facetimehd-firmware facetimehd-dkms-git' "$calls" ||
  fail "a pre-T2 Mac with the camera installs driver and firmware" "$(cat "$calls")"
grep -Fq $'modprobe\tfacetimehd' "$calls" ||
  fail "a live session loads the driver without a reboot" "$(cat "$calls")"
pass "a pre-T2 Mac with the camera installs driver and firmware"

run_leaf "Apple Inc." 0 >/dev/null
[[ ! -s $calls ]] || fail "an Apple machine without the camera is left alone" "$(cat "$calls")"
pass "an Apple machine without the camera is left alone"

run_leaf "LENOVO" 0 >/dev/null
[[ ! -s $calls ]] || fail "non-Apple hardware is left alone" "$(cat "$calls")"
pass "non-Apple hardware is left alone"

run_leaf "Apple Computer, Inc." 1 >/dev/null
grep -Fq 'pkg-aur-add facetimehd-firmware facetimehd-dkms-git' "$calls" ||
  fail "the older Apple vendor string is recognized"
pass "the older Apple vendor string is recognized"

# A failed package install warns instead of aborting hardware setup.
set +e
run_leaf "Apple Inc." 1 1 >/dev/null
status=$?
set -e
(( status == 0 )) || fail "a failed package install does not abort hardware setup"
grep -Fq $'modprobe\t-qn\tfacetimehd' "$calls" ||
  fail "a failed install still probes for a live load" "$(cat "$calls")"
pass "a failed package install warns instead of aborting"

run_migration() {
  local vendor="$1" camera="${2:-0}"
  printf '%s' "$vendor" >"$test_tmp/dmi/sys_vendor"
  : >"$calls"

  OMARCHY_PATH="$ROOT" \
    OMARCHY_DMI_VENDOR="$test_tmp/dmi/sys_vendor" \
    FACETIMEHD_HARDWARE="$camera" \
    PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    bash -euo pipefail "$migration" >/dev/null
}

run_migration "Apple Inc." 1
grep -Fq 'pkg-aur-add facetimehd-firmware facetimehd-dkms-git' "$calls" ||
  fail "the migration installs driver and firmware on a pre-T2 Mac with the camera"
pass "the migration installs driver and firmware on a pre-T2 Mac with the camera"

run_migration "LENOVO" 0
[[ ! -s $calls ]] || fail "the migration leaves other hardware alone" "$(cat "$calls")"
pass "the migration leaves other hardware alone"
