#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
monitor_pid=""
cleanup() {
  if [[ -n $monitor_pid ]]; then
    kill "$monitor_pid" 2>/dev/null || true
    wait "$monitor_pid" 2>/dev/null || true
  fi
  rm -rf "$tmp"
}
trap cleanup EXIT
mkdir -p "$tmp/bin" "$tmp/home"
export HOME="$tmp/home" XDG_STATE_HOME="$tmp/state with spaces" MOCK_DIR="$tmp"
export PATH="$tmp/bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" OMARCHY_BLUETOOTH_POWER_WAIT_SECONDS=0
state_file="$XDG_STATE_HOME/omarchy/bluetooth-power"

cat >"$tmp/bin/busctl" <<'SH'
#!/bin/bash
while [[ $1 == --* ]]; do shift; done
printf 'busctl %s\n' "$*" >>"$MOCK_DIR/log"
[[ -n ${MOCK_BUS_DOWN:-} || -f $MOCK_DIR/bus-unavailable ]] && exit 1
case "$1" in
  call)
    [[ $5 == GetNameOwner ]] || exit 1
    owner=1
    [[ ! -f $MOCK_DIR/bluez-owner ]] || owner=$(cat "$MOCK_DIR/bluez-owner")
    printf 's ":1.%s"\n' "$owner"
    ;;
  tree)
    [[ -n ${MOCK_NO_ADAPTERS:-} || -f $MOCK_DIR/adapter-unavailable ]] && exit 0
    printf '/org/bluez/hci0\n/org/bluez/hci0/dev_AA_BB\n'
    [[ -f $MOCK_DIR/hci1 ]] && echo /org/bluez/hci1
    ;;
  get-property)
    [[ -n ${MOCK_READ_FAIL:-} ]] && exit 1
    if [[ $5 == Address ]]; then
      if [[ -f $MOCK_DIR/address-${3##*/} ]]; then
        address=$(cat "$MOCK_DIR/address-${3##*/}")
      elif [[ ${3##*/} == hci0 ]]; then
        address=AA:BB:CC:DD:EE:FF
      else
        address=11:22:33:44:55:66
      fi
      printf 's "%s"\n' "$address"
    else
      printf 'b %s\n' "$(cat "$MOCK_DIR/${3##*/}")"
    fi
    ;;
  set-property)
    [[ -n ${MOCK_SET_FAIL:-} || -f $MOCK_DIR/set-fail ]] && exit 1
    if [[ -f $MOCK_DIR/reject-once ]]; then
      rm "$MOCK_DIR/reject-once"
      exit 1
    fi
    block=none
    [[ ${3##*/} != hci0 ]] || block=$(cat "$MOCK_DIR/block")
    [[ ! -f $MOCK_DIR/block-${3##*/} ]] || block=$(cat "$MOCK_DIR/block-${3##*/}")
    [[ $7 == true && $block != none ]] && exit 1
    echo "$7" >"$MOCK_DIR/${3##*/}"
    ;;
esac
exit 0
SH

cat >"$tmp/bin/rfkill" <<'SH'
#!/bin/bash
printf 'rfkill %s\n' "$*" >>"$MOCK_DIR/log"
if [[ $1 == unblock ]]; then
  [[ -n ${MOCK_UNBLOCK_FAIL:-} ]] && exit 1
  for file in "$MOCK_DIR/block" "$MOCK_DIR"/block-hci*; do
    [[ ! -f $file || $(cat "$file") != soft ]] || echo none >"$file"
  done
elif [[ $1 == --raw ]]; then
  [[ -n ${MOCK_RFKILL_READ_FAIL:-} ]] && exit 1
  for device in hci0 hci1; do
    [[ $device == hci0 || -f $MOCK_DIR/hci1 || -n ${MOCK_SECONDARY_BLOCK:-} ]] || continue
    block=none
    [[ $device != hci0 ]] || block=$(cat "$MOCK_DIR/block")
    [[ ! -f $MOCK_DIR/block-$device ]] || block=$(cat "$MOCK_DIR/block-$device")
    [[ $device != hci1 || -z ${MOCK_SECONDARY_BLOCK:-} ]] || block=hard
    soft=unblocked hard=unblocked
    case "$block" in
      soft) soft=blocked ;;
      hard) hard=blocked ;;
    esac
    if [[ $* == *'--output DEVICE,SOFT,HARD'* ]]; then
      printf '%s %s %s\n' "$device" "$soft" "$hard"
    elif [[ $* == *'--output SOFT,HARD'* ]]; then
      printf '%s %s\n' "$soft" "$hard"
    else
      echo "$soft"
    fi
  done
else
  echo "unexpected rfkill operation" >&2
  exit 1
fi
exit 0
SH

cat >"$tmp/bin/bluetoothctl" <<'SH'
#!/bin/bash
printf 'bluetoothctl %s\n' "$*" >>"$MOCK_DIR/log"
if [[ $1 == show ]]; then
  if [[ $(cat "$MOCK_DIR/hci0") == true ]]; then echo 'Powered: yes'; else echo 'Powered: no'; fi
fi
SH

cat >"$tmp/bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$MOCK_DIR/log"
[[ -n ${MOCK_NO_SESSION:-} && $1 == --user ]] && exit 1
if [[ -n ${MOCK_MONITOR_INACTIVE:-} ]]; then
  [[ $* == '--user is-active --quiet omarchy-bluetooth-power.service' ]] && exit 1
  [[ $* == '--user is-active --quiet omarchy-bluetooth-power-adopt.service' && ! -f $MOCK_DIR/adopt-started ]] && exit 1
fi
exit 0
SH

cat >"$tmp/bin/systemd-run" <<'SH'
#!/bin/bash
printf 'systemd-run %s\n' "$*" >>"$MOCK_DIR/log"
touch "$MOCK_DIR/adopt-started"
SH

cat >"$tmp/bin/sudo" <<'SH'
#!/bin/bash
echo 'migration must not request elevated radio changes' >&2
exit 1
SH

cat >"$tmp/bin/mv" <<'SH'
#!/bin/bash
[[ -n ${MOCK_RENAME_FAIL:-} ]] && exit 1
/usr/bin/mv "$@"
SH
cat >"$tmp/bin/stat" <<'SH'
#!/bin/bash
path=${@: -1}
if [[ $path == /sys/class/bluetooth/hci* ]]; then
  [[ -f $MOCK_DIR/${path##*/} ]] || exit 1
  instance=1
  [[ ! -f $MOCK_DIR/instance-${path##*/} ]] || instance=$(cat "$MOCK_DIR/instance-${path##*/}")
  printf '1:%s\n' "$instance"
else
  /usr/bin/stat "$@"
fi
SH
cat >"$tmp/bin/sleep" <<'SH'
#!/bin/bash
[[ $1 == infinity ]] && printf 'idle %s\n' "$PPID" >>"$MOCK_DIR/log"
[[ $1 == 2 ]] && printf 'retry %s\n' "$PPID" >>"$MOCK_DIR/log"
exec /usr/bin/sleep "$@"
SH
chmod +x "$tmp/bin/"*

reset_radio() {
  echo "$1" >"$tmp/hci0"
  echo none >"$tmp/block"
  rm -f "$tmp/hci1" "$tmp"/block-hci* "$tmp"/address-hci* "$tmp"/instance-hci* "$tmp/bluez-owner" "$tmp/reject-once" "$tmp/bus-unavailable" "$tmp/adapter-unavailable" "$tmp/set-fail" "$tmp/adopt-started" "$state_file"
  : >"$tmp/log"
}

assert_saved() {
  local address=${2:-AA:BB:CC:DD:EE:FF} actual
  actual=$(awk -v address="${address^^}" 'NR == 1 { state = $0 } toupper($1) == address { state = $2 } END { print state }' "$state_file")
  [[ $actual == "$1" ]] || fail "saved Bluetooth preference for $address is $1 (got $actual)"
}

reset_radio true
omarchy-bluetooth-power off
[[ $(cat "$tmp/hci0") == false && $(cat "$tmp/block") == none ]] || fail "normal off only powers down BlueZ"
! grep -q '^rfkill ' "$tmp/log" || fail "normal off touches rfkill"
assert_saved off
# The exact operation Chromium uses must now work, without an unblock.
busctl --system set-property org.bluez /org/bluez/hci0 org.bluez.Adapter1 Powered b true
[[ $(cat "$tmp/hci0") == true ]] || fail "a BlueZ client can power on after Omarchy turns off"
pass "normal off leaves Chromium's BlueZ power-on path usable"

omarchy-bluetooth-power save
assert_saved on
pass "logout snapshots power changes made by another client"

reset_radio false
echo soft >"$tmp/block"
omarchy-bluetooth-power on
[[ $(cat "$tmp/hci0") == true && $(cat "$tmp/block") == none ]] || fail "explicit on clears a software block"
assert_saved on
pass "explicit on recovers a software block and records success"

omarchy-bluetooth-power toggle
assert_saved off
omarchy-bluetooth-power toggle
assert_saved on
omarchy-bluetooth-power is-on || fail "is-on detects powered adapter"
omarchy-bluetooth-power off
if omarchy-bluetooth-power is-on; then fail "is-on detects unpowered adapter"; fi
pass "toggle and is-on follow BlueZ Powered"

reset_radio false
echo true >"$tmp/hci1"
omarchy-bluetooth-power is-on || fail "secondary adapter counts as on"
omarchy-bluetooth-power toggle
[[ $(cat "$tmp/hci0") == false && $(cat "$tmp/hci1") == false ]] || fail "off reaches all controllers"
omarchy-bluetooth-power on
[[ $(cat "$tmp/hci0") == true && $(cat "$tmp/hci1") == true ]] || fail "on reaches all controllers"
! grep -q 'set-property.*dev_AA_BB' "$tmp/log" || fail "device mistaken for adapter"
pass "both directions reach every controller, not device paths"

reset_radio true
omarchy-bluetooth-power off
echo true >"$tmp/hci0" # BlueZ AutoEnable on the next boot.
omarchy-bluetooth-power restore
[[ $(cat "$tmp/hci0") == false ]] || fail "login restores the saved off state"
assert_saved off
pass "saved off survives a new BlueZ session"

# Restoring is not explicit consent to lift an airplane-mode block.
omarchy-bluetooth-power on
echo false >"$tmp/hci0"
echo soft >"$tmp/block"
: >"$tmp/log"
if omarchy-bluetooth-power restore 2>/dev/null; then fail "restore unexpectedly bypasses soft block"; fi
! grep -q '^rfkill ' "$tmp/log" || fail "restore clears an external rfkill block"
assert_saved on
pass "login respects an external software block without losing the preference"

reset_radio false
omarchy-bluetooth-power save
for failure in MOCK_SET_FAIL MOCK_UNBLOCK_FAIL; do
  if env "$failure=1" omarchy-bluetooth-power on 2>/dev/null; then fail "$failure is reported"; fi
  assert_saved off
done
echo hard >"$tmp/block"
if omarchy-bluetooth-power on 2>/dev/null; then fail "hard block is reported"; fi
assert_saved off
pass "failed power changes and hard blocks do not overwrite the preference"

reset_radio false
omarchy-bluetooth-power on
for failure in MOCK_BUS_DOWN MOCK_NO_ADAPTERS MOCK_READ_FAIL; do
  env "$failure=1" omarchy-bluetooth-power save
  env "$failure=1" omarchy-bluetooth-power restore
  assert_saved on
done
pass "missing hardware and D-Bus failures never become a saved off preference"

reset_radio false
omarchy-bluetooth-power restore
! grep -q 'set-property' "$tmp/log" || fail "missing state causes a power change"
mkdir -p "$(dirname "$state_file")"
echo invalid >"$state_file"
if omarchy-bluetooth-power restore 2>/dev/null; then fail "invalid state is rejected"; fi
! grep -q 'set-property' "$tmp/log" || fail "invalid state causes a power change"
pass "absent or invalid state is never executed as a power direction"

for record in 'invalid off' 'AA:BB:CC:DD:EE:FF invalid' 'AA:BB:CC:DD:EE:FF off extra' $'AA:BB:CC:DD:EE:FF off\naa:bb:cc:dd:ee:ff on'; do
  printf 'on\n%s\n' "$record" >"$state_file"
  if omarchy-bluetooth-power restore 2>/dev/null; then fail "invalid adapter override is accepted"; fi
  ! grep -q 'set-property' "$tmp/log" || fail "invalid overrides change power"
done
pass "invalid, duplicate and extra-token adapter overrides are rejected before power changes"

reset_radio false
touch "$tmp/reject-once"
OMARCHY_BLUETOOTH_POWER_WAIT_SECONDS=2 omarchy-bluetooth-power on
assert_saved on
pass "power control retries a transient BlueZ transition"

reset_radio true
omarchy-bluetooth-device connect AA:BB:CC:DD:EE:FF
! grep -q '^rfkill ' "$tmp/log" || fail "already powered connect incurs a power change"
grep -qx 'bluetoothctl connect AA:BB:CC:DD:EE:FF' "$tmp/log" || fail "already powered connect reaches bluetoothctl"
reset_radio false
omarchy-bluetooth-device connect AA:BB:CC:DD:EE:FF
assert_saved on
grep -qx 'bluetoothctl connect AA:BB:CC:DD:EE:FF' "$tmp/log" || fail "unpowered connect reaches bluetoothctl"
pass "connecting reuses power control only when needed"

reset_radio false
echo soft >"$tmp/block"
migration_output=$(bash -euo pipefail "$ROOT/migrations/1790784806.sh")
grep -qxF 'Existing Bluetooth blocks are preserved. Enable Bluetooth once in Omarchy to allow application power-on.' <<<"$migration_output" || fail "migration hides the existing-block warning"
assert_saved off
[[ $(cat "$tmp/block") == soft && $(cat "$tmp/hci0") == false ]] || fail "migration changes an existing software block"
bash -euo pipefail "$ROOT/migrations/1790784806.sh"
assert_saved off
[[ $(cat "$tmp/block") == soft ]] || fail "migration retry clears an existing software block"
! grep -q '^rfkill unblock' "$tmp/log" || fail "migration clears airplane mode"
! grep -q 'set-property' "$tmp/log" || fail "migration directly changes radio power"
pass "migration preserves all existing blocks on first run and retry"

reset_radio false
echo soft >"$tmp/block"
if MOCK_RENAME_FAIL=1 bash -euo pipefail "$ROOT/migrations/1790784806.sh"; then
  fail "migration continues after an atomic preference write fails"
fi
[[ ! -e $state_file && $(cat "$tmp/block") == soft ]] || fail "failed migration leaves partial state or changes radio blocks"
! compgen -G "$state_file.*" >/dev/null || fail "failed migration leaves staging files"
bash -euo pipefail "$ROOT/migrations/1790784806.sh"
assert_saved off
[[ $(stat -c %a "$state_file") == 600 ]] || fail "migration preference has the helper's private mode"
pass "migration preference writes are atomic, private and retry-safe"

reset_radio true
MOCK_NO_SESSION=1 bash -euo pipefail "$ROOT/migrations/1790784806.sh"
assert_saved on
[[ -L $HOME/.config/systemd/user/graphical-session.target.wants/omarchy-bluetooth-power.service ]] || fail "migration without a user manager enables next login"
pass "migration preserves on and enables restoration without a user manager"

reset_radio true
echo false >"$tmp/hci1"
echo soft >"$tmp/block-hci1"
MOCK_NO_SESSION=1 bash -euo pipefail "$ROOT/migrations/1790784806.sh"
assert_saved on
[[ $(cat "$tmp/block-hci1") == soft ]] || fail "migration unblocks secondary adapter"
omarchy-bluetooth-power restore >/dev/null 2>&1 || true
[[ $(cat "$tmp/hci0") == true ]] || fail "mixed-adapter migration powers off primary at next login"
pass "migration preserves a powered primary alongside a blocked secondary adapter"

reset_radio true
omarchy-bluetooth-power save off # An application has since powered Bluetooth on.
bash -euo pipefail "$ROOT/migrations/1790784806.sh"
assert_saved off
[[ $(cat "$tmp/hci0") == true ]] || fail "migration interrupts active Bluetooth use"
! grep -Eq '^systemctl --user (start|restart)' "$tmp/log" || fail "migration starts or restarts a monitor over an active session"
pass "migration enables next login without reapplying stale off in the live session"
! grep -q '^systemd-run ' "$tmp/log" || fail "migration replaces an already running monitor"

reset_radio true
omarchy-bluetooth-power save off
MOCK_MONITOR_INACTIVE=1 bash -euo pipefail "$ROOT/migrations/1790784806.sh"
MOCK_MONITOR_INACTIVE=1 bash -euo pipefail "$ROOT/migrations/1790784806.sh"
[[ $(grep -c '^systemd-run ' "$tmp/log") == 1 ]] || fail "migration duplicates the update-session monitor"
grep -q '^systemd-run .*--collect.*--unit=omarchy-bluetooth-power-adopt.service.*--property=After=graphical-session.target.*--property=PartOf=graphical-session.target.*monitor --adopt$' "$tmp/log" || fail "migration monitor is not transient, session-bound and adopt-only"
[[ $(cat "$tmp/hci0") == true ]] || fail "adopting an update session changes live power"
assert_saved off
pass "migration launches one snapshot-only session-bound monitor without replacing an existing one"

reset_radio false
echo soft >"$tmp/block"
MOCK_BUS_DOWN=1 bash -euo pipefail "$ROOT/migrations/1790784806.sh"
assert_saved off
[[ $(cat "$tmp/block") == soft ]] || fail "offline migration clears an existing radio block"
pass "migration captures blocked off atomically without BlueZ or clearing the block"

reset_radio true
omarchy-bluetooth-power save on
if MOCK_RENAME_FAIL=1 omarchy-bluetooth-power save off; then fail "failed atomic save is reported"; fi
assert_saved on
if omarchy-bluetooth-power save invalid; then fail "invalid preference is rejected"; fi
assert_saved on
! compgen -G "$state_file.*" >/dev/null || fail "failed save leaves staging files"
pass "explicit preferences use atomic writes without damaging existing state"

wait_for_off() {
  for (( attempt=0; attempt<100; attempt++ )); do
    [[ $(cat "$tmp/hci0") == false ]] && return 0
    sleep 0.1
  done
  fail "monitor restores off after availability returns"
}

wait_monitor_ready() {
  for (( attempt=0; attempt<100; attempt++ )); do
    grep -qx "idle $monitor_pid" "$tmp/log" && return 0
    sleep 0.1
  done
  fail "monitor reaches the post-restoration wait"
}

wait_monitor_retry() {
  for (( attempt=0; attempt<100; attempt++ )); do
    [[ $(grep -cx "retry $monitor_pid" "$tmp/log" || true) -ge $1 ]] && return 0
    sleep 0.1
  done
  fail "monitor retries pending adapter restoration"
}

stop_monitor() {
  # systemd's normal stop sends TERM; the process decides whether to snapshot.
  kill "$monitor_pid"
  wait "$monitor_pid" || true
  monitor_pid=""
}

for unavailable in bus-unavailable adapter-unavailable set-fail; do
  reset_radio true
  omarchy-bluetooth-power save off
  touch "$tmp/$unavailable"
  omarchy-bluetooth-power monitor >/dev/null 2>&1 &
  monitor_pid=$!
  sleep 0.3
  kill -0 "$monitor_pid" || fail "monitor exits while $unavailable"
  [[ $(cat "$tmp/hci0") == true ]] || fail "monitor changes power before $unavailable is resolved"
  rm "$tmp/$unavailable"
  wait_for_off
  wait_monitor_ready
  kill -0 "$monitor_pid" || fail "monitor exits after restoration"
  busctl --system set-property org.bluez /org/bluez/hci0 org.bluez.Adapter1 Powered b true
  stop_monitor
  assert_saved on
  pass "session waits through $unavailable, restores and saves external changes at logout"
done

for pending in bus-unavailable set-fail soft-block; do
  reset_radio false
  omarchy-bluetooth-power save on
  if [[ $pending == "soft-block" ]]; then
    echo soft >"$tmp/block"
  else
    touch "$tmp/$pending"
  fi
  omarchy-bluetooth-power monitor >/dev/null 2>&1 &
  monitor_pid=$!
  sleep 0.3
  kill -0 "$monitor_pid" || fail "pending $pending monitor exits before stop"
  stop_monitor
  assert_saved on
  [[ $(cat "$tmp/hci0") == false ]] || fail "pending $pending monitor changes the radio"
  pass "stopping pending $pending restoration preserves the saved on preference"
done

reset_radio false
omarchy-bluetooth-power save off
omarchy-bluetooth-power monitor >/dev/null 2>&1 &
monitor_pid=$!
wait_monitor_ready
busctl --system set-property org.bluez /org/bluez/hci0 org.bluez.Adapter1 Powered b true
stop_monitor
assert_saved on
: >"$tmp/log"
omarchy-bluetooth-power monitor >/dev/null 2>&1 &
monitor_pid=$!
wait_monitor_ready
[[ $(cat "$tmp/hci0") == true ]] || fail "restarting a ready monitor interrupts an application's power-on"
! grep -q 'set-property.*Powered b false' "$tmp/log" || fail "restart reapplies the old off preference"
stop_monitor
pass "restart snapshots live application power instead of reapplying stale off"

reset_radio true
omarchy-bluetooth-power save off
: >"$tmp/log"
omarchy-bluetooth-power monitor --adopt >/dev/null 2>&1 &
monitor_pid=$!
wait_monitor_ready
[[ $(cat "$tmp/hci0") == true ]] || fail "adopt mode restores stale off over a live connection"
! grep -q 'set-property' "$tmp/log" || fail "adopt mode writes radio power"
stop_monitor
assert_saved on
pass "update-session adoption captures current power without restoring stale preferences"

for mode in restore adopt; do
  for block in soft hard; do
    reset_radio true
    omarchy-bluetooth-power save on
    if [[ $mode == "adopt" ]]; then
      echo false >"$tmp/hci0"
      echo "$block" >"$tmp/block"
      omarchy-bluetooth-power monitor --adopt >/dev/null 2>&1 &
    else
      omarchy-bluetooth-power monitor >/dev/null 2>&1 &
    fi
    monitor_pid=$!
    wait_monitor_ready
    echo false >"$tmp/hci0"
    echo "$block" >"$tmp/block"
    stop_monitor
    assert_saved on
    [[ $(cat "$tmp/block") == "$block" ]] || fail "$mode monitor changes a $block block"
    ! grep -q '^rfkill unblock' "$tmp/log" || fail "$mode monitor clears a $block block"
    pass "$mode monitor preserves saved on when a temporary $block block forces power off"
  done
done

# Public implicit snapshots use the same guard, while explicit off remains a
# user choice even when a block is currently keeping the adapter down.
omarchy-bluetooth-power save
assert_saved on
omarchy-bluetooth-power off
assert_saved off
pass "implicit blocked snapshots preserve preferences but explicit off is remembered"

reset_radio false
omarchy-bluetooth-power save on
MOCK_RFKILL_READ_FAIL=1 omarchy-bluetooth-power save
assert_saved on
MOCK_RFKILL_READ_FAIL=1 omarchy-bluetooth-power monitor --adopt >/dev/null 2>&1 &
monitor_pid=$!
wait_monitor_ready
stop_monitor
assert_saved on
pass "unreadable rfkill state cannot become a saved off preference"

echo false >"$tmp/hci1"
MOCK_SECONDARY_BLOCK=1 omarchy-bluetooth-power save
assert_saved off
assert_saved on 11:22:33:44:55:66
rm "$tmp/hci1"
# Exact blocked-token matching must not reject the ordinary unblocked state.
omarchy-bluetooth-power save
assert_saved off
pass "secondary controller blocks are respected and genuine unblocked off is saved"

for block in soft hard; do
  reset_radio true
  echo false >"$tmp/hci1"
  echo "$block" >"$tmp/block-hci1"
  omarchy-bluetooth-power save on
  omarchy-bluetooth-power monitor --adopt >/dev/null 2>&1 &
  monitor_pid=$!
  wait_monitor_ready
  busctl --system set-property org.bluez /org/bluez/hci0 org.bluez.Adapter1 Powered b false
  stop_monitor
  assert_saved off
  assert_saved on 11:22:33:44:55:66
  echo none >"$tmp/block-hci1"
  echo true >"$tmp/hci0"
  omarchy-bluetooth-power restore
  [[ $(cat "$tmp/hci0") == false && $(cat "$tmp/hci1") == true ]] || fail "login forgets an independent client power-off"
  # Controller indices are not stable across boots; addresses are.
  echo 11:22:33:44:55:66 >"$tmp/address-hci0"
  echo AA:BB:CC:DD:EE:FF >"$tmp/address-hci1"
  omarchy-bluetooth-power restore
  [[ $(cat "$tmp/hci0") == true && $(cat "$tmp/hci1") == false ]] || fail "adapter renumbering swaps preferences"
  pass "client off survives a secondary $block block and adapter renumbering"
done

reset_radio false
echo false >"$tmp/hci1"
echo hard >"$tmp/block-hci1"
omarchy-bluetooth-power save on
omarchy-bluetooth-power monitor >/dev/null 2>&1 &
monitor_pid=$!
wait_monitor_retry 1
[[ $(cat "$tmp/hci0") == true ]] || fail "primary not restored independently"
busctl --system set-property org.bluez /org/bluez/hci0 org.bluez.Adapter1 Powered b false
wait_monitor_retry 2
[[ $(cat "$tmp/hci0") == false ]] || fail "secondary retry overwrites primary client choice"
stop_monitor
assert_saved off
assert_saved on 11:22:33:44:55:66
pass "pending secondary restoration neither reapplies nor discards a ready primary's choice"

for reconnect in replug daemon-restart; do
  reset_radio true
  echo false >"$tmp/hci1"
  echo hard >"$tmp/block-hci1"
  mkdir -p "$(dirname "$state_file")"
  printf 'on\nAA:BB:CC:DD:EE:FF off\n' >"$state_file"
  omarchy-bluetooth-power monitor >/dev/null 2>&1 &
  monitor_pid=$!
  wait_monitor_retry 1
  [[ $(cat "$tmp/hci0") == false ]] || fail "primary off is not restored"
  # Reuse the address and hci index between polls; mere absence tracking cannot
  # detect this. A daemon restart similarly leaves the kernel device unchanged.
  if [[ $reconnect == "replug" ]]; then
    echo 2 >"$tmp/instance-hci0"
  else
    echo 2 >"$tmp/bluez-owner"
  fi
  echo true >"$tmp/hci0"
  wait_monitor_retry 2
  [[ $(cat "$tmp/hci0") == false ]] || fail "$reconnect skips the saved off preference"
  stop_monitor
  assert_saved off
  assert_saved on 11:22:33:44:55:66
  pass "$reconnect invalidates readiness even with the same adapter address and index"
done

reset_radio true
echo false >"$tmp/hci1"
echo hard >"$tmp/block-hci1"
printf 'on\nAA:BB:CC:DD:EE:FF off\n' >"$state_file"
omarchy-bluetooth-power monitor >/dev/null 2>&1 &
monitor_pid=$!
wait_monitor_retry 1
# Keep the retrying parent stopped while the device instance changes so TERM
# tests the snapshot guard itself, rather than the next restoration pass.
kill -STOP "$monitor_pid"
echo 2 >"$tmp/instance-hci0"
echo true >"$tmp/hci0"
kill -TERM "$monitor_pid"
kill -CONT "$monitor_pid"
wait "$monitor_pid" || true
monitor_pid=""
assert_saved off
pass "stopping before a replug can be restored does not snapshot its AutoEnable on"

reset_radio false
echo hard >"$tmp/block"
echo false >"$tmp/hci1"
omarchy-bluetooth-power save on
omarchy-bluetooth-power save
assert_saved on
assert_saved off 11:22:33:44:55:66
cp "$state_file" "$tmp/previous-state"
if MOCK_RENAME_FAIL=1 omarchy-bluetooth-power save; then fail "failed adapter snapshot is reported"; fi
cmp -s "$state_file" "$tmp/previous-state" || fail "atomic failure damages adapter records"
rm "$tmp/hci1"
omarchy-bluetooth-power save
assert_saved off 11:22:33:44:55:66
pass "primary blocks, unplugged adapters and atomic failures preserve independent preferences"

reset_radio true
omarchy-bluetooth-power save on
omarchy-bluetooth-power monitor >/dev/null 2>&1 &
monitor_pid=$!
wait_monitor_ready
echo false >"$tmp/hci1"
stop_monitor
assert_saved off 11:22:33:44:55:66
pass "a late-plugged adapter is captured after initial restoration completes"

reset_radio false
omarchy-bluetooth-power save off
touch "$tmp/bus-unavailable"
omarchy-bluetooth-power monitor --adopt >/dev/null 2>&1 &
monitor_pid=$!
wait_monitor_ready
rm "$tmp/bus-unavailable"
busctl --system set-property org.bluez /org/bluez/hci0 org.bluez.Adapter1 Powered b true
stop_monitor
assert_saved on
pass "update-session adoption snapshots later application changes after delayed Bluetooth startup"

reset_radio false
touch "$tmp/bus-unavailable"
omarchy-bluetooth-power monitor >/dev/null 2>&1 &
monitor_pid=$!
wait_monitor_ready
kill -0 "$monitor_pid" || fail "session without saved state exits when BlueZ is down"
rm "$tmp/bus-unavailable"
echo true >"$tmp/hci0"
stop_monitor
assert_saved on
pass "session without an initial preference still snapshots a late Bluetooth startup"

unit="$ROOT/default/systemd/user/omarchy-bluetooth-power.service"
for line in 'ExecStart=/usr/bin/omarchy-bluetooth-power monitor' 'PartOf=graphical-session.target' 'After=graphical-session.target' 'Type=simple' 'Restart=on-failure' 'WantedBy=graphical-session.target'; do
  grep -qxF "$line" "$unit" || fail "Bluetooth state unit is missing $line"
done
! grep -q '^ExecCondition=\|^ConditionPath' "$unit" || fail "session unit skips late Bluetooth availability"
! grep -q '^ExecStop=' "$unit" || fail "session unit snapshots without the monitor's restoration guard"
grep -qF 'omarchy-bluetooth-power.service' "$ROOT/install/user/first-run/enable-user-units.sh" || fail "first run enables Bluetooth state unit"
pass "graphical session restores on login and saves on logout for new installs"
