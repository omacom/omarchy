#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

detector="$ROOT/bin/omarchy-hw-imac-cs4208"
leaf="$ROOT/install/user/hardware/apple/fix-imac-cs4208-speakers.sh"
all="$ROOT/install/user/all.sh"
conf="$ROOT/default/wireplumber/wireplumber.conf.d/imac-cs4208-speakers.conf"
migration=$(grep -l "fix-imac-cs4208-speakers" "$ROOT"/migrations/*.sh | head -1)

[[ -x $detector ]] || fail "the detector is executable"
pass "the detector is executable"

grep -q 'run_logged .*hardware/apple/fix-imac-cs4208-speakers.sh' "$all" ||
  fail "the CS4208 speaker workaround runs during user setup"
pass "the CS4208 speaker workaround runs during user setup"

[[ -n $migration ]] || fail "a migration enables the workaround on existing installs"
pass "a migration enables the workaround on existing installs"

grep -q 'output:analog-surround-40+input:analog-stereo' "$conf" ||
  fail "the WirePlumber drop-in selects Analog Surround 4.0"
grep -q 'api.alsa.soft-mixer = true' "$conf" ||
  fail "the WirePlumber drop-in uses software volume"
grep -q 'alsa.mixer_name = "Cirrus Logic CS4208"' "$conf" ||
  fail "the WirePlumber drop-in matches the CS4208 mixer, not a PCI path"
! grep -q '0000_00_1b.0' "$conf" ||
  fail "the WirePlumber drop-in does not hard-code a PCI device path"
pass "the WirePlumber drop-in selects 4.0 output and software volume on CS4208"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

run_detector() {
  local name_file="$test_tmp/product_name"
  printf '%s\n' "$1" >"$name_file"
  OMARCHY_DMI_PRODUCT_NAME="$name_file" bash "$detector"
}

run_detector "iMac16,2" || fail "the detector matches iMac16,2"
pass "the detector matches iMac16,2"

run_detector "iMac16,1" || fail "the detector matches iMac16,1"
pass "the detector matches iMac16,1"

run_detector "imac16,2" || fail "the detector matches iMac16,2 case-insensitively"
pass "the detector matches iMac16,2 case-insensitively"

run_detector "iMac17,1" && fail "the detector rejects iMac17,1"
pass "the detector rejects iMac17,1"

run_detector "iMac18,3" && fail "the detector rejects later CS8409 iMacs"
pass "the detector rejects later CS8409 iMacs"

run_detector "MacBookPro12,1" && fail "the detector rejects other Apple machines"
pass "the detector rejects other Apple machines"

run_detector "iMac16,20" && fail "the detector rejects a longer product name"
pass "the detector rejects a longer product name"

run_detector "" && fail "the detector fails closed on an empty product name"
pass "the detector fails closed on an empty product name"

OMARCHY_DMI_PRODUCT_NAME="$test_tmp/absent" bash "$detector" &&
  fail "the detector fails closed when the DMI attribute is missing"
pass "the detector fails closed when the DMI attribute is missing"

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/omarchy-hw-imac-cs4208" <<'SH'
#!/bin/bash
[[ ${TEST_PRODUCT_NAME:-} == iMac16,1 || ${TEST_PRODUCT_NAME:-} == iMac16,2 ]]
SH

cat >"$stub_bin/aplay" <<'SH'
#!/bin/bash
printf '%s\n' 'card 1: PCH [HDA Intel PCH], device 0: CS4208 Analog [CS4208 Analog]'
SH

cat >"$stub_bin/amixer" <<'SH'
#!/bin/bash
printf 'amixer' >>"$CALL_LOG"
printf '\t%s' "$@" >>"$CALL_LOG"
printf '\n' >>"$CALL_LOG"
SH

chmod +x "$stub_bin"/*

run_leaf() {
  local home="$test_tmp/home"
  rm -rf "$home"
  mkdir -p "$home"
  : >"$test_tmp/calls.log"
  HOME="$home" \
    PATH="$stub_bin:$PATH" \
    OMARCHY_PATH="$ROOT" \
    CALL_LOG="$test_tmp/calls.log" \
    TEST_PRODUCT_NAME="${1-iMac16,2}" \
    bash -c 'source "$1"' bash "$leaf"
}

run_leaf || fail "the leaf installs the WirePlumber drop-in on the target machine"
[[ -f $test_tmp/home/.config/wireplumber/wireplumber.conf.d/imac-cs4208-speakers.conf ]] ||
  fail "the leaf installs the WirePlumber drop-in on the target machine"
grep -q $'amixer\t-c\t1\tset\tMaster\t100%\tunmute' "$test_tmp/calls.log" ||
  fail "the leaf opens the CS4208 Master mixer"
pass "the leaf installs the WirePlumber drop-in on the target machine"

run_leaf "ThinkPad X1" || fail "the leaf no-ops on other hardware"
[[ -e $test_tmp/home/.config/wireplumber/wireplumber.conf.d/imac-cs4208-speakers.conf ]] &&
  fail "the leaf no-ops on other hardware"
[[ -s $test_tmp/calls.log ]] && fail "the leaf no-ops on other hardware"
pass "the leaf no-ops on other hardware"

run_migration() {
  local home="$test_tmp/home"
  rm -rf "$home"
  mkdir -p "$home"
  : >"$test_tmp/calls.log"
  HOME="$home" \
    PATH="$stub_bin:$PATH" \
    OMARCHY_PATH="$ROOT" \
    CALL_LOG="$test_tmp/calls.log" \
    TEST_PRODUCT_NAME="${1-iMac16,2}" \
    bash -euo pipefail "$migration" >/dev/null
}

run_migration || fail "the migration installs the workaround on the target machine"
[[ -f $test_tmp/home/.config/wireplumber/wireplumber.conf.d/imac-cs4208-speakers.conf ]] ||
  fail "the migration installs the workaround on the target machine"
pass "the migration installs the workaround on the target machine"

run_migration "ThinkPad X1" || fail "the migration no-ops on other hardware"
[[ -e $test_tmp/home/.config/wireplumber/wireplumber.conf.d/imac-cs4208-speakers.conf ]] &&
  fail "the migration no-ops on other hardware"
pass "the migration no-ops on other hardware"
