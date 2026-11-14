#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

sleep_monitor="$ROOT/bin/omarchy-system-sleep-monitor"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
mock_omarchy="$tmpdir/omarchy"
producer_pid_file="$tmpdir/producer-pid"
lock_log="$tmpdir/lock-log"
mkdir -p "$mock_bin" "$mock_omarchy/bin"

cat >"$mock_bin/systemd-inhibit" <<'SH'
#!/bin/bash

while [[ $1 == --* ]]; do
  shift
done

exec "$@"
SH

cat >"$mock_bin/dbus-monitor" <<'SH'
#!/bin/bash

echo "$$" >"$PRODUCER_PID_FILE"
printf '   boolean true\n'
exec sleep 30
SH

cat >"$mock_omarchy/bin/omarchy-system-sleep-lock" <<'SH'
#!/bin/bash

echo locked >>"$LOCK_LOG"
SH

# The monitor reads logind's and systemd-sleep's journal lines; the real
# journal must never decide a test.
cat >"$mock_bin/journalctl" <<'SH'
#!/bin/bash

case " $* " in
  *" systemd-logind "*) [[ -n ${LOGIND_LINE:-} ]] && echo "$LOGIND_LINE" ;;
  *" systemd-sleep "*) [[ -n ${SLEEP_LINE:-} ]] && echo "$SLEEP_LINE" ;;
esac
exit 0
SH

cat >"$mock_bin/systemd-run" <<'SH'
#!/bin/bash

echo "$*" >>"$GUARD_LOG"
SH

cat >"$mock_bin/busctl" <<'SH'
#!/bin/bash

echo "b true"
SH

cat >"$mock_omarchy/bin/omarchy-system-lock" <<'SH'
#!/bin/bash

echo guard-locked >>"$LOCK_LOG"
SH

cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
SH

cat >"$mock_bin/omarchy-i18n" <<'SH'
#!/bin/bash

echo "$1"
SH

chmod +x \
  "$mock_bin/systemd-inhibit" \
  "$mock_bin/dbus-monitor" \
  "$mock_bin/journalctl" \
  "$mock_bin/systemd-run" \
  "$mock_bin/busctl" \
  "$mock_bin/omarchy-notification-send" \
  "$mock_bin/omarchy-i18n" \
  "$mock_omarchy/bin/omarchy-system-sleep-lock" \
  "$mock_omarchy/bin/omarchy-system-lock"
ln -s "$sleep_monitor" "$mock_omarchy/bin/omarchy-system-sleep-monitor"

# A hibernation resume device on LUKS, as the initramfs encrypt hook opens it.
sys_power="$tmpdir/sys-power"
sys_dev_block="$tmpdir/sys-dev-block"
cmdline_file="$tmpdir/cmdline"
guard_log="$tmpdir/guard-log"
mkdir -p "$sys_power" "$sys_dev_block/254:0/dm"
echo "254:0" >"$sys_power/resume"
echo "CRYPT-LUKS2-0123456789abcdef-root" >"$sys_dev_block/254:0/dm/uuid"
echo "cryptdevice=UUID=abc:root root=/dev/mapper/root resume=/dev/mapper/root resume_offset=1" >"$cmdline_file"

start_us=${EPOCHREALTIME//[!0-9]/}
OMARCHY_PATH="$mock_omarchy" \
  PATH="$mock_bin:$PATH" \
  PRODUCER_PID_FILE="$producer_pid_file" \
  LOCK_LOG="$lock_log" \
  "$sleep_monitor"
elapsed_us=$((10#${EPOCHREALTIME//[!0-9]/} - 10#$start_us))

[[ $(<"$lock_log") == "locked" ]] ||
  fail "sleep monitor invokes the lock helper for a sleep event"
pass "sleep monitor invokes the lock helper for a sleep event"

(( elapsed_us < 2000000 )) ||
  fail "sleep monitor releases the inhibitor after locking" "elapsed: ${elapsed_us}us"
pass "sleep monitor releases the inhibitor after locking"

producer_pid=$(<"$producer_pid_file")
if kill -0 "$producer_pid" 2>/dev/null; then
  fail "sleep monitor reaps its event producer" "producer still running: $producer_pid"
fi
pass "sleep monitor reaps its event producer"

# Terminating the monitor must also clean up the producer instead of orphaning
# it under the user systemd instance.
cat >"$mock_bin/dbus-monitor" <<'SH'
#!/bin/bash

sleep 0.1
echo "$$" >"$PRODUCER_PID_FILE"
exec sleep 30
SH
chmod +x "$mock_bin/dbus-monitor"
rm -f "$producer_pid_file"

OMARCHY_PATH="$mock_omarchy" \
  PATH="$mock_bin:$PATH" \
  PRODUCER_PID_FILE="$producer_pid_file" \
  LOCK_LOG="$lock_log" \
  "$sleep_monitor" &
monitor_pid=$!

for _ in {1..100}; do
  [[ -s $producer_pid_file ]] && break
  sleep 0.01
done
if [[ ! -s $producer_pid_file ]]; then
  kill "$monitor_pid" 2>/dev/null || true
  wait "$monitor_pid" 2>/dev/null || true
  fail "sleep monitor starts its event producer"
fi

producer_pid=$(<"$producer_pid_file")
kill "$monitor_pid"
wait "$monitor_pid" 2>/dev/null || true

if kill -0 "$producer_pid" 2>/dev/null; then
  kill "$producer_pid" 2>/dev/null || true
  fail "sleep monitor cleans up its producer when terminated" "producer still running: $producer_pid"
fi
pass "sleep monitor cleans up its producer when terminated"

# Hibernate: resume asks for the disk passphrase, so the lock screen is skipped
# and a guard is started instead. A keyfile unlock keeps the lock.
cat >"$mock_bin/dbus-monitor" <<'SH'
#!/bin/bash

printf '   boolean true\n'
exec sleep 30
SH
chmod +x "$mock_bin/dbus-monitor"

run_sleep_event() {
  : >"$lock_log"
  : >"$guard_log"
  OMARCHY_PATH="$mock_omarchy" \
    PATH="$mock_bin:$PATH" \
    LOCK_LOG="$lock_log" \
    GUARD_LOG="$guard_log" \
    LOGIND_LINE="$1" \
    OMARCHY_SYS_POWER_PATH="$sys_power" \
    OMARCHY_SYS_DEV_BLOCK_PATH="$sys_dev_block" \
    OMARCHY_PROC_CMDLINE_PATH="$cmdline_file" \
    "$sleep_monitor" 2>/dev/null
}

run_sleep_event "The system will hibernate now!"
[[ ! -s $lock_log && $(<"$guard_log") == *"--hibernate-guard"* ]] ||
  fail "hibernate onto a passphrase LUKS resume device skips the lock and starts the guard" "lock: $(<"$lock_log") guard: $(<"$guard_log")"
pass "hibernate onto a passphrase LUKS resume device skips the lock and starts the guard"

echo "cryptdevice=UUID=abc:root cryptkey=rootfs:/etc/keyfile root=/dev/mapper/root" >"$cmdline_file"
run_sleep_event "The system will hibernate now!"
[[ $(<"$lock_log") == "locked" && ! -s $guard_log ]] ||
  fail "hibernate with a keyfile unlock still locks" "lock: $(<"$lock_log") guard: $(<"$guard_log")"
pass "hibernate with a keyfile unlock still locks"

# The guard locks unless systemd-sleep reports a real restore from the image.
cat >"$mock_bin/dbus-monitor" <<'SH'
#!/bin/bash

printf '   boolean false\n'
exec sleep 30
SH
chmod +x "$mock_bin/dbus-monitor"

run_guard() {
  : >"$lock_log"
  OMARCHY_PATH="$mock_omarchy" \
    PATH="$mock_bin:$PATH" \
    LOCK_LOG="$lock_log" \
    SLEEP_LINE="$1" \
    "$sleep_monitor" --hibernate-guard
}

run_guard "Failed to put system to sleep. System resumed again: Device or resource busy"
[[ $(<"$lock_log") == "guard-locked" ]] ||
  fail "hibernate guard locks when the hibernate failed" "lock: $(<"$lock_log")"
pass "hibernate guard locks when the hibernate failed"

run_guard "System returned from sleep operation 'hibernate'."
[[ ! -s $lock_log ]] ||
  fail "hibernate guard leaves a restored session alone" "lock: $(<"$lock_log")"
pass "hibernate guard leaves a restored session alone"
