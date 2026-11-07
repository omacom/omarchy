#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

cmd="$ROOT/bin/omarchy-system-sleep-wireplumber"
hook="$ROOT/default/systemd/system-sleep/wireplumber-bluetooth"
installer="$ROOT/install/config/wireplumber-sleep.sh"
migration="$ROOT/migrations/1794058100.sh"
autoconnect="$ROOT/config/wireplumber/wireplumber.conf.d/bluetooth-a2dp-autoconnect.conf"

bash -n "$cmd"
pass "wireplumber sleep command parses"

[[ -x $cmd ]] || fail "wireplumber sleep command is executable"
pass "wireplumber sleep command is executable"

[[ -x $hook ]] || fail "wireplumber sleep hook is executable" "mode: $(stat -c '%A' "$hook")"
pass "wireplumber sleep hook is executable"

grep -q 'bluez5.auto-connect' "$autoconnect" ||
  fail "shipped Bluetooth auto-connect config remains in place"
pass "shipped Bluetooth auto-connect config remains in place"

grep -Fq 'config/wireplumber-sleep.sh' "$ROOT/install/config/all.sh" ||
  fail "system setup publishes the wireplumber sleep hook"
pass "system setup publishes the wireplumber sleep hook"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# The trampoline is what systemd executes. Point a copy at a stub so the
# checkout's absolute path can be checked without calling a system binary.
stub_cmd="$tmpdir/stub-cmd"
stub_args="$tmpdir/stub-args"
cat >"$stub_cmd" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$STUB_ARGS"
exit 0
SH
chmod +x "$stub_cmd"

hook_copy="$tmpdir/hook"
sed "s|/usr/bin/omarchy-system-sleep-wireplumber|$stub_cmd|" "$hook" >"$hook_copy"
chmod +x "$hook_copy"
STUB_ARGS="$stub_args" "$hook_copy" pre suspend
[[ $(<"$stub_args") == "pre suspend" ]] ||
  fail "sleep hook forwards systemd's arguments" "args: $(<"$stub_args")"
pass "sleep hook forwards systemd's arguments"

missing_hook="$tmpdir/hook-missing"
sed 's|/usr/bin/omarchy-system-sleep-wireplumber|/no/such/omarchy-system-sleep-wireplumber|' "$hook" >"$missing_hook"
chmod +x "$missing_hook"
"$missing_hook" pre suspend
pass "sleep hook exits clean when its command is not installed"

# install/config is sourced with bash -eE, the same way run_logged runs it.
install_dst="$tmpdir/installed-hook"
OMARCHY_PATH="$ROOT" \
  OMARCHY_WIREPLUMBER_SLEEP_HOOK_DST="$install_dst" \
  bash -eE -c 'source "$1"' bash "$installer"
[[ -x $install_dst ]] || fail "setup installs the hook executable"
cmp -s "$hook" "$install_dst" || fail "setup installs the shipped hook"
OMARCHY_PATH="$ROOT" \
  OMARCHY_WIREPLUMBER_SLEEP_HOOK_DST="$install_dst" \
  bash -eE -c 'source "$1"' bash "$installer"
pass "setup installs the shipped hook and leaves an existing copy"

if OMARCHY_PATH="$ROOT" \
  OMARCHY_WIREPLUMBER_SLEEP_HOOK_SRC="$tmpdir/missing-hook" \
  OMARCHY_WIREPLUMBER_SLEEP_HOOK_DST="$tmpdir/should-not-exist" \
  bash -eE -c 'source "$1"' bash "$installer"; then
  fail "setup fails when the hook source is missing"
fi
[[ ! -e $tmpdir/should-not-exist ]] || fail "setup writes nothing when the source is missing"
pass "setup fails when the hook source is missing"

sudo_log="$tmpdir/sudo-log"
stub_bin="$tmpdir/bin"
mkdir -p "$stub_bin"
cat >"$stub_bin/sudo" <<SH
#!/bin/bash
printf '%s\n' "\$*" >>"$sudo_log"
exec "\$@"
SH
chmod +x "$stub_bin/sudo"

run_migration() {
  PATH="$stub_bin:$PATH" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_WIREPLUMBER_SLEEP_HOOK_SRC="${1:-$hook}" \
    OMARCHY_WIREPLUMBER_SLEEP_HOOK_DST="${2:-$tmpdir/migration-hook}" \
    bash -euo pipefail "$migration" >/dev/null
}

: >"$sudo_log"
run_migration
[[ -x $tmpdir/migration-hook ]] || fail "migration installs the hook executable"
cmp -s "$hook" "$tmpdir/migration-hook" || fail "migration installs the shipped hook"
grep -q 'install -Dm755' "$sudo_log" || fail "migration installs through sudo" "sudo: $(<"$sudo_log")"
pass "migration installs the shipped hook through sudo"

: >"$sudo_log"
run_migration
[[ -z $(<"$sudo_log") ]] || fail "migration does not rewrite an identical hook" "sudo: $(<"$sudo_log")"
pass "migration does not rewrite an identical hook"

if run_migration "$tmpdir/missing-hook" "$tmpdir/migration-missing"; then
  fail "migration stays pending when the hook source is missing"
fi
pass "migration stays pending when the hook source is missing"

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
  *1000@*is-active*|*is-active*1000@*) exit 0 ;;
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
chmod +x "$stub_bin"/*

user_run="$tmpdir/run"
python3 - "$user_run" <<'PY'
import os, socket, sys
root = sys.argv[1]
for uid in ("1000", "1001"):
    path = os.path.join(root, uid)
    os.makedirs(path, exist_ok=True)
    sock = socket.socket(socket.AF_UNIX)
    sock.bind(os.path.join(path, "bus"))
PY

state="$tmpdir/state/uids"
run_sleep() {
  : >"$log"
  PATH="$stub_bin:$PATH" \
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
run_sleep pre suspend
grep -q '^uid 1000$' "$state" ||
  fail "a failed mask is still recovered after resume" "state: $(<"$state")"
pass "a failed mask is still recovered after resume"

generation=$(awk '/^generation / { print $2 }' "$state")
: >"$log"
run_sleep post suspend
grep -q "^systemd-run --quiet --no-block --collect --on-active=1s --timer-property=AccuracySec=100ms $cmd recover $generation$" "$log" ||
  fail "resume schedules one restart for this sleep generation" "calls: $(<"$log")"
grep -q '^systemctl ' "$log" && fail "resume scheduling does not touch user services while they are frozen" "calls: $(<"$log")"
pass "resume schedules the restart outside the sleep hook"

: >"$log"
run_sleep recover 999
grep -q '^systemctl ' "$log" && fail "a stale restart does not unmask a newer hold" "calls: $(<"$log")"
grep -q '^uid 1000$' "$state" || fail "a stale restart leaves the current hold in place"
pass "a stale restart does not unmask a newer hold"

: >"$log"
rm -f "$fixture/powered-count"
printf '0\n' >"$fixture/powered-after"
run_sleep recover "$generation"
grep -q 'systemctl --user --machine=1000@ unmask --runtime wireplumber.service' "$log" ||
  fail "resume unmasks WirePlumber" "calls: $(<"$log")"
grep -q 'systemctl --user --machine=1000@ restart wireplumber.service' "$log" ||
  fail "resume restarts WirePlumber after the adapter is powered" "calls: $(<"$log")"
[[ ! -e $state ]] || fail "resume clears the hold after restarting" "state: $(<"$state" 2>/dev/null || true)"
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
PIPEWIRE_VERSION=1.6.11 run_sleep pre suspend
grep -q 'unmask --runtime wireplumber.service' "$log" ||
  fail "a fixed PipeWire still releases a pause left from the previous version" "calls: $(<"$log")"
grep -q '^uid 1000$' "$state" ||
  fail "a failed release is written back for the next resume" "state: $(<"$state" 2>/dev/null || true)"
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
  fail "adapter paths are found without busctl --list" "calls: $(<"$log") state: $(<"$state" 2>/dev/null || true)"
pass "adapter paths are found without busctl --list"
