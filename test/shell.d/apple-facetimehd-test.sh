#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/fix-facetimehd.sh"
all="$ROOT/install/hardware/all.sh"
migration="$ROOT/migrations/1789743826.sh"

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

# The sudo stub runs its command for real, so without this the hook install
# reaches /usr/lib/systemd/system-sleep on the machine running the suite.
cat >"$stub_bin/install" <<'SH'
#!/bin/bash

printf 'install' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
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
grep -Fq $'sudo\tmodprobe\tfacetimehd' "$calls" ||
  fail "the live load runs through sudo (migration runs as the user)" "$(cat "$calls")"
pass "a pre-T2 Mac with the camera installs driver and firmware"

grep -Fq $'install\t-Dm755' "$calls" &&
  grep -Fq 'system-sleep/facetimehd' "$calls" ||
  fail "a pre-T2 Mac with the camera installs the hibernate hook" "$(cat "$calls")"
pass "a pre-T2 Mac with the camera installs the hibernate hook"

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

# The hook has to unload the driver for hibernate, keep out of S3, and load it
# again after waking: the hang it avoids happens inside the device-freeze.
hook="$ROOT/default/systemd/system-sleep/facetimehd"

hook_module="$test_tmp/module"
hook_marker="$test_tmp/unloaded"

hook_run() {
  local phase="$1" action="$2" verb="${3:-$2}"
  : >"$calls"
  PATH="$stub_bin:$PATH" TEST_LOG="$calls" SYSTEMD_SLEEP_ACTION="$action" \
    OMARCHY_FACETIMEHD_MODULE="$hook_module" OMARCHY_FACETIMEHD_MARKER="$hook_marker" \
    bash "$hook" "$phase" "$verb" >/dev/null 2>&1
}

mkdir -p "$hook_module"

hook_run pre hibernate
grep -Fq $'modprobe\t-r\tfacetimehd' "$calls" ||
  fail "the hook unloads the camera driver before hibernating" "$(cat "$calls")"
pass "the hook unloads the camera driver before hibernating"

hook_run post hibernate
grep -Fq $'modprobe\tfacetimehd' "$calls" && [[ ! -e $hook_marker ]] ||
  fail "the hook loads the camera driver again after resuming" "$(cat "$calls")"
pass "the hook loads the camera driver again after resuming"

hook_cycle() {
  hook_run pre "$@"
  grep -Fq $'modprobe\t-r\tfacetimehd' "$calls" || return 1
  hook_run post "$@"
  grep -Fq $'modprobe\tfacetimehd' "$calls" && [[ ! -e $hook_marker ]]
}

hook_cycle hybrid-sleep ||
  fail "the hook unloads and reloads the camera driver across hybrid sleep" "$(cat "$calls")"
pass "the hook unloads and reloads the camera driver across hybrid sleep"

hook_cycle hibernate suspend-then-hibernate ||
  fail "the hook unloads and reloads the camera driver across suspend-then-hibernate's hibernation" "$(cat "$calls")"
pass "the hook unloads and reloads the camera driver across suspend-then-hibernate's hibernation"

hook_run pre suspend
[[ ! -s $calls ]] || fail "the hook leaves S3 alone" "$(cat "$calls")"
hook_run post suspend
[[ ! -s $calls ]] || fail "the hook leaves S3 alone" "$(cat "$calls")"
pass "the hook leaves S3 alone"

rmdir "$hook_module"
touch "$hook_marker" # left by a cycle whose post never ran
for action in suspend hibernate; do
  hook_run pre $action
  hook_run post $action
  [[ ! -s $calls ]] || fail "a camera driver the user unloaded stays unloaded after $action" "$(cat "$calls")"
done
pass "a camera driver the user unloaded stays unloaded after resume"
