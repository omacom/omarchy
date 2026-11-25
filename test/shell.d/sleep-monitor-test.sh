#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

sleep_monitor="$ROOT/bin/omarchy-system-sleep-monitor"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
mock_omarchy="$tmpdir/omarchy"
producer_pid_file="$tmpdir/producer-pid"
event_log="$tmpdir/event-log"
mkdir -p "$mock_bin" "$mock_omarchy/bin"

# Logs when the delay inhibitor is taken and released, which is for as long as
# the command it runs lives.
cat >"$mock_bin/systemd-inhibit" <<'SH'
#!/bin/bash

while [[ $1 == --* ]]; do
  shift
done

if [[ -n ${INHIBIT_FAILS:-} ]]; then
  exit 1
fi

echo "inhibitor taken" >>"$EVENT_LOG"
"$@"
status=$?
echo "inhibitor released" >>"$EVENT_LOG"
exit "$status"
SH

cat >"$mock_omarchy/bin/omarchy-system-sleep-lock" <<'SH'
#!/bin/bash

echo "locked" >>"$EVENT_LOG"
SH

cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash

echo "omarchy-shell $*" >>"$EVENT_LOG"
SH

chmod +x \
  "$mock_bin/systemd-inhibit" \
  "$mock_bin/omarchy-shell" \
  "$mock_omarchy/bin/omarchy-system-sleep-lock"
ln -s "$sleep_monitor" "$mock_omarchy/bin/omarchy-system-sleep-monitor"

# logind's signals for one suspend and the wake after it, then the bus goes away.
cat >"$mock_bin/dbus-monitor" <<'SH'
#!/bin/bash

echo "$$" >"$PRODUCER_PID_FILE"
printf 'signal time=1 member=PrepareForSleep\n   boolean true\n'
printf 'signal time=2 member=PrepareForSleep\n   boolean false\n'
SH
chmod +x "$mock_bin/dbus-monitor"

run_monitor() {
  OMARCHY_PATH="$mock_omarchy" \
    PATH="$mock_bin:$PATH" \
    PRODUCER_PID_FILE="$producer_pid_file" \
    EVENT_LOG="$event_log" \
    "$sleep_monitor"
}

run_monitor || true

mapfile -t events <"$event_log"
[[ ${events[0]:-} == "inhibitor taken" && ${events[1]:-} == "locked" && ${events[2]:-} == "inhibitor released" ]] ||
  fail "sleep monitor locks while holding the inhibitor, then releases it" "$(<"$event_log")"
pass "sleep monitor locks while holding the inhibitor, then releases it"

grep -v '^omarchy-shell' "$event_log" | sed -n 4p | grep -qx "inhibitor taken" ||
  fail "sleep monitor takes the inhibitor again after the wake" "$(<"$event_log")"
pass "sleep monitor takes the inhibitor again after the wake"

# The refresh runs alongside taking the inhibitor again, so it may land last.
for _ in {1..100}; do
  grep -q '^omarchy-shell' "$event_log" && break
  sleep 0.01
done
[[ $(grep '^omarchy-shell' "$event_log" || true) == "omarchy-shell -q omarchy.clock refresh" ]] ||
  fail "sleep monitor refreshes the bar clock once after the wake" "$(<"$event_log")"
pass "sleep monitor refreshes the bar clock once after the wake"

# A failed inhibit (logind still finishing a sleep, say) must end the monitor
# so systemd retries it, without orphaning the event producer.
cat >"$mock_bin/dbus-monitor" <<'SH'
#!/bin/bash

echo "$$" >"$PRODUCER_PID_FILE"
exec sleep 30
SH
chmod +x "$mock_bin/dbus-monitor"
rm -f "$producer_pid_file" "$event_log"

start_us=${EPOCHREALTIME//[!0-9]/}
if INHIBIT_FAILS=1 run_monitor; then
  fail "sleep monitor exits with an error when the inhibitor cannot be taken"
fi
elapsed_us=$((10#${EPOCHREALTIME//[!0-9]/} - 10#$start_us))
(( elapsed_us < 2000000 )) ||
  fail "sleep monitor exits with an error when the inhibitor cannot be taken" "elapsed: ${elapsed_us}us"
pass "sleep monitor exits with an error when the inhibitor cannot be taken"

for _ in {1..100}; do
  [[ -s $producer_pid_file ]] && break
  sleep 0.01
done
producer_pid=$(<"$producer_pid_file")
if kill -0 "$producer_pid" 2>/dev/null; then
  kill "$producer_pid" 2>/dev/null || true
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
  EVENT_LOG="$event_log" \
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
