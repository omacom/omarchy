#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

watcher="$ROOT/bin/omarchy-hw-apple-bt-a2dp-priority"
helpers="$ROOT/install/hardware/apple/bt-a2dp-priority.sh"
fix="$ROOT/install/hardware/apple/fix-bt-a2dp-priority.sh"
service="$ROOT/default/systemd/system/omarchy-bt-a2dp-priority.service"
migration="$ROOT/migrations/1788703723.sh"

[[ -x $watcher ]] || fail "the watcher script is executable"

grep -Fq 'ExecStart=/usr/bin/omarchy-hw-apple-bt-a2dp-priority' "$service" ||
  fail "service runs the watcher script"
grep -Fq 'ConditionPathIsDirectory=/sys/module/hci_bcm4377' "$service" ||
  fail "service is gated on the hci_bcm4377 driver being loaded"
pass "service runs the watcher script only where hci_bcm4377 is loaded"

grep -Fq 'fix-bt-a2dp-priority.sh' "$ROOT/install/hardware/all.sh" ||
  fail "hardware install runs the A2DP priority fix hook"
pass "A2DP priority fix hook is wired into the installer"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

# --- hardware gate ---
cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash
cat "$LSPCI_OUTPUT"
SH
chmod +x "$stub_bin/lspci"

# shellcheck source=../../install/hardware/apple/bt-a2dp-priority.sh
source "$helpers"

assert_needed() {
  local pci_line=$1 expect=$2 description=$3
  local tmp
  tmp=$(mktemp)
  printf '%s\n' "$pci_line" >"$tmp"
  if PATH="$stub_bin:$PATH" LSPCI_OUTPUT="$tmp" bt_a2dp_priority_needed; then
    [[ $expect == yes ]] || fail "$description"
  else
    [[ $expect == no ]] || fail "$description"
  fi
  rm -f "$tmp"
  pass "$description"
}

assert_needed "00:1f.3 Bluetooth: Broadcom Inc. and subsidiaries [106b:1802] (rev 40)" yes "T2 iBridge (1802) is detected"
assert_needed "00:1f.3 Bluetooth: Broadcom Inc. and subsidiaries [106b:1801] (rev 40)" yes "T2 iBridge (1801) is detected"
assert_needed "00:1f.3 Ethernet controller [8086:15d8]" no "non-T2 hardware is not detected"

# --- watcher script picks A2DP connects out of bluetoothctl --monitor ---
cat >"$stub_bin/bluetoothctl" <<'SH'
#!/bin/bash
if [[ $1 == "--monitor" ]]; then
  cat "$MONITOR_FEED"
  exit 0
fi
if [[ $1 == "info" ]]; then
  grep -q "$2" "$AUDIO_SINK_DEVICES" && echo "UUID: Audio Sink"
  exit 0
fi
SH
cat >"$stub_bin/hcitool" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$HCITOOL_LOG"
[[ $1 == "con" ]] && cat "$HCITOOL_CON_OUTPUT"
SH
chmod +x "$stub_bin"/*

feed="$test_tmp/monitor-feed"
con_out="$test_tmp/con-out"
sink_devices="$test_tmp/sink-devices"
hcitool_log="$test_tmp/hcitool.log"
printf '< ACL AA:BB:CC:DD:EE:FF handle 11 state 1 lm MASTER\n' >"$con_out"

# The stub feed ends after one line, unlike the real bluetoothctl --monitor,
# which never exits — the loop's last `read` then hits EOF and returns 1,
# which becomes the whole script's exit status. That's a property of this
# stub, not a bug in the watcher, so the exit status itself isn't asserted on.
run_watcher() {
  PATH="$stub_bin:$PATH" \
    MONITOR_FEED="$feed" \
    AUDIO_SINK_DEVICES="$sink_devices" \
    HCITOOL_CON_OUTPUT="$con_out" \
    HCITOOL_LOG="$hcitool_log" \
    BT_A2DP_PRIORITY_CONNECT_SETTLE_SECONDS=0 \
    "$watcher" || true
}

printf '[CHG] Device AA:BB:CC:DD:EE:FF Connected: yes\n' >"$feed"
printf 'AA:BB:CC:DD:EE:FF\n' >"$sink_devices"
: >"$hcitool_log"
run_watcher
grep -Fq 'cmd 0x3f 0x57 0x0B 0x00 0x01' "$hcitool_log" ||
  fail "watcher sends the ACL-priority command for a connected audio sink" "$(cat "$hcitool_log")"
pass "watcher sends the ACL-priority command for a connected audio sink"

printf '[CHG] Device 11:22:33:44:55:66 Connected: yes\n' >"$feed"
: >"$sink_devices"
: >"$hcitool_log"
run_watcher
[[ ! -s $hcitool_log ]] || fail "watcher ignores a connect from a non-audio device" "$(cat "$hcitool_log")"
pass "watcher ignores a connect from a non-audio device"

# --- install hook + migration wiring ---
calls="$test_tmp/calls.log"
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
SH
cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'omarchy-pkg-add' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
SH
cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
[[ $1 == "is-enabled" ]] && [[ -f $SERVICE_ENABLED_MARKER ]]
SH
chmod +x "$stub_bin"/*

t2_pci="$test_tmp/pci-t2"
non_t2_pci="$test_tmp/pci-non-t2"
printf '00:1f.3 Bluetooth: Broadcom Inc. and subsidiaries [106b:1802]\n' >"$t2_pci"
printf '00:1f.3 Ethernet controller [8086:15d8]\n' >"$non_t2_pci"
enabled_marker="$test_tmp/service-enabled"

run_fix_or_migration() {
  local script=$1 pci=$2
  PATH="$stub_bin:$PATH" \
    TEST_LOG="$calls" \
    LSPCI_OUTPUT="$pci" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_INSTALL="$ROOT/install" \
    SERVICE_ENABLED_MARKER="$enabled_marker" \
    bash -c 'source "$1"' _ "$script"
}

: >"$calls"; rm -f "$enabled_marker"
run_fix_or_migration "$fix" "$non_t2_pci"
[[ ! -s $calls ]] || fail "install hook no-ops on non-T2 hardware" "$(cat "$calls")"
pass "install hook no-ops on non-T2 hardware"

: >"$calls"; rm -f "$enabled_marker"
run_fix_or_migration "$fix" "$t2_pci"
grep -Fq $'omarchy-pkg-add\tbluez-deprecated-tools' "$calls" ||
  fail "install hook installs bluez-deprecated-tools" "$(cat "$calls")"
grep -Fq $'sudo\tsystemctl\tenable\t--now\tomarchy-bt-a2dp-priority.service' "$calls" ||
  fail "install hook enables the priority-fix service" "$(cat "$calls")"
pass "install hook wires the A2DP priority fix on T2 hardware"

touch "$enabled_marker"
: >"$calls"
run_fix_or_migration "$fix" "$t2_pci"
grep -Fq $'sudo\tsystemctl\tenable\t--now\tomarchy-bt-a2dp-priority.service' "$calls" &&
  fail "install hook is a no-op once already enabled" "$(cat "$calls")"
pass "install hook is a no-op once already enabled"

rm -f "$enabled_marker"
: >"$calls"
run_fix_or_migration "$migration" "$t2_pci"
grep -Fq $'sudo\tsystemctl\tenable\t--now\tomarchy-bt-a2dp-priority.service' "$calls" ||
  fail "migration enables the priority-fix service on existing T2 installs" "$(cat "$calls")"
pass "migration wires the A2DP priority fix on existing T2 installs"

: >"$calls"
run_fix_or_migration "$migration" "$non_t2_pci"
[[ ! -s $calls ]] || fail "migration skips unrelated hardware" "$(cat "$calls")"
pass "migration skips unrelated hardware"
