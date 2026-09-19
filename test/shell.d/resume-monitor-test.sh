#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

resume_monitor="$ROOT/bin/omarchy-system-resume-monitor"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
producer_pid_file="$tmpdir/producer-pid"
call_log="$tmpdir/calls"
mkdir -p "$mock_bin"
: >"$call_log"

# Emits a sleep event, a resume event, then another sleep/resume pair, to
# prove the monitor keeps running and calling into the shell on every resume
# rather than exiting after the first one -- unlike the pre-sleep monitor,
# this has no inhibitor lock tying it to a single event.
cat >"$mock_bin/dbus-monitor" <<'SH'
#!/bin/bash

echo "$$" >"$PRODUCER_PID_FILE"
printf '   boolean true\n'
printf '   boolean false\n'
printf '   boolean true\n'
printf '   boolean false\n'
exec sleep 30
SH
chmod +x "$mock_bin/dbus-monitor"

cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash

printf 'shell %s\n' "$*" >>"$CALL_LOG"
SH
chmod +x "$mock_bin/omarchy-shell"

PATH="$mock_bin:$PATH" CALL_LOG="$call_log" PRODUCER_PID_FILE="$producer_pid_file" \
  "$resume_monitor" &
monitor_pid=$!
sleep 0.5
kill "$monitor_pid" 2>/dev/null || true
wait "$monitor_pid" 2>/dev/null || true

mapfile -t calls <"$call_log"

[[ ${#calls[@]} -eq 2 && ${calls[0]} == "shell lock resume" && ${calls[1]} == "shell lock resume" ]] ||
  fail "resume monitor calls into the shell once per resume, ignoring sleep events" \
    "calls: ${calls[*]:-<none>}"
pass "resume monitor calls into the shell once per resume, ignoring sleep events"

# Terminating the monitor must also clean up the dbus-monitor producer instead
# of orphaning it -- this is the leak the systemd unit (Restart=always plus
# cgroup teardown) guards against; the script's own pipeline shouldn't leak
# one either when killed directly.
rm -f "$producer_pid_file"
cat >"$mock_bin/dbus-monitor" <<'SH'
#!/bin/bash

sleep 0.1
echo "$$" >"$PRODUCER_PID_FILE"
exec sleep 30
SH
chmod +x "$mock_bin/dbus-monitor"

PATH="$mock_bin:$PATH" CALL_LOG="$call_log" PRODUCER_PID_FILE="$producer_pid_file" \
  "$resume_monitor" &
monitor_pid=$!

for _ in {1..100}; do
  [[ -s $producer_pid_file ]] && break
  sleep 0.01
done
if [[ ! -s $producer_pid_file ]]; then
  kill "$monitor_pid" 2>/dev/null || true
  wait "$monitor_pid" 2>/dev/null || true
  fail "resume monitor starts its event producer"
fi

producer_pid=$(<"$producer_pid_file")
kill "$monitor_pid"
wait "$monitor_pid" 2>/dev/null || true

# The producer is allowed a moment to receive and act on the pipeline's own
# teardown before this counts as a leak.
for _ in {1..20}; do
  kill -0 "$producer_pid" 2>/dev/null || break
  sleep 0.05
done
if kill -0 "$producer_pid" 2>/dev/null; then
  kill "$producer_pid" 2>/dev/null || true
  fail "resume monitor cleans up its producer when the pipeline itself is terminated" \
    "producer still running: $producer_pid"
fi
pass "resume monitor cleans up its producer when the pipeline itself is terminated"

# --consume reads events straight off stdin, the same seam the pre-sleep
# monitor's tests use, so the parsing logic is testable without a real (or
# even mocked) dbus-monitor process.
rm -f "$call_log"
: >"$call_log"
printf '   boolean true\n   boolean false\n   garbage\n   boolean false\n' \
  | PATH="$mock_bin:$PATH" CALL_LOG="$call_log" "$resume_monitor" --consume

mapfile -t consume_calls <"$call_log"
[[ ${#consume_calls[@]} -eq 2 && ${consume_calls[0]} == "shell lock resume" && ${consume_calls[1]} == "shell lock resume" ]] ||
  fail "resume monitor --consume calls the shell only for boolean false lines" \
    "calls: ${consume_calls[*]:-<none>}"
pass "resume monitor --consume calls the shell only for boolean false lines"
