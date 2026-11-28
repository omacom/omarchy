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

chmod +x \
  "$mock_bin/systemd-inhibit" \
  "$mock_bin/dbus-monitor" \
  "$mock_omarchy/bin/omarchy-system-sleep-lock"
ln -s "$sleep_monitor" "$mock_omarchy/bin/omarchy-system-sleep-monitor"

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

# A restart during the sleep transition is rejected by logind. Retry that
# rejection in-process so the unit does not record a failure.
cat >"$mock_bin/systemd-inhibit" <<'SH'
#!/bin/bash

while [[ $1 == --* ]]; do
  shift
done

attempts_file="$INHIBIT_ATTEMPTS"
attempts=0
[[ -f $attempts_file ]] && attempts=$(<"$attempts_file")
attempts=$((attempts + 1))
printf '%s\n' "$attempts" >"$attempts_file"
if (( attempts == 1 )); then
  echo "Failed to inhibit: The operation inhibition has been requested for is already running" >&2
  exit 1
fi

exec "$@"
SH
chmod +x "$mock_bin/systemd-inhibit"
: >"$lock_log"
rm -f "$producer_pid_file"

cat >"$mock_bin/dbus-monitor" <<'SH'
#!/bin/bash

echo "$$" >"$PRODUCER_PID_FILE"
printf '   boolean true\n'
exec sleep 30
SH
chmod +x "$mock_bin/dbus-monitor"

inhibit_attempts="$tmpdir/inhibit-attempts"
rm -f "$inhibit_attempts"
OMARCHY_PATH="$mock_omarchy" \
  PATH="$mock_bin:$PATH" \
  PRODUCER_PID_FILE="$producer_pid_file" \
  LOCK_LOG="$lock_log" \
  INHIBIT_ATTEMPTS="$inhibit_attempts" \
  "$sleep_monitor"

[[ $(<"$lock_log") == "locked" ]] ||
  fail "sleep monitor locks after logind rejects the first inhibitor"
[[ $(<"$inhibit_attempts") == "2" ]] ||
  fail "sleep monitor retries an inhibitor rejected as already running" \
    "attempts: $(<"$inhibit_attempts")"
pass "sleep monitor retries an inhibitor rejected as already running"

# The rejection capture must not swallow the lock helper's warnings, such as a
# report that the machine is suspending without a secure lock.
cat >"$mock_omarchy/bin/omarchy-system-sleep-lock" <<'SH'
#!/bin/bash

echo locked >>"$LOCK_LOG"
echo "suspending without a secure lock" >&2
SH
: >"$lock_log"
rm -f "$inhibit_attempts" "$producer_pid_file"
monitor_output=$(
  OMARCHY_PATH="$mock_omarchy" \
    PATH="$mock_bin:$PATH" \
    PRODUCER_PID_FILE="$producer_pid_file" \
    LOCK_LOG="$lock_log" \
    INHIBIT_ATTEMPTS="$inhibit_attempts" \
    "$sleep_monitor" 2>&1
)

[[ $monitor_output == *"suspending without a secure lock"* ]] ||
  fail "sleep monitor keeps the lock helper's warnings" "output: $monitor_output"
pass "sleep monitor keeps the lock helper's warnings"
