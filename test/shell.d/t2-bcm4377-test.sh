#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/fix-t2-bcm4377.sh"
fix_t2="$ROOT/install/hardware/apple/fix-t2.sh"
all="$ROOT/install/hardware/all.sh"
migration="$ROOT/migrations/1789234234.sh"
rebind="$ROOT/bin/omarchy-t2-bcm4377-rebind"
suspend="$ROOT/bin/omarchy-t2-bcm4377-suspend"
rebind_unit="$ROOT/default/systemd/system/omarchy-t2-bcm4377-rebind.service"
suspend_unit="$ROOT/default/systemd/system/omarchy-t2-bcm4377-suspend.service"
reload_unit="$ROOT/default/systemd/system/omarchy-t2-bcm4377-reload.service"
recover_unit="$ROOT/default/systemd/system/omarchy-t2-bcm4377-recover.service"
known_hooks="$ROOT/install/hardware/apple/bcm4377-known-sleep-hooks"

grep -q 'apple/fix-t2-bcm4377.sh' "$all" ||
  fail "the BCM4377 workaround runs during hardware setup"
! grep -q 'omarchy-t2-bcm4377' "$fix_t2" ||
  fail "only the BCM4377 leaf owns the combo-chip units"
grep -q 'Class: 0x00000000' "$rebind" ||
  fail "the rebind treats an unset adapter class as hung"
grep -q 'RequiredBy=sleep.target' "$suspend_unit" ||
  fail "a failed unload fails sleep, instead of continuing without ExecStop"
grep -q 'Before=sleep.target' "$suspend_unit" ||
  fail "suspend unload runs before sleep.target"
grep -q 'OnFailure=omarchy-t2-bcm4377-recover.service' "$suspend_unit" ||
  fail "a killed pre has a unit that puts the radios back"
grep -q 'TimeoutStartSec=70' "$suspend_unit" ||
  fail "pre is allowed the rebind-stop budget plus a slow hci teardown"
grep -q 'omarchy-t2-bcm4377-rebind.service' "$suspend" ||
  fail "resume reloads Bluetooth through the rebind unit"
grep -q 'omarchy-t2-bcm4377-reload.service' "$suspend" ||
  fail "resume is a packaged reload unit"
! grep -q 'systemd-run' "$suspend" ||
  fail "resume does not use a transient unit"
! grep -q 'sleep 15' "$suspend" "$reload_unit" ||
  fail "reload does not wait a fixed 15 seconds"
! grep -q 'ExecStartPre=/bin/sleep' "$reload_unit" ||
  fail "the reload unit has no sleep before it loads brcmfmac"
grep -q 'wait_for_pci_wifi_d0' "$suspend" ||
  fail "reload waits until the Wi-Fi function is in D0"
grep -q 'OnFailure=omarchy-t2-bcm4377-recover.service' "$reload_unit" ||
  fail "a failed reload is handed to recover"
grep -q 'Restart=on-failure' "$reload_unit" ||
  fail "a failed reload is retried"
! grep -q 'rfkill unblock wlan' "$suspend" ||
  fail "resume does not unblock every Wi-Fi adapter"
pass "BCM4377 setup is a dedicated leaf with a class-aware rebind"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
helper_bin="$test_tmp/helper-bin"
calls="$test_tmp/calls.log"
show_count="$test_tmp/show-count"
systemd_dir="$test_tmp/systemd"
sleep_hook="$test_tmp/system-sleep/t2-wifi-suspend"
sys="$test_tmp/sys"
run="$test_tmp/run"
rfkill_dir="$test_tmp/rfkill"
mkdir -p "$stub_bin" "$helper_bin" "$test_tmp/system-sleep"

cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash

# Chatty like real lspci: keep writing well past the pipe buffer after the
# match, so a grep -q consumer would kill this stub with SIGPIPE and pipefail
# would read that as "no such hardware" (#6608).
if (( ${T2_HARDWARE:-0} == 1 )); then
  echo '01:00.0 Bridge [0680]: Apple Inc. T2 Security Chip [106b:1801]'
fi
if [[ -n ${WIFI_ID:-} ]]; then
  echo "03:00.0 Network controller [0280]: Broadcom Inc. Wireless [14e4:$WIFI_ID]"
fi
if [[ -n ${BT_ID:-} ]]; then
  echo "03:00.1 Network controller [0280]: Broadcom Inc. Bluetooth [14e4:$BT_ID]"
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
case "$1" in
  is-system-running)
    printf '%s\n' "${SYSTEM_STATE:-offline}"
    if [[ ${SYSTEM_STATE:-offline} == running ]]; then
      exit 0
    fi
    exit 1
    ;;
esac
exit 0
SH

cat >"$helper_bin/systemctl" <<'SH'
#!/bin/bash

printf 'systemctl' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
cmd=$1
shift || true
case $cmd in
  is-active)
    unit=
    for arg in "$@"; do
      case $arg in
        --*) ;;
        *) unit=$arg ;;
      esac
    done
    if [[ $unit == omarchy-t2-bcm4377-reload.service && ${RELOAD_ACTIVE:-0} == 1 ]]; then
      exit 0
    fi
    exit 3
    ;;
esac
exit 0
SH

cat >"$helper_bin/modprobe" <<'SH'
#!/bin/bash

printf 'modprobe' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
sys=${OMARCHY_T2_BCM4377_SYS:?}
if [[ ${1:-} == -r ]]; then
  shift
  for module in "$@"; do
    if [[ $module == hci_bcm4377 && ${FAIL_HCI:-0} == 1 ]]; then
      exit 1
    fi
    if [[ $module == brcmfmac && ${FAIL_WIFI:-0} == 1 ]]; then
      exit 1
    fi
    rm -rf "$sys/module/$module"
  done
  exit 0
fi
for module in "$@"; do
  [[ $module == -* ]] && continue
  if [[ $module == brcmfmac && ${FAIL_LOAD:-0} == 1 ]]; then
    exit 1
  fi
  if [[ $module == brcmfmac && -f $sys/bus/pci/devices/0000:73:00.0/power_state ]]; then
    printf 'power_state=%s\n' "$(<"$sys/bus/pci/devices/0000:73:00.0/power_state")" >>"$TEST_LOG"
  fi
  mkdir -p "$sys/module/$module"
done
exit 0
SH

cat >"$helper_bin/busctl" <<'SH'
#!/bin/bash

if [[ ${BCM_BUSCTL_SLEEP:-0} != 0 ]]; then
  sleep "$BCM_BUSCTL_SLEEP"
fi

printf 'busctl' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
if [[ $* == *set-property* ]]; then
  exit 0
fi
# hci0 is the dongle: powered, with a real class. Asking it instead of the
# BCM4377's own hci node would look like a healthy adapter and skip the rebind.
if [[ $* == *hci0* ]]; then
  if [[ $* == *Powered* ]]; then
    printf 'b true\n'
  elif [[ $* == *Class* ]]; then
    printf 'u 7078156\n'
  fi
  exit 0
fi
if [[ $* == *hci1* && $* == *Powered* ]]; then
  printf '%s\n' "${BCM_POWERED:-b true}"
  exit 0
fi
if [[ $* == *hci1* && $* == *Class* ]]; then
  echo x >>"${SHOW_COUNT:?}"
  n=$(wc -l <"$SHOW_COUNT")
  if [[ ${BCM_CLASS_MODE:-static} == flip && $n -ge ${BCM_CLASS_FLIP_AT:-2} ]]; then
    printf 'u 7078156\n'
  else
    printf '%s\n' "${BCM_CLASS:-u 7078156}"
  fi
  exit 0
fi
exit 1
SH

cat >"$helper_bin/nmcli" <<'SH'
#!/bin/bash

printf '%s' "$0" >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
if [[ ${1:-} == radio && ${2:-} == wifi && ${3:-} != on ]]; then
  printf '%s\n' "${NM_WIFI_RADIO:-enabled}"
fi
if [[ ${1:-} == -g && ${2:-} == GENERAL.STATE ]]; then
  if [[ ${NM_DEVICE_STATE:-100 (connected)} != missing ]]; then
    printf '%s\n' "${NM_DEVICE_STATE:-100 (connected)}"
  fi
fi
exit 0
SH

for cmd in ip rfkill; do
  cat >"$helper_bin/$cmd" <<'SH'
#!/bin/bash

printf '%s' "$0" >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
exit 0
SH
done

chmod +x "$stub_bin"/* "$helper_bin"/*

run_leaf() {
  local wifi_id="${1:-}" bt_id="${2:-}" t2="${3:-0}" system_state="${4:-offline}" hook_src="${5:-}"
  rm -rf "$systemd_dir" "$(dirname "$sleep_hook")"
  mkdir -p "$systemd_dir" "$(dirname "$sleep_hook")"
  if [[ -n $hook_src ]]; then
    cp "$hook_src" "$sleep_hook"
  else
    printf 'legacy-hook\n' >"$sleep_hook"
  fi
  chmod 755 "$sleep_hook"
  : >"$calls"

  WIFI_ID="$wifi_id" BT_ID="$bt_id" T2_HARDWARE="$t2" PATH="$stub_bin:$PATH" \
    TEST_LOG="$calls" SYSTEM_STATE="$system_state" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_T2_BCM4377_SYSTEMD_DIR="$systemd_dir" \
    OMARCHY_T2_BCM4377_SLEEP_HOOK="$sleep_hook" \
    bash -eE -o pipefail -c 'source "$1"' bash "$leaf" </dev/null
}

run_leaf 4488 5fa0 1 >/dev/null
[[ -f $systemd_dir/omarchy-t2-bcm4377-rebind.service ]] ||
  fail "a BCM4377 machine gets the rebind unit"
[[ -f $systemd_dir/omarchy-t2-bcm4377-suspend.service ]] ||
  fail "a BCM4377 machine gets the suspend unit"
[[ -f $systemd_dir/omarchy-t2-bcm4377-reload.service ]] ||
  fail "a BCM4377 machine gets the reload unit"
[[ -f $systemd_dir/omarchy-t2-bcm4377-recover.service ]] ||
  fail "a BCM4377 machine gets the recover unit"
cmp -s "$rebind_unit" "$systemd_dir/omarchy-t2-bcm4377-rebind.service" ||
  fail "the installed rebind unit matches the packaged file"
cmp -s "$suspend_unit" "$systemd_dir/omarchy-t2-bcm4377-suspend.service" ||
  fail "the installed suspend unit matches the packaged file"
cmp -s "$reload_unit" "$systemd_dir/omarchy-t2-bcm4377-reload.service" ||
  fail "the installed reload unit matches the packaged file"
cmp -s "$recover_unit" "$systemd_dir/omarchy-t2-bcm4377-recover.service" ||
  fail "the installed recover unit matches the packaged file"
grep -Fq $'systemctl\tenable\tomarchy-t2-bcm4377-rebind.service' "$calls" ||
  fail "the rebind unit is enabled" "$(cat "$calls")"
grep -Fq $'systemctl\tenable\tomarchy-t2-bcm4377-suspend.service' "$calls" ||
  fail "the suspend unit is enabled" "$(cat "$calls")"
! grep -Fq $'systemctl\tenable\tomarchy-t2-bcm4377-reload.service' "$calls" ||
  fail "the reload unit is not enabled at boot" "$(cat "$calls")"
grep -Fq $'systemctl\tdisable\t--now\tt2-brcmfmac-suspend.service' "$calls" ||
  fail "leftover community suspend units are disabled" "$(cat "$calls")"
grep -Fq $'systemctl\tdisable\t--now\tbt-bcm4377-rebind.service' "$calls" ||
  fail "leftover community rebind units are disabled" "$(cat "$calls")"
grep -Fq $'systemctl\tdisable\t--now\tt2-wifi-reload.service' "$calls" ||
  fail "the community reload unit is disabled" "$(cat "$calls")"
[[ ! -e $sleep_hook ]] || fail "a custom sleep hook is no longer in the hook path"
[[ -f ${sleep_hook}.disabled ]] || fail "a custom sleep hook is kept"
[[ ! -x ${sleep_hook}.disabled ]] || fail "a custom sleep hook is not left executable"
cmp -s <(printf 'legacy-hook\n') "${sleep_hook}.disabled" ||
  fail "the quarantined hook keeps its original body"
! grep -Fq $'systemctl\tstart\tomarchy-t2-bcm4377-rebind.service' "$calls" ||
  fail "ISO/chroot setup does not start the rebind oneshot" "$(cat "$calls")"
pass "a BCM4377 machine gets the units and a custom sleep hook is kept inactive"

run_leaf 4488 5fa0 1 degraded >/dev/null
grep -Fq $'systemctl\tstart\tomarchy-t2-bcm4377-rebind.service' "$calls" ||
  fail "a degraded boot still starts the rebind" "$(cat "$calls")"
pass "a degraded boot still starts the rebind"

for known in "$known_hooks"/*; do
  run_leaf 4488 5fa0 1 offline "$known" >/dev/null
  [[ ! -e $sleep_hook ]] || fail "a published sleep hook is removed ($known)"
  [[ ! -e ${sleep_hook}.disabled ]] || fail "a published sleep hook is not quarantined ($known)"
done
pass "a published t2-wifi-suspend hook is removed by content"

run_leaf 4464 "" 1 >/dev/null
[[ ! -e $systemd_dir/omarchy-t2-bcm4377-rebind.service ]] ||
  fail "a T2 Mac without BCM4377 is left alone"
[[ ! -s $calls ]] || fail "a T2 Mac without BCM4377 escalates nothing" "$(cat "$calls")"
[[ -x $sleep_hook ]] || fail "a sleep hook on a machine without BCM4377 is left in place"
[[ ! -e ${sleep_hook}.disabled ]] ||
  fail "a sleep hook on a machine without BCM4377 is not renamed"
pass "a T2 Mac without BCM4377 is left alone"

run_leaf "" "" 0 >/dev/null
[[ ! -e $systemd_dir/omarchy-t2-bcm4377-suspend.service ]] ||
  fail "unrelated hardware is left alone"
pass "unrelated hardware is left alone"

run_migration() {
  local wifi_id="${1:-}" bt_id="${2:-}" t2="${3:-0}"
  rm -rf "$systemd_dir" "$(dirname "$sleep_hook")"
  mkdir -p "$systemd_dir" "$(dirname "$sleep_hook")"
  printf 'legacy-hook\n' >"$sleep_hook"
  chmod 755 "$sleep_hook"
  : >"$calls"

  WIFI_ID="$wifi_id" BT_ID="$bt_id" T2_HARDWARE="$t2" PATH="$stub_bin:$PATH" \
    TEST_LOG="$calls" SYSTEM_STATE=offline \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_T2_BCM4377_SYSTEMD_DIR="$systemd_dir" \
    OMARCHY_T2_BCM4377_SLEEP_HOOK="$sleep_hook" \
    bash -euo pipefail "$migration" >/dev/null
}

run_migration 4488 5fa0 1
[[ -f $systemd_dir/omarchy-t2-bcm4377-rebind.service ]] ||
  fail "the migration installs the rebind unit on existing BCM4377 installs"
grep -Fq $'sudo\tenv' "$calls" ||
  fail "the migration escalates to install machine-wide units" "$(cat "$calls")"
grep -Fq $'systemctl\tenable\tomarchy-t2-bcm4377-suspend.service' "$calls" ||
  fail "the migration enables the suspend unit" "$(cat "$calls")"
[[ ! -e $sleep_hook ]] || fail "the migration takes a custom sleep hook out of the hook path"
[[ -f ${sleep_hook}.disabled ]] || fail "the migration keeps a custom sleep hook"
[[ ! -x ${sleep_hook}.disabled ]] || fail "the migration does not leave a custom sleep hook executable"
pass "the migration repairs an existing BCM4377 install"

run_migration 4464 "" 1
[[ ! -e $systemd_dir/omarchy-t2-bcm4377-rebind.service ]] ||
  fail "the migration skips T2 Macs without BCM4377"
[[ ! -s $calls ]] || fail "the migration escalates nothing on other T2 chips" "$(cat "$calls")"
[[ -x $sleep_hook ]] || fail "the migration leaves a sleep hook alone on other T2 chips"
pass "the migration skips T2 Macs without BCM4377"

setup_sysfs() {
  rm -rf "$sys" "$run" "$rfkill_dir"
  mkdir -p \
    "$sys/bus/pci/devices/0000:73:00.0/ieee80211/phy0/rfkill1" \
    "$sys/bus/pci/devices/0000:73:00.1/bluetooth/hci1/rfkill0" \
    "$sys/bus/pci/drivers/hci_bcm4377" \
    "$sys/bus/pci/drivers/brcmfmac" \
    "$sys/module/brcmfmac" \
    "$sys/module/brcmfmac_wcc" \
    "$sys/module/hci_bcm4377" \
    "$sys/class/net/wlp115s0f0/device" \
    "$run" \
    "$rfkill_dir"
  ln -sfn "$sys/bus/pci/drivers/brcmfmac" "$sys/class/net/wlp115s0f0/device/driver"
  printf '0x14e4\n' >"$sys/bus/pci/devices/0000:73:00.0/vendor"
  printf '0x4488\n' >"$sys/bus/pci/devices/0000:73:00.0/device"
  printf 'D0\n' >"$sys/bus/pci/devices/0000:73:00.0/power_state"
  printf '0\n' >"$sys/bus/pci/devices/0000:73:00.0/ieee80211/phy0/rfkill1/soft"
  printf '0\n' >"$sys/bus/pci/devices/0000:73:00.0/ieee80211/phy0/rfkill1/hard"
  printf '0\n' >"$rfkill_dir/pci-0000:73:00.0:wlan"
  printf '1\n' >"$rfkill_dir/pci-0000:01:00.0:wlan"
  printf '0x1003\n' >"$sys/class/net/wlp115s0f0/flags"
  printf '0x14e4\n' >"$sys/bus/pci/devices/0000:73:00.1/vendor"
  printf '0x5fa0\n' >"$sys/bus/pci/devices/0000:73:00.1/device"
  printf '0\n' >"$sys/bus/pci/devices/0000:73:00.1/bluetooth/hci1/rfkill0/soft"
  printf '0\n' >"$sys/bus/pci/devices/0000:73:00.1/bluetooth/hci1/rfkill0/hard"
  printf '0\n' >"$rfkill_dir/pci-0000:73:00.1:bluetooth"
  : >"$sys/bus/pci/drivers/hci_bcm4377/unbind"
  : >"$sys/bus/pci/drivers/hci_bcm4377/bind"
  ln -sfn driver "$sys/bus/pci/devices/0000:73:00.1/driver"
}

run_helper() {
  local script=$1
  shift
  (
    export PATH="$helper_bin:$PATH"
    export TEST_LOG="$calls"
    export SHOW_COUNT="$show_count"
    export OMARCHY_T2_BCM4377_SYS="$sys"
    export OMARCHY_T2_BCM4377_RUN="$run"
    export OMARCHY_T2_BCM4377_RFKILL_STATE="$rfkill_dir"
    export OMARCHY_T2_BCM4377_WIFI_RETRY_SLEEP=0
    export OMARCHY_T2_BCM4377_D0_SLEEP="${D0_SLEEP:-0}"
    export OMARCHY_T2_BCM4377_D0_TRIES="${D0_TRIES:-5}"
    export OMARCHY_T2_BCM4377_IFACE_TRIES=1
    export OMARCHY_T2_BCM4377_UNBIND_SLEEP=0
    export OMARCHY_T2_BCM4377_BIND_SLEEP=0
    export OMARCHY_T2_BCM4377_BLUEZ_SLEEP=0
    export OMARCHY_T2_BCM4377_SETTLE_SLEEP="${SETTLE_SLEEP:-0}"
    export OMARCHY_T2_BCM4377_SETTLE_TRIES="${SETTLE_TRIES:-1}"
    if [[ -n ${SETTLE_BUDGET:-} ]]; then
      export OMARCHY_T2_BCM4377_SETTLE_BUDGET="$SETTLE_BUDGET"
    fi
    export OMARCHY_T2_BCM4377_SETTLE_CALL_TIMEOUT="${SETTLE_CALL_TIMEOUT:-1}"
    export OMARCHY_T2_BCM4377_SETTLE_STALL_LIMIT="${SETTLE_STALL_LIMIT:-2}"
    export OMARCHY_T2_BCM4377_BUS_TIMEOUT="${BUS_TIMEOUT:-5}"
    export BCM_BUSCTL_SLEEP="${BCM_BUSCTL_SLEEP:-0}"
    export MAX_TRIES="${MAX_TRIES:-5}"
    export FAIL_HCI="${FAIL_HCI:-0}"
    export FAIL_WIFI="${FAIL_WIFI:-0}"
    export FAIL_LOAD="${FAIL_LOAD:-0}"
    export NM_WIFI_RADIO="${NM_WIFI_RADIO:-enabled}"
    export NM_DEVICE_STATE="${NM_DEVICE_STATE:-100 (connected)}"
    export RELOAD_ACTIVE="${RELOAD_ACTIVE:-0}"
    export BCM_POWERED="${BCM_POWERED:-b true}"
    export BCM_CLASS="${BCM_CLASS:-u 7078156}"
    export BCM_CLASS_MODE="${BCM_CLASS_MODE:-static}"
    export BCM_CLASS_FLIP_AT="${BCM_CLASS_FLIP_AT:-2}"
    : >"$calls"
    : >"$show_count"
    bash "$script" "$@" >/dev/null 2>&1
  )
}

assert_status() {
  local expected=$1
  local actual=$2
  local description=$3
  [[ $actual == "$expected" ]] || fail "$description" "exit $actual, log:$(cat "$calls")"
}

log_before() {
  local first=$1
  local second=$2
  local first_line second_line
  first_line=$(grep -n -F "$first" "$calls" | head -1 | cut -d: -f1)
  second_line=$(grep -n -F "$second" "$calls" | head -1 | cut -d: -f1)
  [[ -n $first_line && -n $second_line && $first_line -lt $second_line ]]
}

# No chip in the fake sysfs. This machine does have a BCM4377; the helper
# must honor the override or the stub log would show a real unload.
rm -rf "$sys"
mkdir -p "$sys/bus/pci/devices"
set +e
run_helper "$suspend" pre
status=$?
set -e
assert_status 0 "$status" "pre exits cleanly when no BCM4377 is present"
[[ ! -s $calls ]] || fail "pre does not touch modules when no BCM4377 is present" "$(cat "$calls")"
pass "pre exits cleanly when no BCM4377 is present"

setup_sysfs
set +e
run_helper "$suspend" pre
status=$?
set -e
assert_status 0 "$status" "pre unloads both modules"
log_before $'systemctl\tstop\t' $'modprobe\t-r\thci_bcm4377' ||
  fail "pre stops in-flight units before unloading Bluetooth" "$(cat "$calls")"
stop_line=$(grep -F $'systemctl\tstop\t' "$calls" | head -1)
[[ $stop_line == *omarchy-t2-bcm4377-reload.service* && $stop_line == *omarchy-t2-bcm4377-rebind.service* ]] ||
  fail "pre stops the reload and the rebind before unloading" "$stop_line"
[[ ! -d $sys/module/hci_bcm4377 ]] || fail "pre unloads hci_bcm4377"
[[ ! -d $sys/module/brcmfmac ]] || fail "pre unloads brcmfmac"
[[ -f $run/omarchy-t2-bcm4377-unloaded ]] || fail "a successful unload marks itself for resume"
[[ ! -f $run/omarchy-t2-bcm4377-wifi-released ]] ||
  fail "a successful unload clears the dropped-link stamp"
[[ ! -f $run/omarchy-t2-bcm4377-wlan-off ]] ||
  fail "Wi-Fi that was on is not remembered as off"
pass "pre stops in-flight resume work, then unloads both modules"

setup_sysfs
set +e
FAIL_HCI=1 run_helper "$suspend" pre
status=$?
set -e
assert_status 1 "$status" "pre fails when hci_bcm4377 stays bound"
grep -Fq $'modprobe\t-r\tbrcmfmac' "$calls" &&
  fail "a busy hci_bcm4377 aborts before brcmfmac is unloaded" "$(cat "$calls")"
[[ -d $sys/module/hci_bcm4377 ]] || fail "a failed hci unload leaves the module loaded"
[[ -d $sys/module/brcmfmac ]] || fail "a failed hci unload leaves Wi-Fi loaded"
grep -Fq $'systemctl\tstart\tbluetooth.service' "$calls" ||
  fail "a failed hci unload restarts BlueZ" "$(cat "$calls")"
grep -Fq $'systemctl\tstart\t--no-block\tomarchy-t2-bcm4377-rebind.service' "$calls" &&
  fail "a module that never unloaded is not treated as a fresh hung probe" "$(cat "$calls")"
[[ ! -f $run/omarchy-t2-bcm4377-unloaded ]] || fail "a failed hci unload does not mark itself successful"
pass "a busy hci_bcm4377 aborts suspend and restarts BlueZ"

setup_sysfs
set +e
FAIL_WIFI=1 run_helper "$suspend" pre
status=$?
set -e
assert_status 1 "$status" "pre fails when brcmfmac stays loaded"
[[ -d $sys/module/brcmfmac ]] || fail "a failed Wi-Fi unload leaves brcmfmac loaded"
[[ -d $sys/module/hci_bcm4377 ]] || fail "a failed Wi-Fi unload loads Bluetooth again"
log_before $'modprobe\t-r\thci_bcm4377' $'modprobe\thci_bcm4377' ||
  fail "Bluetooth is loaded again only after its unload" "$(cat "$calls")"
grep -Fq $'systemctl\tstart\tbluetooth.service' "$calls" ||
  fail "a failed Wi-Fi unload restarts BlueZ" "$(cat "$calls")"
grep -Fq $'systemctl\tstart\t--no-block\tomarchy-t2-bcm4377-rebind.service' "$calls" ||
  fail "a Bluetooth module loaded again on the failure path is rebound" "$(cat "$calls")"
[[ ! -f $run/omarchy-t2-bcm4377-unloaded ]] || fail "a failed Wi-Fi unload does not mark itself successful"
log_before $'nmcli\tdevice\tdisconnect\twlp115s0f0' $'nmcli\tdevice\tconnect\twlp115s0f0' ||
  fail "a failed Wi-Fi unload reconnects the interface it dropped" "$(cat "$calls")"
log_before $'ip\tlink\tset\twlp115s0f0\tdown' $'ip\tlink\tset\twlp115s0f0\tup' ||
  fail "a failed Wi-Fi unload brings the interface back up" "$(cat "$calls")"
[[ ! -f $run/omarchy-t2-bcm4377-wifi-released ]] ||
  fail "a failed Wi-Fi unload clears the dropped-link stamp"
[[ ! -e $run/omarchy-t2-bcm4377-wifi-connected ]] ||
  fail "a failed Wi-Fi unload clears the connected-interface snapshot"
pass "a failed brcmfmac unload restores Wi-Fi and Bluetooth and aborts suspend"

setup_sysfs
set +e
NM_DEVICE_STATE='30 (disconnected)' FAIL_WIFI=1 run_helper "$suspend" pre
status=$?
set -e
assert_status 1 "$status" "pre fails when brcmfmac stays loaded and Wi-Fi was disconnected"
grep -Fq $'nmcli\tdevice\tdisconnect\twlp115s0f0' "$calls" ||
  fail "a disconnected interface is still released before the unload" "$(cat "$calls")"
grep -Fq $'nmcli\tdevice\tconnect' "$calls" &&
  fail "a disconnected interface is not joined again after a failed unload" "$(cat "$calls")"
log_before $'ip\tlink\tset\twlp115s0f0\tdown' $'ip\tlink\tset\twlp115s0f0\tup' ||
  fail "a link that was up comes back up without being connected" "$(cat "$calls")"
pass "a failed unload does not reconnect a Wi-Fi interface that was disconnected"

setup_sysfs
printf '0x1002\n' >"$sys/class/net/wlp115s0f0/flags"
set +e
NM_DEVICE_STATE='30 (disconnected)' FAIL_WIFI=1 run_helper "$suspend" pre
status=$?
set -e
assert_status 1 "$status" "pre fails when a down, disconnected interface cannot unload"
grep -Fq $'ip\tlink\tset\twlp115s0f0\tup' "$calls" &&
  fail "an interface that was down stays down" "$(cat "$calls")"
grep -Fq $'nmcli\tdevice\tconnect' "$calls" &&
  fail "an interface that was down is not connected" "$(cat "$calls")"
pass "a failed unload leaves a down, disconnected interface down"

setup_sysfs
set +e
NM_DEVICE_STATE='70 (connecting (getting IP configuration))' FAIL_WIFI=1 run_helper "$suspend" pre
status=$?
set -e
assert_status 1 "$status" "pre fails while Wi-Fi is still obtaining an address"
log_before $'nmcli\tdevice\tdisconnect\twlp115s0f0' $'nmcli\tdevice\tconnect\twlp115s0f0' ||
  fail "a connection that was still coming up is joined again" "$(cat "$calls")"
pass "a failed unload resumes Wi-Fi that was still connecting"

setup_sysfs
set +e
NM_DEVICE_STATE=missing FAIL_WIFI=1 run_helper "$suspend" pre
status=$?
set -e
assert_status 1 "$status" "pre fails when the Wi-Fi state lookup returns nothing"
grep -Fq $'nmcli\tdevice\tdisconnect\twlp115s0f0' "$calls" ||
  fail "the interface is still released when its state could not be read" "$(cat "$calls")"
grep -Fq $'nmcli\tdevice\tconnect' "$calls" &&
  fail "a successful disconnect does not rejoin an interface whose state was not read" "$(cat "$calls")"
log_before $'ip\tlink\tset\twlp115s0f0\tdown' $'ip\tlink\tset\twlp115s0f0\tup' ||
  fail "a link that was up still comes back up" "$(cat "$calls")"
pass "a failed state lookup does not rejoin Wi-Fi after a successful disconnect"

setup_sysfs
printf 'x' >"$run/omarchy-t2-bcm4377-unloaded"
set +e
run_helper "$suspend" post
status=$?
set -e
assert_status 0 "$status" "post schedules the reload"
log_before $'systemctl\tstop\tomarchy-t2-bcm4377-rebind.service' \
  $'systemctl\trestart\t--no-block\tomarchy-t2-bcm4377-reload.service' ||
  fail "post stops a running rebind before restarting the reload" "$(cat "$calls")"
grep -Fq $'systemctl\trestart\t--no-block\tomarchy-t2-bcm4377-reload.service' "$calls" ||
  fail "post restarts the packaged reload unit" "$(cat "$calls")"
[[ ! -f $run/omarchy-t2-bcm4377-unloaded ]] || fail "post clears the unload stamp"
pass "post restarts the packaged reload and stops a running rebind"

setup_sysfs
rm -rf "$sys/module/brcmfmac" "$sys/module/hci_bcm4377"
printf 'D3\n' >"$sys/bus/pci/devices/0000:73:00.0/power_state"
(
  sleep 0.2
  printf 'D0\n' >"$sys/bus/pci/devices/0000:73:00.0/power_state"
) &
set +e
D0_SLEEP=0.05 D0_TRIES=40 run_helper "$suspend" resume
status=$?
set -e
wait
assert_status 0 "$status" "resume loads Wi-Fi after D0"
grep -Fq 'power_state=D0' "$calls" ||
  fail "brcmfmac is loaded only once the Wi-Fi function is in D0" "$(cat "$calls")"
grep -Fq 'power_state=D3' "$calls" &&
  fail "brcmfmac is not loaded while the Wi-Fi function is still in D3" "$(cat "$calls")"
grep -Fq $'systemctl\tstart\t--no-block\tomarchy-t2-bcm4377-rebind.service' "$calls" ||
  fail "resume starts the Bluetooth rebind" "$(cat "$calls")"
grep -Fq $'nmcli\tradio\twifi\ton' "$calls" ||
  fail "resume turns the Wi-Fi radio on when it was on before suspend" "$(cat "$calls")"
grep -Fq $'rfkill\tunblock' "$calls" &&
  fail "resume does not unblock every Wi-Fi adapter" "$(cat "$calls")"
[[ $(<"$rfkill_dir/pci-0000:73:00.0:wlan") == 0 ]] ||
  fail "resume keeps the BCM4377 wlan switch unblocked"
[[ $(<"$rfkill_dir/pci-0000:01:00.0:wlan") == 1 ]] ||
  fail "resume leaves another adapter's saved wlan switch alone"
[[ $(<"$sys/bus/pci/devices/0000:73:00.0/ieee80211/phy0/rfkill1/soft") == 0 ]] ||
  fail "resume leaves the BCM4377 killswitch unblocked"
pass "resume loads brcmfmac as soon as the Wi-Fi function is in D0"

setup_sysfs
printf '1\n' >"$rfkill_dir/pci-0000:73:00.0:wlan"
printf '1\n' >"$sys/bus/pci/devices/0000:73:00.0/ieee80211/phy0/rfkill1/soft"
set +e
run_helper "$suspend" pre
status=$?
set -e
assert_status 0 "$status" "pre still unloads when Wi-Fi was off"
[[ -f $run/omarchy-t2-bcm4377-wlan-off ]] ||
  fail "pre remembers a BCM4377 wlan soft block"
rm -rf "$sys/module/brcmfmac" "$sys/module/hci_bcm4377"
set +e
run_helper "$suspend" resume
status=$?
set -e
assert_status 0 "$status" "resume reloads a radio the user had turned off"
grep -Fq $'nmcli\tradio\twifi\ton' "$calls" &&
  fail "resume does not turn Wi-Fi on when the user had turned it off" "$(cat "$calls")"
[[ $(<"$rfkill_dir/pci-0000:73:00.0:wlan") == 1 ]] ||
  fail "resume keeps the saved BCM4377 wlan switch blocked"
[[ $(<"$rfkill_dir/pci-0000:01:00.0:wlan") == 1 ]] ||
  fail "a blocked BCM4377 resume still leaves another adapter alone"
[[ $(<"$sys/bus/pci/devices/0000:73:00.0/ieee80211/phy0/rfkill1/soft") == 1 ]] ||
  fail "resume leaves the BCM4377 killswitch blocked"
pass "resume keeps Wi-Fi off when it was off before suspend"

setup_sysfs
printf 'D3hot\n' >"$sys/bus/pci/devices/0000:73:00.0/power_state"
rm -rf "$sys/module/brcmfmac" "$sys/module/hci_bcm4377"
set +e
D0_TRIES=2 D0_SLEEP=0 run_helper "$suspend" resume
status=$?
set -e
assert_status 1 "$status" "resume fails while the Wi-Fi function is not in D0"
grep -Fq $'modprobe\tbrcmfmac' "$calls" &&
  fail "resume does not probe brcmfmac before D0" "$(cat "$calls")"
pass "resume does not probe brcmfmac while the Wi-Fi function is not in D0"

setup_sysfs
rm -rf "$sys/module/brcmfmac" "$sys/module/hci_bcm4377"
set +e
FAIL_LOAD=1 run_helper "$suspend" resume
status=$?
set -e
assert_status 1 "$status" "resume fails when brcmfmac will not load"
pass "a failed brcmfmac load fails the reload"

setup_sysfs
rm -rf "$sys/module/brcmfmac" "$sys/module/hci_bcm4377"
set +e
run_helper "$suspend" recover
status=$?
set -e
assert_status 0 "$status" "recover reloads missing modules"
grep -Fq 'power_state=D0' "$calls" ||
  fail "recover loads brcmfmac when the unload was killed" "$(cat "$calls")"
grep -Fq $'systemctl\tstart\t--no-block\tomarchy-t2-bcm4377-rebind.service' "$calls" ||
  fail "recover starts the Bluetooth rebind when the module is missing" "$(cat "$calls")"
pass "recover reloads radios when a killed unload left them down"

setup_sysfs
rm -rf "$sys/module/brcmfmac"
set +e
RELOAD_ACTIVE=1 run_helper "$suspend" recover
status=$?
set -e
assert_status 0 "$status" "recover leaves an active reload alone"
grep -Fq $'modprobe\tbrcmfmac' "$calls" &&
  fail "recover does not load brcmfmac while the reload unit is running" "$(cat "$calls")"
pass "recover leaves an active reload alone"

setup_sysfs
: >"$run/omarchy-t2-bcm4377-wifi-released"
mkdir -p "$run/omarchy-t2-bcm4377-wifi-connected"
: >"$run/omarchy-t2-bcm4377-wifi-connected/wlp115s0f0"
set +e
run_helper "$suspend" recover
status=$?
set -e
assert_status 0 "$status" "recover restores a link dropped before a killed unload"
grep -Fq $'nmcli\tdevice\tconnect\twlp115s0f0' "$calls" ||
  fail "recover reconnects Wi-Fi when the unload never finished" "$(cat "$calls")"
grep -Fq $'ip\tlink\tset\twlp115s0f0\tup' "$calls" ||
  fail "recover brings the Wi-Fi interface back up" "$(cat "$calls")"
grep -Fq $'systemctl\tstart\tbluetooth.service' "$calls" ||
  fail "recover restarts BlueZ when a killed pre stopped it first" "$(cat "$calls")"
grep -Fq $'modprobe\tbrcmfmac' "$calls" &&
  fail "recover does not reload a module that is still loaded" "$(cat "$calls")"
grep -Fq $'systemctl\tstart\t--no-block\tomarchy-t2-bcm4377-rebind.service' "$calls" &&
  fail "recover does not rebind a Bluetooth module that never unloaded" "$(cat "$calls")"
[[ ! -f $run/omarchy-t2-bcm4377-wifi-released ]] ||
  fail "recover clears the dropped-link stamp"
[[ ! -e $run/omarchy-t2-bcm4377-wifi-connected ]] ||
  fail "recover clears the connected-interface snapshot"
pass "recover restores radios when a killed pre left both modules loaded"

setup_sysfs
: >"$run/omarchy-t2-bcm4377-wifi-released"
set +e
run_helper "$suspend" recover
status=$?
set -e
assert_status 0 "$status" "recover leaves a disconnected interface disconnected"
grep -Fq $'nmcli\tdevice\tconnect' "$calls" &&
  fail "recover does not join an interface that was not connected" "$(cat "$calls")"
grep -Fq $'ip\tlink\tset\twlp115s0f0\tup' "$calls" &&
  fail "recover does not raise an interface whose link was not up" "$(cat "$calls")"
pass "recover does not reconnect Wi-Fi that was disconnected before the killed unload"

setup_sysfs
set +e
run_helper "$rebind"
status=$?
set -e
assert_status 0 "$status" "a usable BCM4377 adapter is left alone"
[[ ! -s $sys/bus/pci/drivers/hci_bcm4377/unbind ]] ||
  fail "a usable adapter is not unbound" "$(cat "$calls")"
grep -Fq '/org/bluez/hci0' "$calls" &&
  fail "the rebind does not ask BlueZ about hci0" "$(cat "$calls")"
grep -Fq '/org/bluez/hci1' "$calls" ||
  fail "the rebind asks BlueZ about the hci node under the BCM4377 function" "$(cat "$calls")"
pass "a usable BCM4377 adapter is left alone"

setup_sysfs
printf '1\n' >"$sys/bus/pci/devices/0000:73:00.1/bluetooth/hci1/rfkill0/soft"
set +e
run_helper "$rebind"
status=$?
set -e
assert_status 0 "$status" "a soft-blocked adapter exits cleanly"
[[ ! -s $sys/bus/pci/drivers/hci_bcm4377/unbind ]] ||
  fail "a soft-blocked adapter is not unbound" "$(cat "$calls")"
grep -Fq 'busctl' "$calls" &&
  fail "a soft-blocked adapter is not told to power on" "$(cat "$calls")"
pass "a soft-blocked BCM4377 adapter is left off"

setup_sysfs
printf '1\n' >"$rfkill_dir/pci-0000:73:00.1:bluetooth"
set +e
run_helper "$rebind"
status=$?
set -e
assert_status 0 "$status" "a persisted soft block exits cleanly"
[[ ! -s $sys/bus/pci/drivers/hci_bcm4377/unbind ]] ||
  fail "a persisted soft block does not unbind the adapter" "$(cat "$calls")"
grep -Fq 'busctl' "$calls" &&
  fail "a persisted soft block does not power the adapter on" "$(cat "$calls")"
pass "a persisted rfkill block for the BCM4377 function is left off"

setup_sysfs
set +e
BCM_CLASS_MODE=flip BCM_CLASS='u 0' SETTLE_TRIES=3 run_helper "$rebind"
status=$?
set -e
assert_status 0 "$status" "a controller BlueZ powers while settling is usable"
[[ ! -s $sys/bus/pci/drivers/hci_bcm4377/unbind ]] ||
  fail "a controller that comes up while settling is not unbound" "$(cat "$calls")"
power_sets=$(grep -c 'set-property' "$calls" || true)
[[ $power_sets -eq 1 ]] ||
  fail "settle powers the adapter once" "$(cat "$calls")"
pass "a controller that comes up while BlueZ settles is not rebound"

setup_sysfs
set +e
slow_started=$SECONDS
# The class flips on the read after one 6s pause, using the script's own
# settle budget. Sleep 0 would finish inside the old 5s deadline.
BCM_CLASS_MODE=flip BCM_CLASS='u 0' BCM_CLASS_FLIP_AT=3 SETTLE_TRIES=4 \
  SETTLE_SLEEP=6 run_helper "$rebind"
status=$?
slow_elapsed=$((SECONDS - slow_started))
set -e
assert_status 0 "$status" "a controller that answers after five seconds is usable"
[[ ! -s $sys/bus/pci/drivers/hci_bcm4377/unbind ]] ||
  fail "a controller that answers after five seconds is not unbound" "$(cat "$calls")"
((slow_elapsed >= 6)) ||
  fail "the slow init waits past the old five second deadline" "${slow_elapsed}s"
pass "a controller that becomes usable after five seconds is not rebound"

setup_sysfs
set +e
settle_started=$SECONDS
BCM_BUSCTL_SLEEP=30 SETTLE_BUDGET=15 SETTLE_TRIES=30 BUS_TIMEOUT=1 MAX_TRIES=1 \
  run_helper "$rebind"
status=$?
settle_elapsed=$((SECONDS - settle_started))
set -e
assert_status 1 "$status" "a stalled BlueZ settle still finishes the rebind attempt"
grep -qx '0000:73:00.1' "$sys/bus/pci/drivers/hci_bcm4377/unbind" ||
  fail "a stalled settle still rebinds the BCM4377 function" \
    "$(cat "$sys/bus/pci/drivers/hci_bcm4377/unbind")"
((settle_elapsed < 8)) ||
  fail "a stalled settle does not use the rebind timeout" "${settle_elapsed}s"
pass "a stalled BlueZ property read does not exhaust the rebind timeout"

setup_sysfs
set +e
BCM_CLASS_MODE=flip BCM_CLASS='u 0' BCM_CLASS_FLIP_AT=3 MAX_TRIES=1 run_helper "$rebind"
status=$?
set -e
assert_status 0 "$status" "an unset class is rebound until the BCM4377 controller answers"
grep -qx '0000:73:00.1' "$sys/bus/pci/drivers/hci_bcm4377/unbind" ||
  fail "the rebind unbinds the BCM4377 function, not another adapter" \
    "$(cat "$sys/bus/pci/drivers/hci_bcm4377/unbind")"
grep -Fq '/org/bluez/hci0' "$calls" &&
  fail "a hung BCM4377 is not judged via hci0" "$(cat "$calls")"
pass "an unset class on the BCM4377 controller is rebound"

setup_sysfs
set +e
BCM_CLASS='u 0' MAX_TRIES=1 run_helper "$rebind"
status=$?
set -e
assert_status 1 "$status" "a controller that stays at class 0 fails the rebind"
grep -qx '0000:73:00.1' "$sys/bus/pci/drivers/hci_bcm4377/unbind" ||
  fail "the failing rebind still targeted the BCM4377 function"
pass "a controller that stays at class 0 fails the rebind"
