#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"
export TEST_STATE="$test_tmp/state"
export TEST_CALLS="$test_tmp/calls"
export TEST_FAULT=""
export TEST_DEVICE="0000:01:00.0"
export TEST_DEVICE_2="0000:02:00.0"
export PATH="$stub_bin:$PATH"

# Model kernel state separately from package files: DKMS removal deletes the
# latter and refreshes depmod, but cannot unload the module already in memory.
cat >"$stub_bin/stub" <<'SH'
#!/bin/bash
set -euo pipefail
command=${0##*/}
printf '%s %s\n' "$command" "$*" >>"$TEST_CALLS"

case "$command" in
  lspci)
    [[ $* == "-Dn -d 1f0a:6801" ]] || exit 90
    [[ $TEST_FAULT != "pci-fail" ]] || exit 1
    cat "$TEST_STATE/devices"
    [[ $TEST_FAULT != "pci-partial" ]] || exit 1
    ;;
  pacman)
    if [[ $* == "-Qq" ]]; then
      query_count=$(<"$TEST_STATE/queries")
      query_count=$((query_count + 1))
      printf '%s\n' "$query_count" >"$TEST_STATE/queries"
      printf '%s\n' linux
      if [[ -e $TEST_STATE/package ]]; then
        printf '%s\n' yt6801-dkms
      fi
      [[ $TEST_FAULT != "query-fail" ]] || exit 1
      if [[ $TEST_FAULT == "helper-query-fail" ]] && (( query_count == 2 )); then
        exit 1
      fi
      if [[ $TEST_FAULT == "final-query-fail" ]] && [[ ! -e $TEST_STATE/package ]]; then
        exit 1
      fi
    elif [[ $* == "-Rns --noconfirm yt6801-dkms" ]]; then
      [[ $TEST_FAULT != "remove-fail" ]] || exit 1
      if [[ $TEST_FAULT != "remove-noop" ]]; then
        rm -f "$TEST_STATE/package" "$TEST_STATE/module-files"
      fi
      if [[ $TEST_FAULT == "remove-reload" ]]; then
        touch "$TEST_STATE/vendor-loaded"
      elif [[ $TEST_FAULT == "remove-unbind" ]]; then
        rm -f "$TEST_STATE/bindings/$TEST_DEVICE"
      fi
      [[ $TEST_FAULT != "remove-interrupt" ]] || exit 1
    else
      exit 90
    fi
    ;;
  lsmod)
    [[ $TEST_FAULT != "modules-fail" ]] || exit 1
    if [[ $TEST_FAULT == "final-modules-fail" && ! -e $TEST_STATE/package ]]; then
      exit 1
    fi
    printf '%s\n' 'Module Size Used by'
    if [[ -e $TEST_STATE/vendor-loaded ]]; then
      printf '%s\n' 'yt6801 65536 0'
    fi
    ;;
  readlink)
    [[ $# == 2 && $1 == "-f" && $2 == /sys/bus/pci/devices/*/driver ]] || exit 90
    device=${2%/driver}
    device=${device##*/}
    [[ $TEST_FAULT != "binding-read-fail" ]] || exit 1
    if [[ -e $TEST_STATE/bindings/$device ]]; then
      printf '/sys/bus/pci/drivers/%s\n' "$(<"$TEST_STATE/bindings/$device")"
    else
      printf '%s\n' "$2"
    fi
    ;;
  modinfo)
    [[ $* == "-F alias dwmac-motorcomm" ]] || exit 90
    [[ $TEST_FAULT != "alias-fail" ]] || exit 1
    if [[ $TEST_FAULT == "alias-wrong" ]]; then
      printf '%s\n' 'pci:v00001F0Ad00006802sv*sd*bc*sc*i*'
    else
      printf '%s\n' 'pci:v00001F0Ad00006801sv*sd*bc*sc*i*'
    fi
    ;;
  modprobe)
    # Real modprobe cannot resolve a module through its deleted lookup entry.
    if [[ $* == "-r yt6801" ]]; then
      [[ -e $TEST_STATE/module-files ]] || exit 1
      exit 90
    fi
    [[ $* == "dwmac-motorcomm" ]] || exit 90
    [[ $TEST_FAULT != "load-fail" ]] || exit 1
    if [[ $TEST_FAULT != "load-noop" ]]; then
      touch "$TEST_STATE/upstream-loaded"
    fi
    [[ $TEST_FAULT != "load-interrupt" ]] || exit 1
    ;;
  rmmod)
    [[ $* == "yt6801" ]] || exit 90
    [[ $TEST_FAULT != "unload-fail" ]] || exit 1
    [[ -e $TEST_STATE/vendor-loaded ]] || exit 1
    if [[ $TEST_FAULT != "unload-noop" ]]; then
      rm "$TEST_STATE/vendor-loaded"
      for binding in "$TEST_STATE/bindings/"*; do
        if [[ -f $binding && $(<"$binding") == "yt6801" ]]; then
          rm "$binding"
        fi
      done
    fi
    [[ $TEST_FAULT != "unload-interrupt" ]] || exit 1
    ;;
  tee)
    [[ $* == "/sys/bus/pci/drivers_probe" ]] || exit 90
    read -r device
    [[ $device == "$TEST_DEVICE" || $device == "$TEST_DEVICE_2" ]] || exit 90
    [[ $TEST_FAULT != "probe-fail" ]] || exit 1
    if [[ $TEST_FAULT != "probe-noop" && -e $TEST_STATE/upstream-loaded && ! -e $TEST_STATE/bindings/$device ]]; then
      if [[ $TEST_FAULT != "second-probe-noop" || $device != "$TEST_DEVICE_2" ]]; then
        printf '%s\n' dwmac-motorcomm >"$TEST_STATE/bindings/$device"
      fi
    fi
    [[ $TEST_FAULT != "probe-interrupt" ]] || exit 1
    ;;
  sudo)
    [[ $TEST_FAULT != "sudo-fail" ]] || exit 1
    case "$*" in
      'modprobe dwmac-motorcomm'|'rmmod yt6801'|'tee /sys/bus/pci/drivers_probe'|'pacman -Rns --noconfirm yt6801-dkms') "$@" ;;
      *) exit 90 ;;
    esac
    ;;
  omarchy-notification-dismiss) ;;
  *) exit 90 ;;
esac
SH
chmod +x "$stub_bin/stub"
for command in lspci pacman lsmod readlink modinfo modprobe rmmod tee sudo omarchy-notification-dismiss; do
  ln -s stub "$stub_bin/$command"
done
ln -s "$ROOT/bin/omarchy-pkg-drop" "$stub_bin/omarchy-pkg-drop"

reset_state() {
  rm -rf "$TEST_STATE"
  mkdir -p "$TEST_STATE/bindings"
  : >"$TEST_CALLS"
  TEST_FAULT=""
  printf '%s\n' 0 >"$TEST_STATE/queries"
  printf '%s 0200: 1f0a:6801\n' "$TEST_DEVICE" >"$TEST_STATE/devices"
  printf '%s\n' yt6801 >"$TEST_STATE/bindings/$TEST_DEVICE"
  touch "$TEST_STATE/package" "$TEST_STATE/module-files" "$TEST_STATE/vendor-loaded"
}

run_migration() {
  bash -euo pipefail "$ROOT/migrations/1788279117.sh" >"$test_tmp/output" 2>&1
}

assert_complete() {
  [[ ! -e $TEST_STATE/package ]] || fail "completed migration left the vendor package installed"
  [[ ! -e $TEST_STATE/vendor-loaded ]] || fail "completed migration left the vendor module loaded"
  local device rest
  while read -r device rest; do
    [[ -n $device ]] || continue
    [[ -f $TEST_STATE/bindings/$device && $(<"$TEST_STATE/bindings/$device") == "dwmac-motorcomm" ]] ||
      fail "completed migration left an adapter without the upstream driver" "$device"
  done <"$TEST_STATE/devices"
}

assert_no_privileges() {
  if grep -q '^sudo ' "$TEST_CALLS"; then
    fail "$1" "$(<"$TEST_CALLS")"
  fi
}

reset_state
run_migration
assert_complete
# Enforce the safe ordering across the modeled DKMS package transaction.
[[ $(grep -E '^(modprobe|rmmod|tee|pacman -Rns) ' "$TEST_CALLS") == "$(printf '%s\n' \
  'modprobe dwmac-motorcomm' 'rmmod yt6801' 'tee /sys/bus/pci/drivers_probe' 'pacman -Rns --noconfirm yt6801-dkms')" ]] ||
  fail "the replacement must bind before DKMS package removal"
pass "migration cuts over before removing the vendor package and module files"

: >"$TEST_CALLS"
TEST_FAULT=sudo-fail
run_migration
assert_complete
assert_no_privileges "a later user's completed migration must need no privileges"
if grep -Eq '^(modinfo|modprobe|rmmod|tee) ' "$TEST_CALLS"; then
  fail "a completed migration must not need module metadata or reprobe"
fi
pass "completed machines need no privileges, module metadata, or reprobe"

reset_state
printf '%s 0200: 1f0a:6801\n' "$TEST_DEVICE_2" >>"$TEST_STATE/devices"
printf '%s\n' yt6801 >"$TEST_STATE/bindings/$TEST_DEVICE_2"
run_migration
assert_complete
pass "every target adapter is rebound and verified"

for fault in pci-fail pci-partial query-fail modules-fail alias-fail alias-wrong; do
  reset_state
  TEST_FAULT=$fault
  if run_migration; then
    fail "migration must fail on $fault"
  fi
  assert_no_privileges "$fault must be detected before changing hardware or packages"
  [[ -e $TEST_STATE/package && -e $TEST_STATE/vendor-loaded ]] || fail "$fault lost the installed fallback"
  pass "$fault fails before cutover"
done

reset_state
printf '%s\n' 'invalid-address 0200: 1f0a:6801' >"$TEST_STATE/devices"
if run_migration; then
  fail "malformed PCI enumeration must fail the migration"
fi
assert_no_privileges "invalid PCI data must be rejected before privileged work"
pass "invalid PCI addresses cannot reach the reprobe command"

for fault in sudo-fail load-fail load-noop unload-fail unload-noop probe-fail probe-noop binding-read-fail helper-query-fail remove-fail; do
  reset_state
  TEST_FAULT=$fault
  if run_migration; then
    fail "migration must fail on $fault"
  fi
  [[ -e $TEST_STATE/package ]] || fail "$fault discarded the package before cutover succeeded"
  TEST_FAULT=""
  run_migration
  assert_complete
  pass "$fault preserves the package and permits a successful retry"
done

for fault in remove-noop remove-reload remove-unbind final-query-fail final-modules-fail; do
  reset_state
  TEST_FAULT=$fault
  if run_migration; then
    fail "postconditions must detect $fault"
  fi
  TEST_FAULT=""
  run_migration
  assert_complete
  pass "postconditions detect $fault and a retry completes"
done

for fault in load-interrupt unload-interrupt probe-interrupt remove-interrupt; do
  reset_state
  TEST_FAULT=$fault
  if run_migration; then
    fail "interrupted $fault must fail the migration"
  fi
  TEST_FAULT=""
  run_migration
  assert_complete
  pass "retry completes after $fault"
done

reset_state
rm "$TEST_STATE/package" "$TEST_STATE/module-files"
run_migration
assert_complete
pass "retry unloads the vendor module even after an earlier DKMS removal deleted its files"

reset_state
rm "$TEST_STATE/vendor-loaded" "$TEST_STATE/bindings/$TEST_DEVICE"
run_migration
assert_complete
pass "an initially unbound adapter is reprobed without unloading an absent vendor module"

reset_state
rm "$TEST_STATE/vendor-loaded"
printf '%s\n' dwmac-motorcomm >"$TEST_STATE/bindings/$TEST_DEVICE"
TEST_FAULT=alias-fail
run_migration
assert_complete
pass "an already-bound adapter only needs package cleanup even if module metadata is unavailable"

reset_state
printf '%s 0200: 1f0a:6801\n' "$TEST_DEVICE_2" >>"$TEST_STATE/devices"
printf '%s\n' yt6801 >"$TEST_STATE/bindings/$TEST_DEVICE_2"
TEST_FAULT=second-probe-noop
if run_migration; then
  fail "one working adapter must not hide another adapter's failed cutover"
fi
[[ -e $TEST_STATE/package ]] || fail "partial cutover removed the vendor package"
TEST_FAULT=""
run_migration
assert_complete
pass "partial multi-adapter cutover remains pending and can be retried"

for driver in dwmac-motorcomm-extra dwmac_motorcomm vfio-pci; do
  reset_state
  rm "$TEST_STATE/vendor-loaded"
  printf '%s\n' "$driver" >"$TEST_STATE/bindings/$TEST_DEVICE"
  if run_migration; then
    fail "unexpected driver $driver must not count as upstream binding"
  fi
  [[ -e $TEST_STATE/package && $(<"$TEST_STATE/bindings/$TEST_DEVICE") == "$driver" ]] ||
    fail "failed cutover must preserve an unrelated binding and the package"
  pass "exact sysfs binding rejects $driver without forcibly unbinding it"
done

reset_state
: >"$TEST_STATE/devices"
rm -f "$TEST_STATE/bindings/$TEST_DEVICE"
run_migration
assert_complete
pass "without target hardware, the migration still unloads and removes the vendor driver"

: >"$TEST_CALLS"
TEST_FAULT=sudo-fail
run_migration
assert_no_privileges "an unaffected machine must need no privileges"
pass "an unaffected machine is a successful no-op"

# Setup leaves are sourced. A manual rerun on an old or partially migrated
# system must leave the fallback in place for the migration's proven cutover.
reset_state
bash -eE -c 'source "$1"' bash "$ROOT/install/hardware/fix-yt6801-ethernet-adapter.sh"
[[ -e $TEST_STATE/package && -e $TEST_STATE/vendor-loaded ]] ||
  fail "manual hardware setup retired the YT6801 fallback"
[[ ! -s $TEST_CALLS ]] ||
  fail "manual hardware setup performed package, discovery, or module work" "$(cat "$TEST_CALLS")"
pass "manual hardware setup leaves the vendor fallback for the proven migration cutover"

# Exercise the real runner's completion markers and queue, without using the
# current user's state directory or running any other repository migrations.
reset_state
mkdir -p "$test_tmp/omarchy/migrations"
ln -s "$ROOT/migrations/1788279117.sh" "$test_tmp/omarchy/migrations/1788279117.sh"
printf '%s\n' 'touch "$TEST_STATE/later-migration"' >"$test_tmp/omarchy/migrations/1788279118.sh"
export OMARCHY_PATH="$test_tmp/omarchy"
export OMARCHY_MIGRATION_STATE="$test_tmp/migration-state"
TEST_FAULT=probe-noop
if "$ROOT/bin/omarchy-migrate" >"$test_tmp/output" 2>&1; then
  fail "migration runner must fail when cutover is incomplete"
fi
[[ ! -e $OMARCHY_MIGRATION_STATE/1788279117.sh && ! -e $TEST_STATE/later-migration ]] ||
  fail "failed cutover must not write a completion marker or run later migrations"
TEST_FAULT=""
"$ROOT/bin/omarchy-migrate" >"$test_tmp/output" 2>&1
assert_complete
[[ -f $OMARCHY_MIGRATION_STATE/1788279117.sh && -f $TEST_STATE/later-migration ]] ||
  fail "successful retry must mark completion and continue the queue"
pass "the real migration runner keeps failures pending and completes successful retries"

if grep -Fxq 'yt6801-dkms' "$ROOT/install/omarchy-other.packages"; then
  fail "default package list still installs yt6801-dkms"
fi
pass "the default package list no longer installs the vendor driver"
