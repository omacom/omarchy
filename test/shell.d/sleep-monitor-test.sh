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

# Restore event-emitting dbus-monitor for subsequent inhibit-retry tests (the
# termination block replaced it with a silent long sleep).
cat >"$mock_bin/dbus-monitor" <<'SH'
#!/bin/bash

echo "$$" >"$PRODUCER_PID_FILE"
printf '   boolean true\n'
exec sleep 30
SH
chmod +x "$mock_bin/dbus-monitor"
rm -f "$producer_pid_file" "$lock_log"

# logind can reject a delay inhibit while a sleep/wake is still
# settling. Retry that specific error instead of exiting 1 for systemd.
cat >"$mock_bin/systemd-inhibit" <<'SH'
#!/bin/bash

count_file="${INHIBIT_COUNT_FILE:?}"
count=0
[[ -f $count_file ]] && count=$(<"$count_file")
count=$((count + 1))
printf '%s\n' "$count" >"$count_file"

if (( count < 3 )); then
  echo "Failed to inhibit: The operation inhibition has been requested for is already running" >&2
  exit 1
fi

while [[ $1 == --* ]]; do
  shift
done

exec "$@"
SH
chmod +x "$mock_bin/systemd-inhibit"
rm -f "$lock_log"
inhibit_count="$tmpdir/inhibit-count"

OMARCHY_PATH="$mock_omarchy" \
  PATH="$mock_bin:$PATH" \
  PRODUCER_PID_FILE="$producer_pid_file" \
  LOCK_LOG="$lock_log" \
  INHIBIT_COUNT_FILE="$inhibit_count" \
  "$sleep_monitor"

[[ $(<"$lock_log") == "locked" ]] ||
  fail "sleep monitor retries an EBUSY delay inhibit" "lock log: $(<"$lock_log" 2>/dev/null || true)"
pass "sleep monitor retries an EBUSY delay inhibit"

[[ $(<"$inhibit_count") == "4" ]] ||
  fail "sleep monitor retries until inhibit succeeds" "attempts: $(<"$inhibit_count")"
pass "sleep monitor retries until inhibit succeeds"

# Unrelated inhibit failures must still fail the unit.
cat >"$mock_bin/systemd-inhibit" <<'SH'
#!/bin/bash
echo "Failed to inhibit: Permission denied" >&2
exit 1
SH
chmod +x "$mock_bin/systemd-inhibit"

if OMARCHY_PATH="$mock_omarchy" \
  PATH="$mock_bin:$PATH" \
  PRODUCER_PID_FILE="$producer_pid_file" \
  LOCK_LOG="$lock_log" \
  "$sleep_monitor" 2>"$tmpdir/inhibit-fail.err"; then
  fail "sleep monitor still fails unrelated inhibit errors"
fi
grep -Fq "Permission denied" "$tmpdir/inhibit-fail.err" ||
  fail "sleep monitor reports unrelated inhibit errors"
pass "sleep monitor still fails unrelated inhibit errors"

