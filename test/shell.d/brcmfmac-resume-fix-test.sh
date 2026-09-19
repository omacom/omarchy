#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/fix-brcmfmac-resume.sh"
helper="$ROOT/bin/omarchy-brcmfmac-resume-fix"
all="$ROOT/install/hardware/all.sh"
migration=$(grep -l "fix-brcmfmac-resume.sh" "$ROOT"/migrations/*.sh | head -1)

grep -q 'apple/fix-brcmfmac-resume.sh' "$all" ||
  fail "the brcmfmac resume fix runs during hardware setup"
pass "the brcmfmac resume fix runs during hardware setup"

grep -Fq 'After=suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target' "$leaf" ||
  fail "the resume unit is ordered after every sleep target"
grep -Fq 'WantedBy=suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target' "$leaf" ||
  fail "the resume unit is wanted by every sleep target"
grep -Fq 'ExecStart=/usr/bin/omarchy-brcmfmac-resume-fix' "$leaf" ||
  fail "the resume unit runs the reload helper"
pass "the resume unit is wired to every sleep target and the reload helper"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
unit="$test_tmp/etc/systemd/system/omarchy-brcmfmac-resume-fix.service"
mkdir -p "$stub_bin" "$test_tmp/dmi"

cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash

# Chatty like real lspci: keep writing well past the pipe buffer after the
# match, so a grep -q consumer would kill this stub with SIGPIPE and pipefail
# would read that as "no such hardware" (#6608).
if (( ${T2_HARDWARE:-0} == 1 )); then
  echo '01:00.0 Bridge [0680]: Apple Inc. T2 Security Chip [106b:1801]'
fi
if [[ -n ${WIFI_ID:-} ]]; then
  # Domain-qualified, matching real `lspci -Dnn` output -- the helper parses
  # this address and must match the sysfs fixture's PCI address below.
  echo "0000:04:00.0 Network controller [0280]: Broadcom Inc. Wireless [14e4:$WIFI_ID]"
fi
for _ in {1..4096}; do
  echo '02:00.0 Host bridge [0600]: Filler Device [ffff:0000]'
done
SH

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
"$@"
SH

cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash

printf 'systemctl' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
SH

chmod +x "$stub_bin"/*

run_leaf() {
  local vendor="$1" wifi_id="${2:-}" t2="${3:-0}"
  rm -rf "$test_tmp/etc"
  mkdir -p "$test_tmp/etc/systemd/system"
  printf '%s' "$vendor" >"$test_tmp/dmi/sys_vendor"
  : >"$calls"

  local script="$test_tmp/leaf.sh"
  sed -e "s|/sys/class/dmi/id/sys_vendor|$test_tmp/dmi/sys_vendor|g" \
      -e "s|/etc/systemd/system|$test_tmp/etc/systemd/system|g" \
      "$leaf" >"$script"

  WIFI_ID="$wifi_id" T2_HARDWARE="$t2" TEST_LOG="$calls" PATH="$stub_bin:$PATH" \
    bash -eE -o pipefail -c 'source "$1"' bash "$script" </dev/null
}

# The same population fix-brcmfmac-supplicant.sh matches: T2 Macs, and every
# Broadcom part brcmfmac drives over PCIe on a Mac without a T2.
run_leaf "Apple Inc." 4488 1 >/dev/null
[[ -f $unit ]] || fail "a T2 Mac gets the resume unit installed"
grep -Fq $'systemctl\tenable\tomarchy-brcmfmac-resume-fix.service' "$calls" ||
  fail "a T2 Mac gets the resume unit enabled"
pass "a T2 Mac gets the resume unit"

for wifi_id in 43ba 43bb 43bc 43a3 43dc 4464 4425 4433; do
  run_leaf "Apple Inc." "$wifi_id" 0 >/dev/null
  [[ -f $unit ]] || fail "a Mac without a T2 gets the resume unit" "14e4:$wifi_id"
done
pass "every affected Broadcom part on a Mac without a T2 gets the resume unit"

# BCM4360 Macs run the out-of-tree wl driver, unaffected by this msgbuf-only bug.
run_leaf "Apple Inc." 43a0 0 >/dev/null
[[ ! -f $unit ]] || fail "a Mac whose Wi-Fi brcmfmac does not drive is left alone"
pass "a Mac whose Wi-Fi brcmfmac does not drive is left alone"

run_leaf "LENOVO" 43ba 0 >/dev/null
[[ ! -f $unit ]] || fail "non-Apple hardware is left alone"
pass "non-Apple hardware is left alone"

# Installs that predate the fix never ran the leaf, so the migration has to
# reach them.
run_migration() {
  local vendor="$1" wifi_id="${2:-}" t2="${3:-0}"
  rm -rf "$test_tmp/etc"
  mkdir -p "$test_tmp/etc/systemd/system"
  printf '%s' "$vendor" >"$test_tmp/dmi/sys_vendor"
  : >"$calls"

  local script="$test_tmp/migration.sh"
  sed "s|\$OMARCHY_PATH/install/hardware/apple/fix-brcmfmac-resume.sh|$test_tmp/leaf.sh|" \
    "$migration" >"$script"
  sed -e "s|/sys/class/dmi/id/sys_vendor|$test_tmp/dmi/sys_vendor|g" \
      -e "s|/etc/systemd/system|$test_tmp/etc/systemd/system|g" \
      "$leaf" >"$test_tmp/leaf.sh"

  WIFI_ID="$wifi_id" T2_HARDWARE="$t2" TEST_LOG="$calls" PATH="$stub_bin:$PATH" \
    bash -euo pipefail "$script" >/dev/null
}

run_migration "Apple Inc." 43ba 0
[[ -f $unit ]] || fail "the migration installs the resume unit on an existing Mac" "$(ls -R "$test_tmp/etc" 2>&1)"
pass "the migration installs the resume unit on an existing Mac"

run_migration "Apple Inc." 43a0 0
[[ ! -f $unit ]] || fail "the migration skips a Mac brcmfmac does not drive" "$(cat "$unit" 2>&1)"
[[ ! -s $calls ]] || fail "the migration escalates nothing on unaffected Macs" "$(cat "$calls")"
pass "the migration skips hardware brcmfmac does not drive"

# --- the reload helper itself ----------------------------------------------
#
# Exercises the exact defect this fix was written for: modprobe -r reliably
# fails post-resume ("Module brcmfmac is in use"), and the earlier version of
# this fix fell back to a PCI unbind followed by `modprobe brcmfmac` to bring
# it back -- a no-op, since the module was never actually removed from the
# kernel, so modprobe never re-probes a device that was manually unbound via
# sysfs. Confirmed on hardware 2026-09-11: the device stayed unbound and Wi-Fi
# never came back. The fix drives the PCI unbind/bind cycle directly, with no
# modprobe involved. A real unbind/bind is synchronous in the kernel, so the
# sysfs fixture below simulates that: a background reader on each pseudo-file
# updates the driver symlink the same write() call would.
sysfs="$test_tmp/sysfs"
addr="0000:04:00.0"
sysfs_reader_pids=()

stop_sysfs_readers() {
  local pid
  for pid in "${sysfs_reader_pids[@]:-}"; do
    [[ -n $pid ]] && kill "$pid" 2>/dev/null
  done
  sysfs_reader_pids=()
}

# A real unbind/bind is synchronous in the kernel -- the write() to bind
# doesn't return until the probe completes. Simulate that here: a background
# reader on each pseudo-file updates the driver symlink the same write()
# would, so the helper's post-bind poll sees a real transition instead of a
# static fixture.
setup_sysfs() {
  stop_sysfs_readers
  local bound_driver="$1"
  rm -rf "$sysfs"
  mkdir -p "$sysfs/devices/$addr" "$sysfs/drivers/brcmfmac"

  if [[ -n $bound_driver ]]; then
    mkdir -p "$sysfs/drivers/$bound_driver"
    ln -sfn "../../drivers/$bound_driver" "$sysfs/devices/$addr/driver"
  fi

  mkfifo "$sysfs/drivers/brcmfmac/unbind" "$sysfs/drivers/brcmfmac/bind"

  (
    while read -r _ <"$sysfs/drivers/brcmfmac/unbind"; do
      rm -f "$sysfs/devices/$addr/driver"
    done
  ) 2>/dev/null &
  sysfs_reader_pids+=("$!")

  (
    while read -r _ <"$sysfs/drivers/brcmfmac/bind"; do
      ln -sfn "../../drivers/brcmfmac" "$sysfs/devices/$addr/driver"
    done
  ) 2>/dev/null &
  sysfs_reader_pids+=("$!")
}
trap 'stop_sysfs_readers; rm -rf "$test_tmp"' EXIT

run_helper() {
  local wifi_id="${1:-43ba}"
  WIFI_ID="$wifi_id" OMARCHY_LSPCI="$stub_bin/lspci" OMARCHY_PCI_SYSFS="$sysfs" \
    bash "$helper"
}

setup_sysfs ""
run_helper "" >/dev/null || fail "no matching Wi-Fi device is a clean no-op (nonzero exit)"
[[ ! -e $sysfs/devices/$addr/driver ]] || fail "no matching device is left untouched"
pass "no matching Wi-Fi device is a clean no-op"
stop_sysfs_readers

setup_sysfs "other_driver"
run_helper >/dev/null
[[ $(basename "$(readlink "$sysfs/devices/$addr/driver")") == other_driver ]] ||
  fail "a device bound to another driver is left alone"
pass "a device driven by something other than brcmfmac is left alone"
stop_sysfs_readers

setup_sysfs "brcmfmac"
run_helper
[[ $(basename "$(readlink "$sysfs/devices/$addr/driver")") == brcmfmac ]] ||
  fail "the device is bound to brcmfmac again after the reload"
pass "the reload cycles the device through unbind and bind and ends up bound to brcmfmac"
stop_sysfs_readers
