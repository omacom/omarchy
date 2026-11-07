#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

cmd="$ROOT/bin/omarchy-system-sleep-wireplumber"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
stub_bin="$tmpdir/bin"
mkdir -p "$stub_bin" "$tmpdir/home" "$tmpdir/runtime"
# No host command fallback, including when a new effect is added later.
for name in bash cat chmod dirname mkdir mv rm date flock tr timeout grep awk head cut python3; do
  ln -s "$(command -v "$name")" "$stub_bin/$name"
done

fixture="$tmpdir/fixture"
log="$tmpdir/calls"
mkdir -p "$fixture"
: >"$log"

cat >"$stub_bin/pipewire" <<'SH'
#!/bin/bash
printf '%s\n' "${PIPEWIRE_VERSION:-1.6.9}"
SH
cat >"$stub_bin/busctl" <<SH
#!/bin/bash
printf 'busctl %s\n' "\$*" >>"$log"
if [[ \$1 == tree ]]; then
  [[ ! -f $fixture/tree-fail ]] || exit 1
  if [[ \$* == *--list* && -f $fixture/no-list ]]; then
    exit 1
  fi
  cat "$fixture/tree"
  exit 0
fi
prop=\${5:-}
path=\${3:-}
if [[ \$prop == Powered ]]; then
  count=0
  [[ -f $fixture/powered-count ]] && count=\$(<"$fixture/powered-count")
  printf '%s\n' "\$((count + 1))" >"$fixture/powered-count"
  need=0
  [[ -f $fixture/powered-after ]] && need=\$(<"$fixture/powered-after")
  [[ ! -f $fixture/powered-after-\${path##*/} ]] || need=\$(<"$fixture/powered-after-\${path##*/}")
  if (( count >= need )); then
    printf 'b true\n'
  else
    printf 'b false\n'
  fi
  exit 0
fi
key="$fixture/prop\${path//\//_}_\$prop"
if [[ -f \$key ]]; then
  cat "\$key"
  exit 0
fi
exit 1
SH
cat >"$stub_bin/systemctl" <<SH
#!/bin/bash
printf 'systemctl %s\n' "\$*" >>"$log"
mode=active
[[ -f $fixture/systemctl-mode ]] && mode=\$(<"$fixture/systemctl-mode")
case "\$*" in
  *1000@*is-active*|*is-active*1000@*)
    [[ ! -f $fixture/inactive ]] || exit 3
    exit 0
    ;;
  *is-active*) exit 3 ;;
esac
case "\$mode" in
  stop-fails)
    [[ \$* == *\ stop\ * ]] && exit 1
    ;;
  mask-fails)
    [[ \$* == *\ mask\ * ]] && exit 1
    ;;
  restart-fails)
    [[ \$* == *\ restart\ * ]] && exit 1
    ;;
  unmask-fails)
    [[ \$* == *\ unmask\ * ]] && exit 1
    ;;
esac
exit 0
SH
cat >"$stub_bin/rfkill" <<SH
#!/bin/bash
printf 'rfkill %s\n' "\$*" >>"$log"
[[ -f $fixture/rfkill ]] && cat "$fixture/rfkill"
exit 0
SH
cat >"$stub_bin/sleep" <<SH
#!/bin/bash
printf 'sleep %s\n' "\$*" >>"$log"
exit 0
SH
cat >"$stub_bin/systemd-run" <<SH
#!/bin/bash
printf 'systemd-run %s\n' "\$*" >>"$log"
exit 0
SH
chmod +x "$stub_bin"/{pipewire,busctl,systemctl,rfkill,sleep,systemd-run}

user_run="$tmpdir/run"
python3 - "$user_run" <<'PY'
import os, stat, sys
root = sys.argv[1]
for uid in ("1000", "1001"):
    path = os.path.join(root, uid)
    os.makedirs(path, exist_ok=True)
    # Only the socket-inode guard is real; all manager traffic uses a stub.
    os.mknod(os.path.join(path, "bus"), stat.S_IFSOCK | 0o600)
PY

state="$tmpdir/state/uids"
run_sleep() {
  : >"$log"
  env -i PATH="$stub_bin" HOME="$tmpdir/home" \
    XDG_CONFIG_HOME="$tmpdir/home/config" XDG_DATA_HOME="$tmpdir/home/data" \
    XDG_CACHE_HOME="$tmpdir/home/cache" XDG_STATE_HOME="$tmpdir/home/state" \
    XDG_RUNTIME_DIR="$tmpdir/runtime" TMPDIR="$tmpdir" \
    PIPEWIRE_VERSION="${PIPEWIRE_VERSION:-1.6.9}" \
    OMARCHY_WIREPLUMBER_SLEEP_STATE="$state" \
    OMARCHY_WIREPLUMBER_SLEEP_USER_RUN="$user_run" \
    OMARCHY_WIREPLUMBER_SLEEP_POLL=0 \
    OMARCHY_WIREPLUMBER_SLEEP_TRIES="${OMARCHY_WIREPLUMBER_SLEEP_TRIES:-4}" \
    "$cmd" "$@"
}

reset_fixture() {
  rm -rf "$fixture" "$tmpdir/state"
  mkdir -p "$fixture" "$(dirname "$state")"
  printf '0\n' >"$fixture/powered-count"
  printf '0\n' >"$fixture/powered-after"
  printf 's "AA:BB:CC:DD:EE:00"\n' >"$fixture/prop_org_bluez_hci0_Address"
  printf 's "AA:BB:CC:DD:EE:01"\n' >"$fixture/prop_org_bluez_hci1_Address"
}

audio_uuid='as 1 "0000110b-0000-1000-8000-00805f9b34fb"'
hid_uuid='as 1 "00001124-0000-1000-8000-00805f9b34fb"'
device=/org/bluez/hci0/dev_AA_BB_CC_DD_EE_FF

write_device() {
  local paired="$1" uuids="$2"
  printf '/org/bluez\n/org/bluez/hci0\n%s\n' "$device" >"$fixture/tree"
  printf 'b %s\n' "$paired" >"$fixture/prop_org_bluez_hci0_dev_AA_BB_CC_DD_EE_FF_Paired"
  printf '%s\n' "$uuids" >"$fixture/prop_org_bluez_hci0_dev_AA_BB_CC_DD_EE_FF_UUIDs"
}

assert_no_systemctl() {
  if grep -q '^systemctl ' "$log"; then
    fail "$1" "calls: $(<"$log")"
  fi
}

for version in 1.6.11 1.6.11-1 1.7.0 2.0.0; do
  reset_fixture
  write_device true "$audio_uuid"
  PIPEWIRE_VERSION="pipewire $version" run_sleep pre suspend
  assert_no_systemctl "PipeWire $version does not pause WirePlumber"
  if grep -q '^busctl ' "$log"; then
    fail "PipeWire $version does not inspect Bluetooth" "calls: $(<"$log")"
  fi
done
pass "a fixed PipeWire skips the suspend pause"

reset_fixture
printf 'tree-fail\n' >"$fixture/tree-fail"
PIPEWIRE_VERSION=1.6.10 run_sleep pre suspend
assert_no_systemctl "no Bluetooth service means suspend leaves WirePlumber running"
pass "no Bluetooth service means suspend leaves WirePlumber running"

reset_fixture
write_device true "$hid_uuid"
run_sleep pre suspend
assert_no_systemctl "a paired mouse does not pause WirePlumber"
pass "a paired mouse does not pause WirePlumber"

reset_fixture
write_device false "$audio_uuid"
run_sleep pre suspend
assert_no_systemctl "an unpaired headset does not pause WirePlumber"
pass "an unpaired headset does not pause WirePlumber"

reset_fixture
write_device true "$audio_uuid"
run_sleep pre suspend
grep -q 'systemctl --user --machine=1000@ mask --runtime wireplumber.service' "$log" ||
  fail "suspend masks the active user's WirePlumber" "calls: $(<"$log")"
grep -q 'systemctl --user --machine=1000@ stop wireplumber.service' "$log" ||
  fail "suspend stops WirePlumber after the mask" "calls: $(<"$log")"
mask_line=$(grep -n 'mask --runtime wireplumber.service' "$log" | head -1 | cut -d: -f1)
stop_line=$(grep -n 'stop wireplumber.service' "$log" | head -1 | cut -d: -f1)
(( mask_line < stop_line )) ||
  fail "the runtime mask is in place before WirePlumber is stopped" "calls: $(<"$log")"
grep -q '^uid 1000$' "$state" || fail "suspend records the paused user" "state: $(<"$state")"
grep -q '^uid 1001$' "$state" && fail "suspend does not record an inactive session" "state: $(<"$state")"
grep -q '^generation [0-9][0-9]*$' "$state" || fail "suspend records a generation" "state: $(<"$state")"
pass "suspend pauses WirePlumber when a paired audio device is connected"

reset_fixture
write_device true "$audio_uuid"
printf 'stop-fails\n' >"$fixture/systemctl-mode"
run_sleep pre suspend
grep -q 'kill --kill-whom=all --signal=KILL wireplumber.service' "$log" ||
  fail "a stuck stop is killed so suspend can proceed" "calls: $(<"$log")"
pass "a stuck stop is killed so suspend can proceed"

reset_fixture
write_device true "$audio_uuid"
printf 'mask-fails\n' >"$fixture/systemctl-mode"
if run_sleep pre suspend; then
  fail "a mask failure reports unsuccessful audio preparation"
fi
grep -q '^uid 1000$' "$state" ||
  fail "a failed mask is still recovered after resume" "state: $(<"$state")"
pass "a failed mask is still recovered after resume"

generation=$(awk '/^generation / { print $2 }' "$state")

: >"$log"
run_sleep recover 999
grep -q '^systemctl ' "$log" && fail "a stale restart does not unmask a newer hold" "calls: $(<"$log")"
grep -q '^uid 1000$' "$state" || fail "a stale restart leaves the current hold in place"
pass "a stale restart does not unmask a newer hold"

: >"$log"
rm -f "$fixture/powered-count"
printf '0\n' >"$fixture/powered-after"
run_sleep post suspend
grep -q 'systemctl --user --machine=1000@ unmask --runtime wireplumber.service' "$log" ||
  fail "resume unmasks WirePlumber" "calls: $(<"$log")"
grep -q 'systemctl --user --machine=1000@ restart wireplumber.service' "$log" ||
  fail "resume restarts WirePlumber after the adapter is powered" "calls: $(<"$log")"
[[ ! -e $state ]] || fail "resume clears the hold after restarting" "state: $(cat "$state" 2>/dev/null || true)"
grep -q '^sleep ' "$log" && fail "an already-powered adapter does not delay the restart" "calls: $(<"$log")"
pass "resume restarts WirePlumber once the adapter is powered"

reset_fixture
write_device true "$audio_uuid"
run_sleep pre suspend
generation=$(awk '/^generation / { print $2 }' "$state")
printf '2\n' >"$fixture/powered-after"
printf '0\n' >"$fixture/powered-count"
: >"$log"
run_sleep recover "$generation"
sleeps=$(grep -c '^sleep ' "$log" || true)
(( sleeps >= 2 )) || fail "resume waits while the adapter firmware is still loading" "sleeps: $sleeps calls: $(<"$log")"
grep -q 'restart wireplumber.service' "$log" ||
  fail "resume restarts after the adapter becomes powered" "calls: $(<"$log")"
pass "resume waits for the adapter firmware before restarting"

reset_fixture
write_device true "$audio_uuid"
run_sleep pre suspend
generation=$(awk '/^generation / { print $2 }' "$state")
printf 'bluetooth blocked blocked\n' >"$fixture/rfkill"
printf '99\n' >"$fixture/powered-after"
: >"$log"
OMARCHY_WIREPLUMBER_SLEEP_TRIES=4 run_sleep recover "$generation"
sleeps=$(grep -c '^sleep ' "$log" || true)
(( sleeps == 4 )) ||
  fail "a blocked adapter that is still present is given the full firmware wait" "sleeps: $sleeps"
pass "a blocked adapter that is still present is given the full firmware wait"

reset_fixture
printf '/org/bluez\n' >"$fixture/tree"
printf 'generation 7\nuid 1000\n' >"$state"
printf 'bluetooth blocked blocked\n' >"$fixture/rfkill"
: >"$log"
OMARCHY_WIREPLUMBER_SLEEP_TRIES=8 run_sleep recover 7
sleeps=$(grep -c '^sleep ' "$log" || true)
(( sleeps == 3 )) ||
  fail "a blocked radio with no controller does not wait out the firmware timeout" "sleeps: $sleeps calls: $(<"$log")"
grep -q 'restart wireplumber.service' "$log" ||
  fail "a blocked radio with no controller still restarts WirePlumber" "calls: $(<"$log")"
pass "a blocked radio with no controller restarts WirePlumber without the full wait"

reset_fixture
printf 'generation 42\nuid 1000\n' >"$state"
printf 'tree-fail\n' >"$fixture/tree-fail"
printf 'restart-fails\n' >"$fixture/systemctl-mode"
if PIPEWIRE_VERSION=1.6.11 run_sleep pre suspend; then
  fail "failed previous recovery is reported"
fi
grep -q 'unmask --runtime wireplumber.service' "$log" ||
  fail "a fixed PipeWire still releases a pause left from the previous version" "calls: $(<"$log")"
grep -q '^uid 1000$' "$state" ||
  fail "a failed release is written back for the next resume" "state: $(cat "$state" 2>/dev/null || true)"
grep -q ' mask --runtime wireplumber.service' "$log" &&
  fail "a fixed PipeWire does not pause WirePlumber again" "calls: $(<"$log")"
pass "a fixed PipeWire releases an earlier pause and does not take a new one"

# Tree output without --list still carries the adapter path in the drawing.
reset_fixture
printf '└─/org/bluez\n  ├─/org/bluez/hci0\n  │ └─%s\n' "$device" >"$fixture/tree"
printf 'no-list\n' >"$fixture/no-list"
printf 'b true\n' >"$fixture/prop_org_bluez_hci0_dev_AA_BB_CC_DD_EE_FF_Paired"
printf '%s\n' "$audio_uuid" >"$fixture/prop_org_bluez_hci0_dev_AA_BB_CC_DD_EE_FF_UUIDs"
run_sleep pre suspend
grep -q '^uid 1000$' "$state" ||
  fail "adapter paths are found without busctl --list" "calls: $(<"$log") state: $(cat "$state" 2>/dev/null || true)"
pass "adapter paths are found without busctl --list"

# A pending recovery user is stopped and therefore absent from is-active.
reset_fixture
write_device true "$audio_uuid"
printf 'generation 42\nuid 1000\ncontroller AA:BB:CC:DD:EE:00\n' >"$state"
printf 'restart-fails\n' >"$fixture/systemctl-mode"
printf 'inactive\n' >"$fixture/inactive"
run_sleep pre suspend
generation=$(awk '/^generation / { print $2 }' "$state")
grep -q '^uid 1000$' "$state" || fail "a stopped recovery user survives a new sleep generation"
[[ $generation != 42 ]] || fail "a new sleep invalidates the previous generation"
run_sleep recover 42
assert_no_systemctl "old recovery cannot touch the carried hold"
if run_sleep recover "$generation"; then
  fail "restart failure is reported"
fi
grep -q '^uid 1000$' "$state" || fail "failed restart stays pending"
rm "$fixture/systemctl-mode"
run_sleep recover "$generation"
[[ ! -e $state ]] || fail "successful retry clears pending recovery"
pass "failed recovery survives a new sleep and is retried"

reset_fixture
write_device true "$audio_uuid"
printf '/org/bluez/hci1\n' >>"$fixture/tree"
run_sleep pre suspend
generation=$(awk '/^generation / { print $2 }' "$state")
printf '6\n' >"$fixture/powered-after-hci1"
OMARCHY_WIREPLUMBER_SLEEP_TRIES=8 run_sleep recover "$generation"
sleeps=$(grep -c '^sleep ' "$log" || true)
(( sleeps >= 3 )) || fail "a powered controller cannot release a resetting second controller" "calls: $(<"$log")"
grep -q 'restart wireplumber.service' "$log" || fail "all powered controllers release recovery"
pass "recovery waits for every controller"

reset_fixture
write_device true "$audio_uuid"
printf '/org/bluez/hci1\n' >>"$fixture/tree"
run_sleep pre suspend
generation=$(awk '/^generation / { print $2 }' "$state")
# The missing adapter's address must not be replaced by the remaining one.
printf '/org/bluez/hci0\n' >"$fixture/tree"
OMARCHY_WIREPLUMBER_SLEEP_TRIES=5 run_sleep recover "$generation"
sleeps=$(grep -c '^sleep ' "$log" || true)
(( sleeps == 5 )) || fail "a disappeared recorded controller gets the full bounded wait" "calls: $(<"$log")"
pass "missing recorded controllers cannot release another controller's hold"

for radio in 'bluetooth blocked unblocked' 'bluetooth unblocked blocked'; do
  reset_fixture
  printf '/org/bluez\n' >"$fixture/tree"
  printf 'generation 7\nuid 1000\n' >"$state"
  printf '%s\n' "$radio" >"$fixture/rfkill"
  OMARCHY_WIREPLUMBER_SLEEP_TRIES=8 run_sleep recover 7
  sleeps=$(grep -c '^sleep ' "$log" || true)
  (( sleeps == 3 )) || fail "either rfkill block shortens an absent-controller wait" "radio: $radio; calls: $(<"$log")"
done
pass "software and hardware rfkill blocks are read independently"

reset_fixture
printf '/org/bluez\n' >"$fixture/tree"
printf 'generation 7\nuid 1000\n' >"$state"
printf 'bluetooth blocked unblocked\nbluetooth unblocked unblocked\n' >"$fixture/rfkill"
OMARCHY_WIREPLUMBER_SLEEP_TRIES=5 run_sleep recover 7
sleeps=$(grep -c '^sleep ' "$log" || true)
(( sleeps == 5 )) || fail "one unblocked radio retains the bounded wait"
pass "one blocked radio cannot release an unblocked missing controller"

reset_fixture
write_device true "$audio_uuid"
run_sleep pre suspend
generation=$(awk '/^generation / { print $2 }' "$state")
printf 'unmask-fails\n' >"$fixture/systemctl-mode"
if run_sleep recover "$generation"; then
  fail "unmask failure is reported"
fi
grep -q '^uid 1000$' "$state" || fail "unmask failure stays pending"
grep -q 'restart wireplumber.service' "$log" && fail "masked service is not restarted"
pass "unmask failure remains recoverable"

reset_fixture
printf '/org/bluez\n' >"$fixture/tree"
printf 'generation 7\nuid 1000;touch /tmp/unsafe\nuid invalid\nuid 1000\n' >"$state"
run_sleep recover 7
grep -q 'systemctl --user --machine=1000@ restart wireplumber.service' "$log" || fail "numeric user is recovered"
grep -E 'systemctl.*(invalid|touch)' "$log" && fail "invalid state user is never sent to systemctl"
pass "recovery accepts only numeric user records"

reset_fixture
write_device true "$audio_uuid"
run_sleep pre suspend
generation=$(awk '/^generation / { print $2 }' "$state")
# BlueZ may assign a different hci index to the same physical controller.
printf '/org/bluez/hci3\n' >"$fixture/tree"
printf 's "AA:BB:CC:DD:EE:00"\n' >"$fixture/prop_org_bluez_hci3_Address"
run_sleep recover "$generation"
grep -q '^sleep ' "$log" && fail "controller identity survives hci renumbering"
[[ ! -e $state ]] || fail "renumbered powered controller releases recovery"
pass "controller addresses survive hci renumbering"


reset_fixture
printf '/org/bluez\n' >"$fixture/tree"
printf 'generation 7\nuid 1000\n' >"$state"
printf 'unmask-fails\n' >"$fixture/systemctl-mode"
# /dev/full rejects writes. Only the scratch temporary path points to it.
ln -s /dev/full "${state}.tmp"
if run_sleep recover 7; then
  fail "failed state write is reported"
fi
[[ -f $state && ! -L $state ]] || fail "failed write never publishes the temporary symlink"
if ! grep -q '^generation 7$' "$state" || ! grep -q '^uid 1000$' "$state"; then
  fail "failed write preserves the complete earlier recovery record"
fi
pass "failed state write cannot replace a good recovery record"


reset_fixture
printf 'generation 7\nuid 1000\n' >"$state"
printf 'tree-fail\n' >"$fixture/tree-fail"
printf 'bluetooth blocked unblocked\n' >"$fixture/rfkill"
OMARCHY_WIREPLUMBER_SLEEP_TRIES=5 run_sleep recover 7
sleeps=$(grep -c '^sleep ' "$log" || true)
(( sleeps == 5 )) || fail "unavailable BlueZ cannot prove controller nodes disappeared"
pass "a BlueZ query failure keeps the full bounded recovery wait"
