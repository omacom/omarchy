#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/fix-pre-t2-hibernate.sh"
all="$ROOT/install/hardware/all.sh"
migration="$ROOT/migrations/1789095456.sh"

grep -Fq 'apple/fix-pre-t2-hibernate.sh' "$all" ||
  fail "the pre-T2 hibernate quirk runs during hardware setup"
pass "the pre-T2 hibernate quirk runs during hardware setup"

grep -Fq 'HibernateMode=shutdown' "$leaf" ||
  fail "the quirk installs HibernateMode=shutdown"
grep -Fq '106b:180[12]' "$leaf" ||
  fail "the quirk tells T2 Macs apart from pre-T2 Macs"
pass "the quirk targets pre-T2 Apple hardware"

grep -Fq 'fix-pre-t2-hibernate.sh' "$migration" ||
  fail "the migration applies the pre-T2 hibernate quirk" "$migration"
pass "the migration applies the pre-T2 hibernate quirk"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
conf="$test_tmp/etc/systemd/sleep.conf.d/hibernatemode.conf"
mkdir -p "$stub_bin" "$test_tmp/dmi"

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
"$@"
SH

cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash

if (( ${T2_HARDWARE:-0} == 1 )); then
  echo '01:00.0 Bridge [0680]: Apple Inc. T2 Security Chip [106b:1801]'
else
  echo '02:00.0 SATA controller [0106]: Samsung AHCI SSD [144d:a801]'
fi
SH

chmod +x "$stub_bin"/*

run_leaf() {
  local vendor="$1" t2="${2:-0}" keep="${3:-0}"
  if (( keep == 0 )); then
    rm -rf "$test_tmp/etc"
    mkdir -p "$test_tmp/etc"
  fi
  printf '%s' "$vendor" >"$test_tmp/dmi/sys_vendor"
  : >"$calls"

  OMARCHY_DMI_VENDOR="$test_tmp/dmi/sys_vendor" \
    OMARCHY_HIBERNATE_MODE_CONF="$conf" \
    T2_HARDWARE="$t2" \
    PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    bash -eE -o pipefail "$leaf" </dev/null
}

run_leaf "Apple Inc." 0 >/dev/null
[[ -f $conf ]] || fail "a pre-T2 Mac gets the hibernate drop-in"
grep -qx 'HibernateMode=shutdown' "$conf" ||
  fail "the drop-in switches hibernation to shutdown mode" "$(cat "$conf")"
pass "a pre-T2 Mac gets the hibernate drop-in"

before=$(<"$conf")
: >"$calls"
run_leaf "Apple Inc." 0 1 >/dev/null
[[ $(<"$conf") == "$before" ]] || fail "a second run leaves the drop-in alone"
grep -q 'tee' "$calls" &&
  fail "an already-configured install escalates nothing" "$(cat "$calls")"
pass "a second run leaves the drop-in alone"

run_leaf "Apple Inc." 1 >/dev/null
[[ ! -f $conf ]] || fail "a T2 Mac is left alone"
[[ ! -s $calls ]] || fail "a T2 Mac escalates nothing" "$(cat "$calls")"
pass "a T2 Mac is left alone"

run_leaf "LENOVO" 0 >/dev/null
[[ ! -f $conf ]] || fail "non-Apple hardware is left alone"
[[ ! -s $calls ]] || fail "non-Apple hardware escalates nothing" "$(cat "$calls")"
pass "non-Apple hardware is left alone"

run_leaf "Apple Computer, Inc." 0 >/dev/null
[[ -f $conf ]] || fail "the older Apple vendor string is recognized"
pass "the older Apple vendor string is recognized"

rm -rf "$test_tmp/etc"
mkdir -p "$test_tmp/etc"
printf '%s' "Apple Inc." >"$test_tmp/dmi/sys_vendor"
: >"$calls"
OMARCHY_PATH="$ROOT" \
  OMARCHY_DMI_VENDOR="$test_tmp/dmi/sys_vendor" \
  OMARCHY_HIBERNATE_MODE_CONF="$conf" \
  T2_HARDWARE=0 \
  PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
  bash -euo pipefail "$migration" >/dev/null
[[ -f $conf ]] || fail "the migration installs the drop-in on a pre-T2 Mac"
pass "the migration installs the drop-in on a pre-T2 Mac"
