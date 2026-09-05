#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

sleep_monitor="$ROOT/bin/omarchy-system-sleep-monitor"

if grep -q 'exec dbus-monitor' "$sleep_monitor"; then
  fail "sleep monitor does not use dbus-monitor BecomeMonitor on the system bus"
fi
grep -q 'gdbus monitor --system' "$sleep_monitor" ||
  fail "sleep monitor subscribes to login1 with gdbus"
if grep -q 'boolean true' "$sleep_monitor"; then
  fail "sleep monitor does not treat dbus-monitor boolean true as a sleep event"
fi
pass "sleep monitor subscribes to login1 with gdbus"

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

cat >"$mock_bin/gdbus" <<'SH'
#!/bin/bash

echo "$$" >"$PRODUCER_PID_FILE"
printf '/org/freedesktop/login1: org.freedesktop.login1.Manager.PrepareForSleep (true,)\n'
exec sleep 30
SH

cat >"$mock_omarchy/bin/omarchy-system-sleep-lock" <<'SH'
#!/bin/bash

echo locked >>"$LOCK_LOG"
SH

chmod +x \
  "$mock_bin/systemd-inhibit" \
  "$mock_bin/gdbus" \
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
cat >"$mock_bin/gdbus" <<'SH'
#!/bin/bash

sleep 0.1
echo "$$" >"$PRODUCER_PID_FILE"
exec sleep 30
SH
chmod +x "$mock_bin/gdbus"
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

# gdbus monitor dumps every signal on the login1 object, including property
# changes whose payload contains true. Only PrepareForSleep (true is sleep.
: >"$lock_log"
OMARCHY_PATH="$mock_omarchy" LOCK_LOG="$lock_log" "$sleep_monitor" --consume <<'EOF'
   boolean true
/org/freedesktop/login1: org.freedesktop.DBus.Properties.PropertiesChanged ('org.freedesktop.login1.Manager', {'IdleHint': <true>}, @as [])
/org/freedesktop/login1: org.freedesktop.login1.Manager.PrepareForSleep (false,)
EOF
[[ ! -s $lock_log ]] ||
  fail "sleep monitor ignores non-sleep gdbus lines" "$(<"$lock_log")"
pass "sleep monitor ignores non-sleep gdbus lines"

OMARCHY_PATH="$mock_omarchy" LOCK_LOG="$lock_log" "$sleep_monitor" --consume <<'EOF'
/org/freedesktop/login1: org.freedesktop.login1.Manager.PrepareForSleep (true,)
EOF
[[ $(<"$lock_log") == "locked" ]] ||
  fail "sleep monitor locks on gdbus PrepareForSleep true" "$(<"$lock_log")"
pass "sleep monitor locks on gdbus PrepareForSleep true"
