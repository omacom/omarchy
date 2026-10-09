#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

test_home="$tmp_dir/home"
devices="$tmp_dir/sysfs/devices"
stub_bin="$tmp_dir/bin"
notify_log="$tmp_dir/notify.log"
boltctl_log="$tmp_dir/boltctl.log"
state="$test_home/.local/state/omarchy/thunderbolt/notified"

mkdir -p "$test_home" "$devices" "$stub_bin"

# --- stubs ---------------------------------------------------------------

cat >"$stub_bin/omarchy-notification-wait" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$stub_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf 'SEND: %s\n' "$*" >>"$OMARCHY_TEST_NOTIFY_LOG"
[[ ${OMARCHY_TEST_NOTIFY_FAIL:-0} == 1 ]] && exit 1
exit 0
SH

# gum choose returns the choice under test (or exits non-zero on cancellation,
# the way Esc and Ctrl-C do); gum style echoes its message so the menu's output
# can be asserted on.
cat >"$stub_bin/gum" <<'SH'
#!/bin/bash
if [[ ${1:-} == "choose" ]]; then
  [[ ${OMARCHY_TEST_GUM_CANCEL:-0} == 1 ]] && exit 130
  printf '%s\n' "${OMARCHY_TEST_GUM_CHOICE:-Skip}"
  exit 0
fi
[[ $# -gt 0 ]] && printf '%s\n' "${!#}"
exit 0
SH

# A successful authorize/enroll flips the device's authorized attribute, the way
# the kernel does after boltctl returns; when told to vanish it removes the
# device instead, standing in for an unplug mid-action.
cat >"$stub_bin/boltctl" <<'SH'
#!/bin/bash
printf 'BOLTCTL: %s\n' "$*" >>"$OMARCHY_TEST_BOLTCTL_LOG"
case ${1:-} in
list) exit 0 ;;
authorize | enroll)
  [[ ${OMARCHY_TEST_BOLTCTL_OK:-1} == 1 ]] || exit 1
  if [[ -n ${OMARCHY_TEST_DEVICE_AUTHORIZED_FILE:-} ]]; then
    if [[ ${OMARCHY_TEST_DEVICE_VANISH:-0} == 1 ]]; then
      rm -rf "$(dirname "$OMARCHY_TEST_DEVICE_AUTHORIZED_FILE")"
    else
      printf '1\n' >"$OMARCHY_TEST_DEVICE_AUTHORIZED_FILE"
    fi
  fi
  exit 0
  ;;
esac
exit 0
SH

# The reviewer waits a second for sysfs to settle; the tests do not need to.
cat >"$stub_bin/sleep" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$stub_bin"/*

# --- helpers -------------------------------------------------------------

make_device() {
  local dir="$1"
  local uid="$2"
  local name="${3:-}"

  mkdir -p "$devices/$dir"
  printf '0\n' >"$devices/$dir/authorized"
  printf '%s\n' "$uid" >"$devices/$dir/unique_id"
  if [[ -n $name ]]; then
    printf '%s\n' "$name" >"$devices/$dir/device_name"
  fi
  printf 'SomeVendor\n' >"$devices/$dir/vendor_name"
  printf '4\n' >"$devices/$dir/generation"
}

reset_devices() {
  rm -rf "$devices"
  mkdir -p "$devices"
}

reset_state() { rm -rf "$test_home/.local/state"; }

reset_logs() {
  : >"$notify_log"
  : >"$boltctl_log"
}

run_check() {
  HOME="$test_home" \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  OMARCHY_THUNDERBOLT_DEVICES_PATH="$devices" \
  OMARCHY_TEST_NOTIFY_LOG="$notify_log" \
  OMARCHY_TEST_NOTIFY_FAIL="${OMARCHY_TEST_NOTIFY_FAIL:-0}" \
    "$ROOT/bin/omarchy-thunderbolt-check"
}

run_menu() {
  HOME="$test_home" \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  OMARCHY_THUNDERBOLT_DEVICES_PATH="$devices" \
  OMARCHY_TEST_NOTIFY_LOG="$notify_log" \
  OMARCHY_TEST_BOLTCTL_LOG="$boltctl_log" \
  OMARCHY_TEST_BOLTCTL_OK="${OMARCHY_TEST_BOLTCTL_OK:-1}" \
  OMARCHY_TEST_DEVICE_AUTHORIZED_FILE="${OMARCHY_TEST_DEVICE_AUTHORIZED_FILE:-}" \
  OMARCHY_TEST_DEVICE_VANISH="${OMARCHY_TEST_DEVICE_VANISH:-0}" \
  OMARCHY_TEST_GUM_CHOICE="${OMARCHY_TEST_GUM_CHOICE:-Skip}" \
  OMARCHY_TEST_GUM_CANCEL="${OMARCHY_TEST_GUM_CANCEL:-0}" \
    "$ROOT/bin/omarchy-thunderbolt" "$@"
}

# One waiting device plus its recorded notification.
arm() {
  reset_devices
  make_device 01-03 "04:22:05:01:00:00" "CalDigit TS4"
  mkdir -p "$(dirname "$state")"
  printf '04:22:05:01:00:00\n' >"$state"
  reset_logs
}

# --- scanner: detection --------------------------------------------------

reset_state
reset_devices
reset_logs
make_device 01-03 "04:22:05:01:00:00" "CalDigit TS4"
run_check >/dev/null 2>&1
grep -q 'SEND: .*Thunderbolt device waiting for authorization' "$notify_log" ||
  fail "scanner notifies an unauthorized device"
grep -q 'SomeVendor CalDigit TS4 connected' "$notify_log" ||
  fail "scanner names the vendor and device in the toast"
grep -q '04:22:05:01:00:00' "$state" ||
  fail "scanner records the notified device"
pass "scanner notifies an unauthorized device and records it"

reset_logs
run_check >/dev/null 2>&1
[[ ! -s $notify_log ]] ||
  fail "scanner does not re-notify a device that stays connected"
pass "scanner stays quiet while the device remains connected"

rm -rf "$devices/01-03"
run_check >/dev/null 2>&1
[[ ! -s $state ]] ||
  fail "scanner prunes the id of an unplugged device"
pass "scanner prunes an unplugged device"

make_device 01-03 "04:22:05:01:00:00" "CalDigit TS4"
reset_logs
run_check >/dev/null 2>&1
grep -q 'CalDigit TS4 connected' "$notify_log" ||
  fail "scanner notifies again after a replug"
pass "scanner notifies again after a replug"

# A stored (already authorized) device is no longer waiting: its stale id is
# pruned rather than resurrected -- the merge the shared lock protects.
printf '1\n' >"$devices/01-03/authorized"
run_check >/dev/null 2>&1
[[ ! -s $state ]] ||
  fail "scanner prunes a device that became authorized"
pass "scanner prunes a device that became authorized"

# --- scanner: names and retries ------------------------------------------

reset_state
reset_devices
reset_logs
make_device 09-99 "aa:bb:cc:dd:ee:ff" ""
run_check >/dev/null 2>&1
grep -q 'aa:bb:cc:dd:ee:ff' "$notify_log" ||
  fail "scanner falls back to the unique id when device_name is absent"
pass "scanner falls back to the unique id for a nameless device"

reset_state
reset_logs
printf '\n' >"$devices/09-99/device_name"
run_check >/dev/null 2>&1
grep -q 'aa:bb:cc:dd:ee:ff' "$notify_log" ||
  fail "scanner falls back to the unique id when device_name is empty"
pass "scanner falls back to the unique id for an empty name"

reset_state
reset_devices
reset_logs
make_device 01-03 "04:22:05:01:00:00" "CalDigit TS4"
OMARCHY_TEST_NOTIFY_FAIL=1 run_check >/dev/null 2>&1
[[ ! -s $state ]] ||
  fail "scanner does not record a device whose toast failed"
reset_logs
run_check >/dev/null 2>&1
grep -q 'CalDigit TS4 connected' "$notify_log" ||
  fail "scanner retries a device after a failed toast"
grep -q '04:22:05:01:00:00' "$state" ||
  fail "scanner records the device once the retry succeeds"
pass "scanner retries a failed notification instead of silencing the device"

# --- scanner: merge preserves unrelated on-disk ids ----------------------

reset_state
reset_devices
mkdir -p "$(dirname "$state")"
printf 'still-waiting\n' >"$state"
make_device 01-03 "04:22:05:01:00:00" "CalDigit TS4"
make_device 02-04 "still-waiting" "Second dock"
run_check >/dev/null 2>&1
grep -q 'still-waiting' "$state" ||
  fail "scanner keeps an id for a device that is still unauthorized"
grep -q '04:22:05:01:00:00' "$state" ||
  fail "scanner adds a new id alongside existing state"
pass "scanner merges new ids into the on-disk state"

# --- scanner: no bus -----------------------------------------------------

out=$(OMARCHY_THUNDERBOLT_DEVICES_PATH="$tmp_dir/absent" \
  HOME="$test_home" PATH="$stub_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-thunderbolt-check" 2>&1) && rc=0 || rc=$?
(( rc == 0 )) || fail "scanner exits 0 when there is no Thunderbolt bus"
[[ -z $out ]] || fail "scanner stays quiet when there is no Thunderbolt bus"
pass "scanner exits quietly without a Thunderbolt bus"

# --- reviewer: menu choices ----------------------------------------------

arm
OMARCHY_TEST_GUM_CHOICE="Skip" run_menu >/dev/null 2>&1
[[ ! -s $boltctl_log ]] ||
  fail "Skip runs no authorizing boltctl call"
grep -q '04:22:05:01:00:00' "$state" ||
  fail "Skip leaves the notified state alone"
pass "Skip makes no boltctl call and keeps the state"

arm
out=$(OMARCHY_TEST_GUM_CANCEL=1 run_menu 2>&1) && rc=0 || rc=$?
(( rc == 0 )) || fail "a cancelled menu exits cleanly"
[[ ! -s $boltctl_log ]] ||
  fail "a cancelled menu runs no boltctl call"
pass "a cancelled menu exits cleanly without authorizing"

arm
out=$(OMARCHY_TEST_GUM_CHOICE="Authorize for this session" \
  OMARCHY_TEST_DEVICE_AUTHORIZED_FILE="$devices/01-03/authorized" \
  run_menu 2>&1) || true
grep -q 'BOLTCTL: authorize 04:22:05:01:00:00' "$boltctl_log" ||
  fail "session option runs boltctl authorize"
grep -q 'is authorized for this system' <<<"$out" ||
  fail "session option reports success once sysfs shows the device authorized"
[[ ! -s $state ]] ||
  fail "session option drops the device from the notified state"
pass "session authorization calls boltctl authorize and clears the state"

arm
OMARCHY_TEST_GUM_CHOICE="Authorize permanently (enroll)" \
  OMARCHY_TEST_DEVICE_AUTHORIZED_FILE="$devices/01-03/authorized" \
  run_menu >/dev/null 2>&1
grep -q 'BOLTCTL: enroll 04:22:05:01:00:00' "$boltctl_log" ||
  fail "enroll option runs boltctl enroll"
pass "enroll option runs boltctl enroll"

arm
out=$(OMARCHY_TEST_BOLTCTL_OK=0 OMARCHY_TEST_GUM_CHOICE="Authorize for this session" \
  run_menu 2>&1) || true
grep -q 'Failed to authorize' <<<"$out" ||
  fail "a failed authorization is reported"
grep -q '04:22:05:01:00:00' "$state" ||
  fail "a failed authorization keeps the notified id"
pass "a failed authorization is reported and keeps the state"

# boltctl claims success, but the device is gone before the sysfs confirmation:
# the read fails, so the action counts as unsuccessful and the id stays.
arm
out=$(OMARCHY_TEST_DEVICE_AUTHORIZED_FILE="$devices/01-03/authorized" \
  OMARCHY_TEST_DEVICE_VANISH=1 \
  OMARCHY_TEST_GUM_CHOICE="Authorize for this session" run_menu 2>&1) || true
grep -q 'Failed to authorize' <<<"$out" ||
  fail "an unreadable sysfs state after the action is treated as failure"
grep -q '04:22:05:01:00:00' "$state" ||
  fail "an unreadable authorization state keeps the notified id"
pass "an unreadable authorization state is treated as failure"

reset_devices
out=$(run_menu 2>&1) || true
grep -q 'No Thunderbolt devices waiting for authorization.' <<<"$out" ||
  fail "menu reports when nothing is waiting"
pass "menu reports when nothing is waiting"
