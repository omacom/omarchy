#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

cmd="$ROOT/bin/omarchy-wifi-bcm4377-sleep"
leaf="$ROOT/install/hardware/apple/fix-bcm4377-sleep.sh"
unit="$ROOT/default/systemd/system/omarchy-wifi-bcm4377-sleep.service"

[[ -x $cmd ]] || fail "the sleep command is executable" "mode: $(stat -c '%A' "$cmd")"
pass "the sleep command is executable"

# A boot-time WantedBy would unload Wi-Fi at every boot. sleep.target is what
# suspend, hibernate, hybrid-sleep, and suspend-then-hibernate all pull in.
grep -q '^RequiredBy=sleep.target$' "$unit" ||
  fail "the unit is required by sleep.target so a failed unload aborts every sleep"
grep -q '^ExecStop=/usr/bin/omarchy-wifi-bcm4377-sleep post$' "$unit" ||
  fail "brcmfmac is reloaded from ExecStop, after the device is back in D0"
grep -q '^Before=sleep.target$' "$unit" ||
  fail "the unload is ordered before sleep.target"
! grep -q 'WantedBy=multi-user.target' "$unit" ||
  fail "the unit does not run at boot"
! grep -Eq 'SuspendState|mem_sleep' "$unit" "$cmd" "$leaf" ||
  fail "the workaround does not select a sleep mode"
! grep -Eq 'tnt|2600|hci_bcm4377' "$unit" "$cmd" "$leaf" ||
  fail "the workaround does not name a network or unload Bluetooth"
pass "the unit covers every sleep mode and leaves the sleep mode alone"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
call_log="$test_tmp/calls"
mkdir -p "$stub_bin"

cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash
printf '%s\n' "$FAKE_LSPCI"
SH

cat >"$stub_bin/nmcli" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$CALL_LOG"
if [[ $1 == "-g" && $2 == "GENERAL.STATE" ]]; then
  printf '%s\n' "${FAKE_WIFI_STATE:-30 (disconnected)}"
  exit 0
fi
exit 0
SH

cat >"$stub_bin/ip" <<'SH'
#!/bin/bash
printf '%s\n' "ip $*" >>"$CALL_LOG"
exit 0
SH

cat >"$stub_bin/modprobe" <<'SH'
#!/bin/bash
printf '%s\n' "modprobe $*" >>"$CALL_LOG"
if [[ $1 == "-r" ]]; then
  if [[ ${FAIL_RMMOD:-0} == 1 && $2 == "brcmfmac" ]]; then
    exit 1
  fi
  rm -rf "$MODULE_ROOT/$2"
  exit 0
fi
mkdir -p "$MODULE_ROOT/$1"
exit 0
SH

cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash
printf '%s\n' "systemctl $*" >>"$CALL_LOG"
exit 0
SH

cat >"$stub_bin/omarchy-hw-aarch64-apple" <<'SH'
#!/bin/bash
[[ ${FAKE_APPLE_SILICON:-0} == 1 ]]
SH

chmod +x "$stub_bin"/*

make_pci() {
  local bdf=$1 vendor=$2 device=$3 d3=$4
  local dir="$pci/$bdf"

  mkdir -p "$dir"
  printf '%s\n' "$vendor" >"$dir/vendor"
  printf '%s\n' "$device" >"$dir/device"
  printf '%s\n' "$d3" >"$dir/d3cold_allowed"
}

d3_of() {
  cat "$pci/$1/d3cold_allowed"
}

setup_machine() {
  rm -rf "$test_tmp/sys" "$test_tmp/state" "$call_log"
  mkdir -p "$test_tmp/sys" "$test_tmp/state"
  pci="$test_tmp/sys/pci"
  modules="$test_tmp/sys/module"
  net="$test_tmp/sys/net"
  : >"$call_log"
  make_pci 0000:74:00.0 0x106b 0x2005 1
  make_pci 0000:74:00.1 0x106b 0x1801 1
  make_pci 0000:74:00.2 0x106b 0x1802 1
  make_pci 0000:74:00.3 0x106b 0x1803 0
  make_pci 0000:74:00.4 0x106b 0x1234 1
  make_pci 0000:73:00.0 0x14e4 0x4488 1
  mkdir -p "$modules/brcmfmac" "$modules/brcmfmac_wcc" "$net/wlp0/device" \
    "$test_tmp/sys/drivers/brcmfmac"
  ln -s "$test_tmp/sys/drivers/brcmfmac" "$net/wlp0/device/driver"
  printf '%s\n' up >"$net/wlp0/operstate"
}

run_cmd() {
  PATH="$stub_bin:$PATH" \
    CALL_LOG="$call_log" \
    MODULE_ROOT="$modules" \
    FAKE_LSPCI="${FAKE_LSPCI:-Network controller [14e4:4488]}" \
    FAKE_WIFI_STATE="${FAKE_WIFI_STATE:-30 (disconnected)}" \
    FAIL_RMMOD="${FAIL_RMMOD:-0}" \
    OMARCHY_WIFI_BCM4377_STATE_DIR="$test_tmp/state" \
    OMARCHY_WIFI_BCM4377_PCI_ROOT="$pci" \
    OMARCHY_WIFI_BCM4377_MODULE_ROOT="$modules" \
    OMARCHY_WIFI_BCM4377_NET_ROOT="$net" \
    OMARCHY_WIFI_BCM4377_SETTLE_SECONDS=0 \
    OMARCHY_WIFI_BCM4377_ATTEMPTS=2 \
    "$cmd" "$@"
}

# BCM4364 must stay bound. Its suspend failure is a different firmware bug.
setup_machine
FAKE_LSPCI="Network controller [14e4:4464]" run_cmd pre
[[ $(d3_of 0000:74:00.0) == "1" ]] || fail "BCM4364 leaves NVMe d3cold alone"
! grep -q modprobe "$call_log" || fail "BCM4364 does not unload brcmfmac" "$(cat "$call_log")"
pass "BCM4364 is left bound"

# No Broadcom Wi-Fi at all.
setup_machine
FAKE_LSPCI="VGA compatible controller [8086:9a49]" run_cmd pre
[[ $(d3_of 0000:74:00.0) == "1" ]] || fail "a machine without BCM4377 leaves d3cold alone"
pass "a machine without BCM4377 is left alone"

# The driver comes off only after the link is down, and only the Apple
# functions that blocked resume change. 1803 was already 0 and must be
# restored to 0, not forced to 1. An unrelated Apple function stays 1.
setup_machine
run_cmd pre
for bdf in 0000:74:00.0 0000:74:00.1 0000:74:00.2; do
  [[ $(d3_of "$bdf") == "0" ]] || fail "d3cold is blocked for the sleep" "$bdf=$(d3_of "$bdf")"
done
[[ $(d3_of 0000:74:00.3) == "0" ]] || fail "the T2 audio function is held out of d3cold"
[[ $(d3_of 0000:74:00.4) == "1" ]] || fail "an unrelated Apple function keeps its d3cold value"
[[ $(d3_of 0000:73:00.0) == "1" ]] || fail "the Wi-Fi function's own d3cold value is not rewritten"
[[ ! -d $modules/brcmfmac ]] || fail "brcmfmac is unloaded before sleep"
disconnect_line=$(grep -n 'device disconnect wlp0' "$call_log" | head -n 1 | cut -d: -f1)
rmmod_line=$(grep -n 'modprobe -r brcmfmac$' "$call_log" | head -n 1 | cut -d: -f1)
[[ -n $disconnect_line && -n $rmmod_line && $disconnect_line -lt $rmmod_line ]] ||
  fail "the link is disconnected before rmmod" "$(cat "$call_log")"
grep -q 'ip link set wlp0 down' "$call_log" || fail "the interface is brought down before rmmod"
! grep -q 'systemctl' "$call_log" || fail "NetworkManager is not stopped from the sleep command"
! grep -q 'connection up' "$call_log" || fail "pre does not bring a named profile up"
pass "BCM4377 unloads brcmfmac after the link is down and blocks d3cold for the sleep"

# Resume puts the saved values back, reloads the driver, and connects the
# interface without naming a profile.
FAKE_WIFI_STATE="30 (disconnected)" run_cmd post
[[ $(d3_of 0000:74:00.0) == "1" ]] || fail "NVMe d3cold is restored after resume"
[[ $(d3_of 0000:74:00.3) == "0" ]] || fail "a function that was already out of d3cold stays that way"
[[ -d $modules/brcmfmac ]] || fail "brcmfmac is reloaded after resume"
grep -q 'radio wifi on' "$call_log" || fail "the radio is enabled after resume"
grep -q 'device connect wlp0' "$call_log" || fail "a disconnected interface is connected without a profile name"
! grep -q 'connection up' "$call_log" || fail "resume does not bring a named profile up" "$(cat "$call_log")"
[[ ! -d $test_tmp/state ]] || fail "sleep state is cleared after resume"
pass "resume restores d3cold and reconnects without a network name"

# A link NetworkManager already brought back is not kicked.
setup_machine
run_cmd pre
: >"$call_log"
FAKE_WIFI_STATE="100 (connected)" run_cmd post
! grep -q 'device connect' "$call_log" || fail "an already connected interface is left to NetworkManager" "$(cat "$call_log")"
pass "an already connected interface is left to NetworkManager"

# The driver was not ours to remove, so resume must not load it either.
# d3cold is still held for the sleep, because that hang happened with the
# driver already gone.
setup_machine
rm -rf "$modules/brcmfmac" "$modules/brcmfmac_wcc"
run_cmd pre
[[ $(d3_of 0000:74:00.0) == "0" ]] || fail "d3cold is still blocked when brcmfmac is already gone"
! grep -q 'modprobe -r' "$call_log" || fail "an absent module is not removed again"
: >"$call_log"
run_cmd post
[[ $(d3_of 0000:74:00.0) == "1" ]] || fail "d3cold is restored when the module was already absent"
! grep -q 'modprobe brcmfmac' "$call_log" || fail "resume does not load a module it did not unload"
pass "a module that was already unloaded is not reloaded"

# A busy module must fail the sleep and undo the d3cold change. Hiding the
# rmmod failure and sleeping anyway is how the firmware wedge starts.
setup_machine
FAIL_RMMOD=1
set +e
run_cmd pre
status=$?
set -e
FAIL_RMMOD=0
[[ $status -ne 0 ]] || fail "a busy brcmfmac aborts sleep"
[[ -d $modules/brcmfmac ]] || fail "a failed unload leaves the module in place"
[[ $(d3_of 0000:74:00.0) == "1" ]] || fail "a failed unload restores d3cold"
[[ $(d3_of 0000:74:00.3) == "0" ]] || fail "a failed unload restores a previous 0"
grep -q 'radio wifi off' "$call_log" || fail "a busy module gets one try with the radio off"
[[ ! -e $test_tmp/state/method ]] || fail "a failed unload does not leave sleep state behind"
pass "a busy brcmfmac aborts sleep and restores d3cold"

# The link is already down, which is the usual suspend path. Do not disconnect
# a device NetworkManager has already deactivated.
setup_machine
printf '%s\n' down >"$net/wlp0/operstate"
run_cmd pre
! grep -q 'device disconnect' "$call_log" || fail "a down interface is not disconnected again"
grep -q 'modprobe -r brcmfmac' "$call_log" || fail "a down interface is still unloaded"
pass "a down interface is unloaded without another disconnect"

# Installer gate: the unit is written only for BCM4377, and never on Apple Silicon.
run_leaf() {
  local wifi_id=$1 silicon=${2:-0}
  rm -rf "$test_tmp/etc"
  mkdir -p "$test_tmp/etc"
  : >"$call_log"
  FAKE_LSPCI="Network controller [14e4:$wifi_id]" \
    FAKE_APPLE_SILICON="$silicon" \
    CALL_LOG="$call_log" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_WIFI_BCM4377_SYSTEMD_DIR="$test_tmp/etc" \
    PATH="$stub_bin:$PATH" \
    bash -eE -c 'source "$1"' bash "$leaf" </dev/null
}

run_leaf 4464
[[ ! -e $test_tmp/etc/omarchy-wifi-bcm4377-sleep.service ]] ||
  fail "BCM4364 does not get the BCM4377 sleep unit"
pass "the installer leaves BCM4364 alone"

run_leaf 4488 1
[[ ! -e $test_tmp/etc/omarchy-wifi-bcm4377-sleep.service ]] ||
  fail "Apple Silicon does not get the Intel Mac sleep unit"
pass "the installer leaves Apple Silicon alone"

run_leaf 4488
[[ -f $test_tmp/etc/omarchy-wifi-bcm4377-sleep.service ]] ||
  fail "BCM4377 gets the sleep unit"
cmp -s "$unit" "$test_tmp/etc/omarchy-wifi-bcm4377-sleep.service" ||
  fail "the installed unit is the packaged one"
grep -qx 'systemctl enable omarchy-wifi-bcm4377-sleep.service' "$call_log" ||
  fail "the installer enables the unit without starting it" "$(cat "$call_log")"
pass "the installer enables the BCM4377 sleep unit"
